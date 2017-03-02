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
/// BACKEND
/// This control are inside in wizard NZMailer, in the step Preview
/// </summary>
public partial class NZMailerPreview : UserUserControlBase, IActionable
{

    #region Private Member Variables
    private Guid CampaingLogId;
    private CampaignLog campaingLog;
    #endregion

    #region Private Properties


    #endregion

    #region Private Methods
    private string getSubject()
    {
        return "No content";
    }
    private string getBody()
    {
        return "";
    }

    /// <summary>
    /// Load CampaingLogId
    /// </summary>
    private void LoadParams()
    {
        if (CampaingLogId == Guid.Empty)
        {
            if (Request.QueryString["nx"] != string.Empty)
                try
                {
                    CampaingLogId = new Guid(Request.QueryString["nx"]);
                }
                catch
                {
                    CampaingLogId = Guid.Empty;
                }
            else
                CampaingLogId = Guid.Empty;
        }
    }

    /// <summary>
    /// load the campaign through a CampaingLogId
    /// </summary>
    private void LoadObjects()
    {
        if (CampaingLogId != Guid.Empty)
        {
            if (Session["MailPreview"] != null)
            {
                var obj = (List<CampaignLog>)Session["MailPreview"];
                campaingLog = obj.FirstOrDefault(a => a.CampaignLogId == CampaingLogId);
            }
            else
            {
                var cmm = new CampaignLogComponent(CampaingLogId);
                campaingLog = cmm.CampaignLog;
            }
        }
    }
    #endregion

    #region Public Properties



    #endregion

    #region Public Methods


    #endregion

    #region Protected Methods


    #endregion

    #region Subclasses



    #endregion

    #region Events
    /// <summary>
    /// Load Preview
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
        LoadObjects();
        //Load the content to the controls
        if (campaingLog != null)
        {
            ltContent.Text = campaingLog.MailContent;
            lblSubject.Text = campaingLog.MailSubject;
        }
        else
        {
            lblSubject.Text = getSubject();
            ltContent.Text = getBody();
        }
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