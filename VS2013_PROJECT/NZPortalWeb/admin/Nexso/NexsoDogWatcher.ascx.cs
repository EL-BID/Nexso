using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

using DotNetNuke.Common;
using DotNetNuke.Common.Utilities;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Entities.Portals;
using DotNetNuke.Entities.Tabs;
using DotNetNuke.Entities.Users;
using DotNetNuke.Services.Authentication;
using DotNetNuke.Services.Exceptions;
using DotNetNuke.Services.Localization;
using DotNetNuke.Services.Social.Notifications;
using DotNetNuke.Services.Social.Messaging.Internal;
using DotNetNuke.UI.Skins;
using DotNetNuke.UI.UserControls;
using NexsoProDAL;
using NexsoProBLL;

public partial class NexsoDogWatcher : SkinObjectBase
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
       
        try
        {
            
            foreach(var item in Request.QueryString)
            {
                ValidateSecurity.ValidateString(Request.QueryString[item.ToString()], false);
                    
            }
            if (UserController.GetCurrentUserInfo().UserID >0)
            {
                if (UserController.GetCurrentUserInfo().IsInRole("Unverified Users"))
                    return;
                if (!UserController.GetCurrentUserInfo().IsSuperUser)
                {
                    UserPropertyComponent userPropertyComponent = new UserPropertyComponent(UserController.GetCurrentUserInfo().UserID);
                    if (string.IsNullOrEmpty(userPropertyComponent.UserProperty.Agreement))
                    {
                        RedirectToSing();
                        
                    }
                    
                }
            }
        }
        catch(Exception ee)
        {
            
            string ex = ee.ToString();
            if (ee.Message == "Security Issue")
                Response.Redirect("/Error/1000.html");
        }

        
    }

    private void RedirectToSing()
    {
        if (TabController.CurrentPage.FullUrl != NexsoHelper.GetCulturedUrlByTabName("registration"))
            Response.Redirect(NexsoHelper.GetCulturedUrlByTabName("registration"), false);
    }

}