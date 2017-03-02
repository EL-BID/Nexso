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

partial class DesktopModules_Nexso_NXZSolutionWizard_Edit : PortalModuleBase
{

    private ChallengeCustomDataComponent challengeCustomDataComponent;
    private ChallengeComponent challengeComponent;
    private string Language = System.Globalization.CultureInfo.CurrentUICulture.Name;
    protected void Page_Load(System.Object sender, System.EventArgs e)
    {
        try
        {
           
            

            if (!IsPostBack)
            {
                if (Settings.Contains("Template"))
                {
                    txtHtmlTemplate.Text=Settings["Template"].ToString();
                }
            }

        }
        catch (Exception exc) //Module failed to load
        {
            Exceptions.ProcessModuleLoadException(this, exc);
        }

    }
    protected void btnSaveTemplateTemplate_Click(object sender, EventArgs e)
    {
        try
        {
            var modules = new ModuleController();

            modules.UpdateModuleSetting(ModuleId, "Template", txtHtmlTemplate.Text);
           
        }
        catch (Exception exc) //Module failed to load
        {
            Exceptions.ProcessModuleLoadException(this, exc);
        }
    }
}