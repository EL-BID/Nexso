using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Services.Localization;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Security;
using NexsoProDAL;
using NexsoProBLL;
using System.Net;
using DotNetNuke.Services.Exceptions;
using DotNetNuke.Entities.Users;

/// <summary>
/// BACKEND = NexsoChimp,
/// When the user selected Campaign the sistem enable link of generate Report, in this action the sistem ejecuta this control with information of campaign
/// Link = Report
/// https://www.nexso.org/en-us/Backend/Campaign
/// </summary>
public partial class NZReportMailer : UserUserControlBase, IActionable
{
    #region Private Member Variables
    private Guid campaignId;
    private MIFNEXSOEntities mifnexsoEntities;
    #endregion

    #region Private Properties
    #endregion

    #region Private Methods

    /// <summary>
    /// Load campaignId vis query string 
    /// </summary>
    private void LoadParams()
    {
        if (!string.IsNullOrEmpty(Request.QueryString["camId"]))
        {
            try
            {
                campaignId = new Guid(Request.QueryString["camId"]);
            }
            catch (Exception e)
            {
                throw;
            }
        }
    }

    /// <summary>
    /// Campaign statistics per email status (Error, seen, sent) and country
    /// </summary>
    private void DataReportCampaign()
    {
        var listCampaignLog = CampaignLogComponent.GetCampaignLog(campaignId).ToList();
        if (listCampaignLog.Count > 0)
        {
            //Separates campaign for creation date
            var listCampaignLogGroup = listCampaignLog.GroupBy(a => a.CreatedOn);
            var report = new List<ReportCampaign>();
            foreach (var item in listCampaignLogGroup)
            {
                //Status
                var errors = item.Where(a => a.Status == "ERROR");
                var viewMails = item.Where(a => a.Status == "READ");
                var pendingViews = item.Where(a => a.Status == "SENT");
                // calculate statistics emails seen
                decimal effectiveness = 0;
                if (viewMails.ToList().Count != 0)
                    effectiveness = Convert.ToDecimal(viewMails.ToList().Count) / Convert.ToDecimal(item.ToList().Count);
                List<string> ListCountry = new List<string>();
                foreach (var item2 in viewMails.ToList())
                {
                    MailTrackerLog mailTrackerLog = MailTrackerLogComponentByCampaignLogId(item2.CampaignLogId);
                    if (mailTrackerLog != null)
                    {
                        ListCountry.Add(mailTrackerLog.Country);
                    }
                }
                //calculate statistics per cuntry: total view and percentage 
                var ListCountryGroup = ListCountry.GroupBy(a => a);
                List<GeographicView> viewGeographic = new List<GeographicView>();
                foreach (var country in ListCountryGroup)
                {
                    var viewsPercentage = (Convert.ToDecimal(country.Count()) / Convert.ToDecimal(item.Count())) * 100;
                    var countryName = country.Key;
                    if (string.IsNullOrEmpty(country.Key))
                        countryName = "NULL";
                    viewGeographic.Add(new GeographicView
                    {
                        Country = countryName,
                        TotalViews = country.Count(),
                        ViewsPercentage = decimal.Round(viewsPercentage, 2, MidpointRounding.AwayFromZero)
                    });
                }
                if (viewGeographic.Count == 0)
                    viewGeographic = null;
                else
                    viewGeographic = viewGeographic.OrderByDescending(a => a.TotalViews).ToList();
                report.Add(new ReportCampaign
                {
                    Created = Convert.ToDateTime(item.Key),
                    SentMails = item.Count(),
                    Errors = errors.Count(),
                    BouncedMail = 0,
                    ViewMails = viewMails.Count(),
                    PendingViews = pendingViews.Count(),
                    Effectiveness = decimal.Round(effectiveness, 2, MidpointRounding.AwayFromZero),
                    ViewGeographic = viewGeographic
                });
            }
            var list = report.OrderByDescending(a => a.Created).ToList();
            if (report.Count >= 10)
            {
                list = report.OrderByDescending(a => a.Created).ToList().GetRange(0, 10);
            }
            rpReport.DataSource = list;
            rpReport.DataBind();
            lblMessage.Visible = false;
        }
        else
        {
            lblMessage.Visible = true;
        }
    }
    #endregion

    #region Public Properties
    #endregion

    #region Public Methods
    /// <summary>
    /// Load information of each email sent: device type, country, city, browser
    /// </summary>
    /// <param name="CampaignLogId"></param>
    /// <returns>mailTrackerLog</returns>
    public MailTrackerLog MailTrackerLogComponentByCampaignLogId(Guid CampaignLogId)
    {
        MailTrackerLog mailTrackerLog;
        if (CampaignLogId != Guid.Empty)
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            try
            {
                mailTrackerLog = mifnexsoEntities.MailTrackerLogs.FirstOrDefault(a => a.CampaingLogId == CampaignLogId);
                if (mailTrackerLog == null)
                {
                    mailTrackerLog = new MailTrackerLog();
                    mailTrackerLog.MailTrackerLogId = Guid.Empty;
                    mifnexsoEntities.MailTrackerLogs.AddObject(mailTrackerLog);
                }
                return mailTrackerLog;
            }
            catch
            {
                return null;
            }
        }
        else
        {
            return null;
        }
    }
    #endregion

    #region Protected Methods
    #endregion

    #region Subclasses

    public class ReportCampaign
    {
        public DateTime Created { set; get; }
        public int SentMails { set; get; }
        public int Errors { set; get; }
        public int BouncedMail { set; get; }
        public int ViewMails { set; get; }
        public int PendingViews { set; get; }
        public decimal Effectiveness { set; get; }
        public List<GeographicView> ViewGeographic { set; get; }

    }

    public class GeographicView
    {
        public String Country { set; get; }
        public decimal ViewsPercentage { set; get; }
        public int TotalViews { set; get; }
    }

    #endregion

    #region Events

    /// <summary>
    /// Only available for administrator or nexso support
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            if (!UserController.GetCurrentUserInfo().IsInRole("Administrators") && !UserController.GetCurrentUserInfo().IsInRole("NexsoSupport"))
            {
                Exceptions.ProcessModuleLoadException(this, new Exception("UserID: " + UserController.GetCurrentUserInfo().UserID + " - Email: " + UserController.GetCurrentUserInfo().Email + " - " + DateTime.Now + " - Security Issue"));
                Response.Redirect("/error/403.html");
            }
        }
        LoadParams();
        if (campaignId != Guid.Empty)
        {
            DataReportCampaign();
        }
        else
        {
            lblMessage.Visible = true;
        }
    }

    /// <summary>
    /// Setup Page
    /// </summary>
    /// <param name="e"></param>
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        string FileName = System.IO.Path.GetFileNameWithoutExtension(this.AppRelativeVirtualPath);
        if (this.ID != null)
            //this will fix it when its placed as a ChildUserControl 
            this.LocalResourceFile = this.LocalResourceFile.Replace(this.ID, FileName);
        else
            // this will fix it when its dynamically loaded using LoadControl method 
            this.LocalResourceFile = this.LocalResourceFile + FileName + ".ascx.resx";
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