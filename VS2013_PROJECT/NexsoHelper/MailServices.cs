using System.Configuration;
using System.Net.Mail;
using NexsoProBLL;
using NexsoProDAL;
using System.Text;
using System;
using System.Collections.Generic;
using System.Xml.Serialization;
using System.IO;
using DotNetNuke.Entities.Users;
using System.Linq;




public class MailServices
{
    public static bool SendNexsoMail()
    {
        //Mail.SendEmail()
        return true;
    }

    private static string GetSqlClause(MailFilter mailFilter)
    {
        StringBuilder leftClause = new StringBuilder();
        StringBuilder rightClause = new StringBuilder();
        StringBuilder result = new StringBuilder();

        if (mailFilter.FilterValue.Count > 0)
        {
            if (mailFilter.Field.Contains("FUNC:"))
            {
                mailFilter.Field = mailFilter.Field.Replace("FUNC:", "");
                mailFilter.Table = "dbo";
            }
            switch (mailFilter.Operator)
            {
                case "IN":
                    {

                        if (mailFilter.FilterValue.Any(a => a != "%NULL%"))
                        {
                            leftClause.Append(" " + mailFilter.Table + "." + mailFilter.Field + " IN ( ");
                            switch (mailFilter.DataType)
                            {
                                case "Integer":
                                    {

                                        foreach (var item in mailFilter.FilterValue)
                                        {
                                            if (item != "%NULL%")
                                                leftClause.Append("" + item + ",");


                                        }
                                        if (mailFilter.FilterValue.Count > 0)
                                            leftClause.Remove(leftClause.Length - 1, 1);
                                        break;
                                    }
                                case "Float":
                                    {
                                        foreach (var item in mailFilter.FilterValue)
                                        {
                                            if (item != "%NULL%")
                                                leftClause.Append("" + item + ",");
                                        }
                                        if (mailFilter.FilterValue.Count > 0)
                                            leftClause.Remove(leftClause.Length - 1, 1);
                                        break;
                                    }
                                case "String":
                                    {
                                        foreach (var item in mailFilter.FilterValue)
                                        {
                                            if (item != "%NULL%")
                                                leftClause.Append("'" + item + "',");
                                        }
                                        if (mailFilter.FilterValue.Count > 0)
                                            leftClause.Remove(leftClause.Length - 1, 1);
                                        break;
                                    }
                                case "Boolean":
                                    {
                                        foreach (var item in mailFilter.FilterValue)
                                        {
                                            if (item != "%NULL%")
                                                leftClause.Append("" + item + ",");
                                        }
                                        if (mailFilter.FilterValue.Count > 0)
                                            leftClause.Remove(leftClause.Length - 1, 1);
                                        break;
                                    }
                            }
                            leftClause.Append(" ) ");
                        }
                        if (mailFilter.FilterValue.Any(a => a == "%NULL%"))
                            rightClause.Append(" " + mailFilter.Table + "." + mailFilter.Field + " IS NULL  ");

                        if (leftClause.Length > 0 && rightClause.Length > 0)
                            result.Append(" " + mailFilter.ConcatenateOperator + " ( " + leftClause.ToString() + " OR " +
                                          rightClause.ToString() + " " + mailFilter.Command + " ) ");
                        else
                            result.Append(" " + mailFilter.ConcatenateOperator + " ( " + leftClause.ToString() +
                                          rightClause.ToString() + " " + mailFilter.Command + " ) ");
                        break;
                    }

                case "=":
                case ">=":
                case "<=":
                    {

                        if (mailFilter.FilterValue.Count == 1)
                        {
                            leftClause.Append(" " + mailFilter.Table + "." + mailFilter.Field + " " + mailFilter.Operator);
                            switch (mailFilter.DataType)
                            {
                                case "Integer":
                                    {
                                        leftClause.Append(" " + mailFilter.FilterValue[0] + " ");

                                        break;
                                    }
                                case "Float":
                                    {
                                        leftClause.Append(" " + mailFilter.FilterValue[0] + " ");
                                        break;
                                    }
                                case "String":
                                    {
                                        leftClause.Append(" '" + mailFilter.FilterValue[0] + "' ");
                                        break;
                                    }
                                case "Boolean":
                                    {
                                        leftClause.Append(" " + mailFilter.FilterValue[0] + " ");
                                        break;
                                    }
                            }
                            result.Append(" " + mailFilter.ConcatenateOperator + " ( " + leftClause.ToString() + mailFilter.Command + " ) ");

                        }

                        break;
                    }
            }


        }
        return result.ToString();
    }

    public static List<CampaignLog> ProcessXmlFilter(Guid CampaignId, string trackKey, int attemp, string xmlFilter,
                                                     int portalId)
    {
        List<CampaignLog> listResult = new List<CampaignLog>();
        MailContainer mailContainer;
        try
        {
            mailContainer = new MailContainer();

            XmlSerializer serializer = new XmlSerializer(mailContainer.GetType());

            MemoryStream memoryStream = new MemoryStream(Encoding.ASCII.GetBytes(xmlFilter));

            mailContainer = (MailContainer)serializer.Deserialize(memoryStream);

            StringBuilder queryPotentialUser = new StringBuilder();
            StringBuilder queryUser = new StringBuilder();
            StringBuilder queryOrganization = new StringBuilder();
            StringBuilder querySolution = new StringBuilder();


            MIFNEXSOEntities ent = new MIFNEXSOEntities();



            foreach (MailFilter mailFilter in mailContainer.MailFilter)
            {
                switch (mailFilter.Table)
                {
                    case "PotentialUsers":
                        {
                            switch (mailFilter.Field)
                            {
                                case "Country":
                                    {
                                        queryPotentialUser.Append(GetSqlClause(mailFilter));
                                        break;
                                    }
                                case "Language":
                                    {
                                        queryPotentialUser.Append(GetSqlClause(mailFilter));
                                        break;
                                    }
                                case "Source":
                                    {
                                        queryPotentialUser.Append(GetSqlClause(mailFilter));
                                        break;
                                    }

                            }
                            break;
                        }


                    case "UserProperties":
                        {
                            switch (mailFilter.Field)
                            {
                                case "Country":
                                    {
                                        queryUser.Append(GetSqlClause(mailFilter));
                                        break;
                                    }
                                case "Language":
                                    {
                                        queryUser.Append(GetSqlClause(mailFilter));
                                        break;
                                    }
                                //case "CustomerType":
                                //    {

                                //        break;
                                //    }
                                case "[AllowNexsoNotifications]":
                                    {
                                        if (mailFilter.FilterValue.Count > 0)
                                        {
                                            if (mailFilter.FilterValue[0] == "1")
                                                queryUser.Append(GetSqlClause(mailFilter));
                                        }
                                        break;
                                    }

                            }
                            break;
                        }

                    case "UserPropertiesLists":
                        {
                            switch (mailFilter.Field)
                            {
                                case "[Key]":
                                    {
                                        queryUser.Append(GetSqlClause(mailFilter));
                                        break;
                                    }
                            }
                            break;
                        }

                    case "Organization":
                        {
                            switch (mailFilter.Field)
                            {
                                case "Country":
                                    {
                                        queryOrganization.Append(GetSqlClause(mailFilter));
                                        break;
                                    }
                            }
                            break;
                        }

                    case "Solution":
                        {
                            switch (mailFilter.Field)
                            {
                                case "Language":
                                    {
                                        querySolution.Append(GetSqlClause(mailFilter));
                                        break;
                                    }
                                case "ChallengeReference":
                                    {
                                        querySolution.Append(GetSqlClause(mailFilter));
                                        break;
                                    }
                                case "SolutionState":
                                    {
                                        querySolution.Append(GetSqlClause(mailFilter));
                                        break;
                                    }
                                case "FUNC:GetScore(Solution.SolutionId,'JUDGE')":
                                    {
                                        querySolution.Append(GetSqlClause(mailFilter));
                                        break;
                                    }
                                case "FUNC:WordCount(Solution.SolutionId)":
                                    {
                                        querySolution.Append(GetSqlClause(mailFilter));
                                        break;
                                    }

                            }
                            break;
                        }




                }

            }

            foreach (MailFilter mailFilter in mailContainer.MailFilter)
            {
                switch (mailFilter.Table)
                {
                    case "&&1":
                        {
                            switch (mailFilter.Field)
                            {
                                case "UsePotentialUser":
                                    {
                                        if (mailFilter.FilterValue[0] == "0")
                                            queryPotentialUser = null;
                                        break;
                                    }
                                case "UseUser":
                                    {
                                        if (mailFilter.FilterValue[0] == "0")
                                            queryUser = null;
                                        break;
                                    }
                                case "UseOrganization":
                                    {
                                        if (mailFilter.FilterValue[0] == "0")
                                            queryOrganization = null;
                                        break;
                                    }
                                case "UseSolution":
                                    {
                                        if (mailFilter.FilterValue[0] == "0")
                                            querySolution = null;
                                        break;
                                    }

                            }
                            break;
                        }
                }
            }
            List<UserProperty> queryPotentialUserEntity = null;
            IEnumerable<PotentialUser> queryPotentialUserEntityInt = null;
            IEnumerable<UserProperty> querySolutionEntity = null;
            IEnumerable<UserProperty> queryUserEntity = null;
            IEnumerable<UserProperty> queryOrganizationEntity = null;
            if (queryPotentialUser != null)
            {

                queryPotentialUser.Insert(0, " SELECT  * FROM POTENTIALUSERS"
                                             + " where 1=1 ");
                queryPotentialUserEntityInt = ent.ExecuteStoreQuery<PotentialUser>(queryPotentialUser.ToString());
                queryPotentialUserEntity = new List<UserProperty>();
                foreach (var item in queryPotentialUserEntityInt)
                {
                    queryPotentialUserEntity.Add(new UserProperty()
                    {
                        email = item.Email,
                        FirstName = item.FirstName,
                        LastName = item.LastName

                    }

                        );
                }


            }

            if (queryUser != null)
            {

                queryUser.Insert(0, " SELECT        UserProperties.* " +
                                    " FROM UserProperties left JOIN UserPropertiesLists ON UserProperties.UserId = UserPropertiesLists.UserPropertyId"
                                    + " where 1=1 ");
                queryUserEntity = ent.ExecuteStoreQuery<UserProperty>(queryUser.ToString());

            }
            if (queryOrganization != null)
            {

                queryOrganization.Insert(0, " SELECT     UserProperties.* " +
                                            " FROM         Organization INNER JOIN UserOrganization ON Organization.OrganizationID = UserOrganization.OrganizationID " +
                                            " INNER JOIN UserProperties ON UserOrganization.UserID = UserProperties.UserId"
                                            + " where 1=1 ");
                queryOrganizationEntity = ent.ExecuteStoreQuery<UserProperty>(queryOrganization.ToString());

            }


            if (querySolution != null)
            {

                querySolution.Insert(0, " SELECT     UserProperties.* FROM         Solution INNER JOIN UserProperties ON Solution.CreatedUserId = UserProperties.UserId "
                                            + " where 1=1 ");
                querySolutionEntity = ent.ExecuteStoreQuery<UserProperty>(querySolution.ToString());

            }
            IEnumerable<UserProperty> resultfinal = queryUserEntity;


            if (queryOrganizationEntity != null)
            {
                if (resultfinal == null)
                    resultfinal = queryOrganizationEntity;
                else
                    resultfinal = resultfinal.Concat(queryOrganizationEntity);
            }

            if (querySolutionEntity != null)
            {
                if (resultfinal == null)
                    resultfinal = querySolutionEntity;
                else
                    resultfinal = resultfinal.Concat(querySolutionEntity);
            }
            if (queryPotentialUserEntity != null)
            {
                if (resultfinal == null)
                    resultfinal = queryPotentialUserEntity;
                else
                    resultfinal = resultfinal.Concat(queryPotentialUserEntity);
            }

            CampaignComponent campaign = new CampaignComponent(CampaignId);

            if (mailContainer.UserProperty.Count > 0)
            {
                if (resultfinal == null)
                    resultfinal = mailContainer.UserProperty;
                else
                    resultfinal = resultfinal.Concat(mailContainer.UserProperty).ToList();
            }



            if (resultfinal != null)
            {
                var comparer = new UserComparer();
                foreach (var item in resultfinal.Distinct(comparer).ToList())
                {
                    try
                    {
                        var user = UserController.GetUserById(portalId, item.UserId);

                        listResult.Add(getCampaignLog(campaign, item, user));

                    }
                    catch (Exception)
                    {


                    }

                }
            }



        }



        catch (Exception)
        {


        }
        return listResult;
    }


    private static CampaignLog getCampaignLog(CampaignComponent campaign, UserProperty userProperty, UserInfo user)
    {
        CampaignLog return_ = new CampaignLog();
        string mail = userProperty.email;
        if (user != null)
            mail = user.Email;
        string template = campaign.Campaign.CampaignTemplate.TemplateContent;
        if (!string.IsNullOrEmpty(template))
        {
            template = template.Replace("{USER:UserId}", userProperty.UserId.ToString());
            template = template.Replace("{USER:Agreement}", userProperty.Agreement);
            template = template.Replace("{USER:SkypeName} ", userProperty.SkypeName);
            template = template.Replace("{USER:Twitter}", userProperty.Twitter);
            template = template.Replace("{USER:FaceBook}", userProperty.FaceBook);
            template = template.Replace("{USER:Google}", userProperty.Google);
            template = template.Replace("{USER:LinkedIn}", userProperty.LinkedIn);
            template = template.Replace("{USER:OtherSocialNetwork} ", userProperty.OtherSocialNetwork);
            template = template.Replace("{USER:City}", userProperty.City);
            template = template.Replace("{USER:Region}", userProperty.Region);
            template = template.Replace("{USER:Country}", userProperty.Country);
            template = template.Replace("{USER:PostalCode}", userProperty.PostalCode);
            template = template.Replace("{USER:Telephone} ", userProperty.Telephone);
            template = template.Replace("{USER:Address}", userProperty.Address);
            template = template.Replace("{USER:FirstName}", userProperty.FirstName);
            template = template.Replace("{USER:LastName}", userProperty.LastName);
            template = template.Replace("{USER:email}", mail);
            template = template.Replace("{USER:CustomerType}", userProperty.CustomerType.ToString());
            template = template.Replace("{USER:NexsoEnrolment}", userProperty.FirstName);
            template = template.Replace("{USER:AllowNexsoNotifications}", userProperty.AllowNexsoNotifications.ToString());
            template = template.Replace("{USER:Language}", userProperty.Language.ToString());
            template = template.Replace("{USER:Latitude}", userProperty.Latitude.ToString());
            template = template.Replace("{USER:Longitude}", userProperty.Longitude.ToString());
            template = template.Replace("{USER:GoogleLocation}", userProperty.GoogleLocation);

        }
        return_.MailContent = template;

        template = campaign.Campaign.CampaignTemplate.TemplateSubject;
        if (!string.IsNullOrEmpty(template))
        {
            template = template.Replace("{USER:UserId}", userProperty.UserId.ToString());
            template = template.Replace("{USER:Agreement}", userProperty.Agreement);
            template = template.Replace("{USER:SkypeName} ", userProperty.SkypeName);
            template = template.Replace("{USER:Twitter}", userProperty.Twitter);
            template = template.Replace("{USER:FaceBook}", userProperty.FaceBook);
            template = template.Replace("{USER:Google}", userProperty.Google);
            template = template.Replace("{USER:LinkedIn}", userProperty.LinkedIn);
            template = template.Replace("{USER:OtherSocialNetwork} ", userProperty.OtherSocialNetwork);
            template = template.Replace("{USER:City}", userProperty.City);
            template = template.Replace("{USER:Region}", userProperty.Region);
            template = template.Replace("{USER:Country}", userProperty.Country);
            template = template.Replace("{USER:PostalCode}", userProperty.PostalCode);
            template = template.Replace("{USER:Telephone} ", userProperty.Telephone);
            template = template.Replace("{USER:Address}", userProperty.Address);
            template = template.Replace("{USER:FirstName}", userProperty.FirstName);
            template = template.Replace("{USER:LastName}", userProperty.LastName);
            template = template.Replace("{USER:email}", mail);
            template = template.Replace("{USER:CustomerType}", userProperty.CustomerType.ToString());
            template = template.Replace("{USER:NexsoEnrolment}", userProperty.FirstName);
            template = template.Replace("{USER:AllowNexsoNotifications}", userProperty.AllowNexsoNotifications.ToString());
            template = template.Replace("{USER:Language}", userProperty.Language.ToString());
            template = template.Replace("{USER:Latitude}", userProperty.Latitude.ToString());
            template = template.Replace("{USER:Longitude}", userProperty.Longitude.ToString());
            template = template.Replace("{USER:GoogleLocation}", userProperty.GoogleLocation);
        }
        return_.MailSubject = template;
        return_.email = mail;
        return_.userId = userProperty.UserId;
        return_.CreatedOn = DateTime.Now;
        return_.CampaignLogId = Guid.NewGuid();

        return return_;
    }

    //public static List<CampaignLog>   ProcessXmlFilter(Guid CampaignId, string trackKey, int attemp, string xmlFilter, int portalId)
    //{
    //    List<CampaignLog> listResult=new List<CampaignLog>();
    //    MailContainer mailContainer;
    //    try
    //    {
    //        mailContainer = new MailContainer();
    //        XmlSerializer serializer = new XmlSerializer(mailContainer.GetType());
    //        MemoryStream memoryStream = new MemoryStream(Encoding.ASCII.GetBytes(xmlFilter));
    //        mailContainer = (MailContainer) serializer.Deserialize(memoryStream);

    //        MIFNEXSOEntities ent = new MIFNEXSOEntities();

    //        StringBuilder queryUser = new StringBuilder();
    //        StringBuilder queryOrganizationUser = new StringBuilder();
    //        StringBuilder querySolutionUser = new StringBuilder();










    //        if (mailContainer.UserFilter.Countries.Count > 0)
    //        {
    //            queryUser.Append(" AND UserProperties.Country in (");
    //            foreach (var item in mailContainer.UserFilter.Countries)
    //            {
    //                queryUser.Append("'" + item + "',");
    //            }
    //            queryUser.Remove(queryUser.Length - 1, 1);
    //            queryUser.Append(")");
    //        }

    //        if (mailContainer.UserFilter.Languages.Count > 0)
    //        {
    //            queryUser.Append(" AND UserProperties.Language in (");
    //            foreach (var item in mailContainer.UserFilter.Languages)
    //            {
    //                queryUser.Append("" + item + ",");
    //            }
    //            queryUser.Remove(queryUser.Length - 1, 1);
    //            queryUser.Append(")");
    //        }


    //        if (mailContainer.UserFilter.Interests.Count > 0 && mailContainer.UserFilter.Beneficiaries.Count > 0)
    //        {
    //            queryUser.Append(
    //                " AND (UserPropertiesLists.Category in ('Theme','Beneficiaries') AND UserPropertiesLists.[Key] in (");
    //            foreach (var item in mailContainer.UserFilter.Interests)
    //            {
    //                queryUser.Append("'" + item + "',");
    //            }
    //            foreach (var item in mailContainer.UserFilter.Beneficiaries)
    //            {
    //                queryUser.Append("'" + item + "',");
    //            }
    //            queryUser.Remove(queryUser.Length - 1, 1);
    //            queryUser.Append("))");
    //        }
    //        else
    //        {
    //            if (mailContainer.UserFilter.Interests.Count > 0)
    //            {
    //                queryUser.Append(" AND (UserPropertiesLists.Category='Theme' AND UserPropertiesLists.[Key] in (");
    //                foreach (var item in mailContainer.UserFilter.Interests)
    //                {
    //                    queryUser.Append("'" + item + "',");
    //                }
    //                queryUser.Remove(queryUser.Length - 1, 1);
    //                queryUser.Append("))");
    //            }

    //            if (mailContainer.UserFilter.Beneficiaries.Count > 0)
    //            {
    //                queryUser.Append(
    //                    " AND (UserPropertiesLists.Category='Beneficiaries' AND UserPropertiesLists.[Key] in (");
    //                foreach (var item in mailContainer.UserFilter.Beneficiaries)
    //                {
    //                    queryUser.Append("'" + item + "',");
    //                }
    //                queryUser.Remove(queryUser.Length - 1, 1);
    //                queryUser.Append("))");
    //            }
    //        }

    //        if (mailContainer.UserFilter.AgreementNotification == "1")
    //        {
    //            queryUser.Append(
    //                " AND (UserProperties.AllowNexsoNotifications=1)");
    //        }




    //        if (mailContainer.OrganizationFilter.Countries.Count > 0)
    //        {
    //            queryOrganizationUser.Append(" AND Organization.Country in (");
    //            foreach (var item in mailContainer.OrganizationFilter.Countries)
    //            {
    //                queryOrganizationUser.Append("'" + item + "',");
    //            }
    //            queryOrganizationUser.Remove(queryOrganizationUser.Length - 1, 1);
    //            queryOrganizationUser.Append(")");
    //        }



    //        if (mailContainer.SolutionFilter.Languages.Count > 0)
    //        {
    //            querySolutionUser.Append(" AND Solution.Language in (");
    //            foreach (var item in mailContainer.SolutionFilter.Languages)
    //            {
    //                querySolutionUser.Append("'" + item + "',");
    //            }
    //            querySolutionUser.Remove(querySolutionUser.Length - 1, 1);
    //            querySolutionUser.Append(")");
    //        }

    //        IEnumerable<UserProperty> querySolutionEntity = null;
    //        IEnumerable<UserProperty> queryUserEntity = null;
    //        IEnumerable<UserProperty> queryOrganizationEntity = null;

    //        if (queryUser.Length > 0)
    //        {
    //            queryUser.Insert(0,
    //                             "SELECT     UserProperties.* FROM         UserProperties INNER JOIN UserPropertiesLists ON UserProperties.UserId = UserPropertiesLists.UserPropertyId"
    //                             + " where 1=1 ");
    //            queryUserEntity = ent.ExecuteStoreQuery<UserProperty>(queryUser.ToString());
    //        }
    //        if (queryOrganizationUser.Length > 0)
    //        {
    //            queryOrganizationUser.Insert(0, "SELECT     UserProperties.* FROM         UserOrganization INNER JOIN" +
    //                                            " Organization ON UserOrganization.OrganizationID = Organization.OrganizationID INNER JOIN" +
    //                                            " UserProperties INNER JOIN UserPropertiesLists ON UserProperties.UserId = UserPropertiesLists.UserPropertyId ON UserOrganization.UserID = UserProperties.UserId" +
    //                                            " where 1=1");
    //            querySolutionEntity = ent.ExecuteStoreQuery<UserProperty>(queryOrganizationUser.ToString());
    //        }
    //        if (querySolutionUser.Length > 0)
    //        {
    //            querySolutionUser.Insert(0, "SELECT     UserProperties.* FROM         UserPropertiesLists INNER JOIN" +
    //                                        " UserProperties ON UserPropertiesLists.UserPropertyId = UserProperties.UserId INNER JOIN" +
    //                                        " Solution ON UserProperties.UserId = Solution.CreatedUserId where 1=1");
    //            queryOrganizationEntity = ent.ExecuteStoreQuery<UserProperty>(querySolutionUser.ToString());

    //        }





    //        IEnumerable<UserProperty> resultfinal = null;

    //        if (queryUserEntity != null)
    //        {
    //            if (resultfinal == null)
    //                resultfinal = queryUserEntity;
    //            else
    //                resultfinal = resultfinal.Concat(queryUserEntity);
    //        }
    //        if (querySolutionEntity != null)
    //        {
    //            if (resultfinal == null)
    //                resultfinal = querySolutionEntity;
    //            else
    //                resultfinal = resultfinal.Concat(querySolutionEntity);
    //        }
    //        if (queryOrganizationEntity != null)
    //        {
    //            if (resultfinal == null)
    //                resultfinal = queryOrganizationEntity;
    //            else
    //                resultfinal = resultfinal.Concat(queryOrganizationEntity);
    //        }

    //        if (resultfinal != null)
    //        {
    //            var comparer = new UserComparer();

    //            foreach (var item in resultfinal.Distinct(comparer))
    //            {
    //                try
    //                {
    //                    var user = UserController.GetUserById(portalId, item.UserId);
    //                    if(user!=null)
    //                        listResult.Add(new CampaignLog() {email = user.Email, userId = item.UserId});
    //                    else
    //                        listResult.Add(new CampaignLog() { email = item.FirstName+ " (error)", userId = item.UserId });

    //                }
    //                catch (Exception)
    //                {


    //                }

    //            }
    //        }

    //        //if (mailContainer.UserFilter.Languages.Count > 0)
    //        //{
    //        //    queryUser.Append(" AND UserProperties.CustomerType in (");
    //        //    foreach (var item in mailContainer.UserFilter.CustomerTypes)
    //        //    {
    //        //        queryUser.Append("" + item + ",");
    //        //    }
    //        //    queryUser.Remove(queryUser.Length - 1, 1);
    //        //    queryUser.Append(")");
    //        //}


    //    }


    //    catch (Exception)
    //    {


    //    }
    //    return listResult;
    //}

    class UserComparer : IEqualityComparer<UserProperty>
    {
        public bool Equals(UserProperty x, UserProperty y)
        {
            if (Object.ReferenceEquals(x, null) || Object.ReferenceEquals(y, null))
                return false;
            return x.email == y.email;
        }

        // If Equals() returns true for a pair of objects 
        // then GetHashCode() must return the same value for these objects.

        public int GetHashCode(UserProperty user)
        {
            //Check whether the object is null
            if (Object.ReferenceEquals(user, null)) return 0;

            return user.email == null ? 0 : user.email.GetHashCode();
        }
    }

    public static int CreateMailLog(Guid CampaignId, string trackKey, int attemp, string content, string subject, string email, int userId, Guid CampaignLogId, DateTime createdOn)
    {
        CampaignLogComponent campaignLog = new CampaignLogComponent(CampaignLogId);
        campaignLog.CampaignLog.Attemp = attemp;
        campaignLog.CampaignLog.TrackKey = trackKey;
        campaignLog.CampaignLog.CampaignId = CampaignId;
        campaignLog.CampaignLog.email = email;
        campaignLog.CampaignLog.MailContent = content;
        campaignLog.CampaignLog.MailSubject = subject;
        campaignLog.CampaignLog.CreatedOn = createdOn;
        campaignLog.CampaignLog.userId = userId;
        campaignLog.CampaignLog.Status = "NEW";
        return campaignLog.Save();


    }

    public static int SendLog(Guid CampaignId, string trackKey, int attemp)
    {
        return 0;
    }
}

