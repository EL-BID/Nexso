using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Services.Exceptions;

public partial class NZSocialMediaSharingModule_Edit : PortalModuleBase
{
    protected void Page_Load(object sender, EventArgs e)
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