#region [Using]
using NexsoProDAL;
using NexsoProDAL.Dto;
using System;
using System.Collections.Generic;
using System.Linq;
#endregion

namespace NexsoProBLL
{
    /// <summary>
    /// Author: Jesús Alberto Correa
    /// Date: 15/12/2015
    /// Description: Class to manage the Indexed  of information
    /// Update: 
    /// </summary>
    public class IndexDataComponent
    {
        #region [Variables]
        private MIFNEXSOEntities mifnexsoEntities;
        #endregion

        #region [Method of class AnalysisDataIndex]

        /// <summary>
        /// This method gets All Records found in table solution.
        /// But not in the tabla of dataAnalysis.
        /// To make data analysis
        /// </summary>
        /// <returns>Return list of solutions for analysis data</returns>
        public List<DataIndexDto> GetDataAnalysis()
        {
            var lReturn = new List<DataIndexDto>();

            using (mifnexsoEntities = new MIFNEXSOEntities())
            {
                lReturn = (from a in mifnexsoEntities.Solution
                           join b in mifnexsoEntities.AnalysisDatas on a.SolutionId equals b.ObjectId into joined
                           from b in joined.DefaultIfEmpty()
                           where a.Deleted != true && b.ObjectId == null
                           select new DataIndexDto
                           {
                               solutionId = a.SolutionId,
                               title = a.Title,
                               tagline = a.TagLine,
                               challenge = a.Challenge,
                               approach = a.Approach,
                               results = a.Results,
                               implementationDetails = a.ImplementationDetails,
                               durationDetails = a.DurationDetails,
                               description = a.Description,
                               lenguege = a.Language
                           }).Take(100).ToList();
            }

            return lReturn;
        }

        /// <summary>
        /// This method saves the information of the analysis by the web Api
        /// </summary>
        /// <param name="listForAnalysisData"></param>
        /// <returns></returns>
        public void SaveAnalisysData(List<AnalysisDataDto> listForAnalysisData)
        {
            using (mifnexsoEntities = new MIFNEXSOEntities())
            {
                foreach (AnalysisDataDto item in listForAnalysisData)
                {
                    var objInsert = new AnalysisData();

                    objInsert.AnalysisDataId = Guid.NewGuid();
                    objInsert.ObjectId = item.objectId;
                    objInsert.ObjectType = item.objectType;
                    objInsert.TypeKey = item.typeKey;
                    objInsert.Value = item.value;
                    objInsert.DateCreated = System.DateTime.Now;
                    objInsert.DateUpdated = System.DateTime.Now;

                    mifnexsoEntities.AnalysisDatas.AddObject(objInsert);

                }
                mifnexsoEntities.SaveChanges();
            }
        }

        #endregion

        #region [Method of class IndexationDataAnalisys]

        /// <summary>
        /// This method retrieves the information to index a stored procedure 
        /// and the retrives information is encapsulated in DTO
        /// </summary>
        /// <returns></returns>
        public List<IndexDataDto> GetDataForIndex()
        {

            var lReturn = new List<IndexDataDto>();

            using (mifnexsoEntities = new MIFNEXSOEntities())
            {
                lReturn = (from a in mifnexsoEntities.spGetDataIndex()
                           select new IndexDataDto
                           {
                               objectId = a.ObjectId.GetValueOrDefault(Guid.Empty),

                               title =a.Title,
                               organizationName=a.OrganizationName,
                               scoreValue=a.ScoreValue.GetValueOrDefault(1),
                               fullRequest = a.FullText,
                               keywords = a.Keywords,
                               sentences = a.Sentences,
                               concepts = a.ConceptsMember,
                               language = a.Language, 
                               category = a.Category,
                               key = a.keys,
                               label = a.Label,
                               country = a.Country,
                               region = a.Region,
                               city = a.City

                           }).ToList();
            }
            return lReturn;
        }

        /// <summary>
        /// This method Update States indexed in the table AnalysisData
        /// </summary>
        /// <returns></returns>
        public void UpdateIndexingStates(List<Guid> listRequestUpdateState)
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            // Massive upgrade registration status of indexing documents
            mifnexsoEntities.AnalysisDatas.Where(x => listRequestUpdateState.Contains(x.ObjectId)).ToList().ForEach(a => a.Indexed = true);
            mifnexsoEntities.SaveChanges();
        }

        #endregion

        #region [Method of class DeleteDataIndex]

        /// <summary>
        /// This method Delete record in the table AnalysisData
        /// </summary>
        /// <param name="objectId"></param>
        public void DeleteDataAnalysis(Guid objectId)
        {
            using (mifnexsoEntities = new MIFNEXSOEntities())
            {
                // Massive Delete documents of entity AnalysisData
                mifnexsoEntities.AnalysisDatas.Where(p => p.ObjectId == objectId).ToList().ForEach(p => mifnexsoEntities.AnalysisDatas.DeleteObject(p));
                mifnexsoEntities.SaveChanges();
            }
        }

        #endregion

    }
}
