using System;
using System.IO;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Services.Exceptions;
using DotNetNuke.Entities.Users;
using DotNetNuke.Services.Localization;
using DotNetNuke.Security;
using DotNetNuke.Entities.Modules.Actions;
using NexsoProBLL;
using NexsoProDAL;
using System.Net;
/// <summary>
/// Create or Update a organizations
/// </summary>
public partial class NZOrganization : PortalModuleBase, IActionable
{

    /// <summary>
    /// Override DisplayModule property is required when extending the Profile Module Base Class
    /// In page solutions, the user would update informations of organization.
    /// https://www.nexso.org/InsProfile/in/0bd8ac2e-0b3c-42da-873a-162a2454d8b7
    /// When the user register Solutions and organization not exist, the sistems solicita the information of organization and safe in the data base.
    /// https://www.nexso.org/en-us/c/EconomiaNaranja/promote
    /// </summary>
    #region Private Member Variables
    private OrganizationComponent organizationComponent;
    protected string Language = System.Globalization.CultureInfo.CurrentUICulture.Name;
    private int count = 0;
    #endregion

    #region Private Properties
    /// <summary>
    /// Get language of the organization
    /// </summary>
    /// <remarks>
    /// Default is ES
    /// </remarks> 
    protected string OrganizationLanguage
    {
        get
        {
            if (!string.IsNullOrEmpty(organizationComponent.Organization.Language))
            {
                if (organizationComponent.Organization.Language.Contains("en"))
                    return "EN";
                if (organizationComponent.Organization.Language.Contains("es"))
                    return "ES";
                if (organizationComponent.Organization.Language.Contains("pt"))
                    return "PT";
                return organizationComponent.Organization.Language;
            }
            else
            {
                return "ES";
            }
        }
    }

    /// <summary>
    /// Save in viewstate the ID of the organization
    /// </summary>
    private Guid organizationId
    {
        get
        {
            if (ViewState["OrganizationId"] != null)
                return (Guid)ViewState["OrganizationId"];
            else
                return Guid.Empty;
        }
        set { ViewState["OrganizationId"] = value; }
    }

    #endregion

    #region Private Methods
    /// <summary>
    /// Load parameters from QueryString
    /// </summary>
    private void LoadParams()
    {
        if (organizationId == Guid.Empty)
        {
            if (Request.QueryString["in"] != string.Empty)
            {
                try
                {
                    organizationId = new Guid(Request.QueryString["in"]);
                    EnabledButtons = true;
                }
                catch
                {
                    organizationId = Guid.Empty;
                }
            }
            else
            {
                organizationId = Guid.Empty;
            }
        }
    }

    /// <summary>
    /// Enable buttons and inputs to load information from the organization
    /// </summary>
    private void PopulateLabels()
    {
        // Action buttons
        btnEditProfile.Text = Localization.GetString("EditProfile",
                                                     LocalResourceFile);
        btnEditProfile2.Text = Localization.GetString("EditProfile",
                                                     LocalResourceFile);
        btnCancel.Text = Localization.GetString("Cancel",
                                                LocalResourceFile);
        if (organizationId != Guid.Empty)
        {
            EnableEditControls(false);
        }
        else
        {
            EnableEditControls(true);
        }
    }
    /// <summary>
    /// Enable buttons and inputs to load information from the organization
    /// </summary>
    /// <param name="enabled"></param>
    private void EnableEditControls(bool enabled)
    {
        // if querystring [in] (organizationId) exist
        if (EnabledButtons)
        {
            // if organizationId is diferent of Guid.Empty
            if (enabled)
            {
                if (organizationId != Guid.Empty)
                {
                    //get text for buttons and visibility options
                    btnEditProfile.CommandArgument = "";
                    btnEditProfile2.CommandArgument = "";
                    btnCancel.Visible = true;
                    btnEditProfile.Text = Localization.GetString("SaveProfile",
                                                                 LocalResourceFile);
                    btnEditProfile2.Text = Localization.GetString("SaveProfile",
                                                                 LocalResourceFile);
                }
                else
                {
                    //get text for buttons and visibility options
                    btnEditProfile.CommandArgument = "";
                    btnEditProfile2.CommandArgument = "";
                    btnCancel.Visible = false;
                    btnEditProfile.Text = Localization.GetString("CreateNew",
                                                                 LocalResourceFile);
                    btnEditProfile2.Text = Localization.GetString("CreateNew",
                                                                 LocalResourceFile);
                }
            }
            else
            {
                //Get relacion from user and organization
                UserOrganizationComponent com = new UserOrganizationComponent(UserId, organizationId);
                if ((com.UserOrganization.Role == 1 && EnabledButtons) || UserController.GetCurrentUserInfo().IsInRole("Administrator"))
                {
                    //get text for buttons and visibility options
                    btnEditProfile.CommandArgument = "EDIT";
                    btnEditProfile.Text = Localization.GetString("EditProfile",
                                                                 LocalResourceFile);
                    btnEditProfile.Visible = true;
                    btnEditProfile2.CommandArgument = "EDIT";
                    btnEditProfile2.Text = Localization.GetString("EditProfile",
                                                                 LocalResourceFile);
                    btnEditProfile2.Visible = true;         
                    btnCancel.Visible = false;
                }
                else
                {
                    //visibility options
                    btnEditProfile.Visible = false;
                    btnEditProfile2.Visible = false;
                    btnCancel.Visible = false;
                }
            }
        }
        else
        {
            //visibility options
            btnEditProfile.Visible = false;
            btnCancel.Visible = false;
        }
        ViewPanel.Visible = !enabled;
        EditPanel.Visible = enabled;

    }

    /// <summary>
    /// Get and display information of the Organization 
    /// </summary>
    private void FillData()
    {
        // Decode Information and display in the labels and the textbox
        lblInstitutionNameTxt.Text = WebUtility.HtmlDecode(organizationComponent.Organization.Name);
        lblDesciptionTxt.Text = WebUtility.HtmlDecode(organizationComponent.Organization.Description);
        hfInstitutionNameTxt.Text = WebUtility.HtmlDecode(organizationComponent.Organization.Name);
        hfInstitutionNameTxt.Style.Add("display", "none");
        lblCount.Style.Add("display", "none");
        lblCount.Text = "0";
        lblPhoneTxt.Text = organizationComponent.Organization.Phone;
        lblSkype.Text = WebUtility.HtmlDecode(organizationComponent.Organization.Skype);
        lblTwitter.Text = WebUtility.HtmlDecode(organizationComponent.Organization.Twitter);
        lblFacebook.Text = WebUtility.HtmlDecode(organizationComponent.Organization.Facebook);
        lblGoogle.Text = WebUtility.HtmlDecode(organizationComponent.Organization.GooglePlus);
        lblLinkedin.Text = WebUtility.HtmlDecode(organizationComponent.Organization.LinkedIn);
        if (organizationId != Guid.Empty)
        {
            txtInstitutionName.Text = WebUtility.HtmlDecode(organizationComponent.Organization.Name);
        }
        txtDescription.Text = WebUtility.HtmlDecode(organizationComponent.Organization.Description);
        txtPhone.Text = organizationComponent.Organization.Phone;
        txtSkype.Text = WebUtility.HtmlDecode(organizationComponent.Organization.Skype);
        txtTwitter.Text = WebUtility.HtmlDecode(organizationComponent.Organization.Twitter);
        txtFacebook.Text = WebUtility.HtmlDecode(organizationComponent.Organization.Facebook);
        txtGoogle.Text = WebUtility.HtmlDecode(organizationComponent.Organization.GooglePlus);
        txtLinkedIn.Text = WebUtility.HtmlDecode(organizationComponent.Organization.LinkedIn);
        lblEmailTxt.Text = organizationComponent.Organization.Email;
        txtEmail.Text = organizationComponent.Organization.Email;
        lblAddress.Text = WebUtility.HtmlDecode(organizationComponent.Organization.Address);
        lblCity.Text = CountryStateCityViewMode.SelectedCityName;
        lblState.Text = CountryStateCityViewMode.SelectedStateName;
        lblCountry.Text = CountryStateCityViewMode.SelectedCountryName;
        //Set information to module Country State City from organizationComponent
        CountryStateCityEditMode.SelectedAddress = organizationComponent.Organization.Address;
        CountryStateCityEditMode.SelectedCountry = organizationComponent.Organization.Country;
        CountryStateCityEditMode.SelectedState = organizationComponent.Organization.Region;
        CountryStateCityEditMode.SelectedCity = organizationComponent.Organization.City;
        CountryStateCityEditMode.SelectedLatitude = organizationComponent.Organization.Latitude.GetValueOrDefault(0);
        CountryStateCityEditMode.SelectedLongitude = organizationComponent.Organization.Longitude.GetValueOrDefault(0);
        CountryStateCityViewMode.SelectedAddress = organizationComponent.Organization.Address;
        CountryStateCityViewMode.SelectedCountry = organizationComponent.Organization.Country;
        CountryStateCityViewMode.SelectedState = organizationComponent.Organization.Region;
        CountryStateCityViewMode.SelectedCity = organizationComponent.Organization.City;
        CountryStateCityViewMode.SelectedLatitude = organizationComponent.Organization.Latitude.GetValueOrDefault(0);
        CountryStateCityViewMode.SelectedLongitude = organizationComponent.Organization.Longitude.GetValueOrDefault(0);
        // Set images and social networks
        if (!string.IsNullOrEmpty(organizationComponent.Organization.Logo))
        {
            imgInstitution.ImageUrl = PortalSettings.HomeDirectory + "ModIma/Images/" +
                                      organizationComponent.Organization.Logo;
        }
        else
        {
            imgInstitution.ImageUrl = PortalSettings.HomeDirectory + "ModIma/Images/noImage.png";
        }
        imgInstitution2.ImageUrl = imgInstitution.ImageUrl;
        lblSkype.Text = WebUtility.HtmlDecode(organizationComponent.Organization.Skype);
        if (organizationComponent.Organization.Twitter != string.Empty)
        {
            hlTwitter.NavigateUrl = @"http://www.twitter.com/" + organizationComponent.Organization.Twitter;
            hlTwitter.ToolTip = organizationComponent.Organization.Twitter;
            hlTwitter.Visible = true;
        }
        else
        {
            hlTwitter.Visible = false;
        }
        if (organizationComponent.Organization.Facebook != string.Empty)
        {
            hlFacebook.NavigateUrl = @"http://www.facebook.com/" + organizationComponent.Organization.Facebook;
            hlFacebook.ToolTip = organizationComponent.Organization.Facebook;
            hlFacebook.Visible = true;
        }
        else
        {
            hlFacebook.Visible = false;
        }
        if (organizationComponent.Organization.GooglePlus != string.Empty)
        {
            hlGoogle.NavigateUrl = @"http://plus.google.com/" + organizationComponent.Organization.GooglePlus;
            hlGoogle.ToolTip = organizationComponent.Organization.GooglePlus;
            hlGoogle.Visible = true;
        }
        else
        {
            hlGoogle.Visible = false;
        }
        if (organizationComponent.Organization.LinkedIn != string.Empty)
        {
            hlLinkedin.NavigateUrl = @"http://www.linkedin.com/" + organizationComponent.Organization.LinkedIn;
            hlLinkedin.ToolTip = organizationComponent.Organization.LinkedIn;
            hlLinkedin.Visible = true;
        }
        else
        {
            hlLinkedin.Visible = false;
        }
    }

    /// <summary>
    /// Registers the client script with the Page object using a key and a URL, which enables the script to be called from the client.
    /// </summary>
    private void RegisterScripts()
    {
        if (!IsPostBack)
        {
            string script = "<script> function onClientFileUploaded" + ClientID + "(sender, args) {" +
                                "document.getElementById('" + RadButton11.ClientID + "').click();}</script>";
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "script" + ClientID, script);
        }
    }
    #endregion

    #region Public Properties        
    public string OrganizationTitle
    {
        get
        {
            return txtInstitutionName.Text;
        }
        set
        {
            txtInstitutionName.Text = value;
        }

    }
    public string BioClientID
    {
        get { return txtDescription.ClientID; }
    }
    public Guid OrganizationId
    {
        get { return organizationId; }
        set { organizationId = value; }
    }
    public string RadButtonId
    {
        get { return RadButton11.ClientID; }
    }
    public bool EnabledButtons
    {
        get
        {
            if (ViewState["EnabledButtons"] != null)
                return (bool)ViewState["EnabledButtons"];
            else
                return false;
        }
        set { ViewState["EnabledButtons"] = value; }
    }
    #endregion

    #region Public Methods
    /// <summary>
    /// Bind data and config the controls (buttons view, CountryStateCityEditMode)
    /// </summary>
    public void LoadControl()
    {
        organizationComponent = new OrganizationComponent(organizationId);
        organizationId = organizationComponent.Organization.OrganizationID;
        btnEditProfile.CommandArgument = "EDIT";
        btnEditProfile2.CommandArgument = "EDIT";
        FillData();
        btnEditProfile.Visible = EnabledButtons;
        btnEditProfile2.Visible = EnabledButtons;
        PopulateLabels();
        CountryStateCityEditMode.UpdateMap();
        CountryStateCityViewMode.UpdateMap();
    }

    /// <summary>
    /// Save and update information of the organization
    /// </summary>
    /// <returns>status of save</returns>
    public bool SaveData()
    {
        try
        {
            NexsoProDAL.MIFNEXSOEntities mifnexsoEntities = new MIFNEXSOEntities();
            mifnexsoEntities.Connection.Open();
            var trans = mifnexsoEntities.Connection.BeginTransaction();
            try
            {
                if (organizationComponent.Organization.OrganizationID == Guid.Empty)
                {
                    organizationComponent.Organization.Created = DateTime.Now;
                    organizationComponent.Organization.Updated = organizationComponent.Organization.Created.GetValueOrDefault(DateTime.Now);
                }
                else
                {
                    organizationComponent.Organization.Updated = DateTime.Now;
                }
                organizationComponent.Organization.Name = ValidateSecurity.ValidateString(txtInstitutionName.Text, false);
                organizationComponent.Organization.Description = ValidateSecurity.ValidateString(txtDescription.Text, false);
                organizationComponent.Organization.ZipCode = CountryStateCityEditMode.SelectedPostalCode;
                organizationComponent.Organization.Phone = ValidateSecurity.ValidateString(txtPhone.Text, false);
                organizationComponent.Organization.Skype = ValidateSecurity.ValidateString(txtSkype.Text, false);
                organizationComponent.Organization.Twitter = ValidateSecurity.ValidateString(txtTwitter.Text, false);
                organizationComponent.Organization.Facebook = ValidateSecurity.ValidateString(txtFacebook.Text, false);
                organizationComponent.Organization.GooglePlus = ValidateSecurity.ValidateString(txtGoogle.Text, false);
                organizationComponent.Organization.LinkedIn = ValidateSecurity.ValidateString(txtLinkedIn.Text, false);
                organizationComponent.Organization.Address = ValidateSecurity.ValidateString(CountryStateCityEditMode.SelectedAddress, false);
                organizationComponent.Organization.Country = CountryStateCityEditMode.SelectedCountry;
                organizationComponent.Organization.Region = CountryStateCityEditMode.SelectedState;
                organizationComponent.Organization.City = CountryStateCityEditMode.SelectedCity;
                organizationComponent.Organization.Latitude = CountryStateCityEditMode.SelectedLatitude;
                organizationComponent.Organization.Longitude = CountryStateCityEditMode.SelectedLongitude;
                CountryStateCityViewMode.SelectedAddress = ValidateSecurity.ValidateString(CountryStateCityEditMode.SelectedAddress, false);
                CountryStateCityViewMode.SelectedCountry = CountryStateCityEditMode.SelectedCountry;
                CountryStateCityViewMode.SelectedState = CountryStateCityEditMode.SelectedState;
                CountryStateCityViewMode.SelectedCity = CountryStateCityEditMode.SelectedCity;
                CountryStateCityViewMode.SelectedLatitude = CountryStateCityEditMode.SelectedLatitude;
                CountryStateCityViewMode.SelectedLongitude = CountryStateCityEditMode.SelectedLongitude;
                CountryStateCityViewMode.SelectedPostalCode = CountryStateCityEditMode.SelectedPostalCode;
                CountryStateCityViewMode.UpdateMap();
                organizationComponent.Organization.Email = txtEmail.Text;
                string newImg = Path.GetFileName(imgInstitution.ImageUrl);
                if (organizationComponent.Organization.Logo != newImg && newImg.ToUpper() != "NOIMAGE.PNG")
                {
                    File.Move(Server.MapPath(PortalSettings.HomeDirectory + "ModIma/TempImages/" + newImg), Server.MapPath(PortalSettings.HomeDirectory + "ModIma/Images/" + newImg));
                    imgInstitution.ImageUrl = PortalSettings.HomeDirectory + "ModIma/Images/" + newImg;
                    organizationComponent.Organization.Logo = newImg;
                }
                if (organizationComponent.Save() > 0)
                {
                    if (organizationId == Guid.Empty)
                    {
                        UserInfo userInfo = UserController.Instance.GetCurrentUserInfo();
                        organizationId = organizationComponent.Organization.OrganizationID;

                        UserOrganizationComponent userOrganizationComponent = new UserOrganizationComponent(
                            userInfo.UserID, organizationId, 1);
                        userOrganizationComponent.ChangeContext(ref mifnexsoEntities);
                        if (userOrganizationComponent.Save() < 0)
                        {
                            throw new Exception();
                        }
                    }
                }
                else
                {
                    throw new Exception();
                }
                mifnexsoEntities.AcceptAllChanges();
                trans.Commit();
                mifnexsoEntities.Dispose();
                organizationId = organizationComponent.Organization.OrganizationID;
                return true;
            }
            catch (Exception exc)
            {
                trans.Rollback();
                mifnexsoEntities.Dispose();
                Exceptions.
                ProcessModuleLoadException(
                this, exc);
                return false;
            }
        }
        catch (Exception exc)
        {
            Exceptions.
                ProcessModuleLoadException(
                this, exc);
            return false;
        }
    }
    #endregion

    #region Subclasses
    #endregion

    #region Events    
    /// <summary>
    /// Config  controls 
    /// </summary>
    /// <param name="e"></param>
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (organizationComponent == null)
        {
            LoadParams();
            organizationComponent = new OrganizationComponent(organizationId);
            if (!IsPostBack)
            {
                LoadControl();
            }
        }
        if (UserController.Instance.GetCurrentUserInfo().UserID < 0)
        {
            RadAsyncUpload1.Localization.Select = Localization.GetString("UploadImage",                                                             LocalResourceFile);
            btnEditProfile.Visible = false;
            btnEditProfile2.Visible = false;
            btnCancel.Visible = false;
        }
    }

    /// <summary>
    /// Upload files related to the organization
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RadAsyncUpload1_FileUploaded(object sender, Telerik.Web.UI.FileUploadedEventArgs e)
    {
        count++;
        if (RadAsyncUpload1.UploadedFiles.Count > 0 && count == 1)
        {
            string FileName = Path.GetFileName(RadAsyncUpload1.UploadedFiles[RadAsyncUpload1.UploadedFiles.Count - 1].FileName);
            string extensionName = Path.GetExtension(RadAsyncUpload1.UploadedFiles[RadAsyncUpload1.UploadedFiles.Count - 1].FileName);
            FileName = Guid.NewGuid().ToString();
            RadAsyncUpload1.UploadedFiles[RadAsyncUpload1.UploadedFiles.Count - 1].SaveAs(
                Server.MapPath(PortalSettings.HomeDirectory + "ModIma/TempImages/" + FileName + extensionName));
            imgInstitution.ImageUrl = PortalSettings.HomeDirectory + "ModIma/TempImages/" + FileName + extensionName;
        }
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        RadAsyncUpload1.OnClientFileUploaded = "onClientFileUploaded" + ClientID;
        RegisterScripts();
    }

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        string FileName = Path.GetFileNameWithoutExtension(this.AppRelativeVirtualPath);
        if (this.ID != null)
            //this will fix it when its placed as a ChildUserControl 
            this.LocalResourceFile = this.LocalResourceFile.Replace(this.ID, FileName);
        else
            // this will fix it when its dynamically loaded using LoadControl method 
            this.LocalResourceFile = this.LocalResourceFile + FileName + ".ascx.resx";
    }

    protected void btnEditProfile_Click(object sender, EventArgs e)
    {
        if (btnEditProfile.CommandArgument == "EDIT")
        {
            EnableEditControls(true);
        }
        else
        {
            if (SaveData())
            {
                EnableEditControls(false);
                FillData();
            }
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        btnEditProfile.CommandArgument = "EDIT";
        btnEditProfile.Text = Localization.GetString("EditProfile",
                                                     LocalResourceFile);
        btnEditProfile2.CommandArgument = "EDIT";
        btnEditProfile2.Text = Localization.GetString("EditProfile",
                                                     LocalResourceFile);
        btnCancel.Visible = false;
        EnableEditControls(false);
    }
    #endregion

    #region Optional Interfaces
    /// <summary>
    /// DNN actions (Edit mode)
    /// </summary>
    public ModuleActionCollection ModuleActions
    {
        get
        {
            var actions = new ModuleActionCollection
                    {
                        {
                            GetNextActionID(), Localization.GetString("EditModule", LocalResourceFile), "", "", "",
                            EditUrl(), false, SecurityAccessLevel.Edit, true, false
                        }
                    };
            return actions;
        }
    }
    #endregion
}

