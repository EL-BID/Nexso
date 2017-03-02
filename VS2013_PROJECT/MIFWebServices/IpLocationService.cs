using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Collections.Generic;
using System.Runtime.Serialization.Json;
using System.Configuration;

namespace MIFWebServices
{
    public class IpLocationService
    {
        public static IpLocation getIpLocation(string ip)
        {



            string WURL = System.Configuration.ConfigurationManager.AppSettings["MifWebServiceUrl"].ToString();
            string url = "http://www.telize.com/geoip/" + ip;

            

           

            
            
            WebRequest request = WebRequest.Create(url);

            WebResponse ws = request.GetResponse();
            DataContractJsonSerializer jsonSerializer = new DataContractJsonSerializer(typeof(IpLocation));
            IpLocation ipLocation = (IpLocation)jsonSerializer.ReadObject(ws.GetResponseStream());
            return ipLocation;
        }

    }

    public class IpLocation
    {
        public string ip {get;set;}
        public string country_code  {get;set;}
        public string country_code3  {get;set;}
        public string country  {get;set;}
        public string region_code  {get;set;}
        public string region  {get;set;}
        public string city  {get;set;}
        public string postal_code  {get;set;}
        public string continent_code  {get;set;}
        public string latitude  {get;set;}
        public string longitude  {get;set;}
        public string dma_code  {get;set;}
        public string area_code   {get;set;}
        public string asn   {get;set;}
        public string isp   {get;set;}
        public string timezone    {get;set;}

    }
}
