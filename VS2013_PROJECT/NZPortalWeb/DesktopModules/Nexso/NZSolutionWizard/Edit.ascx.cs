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

partial class NZSolutionWizard_Edit : PortalModuleBase
{

    private ChallengeCustomDataComponent challengeCustomDataComponent;
    private ChallengeComponent challengeComponent;
    private string Language = System.Globalization.CultureInfo.CurrentUICulture.Name;
    protected void Page_Load(System.Object sender, System.EventArgs e)
    {
        try
        {
            bool sw = false;
            if (Settings.Contains("ChallengeReference"))
            {
                challengeComponent = new ChallengeComponent(Settings["ChallengeReference"].ToString());
                if (!string.IsNullOrEmpty(challengeComponent.Challenge.ChallengeReference))
                {
                    challengeCustomDataComponent = new ChallengeCustomDataComponent(challengeComponent.Challenge.ChallengeReference, Language);
                    sw = true;
                }
            }

            if (!sw)
            {
                challengeCustomDataComponent = new ChallengeCustomDataComponent();
                challengeComponent = new ChallengeComponent();
            }

            if (!IsPostBack)
            {
                if (!string.IsNullOrEmpty(challengeCustomDataComponent.ChallengeCustomData.CustomDataTemplate))
                    txtCustomDataTemplate.Text = challengeCustomDataComponent.ChallengeCustomData.CustomDataTemplate.ToString();
                if (!string.IsNullOrEmpty(challengeCustomDataComponent.ChallengeCustomData.Scoring))
                    TxtScoring.Text = challengeCustomDataComponent.ChallengeCustomData.Scoring.ToString();
            }

        }
        catch (Exception exc) //Module failed to load
        {
            Exceptions.ProcessModuleLoadException(this, exc);
        }

    }
    protected void btnSaveChallenge_Click(object sender, EventArgs e)
    {
        bool sw = false;
        if (!string.IsNullOrEmpty(challengeComponent.Challenge.ChallengeReference))
        {
            if (!string.IsNullOrEmpty(txtCustomDataTemplate.Text))
            {
                if (!string.IsNullOrEmpty(challengeCustomDataComponent.ChallengeCustomData.ChallengeReference))

                    challengeCustomDataComponent.ChallengeCustomData.CustomDataTemplate = txtCustomDataTemplate.Text;
                else
                {
                    challengeCustomDataComponent.ChallengeCustomData.ChallengeReference = challengeComponent.Challenge.ChallengeReference;
                    challengeCustomDataComponent.ChallengeCustomData.Language = Language;
                    challengeCustomDataComponent.ChallengeCustomData.CustomDataTemplate = txtCustomDataTemplate.Text;
                    sw = true;
                }
                challengeCustomDataComponent.Save();
            }

            if (!string.IsNullOrEmpty(TxtScoring.Text))
            {
                if (!string.IsNullOrEmpty(challengeCustomDataComponent.ChallengeCustomData.ChallengeReference))

                    challengeCustomDataComponent.ChallengeCustomData.Scoring = TxtScoring.Text;
                else
                {
                    if (!sw)
                    {
                        challengeCustomDataComponent.ChallengeCustomData.ChallengeReference = challengeComponent.Challenge.ChallengeReference;
                        challengeCustomDataComponent.ChallengeCustomData.Language = Language;
                        challengeCustomDataComponent.ChallengeCustomData.Scoring = TxtScoring.Text;
                    }
                }
                challengeCustomDataComponent.Save();
            }
        }
    }
}