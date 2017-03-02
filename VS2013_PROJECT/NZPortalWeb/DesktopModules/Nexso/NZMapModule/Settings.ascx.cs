using System.Collections.Generic;
using System;
using DotNetNuke.Services.Exceptions;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Services.Localization;
using DotNetNuke.Security;

public partial class NZMapModule_Settings : ModuleSettingsBase
{
    #region Base Method Implementations

    /// -----------------------------------------------------------------------------
    /// <summary>
    /// LoadSettings loads the settings from the Database and displays them
    /// </summary>
    /// -----------------------------------------------------------------------------
    public override void LoadSettings()
    {
        try
        {
            if (Page.IsPostBack == false)
            {
                //Check for existing settings and use those on this page
                //Settings["SettingName"]

                /* uncomment to load saved settings in the text boxes
                if(Settings.Contains("Setting1"))
                    txtSetting1.Text = Settings["Setting1"].ToString();
			
                if (Settings.Contains("Setting2"))
                    txtSetting2.Text = Settings["Setting2"].ToString();

                */



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
