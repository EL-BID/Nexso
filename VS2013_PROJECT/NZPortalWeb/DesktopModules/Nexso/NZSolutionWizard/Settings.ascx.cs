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
using System.Threading;
using DotNetNuke.Services.Localization;

public partial class NZSolutionWizard_Settings : ModuleSettingsBase
{
    #region Base Method Implementations
    protected string Language = System.Globalization.CultureInfo.CurrentUICulture.Name;
    protected ChallengeComponent challengeComponent;

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
                challengeComponent = new ChallengeComponent(Settings["ChallengeReference"].ToString());
            else
                challengeComponent = new ChallengeComponent();

            if (Page.IsPostBack == false)
            {
                //Check for existing settings and use those on this page
                //Settings["SettingName"]

                if (Settings.Contains("ChallengeReference"))
                    txtChallengeReference.Text = Settings["ChallengeReference"].ToString();

                if (Settings.Contains("RadEditor"))
                {
                    RadEditor.RichText.Text = string.Empty;
                    RadEditor.BasicTextEditor.Text = string.Empty;
                    RadEditor.Text = Settings["RadEditor"].ToString();
                }
                if (!string.IsNullOrEmpty(challengeComponent.Challenge.EntryFrom.ToString()))
                    dtAvailableFrom.SelectedDate = Convert.ToDateTime(challengeComponent.Challenge.EntryFrom.ToString());
                if (!string.IsNullOrEmpty(challengeComponent.Challenge.EntryTo.ToString()))
                    dtAvailableTo.SelectedDate = Convert.ToDateTime(challengeComponent.Challenge.EntryTo.ToString());
                if (!string.IsNullOrEmpty(challengeComponent.Challenge.Closed.ToString()))
                    dtCloseDate.SelectedDate = Convert.ToDateTime(challengeComponent.Challenge.Closed.ToString());

                txtChallengeTitle.Text = challengeComponent.Challenge.ChallengeTitle;
                txtTagUrl.Text = challengeComponent.Challenge.Url;
                txtOutUrl.Text = challengeComponent.Challenge.OutUrl;
                txtEnterUrl.Text = challengeComponent.Challenge.EnterUrl;

                var list = ListComponent.GetListPerCategory("Flavor", Thread.CurrentThread.CurrentCulture.Name).ToList();
                var listEmptyItem = new NexsoProDAL.List();
                listEmptyItem.Key = "Default";
                listEmptyItem.Label = Localization.GetString("SelectItem", LocalResourceFile);
                list.Insert(0, listEmptyItem);

                ddFlavor.DataSource = list;
                ddFlavor.DataBind();

                ddFlavor.SelectedValue = challengeComponent.Challenge.Flavor;

                list = ListComponent.GetListPerCategory("PublishState", Thread.CurrentThread.CurrentCulture.Name).ToList();
                listEmptyItem = new NexsoProDAL.List();
                listEmptyItem.Value = "1000";
                listEmptyItem.Label = Localization.GetString("SelectItem", LocalResourceFile);
                list.Insert(0, listEmptyItem);


                ddPublishState.DataSource = list;
                ddPublishState.DataBind();


                if (Settings.Contains("PublishState"))
                    ddPublishState.SelectedValue = Settings["PublishState"].ToString();
                if (Settings.Contains("ThemeFilter"))
                    txtThemeFilter.Text = Settings["ThemeFilter"].ToString();
                if (Settings.Contains("BeneficiaryFilter"))
                    txtBeneficiaryFilter.Text = Settings["BeneficiaryFilter"].ToString();
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
            if (!string.IsNullOrEmpty(txtChallengeReference.Text))
                challengeComponent = new ChallengeComponent(txtChallengeReference.Text);
            else
                challengeComponent = new ChallengeComponent();

            var modules = new ModuleController();

            //the following are two sample Module Settings, using the text boxes that are commented out in the ASCX file.
            //module settings

            modules.UpdateModuleSetting(ModuleId, "ChallengeReference", txtChallengeReference.Text);
            modules.UpdateModuleSetting(ModuleId, "RadEditor", RadEditor.Text);
            modules.UpdateModuleSetting(ModuleId, "PublishState", ddPublishState.SelectedValue.ToString());
            modules.UpdateModuleSetting(ModuleId, "ThemeFilter", txtThemeFilter.Text.ToString());
            modules.UpdateModuleSetting(ModuleId, "BeneficiaryFilter", txtBeneficiaryFilter.Text.ToString());
            
            SaveChallenge();

        }
        catch (Exception exc) //Module failed to load
        {
            Exceptions.ProcessModuleLoadException(this, exc);
        }
    }

    #endregion


    private void SaveChallenge()
    {

        if (!string.IsNullOrEmpty(txtChallengeReference.Text))
        {
            if (challengeComponent.Challenge.ChallengeReference == string.Empty)
            {

                challengeComponent.Challenge.ChallengeReference = txtChallengeReference.Text;
                challengeComponent.Challenge.Created = DateTime.Now;
                challengeComponent.Challenge.Updated = challengeComponent.Challenge.Created;

            }

            if (dtAvailableFrom.SelectedDate != null)
                challengeComponent.Challenge.EntryFrom = Convert.ToDateTime(dtAvailableFrom.SelectedDate);


            if (dtAvailableTo.SelectedDate != null)
                challengeComponent.Challenge.EntryTo = Convert.ToDateTime(dtAvailableTo.SelectedDate);


            if (dtCloseDate.SelectedDate != null)
                challengeComponent.Challenge.Closed = Convert.ToDateTime(dtCloseDate.SelectedDate);



            if (!string.IsNullOrEmpty(txtTagUrl.Text))
                challengeComponent.Challenge.Url = txtTagUrl.Text;
            if (!string.IsNullOrEmpty(txtOutUrl.Text))
                challengeComponent.Challenge.OutUrl = txtOutUrl.Text;
            if (!string.IsNullOrEmpty(txtEnterUrl.Text))
                challengeComponent.Challenge.EnterUrl = txtEnterUrl.Text;
            if (!string.IsNullOrEmpty(txtChallengeTitle.Text))
                challengeComponent.Challenge.ChallengeTitle = txtChallengeTitle.Text;
            else
                challengeComponent.Challenge.ChallengeTitle = challengeComponent.Challenge.ChallengeTitle != null ? challengeComponent.Challenge.ChallengeTitle : string.Empty;

            challengeComponent.Challenge.Updated = DateTime.Now;
            challengeComponent.Challenge.Flavor = ddFlavor.SelectedValue;
            challengeComponent.Save();
        }

    }

}