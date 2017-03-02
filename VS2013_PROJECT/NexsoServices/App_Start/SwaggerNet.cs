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

using System.Web.Http.Controllers;

[assembly: WebActivator.PreApplicationStartMethod(typeof(NexsoServices.App_Start.SwaggerNet), "PreStart")]
[assembly: WebActivator.PostApplicationStartMethod(typeof(NexsoServices.App_Start.SwaggerNet), "PostStart")]
namespace NexsoServices.App_Start
{



    public static class SwaggerNet
    {

        public static void PreStart()
        {
            //GlobalConfiguration.Configuration.Services.Replace(typeof(IAssembliesResolver), new CustomAssembliesResolver());
        }

        public static void PostStart()
        {

            var config = GlobalConfiguration.Configuration;

            config.Filters.Add(new SwaggerActionFilter());

            try
            {
                config.Services.Replace(typeof(IDocumentationProvider),
                    new XmlCommentDocumentationProvider(HttpContext.Current.Server.MapPath("~/bin/NexsoServices.XML")));
            }
            catch (FileNotFoundException)
            {
                throw new Exception("Please enable \"XML documentation file\" in project properties with default (bin\\NexsoServices.XML) value or edit value in App_Start\\SwaggerNet.cs");
            }
        }
    }


}