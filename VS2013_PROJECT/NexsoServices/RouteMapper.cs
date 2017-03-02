using System;
using DotNetNuke.Web.Api;
using System.Web.Http;
using System.Web.Routing;
using System.Net.Http;
using Swagger.Net;
using Swagger;

namespace NexsoServices
{
    public class RouteMapper : IServiceRouteMapper
    {
        public void RegisterRoutes(IMapRoute mapRouteManager)
        {
            mapRouteManager.MapHttpRoute("NexsoServicesV2", "HelpApiSpec",
             "api.docs/{controllerDisplay}", new { controller = "Swagger", action = "GetHelpDummy", name = "GetHelpDummy", swagger = true, namespaceDescriptor = "NexsoServices.V2", moduleName = "NexsoServicesV2" }, new[] { "Swagger.Net" });
            //mapRouteManager.MapHttpRoute("NexsoServicesV2", "HelpApiGen",
            // "api.docs", new { controller = "Swagger", action = "GetHelp", namespaceDescriptor = "NexsoServices.V2", moduleName = "NexsoServicesV2" }, new[] { "Swagger.Net" });

            mapRouteManager.MapHttpRoute("NexsoServicesV2", "HelpApiGen",
            "api.docs/", new { controller = "Swagger", action = "GetHelp" }, new[] { "Swagger.Net" });

            mapRouteManager.MapHttpRoute("NexsoServices", "default", "{controller}/{action}", new[] { "NexsoServices" });
            mapRouteManager.MapHttpRoute("NexsoServicesV2", "default", "{controller}/{action}", new[] { "NexsoServices.V2" });
            //mapRouteManager.MapHttpRoute("NexsoServicesV2", "SwaggerApi",
            //    "docs/{controller}", new { swagger = true }, new[] { "Swagger.Net" });
            //mapRouteManager.MapHttpRoute("NexsoServicesHelp", "defaulthelp", "{controller}/help", new { action="Anonymous", swagger = true }, new[] { "Swagger.Net", "NexsoServices.V2" });

           

            

        }
    }
}
