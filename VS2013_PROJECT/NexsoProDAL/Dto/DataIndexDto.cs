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
    /// Description: DTO for get  Data Solutions Analysis wep Api
    /// Update: 
    /// </summary>

    [Serializable]
    public class DataIndexDto
    {
        //Atributes for entity Solution
        public Guid solutionId { get; set; }

        public string title { get; set; }

        public string tagline { get; set; }

        public string challenge { get; set; }

        public string approach { get; set; }

        public string results { get; set; }

        public string implementationDetails { get; set; }

        public string durationDetails { get; set; }

        public string description { get; set; }

        public string lenguege { get; set; }

    }
}
