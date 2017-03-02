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
    /// Comment controller
    /// </summary>
    public class CommentController : DnnApiController
    {
        /// <summary>
        /// Comment on a solution
        /// </summary>
        /// <remarks>
        /// Make a comment to a specific solution.
        /// </remarks>
        /// <param name="txtComment">Comment body text</param>
        /// <param name="scope">Value of privacy scope. See https://github.com/NEXSO-MIF/documentation/wiki/Web-Api-V2-Reference </param>
        /// <param name="solutionId"></param>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="400">If parameters do not match with expected schema</response>
        /// <response code="401">Unauthorized if authenticated user is not Registered Users</response>
        /// <response code="500">Internal ServerError</response>
        [DnnAuthorize]
        [HttpPost]
        public HttpResponseMessage CommentSolution(string txtComment, string scope, string solutionId)
        {

            try
            {

                var portalSettings = PortalController.GetCurrentPortalSettings();
                var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();

                if (currentUser.IsInRole("Registered Users"))
                {
                    


                    var solutionComponent = new SolutionComponent(new Guid(solutionId));

                    if (!string.IsNullOrEmpty(ValidateSecurity.ValidateString(txtComment, false)) && currentUser.UserID > 0 && solutionComponent.Solution.SolutionId != Guid.Empty)
                    {

                        SolutionCommentComponent solutionCommentComponent = new SolutionCommentComponent();
                        solutionCommentComponent.SolutionComment.Comment = txtComment;
                        solutionCommentComponent.SolutionComment.CreatedDate = DateTime.Now;
                        solutionCommentComponent.SolutionComment.Publish = true;
                        solutionCommentComponent.SolutionComment.Scope = scope;
                        solutionCommentComponent.SolutionComment.SolutionId = solutionComponent.Solution.SolutionId;
                        solutionCommentComponent.SolutionComment.UserId = currentUser.UserID;

                        if (solutionCommentComponent.Save() > 0)
                        {
                            // Notification

                            var userToNotify = DotNetNuke.Entities.Users.UserController.GetUserById(portalSettings.PortalId, Convert.ToInt32(solutionComponent.Solution.CreatedUserId));
                            var currentUserProperty = new UserPropertyComponent(currentUser.UserID);
                            if (currentUser.UserID != Convert.ToInt32(solutionComponent.Solution.CreatedUserId))
                            {
                                if (Helper.HelperMethods.SetNotification("COMMENT", "SOLUTION", solutionComponent.Solution.SolutionId, userToNotify.UserID, currentUser.UserID,"") > 0)
                                {
                                    Helper.HelperMethods.SendCommentNotificationEmails(solutionCommentComponent, portalSettings,currentUser);
                                    return Request.CreateResponse(HttpStatusCode.OK, "Successful Operation");
                                }
                            }
                        }

                        throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.InternalServerError));


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
        /// Delete a comment 
        /// </summary>
        /// <remarks>
        /// Delete a specific comment.
        /// </remarks>
        /// <param name="solutionCommentId"></param>
        /// <returns></returns>
        /// <response code="202">Successful Delete</response>
        /// <response code="401">Unauthorized if authenticated user is not Registered Users</response>
        /// <response code="500">Internal ServerError</response>
        [DnnAuthorize]
        [HttpDelete]
        public HttpResponseMessage Delete(Guid solutionCommentId)
        {
            try
            {

                var portal = PortalController.GetCurrentPortalSettings();
                var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();

                if (currentUser.IsInRole("Registered Users"))
                {

                    SolutionCommentComponent solutionCommentComponent = new SolutionCommentComponent();
                    solutionCommentComponent = new SolutionCommentComponent(solutionCommentId);

                    if (solutionCommentComponent.Delete() > 0)
                    {
                        return Request.CreateResponse(HttpStatusCode.Accepted, "Successful Delete");
                    }
                    throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.InternalServerError));
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
        /// Get comment list
        /// </summary>
        /// <remarks>
        /// Get a list of comments per solution.
        /// 
        /// Pagination information in Header, see https://github.com/NEXSO-MIF/documentation/wiki/Web-Api-V2-Reference
        /// </remarks>
        /// <param name="solutionId">Solution Id</param>
        /// <param name="rows">Default 10</param>
        /// <param name="page">Default 0</param>
        /// <returns></returns>
        [AllowAnonymous]
        [HttpGet]
        public List<SolutionCommentsModel> GetList(Guid solutionId, int rows = 10, int page = 0)
        {
            try
            {

                var portal = PortalController.GetCurrentPortalSettings();
                var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();

               
                    var result = SolutionCommentComponent.GetCommentsPerSolution(solutionId).OrderByDescending(p => p.CreatedDate).ToList();
                    var totalCount = result.Count();
                    var totalPages = (int)Math.Ceiling((double)totalCount / rows);


                    var prevLink = page > 0 ? string.Format("/Comment/getlist?rows={0}&page={1}", rows, page - 1) : "";
                    var nextLink = page < totalPages - 1 ? string.Format("/Comment/getlist?rows={0}&page={1}", rows, page + 1) : "";
                    List<SolutionCommentsModel> SolutionCommentsModel = new List<SolutionCommentsModel>();

                    foreach (var resultTmp in result.Skip(rows * page).Take(rows).ToList())
                    {
                        var user = new UserPropertyComponent(resultTmp.UserId.GetValueOrDefault(-1));
                        SolutionCommentsModel.Add(new SolutionCommentsModel()
                        {


                            CommentId = resultTmp.Comment_Id,
                            SolutionId = (Guid)resultTmp.SolutionId,
                            UserId = Convert.ToInt32(resultTmp.UserId),
                            FirstName = user.UserProperty.FirstName,
                            LastName = user.UserProperty.LastName,
                            Comment = resultTmp.Comment,
                            CreatedDate = Convert.ToDateTime(resultTmp.CreatedDate),
                            Publish = Convert.ToBoolean(resultTmp.Publish),
                            Scope = resultTmp.Scope

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

                    return SolutionCommentsModel;
               
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
