using System;
using System.Collections.Generic;
using System.Data.Objects.DataClasses;
using System.Linq;
using System.Text;
using System.Web.UI.WebControls;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Entities.Users;
using NexsoProDAL;
using NexsoProBLL;
using Telerik.Web.UI;
using MIFWebServices;
using System.Net;
using System.Runtime.Serialization.Json;
using System.Text.RegularExpressions;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Security;

/// <summary>
/// View solutions for challenge and depending Rol view information of score and judges
/// https://www.nexso.org/es-Es/c/Gobernarte2015/scoring
/// </summary>
public partial class NZReportJudge : PortalModuleBase, IActionable
{
    #region Private Member Variables
    private int index;
    private int timeOut;
    private ChallengeComponent challengeComponent;
    private ChallengeJudgeComponent challengeJudgeComponent;
    private string orderByFormat = "";
    private string sortExpression = "";
    private List<string> challengeReferences;
    #endregion

    #region Private Properties
    #endregion

    #region Private Methods

    /// <summary>
    /// Load text to title (lblTitle)
    /// </summary>
    private void PopulateLabels()
    {
        var swJudge = false;
        // Verify if the user is judge
        if (challengeJudgeComponent.ChallengeJudge != null)
        {
            if (challengeJudgeComponent.ChallengeJudge.UserId == UserId)
            {
                if (!string.IsNullOrEmpty(challengeJudgeComponent.ChallengeJudge.FromDate.ToString()) || !string.IsNullOrEmpty(challengeJudgeComponent.ChallengeJudge.ToDate.ToString()))
                {
                    if (challengeJudgeComponent.ChallengeJudge.FromDate <= DateTime.Now && DateTime.Now <= challengeJudgeComponent.ChallengeJudge.ToDate)
                        swJudge = true;
                    else
                        if ((string.IsNullOrEmpty(challengeJudgeComponent.ChallengeJudge.FromDate.ToString()) && DateTime.Now <= challengeJudgeComponent.ChallengeJudge.ToDate) || (challengeJudgeComponent.ChallengeJudge.FromDate <= DateTime.Now && string.IsNullOrEmpty(challengeJudgeComponent.ChallengeJudge.ToDate.ToString())))
                        swJudge = true;
                }
                else
                    swJudge = true;
            }
        }

        //If the User is Administrador, NexsoSupport or Judge
        if (!(UserController.GetCurrentUserInfo().IsInRole("Administrators") || swJudge || UserController.GetCurrentUserInfo().IsInRole("NexsoSupport")))
            Response.Redirect(NexsoHelper.GetCulturedUrlByTabName("notauth"));
        lblTitle.Text = challengeComponent.Challenge.ChallengeTitle;
    }

    /// <summary>
    /// Load Information to the gridview. The judge have two categories: MOBILIZER, JUDGE-ADMIN
    /// </summary>
    private void BindData()
    {
        var filterChallenge = challengeComponent.Challenge.ChallengeReference;
        var ListJudgeAssign = challengeJudgeComponent.ChallengeJudge.JudgesAssignations;
        IQueryable<UserPropertyOrganizationSolution> OrgList;
        if (string.IsNullOrEmpty(filterChallenge))
        {
            filterChallenge = "NEXSODEFAULT";
        }
        List<UserPropertySolutionOrganization> list = new List<UserPropertySolutionOrganization>();
        bool sw = false;
        if (challengeJudgeComponent.ChallengeJudge.PermisionLevel == "JUDGE-ADMIN" || UserController.GetCurrentUserInfo().IsInRole("Administrators") || UserController.GetCurrentUserInfo().IsInRole("NexsoSupport"))
        {
            sw = true;
            this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("SolutionScoreAcumulate").Visible = true;
            btnExport.Visible = true;
            OrgList = OrganizationComponent.SearchUserPropertyOrganizationsSolutionsByName("").Where(a => (a.Solution.Deleted == false || a.Solution.Deleted == null) && a.Solution.ChallengeReference == filterChallenge && a.Solution.SolutionState >= 800);
        }
        else
        {
            if (challengeJudgeComponent.ChallengeJudge.PermisionLevel == "MOBILIZER")
            {
                sw = true;
                this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("SolutionTitle3").Visible = true;
                this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("SolutionState").Visible = true;
                this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("SolutionScores").Visible = false;
                this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("SolutionTitle").Visible = false;
                OrgList = OrganizationComponent.SearchUserPropertyOrganizationsSolutionsByName("").Where(a => (a.Solution.Deleted == false || a.Solution.Deleted == null) && a.Solution.ChallengeReference == filterChallenge);
            }
            else
            {
                OrgList = OrganizationComponent.SearchUserPropertyOrganizationsSolutionsByName("").Where(a => (a.Solution.Deleted == false || a.Solution.Deleted == null) && a.Solution.ChallengeReference == filterChallenge && a.Solution.SolutionState >= 800);
            }
            this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("SolutionScoreAcumulate").Visible = false;
            btnExport.Visible = false;
        }

        var sw2 = false;
        if (ListJudgeAssign.Count() == 0)
            sw2 = true;
        foreach (var item in OrgList)
        {
            var judgeAssignationComponent = ListJudgeAssign.FirstOrDefault(a => a.SolutionId == item.Solution.SolutionId);
            if (judgeAssignationComponent != null || sw || sw2)
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
                    SolutionScoreAcumulate = GetScore(item.Solution.SolutionId, item.Solution.ChallengeReference),
                    SolutionScores = GetScoreJudge(item.Solution.SolutionId, item.Solution.ChallengeReference, sw),
                });
            }
        }

        //Order list
        List<UserPropertySolutionOrganization> auxList = new List<UserPropertySolutionOrganization>();
        switch (orderByFormat)
        {
            // The following switch section causes an error.
            case "asc":
                switch (sortExpression)
                {
                    // The following switch section causes an error.
                    case "SolutionTitle":
                        auxList = list.OrderBy(x => x.SolutionTitle).ToList();
                        break;
                    // Add a break or other jump statement here.
                    case "OrganizationName":
                        auxList = list.OrderBy(x => x.OrganizationName).ToList();
                        break;
                    case "UserName":
                        auxList = list.OrderBy(x => x.UserName).ToList();
                        break;
                    case "UserEmail":
                        auxList = list.OrderBy(x => x.UserEmail).ToList();
                        break;
                    case "OrganizationCountry":
                        auxList = list.OrderBy(x => x.OrganizationCountry).ToList();
                        break;
                    case "SolutionScoreAcumulate":
                        auxList = list.OrderBy(x => x.SolutionScoreAcumulate).ToList();
                        break;
                    case "SolutionScores":
                        auxList = list.OrderBy(x => x.SolutionScores).ToList();
                        break;
                    case "SolutionState":
                        auxList = list.OrderBy(x => x.SolutionState).ToList();
                        break;
                    default:
                        auxList = list;
                        break;
                }
                break;

            // The following switch section causes an error.
            case "des":
                switch (sortExpression)
                {
                    case "SolutionTitle":
                        auxList = list.OrderByDescending(x => x.SolutionTitle).ToList();
                        break;
                    case "OrganizationName":
                        auxList = list.OrderByDescending(x => x.OrganizationName).ToList();
                        break;
                    case "UserName":
                        auxList = list.OrderByDescending(x => x.UserName).ToList();
                        break;
                    case "UserEmail":
                        auxList = list.OrderByDescending(x => x.UserEmail).ToList();
                        break;
                    case "OrganizationCountry":
                        auxList = list.OrderByDescending(x => x.OrganizationCountry).ToList();
                        break;
                    case "SolutionScoreAcumulate":
                        auxList = list.OrderByDescending(x => x.SolutionScoreAcumulate).ToList();
                        break;
                    case "SolutionScores":
                        auxList = list.OrderByDescending(x => x.SolutionScores).ToList();
                        break;
                    case "SolutionState":
                        auxList = list.OrderByDescending(x => x.SolutionState).ToList();
                        break;
                    default:
                        auxList = list;
                        break;
                }
                break;

            default:
                auxList = list;
                break;

        }
        grdRecentSolution.DataSource = auxList;
    }

    private void LoadSettings()
    {
        challengeReferences = new List<string>();
        if (Settings.Contains("ChallengeReference"))
        {
            if (!string.IsNullOrEmpty(Settings["ChallengeReference"].ToString()))
            {
                challengeComponent = new ChallengeComponent(Settings["ChallengeReference"].ToString());
            }
            else
            {
                challengeComponent = new ChallengeComponent();
            }
        }
        else
        {
            challengeComponent = new ChallengeComponent();
        }
        if (Settings["ChallengeReferences"] != null)
        {
            string references = Regex.Replace(Settings["ChallengeReferences"].ToString(), @"\s+", "");
            references = !string.IsNullOrEmpty(references) ? references : "";
            if (references.Contains(","))
            {
                challengeReferences = references.Split(',').ToList();
            }
            else
            {
                challengeReferences.Add(references);
            }
        }
        else
        {
            challengeReferences.Add("");
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

    /// <summary>
    /// Get score from data base: CUSTOM_XML or JUDGE
    /// </summary>
    /// <param name="solutionId"></param>
    /// <param name="challengeReference"></param>
    /// <returns>acumulate score</returns>
    protected double GetScore(Guid solutionId, string challengeReference)
    {
        double scoreGlobal = ScoreComponent.ScoreJudge.GetGlobalJudgeScoreXML(solutionId, challengeReference);
        if (challengeReferences.Contains(challengeReference))
        {
            scoreGlobal = ScoreComponent.ScoreJudge.GetGlobalAdditionalJudgeScore(solutionId, challengeReference);
        }
        if (scoreGlobal != double.MinValue)
            return Math.Round(scoreGlobal, 1);
        else
            return 0;
    }

    /// <summary>
    /// calculates the score acumulate for each solution
    /// </summary>
    /// <param name="scores"></param>
    /// <returns></returns>
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
        return Math.Round(acumulate, 1);
    }

    /// <summary>
    /// Get the score of solutions. The score may be database or XML (additional questions).
    /// </summary>
    /// <param name="solutionId"></param>
    /// <param name="challengeReference"></param>
    /// <param name="sw"></param>
    /// <returns></returns>
    protected string GetScoreJudge(Guid solutionId, string challengeReference, bool sw)
    {
        SolutionComponent solution = new SolutionComponent(solutionId);
        var scoresSolution = solution.Solution.Scores.Where(a => a.ScoreType != "CUSTOM_XML" && a.Active == true).OrderBy(x => x.UserProperty.FirstName);
        if (challengeReferences.Contains(challengeReference))
        {
            //XML score
            scoresSolution = solution.Solution.Scores.Where(a => a.ScoreType == "CUSTOM_XML" && a.Active == true && (challengeReferences.Contains(a.ChallengeReference))).OrderBy(x => x.UserProperty.FirstName);
        }
        UserPropertyComponent userPropertyComponent;
        string text = string.Empty;
        StringBuilder return_ = new StringBuilder();
        ScoreComponent.ScoreJudge scoreJudge;
        List<Int32> listUserID = new List<Int32>();
        foreach (var score in scoresSolution)
        {
            if (score.UserId == UserId || sw)
            {
                if (challengeReference == score.ChallengeReference || challengeReference == string.Empty)
                {
                    ScoreComponent scoreComponent = new ScoreComponent(solutionId, score.UserId, "CUSTOM_XML", score.ChallengeReference);
                    var user = UserController.GetUserById(PortalId, score.UserId);
                    if (scoreComponent.Score.ScoreId != Guid.Empty)
                    {
                        if (challengeReference == string.Empty)
                            scoreJudge = new ScoreComponent.ScoreJudge(solutionId, score.UserId);
                        else
                            scoreJudge = new ScoreComponent.ScoreJudge(solutionId, score.UserId, challengeReference);
                        double value = Math.Round(((scoreJudge.AbsoluteScore * 0.6) + (Convert.ToDouble(scoreComponent.Score.ComputedValue) * 0.4)), 1);
                        if (challengeReferences.Contains(solution.Solution.ChallengeReference))
                        {
                            value = Math.Round((Convert.ToDouble(scoreComponent.Score.ComputedValue)), 1);
                        }
                        if (user != null)
                            text += user.DisplayName + " (" + value.ToString() + "), ";
                        else

                            text += "Anonymous" + " (" + value.ToString() + "), ";
                    }
                    else
                    {
                        if (challengeReference == string.Empty)
                            scoreJudge = new ScoreComponent.ScoreJudge(solutionId, score.UserId);
                        else
                            scoreJudge = new ScoreComponent.ScoreJudge(solutionId, score.UserId, challengeReference);

                        if (user != null)
                            text += user.DisplayName + " (" + scoreJudge.AbsoluteScore + "), ";
                        else
                            text += "Anonymous" + " (" + scoreJudge.AbsoluteScore + "), ";
                    }
                    if (user != null)
                    {
                        listUserID.Add(user.UserID);
                    }
                }
            }
        }
        if (sw)
        {
            var listJudgesAssignation = JudgesAssignationComponent.GetJudgesPerSolution(solution.Solution.SolutionId, challengeReference).OrderBy(x => x.ChallengeJudge.UserProperty.FirstName).ToList();
            if (listJudgesAssignation.Count() > 0)
            {
                foreach (var item in listJudgesAssignation)
                {
                    var existUser = listUserID.Exists(x => x == item.ChallengeJudge.UserId);
                    if (!existUser)
                    {
                        var user = UserController.GetUserById(PortalId, item.ChallengeJudge.UserId);
                        if (user != null)
                            text += user.DisplayName + " ( - ), ";
                    }
                }
            }
        }
        if (string.IsNullOrEmpty(text))
            text = "Not Scored";
        return text;

    }

    /// <summary>
    /// extract score values
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

    protected void grdRecentSolution_PreRender(object sender, EventArgs e)
    {
        //btnExport.Visible = true;
        //GridItem[] _filterItems = grdRecentSolution.MasterTableView.GetItems(GridItemType.FilteringItem);
        //GridFilteringItem filterItem = _filterItems[0] as GridFilteringItem;
        //foreach (GridColumn column in grdRecentSolution.MasterTableView.RenderColumns)
        //{
        //    if (column.CurrentFilterFunction != GridKnownFunction.NoFilter)
        //    {
        //        btnExport.Visible = true;
        //        return;
        //    }

        //}
        //btnExport.Visible = false;
    }
    #endregion

    #region Subclasses

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

    public class Status
    {
        public int code { get; set; }
        public string status { get; set; }
    }
    #endregion

    #region Events
    protected void Page_Load(object sender, EventArgs e)
    {
        timeOut = Server.ScriptTimeout;
        Server.ScriptTimeout = 300000;
        LoadSettings();
        challengeJudgeComponent = new ChallengeJudgeComponent(UserId, challengeComponent.Challenge.ChallengeReference);
        if (!IsPostBack)
        {
            PopulateLabels();
            index = 0;
            BindData();
            grdRecentSolution.DataBind();
        }
    }
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
        sortExpression = e.SortExpression;
        GridSortExpression expression = new GridSortExpression();
        expression.FieldName = e.SortExpression;
        switch (e.NewSortOrder)
        {
            case GridSortOrder.Ascending:
                orderByFormat = "ORDER BY {0} ASC";
                expression.SortOrder = GridSortOrder.Ascending;
                orderByFormat = "asc";
                break;
            case GridSortOrder.Descending:
                orderByFormat = "ORDER BY {0} DESC";
                expression.SortOrder = GridSortOrder.Descending;
                orderByFormat = "des";
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
        this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("SolutionId").Visible = true;
        this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("SolutionTitle2").Visible = true;
        this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("OrganizationName2").Visible = true;
        this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("Row").Visible = false;
        this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("SolutionTitle").Visible = false;
        this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("SolutionTitle3").Visible = false;
        this.grdRecentSolution.MasterTableView.Columns.FindByUniqueName("OrganizationName").Visible = false;
        ConfigureExport();
        Server.ScriptTimeout = timeOut;
        grdRecentSolution.MasterTableView.ExportToExcel();
    }

    #endregion

    #region Optional Interfaces
    public ModuleActionCollection ModuleActions
    {
        get
        {
            var actions = new ModuleActionCollection
                    {
                        {
                            GetNextActionID(), DotNetNuke.Services.Localization.Localization.GetString("EditModule", LocalResourceFile), "", "", "",
                            EditUrl(), false, SecurityAccessLevel.Edit, true, false
                        }
                    };
            return actions;
        }
    }
    #endregion
}

