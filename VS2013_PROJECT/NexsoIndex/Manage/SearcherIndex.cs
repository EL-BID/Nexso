#region [Using]
using System;
using System.Collections.Generic;
using Lucene.Net.Analysis;
using Lucene.Net.Analysis.Standard;
using Lucene.Net.Index;
using Lucene.Net.Store;
using Lucene.Net.Search;
using Directory = Lucene.Net.Store.Directory;
using Version = Lucene.Net.Util.Version;
using System.IO;
using Lucene.Net.QueryParsers;
using System.Reflection;
using System.Threading.Tasks;
using Lucene.Net.Documents;
using System.Linq;

#endregion

namespace NexsoIndex.Manage
{
    /// <summary>
    /// Author: Jesús Alberto Correa
    /// Date: 17/12/2015
    /// Description: Class that performs the search in Lucene Indexed 
    /// Update: 
    /// </summary>
    public class SearcherIndex
    {
        /// <summary>
        /// </summary>
        /// <param name="textSearcher">This is a text for get data</param>
        /// <returns>List of all Id gets for the search in Lucene Indexed files</returns>
        public List<string> SearcherId(string textSearcher)
        {
            var lReturn = new List<string>();

            DirectoryInfo directoryInfo = null;
            string directoryPath = NexsoHelper.AssemblyDirectory.Replace("bin", "App_Data");
            directoryInfo = new DirectoryInfo(directoryPath + SettingsAppIndex.Default.LuceneFullPath);
            //This line is for remove Accents of text
            textSearcher =  NexsoHelper.DecodeHtmlAndRemoveAccents(textSearcher.ToLower());

            if (directoryInfo != null)
                GetDataIndexId(directoryInfo, ref textSearcher, ref lReturn);

            return lReturn;
        }

        #region [Method Help]
        private void GetDataIndexId(DirectoryInfo directoryInfo, ref string textSearcher, ref List<string> lReturn)
        {

            using (Directory directory = FSDirectory.Open(directoryInfo))
            using (Analyzer analyzer = new StandardAnalyzer(Version.LUCENE_30))
            using (IndexReader indexReader = IndexReader.Open(directory, true))
            using (Searcher indexSearcher = new IndexSearcher(indexReader))
            {
                TopScoreDocCollector collectorMultiPhraseQuery = TopScoreDocCollector.Create(100, true);
                TopScoreDocCollector collectorQueryParser = TopScoreDocCollector.Create(100, true);
                int docId = 0;
                string tempObjectId = string.Empty;
                List<string> listTemp = new List<string>();
                char[] delimiterChars = { ' ', ',', '.', ':', '\t' };

                MultiPhraseQuery multiPhraseQuery = new MultiPhraseQuery();

                //Here implement the search lines for graphs at level 3
                multiPhraseQuery.Slop = 3;

              

                foreach (var word in textSearcher.Split(delimiterChars))
                {
                    multiPhraseQuery.Add(new Term("FullRequest", word));
                }

                indexSearcher.Search(multiPhraseQuery, collectorMultiPhraseQuery);
                ScoreDoc[] listResultPharseQuery = collectorMultiPhraseQuery.TopDocs().ScoreDocs;

                foreach (var itemPharseQuery in listResultPharseQuery)
                {
                    docId = itemPharseQuery.Doc;
                    Document docPharseQuery = indexSearcher.Doc(docId);
                    tempObjectId = docPharseQuery.Get("ObjetcId");

                    if (!string.IsNullOrEmpty(tempObjectId))
                        listTemp.Add(tempObjectId);
                }

                //This lineas implement QueryPArse
                docId = 0;
                tempObjectId = string.Empty;

                var queryParser = new QueryParser(Version.LUCENE_30, "FullRequest", analyzer);
                var query = queryParser.Parse(textSearcher);

                indexSearcher.Search(query, collectorQueryParser);
                ScoreDoc[] listResultquery = collectorQueryParser.TopDocs().ScoreDocs;

                foreach (var itemQuery in listResultquery)
                {
                    docId = itemQuery.Doc;
                    Document docQuery = indexSearcher.Doc(docId);
                    tempObjectId = docQuery.Get("ObjetcId");

                    if (!string.IsNullOrEmpty(tempObjectId))
                        listTemp.Add(tempObjectId);
                }
                lReturn.AddRange(listTemp.Distinct().ToList());
            }
        }
        #endregion

    }
}
