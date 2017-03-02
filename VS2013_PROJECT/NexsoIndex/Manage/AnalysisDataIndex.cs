#region [Using]
using Aylien.TextApi;
using NexsoIndex.Enums;
using NexsoProBLL;
using NexsoProDAL;
using NexsoProDAL.Dto;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading;
#endregion

namespace NexsoIndex.Manage
{
    /// <summary>
    /// Author: Jesús Alberto Correa
    /// Date: 15/12/2015
    /// Description: Class to manage the analysis of information
    /// Update: 
    /// </summary>
    public class AnalysisDataIndex
    {
        #region [Main Method]

        public bool GetDataForIndex()
        {
            // Variable that determines whether there information to indexed and procces
            bool lReturn = false;
            //Counter for calles to the Apli
            int countGetDataForApi = 0;
            //Local Variebles for the analysis of information and aplication flow
            List<AnalysisDataDto> listForAnalysisData = new List<AnalysisDataDto>();

            try
            {
                // The list of information of the data obtainded to index
                List<DataIndexDto> listData = new IndexDataComponent().GetDataAnalysis();

                // if list have more o items this line runs
                if (listData.Count > 0)
                    GetDataForApi(ref listData, ref listForAnalysisData, ref countGetDataForApi);

                // if list have more o items this line runs
                if (listForAnalysisData.Count > 0)
                {
                    new IndexDataComponent().SaveAnalisysData(listForAnalysisData);
                }

                lReturn = true;
            }
            catch (InvalidOperationException iex)
            {
                //This message es throw by closing conection with api and the system know to manager
                if (iex.Message.Contains("Error Api Aylien"))
                    if (listForAnalysisData.Count > 0)
                        new IndexDataComponent().SaveAnalisysData(listForAnalysisData);

                throw iex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return lReturn;
        }


        /// <summary>
        /// This method manages the call to the Web Services API to obtain analysis information
        /// </summary>
        /// <param name="listForIndex">the references list the infordata for index</param>
        /// <param name="listForAnalysisData">this is the list of data get of data base for analysis</param>
        private void GetDataForApi(ref List<DataIndexDto> listData, ref List<AnalysisDataDto> listForAnalysisData, ref int countGetDataForApi)
        {
            //This Linea clear the list data for analysis
            listForAnalysisData.Clear();

            //This line gets a class records enumeration
            var endpointsList = Enum.GetNames(typeof(EndpointEnum));

            //Local Variebles for the analysis of information and aplication flow
            string textForAnalysis = string.Empty;

            //Local Variebles delimeter text concat
            string delimeter = ", ";

            string appId = System.Configuration.ConfigurationManager.AppSettings["AppId"];
            string appKey = System.Configuration.ConfigurationManager.AppSettings["AppKey"];

            if (string.IsNullOrEmpty(appId) || string.IsNullOrEmpty(appKey))
                throw new InvalidOperationException("They could not be obtained passwords API Aylien web config");

            foreach (DataIndexDto item in listData)
            {
                var validateRequest = listForAnalysisData.Where(x => x.objectId == item.solutionId).FirstOrDefault();
                if (validateRequest == null)
                {
                    //This try ensures the continuity of the cycle so a reord fails
                    try
                    {
                        //Text for Analysis
                        textForAnalysis = string.Empty;
                        textForAnalysis = string.Format("{0} {1} {2} {3} {4} {5} {6} {7}",
                                                             item.title, item.tagline, item.challenge, item.approach, item.results, item.implementationDetails, item.durationDetails, item.description);

                        WebUtility.HtmlDecode(textForAnalysis);

                        Client client = new Client(appId, appKey);

                        var combined = client.Combined(url: null, text: textForAnalysis, endpoints: endpointsList);

                        if (combined.Entities.EntitiesMember.Keyword != null)
                            if (combined.Entities.EntitiesMember.Keyword.ToList().Count > 0)
                            {
                                //Get the Keywords of analysis data
                                var ObjAnalysisDataKeyword = GetKeywords(item.solutionId, combined.Entities.EntitiesMember.Keyword.ToList(), delimeter);
                                listForAnalysisData.Add(ObjAnalysisDataKeyword);
                            }

                        if (combined.Concepts.ConceptsMember != null)
                            if (combined.Concepts.ConceptsMember.ToList().Count > 0)
                            {
                                //Get the Concepts  of analysis data
                                var ObjAnalysisDataConceptsMember = GetConcepts(item.solutionId, combined.Concepts.ConceptsMember.ToList(), delimeter);
                                if (ObjAnalysisDataConceptsMember != null)
                                    listForAnalysisData.Add(ObjAnalysisDataConceptsMember);
                            }

                        if (combined.Summarize.Sentences != null)
                            if (combined.Summarize.Sentences.ToList().Count > 0)
                            {
                                //Get the Sentences of analysis data
                                var ObjAnalysisDataSentences = GetSentences(item.solutionId, combined.Summarize.Sentences.ToList(), delimeter);
                                listForAnalysisData.Add(ObjAnalysisDataSentences);
                            }
                    }
                    catch (Aylien.TextApi.Error e)
                    {
                        string msg = string.Format("Error Api Aylien: {0} ({1})", e.Message, e.Status.ToString());

                        switch (e.Status)
                        {
                            case (HttpStatusCode)429:
                                if (e.Message.ToString().Contains("hits per minute"))
                                {
                                    //Too Many Requests: 63 out of 60 hits per minute
                                    Thread.Sleep(72000);
                                    break;
                                }
                                else
                                {
                                    //Too Many Requests: 1003 out of 1000 hits per day
                                    throw new InvalidOperationException(msg);
                                }
                            default: throw new InvalidOperationException(msg);
                        }
                    }
                }
            }
        }

        #endregion

        #region [Help Methods]

        /// <summary>
        /// This Methodo gets the keywords of analysis
        /// </summary>
        /// <param name="solutionId">This is the Id of Solution</param>
        /// <param name="listKeywords">this is the list of Keywords</param>
        /// <param name="delimeter">this is string for delimit the object return</param>
        /// <returns>Return object with the keywords</returns>
        private AnalysisDataDto GetKeywords(Guid solutionId, List<string> listKeywords, string delimeter)
        {
            var objReturn = new AnalysisDataDto();

            objReturn.objectId = solutionId;
            objReturn.objectType = Enum.GetName(typeof(ObjectTypeEnum), ObjectTypeEnum.Solution);
            objReturn.typeKey = Enum.GetName(typeof(TypeKeyEnum), TypeKeyEnum.Keywords);
            objReturn.value = (listKeywords.Aggregate((i, j) => i + delimeter + j));

            return objReturn;
        }

        /// <summary>
        /// This Methodo gets the Concepts of analysis
        /// </summary>
        /// <param name="solutionId">This is the Id of Solution</param>
        /// <param name="listConceptsMember">this is the list of Concepts</param>
        /// <param name="delimeter">this is string for delimit the object return</param>
        /// <returns></returns>
        private AnalysisDataDto GetConcepts(Guid solutionId, List<KeyValuePair<string, Concept>> listConceptsMember, string delimeter)
        {
            var objReturn = new AnalysisDataDto();
            var listConcepts = new List<string>();

            foreach (var concept in listConceptsMember)
            {
                if (concept.Value.SurfaceForms.ToList().Count > 0)
                {
                    foreach (var item in concept.Value.SurfaceForms.ToList())
                    {
                        listConcepts.Add(item.String);
                    }
                }
            }

            if (listConcepts.Count > 0)
            {
                objReturn.objectId = solutionId;
                objReturn.objectType = Enum.GetName(typeof(ObjectTypeEnum), ObjectTypeEnum.Solution);
                objReturn.typeKey = Enum.GetName(typeof(TypeKeyEnum), TypeKeyEnum.ConceptsMember);
                objReturn.value = (listConcepts.Aggregate((i, j) => i + delimeter + j));
            }

            return objReturn;
        }

        /// <summary>
        /// This Methodo gets the Sentences of analysis
        /// </summary>
        /// <param name="solutionId">This is the Id of Solution</param>
        /// <param name="listSentences">This is the list of Sentences</param>
        /// <param name="delimeter">this is string for delimit the object return</param>
        /// <returns></returns>
        private AnalysisDataDto GetSentences(Guid solutionId, List<string> listSentences, string delimeter)
        {
            var objReturn = new AnalysisDataDto();

            objReturn.objectId = solutionId;
            objReturn.objectType = Enum.GetName(typeof(ObjectTypeEnum), ObjectTypeEnum.Solution);
            objReturn.typeKey = Enum.GetName(typeof(TypeKeyEnum), TypeKeyEnum.Sentences);
            objReturn.value = (listSentences.Aggregate((i, j) => i + delimeter + j));

            return objReturn;
        }
        #endregion
    }
}
