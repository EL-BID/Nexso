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
    /// Message controller
    /// </summary>
    public class MessagesController : DnnApiController
    {
        /// <summary>
        /// Send a message
        /// </summary>
        /// <remarks>
        /// Sen a message to a specific user.
        /// </remarks>
        /// <param name="message">string with message</param>
        /// <param name="userIdTo">User Id</param>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="400">Bad Request. Parameters does not match with expected value</response>
        /// <response code="401">Not Authorized</response>
        /// <response code="500">Internal ServerError</response>
        [DnnAuthorize]
        [HttpPost]
        public HttpResponseMessage SendMessage(string message, int userIdTo)
        {
            try
            {
                var portal = PortalController.GetCurrentPortalSettings();
                var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
                UserInfo userTo = DotNetNuke.Entities.Users.UserController.GetUserById(portal.PortalId, userIdTo);

                if (currentUser.IsInRole("Registered Users") && userTo != null)
                {
                    var fromUser = new UserPropertyComponent(currentUser.UserID);
                    var toUser = new UserPropertyComponent(userIdTo);
                    if (!string.IsNullOrEmpty(ValidateSecurity.ValidateString(message, false)) && toUser.UserProperty.UserId > 0 && currentUser.UserID > 0)
                    {
                        MessageComponent messageComponent = new MessageComponent(Guid.Empty);
                        messageComponent.Message.Message1 = message;
                        messageComponent.Message.ToUserId = userIdTo;
                        messageComponent.Message.FromUserId = currentUser.UserID;
                        messageComponent.Message.DateCreated = DateTime.Now;
                        
                        if (messageComponent.Save() > 0)
                        {
                            // Notification
                         
                            if (currentUser.UserID != Convert.ToInt32(userTo.UserID))
                            {
                                if(Helper.HelperMethods.SetNotification("MESSAGE", "MESSAGE", messageComponent.Message.MessageId, toUser.UserProperty.UserId, currentUser.UserID,"")>0)
                                {
                                    CultureInfo culture = new CultureInfo(HelperMethods.GetUserLanguage(toUser.UserProperty.Language.GetValueOrDefault(1)));
                                    Helper.HelperMethods.SendEmailToUser("MessageTitleMessage", "MessageBodyMessage", userTo, culture, "", messageComponent.Message.Message1).ConfigureAwait(false);
                                    return Request.CreateResponse(HttpStatusCode.OK, "Successful Operation");
                                }
                                throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.InternalServerError));
                             }
                        }
                        else
                        {
                            throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.InternalServerError));
                        }
                    }
                    throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.BadRequest));
                }
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
        /// Get Messages from specific user
        /// </summary>
        /// <remarks>
        /// Get all messages from a specific user.
        /// 
        /// Pagination information in Header, see https://github.com/NEXSO-MIF/documentation/wiki/Web-Api-V2-Reference
        /// </remarks>
        /// <param name="rows">Default 10</param>
        /// <param name="page">Default 0</param>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="400">Bad Request. Parameters does not match with expected value</response>
        /// <response code="401">Not Authorized</response>
        /// <response code="500">Internal ServerError</response>
        [DnnAuthorize]
        [HttpGet]
        public List<MessageModel> GetListFrom(int rows = 10, int page = 0)
        {
            try
            {

                var portal = PortalController.GetCurrentPortalSettings();
                var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();

                if (currentUser.IsInRole("Registered Users"))
                {

                   var  result = MessageComponent.GetMessagesFrom(currentUser.UserID).OrderByDescending(p => p.DateCreated);
                   var totalCount = result.Count();
                   var totalPages = (int)Math.Ceiling((double)totalCount / rows);

                   var prevLink = page > 0 ? string.Format("/messages/GetListFrom?rows={0}&page={1}", rows, page - 1) : "";
                   var nextLink = page < totalPages - 1 ? string.Format("/messages/GetListFrom?rows={0}&page={1}", rows, page + 1) : "";
                    
                    List<MessageModel> MessageModel = new List<MessageModel>();

                    foreach (var resultTmp in result.Skip(rows * page).Take(rows).ToList())
                    {
                        MessageModel.Add(new MessageModel()
                        {
                            MessageId = resultTmp.MessageId,
                            Message = resultTmp.Message1,
                            FromUserId = Convert.ToInt32(resultTmp.FromUserId),
                            ToUserId = Convert.ToInt32(resultTmp.ToUserId),
                            CreatedDate = Convert.ToDateTime(resultTmp.DateCreated),
                            DateRead = Convert.ToDateTime(resultTmp.DateRead)

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


                    return MessageModel;
                }
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
        /// Get sent messages to a specific user
        /// </summary>
        /// <remarks>
        /// Get a list of messages sent to a specific user.
        /// 
        /// Pagination information in Header, see https://github.com/NEXSO-MIF/documentation/wiki/Web-Api-V2-Reference
        /// </remarks>
        /// <param name="rows">Default 10</param>
        /// <param name="page">Default 0</param>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="400">Bad Request. Parameters does not match with expected value</response>
        /// <response code="401">Not Authorized</response>
        /// <response code="500">Internal ServerError</response>
        [AllowAnonymous]
        [HttpGet]
        public List<MessageModel> GetListTo(int rows = 10, int page = 0)
        {
            try
            {

                var portal = PortalController.GetCurrentPortalSettings();
                var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();

                if (currentUser.IsInRole("Registered Users"))
                {
                    var result = MessageComponent.GetMessagesTo(currentUser.UserID).OrderByDescending(p => p.DateCreated);
                    var totalCount = result.Count();
                    var totalPages = (int)Math.Ceiling((double)totalCount / rows);
                    var prevLink = page > 0 ? string.Format("/messages/GetListTo?rows={0}&page={1}", rows, page - 1) : "";
                    var nextLink = page < totalPages - 1 ? string.Format("/messages/GetListTo?rows={0}&page={1}", rows, page + 1) : "";
                 

                    List<MessageModel> messagesModel = new List<MessageModel>();

                    foreach (var resultTmp in result.Skip(rows * page).Take(rows).ToList())
                    {
                        messagesModel.Add(new MessageModel()
                        {
                            MessageId = resultTmp.MessageId,
                            Message = resultTmp.Message1,
                            FromUserId = Convert.ToInt32(resultTmp.FromUserId),
                            ToUserId = Convert.ToInt32(resultTmp.ToUserId),
                            CreatedDate = Convert.ToDateTime(resultTmp.DateCreated),
                            DateRead = Convert.ToDateTime(resultTmp.DateRead)

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

                    return messagesModel;
                }
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
    }
}
