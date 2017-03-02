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

public partial class NZAdmin : UserUserControlBase, IActionable
{

    #region Private Member Variables

    #endregion

    #region Private Properties


    #endregion

    #region Private Methods

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
    /// Load configuration to the module
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            Page.ClientScript.RegisterClientScriptInclude(
               this.GetType(), "NZAdmin", ControlPath + "js/NZAdmin.js");


            if (!UserController.GetCurrentUserInfo().IsInRole("Administrators") && !UserController.GetCurrentUserInfo().IsInRole("NexsoSupport"))
            {
                 Exceptions.ProcessModuleLoadException(this, new Exception("UserID: " + UserController.GetCurrentUserInfo().UserID + " - Email: " + UserController.GetCurrentUserInfo().Email + " - "+ DateTime.Now + " - Security Issue"));
                Response.Redirect("/error/403.html");
            }
           
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