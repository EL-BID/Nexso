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
using System.Web.Http.Routing;

namespace NexsoServices.V2
{
    /// <summary>
    /// Notification methods. 
    /// </summary>
    public class NotificationController : DnnApiController
    {

        /// <summary>
        /// Get notifications list
        /// </summary>
        /// <remarks>
        /// Get an user's notification list.
        /// 
        /// Pagination information in Header, see https://github.com/NEXSO-MIF/documentation/wiki/Web-Api-V2-Reference
        /// </remarks>
        /// <param name="rows">Default 10</param>
        /// <param name="page">Default 0</param>
        /// <param name="language">Use for getting localized content. RFC 1766 language convention. Default en-US</param>
        /// <returns></returns>
        /// <response code="200">OK. Successful Operation</response>
        /// <response code="400">Bad Request. Parameters does not match with expected value</response>
        /// <response code="401">Not Authorized operation</response>
        /// <response code="500">Internal Server Error</response>
        [DnnAuthorize]
        [HttpGet]
        public List<NotificationModel> GetNotifications([FromUri]int rows = 10, [FromUri]int page = 0, [FromUri]string language = "en-US")
        {
            try
            {
                List<NotificationModel> auxReturn_ = new List<NotificationModel>();
                List<NotificationModel> return_ = new List<NotificationModel>();
                if (language == null || language == "null")
                    language = "en-US";
                CultureInfo culture = new CultureInfo(language);
                ResourceManager Localization = new ResourceManager("NexsoServices.App_LocalResources.Resource", Assembly.GetExecutingAssembly());

                // var message = Localization.GetString("MessageNotification", lang);

                var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();

                var ListNotification = NexsoProBLL.NotificationComponent.GetNotifications(currentUser.UserID).Where(a=>a.Read==null).OrderBy(a => a.Created);

                var totalCount = ListNotification.Count();
                var totalPages = (int)Math.Ceiling((double)totalCount / rows);

                var urlHelper = new UrlHelper(Request);
                var prevLink = page > 0 ? string.Format("/notification/GetNotifications?rows={0}&page={1}", rows, page - 1) : "";
                var nextLink = page < totalPages - 1 ? string.Format("/notification/GetNotifications?rows={0}&page={1}", rows, page + 1) : "";

                foreach (var notification_ in ListNotification.Skip(rows * page).Take(rows).ToList())
                {

                    return_.Add(new NotificationModel()
                    {
                        NotificationId = notification_.NotificationId,
                        UserId = notification_.UserId,
                        Code = notification_.Code,
                        Created = notification_.Created,
                        Read = notification_.Read.GetValueOrDefault(DateTime.MinValue),
                        Message = Helper.HelperMethods.GetResource(notification_.ObjectType + "Message" + notification_.Code + notification_.Message, culture),
                        ToolTip = Helper.HelperMethods.GetResource(notification_.ObjectType + "ToolTip" + notification_.Code + notification_.Message, culture),
                        Type = notification_.ObjectType,
                        Link = Helper.HelperMethods.GetNotificationLink(notification_.Code, notification_.ObjectType, culture, notification_.Link),
                        RelatedObject = Helper.HelperMethods.ParseGenericObject(new string[] { notification_.Link }, notification_.ObjectType),
                        UserProfileList = Helper.HelperMethods.ParseUserProfile(notification_.UserNotificationConnections.ToList())
                    });




                }


                var paginationHeader = new
                {
                    TotalCount = totalCount,
                    TotalPages = totalPages,
                    PrevPageLink = prevLink,
                    NextPageLink = nextLink
                };
                
                System.Web.HttpContext.Current.Response.Headers.Add("X-Pagination",
                Newtonsoft.Json.JsonConvert.SerializeObject(paginationHeader));
                
                return return_;

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
        /// Mark as red all notifications
        /// </summary>
        /// <remarks>Mark as red all notifications.</remarks>
        /// <returns></returns>
        /// <response code="200">OK. Successful Operation</response>
        /// <response code="400">Bad Request. Parameters does not match with expected value</response>
        /// <response code="401">Not Authorized operation</response>
        /// <response code="500">Internal Server Error</response>
        
        [DnnAuthorize]
        [HttpPut]
        public HttpResponseMessage MarkAllAsRead()
        {
            try
            {
                var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();

                if (!currentUser.IsInRole("Registered Users"))
                    throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.Unauthorized));
                var read = DateTime.Now;
                MIFNEXSOEntities entity=new MIFNEXSOEntities();
                var listNotification=entity.Notifications.Where(a=>a.UserId==currentUser.UserID && a.Read==null);
                foreach (var item in listNotification)
                {
                    item.Read= read;
                   
                }
                if(entity.SaveChanges()>=0)
                    return Request.CreateResponse(HttpStatusCode.OK, "Successful Operation");
                throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.InternalServerError));
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
        /// Mark as red a specific notification
        /// </summary>
        /// <remarks>Mark as red a specific notifications.</remarks>
        /// <param name="notificationId">Notification Id</param>
        /// <returns></returns>
        /// <response code="200">OK. Successful Operation</response>
        /// <response code="400">Bad Request. Parameters does not match with expected value</response>
        /// <response code="403">Forbidden operation. User is not owner of content</response>
        /// <response code="401">Not Authorized operation</response>
        /// <response code="500">Internal Server Error</response>
        [DnnAuthorize]
        [HttpPut]
        public HttpResponseMessage MarkAsRead(Guid notificationId)
        {
            try
            {
                var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();

                if (!currentUser.IsInRole("Registered Users"))
                    throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.Unauthorized));

                NotificationComponent notificationComponent = new NotificationComponent(notificationId);
                if (notificationComponent.Notification.UserId == currentUser.UserID)
                {
                    notificationComponent.Notification.Read = DateTime.Now;
                    if(notificationComponent.Save()>0)
                        return Request.CreateResponse(HttpStatusCode.OK, "Successful Operation");
                    throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.InternalServerError));
                }
                throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.Forbidden));
                
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
