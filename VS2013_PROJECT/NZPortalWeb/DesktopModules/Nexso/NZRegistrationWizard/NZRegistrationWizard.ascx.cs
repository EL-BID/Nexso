using System;
using System.Threading;
using System.Linq;
using System.Web.UI.WebControls;
using DotNetNuke.Entities.Portals;
using DotNetNuke.Security.Roles;
using DotNetNuke.Common.Utilities;
using DotNetNuke.Entities.Users;
using DotNetNuke.Services.Exceptions;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Services.Localization;
using DotNetNuke.Security;
using Telerik.Web.UI;
using NexsoProBLL;
using NexsoProDAL;
using System.Net;


/// <summary>
/// This control is a Wizard for register information user
/// https://www.nexso.org/en-us/registration
/// </summary>
public partial class NZRegistrationWizard : UserUserControlBase, IActionable
{
    #region Private Member Variables
    //private Guid param;
    private int userId;
    private UserInfo currentUser = null;
    private Guid param;
    private string returnParameter;
    private string returnUrl;
    private UserPropertyComponent userPropertyComponent;

    #endregion

    #region Private Properties


    #endregion

    #region Private Methods

    /// <summary>
    /// Load query string ReturnURL (load this page when the process) and returnParameter (load this page when the process)
    /// </summary>
    private void LoadParams()
    {
        if (UserController.GetCurrentUserInfo().IsInRole("Administrators") ||
            UserController.GetCurrentUserInfo().IsInRole("NexsoSupport"))
        {
        }
        if (!string.IsNullOrEmpty(Request.QueryString["ret"]))
        {
            if (!string.IsNullOrEmpty(ValidateSecurity.ValidateString(Request.QueryString["ret"], false)))
            {
                try
                {
                    returnParameter = Request.QueryString["ret"];
                }
                catch (Exception e)
                {
                    throw;
                }
            }
            else
            {
                throw new Exception();
            }
        }
        if (!string.IsNullOrEmpty(Request.QueryString["returnurl"]))
        {
            if (!string.IsNullOrEmpty(ValidateSecurity.ValidateString(Request.QueryString["returnurl"], false)))
            {
                try
                {
                    returnUrl = Request.QueryString["returnurl"];
                }
                catch (Exception e)
                {
                    throw;
                }
            }
            else
            {
                throw new Exception();
            }
        }

        currentUser = UserController.GetCurrentUserInfo();
        userId = currentUser.UserID;
        if (userId > 0)
        {
            userPropertyComponent = new UserPropertyComponent(userId);
            if (!IsPostBack)
            {
                userPropertyComponent.UserProperty.FirstName = UserInfo.FirstName;
                userPropertyComponent.UserProperty.LastName = UserInfo.LastName;
                userPropertyComponent.UserProperty.email = UserInfo.Email;
                userPropertyComponent.Save();
            }
        }

    }
    //private void PopulateData()
    //{
    //    if (!IsPostBack)
    //    {
    //        BindData();

    //    }
    //    else
    //    {
    //        BindData();
    //    }

    //    if (UserController.GetCurrentUserInfo().IsInRole("Administrators") ||
    //                  UserController.GetCurrentUserInfo().IsInRole("NexsoSupport"))
    //    {
    //        BindData();
    //    }
    //}

    /// <summary>
    /// Obtener lista de elementos (respuesta) para los pasos 2 a 5 del asistente
    /// </summary>
    private void BindData()
    {
        var list = ListComponent.GetListPerCategory("Theme", Thread.CurrentThread.CurrentCulture.Name).ToList();

        RadListView1.DataSource = list.Where(x => !x.Key.Contains("ctm_")).ToList();
        RadListView1.DataBind();

        list = ListComponent.GetListPerCategory("Beneficiaries", Thread.CurrentThread.CurrentCulture.Name).ToList();
        RadListView2.DataSource = list;
        RadListView2.DataBind();

        list = ListComponent.GetListPerCategory("Sector", Thread.CurrentThread.CurrentCulture.Name).ToList();
        RadListView3.DataSource = list;
        RadListView3.DataBind();

        list = ListComponent.GetListPerCategory("WhoAreYou", Thread.CurrentThread.CurrentCulture.Name).ToList();
        RadListView4.DataSource = list;
        RadListView4.DataBind();

        //If users is login load the list with its answer
        if (userId >= 0)
        {
            if (!IsPostBack)
            {
                SetChkControl("Theme", RadListView1);
                SetChkControl("Beneficiaries", RadListView2);
                SetChkControl("Sector", RadListView3);
                SetChkControl("WhoAreYou", RadListView4);
                txtEmail.Text = currentUser.Email;
                txtFirstName.Text = WebUtility.HtmlDecode(currentUser.FirstName);
                txtLastName.Text = WebUtility.HtmlDecode(currentUser.LastName);
                CountryStateCityEditMode.SelectedCity = userPropertyComponent.UserProperty.City;
                CountryStateCityEditMode.SelectedCountry = userPropertyComponent.UserProperty.Country;
                CountryStateCityEditMode.SelectedState = userPropertyComponent.UserProperty.Region;
                CountryStateCityEditMode.SelectedAddress = userPropertyComponent.UserProperty.Address;
                CountryStateCityEditMode.UpdateMap();
            }
        }
        SetupWizard(Wizard1.ActiveStepIndex);

    }

    /// <summary>
    /// Get items (answer) of the registered user
    /// </summary>
    /// <param name="listName">name of the list of answer</param>
    /// <param name="checkBoxList"></param>
    private void SetChkControl(string listName, RadListView checkBoxList)
    {
        var list = UserPropertiesListComponent.GetListPerCategory(userId, listName);
        RadListViewDataItem item;
        foreach (var itemL in list)
        {
            item = checkBoxList.Items.Find(a => ((List)a.DataItem).Key == itemL.Key);
            if (item != null)
                item.Selected = true;
        }
    }

    /// <summary>
    /// Save selected answers by the user in steps 2 to 5. This occurs after clicking Finish
    /// </summary>
    /// <param name="listItem"></param>
    /// <returns></returns>
    private bool SaveRadListView(string listItem)
    {
        if (userId > 0)
        {
            if (UserPropertiesListComponent.deleteListPerCategory(userId, listItem))
            {
                switch (listItem)
                {
                    case "Theme":
                        var selected =
                            RadListView1.SelectedItems.Select(
                                item => ((Button)item.FindControl("DeselectButton1")).Text).ToList();
                        var list =
                            ListComponent.GetListPerCategory("Theme", Thread.CurrentThread.CurrentCulture.Name).ToList();


                        for (int i = 0; i < selected.Count; i++)
                        {
                            int j = 0;
                            for (j = 0; i < list.Count; j++)
                            {
                                if (selected[i] == list[j].Label)
                                {
                                    UserPropertiesListComponent sol = new UserPropertiesListComponent(userId,
                                                                                                      list[j].Key,
                                                                                                      listItem);
                                    sol.Save();
                                    break;
                                }

                            }
                            j = 0;
                        }
                        break;

                    case "Beneficiaries":
                        var selected2 =
                            RadListView2.SelectedItems.Select(
                                item => ((Button)item.FindControl("DeselectButton2")).Text).ToList();
                        var list2 =
                            ListComponent.GetListPerCategory("Beneficiaries", Thread.CurrentThread.CurrentCulture.Name)
                                         .ToList();
                        for (int i = 0; i < selected2.Count; i++)
                        {
                            int j = 0;
                            for (j = 0; i < list2.Count; j++)
                            {
                                if (selected2[i] == list2[j].Label)
                                {
                                    UserPropertiesListComponent sol = new UserPropertiesListComponent(userId,
                                                                                                      list2[j].Key,
                                                                                                      listItem);
                                    sol.Save();
                                    break;
                                }

                            }
                            j = 0;
                        }
                        break;

                    case "Sector":
                        var selected3 =
                            RadListView3.SelectedItems.Select(
                                item => ((Button)item.FindControl("DeselectButton3")).Text).ToList();
                        var list3 =
                            ListComponent.GetListPerCategory("Sector", Thread.CurrentThread.CurrentCulture.Name)
                                         .ToList();
                        for (int i = 0; i < selected3.Count; i++)
                        {
                            int j = 0;
                            for (j = 0; i < list3.Count; j++)
                            {
                                if (selected3[i] == list3[j].Label)
                                {
                                    UserPropertiesListComponent sol = new UserPropertiesListComponent(userId,
                                                                                                      list3[j].Key,
                                                                                                      listItem);
                                    sol.Save();
                                    break;
                                }

                            }
                            j = 0;
                        }
                        break;
                    case "WhoAreYou":

                        var selected4 =
                            RadListView4.SelectedItems.Select(
                                item => ((Button)item.FindControl("DeselectButton4")).Text).ToList();
                        var list4 =
                            ListComponent.GetListPerCategory("WhoAreYou", Thread.CurrentThread.CurrentCulture.Name)
                                         .ToList();
                        for (int i = 0; i < selected4.Count; i++)
                        {
                            int j = 0;
                            for (j = 0; i < list4.Count; j++)
                            {
                                if (selected4[i] == list4[j].Label)
                                {
                                    UserPropertiesListComponent sol = new UserPropertiesListComponent(userId,
                                                                                                      list4[j].Key,
                                                                                                      listItem);
                                    sol.Save();
                                    break;
                                }
                            }
                            j = 0;
                        }
                        break;
                    default:
                        break;
                }
                return true;
            }
        }
        return false;
    }

    /// <summary>
    /// Adds information to the current user. Add the user the following roles: Registered Users and NexsoUser
    /// </summary>
    /// <param name="user"></param>
    /// <returns></returns>
    private int SaveProfile(UserProperty user)
    {
        try
        {
            user.FirstName = ValidateSecurity.ValidateString(txtFirstName.Text, false);
            user.LastName = ValidateSecurity.ValidateString(txtLastName.Text, false);
            user.Address = CountryStateCityEditMode.SelectedAddress;
            user.City = CountryStateCityEditMode.SelectedCity;
            user.Region = CountryStateCityEditMode.SelectedState;
            user.Country = CountryStateCityEditMode.SelectedCountry;
            user.PostalCode = CountryStateCityEditMode.SelectedPostalCode;
            user.Longitude = CountryStateCityEditMode.SelectedLongitude;
            user.Latitude = CountryStateCityEditMode.SelectedLatitude;
            user.email = ValidateSecurity.ValidateString(txtEmail.Text, false);
            //user.Telephone = txtPhone.Text;
            //user.SkypeName = txtSkype.Text;
            //user.Twitter = txtTwitter.Text;
            //user.FaceBook = txtFacebook.Text;
            //user.Google = txtGoogle.Text;
            //user.LinkedIn = txtLinkedIn.Text;
            user.Agreement = "A001";
            //user.CustomerType = Convert.ToInt32(ddWhoareYou.SelectedValue);
            //user.NexsoEnrolment = Convert.ToInt32(ddSource.SelectedValue);
            //user.Language = Convert.ToInt32(ddLanguage.SelectedValue);
            //user.AllowNexsoNotifications = Convert.ToInt32(chkNotifications.Checked);
            if (currentUser != null)
            {
                UserInfo myDnnUser = currentUser;
                if (!myDnnUser.IsInRole("Registered Users"))
                {
                    var oDnnRoleController = new RoleController();
                    RoleInfo oCurrentRole = oDnnRoleController.GetRoleByName(this.PortalId, "Registered Users");
                    oDnnRoleController.AddUserRole(this.PortalId, myDnnUser.UserID, oCurrentRole.RoleID,
                                                   System.DateTime.Now.AddDays(-1),
                                                   DotNetNuke.Common.Utilities.Null.NullDate);
                }
                if (!myDnnUser.IsInRole("NexsoUser"))
                {
                    var oDnnRoleController = new RoleController();
                    RoleInfo oCurrentRole = oDnnRoleController.GetRoleByName(this.PortalId, "NexsoUser");
                    oDnnRoleController.AddUserRole(this.PortalId, myDnnUser.UserID, oCurrentRole.RoleID,
                                                   System.DateTime.Now.AddDays(-1),
                                                   DotNetNuke.Common.Utilities.Null.NullDate);
                }
            }
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
    /// Add user to Nexso Database (userproperties), DotNetNuke Database(dnn_user) and roles to user
    /// </summary>
    /// <returns></returns>
    private int AddUser()
    {
        try
        {
            var eventlo = new DotNetNuke.Services.Log.EventLog.EventLogController();
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
                objUser.PortalID = PortalId;
                objUser.Membership.LockedOut = true;
                if (userId == -1000)
                    objUser.Membership.Approved = true; //pero impersonation
                else
                    objUser.Membership.Approved = true; //regular creation
                DotNetNuke.Security.Membership.UserCreateStatus objCreateStatus =
                DotNetNuke.Entities.Users.UserController.CreateUser(ref objUser);
                if (objCreateStatus == DotNetNuke.Security.Membership.UserCreateStatus.Success)
                {
                    if (objUser != null)
                    {
                        CompleteUserCreation(DotNetNuke.Security.Membership.UserCreateStatus.Success, objUser, true, IsRegister);
                        UserInfo myDnnUser = objUser;
                        myDnnUser.Profile.InitialiseProfile(myDnnUser.PortalID);
                        SaveProfile(myDnnUser);
                        UserController.UpdateUser(myDnnUser.PortalID, myDnnUser);
                        UserPropertyComponent userProperty = new UserPropertyComponent(objUser.UserID);
                        if (userProperty.UserProperty != null)
                        {
                            currentUser = objUser;
                            var ret = SaveProfile(userProperty.UserProperty);
                            if (ret >= 0)
                                userProperty.Save();

                            if (!objUser.IsInRole("Registered Users"))
                            {
                                var oDnnRoleController = new RoleController();

                                RoleInfo oCurrentRole = oDnnRoleController.GetRoleByName(this.PortalId, "Registered Users");
                                oDnnRoleController.AddUserRole(this.PortalId, objUser.UserID, oCurrentRole.RoleID,
                                                               System.DateTime.Now.AddDays(-1),
                                                               DotNetNuke.Common.Utilities.Null.NullDate);
                            }
                            if (!objUser.IsInRole("NexsoUser"))
                            {
                                var oDnnRoleController = new RoleController();

                                RoleInfo oCurrentRole = oDnnRoleController.GetRoleByName(this.PortalId, "NexsoUser");
                                oDnnRoleController.AddUserRole(this.PortalId, objUser.UserID, oCurrentRole.RoleID,
                                                               System.DateTime.Now.AddDays(-1),
                                                               DotNetNuke.Common.Utilities.Null.NullDate);
                            }
                            return objUser.UserID;
                        }
                        else
                        {
                            eventlo.AddLog("NEXSO Object Null", "Trace NEXSO", PortalSettings, -1, DotNetNuke.Services.Log.EventLog.EventLogController.EventLogType.ADMIN_ALERT);

                        }
                    }
                    else
                    {
                        eventlo.AddLog("Object null cration nexso", "Trace NEXSO", PortalSettings, -1, DotNetNuke.Services.Log.EventLog.EventLogController.EventLogType.ADMIN_ALERT);

                    }
                }
                else
                {
                    //lblMessage.ErrorMessage = Localization.GetString("ExistingUser",
                    //      LocalResourceFile);
                    //lblMessage.IsValid = false;

                }
            }
            else
            {
                //lblMessage.ErrorMessage = Localization.GetString("ExistingUser",
                // LocalResourceFile);
                //lblMessage.IsValid = false;

            }
        }
        catch (Exception exc)
        //Module failed to load
        {
            Exceptions.
                ProcessModuleLoadException(
                this, exc);
        }
        return -1;
    }

    /// <summary>
    /// Verify that the name and the last name not be written to the database as meta tags
    /// </summary>
    /// <param name="user"></param>
    private void SaveProfile(UserInfo user)
    {
        user.Profile.SetProfileProperty("FirstName", ValidateSecurity.ValidateString(txtFirstName.Text, false));
        user.Profile.SetProfileProperty("LastName", ValidateSecurity.ValidateString(txtLastName.Text, false));
    }

    /// <summary>
    /// Load error messages and validation messages
    /// </summary>
    private void PopulateLabels()
    {
        rgvtxtFirstName.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
        rgvtxtLastName.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
        rgvEmail.ErrorMessage = Localization.GetString("InvalidEmail", LocalResourceFile);
        rgvPassword.ErrorMessage = Localization.GetString("InvalidPassword", LocalResourceFile);
        rvEmail.Text = Localization.GetString("rfvtxtEmail", LocalResourceFile);
        rvFirstName.Text = Localization.GetString("rfvtxtFirstName", LocalResourceFile);
        rvLastName.Text = Localization.GetString("rfvtxtLastName", LocalResourceFile);
        rvPassword.Text = Localization.GetString("rfvtxtPassword", LocalResourceFile);
        //If the user is registered and log in
        if (userId >= 0 && !string.IsNullOrEmpty(userPropertyComponent.UserProperty.Agreement))
        {
            lblIntroductionTitle.Text = Localization.GetString("IntroductionTitleAlt", LocalResourceFile);
            lblStep0Title.Text = Localization.GetString("Step0TitleAlt", LocalResourceFile);
            fsExistingUser.Visible = true;
        }
        else
        {
            if (userId > 0)
            {
                pnlPassword.Visible = false;
                txtEmail.Enabled = false;
            }
            //If the user is not registered
            lblIntroductionTitle.Text = Localization.GetString("IntroductionTitle", LocalResourceFile);
            lblStep0Title.Text = Localization.GetString("Step0Title", LocalResourceFile);
            fsCreateUser.Visible = true;
        }
        string urlBase = Request.Url.AbsoluteUri.Replace(Request.Url.PathAndQuery, "") + ControlPath;
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

    /// <summary>
    /// Load text for the buttons and the  titles of the steps of the wizard
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
        Wizard1.StartNextButtonText = Localization.GetString("Start",
                                                             LocalResourceFile);
        Wizard1.FinishPreviousButtonText = Localization.GetString("Previous",
                                                                  LocalResourceFile);
        Wizard1.StepNextButtonText = Localization.GetString("Next",
                                                            LocalResourceFile);
        Wizard1.StepPreviousButtonText = Localization.GetString("Previous",
                                                                LocalResourceFile);
        Wizard1.FinishCompleteButtonText = Localization.GetString("Finish",
                                                                  LocalResourceFile);
        Wizard1.CancelButtonText = Localization.GetString("Cancel",
                                                          LocalResourceFile);
        WizardStep0.Title = Localization.GetString("Step0",
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
        Wizard1.ActiveStepIndex = step ?? default(int);
    }

    /// <summary>
    /// Load different javascript for the process of registration
    /// </summary>
    private void RegisterScripts()
    {
        Page.ClientScript.RegisterClientScriptInclude(
             this.GetType(), "NZRegistrationWizard", ControlPath + "js/NZRegistrationWizard.js");
        string script = "<script>" +
             "var chkTerms = '" + chkTerms.ClientID + "';"
            + "var rfvTermsValidator = '" + rfvTermsValidator.ClientID + "';"
        + "</script>";
        Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Script22", script);
    }

    #endregion

    #region Constructors



    #endregion

    #region Public Properties

    public string ReturnParameter
    {
        get { return returnParameter; }
        set { returnParameter = value; }
    }
    public string ReturnUrl
    {
        get { return returnUrl; }
        set { returnUrl = value; }
    }
    public Guid Param
    {
        get { return param; }
        set { param = value; }
    }
    #endregion

    #region Public Methods



    #endregion

    #region Subclasses



    #endregion

    #region Events
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

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        LoadParams(); //load user id
        //PopulateData();
        txtPassword.Attributes["value"] = txtPassword.Text;
        if (!IsPostBack)
        {
            PopulateLabels();
            RegisterScripts();
        }
        BindData();
    }

    private void InitializeComponent()
    {
        this.Load += new System.EventHandler(this.Page_Load);
    }

    /// <summary>
    /// Load Items for the sidebar
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Wizard1_PreRender(object sender, EventArgs e)
    {
        Repeater SideBarList = Wizard1.FindControl("HeaderContainer").FindControl("SideBarList") as Repeater;
        SideBarList.DataSource = Wizard1.WizardSteps;
        SideBarList.DataBind();
    }

    private void Page_Load(object sender, System.EventArgs e)
    {
        Wizard1.PreRender += new EventHandler(Wizard1_PreRender);
    }

    /// <summary>
    /// This Command is actívate when one ítems is selected or deselected
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void abc_ItemCommand(object sender, RadListViewCommandEventArgs e)
    {
        if (e.CommandName.Equals("Deselect"))
        {
            var item = e.ListViewItem;
            var selectbutton = (LinkButton)item.FindControl("SelectButton");
        }
        else if (e.CommandName.Equals("Select"))
        {
            var item = e.ListViewItem;
            var selectbutton = (LinkButton)item.FindControl("SelectButton");
        }
    }

    protected void Wizard1_NextButtonClick(object sender, WizardNavigationEventArgs e)
    {
        switch (e.NextStepIndex)
        {
            case 1:
                break;

            case 2:
                if (RadListView1.SelectedItems.Count == 0)
                {
                    //Activate the validator if not selected any item
                    rfvTheme.IsValid = false;
                    e.Cancel = true;
                }
                else
                {
                    //Save the items list
                    SaveRadListView("Theme");
                    rfvTheme.IsValid = true;
                }
                break;

            case 3:
                if (RadListView2.SelectedItems.Count == 0)
                {
                    //Activate the validator if not selected any item
                    rfvBeneficiaries.IsValid = false;
                    e.Cancel = true;
                }
                else
                {
                    //Save the items list
                    SaveRadListView("Beneficiaries");            
                    rfvBeneficiaries.IsValid = true;
                }


                break;
            case 4:
                if (RadListView3.SelectedItems.Count == 0)
                {
                    //Activate the validator if not selected any item
                    rfvSector.IsValid = false;
                    e.Cancel = true;
                }
                else
                {
                    //Save the items list
                    SaveRadListView("Sector");
                    rfvSector.IsValid = true;
                }


                break;
            case 5:
                if (RadListView4.SelectedItems.Count == 0)
                {
                    //Activate the validator if not selected any item
                    rfvWhoAreYou.IsValid = false;
                    e.Cancel = true;
                }
                else
                {
                    //Save the items list
                    SaveRadListView("WhoAreYou");
                    rfvWhoAreYou.IsValid = true;
                }
                CountryStateCityEditMode.ViewInEditMode = true;
                CountryStateCityEditMode.DataBind();
                break;

            case 6:

                if (CountryStateCityEditMode.SelectedCity == "")
                {
                    //     Message5.Visible = true;
                    //    Message5.Text = Localization.GetString("Message5", LocalResourceFile);
                    //Activate the validator if not selected any item
                    rfvAddress.IsValid = false;
                    e.Cancel = true;
                }
                else
                    if (CountryStateCityEditMode.SelectedAddress == "")
                {
                    //  //  Message5.Visible = true;
                    // //   Message5.Text = Localization.GetString("Message55", LocalResourceFile);
                    //Activate the validator if not selected any item
                    rfvAddress.IsValid = false;
                    e.Cancel = true;
                }
                //else
                //{
                //  //  Message5.Visible = false;
                //}
                break;
        }
    }

    //protected void txtEmail_TextChanged(object sender, EventArgs e)
    //{
    //    int total = 0;
    //    UserController.GetUsersByUserName(PortalId, txtEmail.Text, 1, 1, ref total);
    //    if (total > 0)
    //        cvExistingMail.IsValid = false;
    //    else
    //        cvExistingMail.IsValid = true;
    //}
    protected void Wizard1_FinishButtonClick(object sender, WizardNavigationEventArgs e)
    {
        if (userId < 0)
        {
            userId = AddUser();
            if (userId >= 0)
            {
                rfvExistingMail.IsValid = true;
                SaveRadListView("Theme");
                SaveRadListView("Beneficiaries");
                SaveRadListView("WhoAreYou");
                SaveRadListView("Sector");
            }
            else
            {
                rfvExistingMail.IsValid = false;
                return;
            }
        }
        else
        {
            SaveProfile(userPropertyComponent.UserProperty);
            userPropertyComponent.Save();
        }

        if (!string.IsNullOrEmpty(returnParameter))
            Response.Redirect(NexsoHelper.GetCulturedUrlByTabName(returnParameter), false);
        else
        {
            if (!string.IsNullOrEmpty(returnUrl))
                Response.Redirect(returnUrl, false);
            else
                Response.Redirect(NexsoHelper.GetCulturedUrlByTabName("Explore"), false);
        }
    }

    /// <summary>
    /// Load the previous page
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="args"></param>
    protected void Wizard1_PreviousButtonClick(object sender, EventArgs args)
    {
        WizardNavigationEventArgs e = (WizardNavigationEventArgs)args;
        if (e.CurrentStepIndex > 0)
        {
            switch (e.CurrentStepIndex)
            {
                case 0:
                    //Message1.Visible = false;
                    break;
                case 1:
                    Wizard1.ActiveStepIndex = 0;
                    //   Message2.Visible = false;
                    break;
                case 2:
                    Wizard1.ActiveStepIndex = 1;
                    //  Message3.Visible = false;
                    break;
                case 3:
                    Wizard1.ActiveStepIndex = 2;
                    // Message4.Visible = false;
                    break;
                case 4:
                    Wizard1.ActiveStepIndex = 3;
                    //  Message5.Visible = false;
                    break;
                case 5:
                    Wizard1.ActiveStepIndex = 4;
                    break;
                case 6: Wizard1.ActiveStepIndex = 5; break;
                default: e.Cancel = true; break;
            }
        }
    }

    #endregion

    #region Optional Interfaces
    public ModuleActionCollection ModuleActions
    {
        get
        {
            ModuleActionCollection Actions = new ModuleActionCollection();
            Actions.Add(GetNextActionID(), Localization.GetString("EditModule", this.LocalResourceFile), "", "", "",
                        EditUrl(), false, SecurityAccessLevel.Edit, true, false);
            return Actions;
        }
    }
    #endregion
}