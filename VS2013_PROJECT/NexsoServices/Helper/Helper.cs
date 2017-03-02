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
using NexsoServices.V2;

namespace NexsoServices.Helper
{
    public class HelperMethods
    {
        public static List<string> FillFormat(Guid solutionId, string category, CultureInfo cultureInfo)
        {
            var list = SolutionListComponent.GetListPerCategory(solutionId, category);
            List<string> listRet = new List<string>();
            foreach (var item in list)
            {
                listRet.Add(NexsoProBLL.ListComponent.GetLabelFromListKey(category, cultureInfo.Name, item.Key));
            }

            return listRet;
        }

        public static List<ListItemModel> GetListFromUserPropertiesList( IQueryable<UserPropertiesList> list, CultureInfo culture)
        {
            List<ListItemModel> _return = new List<ListItemModel>();
            if(list!=null)
            {
                foreach (var item in list)
                {
                    var itemUserProp=new ListComponent(item.Key,item.Category,culture.Name);
                    _return.Add(new ListItemModel()
                        {
                            Category = itemUserProp.ListItem.Category,
                            Key = itemUserProp.ListItem.Key,
                            Culture = itemUserProp.ListItem.Culture,
                            Order = itemUserProp.ListItem.Order,
                            Value = itemUserProp.ListItem.Value
                        }
                        );
                }
            }

            return _return;
        }

        public static List<ListItemModel> GetListsFromCategory(string category, CultureInfo culture)
        {
            List<ListItemModel> _return = new List<ListItemModel>();
            var list = ListComponent.GetListPerCategory(category, culture.Name).ToList();
                foreach (var item in list)
                {
                  
                    _return.Add(new ListItemModel()
                    {
                        Category = item.Category,
                        Key = item.Key,
                        Culture = item.Culture,
                        Order = item.Order,
                        Value = item.Value
                    }
                        );
                }
            

            return _return;
        }

        public static long GenerateHash(int input)
        {
            return 1414 *input;
        }

        public static void DeleteFiles(string dir, string file)
        {
            string[] filePaths = Directory.GetFiles(dir, file);
            foreach (string filePath in filePaths)
                File.Delete(filePath);

        }

        public static string JsonToSQLParameter(List<string> array)
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

        public static string GetHeaderImage(Guid solutionId, PortalSettings portalSettings)
        {

            if (File.Exists(
                 HttpContext.Current.Server.MapPath(portalSettings.HomeDirectory + "ModIma/HeaderImages/cropThumb" +
                                  solutionId.ToString() +
                                   ".jpg")))
            {
                return portalSettings.HomeDirectory + "ModIma/HeaderImages/cropThumb" + solutionId.ToString() + ".jpg";
            }
            else
                if (File.Exists(
                    HttpContext.Current.Server.MapPath(portalSettings.HomeDirectory + "ModIma/HeaderImages/cropThumb" +
                                  solutionId.ToString() +
                                   ".png")))
                {
                    return portalSettings.HomeDirectory + "ModIma/HeaderImages/cropThumb" + solutionId.ToString() + ".png";
                }
                else
                {
                    var list = SolutionListComponent.GetListPerCategory(solutionId, "Theme").ToList();

                    if (list.Count > 0)
                    {

                        Random randNum = new Random();

                        var theme = list[randNum.Next(list.Count)].Key;
                        if (File.Exists(
                        HttpContext.Current.Server.MapPath(portalSettings.HomeDirectory + "ModIma/HeaderImages/" + theme + ".jpg")))
                        {
                            return portalSettings.HomeDirectory + "ModIma/HeaderImages/" + theme + ".jpg";
                        }
                        else
                        {
                            return portalSettings.HomeDirectory + "ModIma/HeaderImages/noHeader.png";
                        }

                    }
                    else
                    {
                        return portalSettings.HomeDirectory + "ModIma/HeaderImages/noHeader.png";
                    }
                }


        }

        public static List<SolutioLocationJson> GetSolutionLocations(Guid solutionId)
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

        public static string GetUserLanguage(int lang)
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

        public static int SetNotification(string indicatorType, string objectType, Guid objectId, int toUserId, int? fromUserId, string tag)
        {
            NotificationComponent notificationComponent = new NotificationComponent();
            notificationComponent.Notification.Code = indicatorType;
            notificationComponent.Notification.Created = DateTime.Now;
            notificationComponent.Notification.UserId = toUserId;
            notificationComponent.Notification.Message = "V1";
            notificationComponent.Notification.ToolTip = "V1";
            notificationComponent.Notification.Link = objectId.ToString();
            notificationComponent.Notification.ObjectType = objectType;
            notificationComponent.Notification.Tag = tag;

            if (fromUserId.HasValue==true)
            {
                notificationComponent.Notification.UserNotificationConnections.Add(new UserNotificationConnection()
                {
                    UserNotificationConnection1 = Guid.NewGuid(),
                    UserId = fromUserId.Value,
                    Rol = string.Empty
                });
            }
            return notificationComponent.Save();
        }

        public static string GetResource(string code, CultureInfo language)
        {
            ResourceManager Localization = new ResourceManager("NexsoServices.App_LocalResources.Resource",
                                     Assembly.GetExecutingAssembly());
            return Localization.GetString(code, language);
           
        }

        public static string GetNotificationLink(string indicatorType, string objectType, CultureInfo culture, string id)
        {
            switch(objectType)
            {
                case "SOLUTION":
                    {
                        return NexsoHelper.GetCulturedUrlByTabName("solprofile", 7, culture.Name) + "/sl/" + id;
                    }
            }
           
            return "";

        }

        public static int SetMediaIndicator(Guid objectId, int? userId, string indicatorType, string objectType, decimal value, string agregator)
        {
            try
            {
                int values = 0;
                SocialMediaIndicatorComponent socialMediaIndicatorComponent = new SocialMediaIndicatorComponent(objectId, objectType, indicatorType, userId);
                if (socialMediaIndicatorComponent.SocialMediaIndicator.SocialMediaIndicatorId == Guid.Empty)
                {
                    socialMediaIndicatorComponent.SocialMediaIndicator.Value = value;
                    socialMediaIndicatorComponent.SocialMediaIndicator.Created = DateTime.Now;
                    socialMediaIndicatorComponent.SocialMediaIndicator.ObjectType = objectType;
                    socialMediaIndicatorComponent.SocialMediaIndicator.IndicatorType = indicatorType;
                    socialMediaIndicatorComponent.SocialMediaIndicator.Aggregator = agregator;
                    return socialMediaIndicatorComponent.Save();
                }
                else
                {
                    if (socialMediaIndicatorComponent.SocialMediaIndicator.ObjectType == objectType &&
                        socialMediaIndicatorComponent.SocialMediaIndicator.IndicatorType == indicatorType &&
                        socialMediaIndicatorComponent.SocialMediaIndicator.UserId == userId)
                    {
                        if (socialMediaIndicatorComponent.SocialMediaIndicator.Value != value)
                        {
                            socialMediaIndicatorComponent.SocialMediaIndicator.Value = value;
                            return socialMediaIndicatorComponent.Save();
                        }
                        
                    }
                    
                }

                return 0;


            }
            catch
            {
                return -1;
            }
        }

        public static  decimal DeleteMediaIndicator(Guid objectId, string objectType, string indicatorType, int userId, string aggregator)
        {
            try
            {
                decimal indicator = 0;
                SocialMediaIndicatorComponent socialMediaIndicatorComponent = new SocialMediaIndicatorComponent(objectId, objectType, indicatorType, userId);
                if (socialMediaIndicatorComponent.SocialMediaIndicator.SocialMediaIndicatorId != Guid.Empty)
                {
                    socialMediaIndicatorComponent.Delete();
                }
                indicator = Convert.ToInt32(SocialMediaIndicatorComponent.GetAggregatorSocialMediaIndicatorPerObjectRelated(objectId, objectType, indicatorType, aggregator));
                return indicator;
            }
            catch
            {
                return -1;
            }
        }

        public static List<UserProfileModel> ParseUserProfile(List<UserProperty> userProperties)
        {
            List<UserProfileModel> listUserProfileModel = new List<UserProfileModel>();
            if(userProperties!=null)
            {
                foreach (var item in userProperties)
                {
                    listUserProfileModel.Add(new UserProfileModel()
                    {
                        UserId = item.UserId,
                        LastName = item.LastName,
                        FirstName = item.FirstName,
                        Bio = item.Bio,
                        ProfilePicture = item.ProfilePicture.GetValueOrDefault(Guid.Empty),
                        BannerPicture = item.BannerPicture.GetValueOrDefault(Guid.Empty)


                    });
                }
            }
            return listUserProfileModel;
        }

        public static List<UserProfileModel> ParseUserProfile(List<UserNotificationConnection> userNotificationConnection)
        {
            List<UserProfileModel> listUserProfileModel = new List<UserProfileModel>();
            if (userNotificationConnection != null)
            {
                foreach (var item in userNotificationConnection)
                {
                    UserPropertyComponent user_ = new UserPropertyComponent(item.UserId);
                    

                    listUserProfileModel.Add(new UserProfileModel()
                    {
                        UserId = user_.UserProperty.UserId,
                        LastName = user_.UserProperty.LastName,
                        FirstName = user_.UserProperty.FirstName,
                        Bio = user_.UserProperty.Bio,
                        ProfilePicture = user_.UserProperty.ProfilePicture.GetValueOrDefault(Guid.Empty),
                        BannerPicture = user_.UserProperty.BannerPicture.GetValueOrDefault(Guid.Empty),
                         NotificationRole=item.Rol,
                         NotificationTag=item.Tag


                    });
                }
            }
            return listUserProfileModel;
        }

        public static List<GenericObject> ParseGenericObject(string[] Id, string type)
        {
            var return_=new List<GenericObject>();

            foreach(var id in Id)
            {
                switch(type)
                {
                    case "SOLUTION":
                        {
                            var id_ = new Guid(id);
                            var solution_ = new SolutionComponent(id_);
                            if(solution_.Solution.SolutionId!=Guid.Empty)
                            {
                                return_.Add(new GenericObject()
                                    {
                                         ObjectId=solution_.Solution.SolutionId.ToString(),
                                          LongDescription=solution_.Solution.Description,
                                           TagLine=solution_.Solution.TagLine,
                                           Title=solution_.Solution.Title,
                                            Type="SOLUTION"

                                    }
                                    );
                            }
                            break; 
                        }
                }
            }

            return return_;
        }

        public static UserProfileModel ParseUserProfile(UserProperty userProperty, string role, CultureInfo culture)
        {
                var listUserTheme = UserPropertiesListComponent.GetListPerCategory(userProperty.UserId, "Theme");
                var listUserBeneficiaries = UserPropertiesListComponent.GetListPerCategory(userProperty.UserId, "Beneficiaries");
                var listUserSector = UserPropertiesListComponent.GetListPerCategory(userProperty.UserId, "Sector");
               

                var userProfileModel = new UserProfileModel();

                userProfileModel.Themes = Helper.HelperMethods.GetListFromUserPropertiesList(listUserTheme, culture);
                userProfileModel.Beneficiaries = Helper.HelperMethods.GetListFromUserPropertiesList(listUserBeneficiaries, culture);
                userProfileModel.Sectors = Helper.HelperMethods.GetListFromUserPropertiesList(listUserSector, culture);
                userProfileModel.UserId = userProperty.UserId;
                userProfileModel.NexsoUserId = userProperty.NexsoUserId == null ? Guid.Empty : (Guid)userProperty.NexsoUserId;
                userProfileModel.SkypeName =userProperty.SkypeName;
                userProfileModel.Twitter = userProperty.Twitter;
                userProfileModel.FaceBook = userProperty.FaceBook;
                userProfileModel.Google = userProperty.Google;
                userProfileModel.LinkedIn = userProperty.LinkedIn;
                userProfileModel.OtherSocialNetwork = userProperty.OtherSocialNetwork;
                userProfileModel.Bio = userProperty.Bio;
                userProfileModel.BannerPicture = userProperty.BannerPicture.GetValueOrDefault(Guid.Empty);
                userProfileModel.ProfilePicture = userProperty.ProfilePicture.GetValueOrDefault(Guid.Empty);
                userProfileModel.City = userProperty.City;
                userProfileModel.Region = userProperty.Region;
                userProfileModel.Country = userProperty.Country;
                userProfileModel.FirstName = userProperty.FirstName;
                userProfileModel.LastName = userProperty.LastName;
                userProfileModel.Language = Convert.ToInt32(userProperty.Language);
                userProfileModel.Latitude = Convert.ToDecimal(userProperty.Latitude);
                userProfileModel.Longitude = Convert.ToDecimal(userProperty.Longitude);
                userProfileModel.GoogleLocation = userProperty.GoogleLocation;

                if (role=="Owner")
                {
                    userProfileModel.Agreement = userProperty.Agreement;
                    userProfileModel.PostalCode = userProperty.PostalCode;
                    userProfileModel.Telephone = userProperty.Telephone;
                    userProfileModel.Address = userProperty.Address;
                    userProfileModel.email = userProperty.email;
                    userProfileModel.CustomerType = userProperty.CustomerType.GetValueOrDefault(-1);
                    userProfileModel.NexsoEnrolment = userProperty.NexsoEnrolment.GetValueOrDefault(-1);
                    userProfileModel.AllowNexsoNotifications = userProperty.AllowNexsoNotifications.GetValueOrDefault(-1);
                }




                return userProfileModel;
        }

        public static void SendCommentNotificationEmails(SolutionCommentComponent solutionCommentComponent, PortalSettings portalSettings, UserInfo currentUser)
        {
            ResourceManager Localization = new ResourceManager("NexsoServices.App_LocalResources.Resource",
                                  Assembly.GetExecutingAssembly());
            List<int> userIds = new List<int>();

            foreach (SolutionComment solutionComment in solutionCommentComponent.SolutionComment.Solution.SolutionComments)
            {
                if (!userIds.Contains(solutionComment.UserId.GetValueOrDefault(-1)))
                    userIds.Add(solutionComment.UserId.GetValueOrDefault(-1));
            }
            if (solutionCommentComponent.SolutionComment.Solution.CreatedUserId.GetValueOrDefault(-1) != -1)
                userIds.Add(solutionCommentComponent.SolutionComment.Solution.CreatedUserId.GetValueOrDefault(-1));
            foreach (int userids in userIds)
            {

                UserInfo user = DotNetNuke.Entities.Users.UserController.GetUserById(portalSettings.PortalId, userids);
                UserPropertyComponent property = new UserPropertyComponent(userids);
                if (currentUser.UserID != user.UserID)
                {
                    CultureInfo language = new CultureInfo(HelperMethods.GetUserLanguage(property.UserProperty.Language.GetValueOrDefault(1)));
                    DotNetNuke.Services.Mail.Mail.SendEmail("nexso@iadb.org",
                                                              user.Email,
                                                             string.Format(
                                                                 Localization.GetString("MessageTitleComment", language),
                                                                 currentUser.FirstName + " " + currentUser.LastName,
                                                                 solutionCommentComponent.SolutionComment.Solution.Title),
                                                                 Localization.GetString("MessageBodyComment", language).Replace(
                                                                 "{COMMENT:Body}", solutionCommentComponent.SolutionComment.Comment).Replace(
                                                                 "{SOLUTION:Title}", solutionCommentComponent.SolutionComment.Solution.Title).Replace(
                                                                 "{SOLUTION:PageLink}", NexsoHelper.GetCulturedUrlByTabName("solprofile", 7, language.Name) +
                                                                 "/sl/" + solutionCommentComponent.SolutionComment.Solution.SolutionId.ToString())
                                                                 );
                }
            }
            CultureInfo langua = new CultureInfo("en-US");
            DotNetNuke.Services.Mail.Mail.SendEmail("nexso@iadb.org",
                                                          "jairoa@iadb.org,patriciab@nexso.org, wrightgas@gmail.com,YVESL@iadb.org,MONICAO@iadb.org", "NOTIFICATION: " +
                                                           string.Format(
                                                               Localization.GetString("MessageTitleComment", langua),
                                                               currentUser.FirstName + " " + currentUser.LastName, solutionCommentComponent.SolutionComment
                                                                                        .Solution.Title),
                                                            Localization.GetString("MessageBodyComment", langua).Replace(
                                                                 "{COMMENT:Body}", solutionCommentComponent.SolutionComment.Comment).Replace(
                                                                 "{SOLUTION:Title}", solutionCommentComponent.SolutionComment.Solution.Title).Replace(
                                                                 "{SOLUTION:PageLink}", NexsoHelper.GetCulturedUrlByTabName("solprofile", 7, langua.Name) +
                                                                 "/sl/" + solutionCommentComponent.SolutionComment.Solution.SolutionId.ToString())
                                                                 );
        }

        public static async Task SendEmailToUser(string subjectTemplate, string bodyTemplate, UserInfo userTo, CultureInfo culture, string messageSubject, string messageBody)
        {
            await Task.Run(() =>
                {
                    ResourceManager Localization = new ResourceManager("NexsoServices.App_LocalResources.Resource",
                                       Assembly.GetExecutingAssembly());

                    UserPropertyComponent currentUser = new UserPropertyComponent(userTo.UserID);
                    DotNetNuke.Services.Mail.Mail.SendEmail("nexso@iadb.org",
                                                                     userTo.Email,
                                                                    string.Format(
                                                                        Localization.GetString(subjectTemplate, culture),
                                                                        currentUser.UserProperty.FirstName + " " + currentUser.UserProperty.LastName
                                                                      ),
                                                                        Localization.GetString("MessageBodyMessage", culture).Replace(
                                                                        "{MESSAGE:Body}", messageBody).Replace(
                                                                        "{MESSAGE:ViewLink}", NexsoHelper.GetCulturedUrlByTabName("MyMessages", 7, culture.Name))

                                                                        );

                }
                );



        }

        /// <summary>
        /// Send email to user
        /// </summary>
        /// <param name="bodyTemplate"></param>
        /// <param name="userEmailTo"></param>
        /// <param name="culture"></param>
        /// <param name="messageSubject"></param>
        /// <param name="messageBody"></param>
        /// <returns></returns>
        public static void SendEmailToUser( string bodyTemplate, string userEmailTo, CultureInfo culture, string messageSubject, string messageBody)
        {
            
                try
                {
                ResourceManager Localization = new ResourceManager("NexsoServices.App_LocalResources.Resource",
                                   Assembly.GetExecutingAssembly());

                string body= Localization.GetString(bodyTemplate, culture).Replace(
                                                                    "{MESSAGE:Body}", messageBody);
                Task.Factory.StartNew(() =>
                {
                    DotNetNuke.Services.Mail.Mail.SendEmail("nexso@iadb.org",
                                       userEmailTo,
                                      messageSubject,
                                         body

                                          );
                });

                
                }
                catch(Exception ee)
                {
                    DotNetNuke.Services.Exceptions.Exceptions.LogException(ee);
                }

            
             



        }

        public static void SaveImage(ref MemoryStream memoryStream, string path)
        {

            FileStream file = new FileStream(path, FileMode.Create, FileAccess.Write);
            memoryStream.WriteTo(file);
            file.Close();
            memoryStream.Close();
        }
    }
}
