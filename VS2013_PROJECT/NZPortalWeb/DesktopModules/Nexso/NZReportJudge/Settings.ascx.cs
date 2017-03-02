using System.Collections.Generic;
using System;
using DotNetNuke.Services.Exceptions;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Services.Localization;
using DotNetNuke.Security;
using NexsoProBLL;
using NexsoProDAL;
using System.Threading;
using DotNetNuke.Services.Localization;

public partial class NZReportJudge_Settings : ModuleSettingsBase
{
    #region Base Method Implementations
    protected string Language = System.Globalization.CultureInfo.CurrentUICulture.Name;
    protected ChallengeComponent challengeComponent;
    protected string challengeReferences;
    /// -----------------------------------------------------------------------------
    /// <summary>
    /// LoadSettings loads the settings from the Database and displays them
    /// </summary>
    /// -----------------------------------------------------------------------------
    public override void LoadSettings()
    {
        try
        {
            if (Settings.Contains("ChallengeReference"))
            {
                challengeComponent = new ChallengeComponent(Settings["ChallengeReference"].ToString());
            }
            else
            {
                challengeComponent = new ChallengeComponent();
            }

            if (Settings.Contains("ChallengeReferences"))
            {
                challengeReferences =  (Settings["ChallengeReferences"].ToString());
            }
            else
            {
                challengeReferences = "";
            }


            if (Page.IsPostBack == false)
            {
                if (Settings.Contains("ChallengeReference"))
                {
                    txtChallengeReference.Text = Settings["ChallengeReference"].ToString();
                }
                if (Settings.Contains("ChallengeReferences"))
                {
                    txtChallengeReferences.Text = Settings["ChallengeReferences"].ToString();
                }
            }
        }
        catch (Exception exc) //Module failed to load
        {
            Exceptions.ProcessModuleLoadException(this, exc);
        }
    }

    /// -----------------------------------------------------------------------------
    /// <summary>
    /// UpdateSettings saves the modified settings to the Database
    /// </summary>
    /// -----------------------------------------------------------------------------
    public override void UpdateSettings()
    {
        try
        {
            ModuleController modules = new ModuleController();
            if (!string.IsNullOrEmpty(txtChallengeReference.Text))
            {
                challengeComponent = new ChallengeComponent(txtChallengeReference.Text);
            }
            else
            {
                challengeComponent = new ChallengeComponent();
            }

            if (!string.IsNullOrEmpty(txtChallengeReferences.Text))
            {
                challengeReferences = txtChallengeReferences.Text;
            }
            else
            {
                challengeReferences = "";
            }


            modules.UpdateModuleSetting(ModuleId, "ChallengeReference", txtChallengeReference.Text);
            modules.UpdateModuleSetting(ModuleId, "ChallengeReferences", txtChallengeReferences.Text);
            //the following are two sample Module Settings, using the text boxes that are commented out in the ASCX file.
            //module settings
            //modules.UpdateModuleSetting(ModuleId, "Setting1", txtSetting1.Text);
            //modules.UpdateModuleSetting(ModuleId, "Setting2", txtSetting2.Text);

            //tab module settings
            //modules.UpdateTabModuleSetting(TabModuleId, "Setting1",  txtSetting1.Text);
            //modules.UpdateTabModuleSetting(TabModuleId, "Setting2",  txtSetting2.Text);
        }
        catch (Exception exc) //Module failed to load
        {
            Exceptions.ProcessModuleLoadException(this, exc);
        }
    }

    #endregion

}
