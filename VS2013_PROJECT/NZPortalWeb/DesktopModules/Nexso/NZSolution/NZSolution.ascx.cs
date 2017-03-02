using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using System.IO;
using System.Text;
using System.Threading;
using System.Globalization;
using System.Xml;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Entities.Tabs;
using DotNetNuke.Entities.Users;
using DotNetNuke.Services.Exceptions;
using DotNetNuke.Services.Localization;
using DotNetNuke.Security;
using DotNetNuke.Entities.Modules.Actions;
using NexsoProBLL;
using NexsoProDAL;
using MIFWebServices;
using System.Net;




/// <summary>
/// The purpose of the Details module is to provide a UI to show all the details around a solution.
/// https://www.nexso.org/SolProfile/sl/f1563832-cc79-4485-aa99-fb8433f234e9
/// </summary>
public partial class NZSolution : PortalModuleBase, IActionable
{
    #region Private Member Variables
    protected TabController objTabController;
    private Guid solutionId;
    private bool previewMode = false;
    private string folder = string.Empty;
    private List<string> folders = new List<string>();
    protected SolutionComponent solutionComponent;
    private OrganizationComponent organizationComponent;
    private string Language = System.Globalization.CultureInfo.CurrentUICulture.Name;
    #endregion

    #region  Private Properties
    protected string SolutionLanguage
    {
        get
        {
            if (!string.IsNullOrEmpty(solutionComponent.Solution.Language))
            {
                if (solutionComponent.Solution.Language.Contains("en"))
                    return "EN";
                if (solutionComponent.Solution.Language.Contains("es"))
                    return "ES";
                if (solutionComponent.Solution.Language.Contains("pt"))
                    return "PT";
                return solutionComponent.Solution.Language;
            }
            else
            {
                return "ES";
            }
        }
    }
    #endregion

    #region  Private Methods

    private void VerifyVote()
    {
        return;
        if (UserId < 0)
        {
            if (Request.QueryString["ottpyPc"] != string.Empty && Request.QueryString["oztptTo"] != string.Empty)
            {
                Guid potentialCustomer, token = Guid.Empty;
                Guid.TryParse(Request.QueryString["ottpyPc"], out potentialCustomer);
                Guid.TryParse(Request.QueryString["oztptTo"], out token);
                if (potentialCustomer != Guid.Empty && token != Guid.Empty)
                {
                    var potentialUser = new PotentialUserComponent(potentialCustomer);
                    if (potentialUser.PotentialUser.PotentialUserId != Guid.Empty)
                    {
                        if (potentialUser.PotentialUser.Qualification != "BANNED")
                        {
                            if (potentialUser.PotentialUser.CustomField1 != null)
                            {
                                if (potentialUser.PotentialUser.CustomField1.ToUpper() == token.ToString().ToUpper())
                                {
                                    potentialUser.PotentialUser.CustomField1 = null;
                                    if (potentialUser.Save() > 0)
                                    {


                                        SocialMediaIndicatorComponent socialMediaIndicatorComponent = new SocialMediaIndicatorComponent(solutionId, "SOLUTION", "LIKE", null);
                                        if (socialMediaIndicatorComponent.SocialMediaIndicator.SocialMediaIndicatorId == Guid.Empty)
                                        {
                                            socialMediaIndicatorComponent.SocialMediaIndicator.Value = 1;
                                            socialMediaIndicatorComponent.SocialMediaIndicator.Created = DateTime.Now;
                                            socialMediaIndicatorComponent.SocialMediaIndicator.ObjectType = "SOLUTION";
                                            socialMediaIndicatorComponent.SocialMediaIndicator.IndicatorType = "LIKE";
                                            socialMediaIndicatorComponent.SocialMediaIndicator.Aggregator = "SUM";
                                            socialMediaIndicatorComponent.Save();
                                        }
                                    }
                                }
                            }
                        }
                        else
                        {
                            Exception exc = new Exception("Banned voting operation");
                            DotNetNuke.Services.Exceptions.Exceptions.LogException(exc);
                        }
                    }
                }

            }
        }
    }

    /// <summary>
    /// Load solution id via query string
    /// </summary>
    private void LoadParams()
    {
        if (solutionId == Guid.Empty)
        {
            if (Request.QueryString["sl"] != string.Empty)
                try
                {
                    solutionId = new Guid(Request.QueryString["sl"]);
                }
                catch
                {
                    solutionId = Guid.Empty;

                }

            else
                solutionId = Guid.Empty;

            VerifyVote();


            //if (Request.QueryString["or"] != string.Empty)
            //    try
            //    {
            //        organizationId = new Guid(Request.QueryString["or"]);
            //    }
            //    catch
            //    {
            //        organizationId = Guid.Empty;

            //    }

            //else
            //    organizationId = Guid.Empty;
        }
    }

    /// <summary>
    /// Enable labels and buttons to show information from the solution
    /// </summary>
    private void PopulateLabels()
    {
        string urlBase = Request.Url.AbsoluteUri.Replace(Request.Url.PathAndQuery, "") + ControlPath;
        DotNetNuke.Framework.CDefault tp = (DotNetNuke.Framework.CDefault)Context.CurrentHandler;
        ChallengeComponent challengeComponent = new ChallengeComponent(solutionComponent.Solution.ChallengeReference);
        bool swUnpublish = true;
        if (challengeComponent != null)
        {
            if (!string.IsNullOrEmpty(challengeComponent.Challenge.EntryTo.ToString()) && !string.IsNullOrEmpty(challengeComponent.Challenge.Closed.ToString()))
            {
                if (challengeComponent.Challenge.EntryTo < DateTime.Now && challengeComponent.Challenge.Closed > DateTime.Now)
                    swUnpublish = false;
            }
        }

        if (solutionComponent.Solution.SolutionId != Guid.Empty)
        {
            tp.Title = solutionComponent.Solution.Title;
            tp.MetaDescription = solutionComponent.Solution.TagLine;


            //Enable button if user is JUDGE or administrator
            var swJudge = false;
            ChallengeJudgeComponent challengeJudgeComponent = new ChallengeJudgeComponent(UserId, solutionComponent.Solution.ChallengeReference);
            if (challengeJudgeComponent.ChallengeJudge != null)
            {
                if (challengeJudgeComponent.ChallengeJudge.UserId == UserId)
                {
                    if (!string.IsNullOrEmpty(challengeJudgeComponent.ChallengeJudge.FromDate.ToString()) || !string.IsNullOrEmpty(challengeJudgeComponent.ChallengeJudge.ToDate.ToString()))
                    {
                        if (challengeJudgeComponent.ChallengeJudge.FromDate <= DateTime.Now && DateTime.Now <= challengeJudgeComponent.ChallengeJudge.ToDate)
                            swJudge = true;
                        else
                            if ((string.IsNullOrEmpty(challengeJudgeComponent.ChallengeJudge.FromDate.ToString()) && DateTime.Now <= challengeJudgeComponent.ChallengeJudge.ToDate) || (challengeJudgeComponent.ChallengeJudge.FromDate <= DateTime.Now && string.IsNullOrEmpty(challengeJudgeComponent.ChallengeJudge.ToDate.ToString())))
                            swJudge = true;
                    }
                    else
                        swJudge = true;
                }
            }
            if (solutionComponent.Solution.SolutionState.GetValueOrDefault(-1) >= 800)
            {

                if (swJudge)
                {
                    if (challengeJudgeComponent.ChallengeJudge.PermisionLevel != "MOBILIZER")
                    {
                        bannerController.Visible = true;
                        btnRate.Visible = true;
                    }
                }
                else
                {
                    bannerController.Visible = false;
                }
                if (UserController.GetCurrentUserInfo().IsInRole("Administrators") || UserController.GetCurrentUserInfo().IsInRole("NexsoSupport"))
                {
                    btnRate.Visible = true;
                }

                // Enable or disable buttons rate, delete solution, publish, report as spam
                if (solutionComponent.Solution.SolutionState >= 1000)
                {
                    if (UserController.GetCurrentUserInfo().UserID == solutionComponent.Solution.CreatedUserId)
                    {
                        btnUnpublish.Visible = swUnpublish;
                    }

                    btnReportSpam.Visible = true;
                }
                else
                {
                    if (!(UserController.GetCurrentUserInfo().IsInRole("Administrators") || UserController.GetCurrentUserInfo().IsInRole("NexsoSupport") || swJudge))
                    {

                        if (UserController.GetCurrentUserInfo().UserID != solutionComponent.Solution.CreatedUserId)
                            Response.Redirect(NexsoHelper.GetCulturedUrlByTabName("notauth"));
                    }

                }
            }
            else
            {
                if (!(UserController.GetCurrentUserInfo().IsInRole("Administrators") || UserController.GetCurrentUserInfo().IsInRole("NexsoSupport") || swJudge))
                {

                    if (UserController.GetCurrentUserInfo().UserID != solutionComponent.Solution.CreatedUserId)
                        Response.Redirect(NexsoHelper.GetCulturedUrlByTabName("notauth"));
                }
            }

            if (UserController.GetCurrentUserInfo().IsInRole("Administrators") || UserController.GetCurrentUserInfo().IsInRole("NexsoSupport") || challengeJudgeComponent.ChallengeJudge.PermisionLevel == "MOBILIZER")
            {
                lblSolutionState.Visible = true;
                dState.Visible = true;
            }

            if (UserController.GetCurrentUserInfo().IsInRole("Administrators") || UserController.GetCurrentUserInfo().IsInRole("NexsoSupport") || swJudge ||
                     UserController.GetCurrentUserInfo().UserID == solutionComponent.Solution.CreatedUserId)
            {
                filePrivateDocuments.Visible = true;
                dvOtherInformationPanel.Visible = true;
                lblPrivateDocuments.Visible = true;
                btnDeleteSolution.Visible = true;
                bannerController.Visible = true;


                if (solutionComponent.Solution.SolutionState == 800 || solutionComponent.Solution.SolutionState == 801)
                    btnUnpublish.Visible = false;
                else
                {
                    if (UserController.GetCurrentUserInfo().UserID == solutionComponent.Solution.CreatedUserId)
                        btnUnpublish.Visible = swUnpublish;
                    else
                        btnUnpublish.Visible = swUnpublish;
                }

            }
            else
                dvOtherInformationPanel.Visible = false;
        }
        else
            dvOtherInformationPanel.Visible = false;

        dvActionBar.Visible = !previewMode;
        if (UserController.GetCurrentUserInfo().IsInRole("Administrators") || UserController.GetCurrentUserInfo().IsInRole("NexsoSupport"))
            btnUnpublish.Visible = swUnpublish = true;


    }

    /// <summary>
    /// Main method. This method load all information of the solution
    /// </summary>
    private void BindData()
    {
        FillTopicsData();
        FillOtherInformation();
        FillData();
        FillBeneficiaries();
        FillThemes();
        FillFormat();
    }

    private void FillTopicsData()
    {
    }

    /// <summary>
    /// Fill list of formats
    /// </summary>
    private void FillFormat()
    {
        var list = SolutionListComponent.GetListPerCategory(solutionId, "DeliveryFormat");
        StringBuilder str = new StringBuilder();
        str.Append("<ul>");
        foreach (var item in list)
        {
            str.Append("<li>" + NexsoProBLL.ListComponent.GetLabelFromListKey("DeliveryFormat", Thread.CurrentThread.CurrentCulture.Name, item.Key) + "</li>");
        }
        str.Append("</ul>");
        lblDeliveryFormat.Text = str.ToString();
    }


    /// <summary>
    /// Fill list of beneficiaries
    /// </summary>
    private void FillBeneficiaries()
    {
        var list = SolutionListComponent.GetListPerCategory(solutionId, "Beneficiaries");
        StringBuilder str = new StringBuilder();
        str.Append("<ul>");
        foreach (var item in list)
        {
            str.Append("<li>" + NexsoProBLL.ListComponent.GetLabelFromListKey("Beneficiaries", Thread.CurrentThread.CurrentCulture.Name, item.Key) + "</li>");
        }
        str.Append("</ul>");
        lblBeneficiary.Text = str.ToString();
    }


    /// <summary>
    /// Fill list of themes
    /// </summary>
    private void FillThemes()
    {
        var list = SolutionListComponent.GetListPerCategory(solutionId, "Theme");
        StringBuilder str = new StringBuilder();
        str.Append("<ul>");
        foreach (var item in list)
        {
            str.Append("<li>" + NexsoProBLL.ListComponent.GetLabelFromListKey("Theme", Thread.CurrentThread.CurrentCulture.Name, item.Key) + "</li>");
        }
        str.Append("</ul>");
        lblTheme.Text = str.ToString();
    }

    /// <summary>
    /// Load in the controls all information of the solution
    /// </summary>
    private void FillData()
    {
        hfTitle.Text = WebUtility.HtmlDecode(solutionComponent.Solution.Title);
        hfTitle2.Value = WebUtility.HtmlDecode(solutionComponent.Solution.Title);
        hfTagLine.Text = WebUtility.HtmlDecode(solutionComponent.Solution.TagLine);
        hfTagLine2.Value = WebUtility.HtmlDecode(solutionComponent.Solution.TagLine);
        hfInstitutionName.Text = WebUtility.HtmlDecode(organizationComponent.Organization.Name);
        hfInstitutionName2.Value = WebUtility.HtmlDecode(organizationComponent.Organization.Name);
        hfTagLine.Style.Add("display", "none");
        hfTitle.Style.Add("display", "none");
        lblCount.Style.Add("display", "none");
        hfInstitutionName.Style.Add("display", "none");
        lblCount.Text = "0";
        lblTagLine.Text = WebUtility.HtmlDecode(solutionComponent.Solution.TagLine);
        lblChallenge.Text = WebUtility.HtmlDecode(solutionComponent.Solution.Challenge);
        lblApproach.Text = WebUtility.HtmlDecode(solutionComponent.Solution.Approach);
        lblResults.Text = WebUtility.HtmlDecode(solutionComponent.Solution.Results);
        if (!string.IsNullOrEmpty(solutionComponent.Solution.Description))
            pnlLongDescription.Visible = true;
        else
            pnlLongDescription.Visible = false;

        lblDescription.Text = WebUtility.HtmlDecode(solutionComponent.Solution.Description);

        lblTitle.Text = WebUtility.HtmlDecode(solutionComponent.Solution.Title);
        lblInstitutionName.Text = WebUtility.HtmlDecode(organizationComponent.Organization.Name);
        lblOrganizationDescription.Text = WebUtility.HtmlDecode(organizationComponent.Organization.Description);
        lblCountry.Text = LocationService.GetCountryName(organizationComponent.Organization.Country);
        hlInstitutionName.NavigateUrl = NexsoHelper.GetCulturedUrlByTabName("insprofile") + "/in/" + organizationComponent.Organization.OrganizationID;

        var listEmptyItem = new NexsoProDAL.List();
        listEmptyItem.Key = "0";
        listEmptyItem.Label = Localization.GetString("Traslate", LocalResourceFile);

        var list = ListComponent.GetListPerCategory("Language", Thread.CurrentThread.CurrentCulture.Name).ToList();
        list.Insert(0, listEmptyItem);

        ddTranslate.DataSource = list;
        ddTranslate.DataBind();

        lblSolutionState.Text = GetSolutionState(Convert.ToInt32(solutionComponent.Solution.SolutionState)) + " - " + solutionComponent.Solution.ChallengeReference;
        // lblTheme.Text = ListComponent.GetLabelFromListValue("Theme", Thread.CurrentThread.CurrentCulture.Name, solutionComponent.Solution.Topic.ToString());
        //lblBeneficiary.Text = ListComponent.GetLabelFromListValue("Beneficiaries", Thread.CurrentThread.CurrentCulture.Name, solutionComponent.Solution.Beneficiaries.ToString());
        lblDuration.Text = ListComponent.GetLabelFromListValue("ProjectDuration", Thread.CurrentThread.CurrentCulture.Name, solutionComponent.Solution.Duration.ToString());
        //lblDeliveryFormat.Text = ListComponent.GetLabelFromListValue("DeliveryFormat", Thread.CurrentThread.CurrentCulture.Name, solutionComponent.Solution.DeliveryFormat.ToString());
        if (solutionComponent.Solution.DatePublished != null)
        {
            DateTime datePublished = (DateTime)solutionComponent.Solution.DatePublished;
            txtPublishDate.Text = datePublished.ToString("MMM dd, yyyy", Thread.CurrentThread.CurrentCulture);
        }
        else
        {
            lblPublishDate.Visible = false;
            txtPublishDate.Visible = false;
        }
        lblCost.Text = "US" + String.Format(CultureInfo.GetCultureInfo(1033), "{0:C}", solutionComponent.Solution.Cost);//us
        lblCostType.Text = ListComponent.GetLabelFromListValue("Cost", Thread.CurrentThread.CurrentCulture.Name, solutionComponent.Solution.CostType.ToString());
        lblCostDetails.Text = WebUtility.HtmlDecode(solutionComponent.Solution.CostDetails);
        lbldurationDetails.Text = WebUtility.HtmlDecode(solutionComponent.Solution.DurationDetails);
        lblImplementationDetails.Text = WebUtility.HtmlDecode(solutionComponent.Solution.ImplementationDetails);
        //lblCostTitle.Text = NexsoProBLL.ListComponent.GetLabelFromListValue("Cost", Thread.CurrentThread.CurrentCulture.Name,
        //                                                                 solutionComponent.Solution.CostType.ToString());

        //lblSubmitted.Text = DateTime.Today.ToShortDateString();
        if (!string.IsNullOrEmpty(solutionComponent.Solution.VideoObject))
        {
            videoPanel.Visible = true;
            videoObject.Text = formatVideoObject(solutionComponent.Solution.VideoObject);
        }

        UserInfo user = UserController.GetUserById(PortalId, solutionComponent.Solution.CreatedUserId.GetValueOrDefault(-1));

        if (user != null)
        {
            lblPublishedBy.Text = WebUtility.HtmlDecode(user.FirstName) + " " + WebUtility.HtmlDecode(user.LastName);
            hlPublishedBy.NavigateUrl = NexsoHelper.GetCulturedUrlByTabName("My Nexso") + "/ui/" + user.UserID.ToString();

        }
        else
            lblPublishedBy.Text = Localization.GetString("Anonimous", LocalResourceFile);
        fileSupportDocuments.SolutionId = solutionComponent.Solution.SolutionId;
        filePrivateDocuments.SolutionId = solutionComponent.Solution.SolutionId;
        if (!string.IsNullOrEmpty(folder))
            filePrivateDocuments.Folder = folder;
        else
            filePrivateDocuments.Folder = "/challenge/20141/jpo/private";

        if (folders.Count() > 0)
        {
            filePrivateDocuments.Folders = folders;
        }
        bindLocationControl(solutionComponent.Solution.SolutionId);
        NXMapModule.LocationPanelTitle = Localization.GetString("pnlLocations", LocalResourceFile);
        NXMapModule.EmptyMessage = Localization.GetString("EmptyLocation", LocalResourceFile);


        BadgeComponent badgeComponent = new BadgeComponent(solutionComponent.Solution.SolutionId, "Curator");
        if (badgeComponent.Badge.BadgeId == Guid.Empty)
        {
            curatorResponsive.Visible = false;
            curatorContainer.Visible = false;
        }
        else
        {
            lblNameCurator.Text = badgeComponent.Badge.Description;
            lblCurator.Text = Localization.GetString("lblCurator", LocalResourceFile) + " ";
            curatorResponsive.Visible = true;
            curatorContainer.Visible = true;
        }
    }

    /// <summary>
    /// Load HTML format for show the video
    /// </summary>
    /// <param name="url"></param>
    /// <returns></returns>
    private string formatVideoObject(string url)
    {
        return "<p><iframe width='560' height='315' src='" + url + "' frameborder='0' allowfullscreen='' ></iframe></p>";
    }

    /// <summary>
    /// This method converts the XML in HTML controls depending on user permissions
    /// </summary>
    private void FillOtherInformation()
    {
        ChallengeJudgeComponent challengeJudgeComponent = new ChallengeJudgeComponent(UserId, solutionComponent.Solution.ChallengeReference);
        bool sw1 = false;
        if (challengeJudgeComponent.ChallengeJudge != null)
        {
            if (challengeJudgeComponent.ChallengeJudge.UserId == UserController.GetCurrentUserInfo().UserID)
                sw1 = true;
        }

        if (sw1 || UserController.GetCurrentUserInfo().IsInRole("Administrators") || UserController.GetCurrentUserInfo().IsInRole("NexsoSupport") || UserController.GetCurrentUserInfo().UserID == solutionComponent.Solution.CreatedUserId)
        {
            bool sw = false;
            if (!string.IsNullOrEmpty(solutionComponent.Solution.ChallengeReference))
            {
                ChallengeCustomDataComponent challengeCustomDataComponent = new ChallengeCustomDataComponent(solutionComponent.Solution.ChallengeReference, Language);
                string xDocTemplate = challengeCustomDataComponent.ChallengeCustomData.CustomDataTemplate;

                string xDoc2 = solutionComponent.Solution.CustomData;
                if (!string.IsNullOrEmpty(xDoc2) && !string.IsNullOrEmpty(xDocTemplate))
                {
                    StringBuilder str = new StringBuilder();
                    List<OtherInformation> listLabels = GetListXML(xDocTemplate, false);
                    List<OtherInformation> listValues = GetListXML(xDoc2, true);

                    foreach (var item in listLabels)
                    {
                        foreach (var itemL in listValues)
                        {

                            if (itemL.Key == item.Key || "rbCustom" + itemL.Key == item.Key || "txtCustom" + itemL.Key == item.Key
                                || "cbCustom" + itemL.Key == item.Key || "ddCustom" + itemL.Key == item.Key)
                            {

                                var count = 0;
                                foreach (var itemList in itemL.List)
                                {
                                    if (count == 0 && !string.IsNullOrEmpty(itemList))
                                    {
                                        str.Append("<h3 class=\"label\">");
                                        str.Append(item.Label);
                                        str.Append("</h3>");
                                    }

                                    var text = GetTextforValue(xDocTemplate, itemList, itemL.Key);
                                    if (text == string.Empty)
                                        text = itemList;

                                    if (!string.IsNullOrEmpty(text))
                                    {
                                        str.Append("<p>");
                                        str.Append(text);
                                        var value = text;

                                        if (value.Contains("youtube.com") || value.Contains("youtu.be") || value.Contains("vimeo.com"))
                                        {

                                            if (value.Contains("www.youtube.com/embed/"))
                                            {
                                                if (!value.Contains("http"))
                                                {
                                                    value = "https://" + text;
                                                }

                                                str.Append("<iframe width=\"560\" height=\"315\" src='" + value + "' frameborder=\"0\" allowfullscreen></iframe>");
                                            }
                                            else
                                            {

                                                var url = "";
                                                var video_id = GetVideoId(value, "v=");
                                                var baseUrl = "https://www.youtube.com/embed/";
                                                if (video_id != "")
                                                {
                                                    url = baseUrl + video_id;
                                                }
                                                else
                                                {
                                                    video_id = GetVideoId(value, "youtu.be/");
                                                    if (video_id != "")
                                                    {
                                                        url = baseUrl + video_id;
                                                    }
                                                    else
                                                    {

                                                        video_id = GetVideoId(value, "vimeo.com/");
                                                        if (video_id != "")
                                                        {
                                                            url = "//player.vimeo.com/video/" + video_id;
                                                        }

                                                    }
                                                }

                                                if (url != "")
                                                {

                                                    str.Append("<iframe width=\"560\" height=\"315\" src='" + url + "' frameborder=\"0\" allowfullscreen></iframe>");
                                                }

                                            }
                                        }
                                        str.Append("</p>");
                                    }
                                    count++;
                                }
                                break;
                            }
                        }
                    }
                    lOtherInformation.Text = str.ToString();
                }
                else
                    sw = true;
            }
            else
                sw = true;

            if (string.IsNullOrEmpty(lOtherInformation.Text))
                sw = true;
            if (sw)
            {
                string xDoc2 = solutionComponent.Solution.CustomData;
                if (!string.IsNullOrEmpty(xDoc2))
                {
                    var list = ListComponent.GetListPerCategory("GeneralDictionary", Thread.CurrentThread.CurrentCulture.Name).ToList();
                    XmlDocument xDoc = new XmlDocument();
                    xDoc.LoadXml(xDoc2);
                    StringBuilder str = new StringBuilder();
                    foreach (XmlNode path in xDoc.DocumentElement.ChildNodes)
                    {
                        if (path.ChildNodes.Count == 4)
                        {
                            if (!path.ChildNodes[0].Equals(null) && !path.ChildNodes[1].Equals(null))
                            {

                                if (!path.ChildNodes[0].ChildNodes[0].Equals(null))
                                {
                                    string key = path.ChildNodes[0].ChildNodes[0].Value;

                                    string Value = "";

                                    if (path.ChildNodes[1].ChildNodes.Count > 0)
                                        Value = path.ChildNodes[1].ChildNodes[0].Value;
                                    if (!string.IsNullOrEmpty(Value))
                                    {
                                        foreach (var element in list)
                                        {
                                            if (element.Key.Equals(key) || element.Key.Equals(key.Replace("txtCustom", ""))
                                                || element.Key.Equals(key.Replace("ddCustom", "")) || element.Key.Equals(key.Replace("rbCustom", ""))
                                                || element.Key.Equals(key.Replace("cbCustom", "")))
                                            {
                                                str.Append("<h3 class=\"label\">");
                                                str.Append(element.Label);
                                                str.Append("</h3>");
                                                str.Append("<p>");
                                                str.Append(Value);
                                                str.Append("</p>");

                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    lOtherInformation.Text = str.ToString();
                }
            }
            dvOtherInformationPanel.Visible = !string.IsNullOrEmpty(lOtherInformation.Text);

        }
    }

    /// <summary>
    /// Registers the client script with the Page object using a key and a URL, which enables the script to be called from the client.
    /// </summary>
    private void RegisterScripts()
    {
        Page.Header.Controls.Add(
new System.Web.UI.LiteralControl("<link rel=\"stylesheet\" type=\"text/css\" href=\"" + ControlPath + "css/styleUploader.css" + "\" />"));
        Page.Header.Controls.Add(
new System.Web.UI.LiteralControl("<link rel=\"stylesheet\" type=\"text/css\" href=\"" + ControlPath + "css/module.css" + "\" />"));

        Page.ClientScript.RegisterClientScriptInclude(
              this.GetType(), "jquery.alerts", ControlPath + "js/jquery.alerts.js");
        Page.ClientScript.RegisterClientScriptInclude(
              this.GetType(), "NXSolutionV2", ControlPath + "js/NXSolutionV2.js");

        Page.ClientScript.RegisterClientScriptInclude(
             this.GetType(), "jquery.filedrop", ControlPath + "js/jquery.filedrop.js");

        Page.ClientScript.RegisterClientScriptInclude(
             this.GetType(), "script", ControlPath + "js/script.js");

        string script = "<script>" +

            "var messageConfirmation = '" + Localization.GetString("MessageConfirmation", LocalResourceFile) + "';"

           + "var userId = " + UserInfo.UserID + ";"



           + "var lblChallenge = '" + lblChallenge.ClientID + "';"
           + "var lblApproach = '" + lblApproach.ClientID + "';"
           + "var lblResults = '" + lblResults.ClientID + "';"
           + "var lblDescription = '" + lblDescription.ClientID + "';"
           + "var lblCostDetails = '" + lblCostDetails.ClientID + "';"
           + "var lbldurationDetails = '" + lbldurationDetails.ClientID + "';"
           + "var lblImplementationDetails = '" + lblImplementationDetails.ClientID + "';"
           + "var lblOrganizationDescription = '" + lblOrganizationDescription.ClientID + "';"
           + "var lblTitle = '" + lblTitle.ClientID + "';"
           + "var lblTagLine = '" + lblTagLine.ClientID + "';"
           + "var lblInstitutionName = '" + lblInstitutionName.ClientID + "';"
           + "var hfTitle = '" + hfTitle.ClientID + "';"
           + "var hfTitle2 = '" + hfTitle2.ClientID + "';"
           + "var hfTagLine = '" + hfTagLine.ClientID + "';"
           + "var hfTagLine2 = '" + hfTagLine2.ClientID + "';"
           + "var hfInstitutionName = '" + hfInstitutionName.ClientID + "';"
           + "var hfInstitutionName2 = '" + hfInstitutionName2.ClientID + "';"
           + "var lblCount = '" + lblCount.ClientID + "';"
           + "var hfLnguage = '" + hfLnguage.ClientID + "';"
           + "var MessageTransalte = '" + MessageTransalte.ClientID + "';"
           + "var MessageTransalte2 = '" + MessageTransalte2.ClientID + "';"
           + "var btnEdit = '" + btnEdit.ClientID + "';"
           + "var btnDelete = '" + btnDelete.ClientID + "';"
           + "var languageName = '" + System.Threading.Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName.ToUpper() + "';"
           + "var textPopUpReportSpam = '" + Localization.GetString("PopUpReportSpam", this.LocalResourceFile) + "';"
           + "var textConfirmationUnPublish = '" + Localization.GetString("ConfirmationUnPublish", this.LocalResourceFile) + "';"
           + "var textUnpublishTitle = '" + Localization.GetString("UnpublishTitle", this.LocalResourceFile) + "';"
           + "var textDeleteTitle = '" + Localization.GetString("DeleteTitle", this.LocalResourceFile) + "';"
           + "var textbtnOk = '" + Localization.GetString("btnOk", this.LocalResourceFile) + "';"
           + "var textbtnCancel = '" + Localization.GetString("btnCancel", this.LocalResourceFile) + "';"
           + "var messageConfirmation2 = '" + Localization.GetString("MessageConfirmation", LocalResourceFile) + "';"
           + "var SolutionLanguage = '" + SolutionLanguage + "';"

         + " $(document).ready(function () { "

          + "    Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(EndRequestHandler1" + ClientID + "); "
            + "    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler1" + ClientID + "); "
        + "}  ); "

         + "   function EndRequestHandler1" + ClientID + "(sender, args) { "
        + "        "
        + " activateUploaderControls('" + System.Threading.Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName.ToUpper() + "',  $('#btnEnableBannerUploader'),$( '#btnCancelBanner'),   $('#btnSaveBanner'),$('#" + hfSolutionId.ClientID + "').val());  }"

        + "</script>";


        Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Script22", script);

    }

    /// <summary>
    /// some solutions have video . 
    /// </summary>
    /// <param name="url"></param>
    /// <param name="parm"></param>
    /// <returns>This method returns the video ID(Vimeo o youtube)</returns>
    private string GetVideoId(string url, string parm)
    {
        var IdReturn = "";

        var video_id = url.Split(new string[] { parm }, StringSplitOptions.None);

        if (video_id.Length > 1)
        {
            var ampersandPosition = video_id[1].IndexOf('&');
            if (ampersandPosition != -1)

                IdReturn = video_id[1].Substring(0, ampersandPosition);
            else
                IdReturn = video_id[1];
        }
        return IdReturn;
    }

    /// <summary>
    /// get the text for each Control from the XML
    /// </summary>
    /// <param name="xDoc2"></param>
    /// <param name="val"></param>
    /// <param name="key"></param>
    /// <returns></returns>
    private string GetTextforValue(string xDoc2, string val, string key)
    {

        byte[] byteArray = new byte[xDoc2.Length];
        System.Text.Encoding encoding = System.Text.Encoding.Unicode;
        byteArray = encoding.GetBytes(xDoc2);
        MemoryStream memoryStream = new MemoryStream(byteArray);
        memoryStream.Seek(0, SeekOrigin.Begin);
        List<OtherInformation> lst = new List<OtherInformation>();
        string txt = string.Empty;
        if (byteArray.Length > 0)
        {
            try
            {

                var reader = XmlReader.Create(memoryStream);
                reader.MoveToContent();
                while (reader.Read())
                {
                    if (reader.NodeType == XmlNodeType.Element && reader.Name == "ID")
                    {
                        var id = reader.ReadString().ToString();
                        if (id == key || id == "rbCustom" + key || id == "cbCustom" + key
                            || id == "txtCustom" + key || id == "ddCustom" + key ||
                            id.Replace("txtCustom", "") == key || id.Replace("ddCustom", "") == key)
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
                                            value = reader.ReadString();

                                        if (reader.NodeType == XmlNodeType.Element && reader.Name == "TEXT")
                                            text = reader.ReadString();

                                        if (reader.NodeType == XmlNodeType.EndElement && reader.Name == "OPTION")
                                            break;
                                    }
                                    if (value != string.Empty || text != string.Empty)
                                    {
                                        if (value == val)
                                        {
                                            txt = text;
                                            break;
                                        }
                                    }

                                }
                                if (reader.NodeType == XmlNodeType.EndElement && reader.Name == "OPTIONS")
                                    break;
                            }
                            break;
                        }
                    }
                }
            }
            catch
            {

            }
        }

        return txt;
    }

    /// <summary>
    /// Convert XML to controls (assessment)
    /// </summary>
    /// <param name="xDoc2"></param>
    /// <param name="sw"></param>
    /// <returns></returns>
    private List<OtherInformation> GetListXML(string xDoc2, bool sw)
    {
        byte[] byteArray = new byte[xDoc2.Length];
        System.Text.Encoding encoding = System.Text.Encoding.Unicode;
        byteArray = encoding.GetBytes(xDoc2);
        MemoryStream memoryStream = new MemoryStream(byteArray);
        memoryStream.Seek(0, SeekOrigin.Begin);
        List<OtherInformation> lst = new List<OtherInformation>();
        string KEY, LABEL;
        if (byteArray.Length > 0)
        {
            try
            {

                var reader = XmlReader.Create(memoryStream);
                reader.MoveToContent();
                while (reader.Read())
                {
                    if (sw)
                    {

                        List<string> LSTVALUES = new List<string>();
                        KEY = string.Empty;
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

                            lst.Add(new OtherInformation() { Key = KEY, List = LSTVALUES });
                        }
                    }
                    else
                    {

                        KEY = LABEL = string.Empty;

                        if (reader.NodeType == XmlNodeType.Element
                            && reader.Name == "CONTROL")
                        {
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "ID")
                                {
                                    KEY = reader.ReadString();
                                    break;
                                }
                            }
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element && reader.Name == "TYPE")
                                {
                                    var folderss = reader.GetAttribute("folder");
                                    if (reader.ReadString() == "FILEUPLOADERWIZARD")
                                    {

                                        folder = folderss;
                                        folders.Add(folderss);
                                    }
                                    break;
                                }
                            }
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "LABEL")
                                {
                                    LABEL = reader.ReadString();
                                    break;
                                }
                            }
                            lst.Add(new OtherInformation() { Key = KEY, Label = LABEL });
                        }
                    }
                }
            }
            catch
            {

            }
        }
        return lst;
    }

    /// <summary>
    /// Returns the places where the solution will be implemented. These sites were added by the user who  he created the solution.
    /// </summary>
    /// <param name="solutionId"></param>
    private void bindLocationControl(Guid solutionId)
    {
        List<SolutionLocation> solutionLocationList;
        solutionLocationList = SolutionLocationComponent.GetSolutionLocationsPerSolution(solutionId).ToList();
        List<CountryStateCityV2.Location> listLocation = new List<CountryStateCityV2.Location>();
        if (solutionComponent.Solution.Organization != null)
        {
            listLocation.Add(new CountryStateCityV2.Location()
            {
                city = solutionComponent.Solution.Organization.City,
                state = solutionComponent.Solution.Organization.Region,
                country = solutionComponent.Solution.Organization.Country,
                latitude = solutionComponent.Solution.Organization.Latitude.GetValueOrDefault(0),
                longitude = solutionComponent.Solution.Organization.Longitude.GetValueOrDefault(0),
                postal_code = solutionComponent.Solution.Organization.ZipCode,
                inputAddress = solutionComponent.Solution.Organization.Address,
                type = "organization"
            });
            NXMapModule.Organization = solutionComponent.Solution.Organization;
            NXMapModule.Locations = listLocation;
            NXMapModule.UpdateMap();
        }

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
                inputAddress = location.Address,
                type = "testLocation"

            });

            NXMapModule.Locations = listLocation;
            NXMapModule.UpdateMap();
        }


    }

    /// <summary>
    /// Return the actual state of the solution
    /// </summary>
    /// <param name="state"></param>
    /// <returns></returns>
    protected string GetSolutionState(int state)
    {
        var stateText = Localization.GetString("State", LocalResourceFile);
        var list = ListComponent.GetListPerCategory("SolutionState", Thread.CurrentThread.CurrentCulture.Name).ToList();
        foreach (var item in list)
        {
            if (Convert.ToInt32(item.Value) == state)
            {
                return stateText + " " + item.Label;
            }
        }
        return stateText + " Empty";
    }
    #endregion

    #region  Public Properties
    public Guid SolutionId
    {
        get { return solutionId; }
        set { solutionId = value; }
    }
    public bool PreviewMode
    {
        get { return previewMode; }
        set { previewMode = value; }

    }
    #endregion

    #region  Public Methods
    /// <summary>
    /// Search the main image of the solution on the server. If the image doesn't exist shows a generic image
    /// </summary>
    public void AddHeader()
    {
        if (File.Exists(
            Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/cropBig" +
                           solutionId.ToString() +
                           ".jpg")))
        {
            imgBanner.ImageUrl = PortalSettings.HomeDirectory + "ModIma/HeaderImages/cropBig" + solutionId.ToString() + ".jpg";
        }
        else if (File.Exists(
            Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/cropBig" +
                           solutionId.ToString() +
                           ".png")))
        {
            imgBanner.ImageUrl = PortalSettings.HomeDirectory + "ModIma/HeaderImages/cropBig" + solutionId.ToString() + ".png";
        }
        else
        {
            var list = SolutionListComponent.GetListPerCategory(solutionId, "Theme").ToList();

            if (list.Count > 0)
            {
                Random randNum = new Random();

                var theme = list[randNum.Next(list.Count)].Key;
                if (File.Exists(
                Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/" + theme + ".jpg")))
                {
                    imgBanner.ImageUrl = PortalSettings.HomeDirectory + "ModIma/HeaderImages/" + theme + ".jpg";
                }
                else
                {
                    imgBanner.ImageUrl = PortalSettings.HomeDirectory + "ModIma/HeaderImages/noHeader.png";
                }

            }
            else
            {
                imgBanner.ImageUrl = PortalSettings.HomeDirectory + "ModIma/HeaderImages/noHeader.png";
            }
        }

    }

    /// <summary>
    /// Load organization logo
    /// </summary>
    public void Loadlogo()
    {
        if (!string.IsNullOrEmpty(organizationComponent.Organization.Logo))
        {
            imgOrganizationLogo.ImageUrl = PortalSettings.HomeDirectory + "ModIma/Images/" +
                                      organizationComponent.Organization.Logo;

        }
        else
        {
            imgOrganizationLogo.ImageUrl = PortalSettings.HomeDirectory + "ModIma/Images/noImage.png";
        }
    }
    public void LoadData()
    {
        solutionComponent = new SolutionComponent(solutionId);
        organizationComponent = new OrganizationComponent(solutionComponent.Solution.OrganizationId);
        hfSolutionId.Value = solutionId.ToString();
        PopulateLabels();
        BindData();
        Loadlogo();
        fileSupportDocuments.BindData();
        filePrivateDocuments.BindData();
    }

    #endregion

    #region  Subclasses
    public class OtherInformation
    {
        public string Key { get; set; }
        public string Label { get; set; }
        public List<string> List { get; set; }
    }
    #endregion

    #region  Events

    /// <summary>
    /// Setup Page
    /// </summary>
    /// <param name="e"></param>
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
    /// Loads the details from the solutions into the view's child elements
    /// </summary>
    protected void Page_Load(object sender, EventArgs e)
    {
        DotNetNuke.Framework.ServicesFramework.Instance.RequestAjaxScriptSupport();
    }


    /// <summary>
    /// Add meta tags to the head. These tags allow Facebook take this information automatically when a user  share the solution in the social network 
    /// </summary>
    private void PopulateHtmlHead()
    {
        string textHtml =
            @"<meta property='og:title' content='" + solutionComponent.Solution.Title + "'/>" +
            @"<meta property='og:image' content='" + Request.Url.Scheme + "://" + Request.Url.Authority + imgBanner.ImageUrl + "' />" +
            @"<meta property='og:site_name' content='NEXSO'/>" +
            @"<meta property='og:description' content='" + solutionComponent.Solution.TagLine + "' />"
            ;

        var headText = new Literal()
        {
            Text = textHtml
        };

        Page.Header.Controls.Add(headText);
    }

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        objTabController = new TabController();




        LoadParams();

        solutionComponent = new SolutionComponent(solutionId);




        this.Page.Title = solutionComponent.Solution.Title;
        hfSolutionId.Value = solutionId.ToString();
        organizationComponent = new OrganizationComponent(solutionComponent.Solution.OrganizationId);

        PopulateLabels();

        if (!IsPostBack)
        {
            AddHeader();
            BindData();
            PopulateHtmlHead();
            try
            {
                if (UserController.GetCurrentUserInfo().IsInRole("Registered Users"))
                {
                    SocialMediaIndicatorComponent socialMediaIndicatorComponent = new SocialMediaIndicatorComponent(solutionComponent.Solution.SolutionId, "SOLUTION", "VIEW", UserController.GetCurrentUserInfo().UserID);

                    if (socialMediaIndicatorComponent.SocialMediaIndicator.SocialMediaIndicatorId == Guid.Empty)
                    {
                        socialMediaIndicatorComponent.SocialMediaIndicator.Value = 1;
                        socialMediaIndicatorComponent.SocialMediaIndicator.Created = DateTime.Now;
                        socialMediaIndicatorComponent.SocialMediaIndicator.Aggregator = "SUM";
                        socialMediaIndicatorComponent.Save();
                    }
                }
            }
            catch
            {


            }


        }
        Loadlogo();

        if (UserController.GetCurrentUserInfo().UserID < 0)
        {
            btnReportSpam.Visible = false;
            btnUnpublish.Visible = false;



        }
        if (!IsPostBack)
            RegisterScripts();

    }

    /// <summary>
    /// Change estate of the solution. Tne new state is 0
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnUnpublish_Click(object sender, EventArgs e)
    {
        if (solutionComponent.Solution.SolutionState >= 800)
        {
            solutionComponent.Solution.SolutionState = 0;
            if (solutionComponent.Save() < 0)
                Exceptions.ProcessModuleLoadException(this, new Exception("error database"));
        }
        Response.Redirect(NexsoHelper.GetCulturedUrlByTabName("promote") + "/sl/" + solutionComponent.Solution.SolutionId);

    }

    /// <summary>
    /// send an email reporting that the solution is a spam
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReportSpam_Click(object sender, EventArgs e)
    {
        DotNetNuke.Services.Mail.Mail.SendEmail("nexso@iadb.org", "jairoa@iadb.org,YVESL@iadb.org,MONICAO@iadb.org", "Spam Report", string.Format(Localization.GetString("ReportSpamTemplate", LocalResourceFile), solutionId, UserId.ToString()));

        Page.ClientScript.RegisterStartupScript(this.GetType(), "PopUpReportSpam", "PopUpReportSpam();", true);

        btnReportSpam.Text = Localization.GetString("SolutionReported", LocalResourceFile);
        btnReportSpam.Enabled = false;
    }

    /// <summary>
    /// Change page to score mode
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnRate_Click(object sender, EventArgs e)
    {
        Response.Redirect(NexsoHelper.GetCulturedUrlByTabName("solprofilescore") + "/sl/" + solutionId.ToString(), false);
    }
    protected void DeleteSolution_Click(object sender, EventArgs e)
    {
        UserInfo user = UserController.GetUserById(PortalId, solutionComponent.Solution.CreatedUserId.GetValueOrDefault(-1));
        solutionComponent.Solution.Deleted = true;
        solutionComponent.Solution.DateUpdated = DateTime.Now;
        solutionComponent.Save();
        Response.Redirect(NexsoHelper.GetCulturedUrlByTabName("MySolutions") + "/ui/" + user.UserID.ToString());

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
