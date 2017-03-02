using System;
using System.Web;
using DotNetNuke.Common;
using DotNetNuke.Common.Utilities;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Entities.Users;
using DotNetNuke.Entities.Users.Membership;
using DotNetNuke.Instrumentation;
using DotNetNuke.Security;
using DotNetNuke.Security.Membership;
using DotNetNuke.Services.Localization;
using DotNetNuke.Services.Log.EventLog;
using DotNetNuke.Security;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Services.Exceptions;

/// <summary>
/// This control is for Changes Password of user
/// https://www.nexso.org/en-us/My-Nexso/userId/35794
/// </summary>
public partial class NZChangePassword : UserUserControlBase, IActionable
{

    #region Private Member Variables
    private string _ipAddress;
    private UserInfo currentUser = null;
    #endregion

    #region Private Properties


    #endregion

    #region Private Methods

    /// <summary>
    /// Load validation message
    /// </summary>
    private void PopulateLabels()
    {
        rgvPassword.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
    }

    /// <summary>
    /// Redirected to the previous page
    /// </summary>
    protected void RedirectAfterLogin()
    {

        var setting = GetSetting(PortalId, "Redirect_AfterLogin");

        if (Convert.ToInt32(setting) == Null.NullInteger)
        {
            if (Request.QueryString["returnurl"] != null)
            {
                Response.Redirect(Request.QueryString["returnurl"].ToString());
            }
            else
            {
                Response.Redirect(Globals.NavigateURL(PortalSettings.HomeTabId));
            }

        }
    }

    private void LogSuccess()
    {
        LogResult(string.Empty);
    }

    private void LogFailure(string reason)
    {
        LogResult(reason);
    }

    /// <summary>
    /// Register in the log if the email was sent
    /// </summary>
    /// <param name="message"></param>
    private void LogResult(string message)
    {
        var portalSecurity = new PortalSecurity();

        var objEventLog = new EventLogController();
        var objEventLogInfo = new LogInfo();

        objEventLogInfo.AddProperty("IP", _ipAddress);
        objEventLogInfo.LogPortalID = PortalSettings.PortalId;
        objEventLogInfo.LogPortalName = PortalSettings.PortalName;
        objEventLogInfo.LogUserID = currentUser.UserID;
        objEventLogInfo.LogUserName = portalSecurity.InputFilter(currentUser.Username,
                                                               PortalSecurity.FilterFlag.NoScripting | PortalSecurity.FilterFlag.NoAngleBrackets | PortalSecurity.FilterFlag.NoMarkup);
        if (string.IsNullOrEmpty(message))
        {
            objEventLogInfo.LogTypeKey = "PASSWORD_SENT_SUCCESS";
        }
        else
        {
            objEventLogInfo.LogTypeKey = "PASSWORD_SENT_FAILURE";
            objEventLogInfo.LogProperties.Add(new LogDetailInfo("Cause", message));
        }

        objEventLog.AddLog(objEventLogInfo);
    }

    #endregion

    #region Public Properties



    #endregion

    #region Public Methods




    #endregion

    #region Subclasses



    #endregion

    #region Events

    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //Add action click to cmdChangePassword
        cmdChangePassword.Click += cmdChangePassword_Click;
        PopulateLabels();
        if (Request.QueryString["returnurl"] != null)
        {
            hlCancel.NavigateUrl = Request.QueryString["returnurl"];
        }
        else
        {
            hlCancel.NavigateUrl = Globals.NavigateURL();
        }
    }

    /// <summary>
    /// Load setting of the module
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



    private void cmdChangePassword_Click(object sender, EventArgs e)
    {
        try
        {
            currentUser = UserController.GetCurrentUserInfo();
            //1. Check New Password and Confirm are the same
            if (ValidateSecurity.ValidateString(txtPassword.Text, false) != ValidateSecurity.ValidateString(txtConfirmPassword.Text, false))
            {
                resetMessages.Visible = true;
                var failed = Localization.GetString("PasswordMismatch", LocalResourceFile);
                LogFailure(failed);
                lblHelp.Text = failed;
                return;
            }
            try
            {
                // Fail: No match password
                if (UserController.ChangePassword(currentUser, txtOldPassword.Text, txtPassword.Text) == false)
                {
                    resetMessages.Visible = true;
                    var failed = Localization.GetString("FailedAttempt", LocalResourceFile);
                    LogFailure(failed);
                    lblHelp.Text = failed;
                }
                else
                {
                    LogSuccess();
                    var loginStatus = UserLoginStatus.LOGIN_FAILURE;
                    UserController.UserLogin(PortalSettings.PortalId, currentUser.Username, txtPassword.Text, "", "", "", ref loginStatus, false);
                    pChangePassword.Visible = false;
                    pMessage.Visible = true;
                }
            }
            catch
            {
                resetMessages.Visible = true;
                var failed = Localization.GetString("FailedAttempt", LocalResourceFile);
                LogFailure(failed);
                lblHelp.Text = failed;
            }
        }
        catch (Exception exc)
        {
            Exceptions.
                ProcessModuleLoadException(
                this, exc);
        }
    }

    protected void btnClose_Click(object sender, EventArgs e)
    {
        RedirectAfterLogin();
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