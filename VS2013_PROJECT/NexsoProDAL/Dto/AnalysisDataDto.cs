using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NexsoProDAL.Dto
{
    /// <summary>
    /// Author: Jesús Alberto Correa
    /// Date: 14/12/2015
    /// Description: DTO  for save data after analysis Web Api
    /// Update: 
    /// </summary>
    [Serializable]
    public class AnalysisDataDto
    {
        public string analysisDataId { get; set; }
        public Guid objectId { get; set; }
        public string objectType { get; set; }
        public string typeKey { get; set; }
        public string value { get; set; }
        public DateTime dateCreation { get; set; }
        public DateTime dateUpdate { get; set; }

    }
}
