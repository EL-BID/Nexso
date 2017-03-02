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
#endregion

namespace NexsoServices
{
    public class ValidateMimeMultipartContentFilter : ActionFilterAttribute
    {
        public override void OnActionExecuting(HttpActionContext actionContext)
        {
            if (!actionContext.Request.Content.IsMimeMultipartContent())
            {
                throw new HttpResponseException(HttpStatusCode.UnsupportedMediaType);
            }
        }

        public override void OnActionExecuted(HttpActionExecutedContext actionExecutedContext)
        {

        }

    }





    public class NexsoController : DnnApiController
    {





        [HttpGet]
        [DnnAuthorize]
        public HttpResponseMessage TestNexsoUser()
        {
            var ps = PortalController.GetCurrentPortalSettings();
            var currentUser = UserController.GetCurrentUserInfo();
            if (currentUser.IsInRole("Registered Users"))
                return Request.CreateResponse(HttpStatusCode.OK, currentUser.Username + " - " + ps.PortalName);
            return Request.CreateResponse(HttpStatusCode.Unauthorized, "Unauthorized");
        }

        [HttpGet]
        [DnnAuthorize]
        public HttpResponseMessage TestNexsoJudge()
        {
            PortalSettings ps = PortalController.GetCurrentPortalSettings();
            var currentUser = UserController.GetCurrentUserInfo();
            if (currentUser.IsInRole("NexsoJudge"))
                return Request.CreateResponse(HttpStatusCode.OK, currentUser.Username + " - " + ps.PortalName);
            return Request.CreateResponse(HttpStatusCode.Unauthorized, "Unauthorized");
        }

        [HttpGet]
        [DnnAuthorize]
        public HttpResponseMessage TestNexsoSupport()
        {
            var ps = PortalController.GetCurrentPortalSettings();
            var currentUser = UserController.GetCurrentUserInfo();
            if (currentUser.IsInRole("NexsoSupport"))
                return Request.CreateResponse(HttpStatusCode.OK, currentUser.Username + " - " + ps.PortalName);
            return Request.CreateResponse(HttpStatusCode.Unauthorized, "Unauthorized");
        }

        [HttpGet]
        [DnnAuthorize]
        public HttpResponseMessage TestAuth()
        {
            var ps = PortalController.GetCurrentPortalSettings();
            var currentUser = UserController.GetCurrentUserInfo();
            if (currentUser.UserID > 0)
                return Request.CreateResponse(HttpStatusCode.OK, currentUser.Username + " - " + ps.PortalName);
            return Request.CreateResponse(HttpStatusCode.Unauthorized, "Unauthorized");
        }

        [AllowAnonymous]
        [HttpGet]
        public HttpResponseMessage Test()
        {
            var ps = PortalController.GetCurrentPortalSettings();
            var currentUser = UserController.GetCurrentUserInfo();
            if (currentUser.UserID > 0)
                return Request.CreateResponse(HttpStatusCode.OK, currentUser.Username + " - " + ps.PortalName);
            return Request.CreateResponse(HttpStatusCode.OK, "Anonymous");

        }

        [DnnAuthorize]
        [HttpPost]
        [ValidateMimeMultipartContentFilter]
        public async Task<FileResult> UploadSolutionBannerFile()
        {



            try
            {

                var portal = PortalController.GetCurrentPortalSettings();
                var currentUser = UserController.GetCurrentUserInfo();

                if (currentUser.IsInRole("Registered Users"))
                {
                    string ServerUploadFolder = portal.HomeDirectoryMapPath + "ModIma\\TempImages";
                    var streamProvider = new MultipartFormDataStreamProvider(ServerUploadFolder);
                    string ImageProcessingFolfer = "";
                    await Request.Content.ReadAsMultipartAsync(streamProvider);




                    string solutionId = streamProvider.FormData["solutionId"];
                    string yCropPosition = streamProvider.FormData["yCropPosition"];

                    var solution = new SolutionComponent(new Guid(solutionId));



                    if (currentUser.IsInRole("Administrators") || solution.Solution.CreatedUserId == currentUser.UserID)
                    {

                        var file = streamProvider.FileData.First();
                        string originalFileName = file.Headers.ContentDisposition.FileName.Replace("\"", "");
                        string originalExtension = Path.GetExtension(originalFileName);


                        FileInfo fi = new FileInfo(file.LocalFileName);
                        ImageProcessingFolfer = Path.Combine(portal.HomeDirectoryMapPath + "ModIma\\TempImages", solutionId + originalExtension);
                        fi.CopyTo(ImageProcessingFolfer, true);
                        fi.Delete();







                        return new FileResult
                        {


                            Result = "OK",
                            FileName = solutionId + originalExtension

                        };
                    }
                    else
                    {
                        return new FileResult
                        {

                            Result = "Unauthorized"

                        };
                    }

                }
                else
                {
                    return new FileResult
                    {

                        Result = "Unauthorized"

                    };
                }

            }
            catch
            {
                return new FileResult
                {

                    Result = "Internal Server Error"

                };
            }
        }




        private void deleteFiles(string dir, string solutionid)
        {
            string[] filePaths = Directory.GetFiles(dir, "*" + solutionid + "*");
            foreach (string filePath in filePaths)
                File.Delete(filePath);

        }

        [DnnAuthorize]
        [HttpGet]
        public HttpResponseMessage CropBannerFile(string filename, int yCropPosition, string solutionId)
        {
            try
            {
                var solution = new SolutionComponent(new Guid(solutionId));
                var portal = PortalController.GetCurrentPortalSettings();
                var currentUser = UserController.GetCurrentUserInfo();

                if (currentUser.IsInRole("Registered Users"))
                {

                    if (UserController.GetCurrentUserInfo().IsInRole("Administrators") || solution.Solution.CreatedUserId == UserController.GetCurrentUserInfo().UserID)
                    {

                        yCropPosition = yCropPosition * -1;
                        string extension = Path.GetExtension(filename);
                        string fileRootName = filename.Replace(extension, "");

                        string ImageProcessingFolfer = Path.Combine(portal.HomeDirectoryMapPath + "ModIma\\TempImages", filename);
                        deleteFiles(portal.HomeDirectoryMapPath + "ModIma\\HeaderImages", solutionId);
                        ImageFactory imageFactory = new ImageFactory(preserveExifData: true);
                        imageFactory.Load(ImageProcessingFolfer);
                        imageFactory.Save(Path.Combine(portal.HomeDirectoryMapPath + "ModIma\\HeaderImages", fileRootName + extension));
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

                        imageFactory.Resize(sizeBig);
                        imageFactory.Save(Path.Combine(portal.HomeDirectoryMapPath + "ModIma\\HeaderImages", "cropBig" + fileRootName + extension));

                        System.Drawing.Size sizeSmall = new System.Drawing.Size(Convert.ToInt32(600), Convert.ToInt32(300));


                        imageFactory.Resize(sizeSmall);
                        imageFactory.Save(Path.Combine(portal.HomeDirectoryMapPath + "ModIma\\HeaderImages", "cropThumb" + fileRootName + extension));
                        return Request.CreateResponse(HttpStatusCode.OK, "OK");

                    }
                    else
                        return Request.CreateResponse(HttpStatusCode.InternalServerError, "Internal Server Error");
                }
                return Request.CreateResponse(HttpStatusCode.Unauthorized, "Unauthorized");
            }
            catch
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, "Internal Server Error");
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
                        {
                            if (element["SolutionType"].ToString()!=string.Empty)
                                solutionType = element["SolutionType"].ToString();
                        }
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
            return lReturnSolutionOrganizationJson.OrderByDescending(a=>Convert.ToInt32(a.Likes)).ToList();
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
        private List<SolutionOrganizationJson> GetSolutionsIndexed(ref int rows, ref int page, ref int min, ref int max, ref int state, ref string language, ref string search, ref string userId, ref int totalCount)
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
                totalCount = ListSolutionsId.Count();
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
                                ChallengeState = challengeState
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


        #endregion


        [AllowAnonymous]
        [HttpGet]
        public string GetListCategory(string category, string language = "en-US")
        {
            CultureInfo cultureInfo = new CultureInfo(language, false);
            var list = ListComponent.GetListPerCategory(category, cultureInfo.Name).ToList();
            return JsonConvert.SerializeObject(list);
        }

        [DnnAuthorize]
        [HttpGet]
        public string GetUserProfile(int? userId = null)
        {

            var currentUser = UserController.GetCurrentUserInfo();
            int userIdValid = userId.GetValueOrDefault(-1);
            if (userId == null)
                userIdValid = currentUser.UserID;




            UserPropertyComponent userPropertyComponent = new UserPropertyComponent(userIdValid);

            if (currentUser.IsInRole("Administrators") || currentUser.UserID == userIdValid)
            {


                return JsonConvert.SerializeObject(new UserProfileJson()
                {
                    UserId = userPropertyComponent.UserProperty.UserId,
                    NexsoUserId = userPropertyComponent.UserProperty.NexsoUserId == null ? Guid.Empty : (Guid)userPropertyComponent.UserProperty.NexsoUserId,
                    Agreement = userPropertyComponent.UserProperty.Agreement,
                    SkypeName = userPropertyComponent.UserProperty.SkypeName,
                    Twitter = userPropertyComponent.UserProperty.Twitter,
                    FaceBook = userPropertyComponent.UserProperty.FaceBook,
                    Google = userPropertyComponent.UserProperty.Google,
                    LinkedIn = userPropertyComponent.UserProperty.LinkedIn,
                    OtherSocialNetwork = userPropertyComponent.UserProperty.OtherSocialNetwork,
                    City = userPropertyComponent.UserProperty.City,
                    Region = userPropertyComponent.UserProperty.Region,
                    Country = userPropertyComponent.UserProperty.Country,
                    PostalCode = userPropertyComponent.UserProperty.PostalCode,
                    Telephone = userPropertyComponent.UserProperty.Telephone,
                    Address = userPropertyComponent.UserProperty.Address,
                    FirstName = userPropertyComponent.UserProperty.FirstName,
                    LastName = userPropertyComponent.UserProperty.LastName,
                    email = userPropertyComponent.UserProperty.email,
                    CustomerType = Convert.ToInt32(userPropertyComponent.UserProperty.CustomerType),
                    NexsoEnrolment = Convert.ToInt32(userPropertyComponent.UserProperty.NexsoEnrolment),
                    AllowNexsoNotifications = Convert.ToInt32(userPropertyComponent.UserProperty.AllowNexsoNotifications),
                    Language = Convert.ToInt32(userPropertyComponent.UserProperty.Language),
                    Latitude = Convert.ToDecimal(userPropertyComponent.UserProperty.Latitude),
                    Longitude = Convert.ToDecimal(userPropertyComponent.UserProperty.Longitude),
                    GoogleLocation = userPropertyComponent.UserProperty.GoogleLocation
                });
            }
            else
            {
                return JsonConvert.SerializeObject(new UserProfileJson()
                {
                    UserId = userPropertyComponent.UserProperty.UserId,
                    NexsoUserId = userPropertyComponent.UserProperty.NexsoUserId == null ? Guid.Empty : (Guid)userPropertyComponent.UserProperty.NexsoUserId,
                    Twitter = userPropertyComponent.UserProperty.Twitter,
                    FaceBook = userPropertyComponent.UserProperty.FaceBook,
                    Google = userPropertyComponent.UserProperty.Google,
                    LinkedIn = userPropertyComponent.UserProperty.LinkedIn,
                    OtherSocialNetwork = userPropertyComponent.UserProperty.OtherSocialNetwork,
                    City = userPropertyComponent.UserProperty.City,
                    Region = userPropertyComponent.UserProperty.Region,
                    Country = userPropertyComponent.UserProperty.Country,
                    FirstName = userPropertyComponent.UserProperty.FirstName,
                    LastName = userPropertyComponent.UserProperty.LastName,
                    Language = Convert.ToInt32(userPropertyComponent.UserProperty.Language),
                    Latitude = Convert.ToDecimal(userPropertyComponent.UserProperty.Latitude),
                    Longitude = Convert.ToDecimal(userPropertyComponent.UserProperty.Longitude),
                    GoogleLocation = userPropertyComponent.UserProperty.GoogleLocation
                });
            }







        }


        [DnnAuthorize]
        [HttpGet]
        public string GetNotificationList2(int max, string filter, string language = "en-US")
        {
            List<NotificationJson> auxReturn_ = new List<NotificationJson>();
            List<NotificationJson> return_ = new List<NotificationJson>();
            if (language == null || language == "null")
                language = "en-US";
            CultureInfo lang = new CultureInfo(language);
            ResourceManager Localization = new ResourceManager("NexsoServices.App_LocalResources.Resource", Assembly.GetExecutingAssembly());


            var message = Localization.GetString("MessageNotification", lang);

            var currentUser = UserController.GetCurrentUserInfo();

            var ListNotification = NexsoProBLL.UserNotificationConnectionComponent.GetUserNotificationConnections(currentUser.UserID);


            foreach (var item in ListNotification)
            {

                List<UserProfileJson> userProfileJson = new List<UserProfileJson>();
                var ListUserNotificationConnection = NexsoProBLL.UserNotificationConnectionComponent.GetUserNotificationConnections(item.NotificationId);

                foreach (var UserNotification in ListUserNotificationConnection)
                {
                    UserPropertyComponent userPropertyComponent = new UserPropertyComponent(UserNotification.UserId);
                    userProfileJson.Add(new UserProfileJson()
                    {

                        UserId = userPropertyComponent.UserProperty.UserId,
                        NexsoUserId = userPropertyComponent.UserProperty.NexsoUserId == null ? Guid.Empty : (Guid)userPropertyComponent.UserProperty.NexsoUserId,
                        Agreement = userPropertyComponent.UserProperty.Agreement,
                        SkypeName = userPropertyComponent.UserProperty.SkypeName,
                        Twitter = userPropertyComponent.UserProperty.Twitter,
                        FaceBook = userPropertyComponent.UserProperty.FaceBook,
                        Google = userPropertyComponent.UserProperty.Google,
                        LinkedIn = userPropertyComponent.UserProperty.LinkedIn,
                        OtherSocialNetwork = userPropertyComponent.UserProperty.OtherSocialNetwork,
                        City = userPropertyComponent.UserProperty.City,
                        Region = userPropertyComponent.UserProperty.Region,
                        Country = userPropertyComponent.UserProperty.Country,
                        PostalCode = userPropertyComponent.UserProperty.PostalCode,
                        Telephone = userPropertyComponent.UserProperty.Telephone,
                        Address = userPropertyComponent.UserProperty.Address,
                        FirstName = userPropertyComponent.UserProperty.FirstName,
                        LastName = userPropertyComponent.UserProperty.LastName,
                        email = userPropertyComponent.UserProperty.email,
                        CustomerType = Convert.ToInt32(userPropertyComponent.UserProperty.CustomerType),
                        NexsoEnrolment = Convert.ToInt32(userPropertyComponent.UserProperty.NexsoEnrolment),
                        AllowNexsoNotifications = Convert.ToInt32(userPropertyComponent.UserProperty.AllowNexsoNotifications),
                        Language = Convert.ToInt32(userPropertyComponent.UserProperty.Language),
                        Latitude = Convert.ToDecimal(userPropertyComponent.UserProperty.Latitude),
                        Longitude = Convert.ToDecimal(userPropertyComponent.UserProperty.Longitude),
                        GoogleLocation = userPropertyComponent.UserProperty.GoogleLocation

                    });
                }

                NotificationComponent notificacionComponent = new NotificationComponent(item.NotificationId);
                if (notificacionComponent.Notification.Code == "LIKE")
                    message = Localization.GetString("LikeNotification", lang);

                return_.Add(new NotificationJson()
                {
                    NotificationId = notificacionComponent.Notification.NotificationId,
                    UserId = notificacionComponent.Notification.UserId,
                    Code = notificacionComponent.Notification.Code,
                    Created = notificacionComponent.Notification.Created,
                    Read = Convert.ToDateTime(notificacionComponent.Notification.Read),
                    Message = message,
                    ToolTip = message,
                    Tag = item.Tag,
                    Link = notificacionComponent.Notification.Link,
                    UserProfileList = userProfileJson
                });

            }

            if (return_.Count > 0)
            {

                var auxList = return_.OrderByDescending(x => x.Created).ToList();
                if (return_.Count() > max)
                    auxReturn_ = auxList.GetRange(0, max);
                else
                    auxReturn_ = auxList;

            }


            return JsonConvert.SerializeObject(auxReturn_);

        }


        // Dummy method to get notifications
        [DnnAuthorize]
        [HttpGet]
        public string GetNotificationList(int max, string filter, string language = "en-US")
        {
            List<NotificationJson> return_ = new List<NotificationJson>();
            if (language == null || language == "null")
                language = "en-US";

            CultureInfo lang = new CultureInfo(language);
            ResourceManager Localization = new ResourceManager("NexsoServices.App_LocalResources.Resource", Assembly.GetExecutingAssembly());

            var currentUser = UserController.GetCurrentUserInfo();
            var userID = -1;

            DotNetNuke.Security.Roles.RoleController rc = new DotNetNuke.Security.Roles.RoleController();
            var ListUsers = rc.GetUsersByRoleName(0, "Registered Users");

            var message = Localization.GetString("LikeNotification", lang);
            var type = "LIKE";

            for (int i = 0; i < max; i++)
            {

                List<UserProfileJson> userProfileJson = new List<UserProfileJson>();
                Random random = new Random();
                for (int k = 0; k < 4; k++)
                {
                    try
                    {

                        UserInfo objUser = (UserInfo)ListUsers[random.Next(ListUsers.Count)];

                        if (k == 0)
                            userID = currentUser.UserID;
                        else
                            userID = objUser.UserID;

                        UserPropertyComponent userPropertyComponent = new UserPropertyComponent(userID);

                        userProfileJson.Add(new UserProfileJson()
                        {
                            UserId = userPropertyComponent.UserProperty.UserId,
                            NexsoUserId = userPropertyComponent.UserProperty.NexsoUserId == null ? Guid.Empty : (Guid)userPropertyComponent.UserProperty.NexsoUserId,
                            Agreement = userPropertyComponent.UserProperty.Agreement,
                            SkypeName = userPropertyComponent.UserProperty.SkypeName,
                            Twitter = userPropertyComponent.UserProperty.Twitter,
                            FaceBook = userPropertyComponent.UserProperty.FaceBook,
                            Google = userPropertyComponent.UserProperty.Google,
                            LinkedIn = userPropertyComponent.UserProperty.LinkedIn,
                            OtherSocialNetwork = userPropertyComponent.UserProperty.OtherSocialNetwork,
                            City = userPropertyComponent.UserProperty.City,
                            Region = userPropertyComponent.UserProperty.Region,
                            Country = userPropertyComponent.UserProperty.Country,
                            PostalCode = userPropertyComponent.UserProperty.PostalCode,
                            Telephone = userPropertyComponent.UserProperty.Telephone,
                            Address = userPropertyComponent.UserProperty.Address,
                            FirstName = userPropertyComponent.UserProperty.FirstName,
                            LastName = userPropertyComponent.UserProperty.LastName,
                            email = userPropertyComponent.UserProperty.email,
                            CustomerType = Convert.ToInt32(userPropertyComponent.UserProperty.CustomerType),
                            NexsoEnrolment = Convert.ToInt32(userPropertyComponent.UserProperty.NexsoEnrolment),
                            AllowNexsoNotifications = Convert.ToInt32(userPropertyComponent.UserProperty.AllowNexsoNotifications),
                            Language = Convert.ToInt32(userPropertyComponent.UserProperty.Language),
                            Latitude = Convert.ToDecimal(userPropertyComponent.UserProperty.Latitude),
                            Longitude = Convert.ToDecimal(userPropertyComponent.UserProperty.Longitude),
                            GoogleLocation = userPropertyComponent.UserProperty.GoogleLocation
                        });
                    }
                    catch { }
                }

                if (i > 1)
                {
                    message = Localization.GetString("MessageNotification", lang);
                    type = "MESSAGE";
                }


                return_.Add(new NotificationJson()
                {
                    NotificationId = Guid.NewGuid(),
                    Type = type,
                    Created = DateTime.Now,
                    Read = DateTime.MinValue,
                    Message = string.Format(message, i),
                    ToolTip = string.Format(message, i),
                    Tag = "",
                    Link = "http://www.nexso.org/en-us/",
                    UserProfileList = userProfileJson

                });


            }
            return JsonConvert.SerializeObject(return_);
        }

        [AllowAnonymous]
        [HttpGet]
        public string GetUserList(int rows, int page)
        {

            var currentUser = UserController.GetCurrentUserInfo();

            if (currentUser.IsInRole("Registered Users"))
            {
                List<UserProfileJson> listUserProfileJson = new List<UserProfileJson>();
                MIFNEXSOEntities mifNexsoEntities = new MIFNEXSOEntities();
                ObjectResult<spGetUsersProperties_Result> result = null;

                result = mifNexsoEntities.spGetUsersProperties(rows, page);



                foreach (var item in result)
                {
                    listUserProfileJson.Add(new UserProfileJson()
                    {
                        UserId = item.UUserId,
                        LastName = item.ULastName,
                        FirstName = item.UFirstName,
                        email = item.UEmail


                    });
                }
                return JsonConvert.SerializeObject(listUserProfileJson);
            }
            return null;

        }


        [DnnAuthorize]
        [HttpGet]
        public HttpResponseMessage ReadAllNotifications()
        {
            try
            {
                var currentUser = UserController.GetCurrentUserInfo();

                if (!currentUser.IsInRole("Registered Users"))
                    return Request.CreateResponse(HttpStatusCode.Unauthorized, "Unauthorized");

                var listNotification = UserNotificationConnectionComponent.GetUserNotificationConnections(currentUser.UserID);
                var read = DateTime.Now;
                foreach (var item in listNotification)
                {
                    NotificationComponent notificationComponent = new NotificationComponent(item.NotificationId);
                    notificationComponent.Notification.Read = read;
                    notificationComponent.Save();
                }
                return Request.CreateResponse(HttpStatusCode.OK, "OK");
            }
            catch
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, "InternalServerError");
            }
        }

        [DnnAuthorize]
        [HttpGet]
        public HttpResponseMessage ReadNotification(string notificationId)
        {
            try
            {
                var currentUser = UserController.GetCurrentUserInfo();

                if (!currentUser.IsInRole("Registered Users"))
                    return Request.CreateResponse(HttpStatusCode.Unauthorized, "Unauthorized");

                NotificationComponent notificationComponent = new NotificationComponent(new Guid(notificationId));
                notificationComponent.Notification.Read = DateTime.Now;
                notificationComponent.Save();

                return Request.CreateResponse(HttpStatusCode.OK, "OK");
            }
            catch
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, "InternalServerError");
            }
        }

        //get beneficiaries list

        //get theme list

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

        [AllowAnonymous]
        [HttpGet]
        public string GetOrganizationHeaderImage(Guid orgnizationId)
        {

            try
            {
                if (File.Exists(
                     HttpContext.Current.Server.MapPath(PortalSettings.HomeDirectory + "OrgImages/HeaderImages/cropThumb" +
                                      orgnizationId.ToString() +
                                       ".jpg")))
                {
                    return PortalSettings.HomeDirectory + "OrgImages/HeaderImages/" + orgnizationId.ToString() + ".jpg";
                }
                else if (
                   File.Exists(
                    HttpContext.Current.Server.MapPath(PortalSettings.HomeDirectory + "OrgImages/HeaderImages/cropThumb" +
                                     orgnizationId.ToString() +
                                      ".png")))
                {
                    return PortalSettings.HomeDirectory + "OrgImages/HeaderImages/" + orgnizationId.ToString() + ".png";
                }
                else
                {
                    return (PortalSettings.HomeDirectory + "OrgImages/HeaderImages/noHeader.png").ToString();
                }
            }
            catch
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, "InternalServerError").ToString();
            }
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

        [DnnAuthorize]
        [HttpGet]
        public HttpResponseMessage CommentSolution(string txtComment, string scope, string solutionId)
        {

            try
            {

                var portal = PortalController.GetCurrentPortalSettings();
                var currentUser = UserController.GetCurrentUserInfo();

                if (currentUser.IsInRole("Registered Users"))
                {
                    ResourceManager Localization = new ResourceManager("NexsoServices.App_LocalResources.Resource",
                                  Assembly.GetExecutingAssembly());


                    var solution = new SolutionComponent(new Guid(solutionId));

                    if (!string.IsNullOrEmpty(txtComment) && currentUser.UserID > 0)
                    {

                        SolutionCommentComponent solutionCommentComponent = new SolutionCommentComponent(Guid.Empty);
                        solutionCommentComponent.SolutionComment.Comment = txtComment;
                        solutionCommentComponent.SolutionComment.CreatedDate = DateTime.Now;
                        solutionCommentComponent.SolutionComment.Publish = true;
                        solutionCommentComponent.SolutionComment.Scope = scope;
                        solutionCommentComponent.SolutionComment.SolutionId = solution.Solution.SolutionId;
                        solutionCommentComponent.SolutionComment.UserId = currentUser.UserID;

                        if (solutionCommentComponent.Save() > 0)
                        {

                            // Notification

                            var currentUser2 = UserController.GetUserById(portal.PortalId, Convert.ToInt32(solution.Solution.CreatedUserId));
                            var userCurrent = new UserPropertyComponent(currentUser.UserID);
                            if (currentUser.UserID != Convert.ToInt32(solution.Solution.CreatedUserId))
                            {
                                NotificationComponent notificationComponent = new NotificationComponent(Guid.Empty);
                                notificationComponent.Notification.Code = "MESSAGE";
                                notificationComponent.Notification.Created = DateTime.Now;
                                notificationComponent.Notification.UserId = currentUser.UserID;
                                notificationComponent.Notification.Message = "MESSAGE";
                                notificationComponent.Notification.ToolTip = "MESSAGE";
                                notificationComponent.Notification.Link = NexsoHelper.GetCulturedUrlByTabName("solprofile", 0, GetUserLanguage(Convert.ToInt32(userCurrent.UserProperty.Language))) +
                                                                                     "/sl/" + solutionCommentComponent.SolutionComment.Solution.SolutionId.ToString();
                                notificationComponent.Notification.Tag = string.Empty;

                                notificationComponent.Save();

                                UserNotificationConnectionComponent userNotificationConnectionComponent = new UserNotificationConnectionComponent(Guid.Empty);
                                userNotificationConnectionComponent.UserNotificationConnection.NotificationId = notificationComponent.Notification.NotificationId;
                                userNotificationConnectionComponent.UserNotificationConnection.UserId = Convert.ToInt32(solution.Solution.CreatedUserId);
                                userNotificationConnectionComponent.UserNotificationConnection.Tag = string.Empty;
                                userNotificationConnectionComponent.UserNotificationConnection.Rol = string.Empty;


                                userNotificationConnectionComponent.Save();
                            }
                            //end Notification

                            List<int> userIds = new List<int>();

                            foreach (SolutionComment solutionComment in solutionCommentComponent.SolutionComment.Solution.SolutionComments)
                            {
                                if (!userIds.Contains(solutionComment.UserId.GetValueOrDefault(-1)))
                                    userIds.Add(solutionComment.UserId.GetValueOrDefault(-1));
                            }
                            if (solutionCommentComponent.SolutionComment.Solution.CreatedUserId.GetValueOrDefault(-1) != -1)
                                userIds.Add(solutionCommentComponent.SolutionComment.Solution.CreatedUserId.GetValueOrDefault(-1));

                            if (scope != "JUDGE")
                            {
                                foreach (int userids in userIds)
                                {

                                    UserInfo user = UserController.GetUserById(portal.PortalId, userids);
                                    UserPropertyComponent property = new UserPropertyComponent(userids);
                                    if (currentUser.UserID != user.UserID)
                                    {
                                        CultureInfo language = new CultureInfo(GetUserLanguage(property.UserProperty.Language.GetValueOrDefault(1)));
                                        DotNetNuke.Services.Mail.Mail.SendEmail("nexso@iadb.org",
                                                                                  user.Email,
                                                                                 string.Format(
                                                                                     Localization.GetString("MessageTitleComment", language),
                                                                                     currentUser.FirstName + " " + currentUser.LastName,
                                                                                     solutionCommentComponent.SolutionComment.Solution.Title),
                                                                                     Localization.GetString("MessageBodyComment", language).Replace(
                                                                                     "{COMMENT:Body}", solutionCommentComponent.SolutionComment.Comment).Replace(
                                                                                     "{SOLUTION:Title}", solutionCommentComponent.SolutionComment.Solution.Title).Replace(
                                                                                     "{SOLUTION:PageLink}", NexsoHelper.GetCulturedUrlByTabName("solprofile", 0, language.Name) +
                                                                                     "/sl/" + solutionCommentComponent.SolutionComment.Solution.SolutionId.ToString())
                                                                                     );
                                    }
                                }
                                CultureInfo langua = new CultureInfo("en-US");
                                DotNetNuke.Services.Mail.Mail.SendEmail("nexso@iadb.org",
                                                                              "jairoa@iadb.org,YVESL@iadb.org,wrightgas@gmail.com,patriciab@nexso.org,nexso@iadb.org,MONICAO@iadb.org", "NOTIFICATION: " +
                                                                               string.Format(
                                                                                   Localization.GetString("MessageTitleComment", langua),
                                                                                   currentUser.FirstName + " " + currentUser.LastName, solutionCommentComponent.SolutionComment
                                                                                                            .Solution.Title),
                                                                                Localization.GetString("MessageBodyComment", langua).Replace(
                                                                                     "{COMMENT:Body}", solutionCommentComponent.SolutionComment.Comment).Replace(
                                                                                     "{SOLUTION:Title}", solutionCommentComponent.SolutionComment.Solution.Title).Replace(
                                                                                     "{SOLUTION:PageLink}", NexsoHelper.GetCulturedUrlByTabName("solprofile", 0, langua.Name) +
                                                                                     "/sl/" + solutionCommentComponent.SolutionComment.Solution.SolutionId.ToString())
                                                                                     );

                            }
                            return Request.CreateResponse(HttpStatusCode.OK, "OK");
                        }
                        else
                        {
                            return Request.CreateResponse(HttpStatusCode.InternalServerError, "InternalServerError");

                        }
                    }
                    else
                    {
                        return Request.CreateResponse(HttpStatusCode.InternalServerError, "InternalServerError");
                    }
                }
                return Request.CreateResponse(HttpStatusCode.Unauthorized, "Unauthorized");

            }
            catch
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, "InternalServerError");
            }

        }

        [DnnAuthorize]
        [HttpGet]
        public HttpResponseMessage DeleteComment(string solutionCommentId)
        {
            try
            {

                var portal = PortalController.GetCurrentPortalSettings();
                var currentUser = UserController.GetCurrentUserInfo();

                if (currentUser.IsInRole("Registered Users"))
                {

                    SolutionCommentComponent solutionCommentComponent = new SolutionCommentComponent();
                    solutionCommentComponent = new SolutionCommentComponent(new Guid(solutionCommentId));

                    if (solutionCommentComponent.Delete() > 0)
                    {
                        return Request.CreateResponse(HttpStatusCode.OK, "OK");
                    }
                    else
                    {
                        return Request.CreateResponse(HttpStatusCode.InternalServerError, "InternalServerError");
                    }
                }
                return Request.CreateResponse(HttpStatusCode.Unauthorized, "Unauthorized");
            }
            catch
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, "InternalServerError");
            }


        }

        [AllowAnonymous]
        [HttpGet]
        public List<SolutionCommentsJson> GetComments(string solutionId, string scope = "ALL")
        {
            try
            {

                var portal = PortalController.GetCurrentPortalSettings();
                var currentUser = UserController.GetCurrentUserInfo();

                if (currentUser.IsInRole("Registered Users"))
                {
                    List<SolutionComment> listSolutionComment = SolutionCommentComponent.GetCommentsPerSolution(new Guid(solutionId), scope).OrderByDescending(p => p.CreatedDate).ToList();
                    List<SolutionCommentsJson> solutionCommentsJson = new List<SolutionCommentsJson>();

                    if (scope == "JUDGE")
                    {
                        SolutionComponent solution = new SolutionComponent(new Guid(solutionId));
                        string challenge = "NEXSODEFAULT";
                        if (!string.IsNullOrEmpty(solution.Solution.ChallengeReference))
                            challenge = solution.Solution.ChallengeReference;

                        ChallengeJudgeComponent judge = new ChallengeJudgeComponent(currentUser.UserID, challenge);
                        if (!(currentUser.IsInRole("Administrators") || currentUser.IsInRole("NexsoSupport") || judge.ChallengeJudge.PermisionLevel == "ADMIN" || judge.ChallengeJudge.PermisionLevel == "JUDGE-ADMIN"))
                        {
                            if (listSolutionComment.Count() > 0)
                                listSolutionComment = listSolutionComment.Where(x => x.UserId == currentUser.UserID).ToList();
                        }
                    }
                    foreach (var resultTmp in listSolutionComment)
                    {
                        var user = new UserPropertyComponent(resultTmp.UserId.GetValueOrDefault(-1));
                        solutionCommentsJson.Add(new SolutionCommentsJson()
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
                    return solutionCommentsJson;
                }
                return null;
            }
            catch
            {
                return null;
            }
        }

        [DnnAuthorize]
        [HttpGet]
        public HttpResponseMessage SendMessage(string message, int userIdTo)
        {
            try
            {

                var portal = PortalController.GetCurrentPortalSettings();
                var currentUser = UserController.GetCurrentUserInfo();

                if (currentUser.IsInRole("Registered Users"))
                {

                    ResourceManager Localization = new ResourceManager("NexsoServices.App_LocalResources.Resource",
                                     Assembly.GetExecutingAssembly());




                    var fromUser = new UserPropertyComponent(currentUser.UserID);
                    var toUser = new UserPropertyComponent(userIdTo);

                    if (!string.IsNullOrEmpty(message) && toUser.UserProperty.UserId > 0 && currentUser.UserID > 0)
                    {

                        MessageComponent messageComponent = new MessageComponent(Guid.Empty);
                        messageComponent.Message.Message1 = message;
                        messageComponent.Message.ToUserId = userIdTo;
                        messageComponent.Message.FromUserId = currentUser.UserID;
                        messageComponent.Message.DateCreated = DateTime.Now;


                        if (messageComponent.Save() > 0)
                        {
                            // Notification
                            UserInfo userTo = UserController.GetUserById(portal.PortalId, toUser.UserProperty.UserId);

                            if (UserInfo.UserID != Convert.ToInt32(userTo.UserID))
                            {
                                NotificationComponent notificationComponent = new NotificationComponent();
                                notificationComponent.Notification.Code = "MESSAGE";
                                notificationComponent.Notification.Created = DateTime.Now;
                                notificationComponent.Notification.UserId = UserInfo.UserID;
                                notificationComponent.Notification.Message = "MESSAGE";
                                notificationComponent.Notification.ToolTip = "MESSAGE";
                                notificationComponent.Notification.Link = NexsoHelper.GetCulturedUrlByTabName("MyMessages");
                                notificationComponent.Notification.Tag = string.Empty;
                                notificationComponent.Save();

                                UserNotificationConnectionComponent userNotificationConnectionComponent = new UserNotificationConnectionComponent();
                                userNotificationConnectionComponent.UserNotificationConnection.NotificationId = notificationComponent.Notification.NotificationId;
                                userNotificationConnectionComponent.UserNotificationConnection.UserId = Convert.ToInt32(userTo.UserID);
                                userNotificationConnectionComponent.UserNotificationConnection.Rol = string.Empty;
                                userNotificationConnectionComponent.UserNotificationConnection.Tag = string.Empty;
                                userNotificationConnectionComponent.Save();

                            }
                            //end Notification

                            CultureInfo language = new CultureInfo(GetUserLanguage(toUser.UserProperty.Language.GetValueOrDefault(1)));
                            DotNetNuke.Services.Mail.Mail.SendEmail("nexso@iadb.org",
                                                                      userTo.Email,
                                                                     string.Format(
                                                                         Localization.GetString("MessageTitleMessage", language),
                                                                         currentUser.FirstName + " " + currentUser.LastName
                                                                       ),
                                                                         Localization.GetString("MessageBodyMessage", language).Replace(
                                                                         "{MESSAGE:Body}", messageComponent.Message.Message1).Replace(
                                                                         "{MESSAGE:ViewLink}", NexsoHelper.GetCulturedUrlByTabName("MyMessages", 0, language.Name))

                                                                         );

                            return Request.CreateResponse(HttpStatusCode.OK, "OK");
                        }
                        else
                        {
                            return Request.CreateResponse(HttpStatusCode.InternalServerError, "InternalServerError");

                        }
                    }
                    else
                    {
                        return Request.CreateResponse(HttpStatusCode.InternalServerError, "InternalServerError");
                    }
                }
                return Request.CreateResponse(HttpStatusCode.Unauthorized, "Unauthorized");
            }
            catch
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, "InternalServerError");
            }
        }

        [DnnAuthorize]
        [HttpGet]
        public List<MessageJson> GetMessagesFrom()
        {
            try
            {

                var portal = PortalController.GetCurrentPortalSettings();
                var currentUser = UserController.GetCurrentUserInfo();

                if (currentUser.IsInRole("Registered Users"))
                {

                    List<Message> listMessages = MessageComponent.GetMessagesFrom(currentUser.UserID).OrderByDescending(p => p.DateCreated).ToList();
                    List<MessageJson> messageJson = new List<MessageJson>();

                    foreach (var resultTmp in listMessages)
                    {
                        messageJson.Add(new MessageJson()
                        {
                            MessageId = resultTmp.MessageId,
                            Message = resultTmp.Message1,
                            FromUserId = Convert.ToInt32(resultTmp.FromUserId),
                            ToUserId = Convert.ToInt32(resultTmp.ToUserId),
                            CreatedDate = Convert.ToDateTime(resultTmp.DateCreated),
                            DateRead = Convert.ToDateTime(resultTmp.DateRead)

                        });
                    }
                    return messageJson;
                }
                return null;

            }
            catch
            {
                return null;
            }

        }

        [AllowAnonymous]
        [HttpGet]
        public List<MessageJson> GetMessagesTo(int userIdTo)
        {
            try
            {

                var portal = PortalController.GetCurrentPortalSettings();
                var currentUser = UserController.GetCurrentUserInfo();

                if (currentUser.IsInRole("Registered Users"))
                {
                    List<Message> listMessages = MessageComponent.GetMessagesTo(userIdTo).OrderByDescending(p => p.DateCreated).ToList();
                    List<MessageJson> messagesJson = new List<MessageJson>();

                    foreach (var resultTmp in listMessages)
                    {
                        messagesJson.Add(new MessageJson()
                        {
                            MessageId = resultTmp.MessageId,
                            Message = resultTmp.Message1,
                            FromUserId = Convert.ToInt32(resultTmp.FromUserId),
                            ToUserId = Convert.ToInt32(resultTmp.ToUserId),
                            CreatedDate = Convert.ToDateTime(resultTmp.DateCreated),
                            DateRead = Convert.ToDateTime(resultTmp.DateRead)

                        });
                    }
                    return messagesJson;
                }
                return null;
            }
            catch
            {
                return null;
            }
        }

        private string GetUserLanguage(int lang)
        {
            switch (lang)
            {
                case 1:
                    return "en-US";
                case 2:
                    return "es-ES";
                case 3:
                    return "pt-BR";
                default:
                    return "en-US";
            }
        }
    }



}
