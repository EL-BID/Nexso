using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NexsoProDAL;
using NexsoProBLL;

namespace NexsoServices
{
    public class SolutionOrganizationJson
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
        public string ChallengeState { get; set; }
        public string Likes { get; set; }

    }

    public class SolutioLocationJson
    {
        public string City { get; set; }
        public string Region { get; set; }
        public string Country { get; set; }
        public decimal Latitude { get; set; }
        public decimal Longitude { get; set; }
    }

    public class SolutionCommentsJson
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

    public class MessageJson
    {
        public Guid MessageId { get; set; }
        public int FromUserId { get; set; }
        public int ToUserId { get; set; }
        public string Message { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime DateRead { get; set; }


    }



    public class FileResult
    {

        public string Result { get; set; }

        public string DownloadLink { get; set; }

        public string FileName { get; set; }
    }

    public class NotificationJson
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
        public List<UserProfileJson> UserProfileList { get; set; }
    }


    public class UserProfileJson
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
        public string BackgroundPicture { get; set; }
        public string ProfilePicture { get; set; }
        public string Biography { get; set; }
    }
}
