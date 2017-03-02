#region [Using]
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
#endregion

namespace NexsoProDAL.Dto
{
    /// <summary>
    /// Author: Jesús Alberto Correa
    /// Date: 16/12/2015
    /// Description: DTO for get  Solutions and Analysis Data for Index with Lucene
    /// Update: 
    /// </summary>
    [Serializable]
    public class IndexDataDto
    {
        public Guid objectId { get; set; }
        public string title { get; set; }
        public string organizationName { get; set; }
        public int scoreValue { get; set; }
        public string fullRequest { get; set; }
        public string sentences { get; set; }
        public string keywords { get; set; }
        public string concepts { get; set; }
        public string language { get; set; }
        public string category { get; set; } 
	    public string key { get; set; } 
	    public string label { get; set; } 
	    public string country { get; set; } 
	    public string region { get; set; }
	    public string city { get; set; }

    }
}
