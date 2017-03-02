using System.Collections.Generic;
using System;
using DotNetNuke.Services.Exceptions;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Services.Localization;
using DotNetNuke.Security;

public partial class NZSolutionScoreMode_Settings : ModuleSettingsBase
{
    #region Base Method Implementations
    protected string challengeReference;
    protected string challengeReferences;
    protected string challengeComments;
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
                challengeReference = (Settings["ChallengeReference"].ToString());
            }
            else
            {
                challengeReference = "";
            }

            if (Settings.Contains("ChallengeReferences"))
            {
                challengeReferences = (Settings["ChallengeReferences"].ToString());
            }
            else
            {
                challengeReferences = "";
            }

            if (Settings.Contains("commentReference"))
            {
                challengeComments = (Settings["commentReference"].ToString());
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

                if (Settings.Contains("commentReference"))
                {
                    txtChallengeComments.Text = Settings["commentReference"].ToString();
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

            //the following are two sample Module Settings, using the text boxes that are commented out in the ASCX file.
            //module settings
            if (!string.IsNullOrEmpty(txtChallengeReference.Text))
            {
                challengeReference = txtChallengeReference.Text;
            }
            else
            {
                challengeReference = "";
            }

            if (!string.IsNullOrEmpty(txtChallengeReferences.Text))
            {
                challengeReferences = txtChallengeReferences.Text;
            }
            else
            {
                challengeReferences = "";
            }

            if (!string.IsNullOrEmpty(txtChallengeComments.Text))
            {
                challengeComments = txtChallengeComments.Text;
            }
            else
            {
                challengeComments = "";
            }

            //tab module settings
            modules.UpdateModuleSetting(ModuleId, "ChallengeReference", txtChallengeReference.Text);
            modules.UpdateModuleSetting(ModuleId, "ChallengeReferences", txtChallengeReferences.Text);
            modules.UpdateModuleSetting(ModuleId, "commentReference", txtChallengeComments.Text);
        }
        catch (Exception exc) //Module failed to load
        {
            Exceptions.ProcessModuleLoadException(this, exc);
        }
    }

    #endregion

}
