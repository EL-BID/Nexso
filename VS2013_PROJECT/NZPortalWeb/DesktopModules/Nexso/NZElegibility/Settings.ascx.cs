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

public partial class NZElegibility_Settings : ModuleSettingsBase
{
    #region Base Method Implementations
    protected string Language = System.Globalization.CultureInfo.CurrentUICulture.Name;
    protected ChallengeCustomDataComponent challengeCustomDataComponent;

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
                challengeCustomDataComponent = new ChallengeCustomDataComponent(Settings["ChallengeReference"].ToString(), Language);
            else
                challengeCustomDataComponent = new ChallengeCustomDataComponent();

            if (Page.IsPostBack == false)
            {
                //Check for existing settings and use those on this page
                //Settings["SettingName"]

                if (Settings.Contains("ChallengeReference"))
                    txtChallengeReference.Text = Settings["ChallengeReference"].ToString();

                if (Settings.Contains("RedirectPage"))
                    txtRedirectPage.Text = Settings["RedirectPage"].ToString();

                if (Settings.Contains("ButtonText"))
                    txtButtonText.Text = Settings["ButtonText"].ToString();

                fillData();
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

            //the following are two sample Module Settings, using the text boxes that are commented out in the ASCX file.
            //module settings
            modules.UpdateModuleSetting(ModuleId, "RedirectPage", txtRedirectPage.Text);
            modules.UpdateModuleSetting(ModuleId, "ButtonText", txtButtonText.Text);
            modules.UpdateModuleSetting(ModuleId, "ChallengeReference", txtChallengeReference.Text);

            challengeCustomDataComponent = new ChallengeCustomDataComponent(Settings["ChallengeReference"].ToString(), Language);
            SaveChallengeCustomData();

        }
        catch (Exception exc) //Module failed to load
        {
            Exceptions.ProcessModuleLoadException(this, exc);
        }
    }

    #endregion

    //Load EligibilityTemplate in RadEditorTemplate
    private void fillData()
    {
        if (challengeCustomDataComponent != null)
        {
            if (challengeCustomDataComponent.ChallengeCustomData.EligibilityTemplate != null)
            {
                RadEditorTemplate.RichText.Text = string.Empty;
                RadEditorTemplate.BasicTextEditor.Text = string.Empty;
                RadEditorTemplate.Text = challengeCustomDataComponent.ChallengeCustomData.EligibilityTemplate;

            }
        }
    }

    //Save RadEditorTemplate text in the field EligibilityTemplate
    private void SaveChallengeCustomData()
    {
        if (Settings.Contains("ChallengeReference"))
        {
            if (challengeCustomDataComponent.ChallengeCustomData.ChallengeCustomDatalId == Guid.Empty)
            {
                challengeCustomDataComponent.ChallengeCustomData.Language = Language;
                challengeCustomDataComponent.ChallengeCustomData.ChallengeReference = Settings["ChallengeReference"].ToString();

            }

            if (RadEditorTemplate.Text != string.Empty)
            {
                challengeCustomDataComponent.ChallengeCustomData.EligibilityTemplate = RadEditorTemplate.Text;
                challengeCustomDataComponent.Save();
            }
        }
    }
}