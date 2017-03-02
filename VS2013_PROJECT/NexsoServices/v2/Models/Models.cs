using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NexsoProDAL;
using NexsoProBLL;
using Newtonsoft.Json;

namespace NexsoServices.V2
{
    /// <summary>
    /// ff
    /// </summary>
    public class SolutionOrganizationModel
    {
        public string SolutionTitle { get; set; }
        public List<string> SolutionThemes { get; set; }
        public List<string> SolutionBeneficiaries { get; set; }
        public List<string> SolutionDeliveryFormat { get; set; }
        public List<SolutioLocationJson> SolutionLocations { get; set; }
        public int SolutionState { get; set; }
        public Guid SolutionId { get; set; }
        public string OrganizationLogo { get; set; }
        public string SolutionHeader { get; set; }
        public Guid OrganizationId { get; set; }
        public string OrganizationName { get; set; }
        public decimal SolutionCost { get; set; }
        public string SolutionCostUnit { get; set; }
        public string ProjectDuration { get; set; }
        public string OrganizationUrl { get; set; }
        public string SolutionUrl { get; set; }
        public string SolutionTagLine { get; set; }
        public string OrganizationDescription { get; set; }
        public string ChallengeReference { get; set; }
        public string SolutionType { get; set; }
        public string VideoObject { get; set; }
        public string ChallengeState { get; set; }

    }

    /// <summary>
    /// fff
    /// </summary>
    public class SolutioLocationModel
    {
        public string City { get; set; }
        public string Region { get; set; }
        public string Country { get; set; }
        public decimal Latitude { get; set; }
        public decimal Longitude { get; set; }
    }

    /// <summary>
    /// f
    /// </summary>
    public class SolutionCommentsModel
    {
        public Guid CommentId { get; set; }
        public Guid SolutionId { get; set; }
        public int UserId { get; set; }
        public string Comment { get; set; }
        public DateTime CreatedDate { get; set; }
        public Boolean Publish { get; set; }
        public string Scope { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }

    }

    /// <summary>
    /// ff
    /// </summary>
    public class MessageModel
    {
        public Guid MessageId { get; set; }
        public int FromUserId { get; set; }
        public int ToUserId { get; set; }
        public string Message { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime DateRead { get; set; }


    }
    /// <summary>
    /// Challenge Model
    /// </summary>
    public class ChallengeModel
    {

        public string ChallengeReference { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Open { get; set; }
        public string Close { get; set; }
        public bool IfOpen { get; set; }
        public string UrlBanner { get; set; }
        public string UrlChallenge { get; set; }

    }


    /// <summary>
    /// f
    /// </summary>
    public class FileResultModel
    {
        public string Link { get; set; }
        public string Description { get; set; }
        public string ToolTip { get; set; }
        public string Filename { get; set; }
        public string Extension { get; set; }
        public long Size { get; set; }


    }


    public class ListItemModel
    {
        [JsonProperty("Key")]
        public string Key { get; set; }
        [JsonProperty("Category")]
        public string Category { get; set; }
        [JsonProperty("Culture")]
        public string Culture { get; set; }
        [JsonProperty("Value")]
        public string Value { get; set; }
        [JsonProperty("Order")]
        public int Order { get; set; }
    }


    /// <summary>
    /// 
    /// </summary>
    public class CropImage
    {
        public string Filename { get; set; }
        public int xCrop { get; set; }
        public int yCrop { get; set; }
        public int Resolution { get; set; }
        public int Width { get; set; }
        public int Height { get; set; }


    }

    public class NexsoQuery
    {
        public string Sort { get; set; }
        public string[] Beneficiaries { get; set; }
        public string[] Categories { get; set; }
        public string[] DeliveryFormat { get; set; }
        public int state { get; set; }
        public string Language { get; set; }
        public string Search { get; set; }
        public int UserId { get; set; }
    }


    /// <summary>
    /// 
    /// </summary>
    public class NotificationModel
    {
        public Guid NotificationId { get; set; }
        public int UserId { get; set; }
        public string Type { get; set; }
        public string Code { get; set; }
        public DateTime Created { get; set; }
        public DateTime Read { get; set; }
        public string Message { get; set; }
        public string ToolTip { get; set; }
        public string Tag { get; set; }
        public string Link { get; set; }
        public List<UserProfileModel> UserProfileList { get; set; }
        public List<GenericObject> RelatedObject { get; set; }
    }

    public class GenericObject
    {
        public string Type { get; set; }
        public string ObjectId { get; set; }
        public string Title { get; set; }
        public string TagLine { get; set; }
        public string LongDescription { get; set; }
        public string Link { get; set; }
        public string Tooltip { get; set; }
        public string Image { get; set; }
    }

    public class NotificationFilter
    {
        public string language { get; set; }

    }

    public class SolutionLogModel
    {
        public Guid SolutionLogId { get; set; }
        public Guid SolutionId { get; set; }
        public String Key { get; set; }
        public String Value { get; set; }
        public DateTime Date { get; set; }
        public string DataType { get; set; }

    }

    /// <summary>
    /// f
    /// </summary>
    public class UserProfileModel
    {
        public int UserId { get; set; }
        public Guid NexsoUserId { get; set; }
        public string Agreement { get; set; }
        public string SkypeName { get; set; }
        public string Twitter { get; set; }
        public string FaceBook { get; set; }
        public string Google { get; set; }
        public string LinkedIn { get; set; }
        public string OtherSocialNetwork { get; set; }
        public string City { get; set; }
        public string Region { get; set; }
        public string Country { get; set; }
        public string PostalCode { get; set; }
        public string Telephone { get; set; }
        public string Address { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string email { get; set; }
        public int CustomerType { get; set; }
        public int NexsoEnrolment { get; set; }
        public int AllowNexsoNotifications { get; set; }
        public int Language { get; set; }
        public decimal Latitude { get; set; }
        public decimal Longitude { get; set; }
        public string GoogleLocation { get; set; }
        public Guid BannerPicture { get; set; }
        public Guid ProfilePicture { get; set; }
        public string Bio { get; set; }
        public List<ListItemModel> Themes { get; set; }
        public List<ListItemModel> Beneficiaries { get; set; }
        public List<ListItemModel> Sectors { get; set; }
        public string FieldOfWork { get; set; }
        public string Enrollment { get; set; }
        public string NotificationTag { get; set; }
        public string NotificationRole { get; set; }

        public UserProfileModel()
        {
            Themes = new List<ListItemModel>();
            Beneficiaries = new List<ListItemModel>();
            Sectors = new List<ListItemModel>();
        }
    }

    public class AccreditationsModel
    {
        public Guid AccreditationId { get; set; }
        public Guid OrganizationId { get; set; }
        public string Type { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public string Content { get; set; }
        public Guid DocumentId { get; set; }
        public string yearAccreditation { get; set; }
        public string docName { get; set; }
        public string docUrl { get; set; }
    }

    public class ReferencesModel
    {
        public Guid ReferenceId { get; set; }
        public Guid OrganizationId { get; set; }
        public int UserId { get; set; }
        public string Type { get; set; }
        public string Comment { get; set; }
        public string Created { get; set; }
        public string Updated { get; set; }
        public bool Deleted { get; set; }

        public string fullName { get; set; }
    }

    public class OrganizationsModel
    {
        public Guid OrganizationID { get; set; }
        public string Code { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string ContactEmail { get; set; } 
        public string Website { get; set; } 
        public string Twitter { get; set; }
        public string Skype { get; set; }
        public string Facebook { get; set; }
        public string GooglePlus { get; set; }
        public string LinkedIn { get; set; }
        public string Description  { get; set; }
        public string Logo { get; set; }
        public string Country { get; set; }
        public string Region { get; set; }
        public string City { get; set; }
        public string ZipCode { get; set; }
        public DateTime Created { get; set; }
        public DateTime Updated { get; set; }
        public decimal Latitude { get; set; }
        public decimal Longitude { get; set; }
        public string GoogleLocation  { get; set; }
        public string Language { get; set; }
        public int Year { get; set; }
        public int Staff { get; set; }
        public decimal Budget { get; set; }
        public string CheckedBy { get; set; }
        public DateTime CreatedOn { get; set; }
        public DateTime UpdatedOn { get; set; }
        public int CreatedBy { get; set; }
        public bool Deleted { get; set; }
        public List<ReferencesModel> references { get; set; }
        public List<AccreditationsModel> accreditations { get; set; }
        public List<string> partnershipsLogo { get; set; }
        public int solutionNumber { get; set; }
        public List<AttributesModel> attributes { get; set; }        
        public string userProfilePicture { get; set; }
        public string userFirstName { get; set; }
        public string userLastName { get; set; }
        public string userEmail { get; set; }
        public string userLinkedIn { get; set; }
        public string userFacebook { get; set; }
        public string userTwitter { get; set; }
        public string userAddress { get; set; }
        public string userCity { get; set; }
        public string userCountry { get; set; }
        public string userWebSite { get; set; }
        public string userID { get; set; }

        public bool ownerSolution { get; set; }
    }

    public class PartnershipsModel
    {
        public Guid OrganizationID { get; set; }
        public Guid OrganizationPartnerID { get; set; }
        public string Logo { get; set; }
    }

    public class AttributesModel
    {
        public Guid AttributeID { get; set; }
        public Guid OrganizationID { get; set; }
        public string Type { get; set; }
        public string Value { get; set; }
        public string ValueType { get; set; }
        public string Description { get; set; }
        public string Label { get; set; }
    }

    public class SocialMediaIndicatorModel
    {
        public Guid ObjectId { set; get; }
        public string ObjectType { set; get; }
        public int UserId { set; get; }
        public string IndicatorType { set; get; }
        public decimal Value { set; get; }
        public DateTime Created { set; get; }
        public string Unit { set; get; }
        public string Aggregator { set; get; }
    }
}
