#region Using
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks; 
#endregion

namespace NexsoIndex.Enums
{
    /// <summary>
    /// Author: Jesús Alberto Correa
    /// Date: 14/12/2015
    /// Description: Management class for listing the type of data indexed with Lucene
    /// Update: 
    /// </summary>
    public enum EndpointEnum
    {
        entities, 
        concepts, 
      //classify, 
      //extract, 
      //hashtags, 
      //sentiment, 
        summarize
    }
}
