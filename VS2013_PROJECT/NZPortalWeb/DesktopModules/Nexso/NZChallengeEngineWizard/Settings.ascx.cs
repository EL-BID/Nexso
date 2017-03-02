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

public partial class NZChallengeEngineWizard_Settings : ModuleSettingsBase
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
