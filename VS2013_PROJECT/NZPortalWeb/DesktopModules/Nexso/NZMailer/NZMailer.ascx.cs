using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Net;
using System.Runtime.Serialization.Json;
using System.Xml.Serialization;
using System.Globalization;
using DotNetNuke.Security.Roles;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Services.Localization;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Security;
using DotNetNuke.Entities.Users;
using DotNetNuke.Common.Utilities;
using Telerik.Web.UI;
using NexsoProDAL;
using NexsoProBLL;
using DotNetNuke.Services.Exceptions;

/// <summary>
/// BACKEND
/// This component is for configuration companies mailer. this is a wizard
/// In Backend clic in Tools and NexosChimp
/// https://www.nexso.org/en-us/Backend/Campaign
/// The companies configuration is execute with a Job
/// </summary>
public partial class NZMailer : UserUserControlBase, IActionable
{
    #region Private Member Variables

    #endregion

    #region Public Member Variables
    public CampaignComponent campaignComponent;
    public CampaignTemplateComponent campaignTemplateComponent;
    public Guid idTemplate;
    public Guid idCampaign;
    #endregion

    #region Private Properties


    #endregion

    #region Private Methods

    /// <summary>
    /// Load Text and CSS for the buttons and steps circles.
    /// </summary>
    /// <param name="step"></param>
    private void SetupWizard(int? step)
    {
        wizardCampaign.StartNextButtonStyle.CssClass = "btn step-start";
        wizardCampaign.CancelButtonStyle.CssClass = "btn step-cancel";
        wizardCampaign.StepPreviousButtonStyle.CssClass = "btn step-back";
        wizardCampaign.FinishCompleteButtonStyle.CssClass = "btn step-finish";
        wizardCampaign.StepNextButtonStyle.CssClass = "btn step-forward";
        wizardCampaign.FinishPreviousButtonStyle.CssClass = "btn step-back";
        wizardCampaign.StartNextButtonText = Localization.GetString("Start",
                                                             LocalResourceFile);
        wizardCampaign.FinishPreviousButtonText = Localization.GetString("Previous",
                                                                  LocalResourceFile);
        wizardCampaign.StepNextButtonText = Localization.GetString("Next",
                                                            LocalResourceFile);
        wizardCampaign.StepPreviousButtonText = Localization.GetString("Previous",
                                                                LocalResourceFile);
        wizardCampaign.FinishCompleteButtonText = Localization.GetString("Finish",
                                                                  LocalResourceFile);
        wizardCampaign.CancelButtonText = Localization.GetString("Cancel",
                                                          LocalResourceFile);

        WizardStep1.Title = Localization.GetString("Step1",
                                                   LocalResourceFile);
        WizardStep2.Title = Localization.GetString("Step2",
                                                   LocalResourceFile);
        WizardStep3.Title = Localization.GetString("Step3",
                                                   LocalResourceFile);
        WizardStep4.Title = Localization.GetString("Step4",
                                                   LocalResourceFile);
        WizardStep5.Title = Localization.GetString("Step5",
                                                   LocalResourceFile);
        WizardStep6.Title = Localization.GetString("Step6",
                                                  LocalResourceFile);
        WizardStep7.Title = Localization.GetString("Step7",
                                                  LocalResourceFile);
        WizardStep8.Title = Localization.GetString("Step8",
                                                  LocalResourceFile);
        wizardCampaign.ActiveStepIndex = step ?? default(int);
    }

    /// <summary>
    /// Get all countries arround the world
    /// </summary>
    private void fillCountries()
    {
        try
        {
            string WURL = System.Configuration.ConfigurationManager.AppSettings["MifWebServiceUrl"].ToString();
            string url = WURL + "/countries";
            WebRequest request = WebRequest.Create(url);
            WebResponse ws = request.GetResponse();
            DataContractJsonSerializer jsonSerializer = new DataContractJsonSerializer(typeof(List<Country>));
            List<Country> photos = (List<Country>)jsonSerializer.ReadObject(ws.GetResponseStream());
            var country = new Country();
            country.code = "%NULL%";
            country.country = Localization.GetString("NullItem", this.LocalResourceFile);
            ddUserCountry.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
            photos.Insert(0, country);
            ddUserCountry.DataSource = photos;
            ddUserCountry.DataBind();
            ddOrganizationCountry.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
            ddOrganizationCountry.DataSource = photos;
            ddOrganizationCountry.DataBind();

            rdPotentialUserCountry.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
            rdPotentialUserCountry.DataSource = photos;
            rdPotentialUserCountry.DataBind();

        }
        catch (Exception e)
        {

        }
    }
    private void setTitleCurrentStep(int index)
    {

    }

    /// <summary>
    /// Get  users to send a test campaign. This action is necessary to verify as seen in the different email inboxes.
    /// </summary>
    /// <param name="userTest"></param>
    /// <returns></returns>
    private List<UserInfo> GetUserTest(List<UserProperty> userTest)
    {
        List<UserInfo> userTestList = new List<UserInfo>();

        foreach (var item in userTest)
        {
            var user = UserController.GetUserById(PortalId, item.UserId);
            userTestList.Add(user);
        }

        return userTestList;
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="additionalEmails"></param>
    /// <returns></returns>
    private List<AdditionalRecipient> GetAdditionalRecepients(string additionalEmails)
    {
        additionalEmails = additionalEmails.Replace("\"", "");
        List<AdditionalRecipient> additionalRecipients = new List<AdditionalRecipient>();
        string[] emails = additionalEmails.Split(',');
        foreach (string cli in emails)
        {
            if (cli != string.Empty)
            {
                string emailRegex = @"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|""(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*"")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])";
                string emailAddress = Regex.Match(cli.ToLower(), emailRegex).Value;
                string displayName = null;
                try
                {
                    displayName = cli.Substring(0, cli.ToLower().IndexOf(emailAddress) - 1);
                }
                catch
                {
                    displayName = "";
                }
                additionalRecipients.Add(new AdditionalRecipient()
                {
                    name = displayName.Replace("\n", "").Replace("\t", ""),
                    email = emailAddress.Replace("\n", "").Replace("\t", "")
                });
            }
        }
        return additionalRecipients;
    }


    private string GetAdditionalRecipientsFromString(List<AdditionalRecipient> additionalemails)
    {
        StringBuilder result_ = new StringBuilder();
        foreach (var item in additionalemails)
        {
            if (item.name != "")
            {
                result_.Append("" + item.name + " <" + item.email + ">,\n");
            }
            else
            {
                result_.Append(item.email + ",\n");
            }


        }
        return result_.ToString();
    }

    /// <summary>
    /// Load All ComboBox of the campaign. Differents ComboBox with different values
    /// </summary>
    /// <param name="listValue"></param>
    /// <param name="comboBox"></param>
    private void PopulateComboBox(List<string> listValue, RadComboBox comboBox)
    {
        RadComboBoxItem item;
        foreach (var itemL in listValue)
        {
            item = comboBox.FindItemByValue(itemL);
            if (item != null)
                item.Checked = true;
        }

    }
    private void fillFromXml(string xml)
    {
    }
    #endregion

    #region Public Properties



    #endregion

    #region Public Methods

    /// <summary>
    /// Load the information of the page the first time
    /// </summary>
    public void BindData()
    {
        fillCountries();
        var listEmptyItem = new NexsoProDAL.List();
        listEmptyItem.Key = "%NULL%";
        listEmptyItem.Value = "%NULL%";
        listEmptyItem.Label = Localization.GetString("NullItem", this.LocalResourceFile);

        var list = ListComponent.GetListPerCategory("Theme", Thread.CurrentThread.CurrentCulture.Name).ToList();
        list.Insert(0, listEmptyItem);
        ddUserTheme.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        ddUserTheme.DataSource = list;
        ddUserTheme.DataBind();

        list = ListComponent.GetListPerCategory("Beneficiaries", Thread.CurrentThread.CurrentCulture.Name).ToList();
        list.Insert(0, listEmptyItem);
        ddUserBeneficiaries.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        ddUserBeneficiaries.DataSource = list;
        ddUserBeneficiaries.DataBind();

        list = ListComponent.GetListPerCategory("Language", Thread.CurrentThread.CurrentCulture.Name).ToList();
        list.Insert(0, listEmptyItem);
        ddUserLanguage.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        ddUserLanguage.DataSource = list;
        ddUserLanguage.DataBind();

        ddSolutionLanguage.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        ddSolutionLanguage.DataSource = list;
        ddSolutionLanguage.DataBind();

        rdTemplateLanguage.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        rdTemplateLanguage.DataSource = list;
        rdTemplateLanguage.DataBind();

        rdPotentialUserLanguage.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        rdPotentialUserLanguage.DataSource = list;
        rdPotentialUserLanguage.DataBind();

        list = ListComponent.GetListPerCategory("RoleNexso", Thread.CurrentThread.CurrentCulture.Name).ToList();

        ddUserCustomerType.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        ddUserCustomerType.DataSource = list;
        ddUserCustomerType.DataBind();

        list = ListComponent.GetListPerCategory("ScheduleOption", Thread.CurrentThread.CurrentCulture.Name).ToList();

        rdbRepeat.DataSource = list;
        rdbRepeat.DataBind();

        list = ListComponent.GetListPerCategory("Status", Thread.CurrentThread.CurrentCulture.Name).ToList();
        rdbStatus.DataSource = list;
        rdbStatus.DataBind();

        list = ListComponent.GetListPerCategory("ScoreYesNot", Thread.CurrentThread.CurrentCulture.Name).ToList();
        rbNotifications.DataSource = list;
        rbNotifications.DataBind();
        rbNotifications.Items[1].Selected = true;

        rdUseUser.DataSource = list;
        rdUseUser.DataBind();
        rdUseUser.Items[0].Selected = true;

        rdUseOrganization.DataSource = list;
        rdUseOrganization.DataBind();
        rdUseOrganization.Items[0].Selected = true;

        rdUseSolution.DataSource = list;
        rdUseSolution.DataBind();
        rdUseSolution.Items[0].Selected = true;

        rdUsePotentialUsers.DataSource = list;
        rdUsePotentialUsers.DataBind();
        rdUsePotentialUsers.Items[0].Selected = true;


        list = ListComponent.GetListPerCategory("SolutionState", Thread.CurrentThread.CurrentCulture.Name).ToList();
        rdSolutionState.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        rdSolutionState.DataSource = list;
        rdSolutionState.DataBind();
        var tmp = SolutionComponent.GetSolutionChallenges().OrderBy(x => x).ToList();
        tmp.Insert(0, "NULL");
        rdChallenge.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        rdChallenge.DataSource = tmp;
        rdChallenge.DataBind();

        tmp = PotentialUserComponent.GetPotentialUserSources().OrderBy(x => x).ToList();
        tmp.Insert(0, "NULL");
        rdPotentialUserSource.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        rdPotentialUserSource.DataSource = tmp;
        rdPotentialUserSource.DataBind();

        FillDataCampaignTemplate();
        FillDataCampaign();
        SetupWizard(0);
        setTitleCurrentStep(wizardCampaign.ActiveStepIndex);

        RoleController rc = new RoleController();
        var listUser = rc.GetUsersByRoleName(PortalId, "NexsoSupport");
        ddUser.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        ddUser.DataSource = listUser;
        ddUser.DataBind();

        ddCampaignExclude.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        ddCampaignExclude.DataSource = CampaignComponent.GetCampaigns().OrderBy(x => x.CampaignName);
        ddCampaignExclude.DataBind();

        ddCampaignInclude.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        ddCampaignInclude.DataSource = CampaignComponent.GetCampaigns().OrderBy(x => x.CampaignName);
        ddCampaignInclude.DataBind();

    }

    /// <summary>
    /// Load campaign and set the values to the different controls
    /// </summary>
    public void DataCampaign()
    {
        idCampaign = new Guid(ddCampaign.SelectedValue);
        campaignComponent = new CampaignComponent(idCampaign);
        txtCampaignName.Text = campaignComponent.Campaign.CampaignName;
        txtDescription.Text = campaignComponent.Campaign.Description;

        if (RadDatePicker1.MinDate <= Convert.ToDateTime(campaignComponent.Campaign.SendOn))
            RadDatePicker1.SelectedDate = Convert.ToDateTime(campaignComponent.Campaign.SendOn);
        else
            RadDatePicker1.SelectedDate = RadDatePicker1.MinDate;



        int repeat = Convert.ToInt32(campaignComponent.Campaign.Repeat);
        string status = campaignComponent.Campaign.Status;

        foreach (ListItem list in rdbStatus.Items)
        {
            if (status == list.Text)
                list.Selected = true;

        }
        foreach (ListItem list in rdbRepeat.Items)
        {
            if (repeat == Convert.ToInt32(list.Value))
                list.Selected = true;

        }

        Guid idTem = (Guid)(campaignComponent.Campaign.TemplateId);
        CampaignTemplateComponent TemplateComponent = new CampaignTemplateComponent(idTem);

        if (TemplateComponent.CampaignTemplate.Deleted != true)
        {
            string nameTemplate = TemplateComponent.CampaignTemplate.TemplateTitle;

            foreach (RadComboBoxItem item in ddCampaignTemplate.Items)
            {
                if (item.Text.Equals(nameTemplate))
                    item.Selected = true;
            }
            ddCampaignTemplate.Text = nameTemplate;
            ddCampaignTemplate.SelectedValue = TemplateComponent.CampaignTemplate.TemplateId.ToString();
        }
        else
        {
            ddCampaignTemplate.Text = Localization.GetString("NewTemplate", this.LocalResourceFile);
            ddCampaignTemplate.SelectedValue = string.Empty;

        }
        SelectedTemplate();
        ClearControls();
        SetJsonFilter(campaignComponent.Campaign.FilterTemplate);

        hlReport.Visible = true;
        string url = NexsoHelper.GetCulturedUrlByTabName("reportmailer") + "?camId=" + idCampaign;
        hlReport.NavigateUrl = url;
        var clickEvent = UrlUtils.PopUpUrl(hlReport.NavigateUrl, this, PortalSettings, true, false, 480, 1024, false, "");
        if (PortalSettings.EnablePopUps)
        {
            hlReport.Attributes.Add("onclick", "return " + clickEvent);
        }
    }

    /// <summary>
    /// Remove the control values (checked items, text, etc.)
    /// </summary>
    public void ClearControls()
    {
        rdPotentialUserCountry.ClearCheckedItems();
        rdPotentialUserLanguage.ClearCheckedItems();
        rdPotentialUserSource.ClearCheckedItems();
        ddCampaignExclude.ClearCheckedItems();
        ddCampaignInclude.ClearCheckedItems();
        ddUserCountry.ClearCheckedItems();
        ddUserLanguage.ClearCheckedItems();
        ddUser.ClearCheckedItems();
        ddUserCustomerType.ClearCheckedItems();
        rbNotifications.Items[1].Selected = true;
        ddUserTheme.ClearCheckedItems();
        ddUserBeneficiaries.ClearCheckedItems();
        ddOrganizationCountry.ClearCheckedItems();
        ddSolutionLanguage.ClearCheckedItems();
        rdChallenge.ClearCheckedItems();
        rdSolutionState.ClearCheckedItems();
        RadSliderRate.SelectionStart = 0;
        RadSliderRate.SelectionEnd = 100;
        rsWordCounter.SelectionStart = 0;
        rsWordCounter.SelectionEnd = 700;
        rdUsePotentialUsers.Items[0].Selected = true;
        rdUseUser.Items[0].Selected = true;
        rdUseOrganization.Items[0].Selected = true;
        rdUseSolution.Items[0].Selected = true;
    }

    /// <summary>
    /// Geta all campains in Database 
    /// </summary>
    public void FillDataCampaign()
    {
        List<Campaign> ListCampaign = CampaignComponent.GetCampaigns();

        ddCampaign.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        List<Campaign> List = new List<Campaign>();

        foreach (Campaign campaign in ListCampaign)
        {
            // Delete template if deleted is true
            if (!campaign.Deleted)
                List.Add(campaign);

        }

        ddCampaign.DataSource = List.OrderBy(x => x.CampaignName);
        ddCampaign.DataBind();
        ddCampaign.Items.Insert(0, new RadComboBoxItem(Localization.GetString("NewCampaign", this.LocalResourceFile), string.Empty));

    }

    /// <summary>
    /// It takes the information of the controls and the load to the json.
    /// </summary>
    /// <returns></returns>
    public string GetJsonFilter()
    {
        MailContainer mailContainer = new MailContainer();
        List<string> values = new List<string>();


        values = rdPotentialUserCountry.CheckedItems.Select(a => a.Value).ToList();
        mailContainer.MailFilter.Add(new MailFilter()
        {
            Table = "PotentialUsers",
            Field = "Country",
            DataType = "String",
            FilterValue = values,
            Operator = "IN",
            ConcatenateOperator = "AND"

        });

        values = rdPotentialUserLanguage.CheckedItems.Select(a => a.Value).ToList();
        mailContainer.MailFilter.Add(new MailFilter()
        {
            Table = "PotentialUsers",
            Field = "Language",
            DataType = "String",
            FilterValue = values,
            Operator = "IN",
            ConcatenateOperator = "AND"


        });


        values = rdPotentialUserSource.CheckedItems.Select(a => a.Value).ToList();
        mailContainer.MailFilter.Add(new MailFilter()
        {
            Table = "PotentialUsers",
            Field = "Source",
            DataType = "String",
            FilterValue = values,
            Operator = "IN",
            ConcatenateOperator = "AND"


        });

        values = ddUserCountry.CheckedItems.Select(a => a.Value).ToList();
        mailContainer.MailFilter.Add(new MailFilter()
        {
            Table = "UserProperties",
            Field = "Country",
            DataType = "String",
            FilterValue = values,
            Operator = "IN",
            ConcatenateOperator = "AND"

        });

        values = ddUserLanguage.CheckedItems.Select(a => a.Value).ToList();
        mailContainer.MailFilter.Add(new MailFilter()
        {
            Table = "UserProperties",
            Field = "Language",
            DataType = "Integer",
            FilterValue = values,
            Operator = "IN",
            ConcatenateOperator = "AND"


        });


        values = ddUserCustomerType.CheckedItems.Select(a => a.Value).ToList();
        mailContainer.MailFilter.Add(new MailFilter()
        {
            Table = "UserProperties",
            Field = "CustomerType",
            DataType = "String",
            FilterValue = values,
            Operator = "IN",
            ConcatenateOperator = "AND"
        });



        values = ddUserTheme.CheckedItems.Select(a => a.Value).ToList();
        mailContainer.MailFilter.Add(new MailFilter()
        {
            Table = "UserPropertiesLists",
            Field = "[Key]",
            DataType = "String",
            FilterValue = values,
            Operator = "IN",
            ConcatenateOperator = "AND",
            Command = " AND UserPropertiesLists.Category='Theme'"
        });


        values = ddUserBeneficiaries.CheckedItems.Select(a => a.Value).ToList();
        mailContainer.MailFilter.Add(new MailFilter()
        {
            Table = "UserPropertiesLists",
            Field = "[Key]",
            DataType = "String",
            FilterValue = values,
            Operator = "IN",
            ConcatenateOperator = "AND",
            Command = "AND UserPropertiesLists.Category='Beneficiaries'"


        });

        values = new List<string>();
        values.Add(rbNotifications.SelectedValue);
        mailContainer.MailFilter.Add(new MailFilter()
        {
            Table = "UserProperties",
            Field = "[AllowNexsoNotifications]",
            DataType = "Boolean",
            FilterValue = values,
            Operator = "=",
            ConcatenateOperator = "AND"
        });

        values = ddOrganizationCountry.CheckedItems.Select(a => a.Value).ToList();
        mailContainer.MailFilter.Add(new MailFilter()
        {
            Table = "Organization",
            Field = "Country",
            DataType = "String",
            FilterValue = values,
            Operator = "IN",
            ConcatenateOperator = "AND"
        });

        values = ddSolutionLanguage.CheckedItems.Select(a => a.Value).ToList();
        mailContainer.MailFilter.Add(new MailFilter()
        {
            Table = "Solution",
            Field = "Language",
            DataType = "String",
            FilterValue = values,
            Operator = "IN",
            ConcatenateOperator = "AND"
        });

        values = rdChallenge.CheckedItems.Select(a => a.Value).ToList();
        mailContainer.MailFilter.Add(new MailFilter()
        {
            Table = "Solution",
            Field = "ChallengeReference",
            DataType = "String",
            FilterValue = values,
            Operator = "IN",
            ConcatenateOperator = "AND"
        });

        values = rdSolutionState.CheckedItems.Select(a => a.Value).ToList();
        mailContainer.MailFilter.Add(new MailFilter()
        {
            Table = "Solution",
            Field = "SolutionState",
            DataType = "Integer",
            FilterValue = values,
            Operator = "IN",
            ConcatenateOperator = "AND"
        });


        values = new List<string>();
        values.Add(rsWordCounter.SelectionStart.ToString());
        mailContainer.MailFilter.Add(new MailFilter()
        {
            Table = "Solution",
            Field = "FUNC:WordCount(Solution.SolutionId)",
            DataType = "Float",
            FilterValue = values,
            Operator = ">=",
            ConcatenateOperator = "AND"
        });

        values = new List<string>();
        values.Add(rsWordCounter.SelectionEnd.ToString());
        mailContainer.MailFilter.Add(new MailFilter()
        {
            Table = "Solution",
            Field = "FUNC:WordCount(Solution.SolutionId)",
            DataType = "Float",
            FilterValue = values,
            Operator = "<=",
            ConcatenateOperator = "AND"
        });

        values = new List<string>();
        values.Add(RadSliderRate.SelectionStart.ToString());
        mailContainer.MailFilter.Add(new MailFilter()
        {
            Table = "Solution",
            Field = "FUNC:GetScore(Solution.SolutionId,'JUDGE')",
            DataType = "Float",
            FilterValue = values,
            Operator = ">=",
            ConcatenateOperator = "AND"
        });

        values = new List<string>();
        values.Add(RadSliderRate.SelectionEnd.ToString());
        mailContainer.MailFilter.Add(new MailFilter()
        {
            Table = "Solution",
            Field = "FUNC:GetScore(Solution.SolutionId,'JUDGE')",
            DataType = "Float",
            FilterValue = values,
            Operator = "<=",
            ConcatenateOperator = "AND"
        });

        values = new List<string>();
        values.Add(rdUsePotentialUsers.SelectedValue);
        mailContainer.MailFilter.Add(new MailFilter()
        {
            Table = "&&1",
            Field = "UsePotentialUser",
            DataType = "",
            FilterValue = values,
            Operator = "",
            ConcatenateOperator = ""
        });

        values = new List<string>();
        values.Add(rdUseUser.SelectedValue);
        mailContainer.MailFilter.Add(new MailFilter()
        {
            Table = "&&1",
            Field = "UseUser",
            DataType = "",
            FilterValue = values,
            Operator = "",
            ConcatenateOperator = ""
        });

        values = new List<string>();
        values.Add(rdUseOrganization.SelectedValue);
        mailContainer.MailFilter.Add(new MailFilter()
        {
            Table = "&&1",
            Field = "UseOrganization",
            DataType = "",
            FilterValue = values,
            Operator = "",
            ConcatenateOperator = ""
        });

        values = new List<string>();
        values.Add(rdUseSolution.SelectedValue);
        mailContainer.MailFilter.Add(new MailFilter()
        {
            Table = "&&1",
            Field = "UseSolution",
            DataType = "",
            FilterValue = values,
            Operator = "",
            ConcatenateOperator = ""
        });

        List<Guid> ListExceptionsExclude = new List<Guid>();
        foreach (var item in ddCampaignExclude.CheckedItems)
        {
            CampaignComponent campaignComponent = new CampaignComponent(new Guid(item.Value));
            ListExceptionsExclude.Add(campaignComponent.Campaign.CampaignId);
        }
        mailContainer.ExceptionsExclude = ListExceptionsExclude;
        List<Guid> ListExceptionsInclude = new List<Guid>();
        foreach (var item in ddCampaignInclude.CheckedItems)
        {
            CampaignComponent campaignComponent = new CampaignComponent(new Guid(item.Value));
            ListExceptionsInclude.Add(campaignComponent.Campaign.CampaignId);
        }
        mailContainer.ExceptionsInclude = ListExceptionsInclude;
        List<UserProperty> ListUsers = new List<UserProperty>();
        foreach (var item in ddUser.CheckedItems)
        {
            UserPropertyComponent user = new UserPropertyComponent(Convert.ToInt32(item.Value));
            ListUsers.Add(user.UserProperty);
        }

        //  mailContainer.AdditionalRecipients = GetAdditionalRecepients(txtAdditionalRecipients.Text);
        mailContainer.UserProperty = ListUsers;
        XmlSerializer serializer = new XmlSerializer(mailContainer.GetType());
        MemoryStream memStream = new MemoryStream();
        var stWriter = new StreamWriter(memStream);
        serializer.Serialize(stWriter.BaseStream, mailContainer);
        var buffer = Encoding.ASCII.GetString(memStream.GetBuffer());
        return buffer.ToString();
    }

    /// <summary>
    /// Load the JSON (Potential Users, User Properties, Organizations, Solution)  to the controls 
    /// </summary>
    /// <param name="jsonValue"></param>
    public void SetJsonFilter(string jsonValue)
    {
        MailContainer mailContainer;
        try
        {
            mailContainer = new MailContainer();
            XmlSerializer serializer = new XmlSerializer(mailContainer.GetType());
            MemoryStream memoryStream = new MemoryStream(Encoding.ASCII.GetBytes(jsonValue));
            mailContainer = (MailContainer)serializer.Deserialize(memoryStream);
            foreach (MailFilter mailFilter in mailContainer.MailFilter)
            {
                switch (mailFilter.Table)
                {
                    case "PotentialUsers":
                        {
                            switch (mailFilter.Field)
                            {
                                case "Country":
                                    {
                                        PopulateComboBox(mailFilter.FilterValue, rdPotentialUserCountry);
                                        break;
                                    }
                                case "Language":
                                    {
                                        PopulateComboBox(mailFilter.FilterValue, rdPotentialUserLanguage);
                                        break;
                                    }
                                case "Source":
                                    {
                                        PopulateComboBox(mailFilter.FilterValue, rdPotentialUserSource);
                                        break;
                                    }


                            }
                            break;
                        }

                    case "UserProperties":
                        {
                            switch (mailFilter.Field)
                            {
                                case "Country":
                                    {
                                        PopulateComboBox(mailFilter.FilterValue, ddUserCountry);
                                        break;
                                    }
                                case "Language":
                                    {
                                        PopulateComboBox(mailFilter.FilterValue, ddUserLanguage);
                                        break;
                                    }
                                case "CustomerType":
                                    {
                                        PopulateComboBox(mailFilter.FilterValue, ddUserCustomerType);
                                        break;
                                    }
                                case "[AllowNexsoNotifications]":
                                    {
                                        rbNotifications.SelectedValue = mailFilter.FilterValue[0];
                                        break;
                                    }

                            }
                            break;
                        }

                    case "UserPropertiesLists":
                        {
                            switch (mailFilter.Field)
                            {
                                case "[Key]":
                                    {
                                        if (mailFilter.Command.Contains("Theme"))
                                            PopulateComboBox(mailFilter.FilterValue, ddUserTheme);
                                        if (mailFilter.Command.Contains("Beneficiaries"))
                                            PopulateComboBox(mailFilter.FilterValue, ddUserBeneficiaries);
                                        break;
                                    }
                            }
                            break;
                        }

                    case "Organization":
                        {
                            switch (mailFilter.Field)
                            {
                                case "Country":
                                    {
                                        PopulateComboBox(mailFilter.FilterValue, ddOrganizationCountry);
                                        break;
                                    }
                            }
                            break;
                        }

                    case "Solution":
                        {
                            switch (mailFilter.Field)
                            {
                                case "Language":
                                    {
                                        PopulateComboBox(mailFilter.FilterValue, ddSolutionLanguage);
                                        break;
                                    }
                                case "ChallengeReference":
                                    {
                                        PopulateComboBox(mailFilter.FilterValue, rdChallenge);
                                        break;
                                    }
                                case "SolutionState":
                                    {
                                        PopulateComboBox(mailFilter.FilterValue, rdSolutionState);
                                        break;
                                    }
                                case "FUNC:GetScore(Solution.SolutionId,'JUDGE')":
                                    {
                                        if (mailFilter.Operator == ">=")
                                            RadSliderRate.SelectionStart = Convert.ToInt32(mailFilter.FilterValue[0]);
                                        if (mailFilter.Operator == "<=")
                                            RadSliderRate.SelectionEnd = Convert.ToInt32(mailFilter.FilterValue[0]);

                                        break;
                                    }
                                case "FUNC:WordCount(Solution.SolutionId)":
                                    {
                                        if (mailFilter.Operator == "<=")
                                            rsWordCounter.SelectionStart = Convert.ToInt32(mailFilter.FilterValue[0]);
                                        if (mailFilter.Operator == ">=")
                                            rsWordCounter.SelectionEnd = Convert.ToInt32(mailFilter.FilterValue[0]);

                                        break;
                                    }

                            }
                            break;
                        }

                    case "&&1":
                        {
                            switch (mailFilter.Field)
                            {
                                case "UsePotentialUser":
                                    {
                                        rdUsePotentialUsers.SelectedValue = mailFilter.FilterValue[0];
                                        break;
                                    }
                                case "UseUser":
                                    {
                                        rdUseUser.SelectedValue = mailFilter.FilterValue[0];
                                        break;
                                    }
                                case "UseOrganization":
                                    {
                                        rdUseOrganization.SelectedValue = mailFilter.FilterValue[0];
                                        break;
                                    }
                                case "UseSolution":
                                    {
                                        rdUseSolution.SelectedValue = mailFilter.FilterValue[0];
                                        break;
                                    }

                            }
                            break;
                        }
                }
            }
            RadComboBoxItem item;

            foreach (var itemL in mailContainer.ExceptionsExclude)
            {
                item = ddCampaignExclude.FindItemByValue((itemL).ToString());
                if (item != null)
                    item.Checked = true;
            }

            foreach (var itemL in mailContainer.ExceptionsInclude)
            {
                item = ddCampaignInclude.FindItemByValue((itemL).ToString());
                if (item != null)
                    item.Checked = true;
            }
            List<UserInfo> userTestList = GetUserTest(mailContainer.UserProperty);

            foreach (var itemL in userTestList)
            {
                item = ddUser.FindItemByValue((itemL.UserID).ToString());
                if (item != null)
                    item.Checked = true;
            }

            // txtAdditionalRecipients.Text = GetAdditionalRecipientsFromString(mailContainer.AdditionalRecipients);

        }


        catch (Exception)
        {


        }
    }

    /// <summary>
    /// Configure visualization of the template selected
    /// </summary>
    public void SelectedTemplate()
    {
        linkButtonTemplate.Text = Localization.GetString("ExpandTemplate", this.LocalResourceFile);
        btnDeleteTemplate.Visible = true;
        btnSaveTemplate.Visible = true;
        divEditTemplate.Visible = true;
        divEditTemplate2.Visible = true;

        string nameTemplate = String.Format(ddCampaignTemplate.Text);

        if (nameTemplate != Localization.GetString("NewTemplate", this.LocalResourceFile))
        {
            DataTemplate();
            divEditTemplate.Visible = false;
            divEditTemplate2.Visible = false;
            btnCloneTemplate.Visible = true;
        }
        else
        {
            txtSubject.Text = String.Empty;
            linkButtonTemplate.Text = Localization.GetString("CollapseTemplate", this.LocalResourceFile);
            txtTemplateName.Text = String.Empty;
            lbTemplateVersion.Text = "1";
            RadEditorTemplate.Content = string.Empty;
            rdTemplateLanguage.ClearSelection();
            btnCloneTemplate.Visible = false;
        }
    }

    /// <summary>
    /// Load Template from data base and sends the information to  controls: template name, versión, editor HTML, subject.
    /// </summary>
    public void DataTemplate()
    {
        idTemplate = new Guid(ddCampaignTemplate.SelectedValue);
        campaignTemplateComponent = new CampaignTemplateComponent(idTemplate);
        txtTemplateName.Text = campaignTemplateComponent.CampaignTemplate.TemplateTitle;
        lbTemplateVersion.Text = campaignTemplateComponent.CampaignTemplate.TemplateVersion.ToString();
        RadEditorTemplate.Content = campaignTemplateComponent.CampaignTemplate.TemplateContent;

        string language = campaignTemplateComponent.CampaignTemplate.Language;
        txtSubject.Text = campaignTemplateComponent.CampaignTemplate.TemplateSubject;

        rdTemplateLanguage.SelectedValue = language;
        ClearControls();
        SetJsonFilter(campaignComponent.Campaign.FilterTemplate);

    }

    /// <summary>
    /// Get  all Templates in Database
    /// </summary>
    public void FillDataCampaignTemplate()
    {
        List<CampaignTemplate> ListCampaignTemplate = CampaignTemplateComponent.GetTemplateLists();

        ddCampaignTemplate.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        List<CampaignTemplate> List = new List<CampaignTemplate>();

        foreach (CampaignTemplate campaignTemplate in ListCampaignTemplate)
        {
            // Delete template if deleted is true
            if (!campaignTemplate.Deleted)
                List.Add(campaignTemplate);

        }

        ddCampaignTemplate.DataSource = List.OrderBy(x => x.TemplateTitle);
        ddCampaignTemplate.DataBind();
        ddCampaignTemplate.Items.Insert(0, new RadComboBoxItem(Localization.GetString("NewTemplate", this.LocalResourceFile), string.Empty));

    }
    #endregion
    #region Protected Methods

    /// <summary>
    /// Load css class to the steps (circles) in the sidebar.
    /// </summary>
    /// <param name="wizardStep"></param>
    /// <returns></returns>
    protected string GetClassForWizardStep(object wizardStep)
    {
        WizardStep step = wizardStep as WizardStep;

        if (step == null)
        {
            return "";
        }
        int stepIndex = wizardCampaign.WizardSteps.IndexOf(step);

        if (stepIndex < wizardCampaign.ActiveStepIndex)
        {
            return "prevStep";
        }
        else if (stepIndex > wizardCampaign.ActiveStepIndex)
        {
            return "nextStep";
        }
        else
        {
            return "currentStep";
        }
    }

    #endregion

    #region Subclasses
    public class Country
    {
        public string country { get; set; }
        public string code { get; set; }

    }
    public class Template
    {
        public Guid IdTemplate { get; set; }
        public string Title { get; set; }
        public string Content { get; set; }
        public int Version { get; set; }
        public DateTime Created { get; set; }
    }

    #endregion

    #region Events

    protected void Page_Load(object sender, EventArgs e)
    {
        wizardCampaign.PreRender += new EventHandler(Wizard1_PreRender);
    }
    protected override void OnLoad(EventArgs e)
    {
        CultureInfo cultureInfo = new CultureInfo("es-ES", false);
        var deliveryProcessor = NexsoHelper.GetCulturedUrlByTabName("PromoteMicroEn", 7, cultureInfo.Name);
        base.OnLoad(e);
        if (ddCampaign.SelectedValue != "")
        {
            campaignComponent = new CampaignComponent(new Guid(ddCampaign.SelectedValue));
        }
        else
        {
            campaignComponent = new CampaignComponent();
        }
        if (!IsPostBack)
        {
            BindData();
            //Only available for administrator
            if (!UserController.GetCurrentUserInfo().IsInRole("Administrators") && !UserController.GetCurrentUserInfo().IsInRole("NexsoSupport"))
            {
                Exceptions.ProcessModuleLoadException(this, new Exception("UserID: " + UserController.GetCurrentUserInfo().UserID + " - Email: " + UserController.GetCurrentUserInfo().Email + " - " + DateTime.Now + " - Security Issue"));
                Response.Redirect("/error/403.html");
            }
        }
    }
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        string FileName = System.IO.Path.GetFileNameWithoutExtension(this.AppRelativeVirtualPath);
        if (this.ID != null)
            //this will fix it when its placed as a ChildUserControl 
            this.LocalResourceFile = this.LocalResourceFile.Replace(this.ID, FileName);
        else
            // this will fix it when its dynamically loaded using LoadControl method 
            this.LocalResourceFile = this.LocalResourceFile + FileName + ".ascx.resx";
    }

    /// <summary>
    /// Go to selected step in sidebar
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Jump_Click(object sender, EventArgs e)
    {
        if (ddCampaign.Text == Localization.GetString("NewCampaign", this.LocalResourceFile))
        {
            rfvddCampaignn.IsValid = false;
        }
        if (Page.IsValid)
        {
            var link = (LinkButton)sender;
            wizardCampaign.ActiveStepIndex = Convert.ToInt32(link.CommandArgument);
            campaignComponent.Campaign.FilterTemplate = GetJsonFilter();
        }
    }

    protected void SideBarList_DataBinding(object sender, EventArgs e)
    {

    }
    protected void SideBarList_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        var link = (LinkButton)e.Item.FindControl("LinkButton1");
        if (link != null)
        {
            var wizardstep = (WizardStep)e.Item.DataItem;
            link.CommandArgument = e.Item.ItemIndex.ToString();
            link.ToolTip = wizardstep.Name;
        }
    }

    /// <summary>
    /// Load controls the different steps of the wizard
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void wizardCampaign_NextButtonClick(object sender, WizardNavigationEventArgs e)
    {
        if (Page.IsValid)
        {
            switch (e.NextStepIndex)
            {
                case 1:
                    if (ddCampaign.Text == Localization.GetString("NewCampaign", this.LocalResourceFile))
                    {
                        rfvddCampaignn.IsValid = false;
                        e.Cancel = true;
                    }
                    break;
            }
            if (e.NextStepIndex > 1)
            {
                campaignComponent.Campaign.FilterTemplate = GetJsonFilter();
            }
        }
        else
            e.Cancel = true;
    }

    /// <summary>
    /// Returns to the user to step one of the wizard
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void wizardCampaign_FinishButtonClick(object sender, WizardNavigationEventArgs e)
    {
        wizardCampaign.ActiveStepIndex = 0;
    }

    /// <summary>
    /// Bind Sidelbar list
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Wizard1_PreRender(object sender, EventArgs e)
    {
        Repeater SideBarList = wizardCampaign.FindControl("HeaderContainer").FindControl("SideBarList") as Repeater;
        SideBarList.DataSource = wizardCampaign.WizardSteps;
        SideBarList.DataBind();
    }

    /// <summary>
    /// Get text from combobox for to load the campaign
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RadComboBox_TextChangedCampaign(object sender, EventArgs e)
    {
        divEditCampaign.Visible = true;
        divEditCampaign2.Visible = true;
        divActionPanel.Visible = true;
        string nameCampaign = String.Format(ddCampaign.Text);
        if (nameCampaign != Localization.GetString("NewCampaign", this.LocalResourceFile))
        {
            DataCampaign();
        }
        else
        {
            hlReport.Visible = false;
            divEditTemplate.Visible = false;
            divEditTemplate2.Visible = false;
            btnSaveTemplate.Visible = false;
            btnDeleteTemplate.Visible = false;
            ddCampaignTemplate.Text = String.Empty;
            txtCampaignName.Text = String.Empty;
            rdbRepeat.Items[3].Selected = true;
            ddCampaignTemplate.ClearSelection();
            txtDescription.Text = String.Empty;
            rdbStatus.ClearSelection();
            RadDatePicker1.SelectedDate = DateTime.Now;
        }
    }

    /// <summary>
    /// Save or update current campaign
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSaveCampaign_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(ddCampaignTemplate.SelectedValue))
        {
            rfvddCampaignTemplate.IsValid = false;
            return;
        }

        if (Page.IsValid)
        {
            string nameCampaign = String.Format(ddCampaign.Text);
            if (nameCampaign != Localization.GetString("NewCampaign", this.LocalResourceFile))
            {
                idCampaign = new Guid(ddCampaign.SelectedValue);
                campaignComponent = new CampaignComponent(idCampaign);
                campaignComponent.Campaign.Updated = DateTime.Now;
            }
            else
            {
                campaignComponent = new CampaignComponent();
                campaignComponent.Campaign.Created = DateTime.Now;
                campaignComponent.Campaign.Updated = campaignComponent.Campaign.Created;
            }
            //Get values from the controls
            CampaignTemplateComponent objTemplate = new CampaignTemplateComponent(new Guid(ddCampaignTemplate.SelectedValue));
            campaignComponent.Campaign.CampaignName = txtCampaignName.Text;
            campaignComponent.Campaign.TemplateId = objTemplate.CampaignTemplate.TemplateId;
            campaignComponent.Campaign.CampaignName = txtCampaignName.Text;
            campaignComponent.Campaign.Description = txtDescription.Text;
            campaignComponent.Campaign.Repeat = Convert.ToInt32(rdbRepeat.SelectedValue);
            if (campaignComponent.Campaign.NextExecution.GetValueOrDefault(DateTime.MinValue) == new DateTime(9999, 12, 31))
            {
                if (campaignComponent.Campaign.SendOn != Convert.ToDateTime(RadDatePicker1.SelectedDate))
                {
                    campaignComponent.Campaign.SendOn = Convert.ToDateTime(RadDatePicker1.SelectedDate);
                    campaignComponent.Campaign.NextExecution = campaignComponent.Campaign.SendOn;
                }
            }
            else
            {
                campaignComponent.Campaign.SendOn = Convert.ToDateTime(RadDatePicker1.SelectedDate);
                campaignComponent.Campaign.NextExecution = campaignComponent.Campaign.SendOn;
            }
            campaignComponent.Campaign.Status = rdbStatus.SelectedValue;
            campaignComponent.Campaign.Deleted = false;
            campaignComponent.Campaign.FilterTemplate = GetJsonFilter();
            campaignComponent.Campaign.CampaignType = 1;
            if (campaignComponent.Save() > -1)
            {
                HiddenFieldMessage.Value = Localization.GetString("MessageCampaignSave", this.LocalResourceFile);
                ScriptManager.RegisterStartupScript(UpdatePanel1, UpdatePanel1.GetType(), "alert", "MessageAlert();", true);

            }
            //Load newly the current campaign 
            FillDataCampaign();
            foreach (RadComboBoxItem item in ddCampaign.Items)
            {
                if (item.Text.Equals(txtCampaignName.Text))
                    item.Selected = true;
            }
            ddCampaign.Text = txtCampaignName.Text;
            ddCampaign.SelectedValue = campaignComponent.Campaign.CampaignId.ToString();
            DataCampaign();
        }
    }

    /// <summary>
    /// Delete current campaign (selected in the combobox Campaign)
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDeletedCampaign_Click(object sender, EventArgs e)
    {
        string nameCampaign = ddCampaign.Text;
        if (nameCampaign != Localization.GetString("NewCampaign", this.LocalResourceFile))
        {
            CampaignComponent objCampaign = new CampaignComponent(new Guid(ddCampaign.SelectedValue));
            objCampaign.Campaign.Updated = DateTime.Now;
            objCampaign.Campaign.Deleted = true;
            if (objCampaign.Save() > -1)
            {
                HiddenFieldMessage.Value = Localization.GetString("MessageCampaignDelete", this.LocalResourceFile);
                ScriptManager.RegisterStartupScript(UpdatePanel1, UpdatePanel1.GetType(), "alert", "MessageAlert();", true);
            }
        }

        FillDataCampaign();
        divActionPanel.Visible = false;
        divEditCampaign.Visible = false;
        divEditCampaign2.Visible = false;
        ddCampaign.Text = String.Empty;
    }

    /// <summary>
    /// Send email to the test users
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnTestCampaign_Click(object sender, EventArgs e)
    {
        campaignComponent.Campaign.FilterTemplate = GetJsonFilter();
        var result = MailServices.ProcessXmlFilter(campaignComponent.Campaign.CampaignId, "", 0,
                                      campaignComponent.Campaign.FilterTemplate, PortalId);

        var sub = result.Take(2).ToList();
        Session["MailPreview"] = sub;
        grdPreviewList.DataSource = sub;
        grdPreviewList.DataBind();
        lblResult.Text = result.Count.ToString();
    }

    protected void RadComboBox1_TextChanged(object sender, EventArgs e)
    {
        SelectedTemplate();
    }

    /// <summary>
    /// Save or update current template
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSaveTemplate_Click(object sender, EventArgs e)
    {
        if (Page.IsValid)
        {
            string nameTemplate = ddCampaignTemplate.Text;
            if (nameTemplate == Localization.GetString("NewTemplate", this.LocalResourceFile))
            {
                campaignTemplateComponent = new CampaignTemplateComponent(Guid.NewGuid());
                campaignTemplateComponent.CampaignTemplate.Created = DateTime.Now;
            }
            else
            {
                campaignTemplateComponent = new CampaignTemplateComponent(new Guid(ddCampaignTemplate.SelectedValue));
            }

            //Get values from the controls
            var url = NexsoHelper.GetCulturedUrlByTabName("cheese");
            var img = string.Format(@"<div style=""display:none""><img src=""{0}clog/idCampaignLog"" /></div>", url.Replace(".aspx", "/"));
            campaignTemplateComponent.CampaignTemplate.TemplateTitle = txtTemplateName.Text;
            campaignTemplateComponent.CampaignTemplate.TemplateVersion = campaignTemplateComponent.CampaignTemplate.TemplateVersion.GetValueOrDefault(0) + 1;
            campaignTemplateComponent.CampaignTemplate.TemplateContent = RadEditorTemplate.Content;
            campaignTemplateComponent.CampaignTemplate.Language = String.Format(rdTemplateLanguage.SelectedValue);
            campaignTemplateComponent.CampaignTemplate.Updated = DateTime.Now;
            campaignTemplateComponent.CampaignTemplate.Deleted = false;
            campaignTemplateComponent.CampaignTemplate.TemplateSubject = txtSubject.Text;
            if (campaignTemplateComponent.Save() > -1)
            {

                HiddenFieldMessage.Value = Localization.GetString("MessageTemplateSave", this.LocalResourceFile);
                ScriptManager.RegisterStartupScript(UpdatePanel1, UpdatePanel1.GetType(), "alert", "MessageAlert();", true);
                btnCloneTemplate.Visible = true;
            }
            //Load newly the current template 
            FillDataCampaignTemplate();
            foreach (RadComboBoxItem item in ddCampaignTemplate.Items)
            {
                if (item.Text.Equals(txtTemplateName.Text))
                    item.Selected = true;
            }
            ddCampaignTemplate.Text = txtTemplateName.Text;
            ddCampaignTemplate.SelectedValue = campaignTemplateComponent.CampaignTemplate.TemplateId.ToString();
            DataTemplate();
        }
    }

    /// <summary>
    /// It duplicates the template in the database
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnCloneTemplate_Click(object sender, EventArgs e)
    {
        if (Page.IsValid)
        {
            string nameTemplate = ddCampaignTemplate.Text;

            if (!nameTemplate.Equals(txtTemplateName.Text))
            {
                //New Template = Old TEmplate
                campaignTemplateComponent = new CampaignTemplateComponent(Guid.NewGuid());
                campaignTemplateComponent.CampaignTemplate.Created = DateTime.Now;
                var url = NexsoHelper.GetCulturedUrlByTabName("cheese");
                var img = string.Format(@"<div style=""display:none""><img src=""{0}clog/idCampaignLog"" /></div>",
                    url.Replace(".aspx", "/"));
                campaignTemplateComponent.CampaignTemplate.TemplateTitle = txtTemplateName.Text;
                campaignTemplateComponent.CampaignTemplate.TemplateVersion = 1;
                campaignTemplateComponent.CampaignTemplate.TemplateContent = RadEditorTemplate.Content;
                campaignTemplateComponent.CampaignTemplate.Language = String.Format(rdTemplateLanguage.SelectedValue);
                campaignTemplateComponent.CampaignTemplate.Updated = DateTime.Now;
                campaignTemplateComponent.CampaignTemplate.Deleted = false;
                campaignTemplateComponent.CampaignTemplate.TemplateSubject = txtSubject.Text;
                if (campaignTemplateComponent.Save() > -1)
                {
                    HiddenFieldMessage.Value = Localization.GetString("MessageTemplateSave", this.LocalResourceFile);
                    ScriptManager.RegisterStartupScript(UpdatePanel1, UpdatePanel1.GetType(), "alert", "MessageAlert();",
                        true);
                }
                //Load the new template
                FillDataCampaignTemplate();
                foreach (RadComboBoxItem item in ddCampaignTemplate.Items)
                {
                    if (item.Text.Equals(txtTemplateName.Text))
                        item.Selected = true;
                }
                ddCampaignTemplate.Text = txtTemplateName.Text;
                ddCampaignTemplate.SelectedValue = campaignTemplateComponent.CampaignTemplate.TemplateId.ToString();
                DataTemplate();
            }
            else
            {
                cvtxtTemplateName.IsValid = false;
            }
        }
    }

    /// <summary>
    /// Delete template related with the current campaign
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDeleteTemplate_Click(object sender, EventArgs e)
    {
        string nameTemplate = ddCampaignTemplate.Text;
        if (nameTemplate != Localization.GetString("NewTemplate", this.LocalResourceFile))
        {
            CampaignTemplateComponent objTemplate = new CampaignTemplateComponent(new Guid(ddCampaignTemplate.SelectedValue));
            objTemplate.CampaignTemplate.Updated = DateTime.Now;
            objTemplate.CampaignTemplate.Deleted = true;
            objTemplate.Save();
        }
        FillDataCampaignTemplate();
        divEditTemplate.Visible = false;
        divEditTemplate2.Visible = false;
        btnSaveTemplate.Visible = false;
        btnDeleteTemplate.Visible = false;
        ddCampaignTemplate.Text = string.Empty;
        ddCampaignTemplate.SelectedValue = string.Empty;
        ddCampaignTemplate.SelectedIndex = -1;
    }


    /// <summary>
    /// Collapse or expand the information of the template
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void linkButtonTemplate_Click(object sender, EventArgs e)
    {
        if (linkButtonTemplate.Attributes["collapse"] == "false")
        {
            divEditTemplate.Visible = false;
            divEditTemplate2.Visible = false;
            linkButtonTemplate.Text = Localization.GetString("ExpandTemplate", this.LocalResourceFile);
            linkButtonTemplate.Attributes["collapse"] = "true";
        }
        else
        {
            string nameTemplate = String.Format(ddCampaignTemplate.Text);
            divEditTemplate.Visible = true;
            divEditTemplate2.Visible = true;
            linkButtonTemplate.Text = Localization.GetString("CollapseTemplate", this.LocalResourceFile);
            linkButtonTemplate.Attributes["collapse"] = "false";
        }
    }
    #endregion

    #region Optional Interfaces
    public ModuleActionCollection ModuleActions
    {
        get
        {
            var actions = new ModuleActionCollection
                    {
                        {
                            GetNextActionID(), DotNetNuke.Services.Localization.Localization.GetString("EditModule", LocalResourceFile), "", "", "",
                            EditUrl(), false, SecurityAccessLevel.Edit, true, false
                        }
                    };
            return actions;
        }
    }
    #endregion

}