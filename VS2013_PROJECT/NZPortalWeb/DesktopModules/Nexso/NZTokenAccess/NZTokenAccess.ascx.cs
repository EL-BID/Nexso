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

public partial class NZTokenAccess : UserUserControlBase, IActionable
{

    #region Private Member Variables

    #endregion

    #region Private Properties
    public long SessionToken
    {
        get
        {
            if (Session["token"] != null)
            {
                return (long)Session["token"];
            }
            else
            {
                return 1;
            }
        }

        set
        {
            Session["token"] = value;
        }
    }


    #endregion

    #region Private Methods

    #endregion

    #region Public Properties



    #endregion

    #region Public Methods
    public void redirect()
    {

        Session.Timeout = 600; //10hr
        Response.Redirect(NexsoHelper.GetCulturedUrlByTabName("Home"), true);
    }


    #endregion

    #region Protected Methods
    protected void btnLogin_Click(object sender, System.EventArgs e)
    {


        if (SessionToken <= 3)
        {
            SessionToken++;

            if (txtPassword.Text == "NexsoYChapulinColorado2015")
            {
                SessionToken = 0;
                Response.Redirect(NexsoHelper.GetCulturedUrlByTabName("Home"), true);
            }

        }
        else
        {
            if (SessionToken == 4)
            {
                SessionToken = DateTime.Now.Ticks;
            }
            else
            {
                if (DateTime.Now.Ticks - SessionToken > 300000000)
                {
                    SessionToken = 1;
                }
            }
        }


        //DateTime currentTick = DateTime.Now;

        //if (SessionList[0] == "check")
        //{
        //    SessionList[0] = "1";
        //    SessionList.Add(currentTick.AddSeconds(30).ToString());
        //}
        //else if (Convert.ToInt32(SessionList[0]) < 3)
        //{
        //    SessionList[0] = (Convert.ToInt32(SessionList[0]) + 1).ToString();
        //    SessionList[1] = currentTick.AddSeconds(30).ToString();
        //}



        //if (Convert.ToInt32(SessionList[0]) >= 3 && (DateTime.Compare(Convert.ToDateTime(SessionList[1]), DateTime.Now) > 0))
        //{
        //    SessionList[0] = "3";
        //    SessionList[1] = currentTick.AddSeconds(30).ToString();
        //}
        //else if (Convert.ToInt32(SessionList[0]) >= 3 && (DateTime.Compare(Convert.ToDateTime(SessionList[1]), DateTime.Now) <= 0))
        //{
        //    SessionList[0] = "1";
        //}

    }


    #endregion

    #region Subclasses



    #endregion

    #region Events

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            Page.ClientScript.RegisterClientScriptInclude(
               this.GetType(), "NZAdmin", ControlPath + "js/NZAdmin.js");


            //if (!UserController.GetCurrentUserInfo().IsInRole("Administrators") && !UserController.GetCurrentUserInfo().IsInRole("NexsoSupport"))
            //{
            //     Exceptions.ProcessModuleLoadException(this, new Exception("UserID: " + UserController.GetCurrentUserInfo().UserID + " - Email: " + UserController.GetCurrentUserInfo().Email + " - "+ DateTime.Now + " - Security Issue"));
            //    Response.Redirect("/error/403.html");
            //}

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