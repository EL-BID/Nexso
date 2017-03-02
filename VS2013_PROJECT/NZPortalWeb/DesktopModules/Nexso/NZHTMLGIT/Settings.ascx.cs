using System.Collections.Generic;
using System;
using DotNetNuke.Services.Exceptions;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Services.Localization;
using DotNetNuke.Security;

public partial class NZHTMLGIT_Settings : ModuleSettingsBase
{
    #region Base Method Implementations
    protected string Language = System.Globalization.CultureInfo.CurrentUICulture.Name;
   

    /// -----------------------------------------------------------------------------
    /// <summary>
    /// LoadSettings loads the settings from the Database and displays them
    /// </summary>
    /// -----------------------------------------------------------------------------
    public override void LoadSettings()
    {
        try
        {

            if (Settings.Contains("AccessToken"))
            {
                txtAccessToken.Text = Settings["AccessToken"].ToString();
            }
            if (Settings.Contains("Repo"))
            {
                txtRepo.Text = Settings["Repo"].ToString();
            }
            if (Settings.Contains("Content"))
            {
                txtContent.Text = Settings["Content"].ToString();
            }
            if (Settings.Contains("Branch"))
            {
                txtBranch.Text = Settings["Branch"].ToString();
            }
            if (Settings.Contains("Cache"))
            {
                chkCache.Checked = Convert.ToBoolean( Settings["Cache"].ToString());
            }
            if (Settings.Contains("Localization"))
            {
                chkLocalization.Checked = Convert.ToBoolean(Settings["Localization"].ToString());
            }
            if (Settings.Contains("Proxy"))
            {
                txtProxy.Text = Settings["Proxy"].ToString();
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
          

            var modules = new ModuleController();


            modules.UpdateModuleSetting(ModuleId, "AccessToken", txtAccessToken.Text);
            modules.UpdateModuleSetting(ModuleId, "Repo", txtRepo.Text);
            modules.UpdateModuleSetting(ModuleId, "Content", txtContent.Text);
            modules.UpdateModuleSetting(ModuleId, "Branch", txtBranch.Text);
            modules.UpdateModuleSetting(ModuleId, "Cache", chkCache.Checked.ToString());
            modules.UpdateModuleSetting(ModuleId, "Localization", chkLocalization.Checked.ToString());
            modules.UpdateModuleSetting(ModuleId, "Proxy", txtProxy.Text);

        }
        catch (Exception exc) //Module failed to load
        {
            Exceptions.ProcessModuleLoadException(this, exc);
        }
    }

    #endregion


   

}
