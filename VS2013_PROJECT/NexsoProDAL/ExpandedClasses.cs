using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Objects.DataClasses;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Resources;
using System.Text;



namespace NexsoProDAL
{
    //public partial class List : EntityObject
    //{
    //    public CultureInfo CurrentCulture { get; set; }

    //    public string Name
    //    {
    //        get
    //        {
    //            try
    //            {
    //                string resource = ConfigurationManager.AppSettings["NXListResourceFile"];// +CurrentCulture.EnglishName + ".resx";
    //                string filePath = System.AppDomain.CurrentDomain.BaseDirectory.ToString();
                   
    //                ResourceManager rm = new ResourceManager(resource, Assembly.Load(new AssemblyName("app_GlobalResources")));

    //                string return_ = rm.GetString(Key,CurrentCulture);

    //                if (!string.IsNullOrEmpty(return_))
    //                    return return_;
    //                else
    //                {
    //                    return Key;
    //                }
    //            }
    //            catch (Exception)
    //            {
    //                return Key;
    //            }
               
    //        }
    //    }
    //}
}
