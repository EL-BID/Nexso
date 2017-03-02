using System;
using System.Linq;
using System.Net.Http;
using System.Reflection;
using System.Web.Http;
using System.Web.Http.Controllers;
using System.Web.Http.Filters;
using System.Web.Http.Description;
using DotNetNuke.Web.Api;
using DotNetNuke.Entities.Portals;
using DotNetNuke.Entities.Users;
using DotNetNuke.Security.Roles;
using System.Collections.Generic;
using System.Collections;
using System.Collections.ObjectModel;
using System.Web.Http.Routing;

namespace Swagger.Net
{
    /// <summary>
    /// Determines if any request hit the Swagger route. Moves on if not, otherwise responds with JSON Swagger spec doc
    /// </summary>
    public class SwaggerActionFilter : ActionFilterAttribute
    {
        /// <summary>
        /// Executes each request to give either a JSON Swagger spec doc or passes through the request
        /// </summary>
        /// <param name="actionContext">Context of the action</param>
        public override void OnActionExecuting(HttpActionContext actionContext)
        {
            var docRequest = actionContext.ControllerContext.RouteData.Values.ContainsKey(SwaggerGen.SWAGGER);

            dynamic controller = actionContext.ControllerContext.Controller;
            
            if (!docRequest)
            {
                base.OnActionExecuting(actionContext);
                return;
            }

            HttpResponseMessage response = new HttpResponseMessage();

            response.Content = new ObjectContent<ResourceListing>(
                getDocs(actionContext),
                actionContext.ControllerContext.Configuration.Formatters.JsonFormatter);

            actionContext.Response = response;
        }

      

        private ResourceListing getDocs(HttpActionContext actionContext)
        {
            var dataTypeRegistry = new DataTypeRegistry(null,null,null);
            string namespaceDescriptor=actionContext.ControllerContext.RouteData.Values["namespaceDescriptor"].ToString();
            string moduleName=actionContext.ControllerContext.RouteData.Values["moduleName"].ToString();
            string controllerDisplay = actionContext.ControllerContext.RouteData.Values["controllerDisplay"].ToString();
            var docProvider = (XmlCommentDocumentationProvider)GlobalConfiguration.Configuration.Services.GetDocumentationProvider();
            ResourceListing r = SwaggerGen.CreateResourceListing(actionContext);
            r.basePath = r.basePath; 

//#if DEBUG
//            r.basePath = r.basePath + "/nexso/";
//#endif
            r.resourcePath = controllerDisplay;
            var list=GlobalConfiguration.Configuration.Services.GetApiExplorer().ApiDescriptions;
            //var list = WebApiExtensions.GetAllApiDescriptions(GlobalConfiguration.Configuration.Services.GetApiExplorer(), actionContext.ControllerContext.Configuration);
            foreach (var api in list)
            {
                string apiControllerName = api.ActionDescriptor.ControllerDescriptor.ControllerName;
                if (api.Route.Defaults.ContainsKey(SwaggerGen.SWAGGER) ||
                    apiControllerName.ToUpper().Equals(SwaggerGen.SWAGGER.ToUpper())) 
                    continue;

               // var descriptor = actionContext.ControllerContext.RouteData.Route.GetRouteData(""];

                // //Make sure we only report the current controller docs
                //if (!apiControllerName.Equals(actionContext.ControllerContext.ControllerDescriptor.ControllerName))
                //    continue;

               
                if (!api.RelativePath.ToUpper().Contains((moduleName + "/API/" + namespaceDescriptor + "." + controllerDisplay + "controller").ToUpper()))
                    continue;



               

                
               
                ResourceApi rApi = SwaggerGen.CreateResourceApi(api);
                rApi.path ="/"+ api.RelativePath.ToLower().Replace((namespaceDescriptor + ".").ToLower(), "").Replace("controller", "");
                r.apis.Add(rApi);

                ResourceApiOperation rApiOperation = SwaggerGen.CreateResourceApiOperation(api, docProvider, dataTypeRegistry);
                rApi.operations.Add(rApiOperation);

                foreach (var param in api.ParameterDescriptions)
                {
                  DataType dataType=   dataTypeRegistry.GetOrRegister(param.ParameterDescriptor.ParameterType);
                  ResourceApiOperationParameter parameter = SwaggerGen.CreateResourceApiOperationParameter(api, param, docProvider);
                   
                    rApiOperation.parameters.Add(parameter);
                }

                var responses=docProvider.GetResponseMessages(api.ActionDescriptor);


                rApiOperation.responseMessages = SwaggerGen.GetResourceApiResponseMessage(api, docProvider);
                dataTypeRegistry.GetOrRegister(api.ActionDescriptor.ReturnType);
            }

            r.models = dataTypeRegistry.GetModels();
            return r;
        }
    }

    
}
