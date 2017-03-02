
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

public partial class NZChallenge_Settings : ModuleSettingsBase
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
            if (Settings.Contains("ChallengeReference"))
            {
                txtChallengeReference.Text = Settings["ChallengeReference"].ToString();
            }
            if (Settings.Contains("Page"))
            {
                txtPage.Text = Settings["Page"].ToString();
            }
            if (Settings.Contains("SolutionType"))
            {
                txtSolutionType.Text = Settings["SolutionType"].ToString();
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

            modules.UpdateModuleSetting(ModuleId, "ChallengeReference", txtChallengeReference.Text);
            modules.UpdateModuleSetting(ModuleId, "Page", txtPage.Text);
            modules.UpdateModuleSetting(ModuleId, "SolutionType", txtSolutionType.Text);
        
        
        }
        catch (Exception exc) //Module failed to load
        {
            Exceptions.ProcessModuleLoadException(this, exc);
        }
    }

    #endregion
   
}