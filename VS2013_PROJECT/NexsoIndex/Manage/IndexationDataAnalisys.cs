#region [Using]
using NexsoProBLL;
using NexsoProDAL.Dto;
using System;
using System.Collections.Generic;
using Lucene.Net.Analysis;
using Lucene.Net.Analysis.Standard;
using Lucene.Net.Documents;
using Lucene.Net.Index;
using Lucene.Net.Store;
using Directory = Lucene.Net.Store.Directory;
using Version = Lucene.Net.Util.Version;
using System.IO;
using System.Reflection;
using System.Data.Entity;
using System.Linq;
using System.Text;
#endregion


namespace NexsoIndex.Manage
{
    public class IndexationDataAnalisys
    {

        /// <summary>
        /// Author: Jesús Alberto Correa
        /// Date: 16/12/2015
        /// Description: Class to manage the Indexed  of information
        /// Update: 
        /// </summary>
        public void IndexationData()
        {
            var listDataForIndex = new List<IndexDataDto>();

            DirectoryInfo directoryInfo;
            string directoryPath = NexsoHelper.AssemblyDirectory.Replace("bin", "App_Data");
            directoryInfo = new DirectoryInfo(directoryPath + SettingsAppIndex.Default.LuceneFullPath);

            //Get data for indexed
            listDataForIndex = new IndexDataComponent().GetDataForIndex();

            //If validate that the list has records for continuo proceses
            if (listDataForIndex.Count > 0)
                IndexedData(directoryInfo, listDataForIndex);
        }

        /// <summary>
        /// Method for create and indexed Informaction in Lucenen files
        /// </summary>
        /// <param name="directoryInfo"></param>
        /// <param name="listDataIndexed"></param>
        private void IndexedData(DirectoryInfo directoryInfo, List<IndexDataDto> listDataIndexed)
        {
            using (Directory directory = FSDirectory.Open(directoryInfo))
            using (Analyzer analyzer = new StandardAnalyzer(Version.LUCENE_30))
            using (var writer = new IndexWriter(directory, analyzer, new IndexWriter.MaxFieldLength(10000)))
            {
                //This list is for update State in the table AnalysisData whene object is indexed lucene file
                List<Guid> listRequestUpdateState = new List<Guid>();

                foreach (var item in listDataIndexed)
                {
                    var document = new Document();
                    string objectIdEx = item.objectId.ToString();
                    //This try validate that is there is some error in registration can continue the System
                    try
                    {
                        string fullRequest = string.Empty;
                        fullRequest = string.Format("{0} {1} {2} {3} {4} {5} {6} {7} {8} {9} {10} {11} {12}", item.fullRequest, item.title, item.keywords, item.sentences, item.concepts, item.language, item.category, item.key, item.label, item.country, item.region, item.city, item.organizationName);
                        fullRequest = NexsoHelper.DecodeHtmlAndRemoveAccents(fullRequest.ToLower());

                        if (!item.objectId.Equals(Guid.Empty))
                            document.Add(new Field("ObjetcId", item.objectId.ToString(), Field.Store.YES, Field.Index.NOT_ANALYZED));

                        if (!string.IsNullOrEmpty(item.fullRequest))
                            document.Add(new Field("Title", NexsoHelper.DecodeHtmlAndRemoveAccents(item.title), Field.Store.YES, Field.Index.ANALYZED));

                        if (!string.IsNullOrEmpty(item.fullRequest))
                            document.Add(new Field("OrganizationName", NexsoHelper.DecodeHtmlAndRemoveAccents(item.organizationName), Field.Store.YES, Field.Index.ANALYZED));


                        if (!string.IsNullOrEmpty(item.fullRequest))
                            document.Add(new Field("FullRequest", fullRequest, Field.Store.YES, Field.Index.ANALYZED));
                        document.Boost = item.scoreValue;
                        writer.AddDocument(document);
                        listRequestUpdateState.Add(item.objectId);
                    }
                    catch (Exception ex)
                    {
                        DotNetNuke.Services.Exceptions.Exceptions.LogException(ex);
                    }
                }
                writer.Optimize();
                writer.Flush(true, true, true);

                if (listRequestUpdateState.Count > 0)
                    UpdateStateIndex(listRequestUpdateState);
            }
        }

        /// <summary>
        /// This method update in the table Analysis Data all request which they were indexed
        /// </summary>
        /// <param name="listRequestUpdateState"></param>
        private void UpdateStateIndex(List<Guid> listRequestUpdateState)
        {
            new IndexDataComponent().UpdateIndexingStates(listRequestUpdateState);
        }

    }
}

