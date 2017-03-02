using System;
using System.IO;
using System.Globalization;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Xml;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text.RegularExpressions;
using System.Threading;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Entities.Users;
using DotNetNuke.Security;
using DotNetNuke.Services.Exceptions;
using DotNetNuke.Entities.Portals;
using DotNetNuke.Services.Localization;
using DotNetNuke.Common.Utilities;
using DotNetNuke.Common;
using NexsoProBLL;
using NexsoProDAL;
using Newtonsoft.Json;
using Formatting = System.Xml.Formatting;
using Telerik.Web.UI;
using System.Net;

partial class NZSolutionWizard_View : PortalModuleBase, IActionable
{

    #region Private Member Variables

    protected ChallengeComponent challengeComponent;
    private SolutionComponent solutionComponent;
    private OrganizationComponent organizationComponent;
    private ChallengeCustomDataComponent challengeCustomDataComponent;
    protected string Language = System.Globalization.CultureInfo.CurrentUICulture.Name;
    private bool verification;
    private bool copy;
    private bool reUse;
    private bool locK = false;
    private int AddSteps = 0;
    private List<Generic> listControls = new List<Generic>();

    #endregion

    #region Private Properties

    private Guid organizationId
    {
        get
        {
            if (ViewState["orgId"] != null)//if is comming from new form
            {
                try
                {
                    return (Guid)ViewState["orgId"];
                }
                catch
                {
                    throw;
                }

            }
            return Guid.Empty;
        }
        set { ViewState["orgId"] = value; }
    }
    private Guid solutionId
    {
        get
        {
            if (ViewState["solId"] != null)//if is comming from new form
            {
                try
                {
                    return (Guid)ViewState["solId"];
                }
                catch
                {
                    throw;
                }

            }
            return Guid.Empty;
        }

        set { ViewState["solId"] = value; }
    }

    #endregion

    #region Private Methods

    /// <summary>
    /// Load solution id, organization id, if the solution is verify, if the solution is to be copied or the if the solution is going to be reused
    /// </summary>
    private void LoadParams()
    {
        if (!string.IsNullOrEmpty(Request.QueryString["sl"]))
        {
            try
            {
                solutionId = new Guid(Request.QueryString["sl"]);
            }
            catch
            {
                throw;
            }
        }
        if (!string.IsNullOrEmpty(Request.QueryString["or"]))
        {
            try
            {
                organizationId = new Guid(Request.QueryString["or"]);
            }
            catch
            {
                throw;
            }
        }
        if (!string.IsNullOrEmpty(Request.QueryString["ver"]))
        {
            if (!string.IsNullOrEmpty(ValidateSecurity.ValidateString(Request.QueryString["ver"], false)))
            {
                try
                {
                    verification = Convert.ToBoolean(Request.QueryString["ver"]);
                }
                catch
                {
                    verification = false;

                }
            }
            else
            {
                throw new Exception();
            }
        }
        if (!string.IsNullOrEmpty(Request.QueryString["c"]))
        {
            if (!string.IsNullOrEmpty(ValidateSecurity.ValidateString(Request.QueryString["c"], false)))
            {
                try
                {
                    copy = Convert.ToBoolean(Request.QueryString["c"]);
                }
                catch
                {
                    throw;
                }
            }
            else
            {
                throw new Exception();
            }
        }
        if (!string.IsNullOrEmpty(Request.QueryString["r"]))
        {
            if (!string.IsNullOrEmpty(ValidateSecurity.ValidateString(Request.QueryString["r"], false)))
            {
                try
                {
                    reUse = Convert.ToBoolean(Request.QueryString["r"]);
                }
                catch
                {
                    throw;
                }
            }
            else
            {
                throw new Exception();
            }
        }


    }

    /// <summary>
    /// Enable and get text for the labels and buttons 
    /// </summary>
    private void PopulateLabels()
    {
        string dictionary = LocalResourceFile;
        if (!string.IsNullOrEmpty(challengeComponent.Challenge.Flavor))
        {
            if (challengeComponent.Challenge.Flavor != "Default")
                dictionary = LocalResourceFile + "Flavor" + challengeComponent.Challenge.Flavor;
        }
        //  AvailableResourcesDesc.Text = Localization.GetString("AvailableResourcesDesc", dictionary);
        //  BlockAdditionalInformationDesc.Text = Localization.GetString("BlockAdditionalInformationDesc", dictionary);
        //  BlockCostDetailsDesc.Text = Localization.GetString("BlockCostDetailsDesc", dictionary);
        //  BlockDurationDetailsDesc.Text = Localization.GetString("BlockDurationDetailsDesc", dictionary);
        //  BlockOrganizationBasicDetailsDesc.Text = Localization.GetString("BlockOrganizationBasicDetailsDesc", dictionary);
        lblLongDescriptionDesc.Text = Localization.GetString("LongDescriptionDesc", dictionary);
        lblBlockTitle.Text = Localization.GetString("BlockTitle", dictionary);
        lblBlockTitleDesc.Text = Localization.GetString("BlockTitleDesc", dictionary);
        lblBlockTitleDesc.Visible = lblBlockTitleDesc.Text != string.Empty;
        lblSubmissionTitle.Text = Localization.GetString("SubmissionTitle", dictionary);
        lblSubmissionTitleDesc.Text = Localization.GetString("SubmissionTitleDesc", dictionary);
        lblSubmissionTitleDesc.Visible = lblSubmissionTitleDesc.Text != string.Empty;
        lblShortDescription.Text = Localization.GetString("ShortDescription", dictionary);
        lblShortDescriptionDesc.Text = Localization.GetString("ShortDescriptionDesc", dictionary);
        lblShortDescriptionDesc.Visible = lblShortDescriptionDesc.Text != string.Empty;
        lblOrganizationAttached.Text = Localization.GetString("OrganizationAttached", dictionary);
        lblOrganizationAttachedDesc.Text = Localization.GetString("OrganizationAttachedDesc", dictionary);
        lblOrganizationAttachedDesc.Visible = lblOrganizationAttachedDesc.Text != string.Empty;
        lblChallenge.Text = Localization.GetString("Challenge", dictionary);
        lblChallengeDesc.Text = Localization.GetString("ChallengeDesc", dictionary);
        lblChallengeDesc.Visible = lblChallengeDesc.Text != string.Empty;
        lblBlockProblem.Text = Localization.GetString("BlockProblem", dictionary);
        lblBlockProblemDesc.Text = Localization.GetString("BlockProblemDesc", dictionary);
        lblBlockProblemDesc.Visible = lblBlockProblemDesc.Text != string.Empty;
        lblThemeDesc.Text = Localization.GetString("ThemeDesc", dictionary);
        lblThemeDesc.Visible = lblThemeDesc.Text != string.Empty;
        lblApproach.Text = Localization.GetString("Approach", dictionary);
        lblApproachDesc.Text = Localization.GetString("ApproachDesc", dictionary);
        lblApproachDesc.Visible = lblApproachDesc.Text != string.Empty;
        lblBlockInnovation.Text = Localization.GetString("BlockInnovation", dictionary);
        lblBlockInnovationDesc.Text = Localization.GetString("BlockInnovationDesc", dictionary);
        lblBlockInnovationDesc.Visible = lblBlockInnovationDesc.Text != string.Empty;
        lblBeneficiariesDesc.Text = Localization.GetString("BeneficiariesDesc", dictionary);
        lblBeneficiariesDesc.Visible = lblBeneficiariesDesc.Text != string.Empty;
        lblResults.Text = Localization.GetString("Results", dictionary);
        lblResultsDesc.Text = Localization.GetString("ResultsDesc", dictionary);
        lblResultsDesc.Visible = lblResultsDesc.Text != string.Empty;
        lblBlockBenefits.Text = Localization.GetString("BlockBenefits", dictionary);
        lblBlockBenefitsDesc.Text = Localization.GetString("BlockBenefitsDesc", dictionary);
        lblBlockBenefitsDesc.Visible = lblBlockBenefitsDesc.Text != string.Empty;
        lblDeliveryFormatDesc.Text = Localization.GetString("DeliveryFormatDesc", dictionary);
        lblDeliveryFormatDesc.Visible = lblDeliveryFormatDesc.Text != string.Empty;
        lblBlockDetails.Text = Localization.GetString("BlockDetails", dictionary);
        lblBlockDetailsDesc.Text = Localization.GetString("BlockDetailsDesc", dictionary);
        lblBlockDetailsDesc.Visible = lblBlockDetailsDesc.Text != string.Empty;
        lblImplementationDetails.Text = Localization.GetString("ImplementationDetails", dictionary);
        lblImplementationDetailsDesc.Text = Localization.GetString("ImplementationDetailsDesc", dictionary);
        lblImplementationDetailsDesc.Visible = lblImplementationDetailsDesc.Text != string.Empty;
        lblCostValue.Text = Localization.GetString("CostValue", dictionary);
        lblCostDesc.Text = Localization.GetString("CostDesc", dictionary);
        lblCostDesc.Visible = lblCostDesc.Text != string.Empty;
        lblCostDetails.Text = Localization.GetString("CostDetails", dictionary);
        lblCostDetailsDesc.Text = Localization.GetString("CostDetailsDesc", dictionary);
        lblCostDetailsDesc.Visible = lblCostDetailsDesc.Text != string.Empty;
        lblProjectDuration.Text = Localization.GetString("ProjectDuration", dictionary);
        lblProjectDurationDesc.Text = Localization.GetString("ProjectDurationDesc", dictionary);
        lblProjectDurationDesc.Visible = lblProjectDurationDesc.Text != string.Empty;
        lblDurationDetails.Text = Localization.GetString("DurationDetails", dictionary);
        lblDurationDetailsDesc.Text = Localization.GetString("DurationDetailsDesc", dictionary);
        lblDurationDetailsDesc.Visible = lblDurationDetailsDesc.Text != string.Empty;
        lblBlockEvidences.Text = Localization.GetString("BlockEvidences", dictionary);
        lblBlockEvidencesDesc.Text = Localization.GetString("BlockEvidencesDesc", dictionary);
        lblBlockEvidencesDesc.Visible = lblBlockEvidencesDesc.Text != string.Empty;
        lblSupportDocuments.Text = Localization.GetString("SupportDocuments", dictionary);
        lblSupportDocumentsDesc.Text = Localization.GetString("SupportDocumentsDesc", dictionary);
        lblSupportDocumentsDesc.Visible = lblSupportDocumentsDesc.Text != string.Empty;
        lblLocation.Text = Localization.GetString("Location", dictionary);
        lblLocationDesc.Text = Localization.GetString("LocationDesc", dictionary);
        lblLocationDesc.Visible = lblLocationDesc.Text != string.Empty;
        lblBlockFinish.Text = Localization.GetString("BlockFinish", dictionary);
        lblBlockFinishDesc.Text = Localization.GetString("BlockFinishDesc", dictionary);
        lblBlockFinishDesc.Visible = lblBlockFinishDesc.Text != string.Empty;
        lblTheme.Text = Localization.GetString("Theme", dictionary);
        lblBeneficiaries.Text = Localization.GetString("Beneficiaries", dictionary);
        lblDeliveryFormat.Text = Localization.GetString("DeliveryFormat", dictionary);
        imgWizardStep0.ImageUrl = GetLogo();
        imgWizardStep1.ImageUrl = GetLogo();
        imgWizardStep2.ImageUrl = GetLogo();
        imgWizardStep3.ImageUrl = GetLogo();
        imgWizardStep4.ImageUrl = GetLogo();
        imgWizardStep5.ImageUrl = GetLogo();
        imgWizardStep6.ImageUrl = GetLogo();


        rgvtxtApproach.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
        rgvtxtChallenge.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
        rgvtxtCostDetails.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
        rgvtxtDurationDetails.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
        rgvtxtImplementationDetails.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
        rgvtxtLongDescription.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
        rgvtxtResults.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
        rgvtxtShortDescription.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
        rgvtxtSubmissionTitle.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);

        if (challengeCustomDataComponent.ChallengeCustomData.ChallengeReference == "ImprovingLivesGrant2016")
        {
            lblDeliveryFormat.Visible = false;
            cblDeliveryFormat.Visible = false;
            cvcblDeliveryFormat.Visible = false;
        }

        if (challengeCustomDataComponent.ChallengeCustomData.ChallengeReference == "UrbanLabSantaMarta")
        {
            lblBeneficiaries.Visible = false;
            cblBeneficiaries.Visible = false;
            cvcblBeneficiaries.Visible = false;
            lblDeliveryFormat.Visible = false;
            cblDeliveryFormat.Visible = false;
            cvcblDeliveryFormat.Visible = false;
        }
    }
    private void BindData()
    {
        string h = HttpContext.Current.Request["language"];
        var list = ListComponent.GetListPerCategory("AvailableResource", Thread.CurrentThread.CurrentCulture.Name).ToList();
        var listEmptyItem = new NexsoProDAL.List();
        listEmptyItem.Value = "0";
        listEmptyItem.Label = Localization.GetString("SelectItem", LocalResourceFile);
        list.Insert(0, listEmptyItem);
        list = ListComponent.GetListPerCategory("Cost", Thread.CurrentThread.CurrentCulture.Name).ToList();
        list.Insert(0, listEmptyItem);
        ddlCost.DataSource = list;
        ddlCost.DataBind();
        list = ListComponent.GetListPerCategory("Theme", Thread.CurrentThread.CurrentCulture.Name).ToList();
        var themeFilter = string.Empty;
        if (Settings.Contains("ThemeFilter"))
            themeFilter = Settings["ThemeFilter"].ToString();
        if (themeFilter != string.Empty)
        {
            var split = themeFilter.Split(';');

            foreach (var element in split)
            {
                list.RemoveAll(x => x.Key == element);
            }
        }
        list = list.Where(x => !x.Key.Contains("ctm_")).ToList();
        cblTheme.DataSource = list.OrderBy(x => x.Order).ToList();
        cblTheme.DataBind();
        list = ListComponent.GetListPerCategory("DeliveryFormat", Thread.CurrentThread.CurrentCulture.Name).ToList();
        cblDeliveryFormat.DataSource = list;
        cblDeliveryFormat.DataBind();
        list = ListComponent.GetListPerCategory("Beneficiaries", Thread.CurrentThread.CurrentCulture.Name).ToList();
        var beneficiaryFilter = string.Empty;
        if (Settings.Contains("BeneficiaryFilter"))
            beneficiaryFilter = Settings["BeneficiaryFilter"].ToString();
        if (beneficiaryFilter != string.Empty)
        {
            var split = beneficiaryFilter.Split(';');
            foreach (var element in split)
            {
                list.RemoveAll(x => x.Key == element);
            }
        }
        list = list.Where(x => !x.Key.Contains("ctm_")).ToList();
        cblBeneficiaries.DataSource = list.OrderBy(x => x.Label).ToList();
        cblBeneficiaries.DataBind();
        list = ListComponent.GetListPerCategory("ProjectDuration", Thread.CurrentThread.CurrentCulture.Name).ToList();
        list.Insert(0, listEmptyItem);
        ddlProjectDuration.DataSource = list;
        ddlProjectDuration.DataBind();
        BindOrganizations();
        txtSubmissionTitle.Text = WebUtility.HtmlDecode(solutionComponent.Solution.Title);
        txtShortDescription.Text = WebUtility.HtmlDecode(solutionComponent.Solution.TagLine);
        ddlProjectDuration.SelectedValue = solutionComponent.Solution.Duration.ToString();
        txtDurationDetails.Text = WebUtility.HtmlDecode(solutionComponent.Solution.DurationDetails);
        txtChallenge.Text = WebUtility.HtmlDecode(solutionComponent.Solution.Challenge);
        txtApproach.Text = WebUtility.HtmlDecode(solutionComponent.Solution.Approach);
        txtResults.Text = WebUtility.HtmlDecode(solutionComponent.Solution.Results);
        ddlCost.SelectedValue = solutionComponent.Solution.CostType.ToString();
        double price = Convert.ToDouble(solutionComponent.Solution.Cost);
        CultureInfo info = CultureInfo.GetCultureInfo("en-US");
        string FormattedPrice = price.ToString("N", info); // 1,234.25
        txtCost.Text = FormattedPrice;
        txtCostDetails.Text = WebUtility.HtmlDecode(solutionComponent.Solution.CostDetails);
        txtImplementationDetails.Text = WebUtility.HtmlDecode(solutionComponent.Solution.ImplementationDetails);
        txtLongDescription.Text = WebUtility.HtmlDecode(solutionComponent.Solution.Description);

        SetChkControl("DeliveryFormat", cblDeliveryFormat);
        SetChkControl("Beneficiaries", cblBeneficiaries);
        SetChkControl("Theme", cblTheme);
        hfSelectedOrg.Value = organizationComponent.Organization.OrganizationID.ToString();
        if (organizationComponent.Organization.OrganizationID != Guid.Empty)
        {
            RadAutoCompleteBox1.Text = WebUtility.HtmlDecode(organizationComponent.Organization.Name);
            pnlOrganization.Visible = true;
        }
        else
        {
            pnlOrganization.Visible = false;
        }
        NZOrganization1.OrganizationId = organizationComponent.Organization.OrganizationID;
        NZOrganization1.EnabledButtons = true;
        NZOrganization1.LoadControl();
        SetupWizard(solutionComponent.Solution.SolutionState);
        setTitleCurrentStep(Wizard1.ActiveStepIndex);
        btnDeleteSolution.Visible = solutionComponent.Solution.SolutionId != Guid.Empty;
        if (challengeCustomDataComponent.ChallengeCustomData.ChallengeReference == "JPO2014")
            chkPublicationApproval.Visible = true;
        string url = NexsoHelper.GetCulturedUrlByTabName("ExplorePopUp") + "/ui/" + UserId + "?url=" + HttpContext.Current.Server.UrlEncode(DotNetNuke.Entities.Tabs.TabController.CurrentPage.FullUrl) + "&solprofile=" + HttpContext.Current.Server.UrlEncode(NexsoHelper.GetCulturedUrlByTabName("solprofile"));
        hlkOpenPopUp.NavigateUrl = url;
        if (PortalSettings.EnablePopUps)
        {
            hlkOpenPopUp.Attributes.Add("onclick", "return " + UrlUtils.PopUpUrl(url + "&popUp=false", this, PortalSettings, true, false, 620, 1200, false, ""));
        }
        bool swPopUp = false;
        if (solutionComponent.Solution.SolutionId == Guid.Empty)
        {
            var ListSolutions = SolutionComponent.GetAllSolutionPerUser(UserId).ToList().Where(x => x.Deleted != true);
            swPopUp = ListSolutions.Count() > 0;

        }
        hlkOpenPopUp.Visible = swPopUp;
    }

    private void BindDataChallenge()
    {
        switch (AddSteps)
        {
            case 1:
                var quantityScript2 = "addHeaderClass(\"custom2Header\");";
                ScriptManager.RegisterStartupScript(Wizard1, this.GetType(), "success2", quantityScript2, true);
                break;
            case 2:
                var quantityScript = "addHeaderClass(\"customHeader\");";
                ScriptManager.RegisterStartupScript(Wizard1, this.GetType(), "success", quantityScript, true);
                break;
        }

        //switch (challengeCustomDataComponent.ChallengeCustomData.ChallengeReference)
        //{
        //    case "JPO2014":


        //        break;
        //    case "AVINACITY2014":
        //    case "MISANGRE2014":
        //        break;
        //}
    }

    /// <summary>
    /// Load all the information of the organization in the NZOrganization Control
    /// </summary>
    private void SelectOrganizations()
    {
        string title = RadAutoCompleteBox1.Text;
        Guid selectedOrg = IsInList(title);
        if (selectedOrg != Guid.Empty)
        {
            pnlOrganization.Visible = true;
            NZOrganization1.OrganizationId = selectedOrg;
            hfSelectedOrg.Value = selectedOrg.ToString();
            NZOrganization1.EnabledButtons = false;
            NZOrganization1.LoadControl();
            // btnCreateOrganization.Visible = false;
            Button StepNextButton =
                (Button)Wizard1.FindControl("StepNavigationTemplateContainerID").FindControl("StepNextButton");
            //StepNextButton.Enabled = true;
        }
        else
        {
            NZOrganization1.OrganizationTitle = title;
            pnlOrganization.Visible = true;
            NZOrganization1.OrganizationId = Guid.Empty;
            NZOrganization1.EnabledButtons = false;
            NZOrganization1.LoadControl();
            hfSelectedOrg.Value = Guid.Empty.ToString();
            //  btnCreateOrganization.Visible = true;
            Button StepNextButton =
                (Button)Wizard1.FindControl("StepNavigationTemplateContainerID").FindControl("StepNextButton");
            //StepNextButton.Enabled = false;
            locK = true;
        }
    }

    /// <summary>
    /// Save in the database  the history of the  checkboxes selected by the user on each list
    /// </summary>
    /// <param name="listName"></param>
    /// <param name="checkBoxList"></param>
    private void SaveChkSolutionLog(string listName, CheckBoxList checkBoxList)
    {
        int count = 0;
        int countCheck = 0;

        var list = SolutionListComponent.GetListPerCategory(solutionId, listName);
        SolutionListJson solutionListJson = new SolutionListJson();
        List<string> listSol = new List<string>();
        foreach (var item in list)
        {
            countCheck = 0;
            foreach (ListItem itemCheck in checkBoxList.Items)
            {
                if (itemCheck.Selected)
                {
                    countCheck++;
                    if (itemCheck.Value == item.Key)
                        count++;
                }
            }
        }

        if (count != list.Count() && countCheck != count)
        {
            foreach (var itemL in list)
            {
                listSol.Add(itemL.Key);
            }

            solutionListJson.Type = "Select";
            solutionListJson.list = listSol;
            SaveSolutionLog(listName, "true", JsonConvert.SerializeObject(solutionListJson));

        }
    }

    /// <summary>
    /// Generates a copy of the solution with different ID and redirect to the new solution
    /// </summary>
    private void CopySolution()
    {
        SolutionComponent solutionComponentCopy = new SolutionComponent();
        solutionComponentCopy.Solution.OrganizationId = solutionComponent.Solution.OrganizationId;
        solutionComponentCopy.Solution.SolutionTypeId = solutionComponent.Solution.SolutionTypeId;
        solutionComponentCopy.Solution.Title = solutionComponent.Solution.Title + " (Copy)";
        solutionComponentCopy.Solution.TagLine = solutionComponent.Solution.TagLine;
        solutionComponentCopy.Solution.Description = solutionComponent.Solution.Description;
        solutionComponentCopy.Solution.Biography = solutionComponent.Solution.Biography;
        solutionComponentCopy.Solution.Challenge = solutionComponent.Solution.Challenge;
        solutionComponentCopy.Solution.Approach = solutionComponent.Solution.Approach;
        solutionComponentCopy.Solution.Results = solutionComponent.Solution.Results;
        solutionComponentCopy.Solution.ImplementationDetails = solutionComponent.Solution.ImplementationDetails;
        solutionComponentCopy.Solution.AdditionalCost = solutionComponent.Solution.AdditionalCost;
        solutionComponentCopy.Solution.AvailableResources = solutionComponent.Solution.AvailableResources;
        solutionComponentCopy.Solution.TimeFrame = solutionComponent.Solution.TimeFrame;
        solutionComponentCopy.Solution.Duration = solutionComponent.Solution.Duration;
        solutionComponentCopy.Solution.DurationDetails = solutionComponent.Solution.DurationDetails;
        solutionComponentCopy.Solution.SolutionStatusId = solutionComponent.Solution.SolutionStatusId;
        solutionComponentCopy.Solution.SolutionType = solutionComponent.Solution.SolutionType;
        solutionComponentCopy.Solution.Topic = solutionComponent.Solution.Topic;
        solutionComponentCopy.Solution.Language = solutionComponent.Solution.Language;
        solutionComponentCopy.Solution.CreatedUserId = UserId;
        solutionComponentCopy.Solution.Deleted = solutionComponent.Solution.Deleted;
        solutionComponentCopy.Solution.Country = solutionComponent.Solution.Country;
        solutionComponentCopy.Solution.Region = solutionComponent.Solution.Region;
        solutionComponentCopy.Solution.City = solutionComponent.Solution.City;
        solutionComponentCopy.Solution.Address = solutionComponent.Solution.Address;
        solutionComponentCopy.Solution.ZipCode = solutionComponent.Solution.ZipCode;
        solutionComponentCopy.Solution.Logo = solutionComponent.Solution.Logo;
        solutionComponentCopy.Solution.Cost1 = solutionComponent.Solution.Cost1;
        solutionComponentCopy.Solution.Cost2 = solutionComponent.Solution.Cost2;
        solutionComponentCopy.Solution.Cost3 = solutionComponent.Solution.Cost3;
        solutionComponentCopy.Solution.DeliveryFormat = solutionComponent.Solution.DeliveryFormat;
        solutionComponentCopy.Solution.Cost = solutionComponent.Solution.Cost;
        solutionComponentCopy.Solution.CostType = solutionComponent.Solution.CostType;
        solutionComponentCopy.Solution.CostDetails = solutionComponent.Solution.CostDetails;
        solutionComponentCopy.Solution.SolutionState = 0;
        solutionComponentCopy.Solution.Beneficiaries = solutionComponent.Solution.Beneficiaries;
        solutionComponentCopy.Solution.DateCreated = DateTime.Now;
        solutionComponentCopy.Solution.DateUpdated = DateTime.Now;
        solutionComponentCopy.Solution.ChallengeReference = challengeComponent.Challenge.ChallengeReference;
        solutionComponentCopy.Solution.CustomData = solutionComponent.Solution.CustomData;
        solutionComponentCopy.Solution.CustomDataTemplate = solutionComponent.Solution.CustomDataTemplate;
        solutionComponentCopy.Solution.CustomScore = solutionComponent.Solution.CustomScore;
        solutionComponentCopy.Solution.VideoObject = solutionComponent.Solution.VideoObject;
        solutionComponentCopy.Save();
        SaveChkControlCopy("Theme", solutionComponentCopy.Solution.SolutionId);
        SaveChkControlCopy("Beneficiaries", solutionComponentCopy.Solution.SolutionId);
        SaveChkControlCopy("DeliveryFormat", solutionComponentCopy.Solution.SolutionId);
        SaveFileSupportDocumentsCopy(solutionComponentCopy.Solution.SolutionId);
        SaveLocationsCopy(solutionComponentCopy.Solution.SolutionId);
        BannerSolutionCopy(solutionComponentCopy.Solution.SolutionId);
        sendEmailToUser("MailTemplateNewSolutionSubject", "MailTemplateNewSolution", 0, solutionComponentCopy);
        Response.Redirect(DotNetNuke.Entities.Tabs.TabController.CurrentPage.FullUrl + "/sl/" + solutionComponentCopy.Solution.SolutionId.ToString(), false);
    }

    /// <summary>
    /// Save in the database the list of selected checkboxes (copy solutions)
    /// </summary>
    /// <param name="listItem"></param>
    /// <param name="Idsolution"></param>
    /// <returns></returns>
    private void SaveChkControlCopy(string listItem, Guid Idsolution)
    {
        var list = SolutionListComponent.GetListPerCategory(solutionId, listItem);
        foreach (var item in list)
        {
            SolutionListComponent sol = new SolutionListComponent(Idsolution, item.Key, listItem);
            sol.Save();
        }
    }

    /// <summary>
    /// Generates a copy of the Documents (solution copy)
    /// </summary>
    /// <param name="idsolution"></param>
    private void SaveFileSupportDocumentsCopy(Guid idsolution)
    {
        var list = DocumentComponent.GetDocuments(solutionId);
        foreach (var item in list)
        {
            DocumentComponent documentComponent = new DocumentComponent(Guid.NewGuid());
            documentComponent.Document.ExternalReference = idsolution;
            documentComponent.Document.Title = item.Title;
            documentComponent.Document.Name = item.Name;
            documentComponent.Document.Size = item.Size;
            documentComponent.Document.DocumentObject = item.DocumentObject;
            documentComponent.Document.Created = DateTime.Now;
            documentComponent.Document.Updated = documentComponent.Document.Created;
            documentComponent.Document.Deleted = item.Deleted;
            documentComponent.Document.Status = item.Status;
            documentComponent.Document.Permission = item.Permission;
            documentComponent.Document.Description = item.Description;
            documentComponent.Document.FileType = item.FileType;
            documentComponent.Document.Version = 1;
            documentComponent.Document.Category = item.Category;
            documentComponent.Document.Author = item.Author;
            documentComponent.Document.Views = 0;
            documentComponent.Document.Scope = item.Scope;
            documentComponent.Document.UploadedBy = item.UploadedBy;
            documentComponent.Document.CreatedBy = item.CreatedBy;
            documentComponent.Document.Folder = item.Folder;
            documentComponent.Save();
        }
    }

    /// <summary>
    /// Generates a copy of the locations (solution copy)
    /// </summary>
    /// <param name="idsolution"></param>
    private void SaveLocationsCopy(Guid idsolution)
    {
        var list = SolutionLocationComponent.GetSolutionLocationsPerSolution(solutionId);
        foreach (var item in list)
        {
            var solutionLocation = new SolutionLocationComponent(idsolution, item.Country, item.Region, item.City, item.PostalCode,
                                              item.Address, Convert.ToDecimal(item.Latitude), Convert.ToDecimal(item.Longitude));
            solutionLocation.Save();
        }
    }

    /// <summary>
    /// Generates a copy of the banner (solution copy)
    /// </summary>
    /// <param name="idSolution"></param>
    private void BannerSolutionCopy(Guid idSolution)
    {
        try
        {
            if (File.Exists(
               Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/cropBig" + solutionId + ".jpg")))
            {
                File.Copy(
                    Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/cropBig" + solutionId + ".jpg"),
                    Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/cropBig" + idSolution +
                                   ".jpg"));
                File.Copy(
                  Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/cropBig" + solutionId + ".jpg"),
                  Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/" + idSolution +
                                 ".jpg"));
                File.Copy(
                  Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/cropBig" + solutionId + ".jpg"),
                  Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/cropThumb" + idSolution +
                                 ".jpg"));
            }
            else if (File.Exists(
                Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/cropBig" +
                               solutionId.ToString() +
                               ".png")))
            {
                File.Copy(
                    Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/cropBig" + solutionId) +
                    ".png",
                    Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/cropBig" + idSolution +
                                   ".png"));
                File.Copy(
                    Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/cropBig" + solutionId) +
                    ".png",
                    Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/" + idSolution +
                                   ".png"));
                File.Copy(
                    Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/cropBig" + solutionId) +
                    ".png",
                    Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/cropThumb" + idSolution +
                                   ".png"));
            }
        }
        catch
        {
            throw;
        }
    }

    /// <summary>
    /// Read XMl and convert  to asp.net controls
    /// </summary>
    /// <param name="xmlData"></param>
    private void XmlToControls(string xmlData)
    {
        if (!string.IsNullOrEmpty(xmlData))
        {
            var errorString = string.Empty;
            byte[] byteArray = new byte[xmlData.Length];
            System.Text.Encoding encoding = System.Text.Encoding.Unicode;
            byteArray = encoding.GetBytes(xmlData);
            // Load the memory stream
            MemoryStream memoryStream = new MemoryStream(byteArray);
            //XmlDocument doc = new XmlDocument();
            memoryStream.Seek(0, SeekOrigin.Begin);
            string KEY, VALUE, TYPE, CONTROLTYPE;
            if (byteArray.Length > 0)
            {
                try
                {
                    var reader = XmlReader.Create(memoryStream);
                    reader.MoveToContent();
                    while (reader.Read())
                    {
                        KEY = VALUE = TYPE = CONTROLTYPE = string.Empty;
                        List<string> LSTVALUES = new List<string>();
                        if (reader.NodeType == XmlNodeType.Element
                            && reader.Name == "FIELD")
                        {
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "KEY")
                                {
                                    KEY = reader.ReadString();
                                    break;
                                }
                            }
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                   reader.Name == "VALUES")
                                {
                                    while (reader.Read())
                                    {
                                        if (reader.NodeType == XmlNodeType.Element &&
                                            reader.Name == "VALUE")
                                        {
                                            LSTVALUES.Add(reader.ReadString());

                                        }
                                        if (reader.NodeType == XmlNodeType.EndElement &&
                                        reader.Name == "VALUES")
                                        {
                                            break;
                                        }
                                    }
                                    break;
                                }
                                else
                                {
                                    if (reader.NodeType == XmlNodeType.Element &&
                                           reader.Name == "VALUE")
                                    {
                                        LSTVALUES.Add(reader.ReadString());
                                        break;
                                    }
                                }
                            }
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "TYPE")
                                {
                                    TYPE = reader.ReadString();
                                    break;
                                }
                            }
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "CONTROLTYPE")
                                {
                                    CONTROLTYPE = reader.ReadString();
                                    break;
                                }
                            }

                            switch (CONTROLTYPE)
                            {
                                case "DropDown":
                                    {
                                        bool swDdTmp = false;
                                        DropDownList ddTmp = (DropDownList)Wizard1.FindControl("ddCustom" + KEY);
                                        if (ddTmp != null)
                                            swDdTmp = true;
                                        else
                                        {
                                            ddTmp = (DropDownList)Wizard1.FindControl(KEY);
                                            if (ddTmp != null)
                                                swDdTmp = true;
                                        }
                                        if (swDdTmp)
                                        {
                                            ListItem item;
                                            foreach (var itemL in LSTVALUES)
                                            {
                                                item = ddTmp.Items.FindByValue(itemL);
                                                if (item != null)
                                                    ddTmp.SelectedValue = itemL;
                                            }
                                        }
                                        break;
                                    }
                                case "TextBox":
                                    {
                                        bool swTxtTmp = false;
                                        TextBox txtTmp = (TextBox)Wizard1.FindControl("txtCustom" + KEY);
                                        if (txtTmp != null)
                                            swTxtTmp = true;
                                        else
                                        {
                                            txtTmp = (TextBox)Wizard1.FindControl(KEY);
                                            if (txtTmp != null)
                                                swTxtTmp = true;
                                        }
                                        if (swTxtTmp)
                                        {
                                            foreach (var item in LSTVALUES)
                                            {
                                                txtTmp.Text = item;
                                            }
                                            var css = txtTmp.CssClass;
                                            if (css.Contains("Video"))
                                            {
                                                if (!string.IsNullOrEmpty(challengeCustomDataComponent.ChallengeCustomData.CustomDataTemplate))
                                                {
                                                    if (txtTmp.Text != string.Empty && challengeCustomDataComponent.ChallengeCustomData.CustomDataTemplate.Contains(KEY) && (txtTmp.Text.Contains("youtube.com") || txtTmp.Text.Contains("youtu.be") || txtTmp.Text.Contains("vimeo.com")))
                                                    {
                                                        var quantityScript2 = "onChangeVideo('" + txtTmp.ClientID + "', '',false);";
                                                        ScriptManager.RegisterStartupScript(Wizard1, this.GetType(), "ChangeVideo", quantityScript2, true);
                                                    }
                                                }
                                            }
                                        }
                                        break;
                                    }
                                case "RadioButton":
                                    {
                                        bool swBb = false;
                                        RadioButtonList rb = (RadioButtonList)Wizard1.FindControl("rbCustom" + KEY);
                                        if (rb != null)
                                            swBb = true;
                                        else
                                        {
                                            rb = (RadioButtonList)Wizard1.FindControl(KEY);
                                            if (rb != null)
                                                swBb = true;
                                        }
                                        if (swBb)
                                        {
                                            ListItem item;
                                            foreach (var itemL in LSTVALUES)
                                            {
                                                var itemLL = itemL;
                                                if (Language == "es-ES" || Language == "pt-BR")
                                                {
                                                    if (itemLL == "Yes")
                                                        itemLL = "Si";
                                                }
                                                if (Language == "en-US")
                                                {
                                                    if (itemLL == "Si")
                                                        itemLL = "Yes";
                                                }
                                                item = rb.Items.FindByValue(itemLL);
                                                if (item != null)
                                                    rb.SelectedValue = itemLL;
                                            }
                                        }
                                        break;
                                    }

                                case "CheckBox":
                                    {
                                        bool swCb = false;
                                        CheckBoxList cb = (CheckBoxList)Wizard1.FindControl("cbCustom" + KEY);
                                        if (cb != null)
                                            swCb = true;
                                        else
                                        {
                                            cb = (CheckBoxList)Wizard1.FindControl(KEY);
                                            if (cb != null)
                                                swCb = true;
                                        }
                                        if (swCb)
                                        {
                                            ListItem item;
                                            foreach (var itemL in LSTVALUES)
                                            {
                                                item = cb.Items.FindByValue(itemL);
                                                if (item != null)
                                                    item.Selected = true;
                                            }
                                        }
                                        break;
                                    }
                                case "DateTime":
                                    {
                                        bool swDt = false;
                                        RadDatePicker dt = (RadDatePicker)Wizard1.FindControl("dtCustom" + KEY);
                                        if (dt != null)
                                            swDt = true;
                                        else
                                        {
                                            dt = (RadDatePicker)Wizard1.FindControl(KEY);
                                            if (dt != null)
                                                swDt = true;
                                        }
                                        if (swDt)
                                        {
                                            foreach (var item in LSTVALUES)
                                            {
                                                if (!string.IsNullOrEmpty(item))
                                                {
                                                    DateTime dataValue;
                                                    if (DateTime.TryParse(item, CultureInfo.InvariantCulture, DateTimeStyles.None, out dataValue))
                                                    {
                                                        DateTime dateTime = DateTime.Parse(item, CultureInfo.InvariantCulture, DateTimeStyles.None);
                                                        dt.SelectedDate = dateTime;
                                                    }
                                                    else
                                                    {
                                                        if (DateTime.TryParse(item, new CultureInfo("en-US"), DateTimeStyles.None, out dataValue))
                                                        {

                                                            DateTime dateTime = DateTime.Parse(item, new CultureInfo("en-US"), DateTimeStyles.None);
                                                            dt.SelectedDate = dateTime;
                                                        }
                                                        else
                                                        {
                                                            if (DateTime.TryParse(item, new CultureInfo("es-ES"), DateTimeStyles.None, out dataValue))
                                                            {

                                                                DateTime dateTime = DateTime.Parse(item, new CultureInfo("es-ES"), DateTimeStyles.None);
                                                                dt.SelectedDate = dateTime;
                                                            }
                                                            else
                                                            {
                                                                if (DateTime.TryParse(item, new CultureInfo("pt-BR"), DateTimeStyles.None, out dataValue))
                                                                {

                                                                    DateTime dateTime = DateTime.Parse(item, new CultureInfo("pt-BR"), DateTimeStyles.None);
                                                                    dt.SelectedDate = dateTime;
                                                                }
                                                            }
                                                        }
                                                    }
                                                }

                                            }
                                        }
                                        break;
                                    }
                                case "FileUploaderWizard":
                                    {
                                        FileUploaderWizard fu = (FileUploaderWizard)Wizard1.FindControl(KEY);
                                        if (fu != null)
                                        {
                                            fu.SolutionId = solutionComponent.Solution.SolutionId;
                                        }
                                        break;
                                    }

                            }
                        }
                    }
                }
                catch
                {
                    throw;
                }
            }
        }
    }

    /// <summary>
    /// Convert the list of the controls in XML
    /// </summary>
    /// <param name="challengeReference"></param>
    /// <returns></returns>
    private string ControlsToXmlData(string challengeReference)
    {
        string xmlString = null;
        listControls = (List<Generic>)ViewState["listControls"];
        if (listControls != null)
        {
            using (StringWriter sw = new StringWriter())
            {
                XmlTextWriter writer = new XmlTextWriter(sw);
                writer.Formatting = Formatting.None; // if you want it indented
                writer.WriteStartDocument(); // <?xml version="1.0" encoding="utf-16"?>
                writer.WriteStartElement("FIELDS"); //<TAG>

                foreach (var item in listControls)
                {
                    switch (item.Value)
                    {
                        case "DROPDOWNLIST":
                            {
                                writer.WriteStartElement("FIELD");
                                writer.WriteStartElement("KEY");
                                writer.WriteString(item.Id);
                                writer.WriteEndElement();
                                writer.WriteStartElement("VALUE");
                                if (Wizard1.FindControl(item.Id) != null)
                                {
                                    DropDownList dd = (DropDownList)Wizard1.FindControl(item.Id);
                                    writer.WriteString(Request.Form[dd.UniqueID] == null ? dd.SelectedValue : Request.Form[dd.UniqueID]);
                                }
                                writer.WriteEndElement();
                                writer.WriteStartElement("TYPE");
                                writer.WriteString("String");
                                writer.WriteEndElement();
                                writer.WriteStartElement("CONTROLTYPE");
                                writer.WriteString("DropDown");
                                writer.WriteEndElement();
                                writer.WriteEndElement();
                                break;
                            }
                        case "TEXTBOX":
                            {
                                writer.WriteStartElement("FIELD");
                                writer.WriteStartElement("KEY");
                                writer.WriteString(item.Id);
                                writer.WriteEndElement();
                                writer.WriteStartElement("VALUE");
                                if (Wizard1.FindControl(item.Id) != null)
                                {
                                    TextBox txt = (TextBox)Wizard1.FindControl(item.Id);
                                    writer.WriteString(Request.Form[txt.UniqueID] == null ? txt.Text : Request.Form[txt.UniqueID]);
                                }
                                writer.WriteEndElement();
                                writer.WriteStartElement("TYPE");
                                writer.WriteString("String");
                                writer.WriteEndElement();
                                writer.WriteStartElement("CONTROLTYPE");
                                writer.WriteString("TextBox");
                                writer.WriteEndElement();
                                writer.WriteEndElement();
                                break;
                            }

                        case "RADIOBUTTONLIST":
                            {
                                writer.WriteStartElement("FIELD");
                                writer.WriteStartElement("KEY");
                                writer.WriteString(item.Id);
                                writer.WriteEndElement();
                                writer.WriteStartElement("VALUE");
                                if (Wizard1.FindControl(item.Id) != null)
                                {
                                    RadioButtonList rb = (RadioButtonList)Wizard1.FindControl(item.Id);
                                    writer.WriteString(Request.Form[rb.UniqueID] == null ? rb.SelectedValue : Request.Form[rb.UniqueID]);
                                }
                                writer.WriteEndElement();
                                writer.WriteStartElement("TYPE");
                                writer.WriteString("String");
                                writer.WriteEndElement();
                                writer.WriteStartElement("CONTROLTYPE");
                                writer.WriteString("RadioButton");
                                writer.WriteEndElement();
                                writer.WriteEndElement();
                                break;
                            }
                        case "CHECKBOXLIST":
                            {
                                writer.WriteStartElement("FIELD");
                                writer.WriteStartElement("KEY");
                                writer.WriteString(item.Id);
                                writer.WriteEndElement();
                                writer.WriteStartElement("VALUES");
                                if (Wizard1.FindControl(item.Id) != null)
                                {
                                    int countSelected = 0;
                                    CheckBoxList cb = (CheckBoxList)Wizard1.FindControl(item.Id);
                                    foreach (ListItem itemL in cb.Items)
                                    {
                                        if (itemL.Selected)
                                        {
                                            writer.WriteStartElement("VALUE");
                                            writer.WriteString(itemL.Value);
                                            writer.WriteEndElement();
                                            countSelected++;
                                        }
                                    }
                                    var s = Request.Form[cb.UniqueID];
                                    if (countSelected == 0)
                                    {
                                        writer.WriteStartElement("VALUE");
                                        writer.WriteEndElement();
                                    }
                                }
                                else
                                {
                                    writer.WriteStartElement("VALUE");
                                    writer.WriteEndElement();
                                }
                                writer.WriteEndElement();
                                writer.WriteStartElement("TYPE");
                                writer.WriteString("String");
                                writer.WriteEndElement();
                                writer.WriteStartElement("CONTROLTYPE");
                                writer.WriteString("CheckBox");
                                writer.WriteEndElement();
                                writer.WriteEndElement();
                                break;
                            }
                        case "DATETIME":
                            {
                                writer.WriteStartElement("FIELD");
                                writer.WriteStartElement("KEY");
                                writer.WriteString(item.Id);
                                writer.WriteEndElement();
                                writer.WriteStartElement("VALUE");
                                if (Wizard1.FindControl(item.Id) != null)
                                {
                                    RadDatePicker dt = (RadDatePicker)Wizard1.FindControl(item.Id);
                                    if (!string.IsNullOrEmpty(dt.SelectedDate.ToString()))
                                    {
                                        string datetimeString = Convert.ToDateTime(dt.SelectedDate).ToUniversalTime().ToLongDateString();

                                        writer.WriteString(datetimeString);
                                    }
                                    else
                                    {
                                        if (!string.IsNullOrEmpty(Request.Form[dt.UniqueID]))
                                        {
                                            string datetimeString2 = Convert.ToDateTime(Request.Form[dt.UniqueID]).ToUniversalTime().ToLongDateString();
                                            writer.WriteString(datetimeString2);
                                        }
                                        else
                                            writer.WriteString("");
                                    }
                                }
                                writer.WriteEndElement();
                                writer.WriteStartElement("TYPE");
                                writer.WriteString("Date");
                                writer.WriteEndElement();
                                writer.WriteStartElement("CONTROLTYPE");
                                writer.WriteString("DateTime");
                                writer.WriteEndElement();
                                writer.WriteEndElement();
                                break;
                            }
                        case "FILEUPLOADERWIZARD":
                            {
                                FileUploaderWizard fu = (FileUploaderWizard)Wizard1.FindControl(item.Id);
                                if (fu != null)
                                {
                                    fu.SolutionId = solutionComponent.Solution.SolutionId;
                                }
                            }
                            break;
                    }
                }
                writer.WriteEndElement();
                writer.WriteEndDocument();
                xmlString = sw.ToString();
            }
        }
        return xmlString;
    }

    /// <summary>
    /// In step additional information the XML becomes in asp controls(different for each solution) . This allows to the users add additional information, different to the generic information
    /// </summary>
    /// <param name="xmlData"></param>
    private void XMLCreateControls(string xmlData)
    {
        if (!string.IsNullOrEmpty(xmlData))
        {
            ViewState["listControls"] = string.Empty;
            var errorString = string.Empty;
            byte[] byteArray = new byte[xmlData.Length];
            System.Text.Encoding encoding = System.Text.Encoding.Unicode;
            byteArray = encoding.GetBytes(xmlData);
            MemoryStream memoryStream = new MemoryStream(byteArray);
            memoryStream.Seek(0, SeekOrigin.Begin);
            string ID, TYPE, LABEL, REQUIRED, LENGTH, ATTRIBUTE, DESC, REGULAR, CUSTOM;
            if (byteArray.Length > 0)
            {
                try
                {
                    var reader = XmlReader.Create(memoryStream);
                    reader.MoveToContent();
                    while (reader.Read())
                    {
                        ID = TYPE = LABEL = REQUIRED = LENGTH = CUSTOM = ATTRIBUTE = DESC = REGULAR = string.Empty;
                        if (reader.NodeType == XmlNodeType.Element && reader.Name == "STEP")
                        {
                            WizardStepBase ws = new WizardStep();
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element && reader.Name == "ID")
                                {
                                    ws.ID = reader.ReadString();
                                    break;
                                }
                            }
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element && reader.Name == "TITLE")
                                {
                                    ws.Title = reader.ReadString();
                                    break;
                                }
                            }
                            ws.StepType = WizardStepType.Step;
                            Wizard1.WizardSteps.AddAt(Wizard1.WizardSteps.Count - 1, ws);
                            AddSteps++;
                            ws.Controls.Add(new LiteralControl("<div class='row'><div class='Counter'><div class='GlobalCounterContainer'></div><div class='Logo'>"));
                            string img = string.Format("<img src='{0}'></div></div>", GetLogo());
                            ws.Controls.Add(new LiteralControl(img));
                            ws.Controls.Add(new LiteralControl("<div class='wizard-form'>"));
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element && reader.Name == "FIELDSET")
                                {
                                    ws.Controls.Add(new LiteralControl("<fieldset>"));
                                    while (reader.Read())
                                    {
                                        if (reader.NodeType == XmlNodeType.Element && reader.Name == "LEGEND")
                                        {
                                            ws.Controls.Add(new LiteralControl("<legend>"));
                                            Label lb = new Label();
                                            lb.Text = reader.ReadString();
                                            ws.Controls.Add(lb);
                                            ws.Controls.Add(new LiteralControl("</legend>"));
                                            break;
                                        }
                                    }
                                    while (reader.Read())
                                    {
                                        if (reader.NodeType == XmlNodeType.Element && reader.Name == "DESCRIPTION")
                                        {
                                            ws.Controls.Add(new LiteralControl("<p class='introduction'>"));
                                            Label lb = new Label();
                                            lb.Text = reader.ReadString();
                                            ws.Controls.Add(lb);
                                            ws.Controls.Add(new LiteralControl("</p>"));
                                            break;
                                        }
                                    }
                                    while (reader.Read())
                                    {
                                        if (reader.NodeType == XmlNodeType.Element && reader.Name == "CONTROLS")
                                        {
                                            while (reader.Read())
                                            {
                                                if (reader.NodeType == XmlNodeType.Element && reader.Name == "CONTROL")
                                                {
                                                    List<Generic> ATTRIBUTES = new List<Generic>();
                                                    while (reader.Read())
                                                    {
                                                        if (reader.NodeType == XmlNodeType.Element && reader.Name == "ID")
                                                        {
                                                            ID = reader.ReadString();
                                                            break;
                                                        }
                                                    }

                                                    while (reader.Read())
                                                    {
                                                        if (reader.NodeType == XmlNodeType.Element && reader.Name == "TYPE")
                                                        {
                                                            ATTRIBUTES.Add(new Generic() { Id = "TextMode", Value = reader.GetAttribute("TextMode") });
                                                            ATTRIBUTES.Add(new Generic() { Id = "CssClass", Value = reader.GetAttribute("CssClass") });
                                                            ATTRIBUTES.Add(new Generic() { Id = "folder", Value = reader.GetAttribute("folder") });
                                                            ATTRIBUTES.Add(new Generic() { Id = "ShowFileCategories", Value = reader.GetAttribute("ShowFileCategories") });
                                                            ATTRIBUTES.Add(new Generic() { Id = "DefaultCategory", Value = reader.GetAttribute("DefaultCategory") });
                                                            ATTRIBUTES.Add(new Generic() { Id = "DocumentDefaultMode", Value = reader.GetAttribute("DocumentDefaultMode") });
                                                            ATTRIBUTES.Add(new Generic() { Id = "TextTitle", Value = reader.GetAttribute("TextTitle") });
                                                            ATTRIBUTES.Add(new Generic() { Id = "TextTitleValidator", Value = reader.GetAttribute("TextTitleValidator") });
                                                            ATTRIBUTES.Add(new Generic() { Id = "Maximum", Value = reader.GetAttribute("Maximum") });
                                                            TYPE = reader.ReadString();
                                                            break;
                                                        }
                                                    }

                                                    List<Generic> OPTIONS = new List<Generic>();
                                                    while (reader.Read())
                                                    {
                                                        if (reader.NodeType == XmlNodeType.Element && reader.Name == "OPTIONS")
                                                        {
                                                            while (reader.Read())
                                                            {
                                                                if (reader.NodeType == XmlNodeType.Element && reader.Name == "OPTION")
                                                                {
                                                                    string value = "";
                                                                    string text = "";
                                                                    while (reader.Read())
                                                                    {
                                                                        if (reader.NodeType == XmlNodeType.Element && reader.Name == "VALUE")
                                                                        {
                                                                            if (!string.IsNullOrEmpty(reader.GetAttribute("Selected")))
                                                                            {
                                                                                if (reader.GetAttribute("Selected") == "true")
                                                                                {
                                                                                    ATTRIBUTES.Add(new Generic() { Id = "Selected", Value = reader.ReadString() });
                                                                                }
                                                                            }
                                                                            value = reader.ReadString();

                                                                        }
                                                                        if (reader.NodeType == XmlNodeType.Element && reader.Name == "TEXT")
                                                                        {
                                                                            text = reader.ReadString();
                                                                        }
                                                                        if (reader.NodeType == XmlNodeType.EndElement && reader.Name == "OPTION")
                                                                        {
                                                                            break;
                                                                        }
                                                                    }
                                                                    if (value != string.Empty || text != string.Empty)
                                                                    {
                                                                        OPTIONS.Add(new Generic() { Id = value, Value = text });
                                                                    }
                                                                }
                                                                if (reader.NodeType == XmlNodeType.EndElement && reader.Name == "OPTIONS")
                                                                {
                                                                    break;
                                                                }
                                                            }
                                                            break;
                                                        }
                                                    }

                                                    while (reader.Read())
                                                    {
                                                        if (reader.NodeType == XmlNodeType.Element && reader.Name == "LABEL")
                                                        {
                                                            ATTRIBUTES.Add(new Generic() { Id = "Visible", Value = reader.GetAttribute("Visible") });
                                                            LABEL = reader.ReadString();
                                                            break;
                                                        }
                                                    }
                                                    while (reader.Read())
                                                    {
                                                        if (reader.NodeType == XmlNodeType.Element && reader.Name == "REQUIRED")
                                                        {
                                                            ATTRIBUTES.Add(new Generic() { Id = "Class", Value = reader.GetAttribute("Class") });
                                                            REQUIRED = reader.ReadString();
                                                            break;
                                                        }
                                                    }
                                                    while (reader.Read())
                                                    {
                                                        if (reader.NodeType == XmlNodeType.Element && reader.Name == "DESC")
                                                        {
                                                            DESC = reader.ReadString();
                                                            break;
                                                        }
                                                    }
                                                    while (reader.Read())
                                                    {
                                                        if (reader.NodeType == XmlNodeType.Element && reader.Name == "REGULAR")
                                                        {
                                                            ATTRIBUTES.Add(new Generic() { Id = "ValidationExpression", Value = reader.GetAttribute("ValidationExpression") });
                                                            REGULAR = reader.ReadString();
                                                            break;
                                                        }
                                                    }
                                                    while (reader.Read())
                                                    {
                                                        if (reader.NodeType == XmlNodeType.Element && reader.Name == "CUSTOM")
                                                        {
                                                            ATTRIBUTES.Add(new Generic() { Id = "Class", Value = reader.GetAttribute("Class") });
                                                            ATTRIBUTES.Add(new Generic() { Id = "Id", Value = reader.GetAttribute("Id") });
                                                            ATTRIBUTES.Add(new Generic() { Id = "required", Value = reader.GetAttribute("required") });
                                                            CUSTOM = reader.ReadString();
                                                            break;
                                                        }
                                                    }
                                                    while (reader.Read())
                                                    {
                                                        if (reader.NodeType == XmlNodeType.Element && reader.Name == "LENGTH")
                                                        {
                                                            LENGTH = reader.ReadString();

                                                            break;
                                                        }
                                                    }
                                                    CreatedControl(ws, ID, TYPE, OPTIONS, LABEL, REQUIRED, LENGTH, ATTRIBUTES, DESC, REGULAR, CUSTOM);
                                                }

                                                if (reader.NodeType == XmlNodeType.EndElement && reader.Name == "CONTROLS")
                                                {
                                                    break;
                                                }
                                            }
                                        }
                                        if (reader.NodeType == XmlNodeType.EndElement && reader.Name == "CONTROLS")
                                        {
                                            break;
                                        }
                                    }
                                    ws.Controls.Add(new LiteralControl("</fieldset>"));
                                }
                                if (reader.NodeType == XmlNodeType.EndElement && reader.Name == "FIELDSETS")
                                {
                                    break;
                                }
                            }

                            ws.Controls.Add(new LiteralControl("</div></div>"));
                        }
                    }
                    SetupWizard(solutionComponent.Solution.SolutionState);
                    XmlToControls(solutionComponent.Solution.CustomData);
                }
                catch
                {
                    throw;
                }
            }
        }
    }

    /// <summary>
    /// Create asp.net controls (Questions) predefined by the team
    /// </summary>
    /// <param name="ws"></param>
    /// <param name="id"></param>
    /// <param name="type"></param>
    /// <param name="options"></param>
    /// <param name="label"></param>
    /// <param name="required"></param>
    /// <param name="length"></param>
    /// <param name="attributes"></param>
    /// <param name="desc"></param>
    /// <param name="regular"></param>
    /// <param name="custom"></param>
    private void CreatedControl(WizardStepBase ws, string id, string type, List<Generic> options, string label, string required, string length, List<Generic> attributes, string desc, string regular, string custom)
    {
        if (type != "FILEUPLOADERWIZARD")
        {
            ws.Controls.Add(new LiteralControl("<div class='field'><label>"));
            Label lbl = new Label();
            if (GetAttribute("Visible", attributes) != "false")
            {
                lbl.Text = label;
            }
            ws.Controls.Add(lbl);
            ws.Controls.Add(new LiteralControl("</label><div>"));

        }
        switch (type)
        {
            case "TEXTBOX":
                TextBox txt = new TextBox();
                txt.ID = id;
                if (GetAttribute("TextMode", attributes) == "MultiLine")
                {
                    txt.TextMode = System.Web.UI.WebControls.TextBoxMode.MultiLine;
                }
                txt.CssClass = GetAttribute("CssClass", attributes);
                if (GetAttribute("TextMode", attributes) == "Video")
                {
                    txt.CssClass = "Video";
                    txt.Attributes.Add("onChange", "onChangeVideo('',this,true);");
                }

                if (!string.IsNullOrEmpty(length))
                {
                    txt.CssClass = txt.CssClass + " words";
                    string txtMaxlength = Localization.GetString("Maxlength", LocalResourceFile).Replace("{m}", length).Replace("{r}", "0");
                    var span = new HtmlGenericControl("span");
                    span.InnerHtml = txtMaxlength;
                    span.Attributes["class"] = "maxlength-feedback";
                    span.ID = "words" + txt.ClientID;
                    ws.Controls.Add(txt);
                    ws.Controls.Add(span);
                    txt.Attributes.Add("onkeydown", "WordCount(this,'" + length + "')");
                    txt.Attributes.Add("onkeyup", "WordCount(this,'" + length + "')");
                }
                else
                    ws.Controls.Add(txt);
                break;

            case "DATETIME":
                RadDatePicker dt = new RadDatePicker();
                dt.ID = id;
                //dt.MinDate = Convert.ToDateTime("01/01/1950");
                dt.MinDate = DateTime.Parse("01/01/1950", CultureInfo.InvariantCulture, DateTimeStyles.None);
                ws.Controls.Add(dt);

                break;
            case "RADIOBUTTONLIST":
                RadioButtonList rb = new RadioButtonList();
                rb.ID = id;
                rb.DataValueField = "Id";
                rb.DataTextField = "Value";
                ws.Controls.Add(rb);
                rb.DataSource = options;
                rb.DataBind();
                rb.CssClass = GetAttribute("CssClass", attributes);
                if (!string.IsNullOrEmpty(GetAttribute("Selected", attributes)))
                {
                    if (rb.Items.FindByValue(GetAttribute("Selected", attributes)) != null)
                        rb.SelectedValue = GetAttribute("Selected", attributes);
                }


                break;

            case "CHECKBOXLIST":
                CheckBoxList cb = new CheckBoxList();
                cb.ID = id;
                cb.DataValueField = "Id";
                cb.DataTextField = "Value";
                ws.Controls.Add(cb);
                cb.DataSource = options;
                cb.DataBind();
                cb.CssClass = GetAttribute("CssClass", attributes);
                break;


            case "DROPDOWNLIST":
                DropDownList dd = new DropDownList();
                dd.ID = id;
                dd.DataValueField = "Id";
                dd.DataTextField = "Value";
                ws.Controls.Add(dd);
                var listEmptyItem = new Generic();
                listEmptyItem.Id = "0";
                listEmptyItem.Value = Localization.GetString("SelectItem", LocalResourceFile);
                options.Insert(0, listEmptyItem);
                dd.DataSource = options;
                dd.DataBind();
                dd.CssClass = GetAttribute("CssClass", attributes);
                break;

            case "FILEUPLOADERWIZARD":
                ws.Controls.Add(new LiteralControl("<div class='field rdControl'><label>"));
                Label lbl2 = new Label();
                lbl2.Text = label;
                ws.Controls.Add(lbl2);
                ws.Controls.Add(new LiteralControl("</label><div>"));
                FileUploaderWizard fuw = (FileUploaderWizard)Page.LoadControl("DesktopModules/Nexso/NXOtherControls/FileUploaderWizard.ascx");
                fuw.ID = id;
                var val = string.Empty;
                val = GetAttribute("Maximum", attributes);
                if (!string.IsNullOrEmpty(val))
                    fuw.Maximum = Convert.ToInt32(val);
                val = GetAttribute("TextTitle", attributes);
                if (!string.IsNullOrEmpty(val))
                    fuw.TextTitle = val;
                val = GetAttribute("TextTitleValidator", attributes);
                if (!string.IsNullOrEmpty(val))
                    fuw.TextTitleValidator = val;
                val = GetAttribute("folder", attributes);
                if (!string.IsNullOrEmpty(val))
                    fuw.Folder = val;
                val = GetAttribute("ShowFileCategories", attributes);
                if (!string.IsNullOrEmpty(val))
                    fuw.ShowFileCategories = Convert.ToBoolean(val);
                val = GetAttribute("DefaultCategory", attributes);
                if (!string.IsNullOrEmpty(val))
                    fuw.DefaultCategory = val;
                val = GetAttribute("DocumentDefaultMode", attributes);
                if (!string.IsNullOrEmpty(val))
                    fuw.DocumentDefaultMode = val;
                fuw.SolutionId = solutionComponent.Solution.SolutionId;
                ws.Controls.Add(fuw);
                break;

        }
        ws.Controls.Add(new LiteralControl("</div>"));
        if (type != "FILEUPLOADERWIZARD" && type != "CHECKBOXLIST")
        {
            if (!string.IsNullOrEmpty(required))
            {
                //Create RequiredFieldValidator
                ws.Controls.Add(new LiteralControl("<div class='rfv'>"));
                RequiredFieldValidator rfv = new RequiredFieldValidator();
                rfv.Text = required;
                rfv.ErrorMessage = required;
                rfv.ControlToValidate = id;
                rfv.CssClass = GetAttribute("Class", attributes);
                if (type == "DROPDOWNLIST")
                    rfv.InitialValue = "0";
                ws.Controls.Add(rfv);
                ws.Controls.Add(new LiteralControl("</div>"));
            }
            if (!string.IsNullOrEmpty(custom))
            {
                if (!string.IsNullOrEmpty(GetAttribute("Id", attributes)))
                {
                    //Create CustomValidator
                    ws.Controls.Add(new LiteralControl("<div class='rfv'>"));
                    Label rfv = new Label();
                    rfv.ID = GetAttribute("Id", attributes);
                    rfv.Text = custom;
                    rfv.CssClass = GetAttribute("Class", attributes);
                    Visible = false;
                    ws.Controls.Add(rfv);
                    ws.Controls.Add(new LiteralControl("</div>"));
                }

            }
            if (!string.IsNullOrEmpty(regular))
            {
                //Create RegularExpressionValidator
                ws.Controls.Add(new LiteralControl("<div class='rfv'>"));
                RegularExpressionValidator rfv = new RegularExpressionValidator();
                var val = GetAttribute("ValidationExpression", attributes);
                if (!string.IsNullOrEmpty(val))
                    rfv.ValidationExpression = val;
                rfv.Text = regular;
                rfv.ErrorMessage = regular;
                rfv.ControlToValidate = id;
                rfv.CssClass = GetAttribute("Class", attributes);
                ws.Controls.Add(rfv);
                ws.Controls.Add(new LiteralControl("</div>"));
            }
        }
        else
        {
            if (!string.IsNullOrEmpty(GetAttribute("Id", attributes)))
            {
                ws.Controls.Add(new LiteralControl("<div class='rfv'>"));
                CustomValidator rfv = new CustomValidator();
                rfv.ID = GetAttribute("Id", attributes);
                rfv.Text = custom;
                rfv.CssClass = GetAttribute("Class", attributes);
                if (type == "CHECKBOXLIST")
                {
                    rfv.ClientValidationFunction = "ValidateCheckBoxList";
                    rfv.ErrorMessage = custom;
                }
                else
                {
                    rfv.Attributes.Add("required", GetAttribute("required", attributes));
                }
                ws.Controls.Add(rfv);
                ws.Controls.Add(new LiteralControl("</div>"));
            }
        }

        if (!string.IsNullOrEmpty(desc))
        {
            ws.Controls.Add(new LiteralControl("<div class='support-text'>"));
            Label lblDes = new Label();
            lblDes.Text = desc;
            ws.Controls.Add(lblDes);
            ws.Controls.Add(new LiteralControl("</div>"));
        }
        ws.Controls.Add(new LiteralControl("</div>"));
        listControls.Add(new Generic() { Id = id, Value = type });
        ViewState["listControls"] = listControls;
    }
    private string GetAttribute(string id, List<Generic> list)
    {
        foreach (var it in list)
        {
            if (it.Id == id)
                return it.Value;
        }
        return string.Empty;
    }

    /// <summary>
    /// It allows you to modify the current solution (Even if published)
    /// </summary>
    private void ReUseSolution()
    {
        if (!string.IsNullOrEmpty(solutionComponent.Solution.CustomData))
            SaveCustomDataLog("CustomData", ControlsToXmlData(""), solutionComponent.Solution.CustomData, true);

        if (solutionComponent.Solution.ChallengeReference != challengeComponent.Challenge.ChallengeReference)
        {
            solutionComponent.Solution.SolutionState = 0;
            solutionComponent.Solution.ChallengeReference = challengeComponent.Challenge.ChallengeReference;
        }
        solutionComponent.Save();
        Response.Redirect(DotNetNuke.Entities.Tabs.TabController.CurrentPage.FullUrl + "/sl/" + solutionComponent.Solution.SolutionId.ToString(), false);
    }

    /// <summary>
    /// Enable click action on button (circle) in the sidebar
    /// </summary>
    /// <returns></returns>
    protected bool EnableLinkButton()
    {
        return solutionComponent.Solution.DatePublished != null;
    }

    /// <summary>
    /// Returns the maximum length of letters for each textbox
    /// </summary>
    /// <param name="field"></param>
    /// <returns></returns>
    protected int GetMaxLenght(string field)
    {
        switch (field)
        {
            case "txtImplementationDetails":
                {
                    if (solutionComponent.Solution.Description == null)
                        return 135;
                    return 75;
                }
            default:
                return 0;
        }
    }

    /// <summary>
    /// Load all organization in autocomplete box (step 1)
    /// </summary>
    private void LoadAutocompleteControl()
    {
        var orgList = OrganizationComponent.GetOrganizations().OrderBy(a => a.Name).ToList();
        List<Organization> listAux = new List<Organization>();
        foreach (var item in orgList)
        {
            item.Name = WebUtility.HtmlDecode(item.Name);
            listAux.Add(item);
        }
        RadAutoCompleteBox1.DataSource = listAux;
        RadAutoCompleteBox1.DataTextField = "Name";
        RadAutoCompleteBox1.DataValueField = "OrganizationId";
        RadAutoCompleteBox1.DataBind();
        RadAutoCompleteBox1.EmptyMessage = Localization.GetString("AutocompleteMessage",
                                                  LocalResourceFile);
    }

    /// <summary>
    /// Return GUID (organizatión ID)
    /// </summary>
    /// <param name="name"></param>
    /// <returns></returns>
    private Guid IsInList(string name)
    {
        IQueryable<Organization> orgList = OrganizationComponent.GetOrganizations();
        var res = orgList.Where(p => p.Name == name);
        var org = res.FirstOrDefault();
        if (org != null)
        {
            return org.OrganizationID;
        }
        else
        {
            return Guid.Empty;
        }
    }

    /// <summary>
    /// Count the words entered by the user in the different fields of solution wizard
    /// </summary>
    /// <returns></returns>
    protected int GlobalCounterWords()
    {
        int retunr = countWords(txtApproach.Text)
               + countWords(txtChallenge.Text)
               + countWords(txtCostDetails.Text)
               + countWords(txtLongDescription.Text)
               + countWords(txtDurationDetails.Text)
               + countWords(txtImplementationDetails.Text)
               + countWords(txtShortDescription.Text)
               + countWords(txtSubmissionTitle.Text)
               + countWords(txtResults.Text);
        return retunr;
    }

    private int countWords(string input)
    {
        if (!string.IsNullOrEmpty(input))
        {
            return Regex.Matches(input, @"[\S]+").Count;
        }
        else
        {
            return 0;
        }
    }

    /// <summary>
    /// Redirect page profile of the solution, if already published. Else lets the user in the wizard
    /// </summary>
    private void interceptWizard()
    {
        if (solutionComponent.Solution != null)
        {
            if (solutionComponent.Solution.SolutionState > 800)
            {
                Response.Redirect(NexsoHelper.GetCulturedUrlByTabName("solprofile") + "/sl/" + solutionComponent.Solution.SolutionId.ToString(), false);
            }
            if (!string.IsNullOrEmpty(solutionComponent.Solution.ChallengeReference) && !string.IsNullOrEmpty(challengeComponent.Challenge.ChallengeReference))
            {
                if (solutionComponent.Solution.ChallengeReference != challengeComponent.Challenge.ChallengeReference)
                {
                    ChallengeComponent challengeComponent2 = new ChallengeComponent(solutionComponent.Solution.ChallengeReference);

                    if (!string.IsNullOrEmpty(challengeComponent2.Challenge.Url))
                    {
                        var url = string.Empty;
                        var objTabController = new DotNetNuke.Entities.Tabs.TabController();
                        int n;
                        bool sw = int.TryParse(challengeComponent2.Challenge.Url, out n);
                        if (sw)
                        {
                            var culturedTab = objTabController.GetTabByCulture(Convert.ToInt32(challengeComponent2.Challenge.Url),
                                PortalController.GetCurrentPortalSettings().PortalId, LocaleController.Instance.GetCurrentLocale
                                (PortalController.GetCurrentPortalSettings().PortalId));
                            if (culturedTab != null)
                                url = Globals.NavigateURL(culturedTab.TabID);
                        }
                        if (url != string.Empty)
                            Response.Redirect(url + "/sl/" + solutionComponent.Solution.SolutionId.ToString(), false);
                        else
                            Response.Redirect(NexsoHelper.GetCulturedUrlByTabName(challengeComponent2.Challenge.Url) +
                           "/sl/" + solutionComponent.Solution.SolutionId.ToString(), false);
                    }
                }
            }
        }
    }

    /// <summary>
    /// Add to map the locations where the solution is implemented
    /// </summary>
    /// <param name="solutionId"></param>
    private void bindLocationControl(Guid solutionId)
    {
        List<SolutionLocation> solutionLocationList;
        solutionLocationList = SolutionLocationComponent.GetSolutionLocationsPerSolution(solutionId).ToList();
        List<CountryStateCityV2.Location> listLocation = new List<CountryStateCityV2.Location>();
        foreach (var location in solutionLocationList)
        {
            listLocation.Add(new CountryStateCityV2.Location()
            {
                city = location.City,
                state = location.Region,
                country = location.Country,
                latitude = location.Latitude.GetValueOrDefault(0),
                longitude = location.Longitude.GetValueOrDefault(0),
                postal_code = location.PostalCode,
                inputAddress = location.Address
            });
            CountryStateCityEditMode.Locations = listLocation;
            CountryStateCityEditMode.UpdateMap();
        }


    }

    /// <summary>
    /// Load text to the principal buttons 
    /// </summary>
    /// <param name="step"></param>
    private void SetupWizard(int? step)
    {
        Wizard1.StartNextButtonStyle.CssClass = "btn step-start";
        Wizard1.CancelButtonStyle.CssClass = "btn step-cancel";
        Wizard1.StepPreviousButtonStyle.CssClass = "btn step-back";
        Wizard1.FinishCompleteButtonStyle.CssClass = "btn step-finish";
        Wizard1.StepNextButtonStyle.CssClass = "btn step-forward";
        Wizard1.FinishPreviousButtonStyle.CssClass = "btn step-back";
        Wizard1.StartNextButtonText = Localization.GetString("AcceptTerms",
                                                             LocalResourceFile);
        Wizard1.FinishPreviousButtonText = Localization.GetString("Previous",
                                                                  LocalResourceFile);
        Wizard1.StepNextButtonText = Localization.GetString("Next",
                                                            LocalResourceFile);
        Wizard1.StepPreviousButtonText = Localization.GetString("Previous",
                                                                LocalResourceFile);
        Wizard1.CancelButtonText = Localization.GetString("Cancel",
                                                          LocalResourceFile);
        string dictionary = LocalResourceFile;
        if (!string.IsNullOrEmpty(challengeComponent.Challenge.Flavor))
        {
            if (challengeComponent.Challenge.Flavor != "Default")
                dictionary = LocalResourceFile + "Flavor" + challengeComponent.Challenge.Flavor;
        }
        Wizard1.FinishCompleteButtonText = Localization.GetString("Finish",
                                                                 dictionary);
        WizardStep0.Title = Localization.GetString("Step0",
                                                   dictionary);
        WizardStep1.Title = Localization.GetString("Step1",
                                                   dictionary);
        WizardStep2.Title = Localization.GetString("Step2",
                                                   dictionary);
        WizardStep3.Title = Localization.GetString("Step3",
                                                   dictionary);
        WizardStep4.Title = Localization.GetString("Step4",
                                                   dictionary);
        WizardStep5.Title = Localization.GetString("Step5",
                                                   dictionary);
        WizardStep6.Title = Localization.GetString("Step6",
                                                  dictionary);
        var tmpStep = step ?? default(int);
        if (tmpStep >= Wizard1.WizardSteps.Count)
            tmpStep = 0;
        Wizard1.ActiveStepIndex = tmpStep;
    }

    private void setTitleCurrentStep(int index)
    {
        //Image imgHeader =
        //        (Image)Wizard1.FindControl("HeaderContainer").FindControl("imgHeader");
        //if (index != 0)
        //{
        //    imgHeader.Visible = true;

        //    imgHeader.ImageUrl = Request.Url.AbsoluteUri.Replace(Request.Url.PathAndQuery,"") + ControlPath + "Images/WizardHeader" +
        //                         Wizard1.ActiveStepIndex + "." + Thread.CurrentThread.CurrentCulture + ".png";
        //}
        //else
        //{
        //    imgHeader.Visible = false;
        //}
    }

    /// <summary>
    /// Get value from local resource
    /// </summary>
    /// <param name="key"></param>
    /// <returns></returns>
    protected string GetFromDictionary(string key)
    {
        return Localization.GetString(key, LocalResourceFile);
    }

    /// <summary>
    /// Load class for the ítems of the sidebar
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
        int stepIndex = Wizard1.WizardSteps.IndexOf(step);

        if (stepIndex < Wizard1.ActiveStepIndex)
        {
            return "prevStep";
        }
        else if (stepIndex > Wizard1.ActiveStepIndex)
        {
            return "nextStep";
        }
        else
        {
            return "currentStep";
        }
    }
    private void BindOrganizations()
    {
        //var OrgList = OrganizationComponent.GetOrganizations();//77.GetOrganizationsPerUser(UserController.GetCurrentUserInfo().UserID);
        //ddOrganization.DataSource = OrgList;
        //ddOrganization.DataBind();
    }

    /// <summary>
    /// Get items (answer) of the registered user
    /// </summary>
    /// <param name="listName">name of the list of answer</param>
    /// <param name="checkBoxList"></param>
    private void SetChkControl(string listName, CheckBoxList checkBoxList)
    {
        var list = SolutionListComponent.GetListPerCategory(solutionId, listName);
        ListItem item;
        foreach (var itemL in list)
        {
            item = checkBoxList.Items.FindByValue(itemL.Key);
            if (item != null)
                item.Selected = true;
        }
    }

    /// <summary>
    /// Save in the database the list of selected checkboxes
    /// </summary>
    /// <param name="listItem"></param>
    /// <param name="checkBoxList"></param>
    /// <returns></returns>
    private bool SaveChkControl(string listItem, CheckBoxList checkBoxList)
    {
        if (SolutionListComponent.deleteListPerCategory(solutionId, listItem))
        {
            string result = string.Empty;
            foreach (ListItem item in checkBoxList.Items)
            {
                if (item.Selected)
                {
                    SolutionListComponent sol = new SolutionListComponent(solutionId, item.Value, listItem);
                    sol.Save();
                }
            }
            return true;
        }
        return false;
    }

    /// <summary>
    /// Envia email al usuario (creador de la solución)
    /// </summary>
    /// <param name="subjectTemplate"></param>
    /// <param name="messageTemplate"></param>
    /// <param name="step"></param>
    /// <param name="solution"></param>
    private void sendEmailToUser(string subjectTemplate, string messageTemplate, int step, SolutionComponent solution)
    {
        bool sw = false;

        if (UserId == solution.Solution.CreatedUserId)
            sw = true;
        else
            if (!UserController.GetCurrentUserInfo().IsInRole("NexsoSupport"))
            sw = true;
        if (sw)
        {
            try
            {
                UserInfo user = UserController.GetUserById(PortalId, UserId);
                UserPropertyComponent property = new UserPropertyComponent(UserId);

                string dictionary = LocalResourceFile;
                if (!string.IsNullOrEmpty(challengeComponent.Challenge.Flavor))
                {
                    if (challengeComponent.Challenge.Flavor != "Default")
                        dictionary = LocalResourceFile + "Flavor" + challengeComponent.Challenge.Flavor;
                }
                String body = Localization.GetString(messageTemplate, dictionary);
                String subject = Localization.GetString(subjectTemplate, dictionary);

                String solutionUrl = string.Empty;
                if (solution.Solution.SolutionState == 0)
                    solutionUrl = NexsoHelper.GetCulturedUrlByTabName("promote", 0, Thread.CurrentThread.CurrentUICulture.Name) + "/sl/" + solution.Solution.SolutionId;
                if (solution.Solution.SolutionState >= 800)
                    solutionUrl = NexsoHelper.GetCulturedUrlByTabName("solprofile", 0, Thread.CurrentThread.CurrentUICulture.Name) + "/sl/" + solution.Solution.SolutionId;
                if (user != null && subject != null)
                {
                    subject = subject.Replace("{USER:FirstName}", user.FirstName);
                    body = body.Replace("{USER:FirstName}", user.FirstName).Replace("{USER:LastName}", user.LastName).Replace("{SOLUTION:Title}", solution.Solution.Title).Replace("{SOLUTION:URL}", solutionUrl);
                }
                DotNetNuke.Services.Mail.Mail.SendEmail("nexso@iadb.org", user.Email, subject, body);
            }
            catch
            {
                DotNetNuke.Services.Mail.Mail.SendEmail("nexso@iadb.org", "nexso@iadb.org", "Error sending " + messageTemplate, "Error sending " + messageTemplate);
            }
        }
    }

    /// <summary>
    /// Save or update solution
    /// </summary>
    /// <param name="step"></param>
    /// <param name="direction"></param>
    /// <returns></returns>
    private int Save(int step, string direction)
    {
        try
        {
            bool sendCreateSolution = false;
            switch (step)
            {
                // Start solution 
                case 0:
                    {
                        if (solutionComponent.Solution.OrganizationId != Guid.Empty)
                            SaveSolutionLog("OrganizationId", NZOrganization1.OrganizationId.ToString(), solutionComponent.Solution.OrganizationId.ToString());

                        //Create solution ID
                        Guid selected = new Guid(hfSelectedOrg.Value);
                        if (locK)
                            return -1;
                        if (solutionComponent.Solution.SolutionId == Guid.Empty)
                        {
                            if (
                                !string.IsNullOrEmpty(
                                    challengeCustomDataComponent.ChallengeCustomData.ChallengeReference))
                                solutionComponent.Solution.ChallengeReference =
                                    challengeCustomDataComponent.ChallengeCustomData.ChallengeReference;
                            else
                                solutionComponent.Solution.ChallengeReference = "NEXSODEFAULT";
                            solutionComponent.Solution.CreatedUserId = UserController.GetCurrentUserInfo().UserID;
                            sendCreateSolution = true;
                            solutionComponent.Solution.DateCreated = DateTime.Now;
                            solutionComponent.Solution.DateUpdated =
                                solutionComponent.Solution.DateCreated.GetValueOrDefault(DateTime.Now);
                        }
                        else
                        {
                            solutionComponent.Solution.DateUpdated = DateTime.Now;
                        }

                        //Sa information of the organization
                        NZOrganization1.SaveData();
                        NZOrganization1.EnabledButtons = true;
                        NZOrganization1.LoadControl();
                        // btnCreateOrganization.Visible = false;
                        BindOrganizations();
                        if (NZOrganization1.OrganizationId == Guid.Empty)
                            return -1;
                        hfSelectedOrg.Value = NZOrganization1.OrganizationId.ToString();
                        solutionComponent.Solution.OrganizationId = new Guid(hfSelectedOrg.Value);
                        solutionComponent.Solution.SolutionState = step;
                        if (!string.IsNullOrEmpty(ValidateSecurity.ValidateString(txtSubmissionTitle.Text, false)))
                        {
                            SaveSolutionLog("Title", txtSubmissionTitle.Text, solutionComponent.Solution.Title);
                            solutionComponent.Solution.Title = ValidateSecurity.ValidateString(txtSubmissionTitle.Text, false);
                        }
                        else
                        {
                            rgvtxtSubmissionTitle.IsValid = false;
                            return -1;
                        }
                        if (!string.IsNullOrEmpty(ValidateSecurity.ValidateString(txtShortDescription.Text, false)))
                        {
                            SaveSolutionLog("TagLine", txtShortDescription.Text, solutionComponent.Solution.TagLine);
                            solutionComponent.Solution.TagLine = ValidateSecurity.ValidateString(txtShortDescription.Text, false);
                        }
                        else
                        {
                            rgvtxtShortDescription.IsValid = false;
                            return -1;
                        }
                        if (solutionComponent.Solution.Organization.UserOrganizations.Count == 0)
                            solutionComponent.Solution.Organization.UserOrganizations.Add(new UserOrganization() { UserID = UserId, Role = 2 });
                        //UserOrganizationComponent userOrg = new UserOrganizationComponent(UserId,
                        //                                                                  solutionComponent.Solution
                        //                                                                                   .OrganizationId);
                        ////if (userOrg.UserOrganization.Role == -1)
                        ////    userOrg.UserOrganization.Role = 2;
                        //userOrg.Save();
                        break;
                    }
                case 1:
                    {
                        if (!string.IsNullOrEmpty(ValidateSecurity.ValidateString(txtChallenge.Text, false)))
                        {
                            SaveSolutionLog("Challenge", txtChallenge.Text, solutionComponent.Solution.Challenge);
                            solutionComponent.Solution.Challenge = ValidateSecurity.ValidateString(txtChallenge.Text, false);
                        }
                        else
                        {
                            rgvtxtChallenge.IsValid = false;
                            return -1;
                        }
                        SaveChkSolutionLog("Theme", cblTheme);
                        SaveChkControl("Theme", cblTheme);
                        solutionComponent.Solution.DateUpdated = DateTime.Now;
                        break;
                    }
                case 2:
                    {
                        if (!string.IsNullOrEmpty(ValidateSecurity.ValidateString(txtApproach.Text, false)))
                        {
                            SaveSolutionLog("Approach", txtApproach.Text, solutionComponent.Solution.Approach);
                            solutionComponent.Solution.Approach = ValidateSecurity.ValidateString(txtApproach.Text, false);
                        }
                        else
                        {
                            rgvtxtApproach.IsValid = false;
                            return -1;
                        }
                        SaveChkSolutionLog("Beneficiaries", cblBeneficiaries);
                        SaveChkControl("Beneficiaries", cblBeneficiaries);
                        solutionComponent.Solution.DateUpdated = DateTime.Now;
                        break;
                    }
                case 3:
                    {
                        if (!string.IsNullOrEmpty(ValidateSecurity.ValidateString(txtResults.Text, false)))
                        {
                            SaveSolutionLog("Results", txtResults.Text, solutionComponent.Solution.Results);
                            solutionComponent.Solution.Results = ValidateSecurity.ValidateString(txtResults.Text, false);
                        }
                        else
                        {
                            rgvtxtResults.IsValid = false;
                            return -1;
                        }
                        SaveChkSolutionLog("DeliveryFormat", cblDeliveryFormat);
                        SaveChkControl("DeliveryFormat", cblDeliveryFormat);
                        solutionComponent.Solution.DateUpdated = DateTime.Now;
                        break;
                    }
                case 4:
                    {
                        if (!string.IsNullOrEmpty(txtCost.Text))
                        {
                            decimal price = Convert.ToDecimal(solutionComponent.Solution.Cost);
                            string FormattedPrice = price.ToString("N"); // 1,234.25
                            decimal price2 = 0;
                            string FormattedPrice2 = "";
                            string txt = txtCost.Text;
                            decimal parsedValue = 0;
                            //Validates the cost format 
                            CultureInfo info = CultureInfo.GetCultureInfo("en-US");
                            if (decimal.TryParse(txt, NumberStyles.Any, info, out parsedValue))
                            {
                                price2 = Decimal.Parse(txt, NumberStyles.Any, info);
                                FormattedPrice2 = price2.ToString("N"); // 1,234.25
                                if (FormattedPrice2 != FormattedPrice)
                                {
                                    SaveSolutionLog("Cost", "true", solutionComponent.Solution.Cost.ToString());
                                    solutionComponent.Solution.Cost = price2;
                                }
                            }
                        }
                        //Validates the cost format and date format 
                        if (Convert.ToInt32(ddlCost.SelectedValue) != 0)
                        {
                            SaveSolutionLog("CostType", ddlCost.SelectedValue, solutionComponent.Solution.CostType.ToString());
                            solutionComponent.Solution.CostType = Convert.ToInt32(ddlCost.SelectedValue);
                        }
                        if (Convert.ToInt32(ddlProjectDuration.SelectedValue) != 0)
                        {
                            SaveSolutionLog("Duration", ddlProjectDuration.SelectedValue, solutionComponent.Solution.Duration.ToString());
                            solutionComponent.Solution.Duration = Convert.ToInt32(ddlProjectDuration.SelectedValue);
                        }

                        //Security validations 
                        if (!string.IsNullOrEmpty(ValidateSecurity.ValidateString(txtCostDetails.Text, false)))
                        {
                            SaveSolutionLog("CostDetails", txtCostDetails.Text, solutionComponent.Solution.CostDetails);
                            solutionComponent.Solution.CostDetails = ValidateSecurity.ValidateString(txtCostDetails.Text, false);
                        }
                        else
                        {
                            rgvtxtCostDetails.IsValid = false;
                            return -1;
                        }
                        if (!string.IsNullOrEmpty(ValidateSecurity.ValidateString(txtDurationDetails.Text, false)))
                        {
                            SaveSolutionLog("DurationDetails", txtDurationDetails.Text, solutionComponent.Solution.DurationDetails);
                            solutionComponent.Solution.DurationDetails = ValidateSecurity.ValidateString(txtDurationDetails.Text, false);
                        }
                        else
                        {
                            rgvtxtDurationDetails.IsValid = false;
                            return -1;
                        }
                        if (!string.IsNullOrEmpty(ValidateSecurity.ValidateString(txtImplementationDetails.Text, false)))
                        {
                            SaveSolutionLog("ImplementationDetails", txtImplementationDetails.Text, solutionComponent.Solution.ImplementationDetails);
                            solutionComponent.Solution.ImplementationDetails = ValidateSecurity.ValidateString(txtImplementationDetails.Text, false);
                        }
                        else
                        {
                            rgvtxtImplementationDetails.IsValid = false;
                            return -1;
                        }

                        if (txtLongDescription.Text != string.Empty)
                        {
                            if (!string.IsNullOrEmpty(ValidateSecurity.ValidateString(txtLongDescription.Text, false)))
                            {
                                SaveSolutionLog("Description", txtLongDescription.Text, solutionComponent.Solution.Description);
                                solutionComponent.Solution.Description = ValidateSecurity.ValidateString(txtLongDescription.Text, false);
                            }
                            else
                            {
                                rgvtxtLongDescription.IsValid = false;
                                return -1;
                            }
                        }
                        solutionComponent.Solution.DateUpdated = DateTime.Now;
                        break;
                    }
                case 5:
                    {
                        saveFromLocationControl(solutionId);
                        solutionComponent.Solution.DateUpdated = DateTime.Now;
                        break;
                    }
                case 6:
                    {
                        bool swAux = true;
                        //Upload documents
                        foreach (var item in listControls)
                        {
                            if (item.Id.Contains("fileChallengeDocuments"))
                            {
                                if (Wizard1.FindControl("cv" + item.Id) != null)
                                {
                                    CustomValidator cvCustomProjectDocuments = (CustomValidator)Wizard1.FindControl("cv" + item.Id);

                                    if (Wizard1.FindControl(item.Id) != null)
                                    {
                                        FileUploaderWizard fuw = (FileUploaderWizard)Wizard1.FindControl(item.Id);
                                        var required = cvCustomProjectDocuments.Attributes["Required"];
                                        int count = !string.IsNullOrEmpty(required) ? Convert.ToInt32(required) : -1;
                                        if (fuw.DocumentsLoaded < count)
                                        {
                                            cvCustomProjectDocuments.IsValid = false;
                                            swAux = false;
                                        }
                                        else
                                        {
                                            cvCustomProjectDocuments.IsValid = true;
                                            solutionComponent.Solution.DateUpdated = DateTime.Now;
                                        }
                                    }
                                }
                            }
                        }
                        if (!swAux)
                            return -1;
                        break;
                    }
                case 7:
                    {
                        foreach (Control control in Wizard1.WizardSteps[7].Controls)
                        {
                            if (control.ID != null)
                            {
                                if (control.ID.Contains("cvCustomProjectDocuments"))
                                {
                                    CustomValidator cvCustomProjectDocuments = (CustomValidator)control;
                                    string uploaderId = control.ID.Replace("cv", "");
                                    if (Wizard1.FindControl(uploaderId) != null)
                                    {
                                        FileUploaderWizard fuw = (FileUploaderWizard)Wizard1.FindControl(uploaderId);
                                        var required = cvCustomProjectDocuments.Attributes["Required"];
                                        int count = !string.IsNullOrEmpty(required) ? Convert.ToInt32(required) : -1;
                                        if (fuw.DocumentsLoaded < count)
                                        {
                                            cvCustomProjectDocuments.IsValid = false;
                                            return -1;
                                        }
                                        else
                                        {
                                            cvCustomProjectDocuments.IsValid = true;
                                        }
                                    }
                                }
                            }
                        }
                        solutionComponent.Solution.DateUpdated = DateTime.Now;
                        break;
                    }
                default:
                    {
                        solutionComponent.Solution.DateUpdated = DateTime.Now;
                        break;
                    }
            }
            if (direction == "FORWARD")
                solutionComponent.Solution.SolutionState = step;
            else
                solutionComponent.Solution.SolutionState = step - 1;
            solutionComponent.Solution.Language = System.Threading.Thread.CurrentThread.CurrentUICulture.Name;
            //Save Custom information. XML
            SaveCustomDataLog("CustomData", ControlsToXmlData(""), solutionComponent.Solution.CustomData, false);
            solutionComponent.Solution.CustomData = ControlsToXmlData("");
            solutionComponent.Save();
            solutionId = solutionComponent.Solution.SolutionId;
            NZSolution1.SolutionId = solutionId;
            NZSolution1.LoadData();
            HiddenFieldCurrentWords.Value = GlobalCounterWords().ToString();
            btnDeleteSolution.Visible = solutionComponent.Solution.SolutionId != Guid.Empty;
            if (sendCreateSolution)
                sendEmailToUser("MailTemplateNewSolutionSubject", "MailTemplateNewSolution", 0, solutionComponent);
        }
        catch (Exception exc)
        //Module failed to load
        {
            Exceptions.
                ProcessModuleLoadException(
                this, exc);
        }
        return 1;
    }

    /// <summary>
    /// Save in the database the  history of the information entered on the controls generated from XML
    /// </summary>
    /// <param name="key"></param>
    /// <param name="value"></param>
    /// <param name="valueOld"></param>
    /// <param name="sw"></param>
    private void SaveCustomDataLog(string key, string value, string valueOld, bool sw)
    {
        if ((valueOld != value && !string.IsNullOrEmpty(valueOld)) || sw)
        {
            ChallengeCustomDataComponent challengeData = new ChallengeCustomDataComponent(solutionComponent.Solution.ChallengeReference, solutionComponent.Solution.Language);
            CustomDataLogComponent customDataLogComponent = new CustomDataLogComponent();
            customDataLogComponent.CustomDataLog.SolutionId = solutionComponent.Solution.SolutionId;
            customDataLogComponent.CustomDataLog.CustomData = valueOld;
            if (challengeData != null)
                customDataLogComponent.CustomDataLog.CustomaDataSchema = challengeData.ChallengeCustomData.CustomDataTemplate;
            customDataLogComponent.CustomDataLog.CustomDataType = "";
            customDataLogComponent.CustomDataLog.Created = DateTime.Now;
            customDataLogComponent.CustomDataLog.UserId = UserId;
            customDataLogComponent.Save();
        }
    }

    /// <summary>
    /// Save in the database the history of  change for each textbox
    /// </summary>
    /// <param name="key"></param>
    /// <param name="value"></param>
    /// <param name="valueOld"></param>
    private void SaveSolutionLog(string key, string value, string valueOld)
    {
        if (valueOld != value && !string.IsNullOrEmpty(valueOld))
        {
            SolutionLogComponent solutionLogComponent = new SolutionLogComponent();
            solutionLogComponent.SolutionLog.SolutionId = solutionComponent.Solution.SolutionId;
            solutionLogComponent.SolutionLog.Value = valueOld;
            solutionLogComponent.SolutionLog.Key = key;
            solutionLogComponent.SolutionLog.Date = DateTime.Now;
            solutionLogComponent.SolutionLog.Delete = false;
            solutionLogComponent.SolutionLog.UserID = UserId;
            solutionLogComponent.Save();
        }
    }
    //private void RegisterScripts()
    //{
    //    Page.Header.Controls.Add(new System.Web.UI.LiteralControl("<link rel=\"stylesheet\" type=\"text/css\" href=\"" + ControlPath + "css/module.css" + "\" />"));

    //    Page.ClientScript.RegisterClientScriptInclude(
    //          this.GetType(), "jquery.uniform.min", ControlPath + "js/jquery.uniform.min.js");
    //    Page.ClientScript.RegisterClientScriptInclude(
    //         this.GetType(), "script", ControlPath + "js/module.js");

    //    string script = "<script>" +

    //        "var textMaxlength = '" + Localization.GetString("Maxlength", LocalResourceFile) + "';"
    //        + "var maxLengthImplementationDetails = '" + GetMaxLenght("txtImplementationDetails") + "';"
    //        + "var txtSubmissionTitle = '" + txtSubmissionTitle.ClientID + "';"
    //        + "var txtShortDescription = '" + txtShortDescription.ClientID + "';"
    //        + "var txtChallenge = '" + txtChallenge.ClientID + "';"
    //        + "var txtApproach='" + txtApproach.ClientID + "';"
    //        + "var txtResults='" + txtResults.ClientID + "';"
    //        + "var txtLongDescription='" + txtLongDescription.ClientID + "';"
    //        + "var txtCostDetails='" + txtCostDetails.ClientID + "';"
    //        + "var txtDurationDetails='" + txtDurationDetails.ClientID + "';"
    //        + "var txtImplementationDetails ='" + txtImplementationDetails.ClientID + "';"
    //        + "var hiddenFieldCurrentWords ='" + HiddenFieldCurrentWords.ClientID + "';"
    //        + "var language ='" + System.Threading.Thread.CurrentThread.CurrentCulture.ToString() + "';"
    //        + "var cblTheme = '" + cblTheme.ClientID + "';"
    //        + "var cvcblTheme = '" + cvcblTheme.ClientID + "';"
    //        + "var cblBeneficiaries = '" + cblBeneficiaries.ClientID + "';"
    //        + "var cvcblBeneficiaries = '" + cvcblBeneficiaries.ClientID + "';"
    //        + "var cblDeliveryFormat = '" + cblDeliveryFormat.ClientID + "';"
    //        + "var cvcblDeliveryFormat = '" + cvcblDeliveryFormat.ClientID + "';"
    //        + "var btnDoKeep = '" + btnDoKeep.ClientID + "';"
    //        + "var btnDeleteSol = '" + btnDelete.ClientID + "';"
    //        + "var confirmationDelete = '" + Localization.GetString("ConfirmationDelete", this.LocalResourceFile) + "';"
    //        + "var titlePopUp = '" + Localization.GetString("TitlePopUp", this.LocalResourceFile) + "';"
    //        + "var btnOk = '" + Localization.GetString("btnOk", this.LocalResourceFile) + "';"
    //        + "var btnCancel = '" + Localization.GetString("btnCancel", this.LocalResourceFile) + "';"


    //    + "</script>";


    //    Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Script22", script);

    //}
    #endregion

    #region Public Properties
    public string ChellengeReference { get; set; }
    #endregion

    #region Public Methods
    /// <summary>
    /// Add to map the locations where the solution is implemented
    /// </summary>
    public void saveFromLocationControl(Guid solutionId)
    {
        List<SolutionLocation> solutionLocationListOld;
        List<CountryStateCityV2.Location> listLocation = CountryStateCityEditMode.Locations;
        SolutionLocationComponent.DeleteSolutionLocationsPerSolution(solutionId);
        foreach (var location in listLocation)
        {
            List<SolutionLocation> solutionLocationList = SolutionLocationComponent.GetSolutionLocationsPerSolution(solutionId).ToList();
            bool sw = false;
            foreach (var locationn in solutionLocationList)
            {
                if (location.country.Equals(locationn.Country) && location.city.Equals(locationn.City) && location.state.Equals(locationn.Region))
                {
                    sw = true;
                }
            }
            if (!sw)
            {
                /// Pendiente Revisar Country..
                var solutionLocation = new SolutionLocationComponent(solutionId, location.country, location.state, location.city, location.postal_code,
                                                location.inputAddress, location.latitude, location.longitude);
                solutionLocation.Save();
            }
        }
    }

    /// <summary>
    /// Redirect to solprofile
    /// </summary>
    /// <returns></returns>
    public string PopUpFinish()
    {
        if (!string.IsNullOrEmpty(challengeComponent.Challenge.OutUrl))
        {
            if (Settings.Contains("RadEditor"))
            {
                if (!string.IsNullOrEmpty(Settings["RadEditor"].ToString()))
                {
                    if (solutionComponent.Solution.SolutionId != Guid.Empty)
                    {
                        return Settings["RadEditor"].ToString().Replace("/sl/", "/sl/" + solutionComponent.Solution.SolutionId).Replace("OutUrl", NexsoHelper.GetCulturedUrlByTabName(challengeComponent.Challenge.OutUrl)).Replace("none", "block").ToString();
                    }
                }
            }
            return Localization.GetString("lbHeader", LocalResourceFile).Replace("/sl/", "/sl/" + solutionComponent.Solution.SolutionId).Replace("OutUrl", NexsoHelper.GetCulturedUrlByTabName(challengeComponent.Challenge.OutUrl)).Replace("none", "block");
        }
        else
        {
            if (Settings.Contains("RadEditor"))
            {
                if (!string.IsNullOrEmpty(Settings["RadEditor"].ToString()))
                {
                    if (solutionComponent.Solution.SolutionId != Guid.Empty)
                    {
                        return Settings["RadEditor"].ToString().Replace("/sl/", "/sl/" + solutionComponent.Solution.SolutionId).ToString();
                    }
                }
            }
            return Localization.GetString("lbHeader", LocalResourceFile).Replace("/sl/", "/sl/" + solutionComponent.Solution.SolutionId);
        }
    }

    /// <summary>
    /// Class for steps (circles)
    /// </summary>
    /// <returns></returns>
    public string GetClassBanner()
    {
        string classBanner = string.Empty;
        switch (AddSteps)
        {
            case 1:
                classBanner = "custom2";
                break;
            case 2:
                classBanner = "custom";
                break;
        }
        return classBanner;
    }

    /// <summary>
    /// View solutions per user
    /// </summary>
    /// <returns>Popus URL</returns>
    public string GetUrlPopUp()
    {
        return NexsoHelper.GetCulturedUrlByTabName("ExplorePopUp") + "/ui/" + UserId;
    }

    /// <summary>
    /// Get logo of the challenge (english, spanish, portuguese).
    /// </summary>
    /// <returns></returns>
    public string GetLogo()
    {
        string url = string.Empty;
        if (challengeComponent.Challenge.ChallengeReference != null)
        {
            var listUrls = ChallengeFileComponent.GetFilesForChallenge(challengeComponent.Challenge.ChallengeReference, "Banner Wizard");
            var urlFirst = listUrls.FirstOrDefault(x => x.Language == Language && (x.Delete == null || x.Delete == false));
            if (urlFirst != null)
                url = "/" + urlFirst.ObjectLocation;
            else
            {
                if (challengeComponent.Challenge.ChallengeReference != "NEXSODEFAULT")
                    url = "/portals/" + PortalId + "/images/" + challengeComponent.Challenge.ChallengeReference + "-" + Language + ".jpg";
            }
        }
        return url;
    }


    /// <summary>
    /// Validate  if have 500 words or more in the textbox
    /// </summary>
    /// <returns></returns>
    bool validateLenghts()
    {
        foreach (var control in Wizard1.ActiveStep.Controls)
        {

            if (control is TextBox)
            {
                if (((TextBox)control).MaxLength > 0)
                {
                    if (((TextBox)control).Text.Length > ((TextBox)control).MaxLength)
                        return false;
                }
            }
        }
        return true;
    }
    #endregion

    #region Subclasses
    public class SolutionListJson
    {
        public string Type { get; set; }
        public List<string> list { get; set; }
    }


    [Serializable]
    public class Generic
    {
        public string Id { get; set; }
        public string Value { get; set; }
    }

    #endregion

    #region Events
    protected override void OnLoad(EventArgs e)
    {
        var script = DotNetNuke.Framework.AJAX.GetScriptManager(this.Page);
        script.AsyncPostBackTimeout = 3600;
        base.OnLoad(e);
        doPane.Value = "";
        if (UserController.GetCurrentUserInfo().UserID > 0)
        {
            LoadParams();
            solutionComponent = new SolutionComponent(solutionId);
            if (!reUse)
                interceptWizard(); // this method if for routing the different wizard until the Generic one, 
            organizationComponent = new OrganizationComponent(solutionComponent.Solution.OrganizationId);
            fileSupportDocuments.SolutionId = solutionId;
            BindDataChallenge();
            if (!IsPostBack)
            {
                if (!Convert.ToBoolean(solutionComponent.Solution.Deleted))
                {
                    if (copy)
                        CopySolution();
                    if (reUse)
                        ReUseSolution();
                    BindData();
                    PopulateLabels();
                    pnlVerification.Visible = verification;
                }
                else
                {
                    Response.Redirect(NexsoHelper.GetCulturedUrlByTabName("promote"));
                }
            }
            else
            {
                pnlVerification.Visible = false;
            }
            // RegisterScripts();
            if (!IsPostBack)
            {
                bindLocationControl(solutionComponent.Solution.SolutionId);
            }
            HiddenFieldCurrentWords.Value = GlobalCounterWords().ToString();
            if (!(UserController.GetCurrentUserInfo().IsInRole("Administrators") | UserController.GetCurrentUserInfo().IsInRole("NexsoSupport")))
            {
                if (!string.IsNullOrEmpty(challengeComponent.Challenge.EntryFrom.ToString()) && !string.IsNullOrEmpty(challengeComponent.Challenge.EntryTo.ToString()))
                {
                    if (challengeComponent.Challenge.EntryFrom <= DateTime.Now && DateTime.Now <= challengeComponent.Challenge.EntryTo)
                    {
                        UpdatePanel1.Visible = true;
                        lblMessage.Visible = false;
                    }
                    else
                    {
                        UpdatePanel1.Visible = false;
                        lblMessage.Visible = true;
                    }
                }
            }
            if (solutionComponent.Solution.Description != null)
            {
                pnlLongDescription.Visible = true;
            }
            else
            {
                txtImplementationDetails.Height = new System.Web.UI.WebControls.Unit(300);
            }
            if (solutionComponent.Solution.CostType != null)
            {
                pnlCostSelect.Visible = true;
                lblHtmlCostTitle.Visible = true;
            }
        }
        else
        {
            Exceptions.ProcessModuleLoadException(this, new Exception("Unknown User"));
        }
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        LoadAutocompleteControl();
        Wizard1.PreRender += new EventHandler(Wizard1_PreRender);
    }

    protected override void OnInit(EventArgs e)
    {
        LoadParams();
        bool sw = false;
        bool swData = false;
        solutionComponent = new SolutionComponent(solutionId);
        if (Settings.Contains("ChallengeReference"))
        {
            if (!string.IsNullOrEmpty(Settings["ChallengeReference"].ToString()))
            {
                challengeComponent = new ChallengeComponent(Settings["ChallengeReference"].ToString());
                if (!string.IsNullOrEmpty(challengeComponent.Challenge.ChallengeReference))
                {
                    if (challengeComponent.Challenge.ChallengeReference == "NEXSODEFAULT")
                    {
                        if (solutionComponent.Solution.SolutionId != Guid.Empty)
                        {
                            if (!string.IsNullOrEmpty(solutionComponent.Solution.ChallengeReference))
                            {
                                challengeCustomDataComponent = new ChallengeCustomDataComponent(solutionComponent.Solution.ChallengeReference, Language);
                                swData = true;
                            }
                        }
                    }
                    else
                    {
                        challengeCustomDataComponent = new ChallengeCustomDataComponent(challengeComponent.Challenge.ChallengeReference, Language);
                        swData = true;
                    }

                    if (challengeCustomDataComponent != null)
                    {
                        if (!string.IsNullOrEmpty(challengeCustomDataComponent.ChallengeCustomData.CustomDataTemplate))
                        {
                            XMLCreateControls(challengeCustomDataComponent.ChallengeCustomData.CustomDataTemplate);
                            sw = true;
                        }
                    }
                    sw = true;
                }
            }
        }
        if (!sw)
        {
            challengeComponent = new ChallengeComponent();
        }
        if (!swData)
        {
            challengeCustomDataComponent = new ChallengeCustomDataComponent();

        }
        base.OnInit(e);
    }

    protected void Wizard1_PreRender(object sender, EventArgs e)
    {
        Repeater SideBarList = Wizard1.FindControl("HeaderContainer").FindControl("repSideBarList") as Repeater;
        SideBarList.DataSource = Wizard1.WizardSteps;
        SideBarList.DataBind();
    }

    /// <summary>
    /// Change the state of the solution to deleted
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDeleteSolution_OnClick(object sender, EventArgs e)
    {
        solutionComponent.Solution.Deleted = true;
        solutionComponent.Solution.DateUpdated = DateTime.Now;
        solutionComponent.Save();
        Response.Redirect(NexsoHelper.GetCulturedUrlByTabName("MySolutions") + "/ui/" + UserId, false);
    }

    /// <summary>
    /// Next step in the wizard. 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Wizard1_NextButtonClick(object sender, WizardNavigationEventArgs e)
    {
        if (!validateLenghts())
        {
            CustomValidator CustomValidatorCtrl = new CustomValidator();
            CustomValidatorCtrl.IsValid = false;
            CustomValidatorCtrl.ErrorMessage = Localization.GetString("MaxLengthExceeded",
                                                                  LocalResourceFile);
            this.Page.Controls.Add(CustomValidatorCtrl);
            e.Cancel = true;
        }
        else
        {
            if (Save(e.CurrentStepIndex, "FORWARD") > 0)
                doPane.Value = Wizard1.ActiveStepIndex.ToString();
            else
                e.Cancel = true;
        }
    }

    /// <summary>
    /// Previous step in the wizard. 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Wizard1_PreviousButtonClick(object sender, WizardNavigationEventArgs e)
    {
        if (!validateLenghts())
        {
            CustomValidator CustomValidatorCtrl = new CustomValidator();
            CustomValidatorCtrl.IsValid = false;
            CustomValidatorCtrl.ErrorMessage = Localization.GetString("MaxLengthExceeded",
                                                                  LocalResourceFile);
            this.Page.Controls.Add(CustomValidatorCtrl);
            e.Cancel = true;
        }
        else
        {
            Save(e.CurrentStepIndex, "BACKWARD");
            doPane.Value = Wizard1.ActiveStepIndex.ToString();
        }
        Wizard1.ActiveStepIndex = e.CurrentStepIndex - 1;
    }

    /// <summary>
    /// Change the solution to published state and sends notification to the user
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Wizard1_FinishButtonClick(object sender, WizardNavigationEventArgs e)
    {
        if (Settings.Contains("PublishState"))
        {
            if (!string.IsNullOrEmpty(Settings["PublishState"].ToString()))
            {
                solutionComponent.Solution.SolutionState = Convert.ToInt32(Settings["PublishState"].ToString());
            }
            else
                solutionComponent.Solution.SolutionState = 1000;
        }
        else
            solutionComponent.Solution.SolutionState = 1000;
        solutionComponent.Solution.DateUpdated = DateTime.Now;
        if (solutionComponent.Solution.DatePublished == null)
            sendEmailToUser("MailTemplatePublishedSolutionSubject", "MailTemplatePublishedSolution", solutionComponent.Solution.SolutionState.GetValueOrDefault(800), solutionComponent);
        var objTabController = new DotNetNuke.Entities.Tabs.TabController();
        solutionComponent.Solution.DatePublished = solutionComponent.Solution.DateUpdated;
        solutionComponent.Save();
        var txt = PopUpFinish();
        HiddenFieldCurrentWords.Value = GlobalCounterWords().ToString();
        ScriptManager.RegisterClientScriptBlock(UpdatePanel1, this.GetType(), "script", "Finish('" + txt + "');", true);
    }

    //protected void btnCreateNewOrganization_Click(object sender, EventArgs e)
    //{
    //    string title = RadAutoCompleteBox1.Text.Replace("; ", "");
    //    Guid selectedOrg = IsInList(title);
    //    if (selectedOrg != Guid.Empty)
    //    {
    //        pnlOrganization.Visible = true;
    //        NZOrganization1.OrganizationId = selectedOrg;
    //        hfSelectedOrg.Value = selectedOrg.ToString();
    //        NZOrganization1.EnabledButtons = false;
    //        NZOrganization1.LoadControl();
    //        //btnCreateOrganization.Visible = false;
    //        Button StepNextButton =
    //            (Button) Wizard1.FindControl("StepNavigationTemplateContainerID").FindControl("StepNextButton");
    //        StepNextButton.Enabled = true;
    //    }
    //    else
    //    {
    //        NZOrganization1.OrganizationTitle = title;
    //        pnlOrganization.Visible = true;
    //        NZOrganization1.OrganizationId = Guid.Empty;
    //        NZOrganization1.EnabledButtons = false;
    //        NZOrganization1.LoadControl();
    //        //btnCreateOrganization.Visible = true;
    //        Button StepNextButton =
    //            (Button)Wizard1.FindControl("StepNavigationTemplateContainerID").FindControl("StepNextButton");
    //        StepNextButton.Enabled = false;
    //    }
    //}
    protected void RadAutoCompleteBox1_SelectedIndexChanged(object sender, RadComboBoxSelectedIndexChangedEventArgs e)
    {
        //SelectOrganizations();
    }
    /// <summary>
    /// This event runs when an organization is selected
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RadAutoCompleteBox1_TextChanged(object sender, EventArgs e)
    {
        SelectOrganizations();
    }

    /// <summary>
    /// Show title of the current step
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Wizard1_ActiveStepChanged(object sender, EventArgs e)
    {
        setTitleCurrentStep(Wizard1.ActiveStepIndex);
    }
    protected void ddProjectDuration_DataBinding(object sender, EventArgs e)
    {
    }
    protected void btnDoKeep_Click(object sender, EventArgs e)//replicate
    {
        int hh = 0;
    }

    /// <summary>
    /// Bind List of steps 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
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
    /// Jump steps in the wizard
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Jump_Click(object sender, EventArgs e)
    {
        if (Page.IsValid)
        {
            if (solutionComponent.Solution.DatePublished != null)
            {
                var link = (LinkButton)sender;
                if (!validateLenghts())
                {
                    CustomValidator CustomValidatorCtrl = new CustomValidator();
                    CustomValidatorCtrl.IsValid = false;
                    CustomValidatorCtrl.ErrorMessage = Localization.GetString("MaxLengthExceeded",
                                                                          LocalResourceFile);
                    this.Page.Controls.Add(CustomValidatorCtrl);
                }
                else
                {
                    if (Save(Wizard1.ActiveStepIndex, "FORWARD") > 0)
                    {
                        doPane.Value = link.CommandArgument;
                        Wizard1.ActiveStepIndex = Convert.ToInt32(link.CommandArgument);
                        solutionComponent.Solution.SolutionState = Convert.ToInt32(link.CommandArgument);
                        solutionComponent.Save();
                    }

                }

            }
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