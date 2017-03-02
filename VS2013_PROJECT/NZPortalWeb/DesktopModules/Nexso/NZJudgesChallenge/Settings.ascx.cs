
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

public partial class NZJudgesChallenge_Settings : ModuleSettingsBase
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
            var modules = new ModuleController();

          
        }
        catch (Exception exc) //Module failed to load
        {
            Exceptions.ProcessModuleLoadException(this, exc);
        }
    }

    #endregion
   
}