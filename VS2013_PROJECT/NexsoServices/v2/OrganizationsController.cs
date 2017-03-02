using DotNetNuke.Entities.Portals;
using DotNetNuke.Web.Api;
using ImageProcessor;
using NexsoProBLL;
using NexsoProDAL;
using NexsoServices.V2;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;

namespace NexsoServices.v2
{
    /// <summary>
    /// Controller for general Lists
    /// </summary>
    public class OrganizationsController : DnnApiController
    {
        [AllowAnonymous]
        [HttpGet]
        public List<OrganizationsModel> GetOrganization(Guid organization, int ? userId= -1, string language = "en-US")
        {
            try
            {
                var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
  
                //lists
                List<OrganizationsModel> ListOrganization = new List<OrganizationsModel>();

                List<string> ListLogo = new List<string>();

                List<ReferencesModel> ListReference = new List<ReferencesModel>();

                List<AccreditationsModel> ListAccreditation = new List<AccreditationsModel>();

                List<AttributesModel> ListAttributes = new List<AttributesModel>();

                List<UserProfileModel> ListuserInfo = new List<UserProfileModel>();

                //get attributes
                var attributes = AttributesComponent.GetAttributesList(organization).ToList();

                foreach (var item in attributes)
                {
                    ListAttributes.Add(new AttributesModel()
                    {
                           AttributeID = item.AttributeID,
                           OrganizationID = item.OrganizationID,
                           Type = item.Type,
                           Value = item.Value,
                           ValueType = item.ValueType,
                           Description = item.Description,
                           Label = item.Label
                    });
                }

                //get number of solution
                var solutionsNumber = SolutionComponent.GetSolutionPerOrganization(organization).ToList().Count();

                //get partners
                var partnersLogo = PartnershipsComponent.GetPartnershipListLogo(organization).ToList();

                //get organizations by Id
                var List = OrganizationComponent.GetOrganizationPerId(organization).ToList();

                //get organization references by Id
                var resultReferences = ReferencesComponent.GetReferences(organization).ToList();

                //get user info
                var users = List.First().UserOrganizations.Where(a => a.Role == 1);

                //know if current user is owner
                bool owner = false;
                if (currentUser.UserID == users.First().UserID || currentUser.IsInRole("Administrators") || currentUser.IsSuperUser)
                    owner = true;


                var userProfile = new UserPropertyComponent(users.First().UserID);
               
               // UserProfileModel userProfile = user.GetProfile(Convert.ToInt32(List.First().CreatedBy));
                
                string finalExt = "";
                if (System.IO.File.Exists(System.Web.HttpContext.Current.Server.MapPath("~\\Portals\\0\\ModIma\\UserProfileImages\\" + userProfile.UserProperty.ProfilePicture + ".png"))){
                    finalExt = "\\Portals\\0\\ModIma\\UserProfileImages\\" + userProfile.UserProperty.ProfilePicture + ".png";
                }
                else if (System.IO.File.Exists(System.Web.HttpContext.Current.Server.MapPath("~\\Portals\\0\\ModIma\\UserProfileImages\\" + userProfile.UserProperty.ProfilePicture + ".jpg")))
                {
                    finalExt = "\\Portals\\0\\ModIma\\UserProfileImages\\" + userProfile.UserProperty.ProfilePicture + ".jpg";
                }
                else
                {
                    finalExt = "\\Portals\\0\\ModIma\\UserProfileImages\\defaultImage.png";
                }


                if (resultReferences.Count() > 0)
                {
                    foreach (var item in resultReferences)
                    {
                        var userProfileReferences = new UserPropertyComponent(item.UserId);
                        
                        ListReference.Add(new ReferencesModel()
                        {
                            ReferenceId = (Guid)item.ReferenceId,
                            OrganizationId = (Guid)item.OrganizationId,
                            UserId = item.UserId,
                            Type = item.Type,
                            Comment = item.Comment,
                            Created = item.Created.ToString(),
                            Updated = item.Updated.ToString(),
                            Deleted = item.Deleted,
                            fullName = userProfileReferences.UserProperty.FirstName + " " + userProfileReferences.UserProperty.LastName
                        });
                    }
                }

                //Get organization accreditations
                var resultAccreditations = AccreditationsComponent.GetAccreditationId(organization).ToList();

                if (resultAccreditations.Count() > 0)
                {
                    foreach (var item in resultAccreditations)
                    {
                        DocumentComponent doc = new DocumentComponent((Guid)item.DocumentId);

                        ListAccreditation.Add(new AccreditationsModel()
                        {
                            AccreditationId = (Guid)item.AccreditationId,
                            OrganizationId = (Guid)item.OrganizationId,
                            Content = item.Content,
                            Description = item.Description,
                            DocumentId = (Guid)item.DocumentId,
                            Name = item.Name,
                            Type = item.Type,
                            yearAccreditation = item.Year,
                            docName = doc.Document.Name,
                            docUrl = ""
                        });
                    }
                }

                foreach (var item in List)
                {
                    ListOrganization.Add(new OrganizationsModel()
                    {
                        OrganizationID = (Guid)item.OrganizationID,
                        Code = item.Code,
                        Name = item.Name,
                        //Address = currentUser.IsInRole("NexsoUser") ? item.Address : "",
                        Address = item.Address,
                        //Phone = currentUser.IsInRole("NexsoUser") ? item.Phone  : "",
                        Phone = item.Phone,
                        //Email = currentUser.IsInRole("NexsoUser") ? item.Email : "",
                        Email = item.Email,
                        //ContactEmail = currentUser.IsInRole("NexsoUser") ? item.ContactEmail : "",
                        ContactEmail = item.ContactEmail,
                        Website = item.Website,
                        Twitter = item.Twitter,
                        //Skype = currentUser.IsInRole("NexsoUser") ? item.Skype : "",
                        Skype = item.Skype,
                        //Facebook = currentUser.IsInRole("NexsoUser") ? item.Facebook : "",
                        Facebook = item.Facebook,
                        GooglePlus = item.GooglePlus,
                        LinkedIn = item.LinkedIn,
                        Description = item.Description,
                        Logo = item.Logo,
                        Country = item.Country,
                        Region = item.Region,
                        City = item.City,
                        ZipCode = item.ZipCode,
                        Created = Convert.ToDateTime(item.Created),
                        Updated = Convert.ToDateTime(item.Updated),
                        Latitude = Convert.ToDecimal(item.Latitude),
                        Longitude = Convert.ToDecimal(item.Longitude),
                        GoogleLocation = item.GoogleLocation,
                        Language = item.Language,
                        Year = Convert.ToInt32(item.Year),
                        Staff = Convert.ToInt32(item.Staff),
                        Budget = Convert.ToDecimal(item.Budget),
                        CheckedBy = item.CheckedBy,
                        CreatedOn = Convert.ToDateTime(item.Created),
                        UpdatedOn = Convert.ToDateTime(item.Updated),
                        CreatedBy = Convert.ToInt32(item.CreatedBy),
                        Deleted = Convert.ToBoolean(item.Deleted),
                        accreditations = ListAccreditation,
                        references = ListReference,
                        solutionNumber = Convert.ToInt32(solutionsNumber),
                        partnershipsLogo = partnersLogo,
                        attributes = ListAttributes,
                        userFirstName = userProfile.UserProperty.FirstName,
                        userLastName = userProfile.UserProperty.LastName,
                        userEmail = userProfile.UserProperty.email,
                        userLinkedIn = userProfile.UserProperty.LinkedIn,
                        userFacebook = userProfile.UserProperty.FaceBook,
                        userTwitter = userProfile.UserProperty.Twitter,
                        userAddress = userProfile.UserProperty.Address,
                        userCity = userProfile.UserProperty.City,
                        userCountry = userProfile.UserProperty.Country,                        
                        userProfilePicture = finalExt,
                        userID = currentUser.UserID.ToString(),
                        ownerSolution = owner


                    });
                }
                return ListOrganization;
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
        //get organization list
        public List<OrganizationsModel> GetList(int ? userId = -1, int rows = 10, int page = 0, int min = 0, int max = 0, int state = 1000, string language = "en-US")
        {
            try
            {
                var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();

               //lists
                List<OrganizationsModel> ListOrganization = new List<OrganizationsModel>();

                List<ReferencesModel> ListReference = new List<ReferencesModel>();

                List<AccreditationsModel> ListAccreditation = new List<AccreditationsModel>();

                //Get all Organizations
                var result = OrganizationComponent.GetOrganizations().OrderBy(x => x.Name);

                var totalCount = result.Count();
                var totalPages = (int)Math.Ceiling((double)totalCount / rows);

                var prevLink = page > 0 ? string.Format("/Organizations/GetList?rows={0}&page={1}", rows, page - 1) : "";
                var nextLink = page < totalPages - 1 ? string.Format("/Organizations/GetList?rows={0}&page={1}", rows, page + 1) : "";

                foreach (var resultTmp in result.Skip(rows * page).Take(rows).ToList())
                {
                    List<Organization> organizationList = OrganizationComponent.GetOrganizationPerId(resultTmp.OrganizationID);

                    //Get Organization references by Id
                    var resultReferences = ReferencesComponent.GetReferences(resultTmp.OrganizationID).ToList();

                    if (resultReferences.Count() > 0)
                    {
                        foreach (var item in resultReferences)
                        {
                            ListReference.Add(new ReferencesModel()
                            {
                                ReferenceId = (Guid)item.ReferenceId,
                                OrganizationId = (Guid)item.OrganizationId,
                                UserId = item.UserId,
                                Type = item.Type,
                                Comment = item.Comment,
                                Created = item.Created.ToString(),
                                Updated = item.Updated.ToString(),
                                Deleted = item.Deleted
                            });
                        }
                    }

                    //Get Organization Accreditations
                    var resultAccreditations = AccreditationsComponent.GetAccreditationId(resultTmp.OrganizationID).ToList();

                    if (resultAccreditations.Count() > 0)
                    {
                        foreach (var item in resultAccreditations)
                        {
                            ListAccreditation.Add(new AccreditationsModel()
                            {
                                AccreditationId = (Guid)item.AccreditationId,
                                OrganizationId = (Guid)item.OrganizationId,
                                Content = item.Content,
                                Description = item.Description,
                                DocumentId = (Guid)item.DocumentId,
                                Name = item.Name,
                                Type = item.Type
                            });
                        }
                    }
                    
                    foreach (var item in organizationList)
                    {
                        ListOrganization.Add(new OrganizationsModel()
                        {
                            OrganizationID = (Guid)item.OrganizationID,
                            Code = item.Code,
                            Name = item.Name,
                            //Address = currentUser.IsInRole("NexsoUser") ? item.Address : "",
                            Address = item.Address,
                            //Phone = currentUser.IsInRole("NexsoUser") ? item.Phone  : "",
                            Phone = item.Phone,
                            //Email = currentUser.IsInRole("NexsoUser") ? item.Email : "",
                            Email = item.Email,
                            //ContactEmail = currentUser.IsInRole("NexsoUser") ? item.ContactEmail : "",
                            ContactEmail = item.ContactEmail,
                            Website = item.Website,
                            Twitter = item.Twitter,
                            //Skype = currentUser.IsInRole("NexsoUser") ? item.Skype : "",
                            Skype = item.Skype,
                            //Facebook = currentUser.IsInRole("NexsoUser") ? item.Facebook : "",
                            Facebook = item.Facebook,
                            GooglePlus = item.GooglePlus,
                            LinkedIn = item.LinkedIn,
                            Description = item.Description,
                            Logo = item.Logo,
                            Country = item.Country,
                            Region = item.Region,
                            City = item.City,
                            ZipCode = item.ZipCode,
                            Created = Convert.ToDateTime(item.Created),
                            Updated = Convert.ToDateTime(item.Updated),
                            Latitude = Convert.ToDecimal(item.Latitude),
                            Longitude = Convert.ToDecimal(item.Longitude),
                            GoogleLocation = item.GoogleLocation,
                            Language = item.Language,
                            Year = Convert.ToInt32(item.Year),
                            Staff = Convert.ToInt32(item.Staff),
                            Budget = Convert.ToDecimal(item.Budget),
                            CheckedBy = item.CheckedBy,
                            CreatedOn = Convert.ToDateTime(item.Created),
                            UpdatedOn = Convert.ToDateTime(item.Updated),
                            CreatedBy = Convert.ToInt32(item.CreatedBy),
                            Deleted = Convert.ToBoolean(item.Deleted),
                            accreditations = ListAccreditation,
                            references = ListReference
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

                return ListOrganization;
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
                    string ServerUploadFolder = portal.HomeDirectoryMapPath + "OrgImages\\TempImages";
                    var streamProvider = new MultipartFormDataStreamProvider(ServerUploadFolder);
                    string ImageProcessingFolfer = "";
                    await Request.Content.ReadAsMultipartAsync(streamProvider);
                    string organizationId = streamProvider.FormData["organizationId"];
                    var organization = new OrganizationComponent(new Guid(organizationId));

                    if (currentUser.IsInRole("Administrators") || organization.Organization.CreatedBy == currentUser.UserID)
                    {
                        Helper.HelperMethods.DeleteFiles(portal.HomeDirectoryMapPath + "OrgImages\\TempImages", tempId + "*");
                        var file = streamProvider.FileData.First();
                        string originalFileName = file.Headers.ContentDisposition.FileName.Replace("\"", "");
                        string originalExtension = Path.GetExtension(originalFileName);
                        FileInfo fi = new FileInfo(file.LocalFileName);
                        ImageProcessingFolfer = Path.Combine(portal.HomeDirectoryMapPath + "OrgImages\\TempImages", tempId + originalExtension);
                        var size = fi.Length;
                        fi.CopyTo(ImageProcessingFolfer, true);
                        fi.Delete();
                        return new FileResultModel()
                        {
                            Extension = originalExtension,
                            Filename = tempId,
                            Size = size,
                            Link = "/OrgImages/TempImages/" + tempId + originalExtension

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
        public List<FileResultModel> CropSaveBanner([FromUri]Guid organizationId, [FromBody] CropImage body)
        {
            try
            {
                var filename = body.Filename;
                var yCropPosition = body.yCrop;
                var organization = new OrganizationComponent(organizationId);
                var portal = PortalController.GetCurrentPortalSettings();
                var currentUser = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
                var tempId = Helper.HelperMethods.GenerateHash(currentUser.UserID).ToString();
                if (currentUser.IsInRole("Registered Users"))
                {

                    if (currentUser.IsInRole("Administrators") || organization.Organization.CreatedBy == DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo().UserID)
                    {
                        var fileResultModelList = new List<FileResultModel>();
                        yCropPosition = yCropPosition * -1;
                        string extension = ".png";//Path.GetExtension(filename);
                        string fileRootName = organizationId.ToString();
                        MemoryStream outStream = new MemoryStream();
                        long tmpSize = 0;
                        string ImageProcessingFolfer = Path.Combine(portal.HomeDirectoryMapPath + "OrgImages\\TempImages", filename);
                        Helper.HelperMethods.DeleteFiles(portal.HomeDirectoryMapPath + "OrgImages\\HeaderImages", "*" + organizationId.ToString() + "*");
                        ImageFactory imageFactory = new ImageFactory(preserveExifData: true);
                        imageFactory.Load(ImageProcessingFolfer);
                        imageFactory.Save(outStream);// ();
                        tmpSize = outStream.Length;
                        Helper.HelperMethods.SaveImage(ref outStream, Path.Combine(portal.HomeDirectoryMapPath + "OrgImages\\HeaderImages", fileRootName + extension));


                        fileResultModelList.Add(new FileResultModel()
                        {
                            Extension = extension,
                            Filename = fileRootName,
                            Link = portal.HomeDirectory + "OrgImages/HeaderImages/" + fileRootName + extension,
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
                        Helper.HelperMethods.SaveImage(ref outStream, Path.Combine(portal.HomeDirectoryMapPath + "OrgImages\\HeaderImages", "cropBig" + fileRootName + extension));
                        fileResultModelList.Add(new FileResultModel()
                        {
                            Extension = extension,
                            Filename = "cropBig" + fileRootName,
                            Link = portal.HomeDirectory + "OrgImages/HeaderImages/" + "cropBig" + fileRootName + extension,
                            Description = "Crop Big",
                            Size = tmpSize


                        });


                        System.Drawing.Size sizeSmall = new System.Drawing.Size(Convert.ToInt32(600), Convert.ToInt32(300));
                        imageFactory.Resize(sizeSmall);
                        outStream = new MemoryStream();
                        imageFactory.Save(outStream);
                        tmpSize = outStream.Length;
                        Helper.HelperMethods.SaveImage(ref outStream, Path.Combine(portal.HomeDirectoryMapPath + "OrgImages\\HeaderImages", "cropThumb" + fileRootName + extension));




                        fileResultModelList.Add(new FileResultModel()
                        {
                            Extension = extension,
                            Filename = "cropThumb" + fileRootName,
                            Link = portal.HomeDirectory + "OrgImages/HeaderImages/" + "cropThumb" + fileRootName + extension,
                            Description = "Crop Thumbnail",
                            Size = tmpSize


                        });
                        Helper.HelperMethods.DeleteFiles(portal.HomeDirectoryMapPath + "OrgImages\\TempUserImages", filename + "*");
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
        public HttpResponseMessage RemoveBannerImage(Guid organizationId)
        {
            try
            {
                var portal = PortalController.GetCurrentPortalSettings();
                var user = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
                var userProperty = new UserPropertyComponent(user.UserID);

                var organization = new OrganizationComponent(organizationId);
                if (user.IsInRole("Administrators") || organization.Organization.CreatedBy == user.UserID)
                {
                    Helper.HelperMethods.DeleteFiles(portal.HomeDirectoryMapPath + "OrgImages\\HeaderImages", "*" + organization.Organization.OrganizationID.ToString() + "*");
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
    }
}
