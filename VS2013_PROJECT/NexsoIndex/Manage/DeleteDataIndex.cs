#region [Using]
using NexsoProBLL;
using System;
using Lucene.Net.Analysis;
using Lucene.Net.Analysis.Standard;
using Lucene.Net.Index;
using Lucene.Net.Store;
using Directory = Lucene.Net.Store.Directory;
using Version = Lucene.Net.Util.Version;
using System.IO;
#endregion


namespace NexsoIndex.Manage
{
    /// <summary>
    /// Author: Jesús Alberto Correa
    /// Date: 29/12/2015
    /// Description: Class for the elimination of record in the table
    /// AnalysisData and Lucene files
    /// Update: 
    /// </summary>
    public class DeleteDataIndex
    {
        //TODO: Alberto = Esta clase se debe de llamar desde el método donde se actualice o elimine algún registro de las soluciones
        public void DeleteDataIndexed(Guid objectId)
        {
            try
            {
                //This Line calls the method that eliminates DeleteDataAnlysis records tahble if there Analisys Data
                new IndexDataComponent().DeleteDataAnalysis(objectId);

                DirectoryInfo directoryInfo = null;
                string directoryPath = NexsoHelper.AssemblyDirectory.Replace("bin", "App_Data");
                directoryInfo = new DirectoryInfo(directoryPath + SettingsAppIndex.Default.LuceneFullPath);
                
                // If directory Info is not null, call method of delete riquest of Lucene
                if (directoryInfo != null)
                    DeleteFileLucene(directoryInfo, objectId);
            }
            catch (Exception ex)
            {
                DotNetNuke.Services.Exceptions.Exceptions.LogException(ex);
            }
        }

        /// <summary>
        /// This method delete request of archices Lucene
        /// </summary>
        /// <param name="directoryInfo">Path of directory execute</param>
        /// <param name="objectId"> Id of object to remove</param>
        private void DeleteFileLucene(DirectoryInfo directoryInfo, Guid objectId)
        {
            using (Directory directory = FSDirectory.Open(directoryInfo))
            using (Analyzer analyzer = new StandardAnalyzer(Version.LUCENE_30))
            using (var writer = new IndexWriter(directory, analyzer, false, new IndexWriter.MaxFieldLength(10000)))
            {
                Term idTerm = new Term("ObjetcId", objectId.ToString());

                if (idTerm != null)
                    writer.DeleteDocuments(idTerm);

                writer.Optimize();
                writer.Flush(true, true, true);
            }

        }
    }
}
