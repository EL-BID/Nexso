#region [Using]
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
using NexsoIndex.Manage;
using Users = DotNetNuke.Entities.Users;
using NexsoProDAL.Dto;
using System.Net;

#endregion

namespace NexsoServices.V2
{
    /// <summary>
    /// 
    /// </summary>
    public class SolutionController : DnnApiController
    {

        /// <summary>
        /// Get solution list
        /// </summary>
        /// <remarks>
        /// Get a list of solutions in NEXSO, can be filtered or sorted. 
        /// 
        /// Pagination and parameter information in Header, see https://github.com/NEXSO-MIF/documentation/wiki/Web-Api-V2-Reference
        /// </remarks>
        /// <param name="rows">Default 10</param>
        /// <param name="page">Default 0</param>
        /// <param name="min">Min score. Default 0</param>
        /// <param name="max">Max score. Default 100</param>
        /// <param name="state">solution state, default 1000</param>
        /// <param name="categories">List of category keys</param>
        /// <param name="beneficiaries">List of beneficiaries keys</param>
        /// <param name="deliveryFormat">List of delivery format keys</param>
        /// <param name="filter">Optional filter, {"ChallengeReference":"example","SolutionType":"example2","Language":"en-US"}</param>
        /// <param name="fullContent">Get full data. Default false</param>
        /// <param name="language">Query language. Default en-US</param>
        /// <param name="search">Seach string on solution</param>
        /// <param name="userId">User Id, could be null to get logged in user solutions</param>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="500">Internal ServerError</response>
        [AllowAnonymous]
        [HttpGet]
        public List<SolutionOrganizationModel> GetList(int rows = 10, int page = 0, int min = 0, int max = 0, int state = 1000, string categories = "", string beneficiaries = "", string deliveryFormat = "", string filter = "", bool fullContent = false, string language = "en-US", string search = "", string userId = "")
        {
            try
            {
                if (string.IsNullOrWhiteSpace(categories) || categories == "{}" || categories.ToLower() == "null")
                    categories = string.Empty;
                if (string.IsNullOrWhiteSpace(beneficiaries) || beneficiaries == "{}" || beneficiaries.ToLower() == "null")
                    beneficiaries = string.Empty;
                if (string.IsNullOrWhiteSpace(deliveryFormat) || deliveryFormat == "{}" || deliveryFormat.ToLower() == "null")
                    deliveryFormat = string.Empty;
                if (string.IsNullOrWhiteSpace(filter) || filter == "{}" || filter.ToLower() == "null")
                    filter = string.Empty;
                if (string.IsNullOrWhiteSpace(language) || language.ToLower() == "null")
                    language = "en-US";
                if (string.IsNullOrWhiteSpace(search) || search.ToLower() == "null")
                    search = string.Empty;
                if (string.IsNullOrWhiteSpace(userId) || userId.ToLower() == "null")
                    userId = string.Empty;

                int userIdInt = -1;

                try
                {
                    userIdInt = Convert.ToInt32(userId);
                }
                catch
                {

                }



                string challengeReference = "%";
                string solutionType = "%";
                string languageFilter = "%";
                var categoryArray = JsonConvert.DeserializeObject<List<string>>(categories);
                var beneficiariesArray = JsonConvert.DeserializeObject<List<string>>(beneficiaries);
                var deliveryFormatArray = JsonConvert.DeserializeObject<List<string>>(deliveryFormat);
                CultureInfo cultureInfo = new CultureInfo(language, false);
                MIFNEXSOEntities mifNexsoEntities = new MIFNEXSOEntities();



                if (filter != "")
                {


                    dynamic JsonDe = JsonConvert.DeserializeObject(filter);
                    if (JsonDe != null)
                    {
                        foreach (dynamic element in JsonDe)
                        {
                            if (element["ChallengeReference"] != null)
                                challengeReference = element["ChallengeReference"].ToString();
                            if (element["SolutionType"] != null)
                                solutionType = element["SolutionType"].ToString();
                            if (element["Language"] != null)
                                languageFilter = element["Language"].ToString();

                        }

                    }
                }



                ObjectParameter count = new ObjectParameter("Count", typeof(int));
                ObjectResult<spGetSolutionsOrganizations_Result> result = null;
                if (DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo().IsInRole("Administrators") || (DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo().UserID == userIdInt && userIdInt >= 0))
                {
                    result = mifNexsoEntities.spGetSolutionsOrganizations(rows, page + 1, min, max, state, search, HelperMethods.JsonToSQLParameter(categoryArray), HelperMethods.JsonToSQLParameter(beneficiariesArray), HelperMethods.JsonToSQLParameter(deliveryFormatArray), userIdInt, challengeReference, solutionType, languageFilter, "", count, null);
                }
                else if (state >= 1000)
                {
                    result = mifNexsoEntities.spGetSolutionsOrganizations(rows, page + 1, min, max, 1000, search, HelperMethods.JsonToSQLParameter(categoryArray), HelperMethods.JsonToSQLParameter(beneficiariesArray), HelperMethods.JsonToSQLParameter(deliveryFormatArray), userIdInt, challengeReference, solutionType, languageFilter, "", count, null);
                }


                List<spGetSolutionsOrganizations_Result> resultL = new List<spGetSolutionsOrganizations_Result>();
                if (result != null)
                    resultL = result.ToList();

                var totalCount = Convert.ToInt32(count.Value);
                var totalPages = (int)Math.Ceiling((double)totalCount / rows);

                //   var urlHelper = new UrlHelper(Request);
                var prevLink = page > 0 ? string.Format("/solution/GetList?rows={0}&page={1}", rows, page - 1) : "";
                var nextLink = page < totalPages - 1 ? string.Format("/solution/GetList?rows={0}&page={1}", rows, page + 1) : "";


                List<SolutionOrganizationModel> SolutionOrganizationModel = new List<SolutionOrganizationModel>();

                string solutionUrlTmp = string.Empty;

                foreach (var resultTmp in resultL)
                {
                    if (!Convert.ToBoolean(resultTmp.SDeleted))
                    {
                        if (resultTmp.SSolutionState < 800)
                            solutionUrlTmp = NexsoHelper.GetCulturedUrlByTabName("promote", 0, cultureInfo.Name);
                        else
                            solutionUrlTmp = NexsoHelper.GetCulturedUrlByTabName("solprofile", 0, cultureInfo.Name);

                        string challengeState = "enabled";

                        if (resultTmp.SChallengeReference != null)
                        {
                            ChallengeComponent challengeComponent = new ChallengeComponent(resultTmp.SChallengeReference);
                            if (challengeComponent != null)
                            {
                                if (!string.IsNullOrEmpty(challengeComponent.Challenge.EntryTo.ToString()) && !string.IsNullOrEmpty(challengeComponent.Challenge.Closed.ToString()))
                                {
                                    if (challengeComponent.Challenge.EntryTo < DateTime.Now && challengeComponent.Challenge.Closed > DateTime.Now)
                                        challengeState = "disabled";

                                }
                            }
                        }

                        SolutionOrganizationModel.Add(new SolutionOrganizationModel()
                        {
                            SolutionTitle = WebUtility.HtmlDecode(resultTmp.STitle),
                            SolutionThemes = HelperMethods.FillFormat(resultTmp.SSolutionId, "Theme", cultureInfo),
                            SolutionBeneficiaries = HelperMethods.FillFormat(resultTmp.SSolutionId, "Beneficiaries", cultureInfo),
                            SolutionDeliveryFormat = HelperMethods.FillFormat(resultTmp.SSolutionId, "DeliveryFormat", cultureInfo),
                            SolutionState = resultTmp.SSolutionState.GetValueOrDefault(0),
                            SolutionId = resultTmp.SSolutionId,
                            OrganizationLogo = resultTmp.OLogo,
                            OrganizationId = resultTmp.OOrganizationID,
                            OrganizationName = WebUtility.HtmlDecode(resultTmp.OName),
                            SolutionCost = resultTmp.SCost.GetValueOrDefault(-1),
                            SolutionCostUnit = NexsoProBLL.ListComponent.GetLabelFromListValue("Cost", cultureInfo.Name, resultTmp.SCostType.GetValueOrDefault(-1).ToString()),
                            ProjectDuration = NexsoProBLL.ListComponent.GetLabelFromListValue("ProjectDuration", cultureInfo.Name, resultTmp.SDuration.GetValueOrDefault(-1).ToString()),
                            OrganizationUrl = NexsoHelper.GetCulturedUrlByTabName("insprofile", 0, cultureInfo.Name),
                            SolutionUrl = solutionUrlTmp,
                            SolutionTagLine = WebUtility.HtmlDecode(resultTmp.STagLine),
                            SolutionHeader = HelperMethods.GetHeaderImage(resultTmp.SSolutionId, PortalSettings),
                            SolutionLocations = HelperMethods.GetSolutionLocations(resultTmp.SSolutionId),
                            ChallengeReference = resultTmp.SChallengeReference,
                            SolutionType = resultTmp.SSolutionType,
                            VideoObject = resultTmp.SVideoObject,
                            ChallengeState = challengeState

                        });
                    }
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

                return SolutionOrganizationModel;
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
        /// Like a solution
        /// </summary>
        /// <remarks>
        /// Make a like to a solution.
        /// </remarks>
        /// <param name="solutionId">solution id</param>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="401">Unauthorized if authenticated user is not Registered Users or Administrator</response>
        /// <response code="500">Internal ServerError</response>
        /// <response code="406">The specified Id does not much with any record</response>
        /// <response code="409">The specified operation is not allow for a use case conflict</response>
        [AllowAnonymous]
        [HttpPut]
        public SocialMediaIndicatorModel LikeSolution(Guid solutionId, string name, string email)
        {
            try
            {
                throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.NotAcceptable));

                var portal = PortalController.GetCurrentPortalSettings();
                var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
                var indicatorType = "LIKE";
                var objectType = "SOLUTION";
                var aggregattor = "SUM";
                var solution = new SolutionComponent(solutionId);

                int? userId = -1;

                if (solution.Solution.SolutionId != Guid.Empty)
                {

                    if (currentUser.UserID == -1) //anonymous, should be verify vote
                    {
                        if (!string.IsNullOrEmpty(email))
                        {
                            currentUser = DotNetNuke.Entities.Users.UserController.GetUserByEmail(0, email);
                            if (currentUser==null)
                            {
                                var potentialUser = new PotentialUserComponent(email);
                                if (potentialUser.PotentialUser.Batch != "VOTING-ECONOMIANARANJA1")
                                
                                {
                                    CultureInfo culture = Thread.CurrentThread.CurrentCulture;
                                    if (potentialUser.PotentialUser.Created == null)
                                        potentialUser.PotentialUser.Created = DateTime.Now;
                                    potentialUser.PotentialUser.Updated = DateTime.Now;

                                    potentialUser.PotentialUser.Batch = "VOTING-ECONOMIANARANJA1";
                                    IPHostEntry ipEntry = Dns.GetHostEntry(Dns.GetHostName());
                                    IPAddress[] addr = ipEntry.AddressList;
                                    potentialUser.PotentialUser.Source ="IP-ORIGIN:" +addr[1].ToString();
                                    potentialUser.PotentialUser.FirstName=name;
                                 
                                    potentialUser.PotentialUser.CustomField1 = Guid.NewGuid().ToString();
                                    potentialUser.PotentialUser.CustomField2 = solution.Solution.SolutionId.ToString();
                                    potentialUser.PotentialUser.Language = culture.Name;
                                    if(potentialUser.Save()>0)
                                    {
                                       ResourceManager Localization = new ResourceManager("NexsoServices.App_LocalResources.Resource",
                                       Assembly.GetExecutingAssembly());

                                       

                                        string subject = Localization.GetString("SOLUTIONEmailConfirmationVOTESubject", culture);
                                        string body = Localization.GetString("SOLUTIONEmailConfirmationVOTEBody", culture).Replace("{SolutionId}",solution.Solution.SolutionId.ToString()).Replace("{SolutionTitle}",solution.Solution.Title).Replace("{UserName}",name).Replace("{Token}",potentialUser.PotentialUser.CustomField1).Replace("{PotentialUserId}",potentialUser.PotentialUser.PotentialUserId.ToString());


                                        Helper.HelperMethods.SendEmailToUser("EmailBodyConfirmation", email,  culture, subject, body);

                                        var value = SocialMediaIndicatorComponent.GetAggregatorSocialMediaIndicatorPerObjectRelated(solutionId, objectType, indicatorType, aggregattor);
                                        
                                        return new SocialMediaIndicatorModel()
                                        {
                                            Value = value,
                                            Created = DateTime.Now,
                                            IndicatorType = indicatorType,
                                            ObjectType = objectType,
                                            ObjectId = Guid.Empty

                                        };
                                    }
                                    else
                                    {
                                        throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.InternalServerError));
                                    }
                                   
                                }

                                else
                                {
                                    throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.Forbidden));
                                }

                            }
                            else
                            {
                                throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.Unauthorized));
                            }
                       

                        }
                    }
                   
                    if (currentUser.IsInRole("Registered Users"))
                    {
                        userId = currentUser.UserID;
                        var operation =Helper.HelperMethods.SetMediaIndicator(solutionId, userId, indicatorType, objectType, 1, "SUM");
                        if (operation > 0)
                        {

                            if (solution.Solution.CreatedUserId != userId)
                            {
                                Helper.HelperMethods.SetNotification(indicatorType, objectType, solutionId, solution.Solution.CreatedUserId.Value, userId, "");
                                
                               
                            }
                            
                            var value=SocialMediaIndicatorComponent.GetAggregatorSocialMediaIndicatorPerObjectRelated(solutionId, objectType, indicatorType, aggregattor);
                            
                          

                            return new SocialMediaIndicatorModel()
                                {
                                    Value = value,
                                    Created = DateTime.Now,
                                    IndicatorType = indicatorType,
                                    ObjectType = objectType,
                                    ObjectId=Guid.Empty

                                };
                            

                                               
                        }
                        else if (operation == 0)
                        {
                            throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.Conflict));
                        }
                        else
                        {

                            throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.InternalServerError));
                        }
                    }
                    else
                        throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.Conflict));

                }
                else
                    throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.NotAcceptable));






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
        /// Get like for a solution
        /// </summary>
        /// <remarks>
        /// Get the number of likes for a specific solution. 
        /// </remarks>
        /// <param name="solutionId">solution id</param>
        /// <param name="userId">specified to get like per solution and user, Default null</param>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="401">Unauthorized if authenticated user is not Registered Users or Administrator</response>
        /// <response code="500">Internal ServerError</response>
        [AllowAnonymous]
        [HttpGet]
        public int GetLikesSolution(Guid solutionId, int? userId)
        {
            try
            {
                var indicatorType = "LIKE";
                var objectType = "SOLUTION";
                var aggregattor = "SUM";
                if (userId == null)
                {
                    return Convert.ToInt32(SocialMediaIndicatorComponent.GetAggregatorSocialMediaIndicatorPerObjectRelated(solutionId, objectType, indicatorType, aggregattor));
                }
                else
                {
                    var portal = PortalController.GetCurrentPortalSettings();
                    var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();

                    if (currentUser.IsInRole("Registered Users"))
                    {
                        if (userId == currentUser.UserID)
                        {
                            SocialMediaIndicatorComponent socialMediaIndicatorComponent = new SocialMediaIndicatorComponent(solutionId, objectType, indicatorType, userId.Value);
                            if (socialMediaIndicatorComponent.SocialMediaIndicator.SocialMediaIndicatorId != Guid.Empty)
                            {
                                return Convert.ToInt32(socialMediaIndicatorComponent.SocialMediaIndicator.Value);
                            }

                        }

                    }
                    throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.Unauthorized));
                }


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
        /// Dislike a solution
        /// </summary>
        /// <remarks>
        /// Remove a posted solution like. 
        /// </remarks>
        /// <param name="solutionId">solution id</param>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="401">Unauthorized if authenticated user is not Registered Users or Administrator</response>
        /// <response code="500">Internal ServerError</response>
        /// <response code="406">The specified Id does not much with any record</response>
        [DnnAuthorize]
        [HttpPut]
        public HttpResponseMessage DislikeSolution(Guid solutionId)
        {
            try
            {
                var portal = PortalController.GetCurrentPortalSettings();
                var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
                if (currentUser.IsInRole("Registered Users"))
                {
                    if (Helper.HelperMethods.DeleteMediaIndicator(solutionId, "SOLUTION", "LIKE", currentUser.UserID, "SUM") >= 1)
                        return Request.CreateResponse(HttpStatusCode.OK, "Successful Operation");
                    throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.NotAcceptable));
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
        /// Rate a solution
        /// </summary>
        /// <remarks>
        /// Rate a specific solution by the current authenticated user.
        /// </remarks>
        /// <param name="solutionId">Solution id</param>
        /// <param name="value">Rate rage 0 -5 </param>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="401">Unauthorized if authenticated user is not Registered Users or Administrator.</response>
        /// <response code="500">Internal ServerError.</response>
        /// <response code="406">The specified Id does not much with any record or value is not in the range.</response>
        [DnnAuthorize]
        [HttpPut]
        public decimal RateSolution(Guid solutionId, int value)
        {
            try
            {
                if (value < 0 || value > 5)
                    throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.NotAcceptable));

                var portal = PortalController.GetCurrentPortalSettings();
                var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
                var indicatorType = "RATE";
                var objectType = "SOLUTION";
                if (currentUser.IsInRole("Registered Users"))
                {
                    var solution = new SolutionComponent(solutionId);
                    if (solution.Solution != null)
                    {
                        if (Helper.HelperMethods.SetMediaIndicator(solutionId, currentUser.UserID, indicatorType, objectType, value, "AVG") > 0)
                        {
                            // Notification
                            if (solution.Solution.CreatedUserId != currentUser.UserID)
                            {
                                if (Helper.HelperMethods.SetNotification(indicatorType, objectType, solutionId, solution.Solution.CreatedUserId.Value, currentUser.UserID, "")
                                    > 0)
                                    return value;
                                throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.NotAcceptable));
                            }
                            throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.InternalServerError));

                        }
                        throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.InternalServerError));
                    }
                    throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.NotAcceptable));
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
        /// Get a solution rate
        /// </summary>
        /// <remarks>
        /// Get an overal solution rate or a specific solution rate by a specific user.
        /// </remarks>
        /// <param name="solutionId">solution id</param>
        /// <param name="userId">user id to get an user's rate or null to get all rate</param>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="401">Unauthorized if authenticated user id is not valid or user is not Registered Users or Administrator.</response>
        /// <response code="500">Internal ServerError.</response>
        /// <response code="406">The specified Id does not much with any record.</response>
        [AllowAnonymous]
        [HttpGet]
        public decimal GetRateSolution(Guid solutionId, int? userId = null)
        {
            try
            {
                var indicatorType = "RATE";
                var objectType = "SOLUTION";
                var aggregattor = "AVG";

                if (userId == null)
                {
                    return SocialMediaIndicatorComponent.GetAggregatorSocialMediaIndicatorPerObjectRelated(solutionId, objectType, indicatorType, aggregattor);
                }
                else
                {
                    var portal = PortalController.GetCurrentPortalSettings();
                    var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();

                    if (currentUser.IsInRole("Registered Users"))
                    {
                        if (userId == currentUser.UserID)
                        {
                            SocialMediaIndicatorComponent socialMediaIndicatorComponent = new SocialMediaIndicatorComponent(solutionId, objectType, indicatorType, userId.Value);
                            if (socialMediaIndicatorComponent.SocialMediaIndicator.SocialMediaIndicatorId != Guid.Empty)
                            {
                                return socialMediaIndicatorComponent.SocialMediaIndicator.Value;
                            }
                            throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.NotAcceptable));
                        }
                        throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.Unauthorized));
                    }
                    throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.Unauthorized));
                }


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
        /// Get solution views
        /// </summary>
        /// <remarks>
        /// Get the number of views of a solution in general or by a specific user. 
        /// 
        /// </remarks>
        /// <param name="solutionId">solution Id</param>
        /// <param name="userId">solution id. Deafault null for all views</param>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="401">Unauthorized if authenticated user id is not valid or user is not Registered Users or Administrator.</response>
        /// <response code="500">Internal ServerError.</response>
        /// <response code="406">The specified Id does not much with any record.</response>
        [AllowAnonymous]
        [HttpGet]
        public int GetViewSolution(Guid solutionId, int? userId = null)
        {
            try
            {
                var indicatorType = "VIEW";
                var objectType = "SOLUTION";
                var aggregattor = "SUM";
                if (userId == null)
                {
                    return Convert.ToInt32(SocialMediaIndicatorComponent.GetAggregatorSocialMediaIndicatorPerObjectRelated(solutionId, objectType, indicatorType, aggregattor));
                }
                else
                {
                    var portal = PortalController.GetCurrentPortalSettings();
                    var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();

                    if (currentUser.IsInRole("Registered Users"))
                    {
                        if (userId == currentUser.UserID)
                        {
                            SocialMediaIndicatorComponent socialMediaIndicatorComponent = new SocialMediaIndicatorComponent(solutionId, objectType, indicatorType, userId.Value);
                            if (socialMediaIndicatorComponent.SocialMediaIndicator.SocialMediaIndicatorId != Guid.Empty)
                            {
                                return Convert.ToInt32(socialMediaIndicatorComponent.SocialMediaIndicator.Value);
                            }
                            throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.NotAcceptable));
                        }
                        throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.Unauthorized));
                    }
                    throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.Unauthorized));
                }


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
        /// Upload a solution Banner
        /// </summary>
        /// <remarks>
        /// Upload a solution banner image in temporal repository. Only available for Registered Users. 
        /// Require CropSaveBanner to complete publishing operation.
        /// 
        /// Note: the file have to be upload via form-data. Include solutionId parameter as a Guid value. 
        /// </remarks>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="401">Unauthorized if authenticated user is not Registered Users or Administrator</response>
        /// <response code="500">Internal ServerError</response>
        [DnnAuthorize]
        [HttpPost]
        [ValidateMimeMultipartContentFilter]
        public async Task<FileResultModel> UploadBanner()
        {
            try
            {

                var portal = PortalController.GetCurrentPortalSettings();
                var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
                var tempId = Helper.HelperMethods.GenerateHash(currentUser.UserID).ToString();

                if (currentUser.IsInRole("Registered Users"))
                {
                    string ServerUploadFolder = portal.HomeDirectoryMapPath + "ModIma\\TempImages";
                    var streamProvider = new MultipartFormDataStreamProvider(ServerUploadFolder);
                    string ImageProcessingFolfer = "";
                    await Request.Content.ReadAsMultipartAsync(streamProvider);
                    string solutionId = streamProvider.FormData["solutionId"];
                    var solution = new SolutionComponent(new Guid(solutionId));

                    if (currentUser.IsInRole("Administrators") || currentUser.IsInRole("NexsoSupport") || solution.Solution.CreatedUserId == currentUser.UserID)
                    {
                        Helper.HelperMethods.DeleteFiles(portal.HomeDirectoryMapPath + "ModIma\\TempImages", tempId + "*");
                        var file = streamProvider.FileData.First();
                        string originalFileName = file.Headers.ContentDisposition.FileName.Replace("\"", "");
                        string originalExtension = Path.GetExtension(originalFileName);
                        FileInfo fi = new FileInfo(file.LocalFileName);
                        ImageProcessingFolfer = Path.Combine(portal.HomeDirectoryMapPath + "ModIma\\TempImages", tempId + originalExtension);
                        var size = fi.Length;
                        fi.CopyTo(ImageProcessingFolfer, true);
                        fi.Delete();
                        return new FileResultModel()
                        {
                            Extension = originalExtension,
                            Filename = tempId,
                            Size = size,
                            Link = "/ModIma/TempImages/" + tempId + originalExtension

                        };

                    }
                    throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.Unauthorized));
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
        /// Crop and Save an existing Solution Banner picture.
        /// </summary>
        /// <remarks>
        ///  This method takes an uploaded image into the temporal file repository using UploadBanner method and applies the repositiones and crop it.
        ///  Final image Height=575, Width=1148. Including original and thumbnail version. 
        /// </remarks>
        /// <param name="body">For this method Use yCrop and Filename</param>
        /// <param name="solutionId">Solution Id</param>
        /// <returns></returns>
        [DnnAuthorize]
        [HttpPut]
        public List<FileResultModel> CropSaveBanner([FromUri]Guid solutionId, [FromBody] CropImage body)
        {
            try
            {
                var filename = body.Filename;
                var yCropPosition = body.yCrop;
                var solution = new SolutionComponent(solutionId);
                var portal = PortalController.GetCurrentPortalSettings();
                var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
                var tempId = Helper.HelperMethods.GenerateHash(currentUser.UserID).ToString();
                if (currentUser.IsInRole("Registered Users"))
                {

                    if (currentUser.IsInRole("Administrators") || currentUser.IsInRole("NexsoSupport") || solution.Solution.CreatedUserId == DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo().UserID)
                    {
                        var fileResultModelList = new List<FileResultModel>();
                        yCropPosition = yCropPosition * -1;
                        string extension = ".png";//Path.GetExtension(filename);
                        string fileRootName = solutionId.ToString();
                        MemoryStream outStream = new MemoryStream();
                        long tmpSize = 0;
                        string ImageProcessingFolfer = Path.Combine(portal.HomeDirectoryMapPath + "ModIma\\TempImages", filename);
                        Helper.HelperMethods.DeleteFiles(portal.HomeDirectoryMapPath + "ModIma\\HeaderImages", "*" + solutionId.ToString() + "*");
                        ImageFactory imageFactory = new ImageFactory();
                        imageFactory.FixGamma = false;
                        imageFactory.Load(ImageProcessingFolfer);
                        imageFactory.Save(outStream);// ();
                        tmpSize = outStream.Length;
                        Helper.HelperMethods.SaveImage(ref outStream, Path.Combine(portal.HomeDirectoryMapPath + "ModIma\\HeaderImages", fileRootName + extension));


                        fileResultModelList.Add(new FileResultModel()
                        {
                            Extension = extension,
                            Filename = fileRootName,
                            Link = portal.HomeDirectory + "ModIma/HeaderImages/" + fileRootName + extension,
                            Description = "Original Image",
                            Size = tmpSize
                        });




                        var image = imageFactory.Image;
                        var originalHeight = image.Size.Height;
                        var originalWidth = image.Size.Width;
                        float referenceHeight = 575;
                        float referenceWidth = 1148;
                        float WidthFactor = 1;
                        WidthFactor = referenceWidth / originalWidth;
                        float HeightFactor = 1;
                        HeightFactor = referenceHeight / originalHeight;
                        float standardHeight = 0;
                        standardHeight = originalHeight * WidthFactor;
                        float cutTop = Convert.ToSingle(yCropPosition) / WidthFactor;
                        float cutBotom = (standardHeight - referenceHeight - cutTop) / WidthFactor;
                        Size sizeCrop = new Size(Convert.ToInt32(referenceWidth / WidthFactor), Convert.ToInt32(referenceHeight / WidthFactor));
                        Point pointCrop = new Point(0, Convert.ToInt32(cutTop));
                        Rectangle rectangleCrop = new Rectangle(pointCrop, sizeCrop);
                        imageFactory.Crop(rectangleCrop);
                        System.Drawing.Size sizeBig = new System.Drawing.Size(Convert.ToInt32(referenceWidth), Convert.ToInt32(referenceHeight));
                        var img = imageFactory.Resize(sizeBig);


                        outStream = new MemoryStream();
                        imageFactory.Save(outStream);
                        tmpSize = outStream.Length;
                        Helper.HelperMethods.SaveImage(ref outStream, Path.Combine(portal.HomeDirectoryMapPath + "ModIma\\HeaderImages", "cropBig" + fileRootName + extension));
                        fileResultModelList.Add(new FileResultModel()
                        {
                            Extension = extension,
                            Filename = "cropBig" + fileRootName,
                            Link = portal.HomeDirectory + "ModIma/HeaderImages/" + "cropBig" + fileRootName + extension,
                            Description = "Crop Big",
                            Size = tmpSize


                        });


                        System.Drawing.Size sizeSmall = new System.Drawing.Size(Convert.ToInt32(600), Convert.ToInt32(300));
                        imageFactory.Resize(sizeSmall);
                        outStream = new MemoryStream();
                        imageFactory.Save(outStream);
                        tmpSize = outStream.Length;
                        Helper.HelperMethods.SaveImage(ref outStream, Path.Combine(portal.HomeDirectoryMapPath + "ModIma\\HeaderImages", "cropThumb" + fileRootName + extension));




                        fileResultModelList.Add(new FileResultModel()
                        {
                            Extension = extension,
                            Filename = "cropThumb" + fileRootName,
                            Link = portal.HomeDirectory + "ModIma/HeaderImages/" + "cropThumb" + fileRootName + extension,
                            Description = "Crop Thumbnail",
                            Size = tmpSize


                        });
                        Helper.HelperMethods.DeleteFiles(portal.HomeDirectoryMapPath + "ModIma\\TempUserImages", filename + "*");
                        return fileResultModelList;

                    }
                    else
                        throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.Unauthorized));
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
        /// Remove a solution banner image
        /// </summary>
        /// <remarks>
        /// Delete a solution banner image from the file system.
        /// </remarks>
        /// <returns></returns>
        /// <response code="202">Successful Delete</response>
        /// <response code="401">Unauthorized if user is not authenticated</response>
        /// <response code="500">Internal ServerError</response>
        [DnnAuthorize]
        [HttpDelete]
        public HttpResponseMessage RemoveBannerImage(Guid solutionId)
        {
            try
            {
                var portal = PortalController.GetCurrentPortalSettings();
                var user = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
                var userProperty = new UserPropertyComponent(user.UserID);

                var solution = new SolutionComponent(solutionId);
                if (user.IsInRole("Administrators") || solution.Solution.CreatedUserId == user.UserID)
                {
                    Helper.HelperMethods.DeleteFiles(portal.HomeDirectoryMapPath + "ModIma\\HeaderImages", "*" + solution.Solution.SolutionId.ToString() + "*");
                    return Request.CreateResponse(HttpStatusCode.Accepted, "Successful Delete");
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
        /// Get a list of changes for a specific solution
        /// </summary>
        /// <remarks>
        /// Get a particular log for an specific field in the solution.
        /// </remarks>
        /// <param name="solutionId">Solution Id</param>
        /// <param name="key">key for search</param>
        /// <param name="rows">Default 0</param>
        /// <param name="page">Default 0</param>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="401">Unauthorized if authenticated user id is not valid or user is not owner of the solution or administrator</response>
        /// <response code="500">Internal ServerError.</response>
        /// <response code="400">The specified parameters are incorrect.</response>
        /// <response code="406">The specified Id does not much with any record</response>
        [DnnAuthorize]
        [HttpGet]
        public List<SolutionLogModel> GetLog(Guid solutionId, string key, int rows = 0, int page = 0)
        {
            try
            {
                if (solutionId != Guid.Empty && !string.IsNullOrEmpty(key))
                {
                    SolutionComponent solution = new SolutionComponent(solutionId);
                    if (solution.Solution.SolutionId != Guid.Empty)
                    {
                        var portal = PortalController.GetCurrentPortalSettings();
                        var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
                        if (solution.Solution.CreatedUserId == currentUser.UserID || currentUser.IsInRole("Administrator"))
                        {

                            var result = SolutionLogComponent.GetLogs(solutionId, key).OrderByDescending(p => p.Date);
                            var totalCount = result.Count();
                            var totalPages = (int)Math.Ceiling((double)totalCount / rows);

                            var prevLink = page > 0 ? string.Format("/solution/GetLog?rows={0}&page={1}", rows, page - 1) : "";
                            var nextLink = page < totalPages - 1 ? string.Format("/solution/GetLog?rows={0}&page={1}", rows, page + 1) : "";

                            List<SolutionLogModel> solutionLogModel = new List<SolutionLogModel>();

                            foreach (var resultTmp in result.Skip(page * rows).Take(rows).ToList())
                            {
                                solutionLogModel.Add(new SolutionLogModel()
                                {
                                    SolutionLogId = resultTmp.SolutionLogId,
                                    SolutionId = resultTmp.SolutionId,
                                    Key = resultTmp.Key,
                                    Value = resultTmp.Value,
                                    Date = Convert.ToDateTime(resultTmp.Date),
                                    DataType = resultTmp.DataType

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
                            return solutionLogModel;
                        }
                        throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.Unauthorized));
                    }
                    throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.NotAcceptable));
                }
                throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.BadRequest));
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


        [AllowAnonymous]
        [HttpGet]
        public string GetSolutions(int rows, int page, int min, int max, int state, string categories = "", string beneficiaries = "", string deliveryFormat = "", string filter = "", bool fullContent = false, string language = "en-US", string search = "", string userId = "", string organization = null)
        {
            try
            {
                var solutionOrganizationJson = new List<SolutionOrganizationJson>();
                int totalCount = 0;

                if (!string.IsNullOrEmpty(search))
                {
                    solutionOrganizationJson = GetSolutionsIndexed(ref rows, ref page, ref min, ref max, ref state, ref language, ref search, ref userId, ref totalCount);
                }
                else
                {
                    solutionOrganizationJson = GetSolutionsList(ref rows, ref page, ref min, ref max, ref state, ref categories, ref beneficiaries, ref deliveryFormat, ref filter, ref language, ref search, ref userId, ref organization);
                }

                // This line for pagination
                if (totalCount > 0)
                {
                    var totalPages = (totalCount / rows);
                    var pageOf = page;

                    var paginationHeader = new
                    {
                        TotalCount = totalCount,
                        TotalPages = totalPages,
                        pageOf = page

                    };

                    System.Web.HttpContext.Current.Response.Headers.Add("X-Pagination",
                    Newtonsoft.Json.JsonConvert.SerializeObject(paginationHeader));
                }
                
                return JsonConvert.SerializeObject(solutionOrganizationJson);

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

        #region [Method Help GetSolutions]
        private List<SolutionOrganizationJson> GetSolutionsList(ref int rows, ref int page, ref int min, ref int max, ref int state, ref string categories, ref string beneficiaries, ref string deliveryFormat, ref string filter, ref string language, ref string search, ref string userId, ref string organization)
        {
            var lReturnSolutionOrganizationJson = new List<SolutionOrganizationJson>();

            if (string.IsNullOrWhiteSpace(categories))
                categories = string.Empty;
            if (string.IsNullOrWhiteSpace(beneficiaries))
                beneficiaries = string.Empty;
            if (string.IsNullOrWhiteSpace(deliveryFormat))
                deliveryFormat = string.Empty;
            if (string.IsNullOrWhiteSpace(filter))
                filter = string.Empty;
            if (string.IsNullOrWhiteSpace(language))
                language = "en-US";
            if (string.IsNullOrWhiteSpace(search))
                search = string.Empty;
            if (string.IsNullOrWhiteSpace(userId))
                userId = string.Empty;

            int userIdInt = -1;

            try
            {
                userIdInt = Convert.ToInt32(userId);
            }
            catch
            {

            }

            string challengeReference = "%";
            string solutionType = "%";
            string languageFilter = "%";
            var categoryArray = JsonConvert.DeserializeObject<List<string>>(categories);
            var beneficiariesArray = JsonConvert.DeserializeObject<List<string>>(beneficiaries);
            var deliveryFormatArray = JsonConvert.DeserializeObject<List<string>>(deliveryFormat);
            CultureInfo cultureInfo = new CultureInfo(language, false);
            MIFNEXSOEntities mifNexsoEntities = new MIFNEXSOEntities();



            if (filter != "")
            {


                dynamic JsonDe = JsonConvert.DeserializeObject(filter);
                if (JsonDe != null)
                {
                    foreach (dynamic element in JsonDe)
                    {
                        if (element["ChallengeReference"] != null)
                            challengeReference = element["ChallengeReference"].ToString();
                        if (element["SolutionType"] != null)
                            solutionType = element["SolutionType"].ToString();
                        if (element["Language"] != null)
                            languageFilter = element["Language"].ToString();
                        if (element["Language"] != null)
                            languageFilter = element["Language"].ToString();
                    }

                }
            }
            ObjectParameter count = new ObjectParameter("Count", typeof(int));
            ObjectResult<spGetSolutionsOrganizations_Result> result = null;
            if (Users.UserController.Instance.GetCurrentUserInfo().IsInRole("Administrators") || (Users.UserController.Instance.GetCurrentUserInfo().UserID == userIdInt && userIdInt >= 0))
            {
                result = mifNexsoEntities.spGetSolutionsOrganizations(rows, page, min, max, state, search, JsonToSQLParameter(categoryArray), JsonToSQLParameter(beneficiariesArray), JsonToSQLParameter(deliveryFormatArray), userIdInt, challengeReference, solutionType, languageFilter, "", count, organization);
            }
            else if (state >= 1000)
            {
                result = mifNexsoEntities.spGetSolutionsOrganizations(rows, page, min, max, 1000, search, JsonToSQLParameter(categoryArray), JsonToSQLParameter(beneficiariesArray), JsonToSQLParameter(deliveryFormatArray), userIdInt, challengeReference, solutionType, languageFilter, "", count, organization);
            }

            List<spGetSolutionsOrganizations_Result> resultL = new List<spGetSolutionsOrganizations_Result>();


            if (result != null)
                resultL = result.ToList();
            string solutionUrlTmp = string.Empty;

            foreach (var resultTmp in resultL)
            {
                if (!Convert.ToBoolean(resultTmp.SDeleted))
                {
                    if (resultTmp.SSolutionState < 800)
                        solutionUrlTmp = NexsoHelper.GetCulturedUrlByTabName("promote", 0, cultureInfo.Name);
                    else
                        solutionUrlTmp = NexsoHelper.GetCulturedUrlByTabName("solprofile", 0, cultureInfo.Name);

                    string challengeState = "enabled";
                    if (resultTmp.SChallengeReference != null)
                    {
                        ChallengeComponent challengeComponent = new ChallengeComponent(resultTmp.SChallengeReference);
                        if (challengeComponent != null)
                        {
                            if (challengeComponent.Challenge != null)
                            {
                                if (challengeComponent.Challenge.EntryTo != null && challengeComponent.Challenge.Closed != null)
                                {
                                    if (!string.IsNullOrEmpty(challengeComponent.Challenge.EntryTo.ToString()) && !string.IsNullOrEmpty(challengeComponent.Challenge.Closed.ToString()))
                                    {
                                        if (challengeComponent.Challenge.EntryTo < DateTime.Now && challengeComponent.Challenge.Closed > DateTime.Now)
                                            challengeState = "disabled";
                                    }
                                }
                            }
                        }
                    }

                    lReturnSolutionOrganizationJson.Add(new SolutionOrganizationJson()
                    {
                        SolutionTitle = WebUtility.HtmlDecode(resultTmp.STitle),
                        SolutionThemes = FillFormat(resultTmp.SSolutionId, "Theme", cultureInfo),
                        SolutionBeneficiaries = FillFormat(resultTmp.SSolutionId, "Beneficiaries", cultureInfo),
                        SolutionDeliveryFormat = FillFormat(resultTmp.SSolutionId, "DeliveryFormat", cultureInfo),
                        SolutionState = resultTmp.SSolutionState.GetValueOrDefault(0),
                        SolutionId = resultTmp.SSolutionId,
                        OrganizationLogo = resultTmp.OLogo,
                        OrganizationId = resultTmp.OOrganizationID,
                        OrganizationName = WebUtility.HtmlDecode(resultTmp.OName),
                        SolutionCost = resultTmp.SCost.GetValueOrDefault(-1),
                        SolutionCostUnit = NexsoProBLL.ListComponent.GetLabelFromListValue("Cost", cultureInfo.Name, resultTmp.SCostType.GetValueOrDefault(-1).ToString()),
                        ProjectDuration = NexsoProBLL.ListComponent.GetLabelFromListValue("ProjectDuration", cultureInfo.Name, resultTmp.SDuration.GetValueOrDefault(-1).ToString()),
                        OrganizationUrl = NexsoHelper.GetCulturedUrlByTabName("insprofile", 0, cultureInfo.Name),
                        SolutionUrl = solutionUrlTmp,
                        SolutionTagLine = WebUtility.HtmlDecode(resultTmp.STagLine),
                        SolutionHeader = GetHeaderImage(resultTmp.SSolutionId),
                        SolutionLocations = GetSolutionLocations(resultTmp.SSolutionId),
                        ChallengeReference = resultTmp.SChallengeReference,
                        SolutionType = resultTmp.SSolutionType,
                        ChallengeState = challengeState,                        
                        Likes=Convert.ToInt32(SocialMediaIndicatorComponent.GetAggregatorSocialMediaIndicatorPerObjectRelated(resultTmp.SSolutionId, "SOLUTION", "LIKE", "SUM")).ToString()
                    });
                }
            }
            return lReturnSolutionOrganizationJson;
        }

        /// <summary>
        /// Gets list of solutions for index data
        /// </summary>
        /// <param name="rows"></param>
        /// <param name="page"></param>
        /// <param name="min"></param>
        /// <param name="max"></param>
        /// <param name="state"></param>
        /// <param name="language"></param>
        /// <param name="search"></param>
        /// <param name="userId"></param>
        /// <returns></returns>
        private List<SolutionOrganizationJson> GetSolutionsIndexed(ref int rows, ref int page, ref int min, ref int max, ref int state, ref string language, ref string search, ref string userId,  ref int totalCount)
        {
            // This list of return
            var lReturnSolutionOrganizationJson = new List<SolutionOrganizationJson>();
            // This variable get num of request gets for Lucene // this is for pagination
            totalCount = 0;

            // Here it validates that the variable has information 
            if (!string.IsNullOrEmpty(search))
            {
                //This line ensures that the variable always have a value UserIdInt
                int userIdInt = int.TryParse(userId, out userIdInt) ? userIdInt : -1;

                // Get Culture Info
                CultureInfo cultureInfo = new CultureInfo(language, false);

                // Initial Lines for Lucene
                List<string> ListSolutionsId = new List<string>();
                //This line gets the Id files Solutions indexed Lucene 
                ListSolutionsId = new SearcherIndex().SearcherId(search.Trim());
                // end Lines for Lucene

                if (ListSolutionsId.Count > 0)
                {
                    //Variables for get information of Data base.
                    var count = new ObjectParameter("Count", typeof(int));

                    var resultL = new List<spGetSolutionsOrganizationsV2_Result>();
                    var resultLOrderbyLucene = new List<spGetSolutionsOrganizationsV2_Result>();

                    //This line opening conexion database, get data an closing
                    using (var mifNexsoEntities = new MIFNEXSOEntities())
                    {
                        if (Users.UserController.Instance.GetCurrentUserInfo().IsInRole("Administrators") || (Users.UserController.Instance.GetCurrentUserInfo().UserID == userIdInt && userIdInt >= 0))
                            resultL = mifNexsoEntities.spGetSolutionsOrganizationsV2(rows, page, min, max, state, JsonToSQLParameter(ListSolutionsId), userIdInt, count).ToList();
                        else if (state >= 1000)
                            resultL = mifNexsoEntities.spGetSolutionsOrganizationsV2(rows, page, min, max, 1000, JsonToSQLParameter(ListSolutionsId), userIdInt, count).ToList();
                    }

                    //These lines organize the list that recovery of the database in the same order as the Lucene give again.

                    //This variable breaks the cicles when the list of result Db is equals of the new list of resultLOrderbyLucene
                    bool endCicle = false;
                    //This method iterates through  the list of records obtained by lucene.
                    foreach (var itemSolutionsId in ListSolutionsId)
                    {   //This method iterates through  the list of records obtained by DB.
                        foreach (var itemresultL in resultL)
                        {    //This method compare the two lists 
                            if (itemresultL.SSolutionId.ToString().Equals(itemSolutionsId))
                            {   //This line again inserted records arranged list
                                resultLOrderbyLucene.Add(itemresultL);

                                if (resultL.Count() == resultLOrderbyLucene.Count())
                                {
                                    endCicle = true;
                                    break;
                                }
                            }
                        }
                        if (endCicle)
                            break;
                    }

                    string solutionUrlTmp = string.Empty;
                    foreach (var resultTmp in resultLOrderbyLucene)
                    {
                        if (!Convert.ToBoolean(resultTmp.SDeleted))
                        {
                            if (resultTmp.SSolutionState < 800)
                                solutionUrlTmp = NexsoHelper.GetCulturedUrlByTabName("promote", 0, cultureInfo.Name);
                            else
                                solutionUrlTmp = NexsoHelper.GetCulturedUrlByTabName("solprofile", 0, cultureInfo.Name);

                            string challengeState = "enabled";
                            if (resultTmp.SChallengeReference != null)
                            {
                                ChallengeComponent challengeComponent = new ChallengeComponent(resultTmp.SChallengeReference);
                                if (challengeComponent != null)
                                    if (challengeComponent.Challenge != null)
                                        if (challengeComponent.Challenge.EntryTo != null && challengeComponent.Challenge.Closed != null)
                                            if (!string.IsNullOrEmpty(challengeComponent.Challenge.EntryTo.ToString()) && !string.IsNullOrEmpty(challengeComponent.Challenge.Closed.ToString()))
                                                if (challengeComponent.Challenge.EntryTo < DateTime.Now && challengeComponent.Challenge.Closed > DateTime.Now)
                                                    challengeState = "disabled";
                            }

                            lReturnSolutionOrganizationJson.Add(new SolutionOrganizationJson()
                            {
                                SolutionTitle = WebUtility.HtmlDecode(resultTmp.STitle),
                                SolutionThemes = FillFormat(resultTmp.SSolutionId, "Theme", cultureInfo),
                                SolutionBeneficiaries = FillFormat(resultTmp.SSolutionId, "Beneficiaries", cultureInfo),
                                SolutionDeliveryFormat = FillFormat(resultTmp.SSolutionId, "DeliveryFormat", cultureInfo),
                                SolutionState = resultTmp.SSolutionState.GetValueOrDefault(0),
                                SolutionId = resultTmp.SSolutionId,
                                OrganizationLogo = resultTmp.OLogo,
                                OrganizationId = resultTmp.OOrganizationID,
                                OrganizationName = WebUtility.HtmlDecode(resultTmp.OName),
                                SolutionCost = resultTmp.SCost.GetValueOrDefault(-1),
                                SolutionCostUnit = NexsoProBLL.ListComponent.GetLabelFromListValue("Cost", cultureInfo.Name, resultTmp.SCostType.GetValueOrDefault(-1).ToString()),
                                ProjectDuration = NexsoProBLL.ListComponent.GetLabelFromListValue("ProjectDuration", cultureInfo.Name, resultTmp.SDuration.GetValueOrDefault(-1).ToString()),
                                OrganizationUrl = NexsoHelper.GetCulturedUrlByTabName("insprofile", 0, cultureInfo.Name),
                                SolutionUrl = solutionUrlTmp,
                                SolutionTagLine = WebUtility.HtmlDecode(resultTmp.STagLine),
                                SolutionHeader = GetHeaderImage(resultTmp.SSolutionId),
                                SolutionLocations = GetSolutionLocations(resultTmp.SSolutionId),
                                ChallengeReference = resultTmp.SChallengeReference,
                                SolutionType = resultTmp.SSolutionType,
                                ChallengeState = challengeState,
                                Likes = Convert.ToInt32(SocialMediaIndicatorComponent.GetAggregatorSocialMediaIndicatorPerObjectRelated(resultTmp.SSolutionId, "SOLUTION", "LIKE", "SUM")).ToString()
                            });
                        }
                    }


                }
                else
                {
                    //TODO: Alberto Message No Records Found
                }

            }
            else
            {
                //TODO: Alberto "search" in Empty
            }

            return lReturnSolutionOrganizationJson;
        }

        private List<string> FillFormat(Guid solutionId, string category, CultureInfo cultureInfo)
        {
            var list = SolutionListComponent.GetListPerCategory(solutionId, category);
            List<string> listRet = new List<string>();
            foreach (var item in list)
            {
                listRet.Add(NexsoProBLL.ListComponent.GetLabelFromListKey(category, cultureInfo.Name, item.Key));
            }

            return listRet;
        }

        private string GetHeaderImage(Guid solutionId)
        {

            if (File.Exists(
                 HttpContext.Current.Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/cropThumb" +
                                  solutionId.ToString() +
                                   ".jpg")))
            {
                return PortalSettings.HomeDirectory + "ModIma/HeaderImages/cropThumb" + solutionId.ToString() + ".jpg";
            }
            else
                if (File.Exists(
                    HttpContext.Current.Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/cropThumb" +
                                  solutionId.ToString() +
                                   ".png")))
                {
                    return PortalSettings.HomeDirectory + "ModIma/HeaderImages/cropThumb" + solutionId.ToString() + ".png";
                }
                else
                {
                    var list = SolutionListComponent.GetListPerCategory(solutionId, "Theme").ToList();

                    if (list.Count > 0)
                    {

                        Random randNum = new Random();

                        var theme = list[randNum.Next(list.Count)].Key;
                        if (File.Exists(
                        HttpContext.Current.Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/" + theme + ".jpg")))
                        {
                            return PortalSettings.HomeDirectory + "ModIma/HeaderImages/" + theme + ".jpg";
                        }
                        else
                        {
                            return PortalSettings.HomeDirectory + "ModIma/HeaderImages/noHeader.png";
                        }

                    }
                    else
                    {
                        return PortalSettings.HomeDirectory + "ModIma/HeaderImages/noHeader.png";
                    }
                }
        }

        private List<SolutioLocationJson> GetSolutionLocations(Guid solutionId)
        {
            List<SolutioLocationJson> return_ = new List<SolutioLocationJson>();
            var solutionLocationSource = SolutionLocationComponent.GetSolutionLocationsPerSolution(solutionId).ToList();
            foreach (var solLoc in solutionLocationSource)
            {
                return_.Add(new SolutioLocationJson()
                {
                    City = MIFWebServices.LocationService.GetCityName(solLoc.City),
                    Region = MIFWebServices.LocationService.GetStateName(solLoc.Region),
                    Country = MIFWebServices.LocationService.GetCountryName(solLoc.Country),
                    Latitude = solLoc.Latitude.GetValueOrDefault(0),
                    Longitude = solLoc.Longitude.GetValueOrDefault(0)


                });
            }
            return return_;
        }

        private string JsonToSQLParameter(List<string> array)
        {
            StringBuilder clause = new StringBuilder();
            if (array != null)
            {
                foreach (var element in array)
                {
                    clause.Append("'" + element + "',");
                }
                if (clause.Length > 0)
                    clause.Remove(clause.Length - 1, 1);
            }
            return clause.ToString();
        }

        #endregion

    }
}
