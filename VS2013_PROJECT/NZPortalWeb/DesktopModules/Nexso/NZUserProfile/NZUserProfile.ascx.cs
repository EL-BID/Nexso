using System.Configuration;
using System.Linq;
using System.Threading;
using System.Web.UI.WebControls;
using DotNetNuke.Common;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Entities.Portals;
using DotNetNuke.Security.Roles;
using DotNetNuke.Services.Exceptions;
using System;
using DotNetNuke.Common.Utilities;
using DotNetNuke.Entities.Users;
using DotNetNuke.Entities.Profile;
using DotNetNuke.Services.Localization;
using DotNetNuke.Security;
using DotNetNuke.Entities.Modules.Actions;
using NexsoProBLL;
using NexsoProDAL;
using System.Web;
using System.Net;


public partial class NZUserProfile : UserUserControlBase, IActionable
{
    #region Private Member Variables
    private ProfilePropertyAccess propertyAccess;
    private string profileResourceFile;
    private int userId;
    private UserInfo currentUser = null;
    #endregion

    #region Private Properties
    #endregion

    #region Private Methods

    /// <summary>
    /// Load information of the current user or the user sent via querystring (ui)
    /// </summary>
    private void LoadParams()
    {
        if (UserController.GetCurrentUserInfo().IsInRole("Administrators") ||
            UserController.GetCurrentUserInfo().IsInRole("NexsoSupport"))
        {
            if (!string.IsNullOrEmpty(Request.QueryString["ui"]))
            {
                if (!string.IsNullOrEmpty(ValidateSecurity.ValidateString(Request.QueryString["ui"], false)))
                {
                    if (Request.QueryString["ui"] == "create")
                    {
                        userId = -1000;
                        currentUser = new UserInfo();
                        return;
                    }
                    else
                    {
                    }
                }
                else
                {
                    throw new Exception();
                }
            }
        }
        try
        {
            if (!string.IsNullOrEmpty(Request.QueryString["ui"]))
            {
                if (!string.IsNullOrEmpty(ValidateSecurity.ValidateString(Request.QueryString["ui"], false)))
                {
                    userId = Convert.ToInt32(Request.QueryString["ui"]);
                    currentUser = UserController.GetUserById(PortalId, userId);
                    return;
                }
                else
                {
                    throw new Exception();
                }
            }
        }
        catch
        {
            throw;
        }
        currentUser = UserController.GetCurrentUserInfo();
        userId = currentUser.UserID;
    }

    /// <summary>
    /// Load validations messages
    /// </summary>
    private void PopulateLabels()
    {
        rgvEmail.ErrorMessage = Localization.GetString("InvalidEmail", LocalResourceFile);
        rgvPassword.ErrorMessage = Localization.GetString("InvalidPassword", LocalResourceFile);
        rgvtxtFirstName.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
        rgvtxtLastName.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
        rgvtxtFacebook.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
        rgvtxtGoogle.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
        rgvtxtLinkedIn.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
        rgvtxtPhone.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
        rgvtxtSkype.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
        rgvtxtTwitter.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
        string urlBase = Request.Url.AbsoluteUri.Replace(Request.Url.PathAndQuery, "") + ControlPath;
    }

    /// <summary>
    /// Load text to labels and load the all categories of user preferences
    /// </summary>
    private void PopulateControls()
    {
        var list = ListComponent.GetListPerCategory("AvailableResource", Thread.CurrentThread.CurrentCulture.Name).ToList();
        var listEmptyItem = new NexsoProDAL.List();
        listEmptyItem.Value = "0";
        listEmptyItem.Label = Localization.GetString("SelectItem", LocalResourceFile);
        list = ListComponent.GetListPerCategory("Theme", Thread.CurrentThread.CurrentCulture.Name).ToList();
        chkTheme.DataSource = list;
        chkTheme.DataBind();
        list = ListComponent.GetListPerCategory("Beneficiaries", Thread.CurrentThread.CurrentCulture.Name).ToList();
        chkBeneficiaries.DataSource = list;
        chkBeneficiaries.DataBind();
        list = ListComponent.GetListPerCategory("Sector", Thread.CurrentThread.CurrentCulture.Name).ToList();
        chkSector.DataSource = list;
        chkSector.DataBind();
        list = ListComponent.GetListPerCategory("WhoAreYou", Thread.CurrentThread.CurrentCulture.Name).ToList();
        list.Insert(0, listEmptyItem);
        ddlWhoareYou.DataSource = list;
        ddlWhoareYou.DataBind();
        list = ListComponent.GetListPerCategory("Source", Thread.CurrentThread.CurrentCulture.Name).ToList();
        list.Insert(0, listEmptyItem);
        ddlSource.DataSource = list;
        ddlSource.DataBind();
        list = ListComponent.GetListPerCategory("Language", Thread.CurrentThread.CurrentCulture.Name).ToList();
        list.Insert(0, listEmptyItem);
        ddlLanguage.DataSource = list;
        ddlLanguage.DataBind();
        if (userId > 0)
        {
            txtEmail.Text = currentUser.Email;
            lblEmailTxt.Text = txtEmail.Text;
            foreach (ProfilePropertyDefinition property in currentUser.Profile.ProfileProperties)
            {
                MapPropToPage(property.PropertyName, property.PropertyValue);
            }
            MapPropToPage(userId);
        }

        var returnUrl = Globals.UserProfileURL(userId);
        string url = NexsoHelper.GetCulturedUrlByTabName("Change Password") + "?returnurl=" + returnUrl;
        passwordLink.NavigateUrl = url;
        if (PortalSettings.EnablePopUps)
        {
            passwordLink.Attributes.Add("onclick", "return " + UrlUtils.PopUpUrl(url, this, PortalSettings, true, false, 300, 650));
        }
    }

    /// <summary>
    /// Get items (answer) of the registered user
    /// </summary>
    /// <param name="listName">name of the list of answer</param>
    /// <param name="checkBoxList"></param>
    private void SetChkControl(string listName, CheckBoxList checkBoxList)
    {
        var list = UserPropertiesListComponent.GetListPerCategory(userId, listName);

        ListItem item;
        foreach (var itemL in list)
        {
            item = checkBoxList.Items.FindByValue(itemL.Key);
            if (item != null)
                item.Selected = true;
        }

    }

    /// <summary>
    /// Save items (answer) of the registered user
    /// </summary>
    /// <param name="listName">name of the list of answer</param>
    /// <param name="checkBoxList"></param>
    private bool SaveChkControl(string listItem, CheckBoxList checkBoxList)
    {
        if (UserPropertiesListComponent.deleteListPerCategory(userId, listItem))
        {
            string result = string.Empty;
            foreach (ListItem item in checkBoxList.Items)
            {
                if (item.Selected)
                {
                    UserPropertiesListComponent sol = new UserPropertiesListComponent(userId, item.Value, listItem);
                    sol.Save();
                }
            }
            return true;
        }
        return false;
    }


    /// <summary>
    /// Add new user to the data base
    /// </summary>
    /// <returns></returns>
    private int AddUser()
    {
        int totalUsers = 0;
        UserController.GetUsersByUserName(PortalId, txtEmail.Text, 1, 1, ref totalUsers);
        if (totalUsers == 0)
        {
            var objUser = new DotNetNuke.Entities.Users.UserInfo();
            objUser.AffiliateID = Null.NullInteger;
            objUser.Email = ValidateSecurity.ValidateString(txtEmail.Text, false);
            objUser.FirstName = ValidateSecurity.ValidateString(txtFirstName.Text, false);
            objUser.IsSuperUser = false;
            objUser.LastName = ValidateSecurity.ValidateString(txtLastName.Text, false);
            objUser.PortalID = PortalController.GetCurrentPortalSettings().PortalId;
            objUser.Username = ValidateSecurity.ValidateString(txtEmail.Text, false);
            objUser.DisplayName = ValidateSecurity.ValidateString(txtFirstName.Text, false) + " " + ValidateSecurity.ValidateString(txtLastName.Text, false);
            objUser.Membership.Password = txtPassword.Text;
            objUser.Membership.Email = objUser.Email;
            objUser.Membership.Username = objUser.Username;
            objUser.Membership.UpdatePassword = false;
            objUser.Membership.LockedOut = true;
            if (userId == -1000)
                objUser.Membership.Approved = true; //pero impersonation
            else
                objUser.Membership.Approved = true; //regular creation
            DotNetNuke.Security.Membership.UserCreateStatus objCreateStatus =
            DotNetNuke.Entities.Users.UserController.CreateUser(ref objUser);
            if (objCreateStatus == DotNetNuke.Security.Membership.UserCreateStatus.Success)
            {
                CompleteUserCreation(DotNetNuke.Security.Membership.UserCreateStatus.Success, objUser, true, IsRegister);
                //objUser.Profile.InitialiseProfile(objUser.PortalID);
                //objUser.Profile.Country = CountryStateCity1.SelectedCountry;
                //objUser.Profile.Street = txtAddress.Text;
                //objUser.Profile.City = CountryStateCity1.SelectedCity;
                //objUser.Profile.Region = CountryStateCity1.SelectedState;
                //objUser.Profile.PostalCode = txtPostalCode.Text;
                //objUser.Profile.Telephone = txtPhone.Text;
                //objUser.Profile.FirstName = txtFirstName.Text;
                //objUser.Profile.LastName = txtLastName.Text;
                ////the agreement is sgned on
                //objUser.Profile.SetProfileProperty("Agreement", "A001");
                //UserController.UpdateUser(objUser.PortalID, objUser);
                UserPropertyComponent userProperty = new UserPropertyComponent(objUser.UserID);
                SaveProfile(userProperty.UserProperty);
                userProperty.Save();
                if (!objUser.IsInRole("Registered Users"))
                {
                    var oDnnRoleController = new RoleController();

                    RoleInfo oCurrentRole = oDnnRoleController.GetRoleByName(this.PortalId, "Registered Users");
                    oDnnRoleController.AddUserRole(this.PortalId, objUser.UserID, oCurrentRole.RoleID,
                                                   System.DateTime.Now.AddDays(-1),
                                                   DotNetNuke.Common.Utilities.Null.NullDate);
                }
                return objUser.UserID;
            }
            else
            {
                lblMessage.ErrorMessage = Localization.GetString("ExistingUser",
                                                                 LocalResourceFile);
                lblMessage.IsValid = false;
            }
        }
        else
        {
            lblMessage.ErrorMessage = Localization.GetString("ExistingUser",
                                                             LocalResourceFile);
            lblMessage.IsValid = false;
        }
        return -1;
    }

    /// <summary>
    /// Verify that the entered text isn't a script or a stylesheet
    /// </summary>
    /// <param name="user"></param>
    private void SaveProfile(UserInfo user)
    {
        user.Profile.SetProfileProperty("FirstName", ValidateSecurity.ValidateString(txtFirstName.Text, false));
        user.Profile.SetProfileProperty("LastName", ValidateSecurity.ValidateString(txtLastName.Text, false));
        //user.Profile.SetProfileProperty("Street", txtAddress.Text);
        //user.Profile.SetProfileProperty("City", CountryStateCity1.SelectedCity);
        //user.Profile.SetProfileProperty("Region", CountryStateCity1.SelectedState);
        //user.Profile.SetProfileProperty("Country", CountryStateCity1.SelectedCountry);
        //user.Profile.SetProfileProperty("PostalCode", txtPostalCode.Text);
        //user.Profile.SetProfileProperty("Telephone", txtPhone.Text);
        //user.Profile.SetProfileProperty("SkypeName", txtSkype.Text);
        //user.Profile.SetProfileProperty("Twitter", txtTwitter.Text);
        //user.Profile.SetProfileProperty("FaceBook", txtFacebook.Text);
        //user.Profile.SetProfileProperty("Google", txtGoogle.Text);
        //user.Profile.SetProfileProperty("LinkedIn", txtLinkedIn.Text);
        //user.Profile.SetProfileProperty("Agreement", "A001");
    }

    /// <summary>
    /// Save the new user or update an exist user
    /// </summary>
    /// <param name="user"></param>
    /// <returns></returns>
    private int SaveProfile(UserProperty user)
    {
        try
        {
            user.FirstName = ValidateSecurity.ValidateString(txtFirstName.Text, false);
            user.LastName = ValidateSecurity.ValidateString(txtLastName.Text, false);
            user.Address = ValidateSecurity.ValidateString(CountryStateCityEditMode.SelectedAddress, false);
            user.City = CountryStateCityEditMode.SelectedCity;
            user.Region = CountryStateCityEditMode.SelectedState;
            user.Country = CountryStateCityEditMode.SelectedCountry;
            user.PostalCode = CountryStateCityEditMode.SelectedPostalCode;
            user.Longitude = CountryStateCityEditMode.SelectedLongitude;
            user.Latitude = CountryStateCityEditMode.SelectedLatitude;
            user.Telephone = ValidateSecurity.ValidateString(txtPhone.Text, false);
            user.SkypeName = ValidateSecurity.ValidateString(txtSkype.Text, false);
            user.Twitter = ValidateSecurity.ValidateString(txtTwitter.Text, false);
            user.FaceBook = ValidateSecurity.ValidateString(txtFacebook.Text, false);
            user.Google = ValidateSecurity.ValidateString(txtGoogle.Text, false);
            user.LinkedIn = ValidateSecurity.ValidateString(txtLinkedIn.Text, false);
            user.Agreement = "A001";
            user.CustomerType = Convert.ToInt32(ddlWhoareYou.SelectedValue);
            user.NexsoEnrolment = Convert.ToInt32(ddlSource.SelectedValue);
            user.Language = Convert.ToInt32(ddlLanguage.SelectedValue);
            user.AllowNexsoNotifications = Convert.ToInt32(chkNotifications.Checked);
        }
        catch (Exception exc)
        //Module failed to load
        {
            Exceptions.
                ProcessModuleLoadException(
                this, exc);
        }
        return 0;
    }

    /// <summary>
    /// configure the display (visible or invisible buttons and labels) depending on whether you want to create, view or edit a user)
    /// </summary>
    /// <param name="state"></param>
    private void setControl(string state)
    {
        switch (state)
        {
            case "CREATE":
                {
                    btnEditProfile.Text = Localization.GetString("CreateNewProfile", LocalResourceFile);
                    btnCancel.Text = Localization.GetString("Decline",
                                                            LocalResourceFile);
                    btnEditProfile.CommandArgument = "CREATE";
                    btnCancel.CommandArgument = "DECLINE";
                    divPassword.Visible = true;
                    divPasswordConfirm.Visible = true;
                    CountryStateCityEditMode.ViewInEditMode = true;
                    CountryStateCityEditMode.DataBind();
                    EditPanel.Visible = true;
                    ViewPanel.Visible = false;
                    dvTerms.Visible = true;
                    dvSocialMediaPane.Visible = false;
                    txtEmail.Enabled = true;
                    btnEditProfile.Enabled = chkTerms.Checked;
                    btnEditProfile.Visible = true;
                    btnCancel.Visible = false;
                    break;
                }
            case "VIEW":
                {
                    btnEditProfile.Text = Localization.GetString("EditProfile",
                                                                 LocalResourceFile);
                    btnCancel.Text = Localization.GetString("Cancel",
                                                            LocalResourceFile);
                    btnEditProfile.CommandArgument = "EDIT";
                    btnCancel.CommandArgument = "CANCEL";
                    divPassword.Visible = false;
                    divPasswordConfirm.Visible = false;
                    //     CountryStateCityEditMode.EditMode = false;
                    //     CountryStateCityEditMode.DataBind();
                    dvTerms.Visible = false;
                    EditPanel.Visible = false;
                    ViewPanel.Visible = true;
                    dvSocialMediaPane.Visible = true;
                    txtEmail.Enabled = false;
                    btnEditProfile.Visible = false;
                    btnCancel.Visible = false;
                    if (currentUser.UserID == UserController.GetCurrentUserInfo().UserID)
                    {
                        btnEditViewMode.Visible = true;
                        passwordLink.Visible = true;
                    }
                    else
                    {
                        btnEditViewMode.Visible = false;
                        passwordLink.Visible = false;
                    }
                    rvPassword.Enabled = false;
                    rvPasswordConfirmation.Enabled = false;
                    //     CountryStateCityEditMode.EditMode = true;
                    break;
                }

            case "EDIT":
                {
                    btnEditProfile.CommandArgument = "EDITING";
                    btnEditProfile.Text = Localization.GetString("SaveProfile",
                                                                 LocalResourceFile);
                    btnCancel.Text = Localization.GetString("Cancel",
                                                            LocalResourceFile);
                    if (!chkTerms.Checked)
                    {
                        dvTerms.Visible = true;
                        btnEditProfile.Enabled = false;
                        btnCancel.Visible = false;
                        pnlImportantMessage.Visible = true;
                        lblImportantMessage.Text = Localization.GetString("SingAgreement",
                                                                          LocalResourceFile);
                    }
                    else
                    {
                        dvTerms.Visible = false;
                        btnEditProfile.Enabled = true;
                        btnCancel.Visible = true;
                        pnlImportantMessage.Visible = false;
                    }
                    divPassword.Visible = false;
                    divPasswordConfirm.Visible = false;
                    //CountryStateCity1.EditMode = true;
                    //CountryStateCity1.DataBind();
                    EditPanel.Visible = true;
                    ViewPanel.Visible = false;
                    dvSocialMediaPane.Visible = true;
                    txtEmail.Enabled = false;
                    btnEditProfile.Visible = true;
                    break;
                }
        }
    }

    #endregion

    #region Constructors
    #endregion

    #region Public Properties
    public bool IncludeButton
    {
        get
        {
            var includeButton = true;
            if (ModuleContext.Settings.ContainsKey("IncludeButton"))
            {
                includeButton = Convert.ToBoolean(ModuleContext.Settings["IncludeButton"]);
            }
            return includeButton;
        }
    }
    public string ProfileProperties { get; set; }
    #endregion

    #region Public Methods
    /// <summary>
    /// Load Location and social networks of the user
    /// </summary>
    /// <param name="userId"></param>
    public void MapPropToPage(int userId)
    {
        UserPropertyComponent userPropertyComponent = new UserPropertyComponent(userId);
        if (!string.IsNullOrEmpty(userPropertyComponent.UserProperty.Agreement))
        {
            chkTerms.Checked = true;
        }
        else
        {
            chkTerms.Checked = false;
        }
        CountryStateCityEditMode.SelectedCountry = userPropertyComponent.UserProperty.Country;
        CountryStateCityEditMode.SelectedState = userPropertyComponent.UserProperty.Region;
        CountryStateCityEditMode.SelectedCity = userPropertyComponent.UserProperty.City;
        CountryStateCityEditMode.SelectedLatitude = userPropertyComponent.UserProperty.Latitude.GetValueOrDefault(0);
        CountryStateCityEditMode.SelectedLongitude = userPropertyComponent.UserProperty.Longitude.GetValueOrDefault(0);
        CountryStateCityEditMode.SelectedAddress = userPropertyComponent.UserProperty.Address;
        CountryStateCityViewMode.SelectedCountry = userPropertyComponent.UserProperty.Country;
        CountryStateCityViewMode.SelectedState = userPropertyComponent.UserProperty.Region;
        CountryStateCityViewMode.SelectedCity = userPropertyComponent.UserProperty.City;
        CountryStateCityViewMode.SelectedLatitude = userPropertyComponent.UserProperty.Latitude.GetValueOrDefault(0);
        CountryStateCityViewMode.SelectedLongitude = userPropertyComponent.UserProperty.Longitude.GetValueOrDefault(0);
        CountryStateCityViewMode.SelectedAddress = userPropertyComponent.UserProperty.Address;
        txtPhone.Text = userPropertyComponent.UserProperty.Telephone;
        lblPhoneTxt.Text = userPropertyComponent.UserProperty.Telephone;
        txtSkype.Text = userPropertyComponent.UserProperty.SkypeName;
        lblSkype.Text = userPropertyComponent.UserProperty.SkypeName;
        txtTwitter.Text = userPropertyComponent.UserProperty.Twitter;
        lblAddress.Text = userPropertyComponent.UserProperty.Address;
        lblCity.Text = CountryStateCityEditMode.SelectedCityName;
        lblState.Text = CountryStateCityEditMode.SelectedStateName;
        lblCountry.Text = CountryStateCityEditMode.SelectedCountryName;
        ddlLanguage.SelectedValue = userPropertyComponent.UserProperty.Language.GetValueOrDefault(0).ToString();
        ddlWhoareYou.SelectedValue = userPropertyComponent.UserProperty.CustomerType.GetValueOrDefault(0).ToString();
        ddlSource.SelectedValue = userPropertyComponent.UserProperty.NexsoEnrolment.GetValueOrDefault(0).ToString();
        chkNotifications.Checked =
            Convert.ToBoolean(userPropertyComponent.UserProperty.AllowNexsoNotifications.GetValueOrDefault(0));
        SetChkControl("Theme", chkTheme);
        SetChkControl("Beneficiaries", chkBeneficiaries);
        SetChkControl("Sector", chkSector);

        if (userPropertyComponent.UserProperty.Twitter != string.Empty)
        {
            hlTwitter.NavigateUrl = @"http://www.twitter.com/" + userPropertyComponent.UserProperty.Twitter;
            hlTwitter.ToolTip = userPropertyComponent.UserProperty.Twitter;
            hlTwitter.Visible = true;
        }
        else
        {
            hlTwitter.Visible = false;
        }
        //lblTwitter.Text = value;

        if (userPropertyComponent.UserProperty.FaceBook != string.Empty)
        {
            hlFacebook.NavigateUrl = @"http://www.facebook.com/" + userPropertyComponent.UserProperty.FaceBook;
            hlFacebook.ToolTip = userPropertyComponent.UserProperty.FaceBook;
            hlFacebook.Visible = true;
        }
        else
        {
            hlFacebook.Visible = false;
        }
        //lblFacebook.Text = value;
        if (userPropertyComponent.UserProperty.Google != string.Empty)
        {
            hlGoogle.NavigateUrl = @"http://plus.google.com/" + userPropertyComponent.UserProperty.Google;
            hlGoogle.ToolTip = userPropertyComponent.UserProperty.Google;
            hlGoogle.Visible = true;
        }
        else
        {
            hlGoogle.Visible = false;
        }
        //lblGoogle.Text = value;

        if (userPropertyComponent.UserProperty.LinkedIn != string.Empty)
        {
            hlLinkedin.NavigateUrl = @"http://www.linkedin.com/" + userPropertyComponent.UserProperty.LinkedIn;
            hlLinkedin.ToolTip = userPropertyComponent.UserProperty.LinkedIn;
            hlLinkedin.Visible = true;
        }
        else
        {
            hlLinkedin.Visible = false;
        }
    }

    /// <summary>
    /// Return first and last name of the user
    /// </summary>
    /// <param name="propertyName"></param>
    /// <param name="value"></param>
    public void MapPropToPage(string propertyName, string value)
    {
        switch (propertyName)
        {
            case "FirstName":
                txtFirstName.Text = value;
                lblFirstName.Text = value;
                break;
            case "LastName":
                txtLastName.Text = value;
                lblLastName.Text = value;
                break;
            //case "Agreement":
            //    if (!string.IsNullOrEmpty(value))
            //    {
            //        chkTerms.Checked = true;

            //    }
            //    else
            //    {
            //        chkTerms.Checked = false;
            //    }

            //    break;
            //case "Street":
            //    txtAddress.Text = value;
            //    lblAddress.Text = value;
            //    break;
            //case "City":
            //    CountryStateCity1.SelectedCity = value;

            //    break;
            //case "Region":
            //    CountryStateCity1.SelectedState = value;

            //    break;
            //case "Country":
            //    CountryStateCity1.SelectedCountry = value;
            //    break;
            //case "PostalCode":
            //    txtPostalCode.Text = value;
            //    lblPostalCode.Text = value;
            //    break;
            //case "Telephone":
            //    txtPhone.Text = value;
            //    lblPhone.Text = value;
            //    break;
            //case "SkypeName":
            //    txtSkype.Text = value;
            //    lblSkype.Text = value;
            //    break;
            //case "Twitter":
            //    txtTwitter.Text = value;
            //    if (value != string.Empty)
            //    {
            //        imgBtnTwitter.OnClientClick = "return NavigateUrl('http://www.twitter.com/" + value + "')";
            //        imgBtnTwitter.ToolTip = value;
            //        imgBtnTwitter.Visible = true;
            //    }
            //    else
            //    {
            //        imgBtnTwitter.Visible = false;
            //    }

            //    break;
            //case "FaceBook":
            //    txtFacebook.Text = value;
            //    if (value != string.Empty)
            //    {
            //        imgBtnFaceBook.OnClientClick = "return NavigateUrl('http://www.facebook.com/" + value + "')";
            //        imgBtnFaceBook.ToolTip = value;
            //        imgBtnFaceBook.Visible = true;
            //    }
            //    else
            //    {
            //        imgBtnFaceBook.Visible = false;
            //    }

            //    break;
            //case "Google":
            //    txtGoogle.Text = value;
            //    if (value != string.Empty)
            //    {
            //        imgBtnGoogle.OnClientClick = "return NavigateUrl('http://plus.google.com/" + value + "')";
            //        imgBtnGoogle.ToolTip = value;
            //        imgBtnGoogle.Visible = true;
            //    }
            //    else
            //    {
            //        imgBtnGoogle.Visible = false;
            //    }

            //    break;
            //case "LinkedIn":
            //    txtLinkedIn.Text = value;
            //    if (value != string.Empty)
            //    {
            //        imgBtnLinkedIn.OnClientClick = "return NavigateUrl('http://www.linkedin.com/in/" + value + "')";
            //        imgBtnLinkedIn.ToolTip = value;
            //        imgBtnLinkedIn.Visible = true;
            //    }
            //    else
            //    {
            //        imgBtnLinkedIn.Visible = false;
            //    }

            //    break;
            //case "OtherSocialNetwork":

            //    break;

            default:
                break;
        }
    }
    #endregion

    #region Subclasses
    #endregion

    #region Events

    /// <summary>
    /// Verify if the action is CREATE, EDIT or VIEW
    /// </summary>
    /// <param name="e"></param>
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        LoadParams(); //load user id
        txtPassword.Attributes["value"] = txtPassword.Text;
        txtPasswordConfirmation.Attributes["value"] = txtPasswordConfirmation.Text;
        PopulateLabels();
        if (!IsPostBack)
        {
            if (userId > 0)
            {
                LoadParams();
                try
                {
                    PopulateControls();
                    if (chkTerms.Checked)
                        setControl("VIEW");
                    else
                        setControl("EDIT");

                    ViewSocialInformation.Visible = true;
                    if (UserController.GetCurrentUserInfo().IsInRole("Administrators") || userId == UserId)
                    {
                        ViewEmail.Visible = true;
                    }
                }
                catch (Exception exc)
                {
                    Exceptions.ProcessModuleLoadException(this, exc);
                }
            }
            else
            {
                PopulateControls();
                setControl("CREATE");
            }
        }
    }

    /// <summary>
    /// Enable btnEdit Profile of the chk Terms are checked
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void chkTerms_CheckedChanged(object sender, EventArgs e)
    {
        btnEditProfile.Enabled = chkTerms.Checked;
    }


    /// <summary>
    /// Load setting of the module
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
    /// Verify if textEmail exist
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void txtEmail_TextChanged(object sender, EventArgs e)
    {
        int total = 0;
        UserController.GetUsersByUserName(PortalId, txtEmail.Text, 1, 1, ref total);
        if (total > 0)
            cvExistingMail.IsValid = false;
        else
            cvExistingMail.IsValid = true;
    }

    /// <summary>
    /// Changes the view to edit mode
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnEditProfile_Click1(object sender, EventArgs e)
    {
        if (btnEditProfile.CommandArgument == "EDIT")
        {
            PopulateControls();
            setControl("EDIT");
        }
        else if (btnEditProfile.CommandArgument == "CREATE")
        {
            int userIdTmp = AddUser();

            if (userId == -1000)
            {
                userId = userIdTmp;
                SaveChkControl("Theme", chkTheme);
                Response.Redirect(NexsoHelper.GetCulturedUrlByTabName("My Nexso") + "/ui/" + userId,
                 false);
            }
            else if (userIdTmp >= 0)
            {
                userId = userIdTmp;
                SaveChkControl("Theme", chkTheme);
                Response.Redirect(NexsoHelper.GetCulturedUrlByTabName("Discover solutions"),
                 false);
            }

        }
        else if (btnEditProfile.CommandArgument == "EDITING")
        {
            btnEditProfile.CommandArgument = "EDIT";
            btnEditProfile.Text = Localization.GetString("EditProfile",
                                                         LocalResourceFile);
            UserPropertyComponent userProperty = new UserPropertyComponent(userId);
            UserInfo myDnnUser = currentUser;
            myDnnUser.Profile.InitialiseProfile(myDnnUser.PortalID);
            SaveProfile(myDnnUser);
            UserController.UpdateUser(myDnnUser.PortalID, myDnnUser);
            var sw = SaveProfile(userProperty.UserProperty);
            CountryStateCityViewMode.SelectedAddress = CountryStateCityEditMode.SelectedAddress;
            CountryStateCityViewMode.SelectedCity = CountryStateCityEditMode.SelectedCity;
            CountryStateCityViewMode.SelectedState = CountryStateCityEditMode.SelectedState;
            CountryStateCityViewMode.SelectedCountry = CountryStateCityEditMode.SelectedCountry;
            CountryStateCityViewMode.SelectedPostalCode = CountryStateCityEditMode.SelectedPostalCode;
            CountryStateCityViewMode.SelectedLongitude = CountryStateCityEditMode.SelectedLongitude;
            CountryStateCityViewMode.SelectedLatitude = CountryStateCityEditMode.SelectedLatitude;
            CountryStateCityViewMode.UpdateMap();
            if (sw >= 0)
                userProperty.Save();
            else
                return;
            SaveChkControl("Theme", chkTheme);
            SaveChkControl("Beneficiaries", chkBeneficiaries);
            SaveChkControl("Sector", chkSector);

            if (!myDnnUser.IsInRole("Registered Users"))
            {
                var oDnnRoleController = new RoleController();

                RoleInfo oCurrentRole = oDnnRoleController.GetRoleByName(this.PortalId, "Registered Users");
                oDnnRoleController.AddUserRole(this.PortalId, myDnnUser.UserID, oCurrentRole.RoleID,
                                               System.DateTime.Now.AddDays(-1),
                                               DotNetNuke.Common.Utilities.Null.NullDate);
            }

            PopulateControls();
            setControl("VIEW");
        }
    }

    /// <summary>
    /// Changes the view to view mode
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnCancelProfile_Click1(object sender, EventArgs e)
    {
        btnEditProfile.CommandArgument = "EDIT";
        btnEditProfile.Text = Localization.GetString("EditProfile",
                                                     LocalResourceFile);
        PopulateControls();
        setControl("VIEW");
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


