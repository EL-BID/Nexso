using System;
using System.Data.Common;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using DotNetNuke.Web.Api;
using System.Text;
using System.Web;
using Newtonsoft.Json;
using System.Linq;
using Newtonsoft;
using DotNetNuke.Entities.Portals;
using DotNetNuke.Entities.Users;
using DotNetNuke.Security.Roles;
using System.Collections.Generic;
using System.Globalization;
using NexsoProBLL;
using NexsoProDAL;
using System.Data.Objects;
using System.IO;
using System.Threading;

using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.Web.Http.Controllers;
using System.Web.Http.Filters;
using ImageProcessor;
using System.Drawing;
using System.Resources;
using System.Reflection;
using System.Collections;
using NexsoServices.Helper;
namespace NexsoServices.V2
{
    /// <summary>
    /// Controller for general Lists
    /// </summary>
    public class ListController : DnnApiController
    {
        /// <summary>
        /// Get a nexso list collection
        /// </summary>
        /// <remarks>
        /// Get a specific collection list in NEXSO based in a category and language.
        /// 
        /// For categories reference see https://github.com/NEXSO-MIF/documentation/wiki/List-Categories
        /// </remarks>
        /// <param name="category">Key name for categoy</param>
        /// <param name="language"> RFC 1766 language convention. Default en-US</param>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="500">Internal ServerError</response>
        [AllowAnonymous]
        [HttpGet]
        public List<ListItemModel> GetCategories(string category, string language = "en-US")
        {
            try
            {
                CultureInfo cultureInfo = new CultureInfo(language, false);
                return Helper.HelperMethods.GetListsFromCategory(category, cultureInfo);
            }
            catch (HttpResponseException e)
            {
                throw e;
            }
            catch (Exception ee)
            {
                DotNetNuke.Services.Exceptions.Exceptions.LogException(ee);
                throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.InternalServerError));
            }
     
        }


    }
}
