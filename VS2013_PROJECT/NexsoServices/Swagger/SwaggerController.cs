using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Reflection;
using System.Web;
using System.Web.Http;
using DotNetNuke.Entities.Portals;
using DotNetNuke.Entities.Users;
using DotNetNuke.Security.Roles;
using DotNetNuke.Web.Api;

namespace Swagger.Net
{
    [AllowAnonymous]
    public class SwaggerController : DnnApiController
    {
        /// <summary>
        /// Get the resource description of the api for swagger documentation
        /// </summary>
        /// <remarks>It is very convenient to have this information available for generating clients. This is the entry point for the swagger UI
        /// </remarks>
        /// <returns>JSON document representing structure of API</returns>
        [AllowAnonymous]
        [HttpGet]
        public HttpResponseMessage GetHelp()
        {
          string  namespaceDescriptor = "NexsoServices.V2", moduleName = "NexsoServicesV2";

            
            var docProvider = (XmlCommentDocumentationProvider)GlobalConfiguration.Configuration.Services.GetDocumentationProvider();

            //ResourceListing r = SwaggerGen.CreateResourceListing(ControllerContext);

            Uri uri = Request.RequestUri;

            ResourceListingL r =  new ResourceListingL()
            {
                apiVersion = Assembly.GetCallingAssembly().GetType().Assembly.GetName().Version.ToString(),
                swaggerVersion = SwaggerGen.SWAGGER_VERSION,
                basePath = uri.GetLeftPart(UriPartial.Authority) + HttpRuntime.AppDomainAppVirtualPath.TrimEnd('/'),
                apis = new List<ResourceApiL>()
            };

            r.basePath = r.basePath + "/DesktopModules/NexsoServicesV2/API/api.docs";
            
//#if DEBUG

//            r.basePath=r.basePath.Replace("/DesktopModules/", "/nexso/DesktopModules/");

//#endif
            List<string> uniqueControllers = new List<string>();


            //foreach (var api in GlobalConfiguration.Configuration.Services.GetApiExplorer().ApiDescriptions)
            //{
                

            //    string controllerName = api.ActionDescriptor.ControllerDescriptor.ControllerName;
            //    if (uniqueControllers.Contains(controllerName) ||
            //          controllerName.ToUpper().Equals(SwaggerGen.SWAGGER.ToUpper())) continue;

            //    uniqueControllers.Add(controllerName);

            //    ResourceApiL rApi = SwaggerGen.CreateResourceApi(api);
            //    r.apis.Add(rApi);
            //}

            foreach (var api in GlobalConfiguration.Configuration.Services.GetApiExplorer().ApiDescriptions)
            {


                string controllerName = api.ActionDescriptor.ControllerDescriptor.ControllerName;

                if (!api.RelativePath.ToUpper().Contains((moduleName + "/API/" + namespaceDescriptor).ToUpper()))
                    continue;


                if (uniqueControllers.Contains(controllerName) ||
                      controllerName.ToUpper().Equals(SwaggerGen.SWAGGER.ToUpper())) continue;

                uniqueControllers.Add(controllerName);


                ResourceApiL rt = new ResourceApiL();
                rt.description = " ";
                rt.path = "/" + controllerName;
                r.apis.Add(rt);
            }

        
          
            HttpResponseMessage resp = new HttpResponseMessage();

            resp.Content = new ObjectContent<ResourceListingL>(r, ControllerContext.Configuration.Formatters.JsonFormatter);            
            
            return resp;
        }

          [AllowAnonymous]
        [HttpGet]
        public HttpResponseMessage GetHelpDummy()
        {
            return null;
        }
    }
}
