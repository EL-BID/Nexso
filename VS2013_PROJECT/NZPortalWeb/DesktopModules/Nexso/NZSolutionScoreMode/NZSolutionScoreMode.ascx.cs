using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Text;
using System.Threading;
using System.Globalization;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Resources;
using System.Text.RegularExpressions;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Services.Localization;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Security;
using DotNetNuke.Entities.Tabs;
using DotNetNuke.Entities.Users;
using DotNetNuke.Services.Exceptions;
using DotNetNuke.Entities.Portals;
using DotNetNuke.Entities.Users;
using DotNetNuke.Common;
using NexsoProDAL;
using NexsoProBLL;
using MIFWebServices;
using System.Xml;
using request = System.Web.Http;

using System.Net;
using System.Net.Http;
using System.Web.Http;

/// <summary>
/// This control is equals a NZSolutions. but here add questions of calification solutions
/// https://www.nexso.org/solprofilescore/sl/7223e31c-b459-45a9-ba31-6351cc255a3b
/// </summary>
public partial class NZSolutionScoreMode : PortalModuleBase, IActionable
{
    protected TabController objTabController;
    private Guid solutionId;
    private ChallengeJudgeComponent challengeJudgeComponent;

    public Guid SolutionId
    {
        get { return solutionId; }
        set { solutionId = value; }
    }

    private ScoreComponent.ScoreJudge scoreJudge;
    protected SolutionComponent solutionComponent;
    private OrganizationComponent organizationComponent;
    private string folder = string.Empty;
    string Language = System.Globalization.CultureInfo.CurrentUICulture.Name;
    List<Generic> listControls = new List<Generic>();
    private List<string> challengeReferences = new List<string>();
    string commentReference = "";

    /// <summary>
    /// Loads the details from the solutions into the view's child elements
    /// </summary>
    protected void Page_Load(object sender, EventArgs e)
    {
        LoadSettings();
    }

    protected override void Render(HtmlTextWriter writer)
    {
        FillFlavor();
        base.Render(writer);
    }

    protected override void OnInit(EventArgs e)
    {
        LoadParams();
        solutionComponent = new SolutionComponent(solutionId);
        ChallengeCustomDataComponent challengeCustomDataComponent = new ChallengeCustomDataComponent(solutionComponent.Solution.ChallengeReference, Language);
        if (challengeCustomDataComponent != null)
        {
            if (!string.IsNullOrEmpty(challengeCustomDataComponent.ChallengeCustomData.Scoring))
            {
                XMLCreateControls(challengeCustomDataComponent.ChallengeCustomData.Scoring);
            }
        }
        base.OnInit(e);
        string FileName = System.IO.Path.GetFileNameWithoutExtension(this.AppRelativeVirtualPath);
        if (this.ID != null)
        {
            //this will fix it when its placed as a ChildUserControl 
            this.LocalResourceFile = this.LocalResourceFile.Replace(this.ID, FileName);
        }
        else
        {
            // this will fix it when its dynamically loaded using LoadControl method 
            this.LocalResourceFile = this.LocalResourceFile + FileName + ".ascx.resx";
        }
    }

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

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        objTabController = new TabController();
        LoadParams();
        solutionComponent = new SolutionComponent(solutionId);
        organizationComponent = new OrganizationComponent(solutionComponent.Solution.OrganizationId);
        challengeJudgeComponent = new ChallengeJudgeComponent(UserController.GetCurrentUserInfo().UserID, solutionComponent.Solution.ChallengeReference);
        bool sw = false;
        if (challengeJudgeComponent.ChallengeJudge != null)
        {
            if (challengeJudgeComponent.ChallengeJudge.UserId == UserController.GetCurrentUserInfo().UserID)
                sw = true;
        }
        if (challengeJudgeComponent.ChallengeJudge.PermisionLevel == "MOBILIZER")
        {
            sw = false;
        }
        if (sw || UserController.GetCurrentUserInfo().IsInRole("Administrators") || UserController.GetCurrentUserInfo().IsInRole("NexsoSupport"))
        {
            var challenge = GetChallenge();
            if (challenge == string.Empty)
            {
                scoreJudge = new ScoreComponent.ScoreJudge(solutionId, UserController.GetCurrentUserInfo().UserID);
            }
            else
            {
                scoreJudge = new ScoreComponent.ScoreJudge(solutionId, UserController.GetCurrentUserInfo().UserID, challenge);
            }
            PopulateLabels();
            if (!IsPostBack)
            {
                AddHeader();
                BindData();
            }
            Loadlogo();

            if (UserController.GetCurrentUserInfo().UserID < 0)
            {
                btnReportSpam.Visible = false;
                btnUnpublish.Visible = false;
            }
        }
        else
        {
            Response.Redirect(NexsoHelper.GetCulturedUrlByTabName("solprofile") + "/sl/" + solutionId.ToString());
        }
    }

    /// <summary>
    /// Search the main image of the solution on the server. If the image doesn't exist shows a generic image
    /// </summary>
    public void AddHeader()
    {
        if (File.Exists(
            Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/" +
                           solutionId.ToString() +
                           ".jpg")))
        {
            imgBanner.ImageUrl = PortalSettings.HomeDirectory + "ModIma/HeaderImages/" + solutionId.ToString() + ".jpg";
        }
        else if (File.Exists(
            Server.MapPath(PortalSettings.HomeDirectory + "ModIma/HeaderImages/" +
                           solutionId.ToString() +
                           ".png")))
        {
            imgBanner.ImageUrl = PortalSettings.HomeDirectory + "ModIma/HeaderImages/" + solutionId.ToString() + ".png";
        }
        else
        {
            imgBanner.ImageUrl = PortalSettings.HomeDirectory + "ModIma/HeaderImages/noHeader.png";
        }
    }

    /// <summary>
    /// Convert string to list  challengeReferences
    /// </summary>
    private void LoadSettings()
    {
        if (Settings["ChallengeReferences"] != null)
        {
            string references = Regex.Replace(Settings["ChallengeReferences"].ToString(), @"\s+", "");
            references = !string.IsNullOrEmpty(references) ? references : "";
            if (references.Contains(","))
            {
                challengeReferences = references.Split(',').ToList();
            }
            else
            {
                challengeReferences.Add(references);
            }
        }
        else
        {
            challengeReferences.Add("");
        }

        if (Settings["commentReference"] != null)
        {
            commentReference = Settings["commentReference"].ToString();
        }
    }

    /// <summary>
    /// Load organization logo
    /// </summary>
    public void Loadlogo()
    {
        if (!string.IsNullOrEmpty(organizationComponent.Organization.Logo))
        {
            imgOrganizationLogo.ImageUrl = PortalSettings.HomeDirectory + "ModIma/Images/" + organizationComponent.Organization.Logo;
        }
        else
        {
            imgOrganizationLogo.ImageUrl = PortalSettings.HomeDirectory + "ModIma/Images/noImage.png";
        }
    }

    public void LoadData()
    {
        organizationComponent = new OrganizationComponent(solutionComponent.Solution.OrganizationId);
        solutionComponent = new SolutionComponent(solutionId);
        var challenge = GetChallenge();
        if (challenge == string.Empty)
        {
            scoreJudge = new ScoreComponent.ScoreJudge(solutionId, UserController.GetCurrentUserInfo().UserID);
        }
        else
        {
            scoreJudge = new ScoreComponent.ScoreJudge(solutionId, UserController.GetCurrentUserInfo().UserID, challenge);
        }
        PopulateLabels();
        BindData();
        Loadlogo();
        fileSupportDocuments.BindData();
        filePrivateDocuments.BindData();
    }

    /// <summary>
    /// Load solution id via query string
    /// </summary>
    private void LoadParams()
    {
        if (solutionId == Guid.Empty)
        {
            if (Request.QueryString["sl"] != string.Empty)
            {
                try
                {
                    solutionId = new Guid(Request.QueryString["sl"]);
                }
                catch
                {
                    solutionId = Guid.Empty;
                }
            }
            else
            {
                solutionId = Guid.Empty;
            }
        }
    }


    /// <summary>
    /// Enable labels and buttons to show information from the solution
    /// </summary>
    private void PopulateLabels()
    {
        string urlBase = Request.Url.AbsoluteUri.Replace(Request.Url.PathAndQuery, "") + ControlPath;
        bool sw = false;
        ChallengeJudgeComponent challengeJudgeComponent = new ChallengeJudgeComponent(UserController.GetCurrentUserInfo().UserID, solutionComponent.Solution.ChallengeReference);
        if (challengeJudgeComponent.ChallengeJudge != null)
        {
            if (challengeJudgeComponent.ChallengeJudge.UserId == UserController.GetCurrentUserInfo().UserID)
            {
                if (!string.IsNullOrEmpty(challengeJudgeComponent.ChallengeJudge.FromDate.ToString()) || !string.IsNullOrEmpty(challengeJudgeComponent.ChallengeJudge.ToDate.ToString()))
                {
                    if (challengeJudgeComponent.ChallengeJudge.FromDate <= DateTime.Now && DateTime.Now <= challengeJudgeComponent.ChallengeJudge.ToDate)
                    {
                        sw = true;
                    }
                    else
                        if ((string.IsNullOrEmpty(challengeJudgeComponent.ChallengeJudge.FromDate.ToString()) && DateTime.Now <= challengeJudgeComponent.ChallengeJudge.ToDate) || (challengeJudgeComponent.ChallengeJudge.FromDate <= DateTime.Now && string.IsNullOrEmpty(challengeJudgeComponent.ChallengeJudge.ToDate.ToString())))
                    {
                        sw = true;
                    }
                }
                else
                {
                    sw = true;
                }
            }
        }

        if (commentReference == solutionComponent.Solution.ChallengeReference)
        {
            box.Visible = false;
            lblTitleFeedback.Visible = lblFeedBackEn.Visible = lblFeedBackEs.Visible = txtFeedBack.Visible = true;
            validatorFeedBack.Enabled = true;
        }
        else
        {
            box.Visible = true;
            lblTitleFeedback.Visible = lblFeedBackEn.Visible = lblFeedBackEs.Visible = txtFeedBack.Visible = false;
            validatorFeedBack.Enabled = false;
        }
        Comments.Visible = true;
        if (sw || UserController.GetCurrentUserInfo().IsInRole("Administrators") || UserController.GetCurrentUserInfo().IsInRole("NexsoSupport"))
        {
            if (solutionComponent.Solution.SolutionId != Guid.Empty)
            {
                if (solutionComponent.Solution.SolutionState.GetValueOrDefault(-1) >= 800)
                {
                    filePrivateDocuments.Visible = true;
                    dvOtherInformationPanel.Visible = true;
                    lblPrivateDocuments.Visible = true;

                    //Load header text in the Judges grid
                    gvListJudges.Columns[0].HeaderText = Localization.GetString("GridFirstName", LocalResourceFile);
                    gvListJudges.Columns[1].HeaderText = Localization.GetString("GridLastName", LocalResourceFile);
                    gvListJudges.Columns[2].HeaderText = Localization.GetString("GridScore", LocalResourceFile);
                    gvListJudges.Columns[3].HeaderText = Localization.GetString("GridCustomScore", LocalResourceFile);
                    gvListJudges.Columns[4].HeaderText = Localization.GetString("GridTotalScore", LocalResourceFile);
                }
            }
        }
        else
        {
            Response.Redirect(NexsoHelper.GetCulturedUrlByTabName("notauth"));
        }
        if (!challengeReferences.Contains(solutionComponent.Solution.ChallengeReference))
            PopulateLabelsScore();
    }

    /// <summary>
    /// Enable labels and buttons 
    /// </summary>
    private void PopulateLabelsScore()
    {
        pnlInstitutionNameScoreCard.Visible = true;
        pnlChallengeScoreCard.Visible = true;
        pnlApproachScoreCard.Visible = true;
        pnlResultsScoreCard.Visible = true;
        pnlImplementationDetailsScoreCard.Visible = true;
        pnlCostDetailsScoreCard.Visible = true;
        pnlCostScoreCard.Visible = true;
        pnldurationDetailsScoreCard.Visible = true;
        pnlDurationScoreCard.Visible = true;
        pnlDescriptionScoreCard.Visible = true;
    }

    /// <summary>
    /// This method converts the XML in HTML controls depending on user permissions
    /// </summary>
    private void FillOtherInformation()
    {
        ChallengeJudgeComponent challengeJudgeComponent = new ChallengeJudgeComponent(UserController.GetCurrentUserInfo().UserID, solutionComponent.Solution.ChallengeReference);
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
                                    {
                                        text = itemList;
                                    }
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
                                                else
                                                {
                                                    if (!value.Contains("https"))
                                                    {
                                                        value = value.Replace("http", "https");
                                                    }
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
                {
                    sw = true;
                }
            }
            else
            {
                sw = true;
            }
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
                                        {
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
                                    var folders = reader.GetAttribute("folder");
                                    if (reader.ReadString() == "FILEUPLOADERWIZARD")
                                    {
                                        folder = folders;
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
    /// Main method. This method load all information of the solution
    /// </summary>
    private void BindData()
    {
        FillTopicsData();
        FillOtherInformation();
        FillData();
        FillAvailableResources();
        FillBeneficiaries();
        FillThemes();
        FillFormat();
        FillScoreData();
        FillDataJudges();
        FillScore();
        FillFlavor();
        if (challengeReferences.Contains(solutionComponent.Solution.ChallengeReference))
        {
            lblScoreGlobal.Visible = false;
            lblAdditionalScoreGlobal.Visible = false;
        }
    }

    /// <summary>
    /// Load generic assessment
    /// </summary>
    private void FillScoreData()
    {
        rdbTitle.DataSource = ListComponent.GetListPerCategory("ScoreUniqueSelectorName", Thread.CurrentThread.CurrentCulture.Name).ToList();
        rdbTitle.DataBind();
        rdbTagLine.DataSource = ListComponent.GetListPerCategory("ScoreUniqueSelectorTagLine0-5", Thread.CurrentThread.CurrentCulture.Name).ToList();
        rdbTagLine.DataBind();
        chkChallenge.DataSource = ListComponent.GetListPerCategory("ScoreMultiSelectorChallenge", Thread.CurrentThread.CurrentCulture.Name).ToList();
        chkChallenge.DataBind();
        chkAproach.DataSource = ListComponent.GetListPerCategory("ScoreMultiSelectorInnovation", Thread.CurrentThread.CurrentCulture.Name).ToList();
        chkAproach.DataBind();
        chkResults.DataSource = ListComponent.GetListPerCategory("ScoreMultiSelectorResults", Thread.CurrentThread.CurrentCulture.Name).ToList();
        chkResults.DataBind();
        rbdCostDetails.DataSource = ListComponent.GetListPerCategory("ScoreYesNot", Thread.CurrentThread.CurrentCulture.Name).ToList();
        rbdCostDetails.DataBind();
        rbdDurationDetails.DataSource = ListComponent.GetListPerCategory("ScoreYesNot", Thread.CurrentThread.CurrentCulture.Name).ToList();
        rbdDurationDetails.DataBind();
        rdbImplemenationDetails.DataSource = ListComponent.GetListPerCategory("ScoreUniqueSelectorImplementation", Thread.CurrentThread.CurrentCulture.Name).ToList();
        rdbImplemenationDetails.DataBind();
        rdbDescription.DataSource = ListComponent.GetListPerCategory("ScoreYesNot", Thread.CurrentThread.CurrentCulture.Name).ToList();
        rdbDescription.DataBind();
        rdbDuration.DataSource = ListComponent.GetListPerCategory("ScoreYesNot", Thread.CurrentThread.CurrentCulture.Name).ToList();
        rdbDuration.DataBind();
        rdbCost.DataSource = ListComponent.GetListPerCategory("ScoreYesNot", Thread.CurrentThread.CurrentCulture.Name).ToList();
        rdbCost.DataBind();
    }


    private void FillFlavor()
    {
        if (solutionComponent.Solution.ChallengeReference == "EconomiaNaranja")
        {
            ChallengeComponent challengeComponent = new ChallengeComponent(solutionComponent.Solution.ChallengeReference);
            string dictionary = LocalResourceFile;
            if (!string.IsNullOrEmpty(challengeComponent.Challenge.Flavor))
            {
                if (challengeComponent.Challenge.Flavor != "Default")
                {
                    dictionary = LocalResourceFile + "Flavor" + challengeComponent.Challenge.Flavor;
                }
            }
            lblTagLineScoreCardFlavor.Text = Localization.GetString("ShortDescriptionDesc", dictionary);
            lblChallengeScoreCardFlavor.Text = Localization.GetString("BlockProblemDesc", dictionary);
            lblApproachScoreCardFlavor.Text = Localization.GetString("BlockInnovationDesc", dictionary);
            lblResultsScoreCardFlavor.Text = Localization.GetString("BlockBenefitsDesc", dictionary);
            lblImplementationDetailsScoreCardFlavor.Text = Localization.GetString("BlockDetailsDesc", dictionary);
            lblInstitutionNameScoreCard.Text = Localization.GetString("InstitutionNameScoreCard", dictionary);
            lblChallengeScoreCard.Text = Localization.GetString("ChallengeScoreCard", dictionary);
            lbldurationDetailsScoreCard.Text = Localization.GetString("DurationDetailsScoreCard", dictionary);
            lblDurationScoreCard.Text = Localization.GetString("DurationScoreCard", dictionary);
        }
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
        lblDeliveryFormat2.Text = str.ToString();
    }

    /// <summary>
    /// Fill other resources of the actual solution
    /// </summary>
    private void FillAvailableResources()
    {
        var list = SolutionListComponent.GetListPerCategory(solutionId, "AvailableResource");
        StringBuilder str = new StringBuilder();
        str.Append("<ul>");
        foreach (var item in list)
        {
            str.Append("<li>" + NexsoProBLL.ListComponent.GetLabelFromListKey("AvailableResource", Thread.CurrentThread.CurrentCulture.Name, item.Key) + "</li>");
        }
        str.Append("</ul>");
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
        lblBeneficiary2.Text = str.ToString();
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
        lblTheme2.Text = str.ToString();
    }


    /// <summary>
    /// Load in the controls all information of the solution (including score)
    /// </summary>
    private void FillData()
    {
        lblCount.Text = "0";
        lblCount.Style.Add("display", "none");
        hfTagLine.Text = WebUtility.HtmlDecode(solutionComponent.Solution.TagLine);
        hfTagLine.Style.Add("display", "none");
        hfTitle.Text = WebUtility.HtmlDecode(solutionComponent.Solution.Title);
        hfTitle.Style.Add("display", "none");
        lblTagLine.Text = WebUtility.HtmlDecode(solutionComponent.Solution.TagLine);
        lblChallenge.Text = WebUtility.HtmlDecode(solutionComponent.Solution.Challenge);
        lblApproach.Text = WebUtility.HtmlDecode(solutionComponent.Solution.Approach);
        lblResults.Text = WebUtility.HtmlDecode(solutionComponent.Solution.Results);
        if (!string.IsNullOrEmpty(solutionComponent.Solution.Description))
        {
            pnlLongDescription.Visible = true;
        }
        else
        {
            pnlLongDescription.Visible = false;
        }
        lblDescription.Text = WebUtility.HtmlDecode(solutionComponent.Solution.Description);
        lblTitle.Text = WebUtility.HtmlDecode(solutionComponent.Solution.Title);
        lblTitle2.Text = WebUtility.HtmlDecode(solutionComponent.Solution.Title);
        lblInstitutionName.Text = WebUtility.HtmlDecode(organizationComponent.Organization.Name);
        lblOrganizationDescription.Text = WebUtility.HtmlDecode(organizationComponent.Organization.Description);
        lblCountry.Text = LocationService.GetCountryName(organizationComponent.Organization.Country);
        hlInstitutionName.NavigateUrl = NexsoHelper.GetCulturedUrlByTabName("insprofile") + "/in/" + organizationComponent.Organization.OrganizationID;
        lblDuration.Text = ListComponent.GetLabelFromListValue("ProjectDuration", Thread.CurrentThread.CurrentCulture.Name, solutionComponent.Solution.Duration.ToString());
        lblDuration2.Text = ListComponent.GetLabelFromListValue("ProjectDuration", Thread.CurrentThread.CurrentCulture.Name, solutionComponent.Solution.Duration.ToString());
        lblCost.Text = "US" + String.Format(CultureInfo.GetCultureInfo(1033), "{0:C}", solutionComponent.Solution.Cost);//us
        lblCost2.Text = "US" + String.Format(CultureInfo.GetCultureInfo(1033), "{0:C}", solutionComponent.Solution.Cost) + " " + ListComponent.GetLabelFromListValue("Cost", Thread.CurrentThread.CurrentCulture.Name, solutionComponent.Solution.CostType.ToString());
        lblCostDetails.Text = WebUtility.HtmlDecode(solutionComponent.Solution.CostDetails);
        lbldurationDetails.Text = WebUtility.HtmlDecode(solutionComponent.Solution.DurationDetails);
        lblImplementationDetails.Text = WebUtility.HtmlDecode(solutionComponent.Solution.ImplementationDetails);
        UserInfo user = UserController.GetUserById(PortalId, solutionComponent.Solution.CreatedUserId.GetValueOrDefault(-1));
        if (user != null)
        {
            lblPublishedBy.Text = user.FirstName + " " + user.LastName;
            hlPublishedBy.NavigateUrl = Globals.UserProfileURL(user.UserID);
        }
        else
        {
            lblPublishedBy.Text = Localization.GetString("Anonimous", LocalResourceFile);
        }
        fileSupportDocuments.SolutionId = solutionComponent.Solution.SolutionId;
        filePrivateDocuments.SolutionId = solutionComponent.Solution.SolutionId;
        if (!string.IsNullOrEmpty(folder))
        {
            filePrivateDocuments.Folder = folder;
        }
        else
        {
            filePrivateDocuments.Folder = "/challenge/20141/jpo/private";
        }
        bindLocationControl(solutionComponent.Solution.SolutionId);
        NXMapModule.LocationPanelTitle = Localization.GetString("pnlLocations", LocalResourceFile);
        NXMapModule.EmptyMessage = Localization.GetString("EmptyLocation", LocalResourceFile);
        try
        {
            double scoreValue = 0;
            double scoreAdditionalValue = 0;
            double scoreTotalValue = 0;
            bool visible = false;
            bool sw = false;
            if (solutionComponent.Solution.ChallengeReference == null)
            {
                sw = true;
            }
            else
            {
                if (solutionComponent.Solution.ChallengeReference == "NEXSODEFAULT")
                {
                    scoreValue = ScoreComponent.ScoreJudge.GetGlobalJudgeScore(solutionId, solutionComponent.Solution.ChallengeReference);
                    if (scoreValue == double.MinValue)
                    {
                        sw = true;
                    }
                }
                else
                {
                    scoreValue = ScoreComponent.ScoreJudge.GetGlobalJudgeScore(solutionId, solutionComponent.Solution.ChallengeReference);
                    ChallengeCustomDataComponent challengeCustomDataComponent = new ChallengeCustomDataComponent(solutionComponent.Solution.ChallengeReference, Language);
                    if (challengeCustomDataComponent != null)
                    {
                        if (!string.IsNullOrEmpty(challengeCustomDataComponent.ChallengeCustomData.Scoring))
                        {
                            gvListJudges.Columns[2].HeaderText = Localization.GetString("GridScore2", LocalResourceFile);
                            scoreAdditionalValue = ScoreComponent.ScoreJudge.GetGlobalAdditionalJudgeScore(solutionId, solutionComponent.Solution.ChallengeReference);
                            scoreTotalValue = ScoreComponent.ScoreJudge.GetGlobalJudgeScoreXML(solutionId, solutionComponent.Solution.ChallengeReference);
                            if (challengeReferences.Contains(solutionComponent.Solution.ChallengeReference))
                            {
                                scoreTotalValue = ScoreComponent.ScoreJudge.GetGlobalAdditionalJudgeScore(solutionId, solutionComponent.Solution.ChallengeReference);
                            }
                        }
                        else
                        {
                            lblAdditionalScoreGlobal.Visible = false;
                            lblTotalScoreGlobal.Visible = false;
                        }
                    }
                    else
                    {
                        lblAdditionalScoreGlobal.Visible = false;
                        lblTotalScoreGlobal.Visible = false;
                    }
                }
            }
            if (sw)
            {
                var list = CustomDataLogComponent.GetCustomDataLogs(solutionId);
                if (list.Count() > 0)
                {
                    var challenge = new ChallengeCustomDataComponent(list.First().CustomaDataSchema);
                    if (challenge != null)
                    {
                        scoreValue = ScoreComponent.ScoreJudge.GetGlobalJudgeScore(solutionId, challenge.ChallengeCustomData.ChallengeReference);
                        ChallengeCustomDataComponent challengeCustomDataComponent = new ChallengeCustomDataComponent(challenge.ChallengeCustomData.ChallengeReference, Language);
                        if (challengeCustomDataComponent != null)
                        {
                            if (!string.IsNullOrEmpty(challengeCustomDataComponent.ChallengeCustomData.Scoring))
                            {
                                scoreAdditionalValue = ScoreComponent.ScoreJudge.GetGlobalJudgeScore(solutionId, challenge.ChallengeCustomData.ChallengeReference);
                                scoreTotalValue = ScoreComponent.ScoreJudge.GetGlobalJudgeScoreXML(solutionId, challenge.ChallengeCustomData.ChallengeReference);
                            }
                            else
                            {
                                visible = true;
                            }
                        }
                        else
                        {
                            visible = true;
                        }
                    }
                    else
                    {
                        scoreValue = ScoreComponent.ScoreJudge.GetGlobalJudgeScore(solutionId);
                        visible = true;
                    }
                }
                else
                {
                    scoreValue = ScoreComponent.ScoreJudge.GetGlobalJudgeScore(solutionId);
                    visible = true;
                }
            }
            if (visible)
            {
                lblAdditionalScoreGlobal.Visible = false;
                lblTotalScoreGlobal.Visible = false;
            }
            if (scoreValue != double.MinValue || challengeReferences.Contains(solutionComponent.Solution.ChallengeReference))
            {
                if (lblAdditionalScoreGlobal.Visible == false)
                {
                    lblScoreGlobal.Text = " <b>" + Localization.GetString("FinalScoreGlobal", this.LocalResourceFile) + " " +
                                          Math.Round(scoreValue, 1) + "</b>";
                }
                else
                {
                    lblScoreGlobal.Text = " <b>" + Localization.GetString("FinalScoreGlobal2", this.LocalResourceFile) + " " +
                                         Math.Round(scoreValue, 1) + "</b>";
                }
                if (challengeReferences.Contains(solutionComponent.Solution.ChallengeReference))
                {
                    lblScoreGlobal.Visible = false;
                }
                lblAdditionalScoreGlobal.Text = " <b>" + Localization.GetString("FinalAdditionalScoreGlobal", this.LocalResourceFile) + " " +
                                      Math.Round(scoreAdditionalValue, 1) + "</b>";
                lblTotalScoreGlobal.Text = " <b>" + Localization.GetString("TotalScoreGlobal", this.LocalResourceFile) + " " +
                                     Math.Round(scoreTotalValue, 1) + "</b>";

            }
            else
            {
                lblScoreGlobal.Text = Localization.GetString("NotScored", this.LocalResourceFile);
                lblAdditionalScoreGlobal.Visible = false;
                lblTotalScoreGlobal.Visible = false;
            }
            if (UserController.GetCurrentUserInfo().IsInRole("Administrators") || UserController.GetCurrentUserInfo().IsInRole("NexsoSupport") || challengeJudgeComponent.ChallengeJudge.PermisionLevel == "JUDGE-ADMIN")
            {
                if (!visible)
                {
                    lblAdditionalScoreGlobal.Visible = true;
                    lblScoreGlobal.Visible = true;
                    lblTotalScoreGlobal.Visible = true;
                }
            }
            else
            {
                lblAdditionalScoreGlobal.Visible = false;
                lblScoreGlobal.Visible = false;
                lblTotalScoreGlobal.Visible = false;
            }
            if (lblScoreGlobal.Text == Localization.GetString("NotScored", this.LocalResourceFile))
            {
                lblScoreGlobal.Visible = true;
            }
            if (scoreTotalValue == double.MinValue)
            {
                lblTotalScoreGlobal.Visible = false;
            }
        }
        catch (Exception e) { }
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
    /// main method to fill score
    /// </summary>
    public void FillScore()
    {
        if (scoreJudge.AbsoluteScore != 0 || challengeReferences.Contains(solutionComponent.Solution.ChallengeReference))
        {
            if (!challengeReferences.Contains(solutionComponent.Solution.ChallengeReference))
            {
                rdbSelected(rdbImplemenationDetails, scoreJudge.ImplementationScore, "Implementation");
                rdbSelected(rdbTagLine, scoreJudge.TagLineScore, "TagLine");
                ckSelected(chkChallenge, scoreJudge.ChallengeScoreCurrentSituation, "Challenge", "ChallengeScoreCurrentSituation");
                ckSelected(chkChallenge, scoreJudge.ChallengeScoreSpecificProblem, "Challenge", "ChallengeScoreSpecificProblem");
                ckSelected(chkChallenge, scoreJudge.ChallengeScoreDimension, "Challenge", "ChallengeScoreDimension");
                ckSelected(chkChallenge, scoreJudge.ChallengeScoreBeneficiaries, "Challenge", "ChallengeScoreBeneficiaries");
                ckSelected(chkChallenge, scoreJudge.ChallengeScoreCause, "Challenge", "ChallengeScoreCause");
                ckSelected(chkAproach, scoreJudge.InnovationScoreInnovation, "Innovation", "InnovationScoreInnovation");
                ckSelected(chkAproach, scoreJudge.InnovationScoreMethodology, "Innovation", "InnovationScoreMethodology");
                ckSelected(chkAproach, scoreJudge.InnovationScoreChallenge, "Innovation", "InnovationScoreChallenge");
                ckSelected(chkAproach, scoreJudge.InnovationScoreRealizable, "Innovation", "InnovationScoreRealizable");
                ckSelected(chkAproach, scoreJudge.InnovationScoreReplicable, "Innovation", "InnovationScoreReplicable");
                ckSelected(chkResults, scoreJudge.ResultScoreMarketingDescription, "Result", "ResultScoreMarketingDescription");
                ckSelected(chkResults, scoreJudge.ResultScoreAdopter, "Result", "ResultScoreAdopter");
                ckSelected(chkResults, scoreJudge.ResultScoreEvidence, "Result", "ResultScoreEvidence");
                ckSelected(chkResults, scoreJudge.ResultScoreReplication, "Result", "ResultScoreReplication");
                ckSelected(chkResults, scoreJudge.ResultScoreBeneficiary, "Result", "ResultScoreBeneficiary");
                rdbYesNoSelected(rbdCostDetails, scoreJudge.ImplementationCostScore);
                rdbYesNoSelected(rbdDurationDetails, scoreJudge.ImplementationTimeScore);
                if (!string.IsNullOrEmpty(solutionComponent.Solution.Description))
                {
                    rdbYesNoSelected(rdbDescription, scoreJudge.AdditionalInformationScore);
                }
                rdbYesNoSelected(rdbDuration, scoreJudge.TimeScore);
                rdbYesNoSelected(rdbCost, scoreJudge.CostScore);
            }
            if (commentReference == solutionComponent.Solution.ChallengeReference)
            {
                box.Visible = false;
                lblTitleFeedback.Visible = lblFeedBackEn.Visible = lblFeedBackEs.Visible = txtFeedBack.Visible = true;
                validatorFeedBack.Enabled = true;
            }
            else
            {
                box.Visible = true;
                lblTitleFeedback.Visible = lblFeedBackEn.Visible = lblFeedBackEs.Visible = txtFeedBack.Visible = false;
                validatorFeedBack.Enabled = false;
            }
            Comments.Visible = true;
            ScoreComponent scoreComponentXML = new ScoreComponent(solutionId, UserController.GetCurrentUserInfo().UserID, "CUSTOM_XML", solutionComponent.Solution.ChallengeReference);
            ScoreValue scoreValue = scoreComponentXML.Score.ScoreValues.FirstOrDefault(a => a.ScoreValueType == scoreComponentXML.Score.ScoreType);
            if (scoreValue != null)
                XmlToControls(scoreValue.MetaData);
        }
    }

    /// <summary>
    /// Displays the selected value is radio button list
    /// </summary>
    /// <param name="radioButtonList"></param>
    /// <param name="value"></param>s
    public void rdbSelected(RadioButtonList radioButtonList, double value, string name)
    {
        foreach (ListItem item in radioButtonList.Items)
        {
            if (value == 0.0)
            {
                if (item.Value == "Score" + name + "1")
                {
                    item.Selected = true;
                    break;
                }
            }
            if (value == 1.0)
            {
                if (item.Value == "Score" + name + "2")
                {
                    item.Selected = true;
                    break;
                }
            }
            if (value == 3.0)
            {
                if (item.Value == "Score" + name + "3")
                {
                    item.Selected = true;
                    break;
                }
            }
            if (value == 4.0)
            {
                if (item.Value == "Score" + name + "4")
                {
                    item.Selected = true;
                    break;
                }
            }
            if (value == 5.0)
            {
                if (item.Value == "Score" + name + "5")
                {
                    item.Selected = true;
                    break;
                }
            }
        }
    }


    /// <summary>
    /// Displays the selected value in checkbox list
    /// </summary>
    /// <param name="checkBoxList"></param>
    /// <param name="value"></param>
    /// <param name="name"></param>
    /// <param name="nameScore"></param>
    public void ckSelected(CheckBoxList checkBoxList, double value, string name, string nameScore)
    {
        if (value == 1.0)
        {
            foreach (ListItem item in checkBoxList.Items)
            {
                if (nameScore == "InnovationScoreInnovation" || nameScore == "ResultScoreMarketingDescription" || nameScore == "ChallengeScoreCurrentSituation")
                {
                    if (item.Value == "Score" + name + "1")
                    {
                        item.Selected = true;
                        break;
                    }
                }
                if (nameScore == "InnovationScoreMethodology" || nameScore == "ResultScoreAdopter" || nameScore == "ChallengeScoreSpecificProblem")
                {
                    if (item.Value == "Score" + name + "2")
                    {
                        item.Selected = true;
                        break;
                    }
                }
                if (nameScore == "InnovationScoreChallenge" || nameScore == "ResultScoreEvidence" || nameScore == "ChallengeScoreDimension")
                {
                    if (item.Value == "Score" + name + "3")
                    {
                        item.Selected = true;
                        break;
                    }
                }
                if (nameScore == "InnovationScoreRealizable" || nameScore == "ResultScoreReplication" || nameScore == "ChallengeScoreBeneficiaries")
                {
                    if (item.Value == "Score" + name + "4")
                    {
                        item.Selected = true;
                        break;
                    }
                }
                if (nameScore == "InnovationScoreReplicable" || nameScore == "ResultScoreBeneficiary" || nameScore == "ChallengeScoreCause")
                {
                    if (item.Value == "Score" + name + "5")
                    {
                        item.Selected = true;
                        break;
                    }
                }
            }
        }
    }

    /// <summary>
    /// Displays the selected value is radio button list
    /// </summary>
    /// <param name="radioButtonList"></param>
    /// <param name="value"></param>
    public void rdbYesNoSelected(RadioButtonList radioButtonList, double value)
    {
        foreach (ListItem item in radioButtonList.Items)
        {
            if (value == 1.0)
            {
                if (item.Value == "ScoreYes")
                {
                    item.Selected = true;
                    break;
                }
            }
            if (value == 0.0)
            {
                if (item.Value == "ScoreNot")
                {
                    item.Selected = true;
                    break;
                }
            }
        }
    }

    /// <summary>
    /// Change estate of the solution. Tne new state is 0
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnUnpublish_Click(object sender, EventArgs e)
    {
        solutionComponent.Solution.SolutionState = 0;
        if (solutionComponent.Save() > 0)
        {
            Response.Redirect(NexsoHelper.GetCulturedUrlByTabName("submit your solution") + "/sl/" + solutionComponent.Solution.SolutionId);
        }
        else
        {
            Exceptions.ProcessModuleLoadException(this, new Exception("error database"));
        }
    }

    /// <summary>
    /// send an email reporting that the solution is a spam
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReportSpam_Click(object sender, EventArgs e)
    {
        DotNetNuke.Services.Mail.Mail.SendEmail("nexso@iadb.org", "jairoa@iadb.org,YVESL@iadb.org,MONICAO@iadb.org", "Spam Report", string.Format(Localization.GetString("ReportSpamTemplate", LocalResourceFile), solutionId, UserController.GetCurrentUserInfo().UserID.ToString()));
        Page.ClientScript.RegisterStartupScript(this.GetType(), "PopUpReportSpam", "PopUpReportSpam();", true);
        btnReportSpam.Text = Localization.GetString("SolutionReported", LocalResourceFile);
        btnReportSpam.Enabled = false;
    }


    /// <summary>
    /// Calculate the total score depending on selected values
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnScore_Click(object sender, EventArgs e)
    {
        try
        {
            int hh = 0;
            int h = 0;
            if (!challengeReferences.Contains(solutionComponent.Solution.ChallengeReference))
            {
                ListComponent listComponent = new ListComponent(rdbTagLine.SelectedValue, "ScoreUniqueSelectorTagLine0-5");//edited by economia naranja
                scoreJudge.TagLineScore = Convert.ToSingle(listComponent.ListItem.Value);
                scoreJudge.ChallengeScoreBeneficiaries = 0;
                scoreJudge.ChallengeScoreCause = 0;
                scoreJudge.ChallengeScoreCurrentSituation = 0;
                scoreJudge.ChallengeScoreDimension = 0;
                scoreJudge.ChallengeScoreSpecificProblem = 0;
                foreach (ListItem item in chkChallenge.Items)
                {
                    if (item.Selected)
                    {
                        switch (item.Value)
                        {
                            case "ScoreChallenge1":
                                scoreJudge.ChallengeScoreCurrentSituation = 1.0;
                                break;

                            case "ScoreChallenge2":
                                scoreJudge.ChallengeScoreSpecificProblem = 1.0;
                                break;

                            case "ScoreChallenge3":
                                scoreJudge.ChallengeScoreCause = 1.0;
                                break;

                            case "ScoreChallenge4":
                                scoreJudge.ChallengeScoreDimension = 1.0;
                                break;

                            case "ScoreChallenge5":
                                scoreJudge.ChallengeScoreBeneficiaries = 1.0;
                                break;
                        }

                    }
                }
                scoreJudge.InnovationScoreRealizable = 0;
                scoreJudge.InnovationScoreChallenge = 0;
                scoreJudge.InnovationScoreInnovation = 0;
                scoreJudge.InnovationScoreMethodology = 0;
                scoreJudge.InnovationScoreReplicable = 0;
                foreach (ListItem item in chkAproach.Items)
                {
                    if (item.Selected)
                    {
                        switch (item.Value)
                        {
                            case "ScoreInnovation1":
                                scoreJudge.InnovationScoreInnovation = 1.0;
                                break;

                            case "ScoreInnovation2":
                                scoreJudge.InnovationScoreMethodology = 1.0;
                                break;

                            case "ScoreInnovation3":
                                scoreJudge.InnovationScoreChallenge = 1.0;
                                break;

                            case "ScoreInnovation4":
                                scoreJudge.InnovationScoreRealizable = 1.0;
                                break;

                            case "ScoreInnovation5":
                                scoreJudge.InnovationScoreReplicable = 1.0;

                                break;
                        }
                    }
                }
                scoreJudge.ResultScoreAdopter = 0;
                scoreJudge.ResultScoreBeneficiary = 0;
                scoreJudge.ResultScoreEvidence = 0;
                scoreJudge.ResultScoreMarketingDescription = 0;
                scoreJudge.ResultScoreReplication = 0;
                foreach (ListItem item in chkResults.Items)
                {
                    if (item.Selected)
                    {
                        switch (item.Value)
                        {
                            case "ScoreResult1":
                                scoreJudge.ResultScoreMarketingDescription = 1.0;
                                break;

                            case "ScoreResult2":
                                scoreJudge.ResultScoreAdopter = 1.0;
                                break;

                            case "ScoreResult3":
                                scoreJudge.ResultScoreEvidence = 1.0;
                                break;

                            case "ScoreResult4":
                                scoreJudge.ResultScoreReplication = 1.0;
                                break;

                            case "ScoreResult5":
                                scoreJudge.ResultScoreBeneficiary = 1.0;
                                break;
                        }
                    }
                }
                listComponent = new ListComponent(rbdCostDetails.SelectedValue, "ScoreYesNot");
                scoreJudge.ImplementationCostScore = Convert.ToSingle(listComponent.ListItem.Value);
                listComponent = new ListComponent(rbdDurationDetails.SelectedValue, "ScoreYesNot");
                scoreJudge.ImplementationTimeScore = Convert.ToSingle(listComponent.ListItem.Value);
                listComponent = new ListComponent(rdbImplemenationDetails.SelectedValue, "ScoreUniqueSelectorImplementation");
                scoreJudge.ImplementationScore = Convert.ToSingle(listComponent.ListItem.Value);
                if (!string.IsNullOrEmpty(solutionComponent.Solution.Description))
                {
                    listComponent = new ListComponent(rdbDescription.SelectedValue, "ScoreYesNot");
                    scoreJudge.AdditionalInformationScore = Convert.ToSingle(listComponent.ListItem.Value);
                }
                listComponent = new ListComponent(rdbDuration.SelectedValue, "ScoreYesNot");
                scoreJudge.TimeScore = Convert.ToSingle(listComponent.ListItem.Value);
                listComponent = new ListComponent(rdbCost.SelectedValue, "ScoreYesNot");
                scoreJudge.CostScore = Convert.ToSingle(listComponent.ListItem.Value);
                h = solutionComponent.Save();
                h = scoreJudge.save(solutionComponent.Solution.ChallengeReference);
            }
            ChallengeCustomDataComponent challengeCustomDataComponent = new ChallengeCustomDataComponent(solutionComponent.Solution.ChallengeReference, Language);
            if (challengeCustomDataComponent != null)
            {
                if (!string.IsNullOrEmpty(challengeCustomDataComponent.ChallengeCustomData.Scoring))
                {
                    ScoreComponent scoreComponentXML = new ScoreComponent(solutionId, UserController.GetCurrentUserInfo().UserID, "CUSTOM_XML", solutionComponent.Solution.ChallengeReference);
                    if (scoreComponentXML.Score.ScoreId == Guid.Empty)
                    {
                        scoreComponentXML.Score.Created = DateTime.Now;
                        scoreComponentXML.Score.Updated = scoreComponentXML.Score.Created;
                        scoreComponentXML.Score.ChallengeReference = solutionComponent.Solution.ChallengeReference;
                        scoreComponentXML.Score.Active = true;
                    }
                    else
                    {
                        scoreComponentXML.Score.Updated = DateTime.Now;
                    }
                    scoreComponentXML.Score.ComputedValue = GetComputedValueXML();
                    ScoreValue score = scoreComponentXML.Score.ScoreValues.FirstOrDefault(a => a.ScoreValueType == scoreComponentXML.Score.ScoreType && a.Score.Active == true);
                    if (score == null)
                    {
                        score = new ScoreValue()
                        {
                            ScoreValueId = Guid.NewGuid(),
                            value = Convert.ToDouble(scoreComponentXML.Score.ComputedValue),
                            ScoreValueType = scoreComponentXML.Score.ScoreType,
                            Created = scoreComponentXML.Score.Created,
                            Updated = scoreComponentXML.Score.Created,
                            MetaData = ControlsToXmlData("").ToString(),
                            ScoreId = scoreComponentXML.Score.ScoreId
                        };
                        scoreComponentXML.Score.ScoreValues.Add(score);
                    }
                    else
                    {
                        score.Updated = scoreComponentXML.Score.Updated;
                        score.MetaData = ControlsToXmlData("").ToString();
                        score.value = Convert.ToDouble(scoreComponentXML.Score.ComputedValue);
                    }
                    hh = scoreComponentXML.Save(Guid.NewGuid());
                    lblAdditionalScoreGlobal.Text = " <b>" + Localization.GetString("FinalAdditionalScoreGlobal", this.LocalResourceFile) + " " + Math.Round(ScoreComponent.ScoreJudge.GetGlobalAdditionalJudgeScore(solutionId, solutionComponent.Solution.ChallengeReference), 1) + "</b>";
                }
                else
                {
                    lblAdditionalScoreGlobal.Visible = false;
                }
            }
            else
            {
                lblAdditionalScoreGlobal.Visible = false;
            }
            lblScoreGlobal.Text = " <b>" + Localization.GetString("FinalScoreGlobal", this.LocalResourceFile) + " " + Math.Round(scoreJudge.AbsoluteScore, 1) + "</b>";
            Comments.Visible = true;
            if (commentReference == solutionComponent.Solution.ChallengeReference)
            {
                box.Visible = false;
                lblTitleFeedback.Visible = lblFeedBackEn.Visible = lblFeedBackEs.Visible = txtFeedBack.Visible = true;
                validatorFeedBack.Enabled = true;
            }
            else
            {
                box.Visible = true;
                lblTitleFeedback.Visible = lblFeedBackEn.Visible = lblFeedBackEs.Visible = txtFeedBack.Visible = false;
                validatorFeedBack.Enabled = false;
            }
            saveComments(solutionComponent);
            if (h == -1 || hh == -1)
                Page.ClientScript.RegisterStartupScript(this.GetType(), "CallMyFunction", "ErrorScore();", true);
            else
            {
                Page.ClientScript.RegisterStartupScript(this.GetType(), "CallMyFunction", "Finish();", true);
                BindData();
            }
        }
        catch
        {
            Page.ClientScript.RegisterStartupScript(this.GetType(), "CallMyFunction", "ErrorScore();", true);
        }
    }

    /// <summary>
    /// Save new comment in database
    /// </summary>
    /// <param name="solution"></param>
    public void saveComments(SolutionComponent solution)
    {
        try
        {
            var portal = PortalController.GetCurrentPortalSettings();
            var currentUser = UserController.GetCurrentUserInfo();
            bool exist = false;
            if (currentUser.IsInRole("Registered Users"))
            {
                ResourceManager Localization = new ResourceManager("NexsoServices.App_LocalResources.Resource",
                              System.Reflection.Assembly.GetExecutingAssembly());

                if (!string.IsNullOrEmpty(txtFeedBack.Text) && currentUser.UserID > 0)
                {
                    string guid = solution.Solution.SolutionId.ToString();
                    List<SolutionComment> listSolutionComments = SolutionCommentComponent.GetCommentsPerSolution(new Guid(guid), "JUDGE").OrderByDescending(p => p.CreatedDate).ToList();
                    foreach (SolutionComment solutionComment in listSolutionComments)
                    {
                        if (txtFeedBack.Text == solutionComment.Comment)
                        {
                            exist = true;
                        }
                    }

                    if (!exist)
                    {
                        SolutionCommentComponent solutionCommentComponent = new SolutionCommentComponent(Guid.Empty);
                        solutionCommentComponent.SolutionComment.Comment = txtFeedBack.Text;
                        solutionCommentComponent.SolutionComment.CreatedDate = DateTime.Now;
                        solutionCommentComponent.SolutionComment.Publish = true;
                        solutionCommentComponent.SolutionComment.Scope = "JUDGE";
                        solutionCommentComponent.SolutionComment.SolutionId = solution.Solution.SolutionId;
                        solutionCommentComponent.SolutionComment.UserId = currentUser.UserID;

                        if (solutionCommentComponent.Save() > 0)
                        {
                            // Notification
                            var currentUser2 = UserController.GetUserById(portal.PortalId,
                                Convert.ToInt32(solution.Solution.CreatedUserId));
                            var userCurrent = new UserPropertyComponent(currentUser.UserID);
                            if (currentUser.UserID != Convert.ToInt32(solution.Solution.CreatedUserId))
                            {
                                NotificationComponent notificationComponent = new NotificationComponent(Guid.Empty);
                                notificationComponent.Notification.Code = "MESSAGE";
                                notificationComponent.Notification.Created = DateTime.Now;
                                notificationComponent.Notification.UserId = currentUser.UserID;
                                notificationComponent.Notification.Message = "MESSAGE";
                                notificationComponent.Notification.ToolTip = "MESSAGE";
                                notificationComponent.Notification.Link =
                                    NexsoHelper.GetCulturedUrlByTabName("solprofile", 0,
                                        GetUserLanguage(Convert.ToInt32(userCurrent.UserProperty.Language))) +
                                    "/sl/" + solutionCommentComponent.SolutionComment.Solution.SolutionId.ToString();
                                notificationComponent.Notification.Tag = string.Empty;
                                notificationComponent.Save();
                                UserNotificationConnectionComponent userNotificationConnectionComponent =
                                    new UserNotificationConnectionComponent(Guid.Empty);
                                userNotificationConnectionComponent.UserNotificationConnection.NotificationId =
                                    notificationComponent.Notification.NotificationId;
                                userNotificationConnectionComponent.UserNotificationConnection.UserId =
                                    Convert.ToInt32(solution.Solution.CreatedUserId);
                                userNotificationConnectionComponent.UserNotificationConnection.Tag = string.Empty;
                                userNotificationConnectionComponent.UserNotificationConnection.Rol = string.Empty;
                                userNotificationConnectionComponent.Save();
                            }
                            //end Notification

                            List<int> userIds = new List<int>();

                            foreach (
                                SolutionComment solutionComment in
                                    solutionCommentComponent.SolutionComment.Solution.SolutionComments)
                            {
                                if (!userIds.Contains(solutionComment.UserId.GetValueOrDefault(-1)))
                                    userIds.Add(solutionComment.UserId.GetValueOrDefault(-1));
                            }
                            if (solutionCommentComponent.SolutionComment.Solution.CreatedUserId.GetValueOrDefault(-1) != -1)
                                userIds.Add(
                                    solutionCommentComponent.SolutionComment.Solution.CreatedUserId.GetValueOrDefault(-1));

                            foreach (int userids in userIds)
                            {

                                UserInfo user = UserController.GetUserById(portal.PortalId, userids);
                                UserPropertyComponent property = new UserPropertyComponent(userids);
                                if (currentUser.UserID != user.UserID)
                                {
                                    CultureInfo language =
                                        new CultureInfo(GetUserLanguage(property.UserProperty.Language.GetValueOrDefault(1)));
                                    DotNetNuke.Services.Mail.Mail.SendEmail("nexso@iadb.org",
                                        user.Email,
                                        string.Format(
                                            Localization.GetString("MessageTitleComment", language),
                                            currentUser.FirstName + " " + currentUser.LastName,
                                            solutionCommentComponent.SolutionComment.Solution.Title),
                                        Localization.GetString("MessageBodyComment", language).Replace(
                                            "{COMMENT:Body}", solutionCommentComponent.SolutionComment.Comment).Replace(
                                                "{SOLUTION:Title}", solutionCommentComponent.SolutionComment.Solution.Title)
                                            .Replace(
                                                "{SOLUTION:PageLink}",
                                                NexsoHelper.GetCulturedUrlByTabName("solprofile", 0, language.Name) +
                                                "/sl/" +
                                                solutionCommentComponent.SolutionComment.Solution.SolutionId.ToString())
                                        );
                                }
                            }
                            CultureInfo langua = new CultureInfo("en-US");
                            DotNetNuke.Services.Mail.Mail.SendEmail("nexso@iadb.org",
                                "jairoa@iadb.org,YVESL@iadb.org,wrightgas@gmail.com,patriciab@nexso.org,nexso@iadb.org,MONICAO@iadb.org",
                                "NOTIFICATION: " +
                                string.Format(
                                    Localization.GetString("MessageTitleComment", langua),
                                    currentUser.FirstName + " " + currentUser.LastName,
                                    solutionCommentComponent.SolutionComment
                                        .Solution.Title),
                                Localization.GetString("MessageBodyComment", langua).Replace(
                                    "{COMMENT:Body}", solutionCommentComponent.SolutionComment.Comment).Replace(
                                        "{SOLUTION:Title}", solutionCommentComponent.SolutionComment.Solution.Title)
                                    .Replace(
                                        "{SOLUTION:PageLink}",
                                        NexsoHelper.GetCulturedUrlByTabName("solprofile", 0, langua.Name) +
                                        "/sl/" + solutionCommentComponent.SolutionComment.Solution.SolutionId.ToString())
                                );
                        }
                    }
                }
            }
        }
        catch
        {
        }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="lang"></param>
    /// <returns>Language of the current user</returns>
    private string GetUserLanguage(int lang)
    {
        switch (lang)
        {
            case 1:
                return "en-US";
            case 2:
                return "es-ES";
            case 3:
                return "pt-BR";
            default:
                return "en-US";
        }
    }

    /// <summary>
    /// Load XML score per JUDGE
    /// </summary>
    public void FillDataJudges()
    {
        SolutionComponent solution = new SolutionComponent(solutionId);
        var scoresSolution = solution.Solution.Scores.Where(a => a.ScoreType != "CUSTOM_XML" && a.Active == true);
        if (challengeReferences.Contains(solution.Solution.ChallengeReference))
        {
            scoresSolution = solution.Solution.Scores.Where(a => a.ScoreType == "CUSTOM_XML" && a.Active == true && (challengeReferences.Contains(a.ChallengeReference)));
        }
        List<UserScore> userPropertyList = new List<UserScore>();
        UserPropertyComponent userPropertyComponent;
        var challenge = GetChallenge();
        ScoreComponent.ScoreJudge scoreJudge;
        foreach (var score in scoresSolution)
        {
            if (score.UserId == UserController.GetCurrentUserInfo().UserID || UserController.GetCurrentUserInfo().IsInRole("Administrators") || UserController.GetCurrentUserInfo().IsInRole("NexsoSupport") || challengeJudgeComponent.ChallengeJudge.PermisionLevel == "JUDGE-ADMIN")
            {
                if (challenge == score.ChallengeReference || challenge == string.Empty)
                {
                    ScoreComponent scoreComponent = new ScoreComponent(solutionId, score.UserId, "CUSTOM_XML", score.ChallengeReference);
                    if (scoreComponent.Score.ScoreId != Guid.Empty)
                    {
                        if (challenge == string.Empty)
                        {
                            scoreJudge = new ScoreComponent.ScoreJudge(solutionId, score.UserId);
                        }
                        else
                        {
                            scoreJudge = new ScoreComponent.ScoreJudge(solutionId, score.UserId, challenge);
                        }
                        userPropertyComponent = new UserPropertyComponent(score.UserId);
                        var totalScore = Math.Round(((scoreJudge.AbsoluteScore * 0.6) + (Convert.ToDouble(scoreComponent.Score.ComputedValue) * 0.4)), 1);
                        if (challengeReferences.Contains(solution.Solution.ChallengeReference))
                        {
                            totalScore = Math.Round((Convert.ToDouble(scoreComponent.Score.ComputedValue)), 1);
                        }
                        userPropertyList.Add(new UserScore()
                        {
                            FirstName = userPropertyComponent.UserProperty.FirstName,
                            LastName = userPropertyComponent.UserProperty.LastName,
                            ScoreValue = scoreJudge.AbsoluteScore,
                            userId = userPropertyComponent.UserProperty.UserId,
                            CustomScore = Convert.ToDouble(scoreComponent.Score.ComputedValue),
                            TotalScore = totalScore
                        });
                    }
                    else
                    {
                        if (challenge == string.Empty)
                        {
                            scoreJudge = new ScoreComponent.ScoreJudge(solutionId, score.UserId);
                        }
                        else
                        {
                            scoreJudge = new ScoreComponent.ScoreJudge(solutionId, score.UserId, challenge);
                        }
                        userPropertyComponent = new UserPropertyComponent(score.UserId);
                        userPropertyList.Add(new UserScore()
                        {
                            FirstName = userPropertyComponent.UserProperty.FirstName,
                            LastName = userPropertyComponent.UserProperty.LastName,
                            ScoreValue = scoreJudge.AbsoluteScore,
                            userId = userPropertyComponent.UserProperty.UserId
                        });
                    }
                }
            }
        }
        if (userPropertyList.Count == 0)
            lblListJudges.Visible = false;
        else
            lblListJudges.Visible = true;
        gvListJudges.DataSource = userPropertyList;
        gvListJudges.DataBind();

    }

    /// <summary>
    /// 
    /// </summary>
    /// <returns>Return challenge reference</returns>
    public string GetChallenge()
    {
        SolutionComponent solution = new SolutionComponent(solutionId);
        var scoresSolution = solution.Solution.Scores;
        var challenge = string.Empty;
        if (scoresSolution.Count() > 0)
        {
            bool sw = false;
            if (solutionComponent.Solution.ChallengeReference == null)
            {
                sw = true;
            }
            else
            {
                if (solutionComponent.Solution.ChallengeReference == "NEXSODEFAULT")
                {
                    var challengeExist = solutionComponent.Solution.Scores.Where(x => x.ChallengeReference == solutionComponent.Solution.ChallengeReference);
                    if (challengeExist.Count() > 0)
                    {
                        challenge = solutionComponent.Solution.ChallengeReference;
                    }
                    else
                    {
                        sw = true;
                        challenge = string.Empty;
                    }
                }
                else
                {
                    challenge = solutionComponent.Solution.ChallengeReference;
                }
            }
            if (sw)
            {
                var list = CustomDataLogComponent.GetCustomDataLogs(solutionId);
                if (list.Count() > 0)
                {
                    var challenge2 = new ChallengeCustomDataComponent(list.First().CustomaDataSchema);
                    if (challenge2 != null)
                    {
                        challenge = challenge2.ChallengeCustomData.ChallengeReference;
                    }
                }
            }
        }
        return challenge;
    }

    protected class UserScore
    {
        public string LastName { get; set; }
        public string FirstName { get; set; }
        public double ScoreValue { get; set; }
        public DateTime ScoredDate { get; set; }
        public int userId { get; set; }
        public double CustomScore { get; set; }
        public double TotalScore { get; set; }
    }

    public class OtherInformation
    {
        public string Key { get; set; }
        public string Label { get; set; }
        public List<string> List { get; set; }
    }

    #region Score XML

    /// <summary>
    /// Calculate the total value of the selected values in the XML
    /// </summary>
    /// <returns></returns>
    private double GetComputedValueXML()
    {
        double computedValue = 0;
        int count = 0;
        listControls = (List<Generic>)ViewState["listControls"];
        if (listControls != null)
        {
            foreach (var item in listControls)
            {
                if (!challengeReferences.Contains(solutionComponent.Solution.ChallengeReference))
                {
                    switch (item.Value)
                    {
                        case "RADIOBUTTONLIST":
                            {
                                if (dvOtherInformationPanelScore.FindControl(item.Id) != null)
                                {
                                    RadioButtonList rb = (RadioButtonList)dvOtherInformationPanelScore.FindControl(item.Id);
                                    string value = Request.Form[rb.UniqueID] == null ? rb.SelectedValue : Request.Form[rb.UniqueID];
                                    if (value != string.Empty)
                                    {
                                        computedValue = computedValue + Convert.ToDouble(value) * Convert.ToDouble(item.Score);
                                    }
                                    count++;
                                }
                                break;
                            }

                        case "CHECKBOXLIST":
                            {
                                if (dvOtherInformationPanelScore.FindControl(item.Id) != null)
                                {
                                    double ItemValues = 0;
                                    int countSelected = 0;
                                    CheckBoxList cb = (CheckBoxList)dvOtherInformationPanelScore.FindControl(item.Id);
                                    foreach (ListItem itemL in cb.Items)
                                    {
                                        if (itemL.Selected)
                                        {
                                            ItemValues = ItemValues + Convert.ToDouble(itemL.Value);
                                            countSelected++;
                                        }
                                    }
                                    if (countSelected > 0)
                                    {
                                        computedValue = computedValue + Convert.ToDouble(ItemValues) * Convert.ToDouble(item.Score);
                                    }
                                    count++;
                                }
                                break;
                            }
                    }
                }
                else
                {
                    switch (item.Value)
                    {
                        case "RADIOBUTTONLIST":
                            {
                                if (dvOtherInformationPanelScore.FindControl(item.Id) != null)
                                {
                                    RadioButtonList rb = (RadioButtonList)dvOtherInformationPanelScore.FindControl(item.Id);
                                    string value = Request.Form[rb.UniqueID] == null ? rb.SelectedValue : Request.Form[rb.UniqueID];
                                    if (value != string.Empty)
                                    {
                                        if (!string.IsNullOrEmpty(item.ControlValidateId))
                                        {
                                            RadioButtonList rbAux = (RadioButtonList)dvOtherInformationPanelScore.FindControl(item.ControlValidateId);
                                            string value2 = Request.Form[rbAux.UniqueID] == null ? rbAux.SelectedValue : Request.Form[rbAux.UniqueID];
                                            if (value2 != string.Empty)
                                            {
                                                var val = Convert.ToDouble(value2, CultureInfo.InvariantCulture) * Convert.ToDouble(value, CultureInfo.InvariantCulture);
                                                computedValue = computedValue + ((Convert.ToDouble(val, CultureInfo.InvariantCulture) * Convert.ToDouble(item.Score, CultureInfo.InvariantCulture)) / Convert.ToDouble(item.MaxValue, CultureInfo.InvariantCulture));
                                            }
                                            else
                                            {
                                                computedValue = computedValue + ((Convert.ToDouble(value, CultureInfo.InvariantCulture) * Convert.ToDouble(item.Score, CultureInfo.InvariantCulture)) / Convert.ToDouble(item.MaxValue, CultureInfo.InvariantCulture));
                                            }
                                        }
                                        else
                                        {
                                            computedValue = computedValue + ((Convert.ToDouble(value, CultureInfo.InvariantCulture) * Convert.ToDouble(item.Score, CultureInfo.InvariantCulture)) / Convert.ToDouble(item.MaxValue, CultureInfo.InvariantCulture));
                                        }
                                    }
                                    count++;
                                }
                                break;
                            }
                    }

                }

            }
        }
        if (!challengeReferences.Contains(solutionComponent.Solution.ChallengeReference))
        {
            if (count > 0 && computedValue > 0)
            {
                computedValue = computedValue / count;
            }
        }
        else
        {
            computedValue = computedValue * 100;
        }
        if (computedValue > 100)
        {
            return Math.Round(computedValue);
        }
        else
        {
            return Math.Round(computedValue, 1);
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
                                if (dvOtherInformationPanelScore.FindControl(item.Id) != null)
                                {
                                    DropDownList dd = (DropDownList)dvOtherInformationPanelScore.FindControl(item.Id);
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
                                if (dvOtherInformationPanelScore.FindControl(item.Id) != null)
                                {
                                    TextBox txt = (TextBox)dvOtherInformationPanelScore.FindControl(item.Id);
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
                                if (dvOtherInformationPanelScore.FindControl(item.Id) != null)
                                {
                                    RadioButtonList rb = (RadioButtonList)dvOtherInformationPanelScore.FindControl(item.Id);
                                    writer.WriteString(Request.Form[rb.UniqueID] == null ? rb.SelectedValue : Request.Form[rb.UniqueID]);
                                }
                                writer.WriteEndElement();
                                writer.WriteStartElement("TYPE");
                                writer.WriteString("Int");
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
                                if (dvOtherInformationPanelScore.FindControl(item.Id) != null)
                                {
                                    int countSelected = 0;
                                    CheckBoxList cb = (CheckBoxList)dvOtherInformationPanelScore.FindControl(item.Id);
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
                                writer.WriteString("Int");
                                writer.WriteEndElement();
                                writer.WriteStartElement("CONTROLTYPE");
                                writer.WriteString("CheckBox");
                                writer.WriteEndElement();
                                writer.WriteEndElement();
                                break;
                            }
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
    /// Convert XML to asp.net controls
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
                                        DropDownList ddTmp = (DropDownList)dvOtherInformationPanelScore.FindControl("ddCustom" + KEY);
                                        if (ddTmp != null)
                                            swDdTmp = true;
                                        else
                                        {
                                            ddTmp = (DropDownList)dvOtherInformationPanelScore.FindControl(KEY);
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
                                        TextBox txtTmp = (TextBox)dvOtherInformationPanelScore.FindControl("txtCustom" + KEY);
                                        if (txtTmp != null)
                                            swTxtTmp = true;
                                        else
                                        {
                                            txtTmp = (TextBox)dvOtherInformationPanelScore.FindControl(KEY);
                                            if (txtTmp != null)
                                                swTxtTmp = true;
                                        }
                                        if (swTxtTmp)
                                        {
                                            foreach (var item in LSTVALUES)
                                            {
                                                txtTmp.Text = item;
                                            }
                                        }
                                        break;
                                    }

                                case "RadioButton":
                                    {
                                        bool swBb = false;
                                        RadioButtonList rb = (RadioButtonList)dvOtherInformationPanelScore.FindControl("rbCustom" + KEY);
                                        if (rb != null)
                                            swBb = true;
                                        else
                                        {
                                            rb = (RadioButtonList)dvOtherInformationPanelScore.FindControl(KEY);
                                            if (rb != null)
                                                swBb = true;
                                        }
                                        if (swBb)
                                        {
                                            ListItem item;
                                            foreach (var itemL in LSTVALUES)
                                            {
                                                item = rb.Items.FindByValue(itemL);
                                                if (item != null)
                                                    rb.SelectedValue = itemL;
                                            }
                                        }
                                        break;
                                    }

                                case "CheckBox":
                                    {
                                        bool swCb = false;
                                        CheckBoxList cb = (CheckBoxList)dvOtherInformationPanelScore.FindControl("cbCustom" + KEY);
                                        if (cb != null)
                                            swCb = true;
                                        else
                                        {
                                            cb = (CheckBoxList)dvOtherInformationPanelScore.FindControl(KEY);
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
                            }
                        }
                    }
                }
                catch
                {

                }
            }
        }
    }


    /// <summary>
    /// Convert XML to asp.net controls
    /// </summary>
    /// <param name="xmlData"></param>
    private void XMLCreateControls(string xmlData)
    {
        if (!string.IsNullOrEmpty(xmlData))
        {
            gvListJudges.Columns[3].Visible = true;
            gvListJudges.Columns[4].Visible = true;
            gvListJudges.Columns[2].HeaderText = Localization.GetString("GridScore2", LocalResourceFile);
            if (challengeReferences.Contains(solutionComponent.Solution.ChallengeReference))
            {
                gvListJudges.Columns[2].Visible = false;
                gvListJudges.Columns[4].Visible = false;
            }
            ViewState["listControls"] = string.Empty;
            var errorString = string.Empty;
            byte[] byteArray = new byte[xmlData.Length];
            System.Text.Encoding encoding = System.Text.Encoding.Unicode;
            byteArray = encoding.GetBytes(xmlData);
            MemoryStream memoryStream = new MemoryStream(byteArray);
            memoryStream.Seek(0, SeekOrigin.Begin);
            string ID, TYPE, LABEL, REQUIRED, LABEL2, ATTRIBUTE, VALUESCORE;
            if (byteArray.Length > 0)
            {
                try
                {
                    var reader = XmlReader.Create(memoryStream);
                    reader.MoveToContent();
                    while (reader.Read())
                    {
                        ID = TYPE = LABEL = REQUIRED = LABEL2 = ATTRIBUTE = VALUESCORE = string.Empty;
                        if (reader.NodeType == XmlNodeType.Element && reader.Name == "SCORE")
                        {
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element && reader.Name == "LABEL")
                                {
                                    LABEL = reader.ReadString();
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
                                                    ATTRIBUTES.Add(new Generic() { Id = "RepeatDirection", Value = reader.GetAttribute("RepeatDirection") });
                                                    TYPE = reader.ReadString();
                                                    break;
                                                }
                                            }
                                            while (reader.Read())
                                            {
                                                if (reader.NodeType == XmlNodeType.Element && reader.Name == "LABEL")
                                                {
                                                    LABEL2 = reader.ReadString();
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
                                                if (reader.NodeType == XmlNodeType.Element && reader.Name == "REQUIRED")
                                                {
                                                    ATTRIBUTES.Add(new Generic() { Id = "Class", Value = reader.GetAttribute("Class") });
                                                    ATTRIBUTES.Add(new Generic() { Id = "ValidationGroup", Value = reader.GetAttribute("ValidationGroup") });
                                                    REQUIRED = reader.ReadString();
                                                    break;
                                                }
                                            }
                                            while (reader.Read())
                                            {
                                                if (reader.NodeType == XmlNodeType.Element && reader.Name == "VALUESCORE")
                                                {
                                                    ATTRIBUTES.Add(new Generic() { Id = "MaxValue", Value = reader.GetAttribute("MaxValue") });
                                                    ATTRIBUTES.Add(new Generic() { Id = "ControlValidateId", Value = reader.GetAttribute("ControlValidateId") });
                                                    VALUESCORE = reader.ReadString();
                                                    break;
                                                }
                                            }
                                            CreatedControl(ID, TYPE, OPTIONS, LABEL, REQUIRED, LABEL2, ATTRIBUTES, VALUESCORE);
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
                            if (reader.NodeType == XmlNodeType.EndElement && reader.Name == "SCORE")
                            {
                                break;
                            }
                        }
                    }
                }
                catch
                {
                }
            }
        }
    }

    /// <summary>
    /// Convert XML to controls type TEXTBOX, RADIOBUTTONLIST, CHECKBOXLIST, DROPDOWNLIST
    /// </summary>
    /// <param name="id"></param>
    /// <param name="type"></param>
    /// <param name="options"></param>
    /// <param name="label"></param>
    /// <param name="required"></param>
    /// <param name="label2"></param>
    /// <param name="attributes"></param>
    /// <param name="valueScore"></param>
    private void CreatedControl(string id, string type, List<Generic> options, string label, string required, string label2, List<Generic> attributes, string valueScore)
    {
        dvOtherInformationPanelScore.Controls.Add(new LiteralControl("<div class='content-block'><h3 class='sub-title'>"));
        Label lbl = new Label();
        lbl.Text = label;
        dvOtherInformationPanelScore.Controls.Add(lbl);
        dvOtherInformationPanelScore.Controls.Add(new LiteralControl("</h3><div class='radiobuttonlist'>"));
        Label lbl2 = new Label();
        lbl2.Text = label2;
        dvOtherInformationPanelScore.Controls.Add(lbl2);

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
                dvOtherInformationPanelScore.Controls.Add(txt);
                break;

            case "RADIOBUTTONLIST":
                RadioButtonList rb = new RadioButtonList();
                rb.ID = id;
                rb.DataValueField = "Id";
                rb.DataTextField = "Value";
                dvOtherInformationPanelScore.Controls.Add(rb);
                rb.DataSource = options;
                rb.DataBind();
                rb.CssClass = GetAttribute("CssClass", attributes);

                if (GetAttribute("RepeatDirection", attributes) == "Horizontal")
                {
                    rb.RepeatDirection = RepeatDirection.Horizontal;
                }
                else
                {
                    if (GetAttribute("RepeatDirection", attributes) == "Vertical")
                        rb.RepeatDirection = RepeatDirection.Vertical;
                }
                break;

            case "CHECKBOXLIST":
                CheckBoxList cb = new CheckBoxList();
                cb.ID = id;
                cb.DataValueField = "Id";
                cb.DataTextField = "Value";
                dvOtherInformationPanelScore.Controls.Add(cb);
                cb.DataSource = options;
                cb.DataBind();
                cb.CssClass = GetAttribute("CssClass", attributes);
                if (GetAttribute("RepeatDirection", attributes) == "Horizontal")
                {
                    cb.RepeatDirection = RepeatDirection.Horizontal;
                }
                else
                {
                    if (GetAttribute("RepeatDirection", attributes) == "Vertical")
                        cb.RepeatDirection = RepeatDirection.Vertical;
                }
                break;

            case "DROPDOWNLIST":
                DropDownList dd = new DropDownList();
                dd.ID = id;
                dd.DataValueField = "Id";
                dd.DataTextField = "Value";
                dvOtherInformationPanelScore.Controls.Add(dd);
                var listEmptyItem = new Generic();
                listEmptyItem.Id = "0";
                listEmptyItem.Value = Localization.GetString("SelectItem", LocalResourceFile);
                options.Insert(0, listEmptyItem);
                dd.DataSource = options;
                dd.DataBind();
                dd.CssClass = GetAttribute("CssClass", attributes);
                break;
        }

        if (!string.IsNullOrEmpty(required))
        {
            //Create RequiredFieldValidator
            RequiredFieldValidator rfv = new RequiredFieldValidator();
            rfv.Text = required;
            rfv.ErrorMessage = required;
            rfv.ControlToValidate = id;
            rfv.CssClass = GetAttribute("Class", attributes);
            if (type == "DROPDOWNLIST")
                rfv.InitialValue = "0";
            if (!string.IsNullOrEmpty(GetAttribute("ValidationGroup", attributes)))
                rfv.ValidationGroup = GetAttribute("ValidationGroup", attributes);
            dvOtherInformationPanelScore.Controls.Add(rfv);
        }
        dvOtherInformationPanelScore.Controls.Add(new LiteralControl("</div></div>"));
        listControls.Add(new Generic() { Id = id, Value = type, Score = valueScore, MaxValue = GetAttribute("MaxValue", attributes), ControlValidateId = GetAttribute("ControlValidateId", attributes) });
        ViewState["listControls"] = listControls;
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="id"></param>
    /// <param name="list"></param>
    /// <returns>Return value of the attribute</returns>
    private string GetAttribute(string id, List<Generic> list)
    {
        foreach (var it in list)
        {
            if (it.Id == id)
                return it.Value;
        }
        return string.Empty;
    }

    [Serializable]
    public class Generic
    {
        public string Id { get; set; }
        public string Value { get; set; }
        public string Score { get; set; }
        public string MaxValue { get; set; }
        public string ControlValidateId { get; set; }
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