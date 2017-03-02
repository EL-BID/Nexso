using System;
using System.IO;
using System.Web;
using System.Web.Http;
using System.Web.Http.Description;
using System.Web.Http.Dispatcher;
using System.Web.Routing;
using Swagger.Net;
using System.Collections.Generic;
using System.Reflection;
using System.IO;
using System.Collections;
using System.Linq;
using NexsoServices.V2;



using System.Web.Http.Controllers;
[assembly: WebActivator.PreApplicationStartMethod(typeof(NexsoServices.App_Start.CorsHandlerStart), "PreStart")]
[assembly: WebActivator.PostApplicationStartMethod(typeof(NexsoServices.App_Start.CorsHandlerStart), "PostStart")]
namespace NexsoServices.App_Start
{
    public static class CorsHandlerStart
    {
         public static void PreStart()
        {
            //GlobalConfiguration.Configuration.Services.Replace(typeof(IAssembliesResolver), new CustomAssembliesResolver());
        }

         public static void PostStart()
         {

             var config = GlobalConfiguration.Configuration;
            config.MessageHandlers.Add(new CorsHandler());
            
         }
    }
}
