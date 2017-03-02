using System;
using System.Collections.Generic;
using System.Data.Objects.DataClasses;
using System.Linq;
using System.Text;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Entities.Users;
using NexsoProDAL;
using NexsoProBLL;
using Telerik.Web.UI;
using MIFWebServices;
using System.Net;
using System.Runtime.Serialization.Json;

/// <summary>
/// BACKEND
/// Get List of solutions. This is a grid but not edition, only read and sport document in other words this is reports.
/// This Uses NZAdmi.js
/// </summary>
public partial class SolutionListAdminControl : PortalModuleBase
{
    #region Private Member Variables
    private int index;
    private int timeOut;
    #endregion

    #region Private Properties


    #endregion

    #region Private Methods
    /// <summary>
    ///Select and load information to the gridview.
    /// </summary>
    private void BindData()
    {
        try
        {
            var OrgList = OrganizationComponent.SearchUserPropertyOrganizationsSolutionsByName("").Where(a => a.Solution.Deleted == false || a.Solution.Deleted == null);
            List<UserPropertySolutionOrganization> list = new List<UserPropertySolutionOrganization>();
            foreach (var item in OrgList)
            {
                if (item.UserProperty != null && item.Solution != null && item.Organization != null)
                {
                    list.Add(new UserPropertySolutionOrganization
                    {
                        Row = GetIndex(),
                        SolutionId = item.Solution.SolutionId,
                        UserId = item.UserProperty.UserId,
                        OrganizationId = item.Organization.OrganizationID,
                        UserName = item.UserProperty.FirstName + " " + item.UserProperty.LastName,
                        UserEmail = item.UserProperty.email,
                        SolutionTitle = item.Solution.Title,
                        OrganizationName = item.Organization.Name,
                        SolutionState = Convert.ToInt32(item.Solution.SolutionState),
                        SolutionDateCreated = Convert.ToDateTime(item.Solution.DateCreated),
                        SolutionDateUpdated = Convert.ToDateTime(item.Solution.DateUpdated),
                        OrganizationCountry = item.Organization.Country,
                        OrganizationRegion = item.Organization.Region,
                        OrganizationCity = item.Organization.City,
                        SolutionLanguage = item.Solution.Language,
                        SolutionChallengeReference = item.Solution.ChallengeReference,
                        SolutionScoreAcumulate = GetScore(item.Solution.Scores),
                        //Score per solution
                        SolutionScores = GetScoreJudge(item.Solution.Scores),
                    });

                }
            }

            grdRecentSolution.DataSource = list;
        }
        catch
        {

        }
    }
    #endregion

    #region Public Properties



    #endregion

    #region Public Methods
    /// <summary>
    /// Get all countries around the world
    /// </summary>
    /// <returns></returns>
    public List<Country> BindCountry()
    {

        try
        {
            string WURL = System.Configuration.ConfigurationManager.AppSettings["MifWebServiceUrl"].ToString();
            string url = WURL + "/countries";
            WebRequest request = WebRequest.Create(url);
            WebResponse ws = request.GetResponse();
            DataContractJsonSerializer jsonSerializer = new DataContractJsonSerializer(typeof(List<Country>));
            List<Country> photos = (List<Country>)jsonSerializer.ReadObject(ws.GetResponseStream());
            var country = new Country();
            country.code = "%NULL%";
            country.country = "No Filter";
            photos.Insert(0, country);
            country = new Country();
            country.code = string.Empty;
            country.country = "Empty";
            photos.Insert(1, country);
            return photos;
        }
        catch (Exception x)
        {
            return null;
        }

    }

    /// <summary>
    /// Change the status code to text (Column grid)
    /// </summary>
    /// <returns></returns>
    public List<Status> BindStatus()
    {
        List<Status> list = new List<Status>();

        var status = new Status();
        status.code = -1;
        status.status = "No Filter";
        list.Insert(0, status);
        status = new Status();
        status.code = 0;
        status.status = "Draft";
        list.Insert(1, status);
        status = new Status();
        status.code = 800;
        status.status = "Published";
        list.Insert(2, status);

        return list;

    }

    /// <summary>
    /// Configuration for export to excel
    /// </summary>
    public void ConfigureExport()
    {

        grdRecentSolution.ExportSettings.ExportOnlyData = true;
        grdRecentSolution.ExportSettings.IgnorePaging = true;
        grdRecentSolution.ExportSettings.OpenInNewWindow = true;
        grdRecentSolution.ExportSettings.UseItemStyles = true;
        grdRecentSolution.ExportSettings.FileName = string.Format("ReportSolutionList_{0}", DateTime.Now);


    }


    public string UrlEscore(string SolutionId, int Status)
    {

        string Url = NexsoHelper.GetCulturedUrlByTabName("solprofile") + "/sl/" + SolutionId;

        if (Status >= 800)
            Url = NexsoHelper.GetCulturedUrlByTabName("solprofilescore") + "/sl/" + SolutionId;
        return Url;
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="value"></param>
    /// <returns>Status of the solution</returns>
    public string GetValueSolutionState(string value)
    {
        if (string.IsNullOrEmpty(value))
            return "";
        if (value == "0 799")

            return "0";


        return "800";
    }
    #endregion

    #region Protected Methods
    protected int GetIndex()
    {
        index++;
        return index;
    }

    /// <summary>
    /// Change the status code to text (Column grid)
    /// </summary>
    /// <param name="index"></param>
    /// <returns></returns>
    protected string GetStatus(int index)
    {
        if (index >= 800)
            return "Published";
        return "Draft";
    }


    /// <summary>
    /// 
    /// </summary>
    /// <param name="userdId"></param>
    /// <returns>Email of the user with the userID</returns>
    protected string GetUserEmail(int? userdId)
    {
        if (userdId.HasValue)
        {
            var user = UserController.GetUserById(PortalId, userdId.Value);
            if (user != null)
                return user.Email;
        }
        return "Deleted User";

    }


    /// <summary>
    /// Nexso location of the user
    /// </summary>
    /// <param name="country"></param>
    /// <param name="region"></param>
    /// <param name="city"></param>
    /// <returns>String  with the location</returns>
    protected string GetNexsoLocation(string country, string region, string city)
    {

        string return_ = string.Empty;
        try
        {
            if (!string.IsNullOrEmpty(country))
            {

                return_ = return_ + MIFWebServices.LocationService.GetCountryName(country);

                if (string.IsNullOrEmpty(return_))
                    return_ = return_ + country.ToUpper();
            }
            else
            {
                return_ = return_ + " empty ";
            }
            if (!String.IsNullOrEmpty(region))
            {
                try
                {
                    return_ = return_ + " " + MIFWebServices.LocationService.GetStateName(Convert.ToInt32(region));

                }
                catch (Exception)
                {

                    return_ = return_ + " " + region;
                }
            }
            else
            {
                return_ = return_ + " empty ";
            }

            if (!String.IsNullOrEmpty(city))
            {
                try
                {
                    return_ = return_ + " " + MIFWebServices.LocationService.GetCityName(Convert.ToInt32(city));

                }
                catch (Exception)
                {

                    return_ = return_ + " " + city;
                }
            }
            else
            {
                return_ = return_ + " empty ";
            }
        }
        catch (Exception e)
        {
            return_ = " empty error";
        }
        return return_;

    }
    protected double GetScore(object scores)
    {
        EntityCollection<Score> scoreList = (EntityCollection<Score>)scores;
        double acumulate = 0;
        if (scoreList.Count > 0)
        {
            foreach (var score in scoreList)
            {
                acumulate += score.ComputedValue.GetValueOrDefault(0);
            }

            acumulate = acumulate / scoreList.Count;

        }

        return acumulate;
    }

    /// <summary>
    /// Get score from data base: from table [Scores] JUDGE
    /// </summary>
    /// <param name="scores"></param>
    /// <returns></returns>
    protected string GetScoreJudge(object scores)
    {
        EntityCollection<Score> scoreList = (EntityCollection<Score>)scores;

        string text = "";
        StringBuilder return_ = new StringBuilder();

        double acumulate = 0;

        if (scoreList.Count > 0)
        {
            foreach (var score in scoreList)
            {
                var user = UserController.GetUserById(PortalId, score.UserId);
                if (user != null)
                {
                    text += user.DisplayName + " (" + score.ComputedValue + "), ";

                }
                else
                {
                    text += "Anonymous" + " (" + score.ComputedValue + "), ";

                }
            }

        }
        else
        {
            text = "Not Scored";

        }
        return text;
    }
    #endregion

    #region Subclasses

    public class Status
    {
        public int code { get; set; }
        public string status { get; set; }
    }
    public class UserPropertySolutionOrganization
    {
        public int Row { set; get; }
        public Guid SolutionId { set; get; }
        public int UserId { set; get; }
        public Guid OrganizationId { set; get; }
        public string UserName { set; get; }
        public string UserEmail { set; get; }
        public string SolutionTitle { set; get; }
        public string OrganizationName { set; get; }
        public int SolutionState { set; get; }
        public DateTime SolutionDateCreated { set; get; }
        public DateTime SolutionDateUpdated { set; get; }
        public string OrganizationCountry { set; get; }
        public string OrganizationRegion { set; get; }
        public string OrganizationCity { set; get; }
        public string SolutionLanguage { set; get; }
        public string SolutionChallengeReference { set; get; }
        public double SolutionScoreAcumulate { set; get; }
        public string SolutionScores { set; get; }


    }
    #endregion

    #region Events
    protected void Page_Load(object sender, EventArgs e)
    {
        timeOut = Server.ScriptTimeout;
        Server.ScriptTimeout = 300000;
        if (!IsPostBack)
        {
            index = 0;
            BindData();
            grdRecentSolution.DataBind();
            this.grdRecentSolution.Columns[5].Visible = false;
        }
    }

    /// <summary>
    /// Bind all data in grid
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RadGrid1_NeedDataSource(object sender, GridNeedDataSourceEventArgs e)
    {
        BindData();
    }

    /// <summary>
    /// Sort order action (grid)
    /// </summary>
    /// <param name="source"></param>
    /// <param name="e"></param>
    protected void grdRecentSolution_SortCommand(object source, GridSortCommandEventArgs e)
    {
        string orderByFormat = string.Empty;
        switch (e.NewSortOrder)
        {
            case GridSortOrder.Ascending:
                orderByFormat = "ORDER BY {0} ASC";
                break;
            case GridSortOrder.Descending:
                orderByFormat = "ORDER BY {0} DESC";
                break;
        }
        e.Item.OwnerTableView.Rebind();
    }

    /// <summary>
    /// Export result to excel
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnExport_Click(object sender, EventArgs e)
    {

        if (ckbScoreMode.Checked)
        {
            this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("SolutionId").Visible = false;
            this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("SolutionIDScore").Visible = true;
        }
        else
        {
            this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("SolutionId").Visible = true;
            this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("SolutionIDScore").Visible = false;
        }
        this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("SolutionTitle2").Visible = true;
        this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("OrganizationName2").Visible = true;
        this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("Row").Visible = false;
        this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("SolutionTitle").Visible = false;
        this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("SolutionTitleScore").Visible = false;
        this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("OrganizationName").Visible = false;
        ConfigureExport();
        Server.ScriptTimeout = timeOut;
        grdRecentSolution.MasterTableView.ExportToExcel();
    }

    /// <summary>
    /// Change vizualization score mode
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ckbScoreMode_CheckedChanged(object sender, EventArgs e)
    {
        if (ckbScoreMode.Checked == true)
        {
            this.grdRecentSolution.Columns[6].Visible = false;
            this.grdRecentSolution.Columns[5].Visible = true;
        }
        else
        {
            this.grdRecentSolution.Columns[6].Visible = true;
            this.grdRecentSolution.Columns[5].Visible = false;
        }
        grdRecentSolution.Rebind();
    }

    protected void grdRecentSolution_PreRender(object sender, EventArgs e)
    {
        btnExport.Visible = true;
    }
    #endregion

}