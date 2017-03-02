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
    public class LocationService
    {
        public static string GetStateName(int code)
        {
            try
            {

                string WURL = System.Configuration.ConfigurationManager.AppSettings["MifWebServiceUrl"].ToString();
                string url = WURL + "/state?id=" + code;
                WebRequest request = WebRequest.Create(url);

                WebResponse ws = request.GetResponse();
                DataContractJsonSerializer jsonSerializer = new DataContractJsonSerializer(typeof(State));
                State country = (State)jsonSerializer.ReadObject(ws.GetResponseStream());
                if (country != null)
                    return country.state;
                else
                {
                    return "";
                }
            }
            catch (Exception)
            {
                return "";
            }



        }

        public static string GetStateName(string code)
        {
       
            try
            {
                try
                {
                    int u = int.Parse(code);

                }
                catch (Exception)
                {
                    return code;

                }

                return LocationService.GetStateName(Convert.ToInt32(code));

            }
            catch
            {
                return String.Empty;
            }
        
        }
        public static string GetCountryName(string code)
        {
            try
            {
                string WURL= System.Configuration.ConfigurationManager.AppSettings["MifWebServiceUrl"].ToString();

                string url = WURL + "/country?id=" + code;

                WebRequest request = WebRequest.Create(url);
                WebResponse ws = request.GetResponse();
                DataContractJsonSerializer jsonSerializer = new DataContractJsonSerializer(typeof(Country));
                Country country = (Country)jsonSerializer.ReadObject(ws.GetResponseStream());
                if (country != null)
                    return country.country;
                else
                {
                    return "";
                }
            }
            catch (Exception)
            {

                return "";//registar error
            }



        }

        public static List<SearchCityDTO> Geocode(string country, string region, string city, decimal lat, decimal lon)
        {
            try
            {
                string WURL = System.Configuration.ConfigurationManager.AppSettings["MifWebServiceUrl"].ToString();
                string url = WURL + "/info?country=" + country + "&stateName=" + region + "&cityName=" + city + "&lat=" +
                             lat.ToString() + "&lon=" + lon.ToString();
                WebRequest request = WebRequest.Create(url);
                WebResponse ws = request.GetResponse();
                DataContractJsonSerializer jsonSerializer = new DataContractJsonSerializer(typeof(SearchCityDTO));
                List<SearchCityDTO> dtoObj = (List<SearchCityDTO>)jsonSerializer.ReadObject(ws.GetResponseStream());
                if (dtoObj != null)
                    return dtoObj;
                return null;
            }
            catch (Exception)
            {

                return null;
            }
        }

        public static string GetCityName(int code)
        {
            try
            {
                string WURL = System.Configuration.ConfigurationManager.AppSettings["MifWebServiceUrl"].ToString();
                string url = WURL + "/city?id=" + code;
                WebRequest request = WebRequest.Create(url);
                WebResponse ws = request.GetResponse();
                DataContractJsonSerializer jsonSerializer = new DataContractJsonSerializer(typeof(City));
                City country = (City)jsonSerializer.ReadObject(ws.GetResponseStream());
                if (country != null)
                    return country.city;
                else
                {
                    return "";
                }
            }
            catch (Exception)
            {

                return "";//registar error
            }


        }

        public static string GetCityName(string code)
        {
            try
            {
                try
                {
                    int u = int.Parse(code);

                }
                catch (Exception)
                {
                    return code;

                }

                return LocationService.GetCityName(Convert.ToInt32(code));

            }
            catch
            {
                return String.Empty;
            }
        }
        
    }



    /// <summary>
    /// class estructure compatible with Json
    /// </summary>
    public class Country
    {
        public string country { get; set; }
        public string code { get; set; }

    }

    /// <summary>
    /// class structure compatible with Json
    /// </summary>
    public class State
    {
        public string state { get; set; }
        public string code { get; set; }

    }

    /// <summary>
    /// class structure compatible with Json
    /// </summary>
    public class City
    {
        public string city { get; set; }
        public string code { get; set; }

    }

    public class SearchCityDTO
    {
        public int Total { get; set; }
        public int Score_City { get; set; }
        public int Diference_City { get; set; }
        public int Score_State { get; set; }
        public int Diference_State { get; set; }
        public double? Total_Distance { get; set; }

        public string Country_Code { get; set; }
        public string Country_Name { get; set; }

        public int State_Code { get; set; }
        public string State_Name { get; set; }


        public int City_Code { get; set; }
        public string City_Name { get; set; }

        public double? City_Lat { get; set; }
        public double? City_Lon { get; set; }

        public double? State_Lat { get; set; }
        public double? State_Lon { get; set; }
    }

}
