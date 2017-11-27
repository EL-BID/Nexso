using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.Http.Controllers;
using System.Web.Http.Description;
using Newtonsoft.Json;
using System.Text;



namespace Swagger.Net
{
    public static class SwaggerGen
    {
        public const string SWAGGER = "swagger";
        public const string SWAGGER_VERSION = "2.0";
        public const string FROMURI = "FromUri";
        public const string FROMBODY = "FromBody";
        public const string QUERY = "query";
        public const string PATH = "path";
        public const string BODY = "body";

        /// <summary>
        /// Create a resource listing
        /// </summary>
        /// <param name="actionContext">Current action context</param>
        /// <param name="includeResourcePath">Should the resource path property be included in the response</param>
        /// <returns>A resource Listing</returns>
        public static ResourceListing CreateResourceListing(HttpActionContext actionContext, bool includeResourcePath = true)
        {
            return CreateResourceListing(actionContext.ControllerContext, includeResourcePath);
        }

        /// <summary>
        /// Create a resource listing
        /// </summary>
        /// <param name="actionContext">Current controller context</param>
        /// <param name="includeResourcePath">Should the resource path property be included in the response</param>
        /// <returns>A resrouce listing</returns>
        public static ResourceListing CreateResourceListing(HttpControllerContext controllerContext, bool includeResourcePath = false)
        {
            Uri uri = controllerContext.Request.RequestUri;

            ResourceListing rl = new ResourceListing()
            {
                apiVersion = Assembly.GetCallingAssembly().GetType().Assembly.GetName().Version.ToString(),
                swaggerVersion = SWAGGER_VERSION,
                basePath = uri.GetLeftPart(UriPartial.Authority) + HttpRuntime.AppDomainAppVirtualPath.TrimEnd('/'),
                apis = new List<ResourceApi>()
            };

            if (includeResourcePath) rl.resourcePath = controllerContext.ControllerDescriptor.ControllerName;

            return rl;
        }

        /// <summary>
        /// Create an api element 
        /// </summary>
        /// <param name="api">Description of the api via the ApiExplorer</param>
        /// <returns>A resource api</returns>
        public static ResourceApi CreateResourceApi(ApiDescription api)
        {
            ResourceApi rApi = new ResourceApi()
            {
                path = "/" + api.RelativePath,
                description = api.Documentation,
                operations = new List<ResourceApiOperation>()
            };

            return rApi;
        }

        /// <summary>
        /// Creates an api operation
        /// </summary>
        /// <param name="api">Description of the api via the ApiExplorer</param>
        /// <param name="docProvider">Access to the XML docs written in code</param>
        /// <returns>An api operation</returns>
        public static ResourceApiOperation CreateResourceApiOperation(ApiDescription api, XmlCommentDocumentationProvider docProvider, DataTypeRegistry dataTypeRegistry)
        {
            ResourceApiOperation rApiOperation = new ResourceApiOperation()
            {
                httpMethod = api.HttpMethod.ToString(),
                nickname = docProvider.GetNickname(api.ActionDescriptor),
                responseClass = docProvider.GetResponseClass(api.ActionDescriptor),
                summary = api.Documentation,
                notes = docProvider.GetNotes(api.ActionDescriptor),
                type = docProvider.GetResponseClass(api.ActionDescriptor),
                parameters = new List<ResourceApiOperationParameter>(),
                responseMessages=new List<ResourceApiOperationResponseMessage>(),

                
            };

            var responseType = api.ActualResponseType();
            if (responseType == null)
            {
                rApiOperation.type = "void";
            }
            else
            {
                var dataType = dataTypeRegistry.GetOrRegister(responseType);
                if (dataType.Type == "object")
                {
                    rApiOperation.type = dataType.Id;
                }
                else
                {
                    rApiOperation.type = dataType.Type;
                    rApiOperation.format = dataType.Format;
                    rApiOperation.items = dataType.Items;
                    rApiOperation.Enum = dataType.Enum;
                }
            }

            return rApiOperation;
        }

        /// <summary>
        /// Creates an operation parameter
        /// </summary>
        /// <param name="api">Description of the api via the ApiExplorer</param>
        /// <param name="param">Description of a parameter on an operation via the ApiExplorer</param>
        /// <param name="docProvider">Access to the XML docs written in code</param>
        /// <returns>An operation parameter</returns>
        public static ResourceApiOperationParameter CreateResourceApiOperationParameter(ApiDescription api, ApiParameterDescription param, XmlCommentDocumentationProvider docProvider)
        {
            string paramType = (param.Source.ToString().Equals(FROMURI)) ? QUERY : BODY;
            ResourceApiOperationParameter parameter = new ResourceApiOperationParameter()
            {
                paramType = (paramType == "query" && api.RelativePath.IndexOf("{" + param.Name + "}") > -1) ? PATH : paramType,
                name = param.Name,
                description = param.Documentation,
                dataType = param.ParameterDescriptor.ParameterType.Name,
                required = docProvider.GetRequired(param.ParameterDescriptor)
               
            };

            return parameter;
        }

        public static List<ResourceApiOperationResponseMessage> GetResourceApiResponseMessage(ApiDescription api, XmlCommentDocumentationProvider docProvider)
        {
            List<ResourceApiOperationResponseMessage> ret = new List<ResourceApiOperationResponseMessage>();
            var elements = docProvider.GetResponseMessages(api.ActionDescriptor);
            if (elements != null)
            {
                while (elements.MoveNext())
                {
                    ret.Add(new ResourceApiOperationResponseMessage()
                        {
                            code = elements.Current.GetAttribute("code",""),
                            message = elements.Current.Value
                        });
                }
            }
            return ret;

        }

      
    }

    public class ResourceListing
    {
        public string apiVersion { get; set; }
        public string swaggerVersion { get; set; }
        public string basePath { get; set; }
        public string resourcePath { get; set; }
        public List<ResourceApi> apis { get; set; }
        public IDictionary<string, DataType> models { get; set; }
    }

    public class ResourceListingL
    {
        public string apiVersion { get; set; }
        public string swaggerVersion { get; set; }
        public string basePath { get; set; }
        public List<ResourceApiL> apis { get; set; }
        public IDictionary<string, DataType> models { get; set; }
    }

    public class ResourceModel
    {
        public string model;
    }
    public class ResourceApi
    {
        public string path { get; set; }
        public string description { get; set; }
        public List<ResourceApiOperation> operations { get; set; }
    }

    public class ResourceApiL
    {
        public string path { get; set; }
        public string description { get; set; }
        
    }
    public class ResourceApiOperation
    {
        public string httpMethod { get; set; }
        public string nickname { get; set; }
        public string responseClass { get; set; }
        public string summary { get; set; }
        public string notes { get; set; }
        public string type { get; set; }
        public List<ResourceApiOperationParameter> parameters { get; set; }
        public List<ResourceApiOperationResponseMessage> responseMessages { get; set; }
        public DataType items { get; set; }
        public string format { get; set; }

        [JsonProperty("enum")]
        public IList<string> Enum { get; set; }
    }

    public class ResourceApiOperationParameter
    {
        public string paramType { get; set; }
        public string name { get; set; }
        public string description { get; set; }
        public string dataType { get; set; }
        public bool required { get; set; }
        public bool allowMultiple { get; set; }
        public OperationParameterAllowableValues allowableValues { get; set; }
       
    }

    public class ResourceApiOperationResponseMessage
    {
        public string code {get;set;}
        public string message {get;set;}
    }

    public class OperationParameterAllowableValues
    {
        public int max { get; set; }
        public int min { get; set; }
        public string valueType { get; set; }
    }

    public class DataType
    {
        [JsonProperty("type")]
        public string Type { get; set; }

        [JsonProperty("$ref")]
        public string Ref { get; set; }

        [JsonProperty("format")]
        public string Format { get; set; }

        [JsonProperty("enum")]
        public IList<string> Enum { get; set; }

        [JsonProperty("minimum")]
        public string Minimum { get; set; }

        [JsonProperty("maximum")]
        public string Maximum { get; set; }

        [JsonProperty("items")]
        public DataType Items { get; set; }

        [JsonProperty("uniqueItems")]
        public bool? UniqueItems { get; set; }

        /*
        NOTE: The properties below should be in a separate "Model" class. Unfortunately,
        it was modelled incorrectly and can't be fixed until the next major version of
        Swashbuckle due to backward-comptability
         */

        [JsonProperty("id")]
        public string Id { get; set; }

        [JsonProperty("description")]
        public string Description { get; set; }

        [JsonProperty("required")]
        public IList<string> Required { get; set; }

        [JsonProperty("properties")]
        public IDictionary<string, DataType> Properties { get; set; }

        [JsonProperty("subTypes")]
        public IList<string> SubTypes { get; set; }

        [JsonProperty("discriminator")]
        public string Discriminator { get; set; }
    }
}