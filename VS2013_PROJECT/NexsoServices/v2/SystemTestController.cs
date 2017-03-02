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
using System.Web.Http.Description;


namespace NexsoServices.V2
{
    /// <summary>
    /// Test controller
    /// </summary>
    [AllowAnonymous]
    public class SystemTestController : DnnApiController
    {
        /// <summary>
        /// Test Registered Users rol
        /// </summary>
        /// <remarks>
        /// This method retrieves if an user belongs to Registered Users role.
        /// </remarks>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="401">Not Authorized. User does not belog to Role</response>
        /// <response code="500">Internal ServerError</response>
        [HttpGet]
        [DnnAuthorize]
        public HttpResponseMessage NexsoUser()
        {
            try
            {
                var ps = PortalController.GetCurrentPortalSettings();
                var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
                if (currentUser.IsInRole("Registered Users"))
                    return Request.CreateResponse(HttpStatusCode.OK, currentUser.Username + " - " + ps.PortalName);
                throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.Unauthorized));
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

        /// <summary>
        /// Test NexsoJudge rol
        /// </summary>
        /// <remarks>
        /// This method retrieves if an user belongs to NexsoJudge role.
        /// </remarks>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="401">Not Authorized. User does not belog to Role</response>
        /// <response code="500">Internal ServerError</response>
        [HttpGet]
        [DnnAuthorize]
        // GET api/MyObjects/function
        public HttpResponseMessage NexsoJudge()
        {
            try
            { 
            PortalSettings ps = PortalController.GetCurrentPortalSettings();
            var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
            if (currentUser.IsInRole("NexsoJudge"))
                return Request.CreateResponse(HttpStatusCode.OK, currentUser.Username + " - " + ps.PortalName);
            throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.Unauthorized));
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

        /// <summary>
        /// Test NexsoSupport rol
        /// </summary>
        /// <remarks>
        /// This retrieves if an user belongs to NexsoSupport rol.
        /// </remarks>
        /// <response code="200">OK</response>
        /// <response code="401">Not Authorized. User does not belog to Role</response>
        /// <response code="500">Internal ServerError</response>
        [HttpGet]
        [DnnAuthorize]
        public HttpResponseMessage NexsoSupport()
        {
            try
            { 
            var ps = PortalController.GetCurrentPortalSettings();
            var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
            if (currentUser.IsInRole("NexsoSupport"))
                return Request.CreateResponse(HttpStatusCode.OK, currentUser.Username + " - " + ps.PortalName);
            throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.Unauthorized));
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

        /// <summary>
        /// Test authentication
        /// </summary>
        /// <remarks>
        /// This retrieves if an user is athenticated.
        /// </remarks>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="401">Not Authorized. User does not belog to Role</response>
        /// <response code="500">Internal ServerError</response>
        [HttpGet]
        [DnnAuthorize]
        public HttpResponseMessage Auth()
        {
            try { 
            var ps = PortalController.GetCurrentPortalSettings();
            var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
            if (currentUser.UserID > 0)
                return Request.CreateResponse(HttpStatusCode.OK, currentUser.Username + " - " + ps.PortalName);
            throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.Unauthorized));
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


        /// <summary>
        /// Test anonymous
        /// </summary>
        /// <remarks>
        /// This method retrieves if an user is anonymous or athenticated.
        /// </remarks>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="500">Internal ServerError</response>
        [AllowAnonymous]
        [HttpGet]
        public HttpResponseMessage Anonymous()
        {
            try { 
            var ps = PortalController.GetCurrentPortalSettings();
            var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
            if (currentUser.UserID > 0)
                return Request.CreateResponse(HttpStatusCode.OK, currentUser.Username + " - " + ps.PortalName);
            return Request.CreateResponse(HttpStatusCode.OK, "Anonymous");
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
        
        /// <summary>
        /// Make an echo request
        /// </summary>
        /// <remarks>
        /// Make an echo request sending a string an getting back.
        /// </remarks>
        /// <param name="echo">Any string</param>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="500">Internal ServerError</response>
        [AllowAnonymous]
        [HttpGet]
       
        public HttpResponseMessage Echo(string echo)
        {
            try
            { 
            return Request.CreateResponse(HttpStatusCode.OK, echo);
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
