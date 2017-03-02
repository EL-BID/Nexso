using DotNetNuke.Entities.Modules;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DotNetNuke.Services.Exceptions;
using NexsoProBLL;
using NexsoProDAL;

partial class DesktopModules_Nexso_NZJudgesChallenge_Edit : PortalModuleBase
{

    protected void Page_Load(System.Object sender, System.EventArgs e)
    {
        try
        {
           

        }
        catch (Exception exc) //Module failed to load
        {
            Exceptions.ProcessModuleLoadException(this, exc);
        }

    }
   
}