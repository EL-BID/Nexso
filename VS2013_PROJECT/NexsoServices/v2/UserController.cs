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
using Newtonsoft.Json.Linq;
using System.Web.Http.Routing;

namespace NexsoServices.V2
{
    public class UserController : DnnApiController
    {
        /// <summary>
        /// Get user profile 
        /// </summary>
        /// <remarks>
        /// Get a specific user profile by user Id. If user id is null will be return the current logged user profile.
        /// The information returned depends of level of permission.
        /// </remarks>
        /// <param name="userId">UserId. Deafault null</param>
        /// <param name="language">Use for getting localized content. RFC 1766 language convention. Default en-US</param>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="401">Not Authorized operation</response>
        /// <response code="500">Internal ServerError</response>
        [DnnAuthorize]
        [HttpGet]
        public UserProfileModel GetProfile(int? userId = null, string language = "en-US")
        {
            try
            {
                var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
                if (currentUser.IsInRole("Registered Users"))
                {
                    CultureInfo culture = new CultureInfo(language);

                    int userIdValid = userId.GetValueOrDefault(currentUser.UserID);
                    if (userIdValid == -1)
                        return new UserProfileModel();
                    var portal = PortalController.GetCurrentPortalSettings();
                    UserPropertyComponent userPropertyComponent = new UserPropertyComponent(userIdValid);

                    if (currentUser.IsInRole("Administrators") || currentUser.UserID == userIdValid)
                        return Helper.HelperMethods.ParseUserProfile(userPropertyComponent.UserProperty, "Owner", culture);
                    return Helper.HelperMethods.ParseUserProfile(userPropertyComponent.UserProperty, "", culture);
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
        /// Get a list of current users 
        /// </summary>
        ///  /// <remarks>
        /// Get a list of current users in NEXSO. This can be filtered or sorted. Only Registered Users role is allowed.
        /// 
        /// Pagination information in Header, see https://github.com/NEXSO-MIF/documentation/wiki/Web-Api-V2-Reference/// 
        /// </remarks>
        /// <param name="rows">Default 10</param>
        /// <param name="page">Default 0</param>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="401">Not Authorized</response>
        /// <response code="500">Internal ServerError</response>
        [DnnAuthorize]
        [HttpGet]
        public List<UserProfileModel> GetList(int rows = 10, int page = 0)
        {
            try
            {

                var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();

                if (currentUser.IsInRole("Registered Users"))
                {
                 
                    MIFNEXSOEntities mifNexsoEntities = new MIFNEXSOEntities();
                    //   ObjectResult<spGetUsersProperties_Result> result = null;

                    var result = mifNexsoEntities.UserProperties.Where(a=>a.FirstName!=string.Empty).OrderBy(a => a.FirstName);//.spGetUsersProperties(rows, page);

                    var totalCount = result.Count();
                    var totalPages = (int)Math.Ceiling((double)totalCount / rows);

                    var urlHelper = new UrlHelper(Request);
                    var prevLink = page > 0 ? string.Format("/user/getlist?rows={0}&page={1}", rows, page - 1) : "";
                    var nextLink = page < totalPages - 1 ? string.Format("/user/getlist?rows={0}&page={1}", rows, page + 1) : "";


                    var listUserProfileModel=Helper.HelperMethods.ParseUserProfile(result.Skip(rows * page).Take(rows).ToList());
                   


                    var paginationHeader = new
                    {
                        TotalCount = totalCount,
                        TotalPages = totalPages,
                        PrevPageLink = prevLink,
                        NextPageLink = nextLink
                    };

                    System.Web.HttpContext.Current.Response.Headers.Add("X-Pagination",
                    Newtonsoft.Json.JsonConvert.SerializeObject(paginationHeader));

                    return listUserProfileModel;
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
        /// Upload an user picture
        /// </summary>
        /// <remarks>
        /// Upload an user  image in temporal repository. Only available for Registered Users. 
        /// Require CropSaveBanner or CropSaveProfile to complete publishing operation.
        /// 
        /// Note: the file have to be upload via form-data. Include userId as well as integer value. 
        /// </remarks>
        /// <returns>FileResult structure</returns>
        /// <response code="200">OK</response>
        /// <response code="401">Unauthorized if authenticated user is not Registered Users or Administrator</response>
        /// <response code="500">Internal ServerError</response>
        [DnnAuthorize]
        [HttpPost]
        [ValidateMimeMultipartContentFilter]
        public async Task<FileResultModel> UploadUserImage( )
        {
            try
            {
               
                var portal = PortalController.GetCurrentPortalSettings();
                var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
                var tempId = Helper.HelperMethods.GenerateHash(currentUser.UserID).ToString();
                if (currentUser.IsInRole("Registered Users"))
                {
                    string ServerUploadFolder = portal.HomeDirectoryMapPath + "ModIma\\TempUserImages";
                    var streamProvider = new MultipartFormDataStreamProvider(ServerUploadFolder);
                    string ImageProcessingFolfer = "";
                    await Request.Content.ReadAsMultipartAsync(streamProvider);
                    string userId = streamProvider.FormData["userId"];
                    var user = new UserPropertyComponent(Convert.ToInt32(userId));
                    if (currentUser.IsInRole("Administrators") || user.UserProperty.UserId == currentUser.UserID)
                    {
                        Helper.HelperMethods.DeleteFiles(portal.HomeDirectoryMapPath + "ModIma\\TempUserImages", tempId+"*");
                        var file = streamProvider.FileData.First();
                        string originalFileName = file.Headers.ContentDisposition.FileName.Replace("\"", "");
                        string originalExtension = Path.GetExtension(originalFileName);
                        FileInfo fi = new FileInfo(file.LocalFileName);
                        ImageProcessingFolfer = Path.Combine(portal.HomeDirectoryMapPath + "ModIma\\TempUserImages", tempId  + originalExtension);
                        var size = fi.Length;
                        fi.CopyTo(ImageProcessingFolfer, true);
                        fi.Delete();
                        return new FileResultModel()
                        {
                          
                             
                                  Extension=originalExtension,
                                  Filename=tempId,
                                  Size=size,
                                  Link="/ModIma/TempUserImages/"+tempId  + originalExtension

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
        /// Crop and Save a temporal User Banner picture
        /// </summary>
        /// <remarks>
        ///  This method takes an uploaded image into the temporal file repository using UploadUserImage method and applies the reposition value and crop it.
        ///  Final image Height=575, Width=1148. Including original and thumbnail version. The file will be stored in PNG format.
        /// </remarks>
        /// <param name="userId">Use user Id</param>
        /// <param name="body">Use yCrop and Filename</param>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="401">Unauthorized if authenticated user is not Registered Users or Administrator</response>
        /// <response code="500">Internal ServerError</response>
        [DnnAuthorize]
        [HttpPut]
        public List<FileResultModel> CropSaveBanner([FromBody] CropImage body)
        {
            try
            {

                var filename = body.Filename;
                var yCropPosition = body.yCrop;
                var portal = PortalController.GetCurrentPortalSettings();
                var user = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
                var userProperty = new UserPropertyComponent(user.UserID);
                if (user.IsInRole("Registered Users"))
                {
                    if (userProperty.UserProperty.BannerPicture.GetValueOrDefault(Guid.Empty) == Guid.Empty)
                    {

                        userProperty.UserProperty.BannerPicture = Guid.NewGuid();
                        if (userProperty.Save() <= 0)
                            throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.InternalServerError));
                    }

                    var fileResultModelList = new List<FileResultModel>();
                    yCropPosition = yCropPosition * -1;
                    string extension =".png";//=Path.GetExtension(filename);
                    string fileRootName = userProperty.UserProperty.BannerPicture.ToString();
                    MemoryStream outStream = new MemoryStream();
                    long tmpSize = 0;
                    string ImageProcessingFolfer = Path.Combine(portal.HomeDirectoryMapPath + "ModIma\\TempUserImages", filename);
                    
                    ImageFactory imageFactory = new ImageFactory(preserveExifData: true);
                    imageFactory.Load(ImageProcessingFolfer);
                    imageFactory.Save(outStream);// ();
                    tmpSize = outStream.Length;
                    Helper.HelperMethods.SaveImage(ref outStream, Path.Combine(portal.HomeDirectoryMapPath + "ModIma\\UserHeaderImages", fileRootName + extension));
                    fileResultModelList.Add(new FileResultModel()
                    {
                        Extension = extension,
                        Filename = fileRootName,
                        Link = portal.HomeDirectory + "ModIma/UserHeaderImages/" + fileRootName + extension,
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
                    imageFactory.Resize(sizeBig);
                    outStream = new MemoryStream();
                    imageFactory.Save(outStream);
                    tmpSize = outStream.Length;
                    Helper.HelperMethods.SaveImage(ref outStream, Path.Combine(portal.HomeDirectoryMapPath + "ModIma\\UserHeaderImages", "cropBig" + fileRootName + extension));
                    fileResultModelList.Add(new FileResultModel()
                    {
                        Extension = extension,
                        Filename = "cropBig" + fileRootName,
                        Link = portal.HomeDirectory + "ModIma/UserHeaderImages/" + "cropBig" + fileRootName + extension,
                        Description = "Crop Big",
                        Size = tmpSize
                    });
                    System.Drawing.Size sizeSmall = new System.Drawing.Size(Convert.ToInt32(600), Convert.ToInt32(300));
                    imageFactory.Resize(sizeSmall);
                    outStream = new MemoryStream();
                    imageFactory.Save(outStream);
                    tmpSize = outStream.Length;
                    Helper.HelperMethods.SaveImage(ref outStream, Path.Combine(portal.HomeDirectoryMapPath + "ModIma\\UserHeaderImages", "cropThumb" + fileRootName + extension));
                    fileResultModelList.Add(new FileResultModel()
                    {
                        Extension = extension,
                        Filename = "cropThumb" + fileRootName,
                        Link = portal.HomeDirectory + "ModIma/UserHeaderImages/" + "cropThumb" + fileRootName + extension,
                        Description = "Crop Thumbnail",
                        Size = tmpSize


                    });
                    Helper.HelperMethods.DeleteFiles(portal.HomeDirectoryMapPath + "ModIma\\TempUserImages", filename);
                    return fileResultModelList;

                }
                else
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
        /// Crop and Save an existing User Profile picture 
        /// </summary>
        /// <remarks>
        ///  This method takes an uploaded image into the temporal file repository using UploadUserImage method and applies the reposition value and crop it.
        ///  Final image Height=512, Width=512. Including original and thumbnail version. The file will be stored in PNG format.
        /// </remarks>
        /// <param name="body">For this method Use yCrop and Filename</param>
        /// <returns></returns>
        /// <response code="200">OK</response>
        /// <response code="401">Unauthorized if authenticated user is not Registered Users or Administrator</response>
        /// <response code="500">Internal ServerError</response>
        [DnnAuthorize]
        [HttpPut]
        public List<FileResultModel> CropSaveProfile([FromBody] CropImage body)
        {

            try
            {

                var filename = body.Filename;
                var yCropPosition = body.yCrop;
                var portal = PortalController.GetCurrentPortalSettings();
                var user = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
                var userProperty = new UserPropertyComponent(user.UserID);
                if (user.IsInRole("Registered Users"))
                {
                    if (userProperty.UserProperty.ProfilePicture.GetValueOrDefault(Guid.Empty) == Guid.Empty)
                    {
                        userProperty.UserProperty.ProfilePicture = Guid.NewGuid();
                        if (userProperty.Save() <= 0)
                            throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.InternalServerError));
                    }

                    var fileResultModelList = new List<FileResultModel>();
                    yCropPosition = yCropPosition * -1;
                    string extension  =".png";//Path.GetExtension(filename);
                    string fileRootName = userProperty.UserProperty.ProfilePicture.ToString();
                    MemoryStream outStream = new MemoryStream();
                    long tmpSize = 0;
                    string ImageProcessingFolfer = Path.Combine(portal.HomeDirectoryMapPath + "ModIma\\TempUserImages", filename);
                  
                    ImageFactory imageFactory = new ImageFactory(preserveExifData: true);
                    imageFactory.Load(ImageProcessingFolfer);
                    imageFactory.Save(outStream);// ();
                    tmpSize = outStream.Length;
                    Helper.HelperMethods.SaveImage(ref outStream, Path.Combine(portal.HomeDirectoryMapPath + "ModIma\\UserProfileImages", fileRootName + extension));
                    fileResultModelList.Add(new FileResultModel()
                    {
                        Extension = extension,
                        Filename = fileRootName,
                        Link = portal.HomeDirectory + "ModIma/UserProfileImages/" + fileRootName + extension,
                        Description = "Original Image",
                        Size = tmpSize
                    });
                    var image = imageFactory.Image;
                    var originalHeight = image.Size.Height;
                    var originalWidth = image.Size.Width;
                    float referenceHeight = 512;
                    float referenceWidth = 512;
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
                    outStream = new MemoryStream();
                    imageFactory.Save(outStream);
                    tmpSize = outStream.Length;
                    Helper.HelperMethods.SaveImage(ref outStream, Path.Combine(portal.HomeDirectoryMapPath + "ModIma\\UserProfileImages", "cropBig" + fileRootName + extension));
                    fileResultModelList.Add(new FileResultModel()
                    {
                        Extension = extension,
                        Filename = "cropBig" + fileRootName,
                        Link = portal.HomeDirectory + "ModIma/UserProfileImages/" + "cropBig" + fileRootName + extension,
                        Description = "Crop Big",
                        Size = tmpSize
                    });
                    System.Drawing.Size sizeSmall = new System.Drawing.Size(Convert.ToInt32(300), Convert.ToInt32(300));
                    imageFactory.Resize(sizeSmall);
                    outStream = new MemoryStream();
                    imageFactory.Save(outStream);
                    tmpSize = outStream.Length;
                    Helper.HelperMethods.SaveImage(ref outStream, Path.Combine(portal.HomeDirectoryMapPath + "ModIma\\UserProfileImages", "cropThumb" + fileRootName + extension));
                    fileResultModelList.Add(new FileResultModel()
                    {
                        Extension = extension,
                        Filename = "cropThumb" + fileRootName,
                        Link = portal.HomeDirectory + "ModIma/UserProfileImages/" + "cropThumb" + fileRootName + extension,
                        Description = "Crop Thumbnail",
                        Size = tmpSize


                    });
                    Helper.HelperMethods.DeleteFiles(portal.HomeDirectoryMapPath + "ModIma\\TempUserImages", filename);
                    return fileResultModelList;

                }
                else
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
        /// Remove an user profile image
        /// </summary>
        /// <remarks>
        /// Delete an user profile image form DB and file system. 
        /// </remarks>
        /// <returns></returns>
        /// <response code="202">Successful Delete</response>
        /// <response code="401">Unauthorized if user is not authenticated</response>
        /// <response code="500">Internal ServerError</response>
        [DnnAuthorize]
        [HttpDelete]
        public HttpResponseMessage RemoveProfileImage()
        {
            try
            {
                var portal = PortalController.GetCurrentPortalSettings();
                var user = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
                var userProperty = new UserPropertyComponent(user.UserID);
                if (userProperty.UserProperty.ProfilePicture != null)
                {
                    Helper.HelperMethods.DeleteFiles(portal.HomeDirectoryMapPath + "ModIma\\UserProfileImages", "*" + userProperty.UserProperty.ProfilePicture.ToString() + ".png");

                    userProperty.UserProperty.ProfilePicture = null;
                    if (userProperty.Save() > 0)
                        return Request.CreateResponse(HttpStatusCode.Accepted, "Successful Delete");
                    throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.InternalServerError));
                }
                return Request.CreateResponse(HttpStatusCode.NotModified, "Nothing to Delete");
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
        /// Remove an user banner image
        /// </summary>
        /// <remarks>
        /// Delete an user banner image form DB and file system.
        /// </remarks>
        /// <returns></returns>
        /// <response code="202">Successful Delete</response>
        /// <response code="401">Unauthorized if user is not authenticated</response>
        /// <response code="500">Internal ServerError</response>
        [DnnAuthorize]
        [HttpDelete]
        public HttpResponseMessage RemoveBannerImage()
        {
            try
            {
                var portal = PortalController.GetCurrentPortalSettings();
                var user = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
                var userProperty = new UserPropertyComponent(user.UserID);
                if (userProperty.UserProperty.BannerPicture != null)
                {
                    Helper.HelperMethods.DeleteFiles(portal.HomeDirectoryMapPath + "ModIma\\UserHeaderImages", "*"+userProperty.UserProperty.BannerPicture.ToString()+".png");

                    userProperty.UserProperty.BannerPicture = null;
                    if (userProperty.Save() > 0)
                        return Request.CreateResponse(HttpStatusCode.Accepted, "Successful Delete");
                    throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.InternalServerError));
                   
                        
                }
                return Request.CreateResponse(HttpStatusCode.NotModified, "Nothing to Delete");
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
