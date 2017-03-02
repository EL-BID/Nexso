using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Runtime.Serialization.Json;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Services.Localization;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Security;
using DotNetNuke.Entities.Users;
using DotNetNuke.Common.Utilities;
using DotNetNuke.Services.Exceptions;
using DotNetNuke.Entities.Portals;
using DotNetNuke.Security.Roles;
using Telerik.Web.UI;
using NexsoProDAL;
using NexsoProBLL;
using MIFWebServices;
using System.Web.Security;

/// <summary>
/// BACKEND 
/// This control is for user gestion  (Existing User)
/// When user is administration, the sistem don`t permite changes password.
/// Only Adminsitration would changes your password
/// https://www.nexso.org/en-us/Backend/Users
/// </summary>
public partial class NZManageUsers : UserUserControlBase, IActionable
{
    #region Public Member Variables
    public UserPropertyComponent userPropertyComponent;
    public bool ExistEmail = false;
    #endregion

    #region Private Member Variables
    private DotNetNuke.Entities.Users.UserInfo currentUser = null;
    #endregion

    #region Private Properties


    #endregion

    #region Private Methods
    private bool SaveChkControl(string listItem, RadComboBox radComboBoxList, int UserId)
    {
        if (UserPropertiesListComponent.deleteListPerCategory(UserId, listItem))
        {
            //string result = string.Empty;
            foreach (RadComboBoxItem item in radComboBoxList.Items)
            {
                if (item.Checked)
                {

                    UserPropertiesListComponent sol = new UserPropertiesListComponent(UserId, item.Value, listItem);
                    sol.Save();

                }
            }
            return true;
        }
        return false;
    }
    #endregion

    #region Public Properties



    #endregion

    #region Public Methods
    /// <summary>
    /// Get all users in Database
    /// </summary>
    public void DataBind()
    {
        MIFNEXSOEntities nx = new MIFNEXSOEntities();

        grdManageUsers.DataSource = nx.UserProperties;

    }
    public bool MessageExistEmail()
    {
        return ExistEmail;

    }
    public string InvalidEmail()
    {
        return Localization.GetString("InvalidEmail", LocalResourceFile);

    }
    public string InvalidPassword()
    {
        return Localization.GetString("InvalidPassword", LocalResourceFile);

    }

    /// <summary>
    /// Get all countries around the world
    /// </summary>
    /// <returns></returns>
    public List<Country> BindCountry()
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
            country.country = Localization.GetString("NoFilter", this.LocalResourceFile);
            photos.Insert(0, country);
            country = new Country();
            country.code = string.Empty;
            country.country = "Empty";
            photos.Insert(1, country);
            return photos;
        }
        catch (Exception x)
        {
            return null;
        }

    }
    #endregion

    #region Protected Methods
    protected string GetNexsoLocation(string country, string region, string city)
    {

        string return_ = string.Empty;
        try
        {
            if (!string.IsNullOrEmpty(country))
            {

                return_ = return_ + MIFWebServices.LocationService.GetCountryName(country);

                if (string.IsNullOrEmpty(return_))
                    return_ = return_ + country.ToUpper();
            }
            else
            {
                return_ = return_ + " empty ";
            }
            if (!String.IsNullOrEmpty(region))
            {
                try
                {
                    return_ = return_ + " " + MIFWebServices.LocationService.GetStateName(Convert.ToInt32(region));

                }
                catch (Exception)
                {

                    return_ = return_ + " " + region;
                }
            }
            else
            {
                return_ = return_ + " empty ";
            }

            if (!String.IsNullOrEmpty(city))
            {
                try
                {
                    return_ = return_ + " " + MIFWebServices.LocationService.GetCityName(Convert.ToInt32(city));

                }
                catch (Exception)
                {

                    return_ = return_ + " " + city;
                }
            }
            else
            {
                return_ = return_ + " empty ";
            }
        }
        catch (Exception e)
        {
            return_ = " empty error";
        }
        return return_;
    }

    #endregion

    #region Subclasses



    #endregion

    #region Events

    /// <summary>
    /// Verify if the current user is administrator
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Page_Load(object sender, EventArgs e)
    {
        if (UserController.GetCurrentUserInfo().IsInRole("Administrators"))
        {
            btnUpdateBatch.Visible = true;
        }
        else
        {
            btnUpdateBatch.Visible = false;
        }
        if (!IsPostBack)
        {
            if (!UserController.GetCurrentUserInfo().IsInRole("Administrators") && !UserController.GetCurrentUserInfo().IsInRole("NexsoSupport"))
            {
                Exceptions.ProcessModuleLoadException(this, new Exception("UserID: " + UserController.GetCurrentUserInfo().UserID + " - Email: " + UserController.GetCurrentUserInfo().Email + " - " + DateTime.Now + " - Security Issue"));
                Response.Redirect("/error/403.html");
            }
        }
    }

    /// <summary>
    /// Bind all data in grid
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RadGrid1_NeedDataSource(object sender, GridNeedDataSourceEventArgs e)
    {
        DataBind();
    }

    /// <summary>
    /// Update information of the user (if user is administrator is not possible change the password)
    /// This Method also update the user information in DNN
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RadGrid1_UpdateCommand(object sender, GridCommandEventArgs e)
    {
        if (e.CommandName == RadGrid.UpdateCommandName)
        {
            if (e.Item is GridEditableItem)
            {
                GridEditableItem editItem = (GridEditableItem)e.Item;
                TextBox txtUserId = (TextBox)editItem.FindControl("txtUserId");
                int userId;
                if (txtUserId.Text == string.Empty)
                    userId = 0;
                else
                    userId = Convert.ToInt32(txtUserId.Text);

                // Get controls
                RadTextBox txtEmail = (RadTextBox)editItem.FindControl("txtEmail");
                RadTextBox txtFirstName = (RadTextBox)editItem.FindControl("txtFirstName");
                RadTextBox txtLastName = (RadTextBox)editItem.FindControl("txtLastName");
                RadTextBox txtPhone = (RadTextBox)editItem.FindControl("txtTelephone");
                RadTextBox txtAddress = (RadTextBox)editItem.FindControl("txtAddress");
                RadTextBox txtLinkedIn = (RadTextBox)editItem.FindControl("txtLinkedIn");
                RadTextBox txtGoogle = (RadTextBox)editItem.FindControl("txtGoogle");
                RadTextBox txtTwitter = (RadTextBox)editItem.FindControl("txtTwitter");
                RadTextBox txtFacebook = (RadTextBox)editItem.FindControl("txtFacebook");
                RadTextBox txtSkype = (RadTextBox)editItem.FindControl("txtSkypeName");
                RadComboBox ddLanguage = (RadComboBox)editItem.FindControl("ddLanguage");
                RadComboBox ddCustomerType = (RadComboBox)editItem.FindControl("ddCustomerType");
                RadComboBox ddNexsoEnrolment = (RadComboBox)editItem.FindControl("ddNexsoEnrolment");
                RadComboBox ddUserTheme = (RadComboBox)editItem.FindControl("ddUserTheme");
                RadComboBox ddUserBeneficiaries = (RadComboBox)editItem.FindControl("ddUserBeneficiaries");
                RadComboBox ddUserSector = (RadComboBox)editItem.FindControl("ddUserSector");
                RadTextBox txtOtherSocialNetwork = (RadTextBox)editItem.FindControl("txtOtherSocialNetwork");
                CheckBox chkNotifications = (CheckBox)editItem.FindControl("chkNotifications");
                RadTextBox txtPassword = (RadTextBox)editItem.FindControl("txtPassword");
                if (userId == 0)
                {
                    if (txtEmail.Text != string.Empty)
                    {
                        int totalUsers = 0;
                        UserController.GetUsersByUserName(PortalId, txtEmail.Text, 1, 1, ref totalUsers);
                        if (totalUsers == 0)
                        {
                            //Update DNN Information
                            var objUser = new DotNetNuke.Entities.Users.UserInfo();
                            objUser.AffiliateID = Null.NullInteger;
                            objUser.Email = txtEmail.Text;
                            objUser.FirstName = txtFirstName.Text;
                            objUser.IsSuperUser = false;
                            objUser.LastName = txtLastName.Text;
                            objUser.PortalID = PortalController.GetCurrentPortalSettings().PortalId;
                            objUser.Username = txtEmail.Text;
                            objUser.DisplayName = txtFirstName.Text + " " + txtLastName.Text;
                            objUser.Membership.LockedOut = false;
                            objUser.Membership.Password = txtPassword.Text;
                            objUser.Membership.Email = objUser.Email;
                            objUser.Membership.Username = objUser.Username;
                            objUser.Membership.UpdatePassword = false;
                            objUser.Membership.LockedOut = false;
                            objUser.Membership.Approved = true;
                            DotNetNuke.Security.Membership.UserCreateStatus objCreateStatus =
                             DotNetNuke.Entities.Users.UserController.CreateUser(ref objUser);
                            if (objCreateStatus == DotNetNuke.Security.Membership.UserCreateStatus.Success)
                            {
                                UserInfo myDnnUser = objUser;
                                myDnnUser.Profile.InitialiseProfile(myDnnUser.PortalID);
                                myDnnUser.Profile.SetProfileProperty("FirstName", txtFirstName.Text);
                                myDnnUser.Profile.SetProfileProperty("LastName", txtLastName.Text);
                                UserController.UpdateUser(myDnnUser.PortalID, myDnnUser);
                                //Update Nexso information
                                userPropertyComponent = new UserPropertyComponent(objUser.UserID);
                                //Update DNN roles
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
                                ExistEmail = false;
                            }
                            else
                            {
                                ExistEmail = true;
                                return;
                            }
                        }
                        else
                        {
                            ExistEmail = true;
                            return;
                        }
                    }
                    else
                        return;
                }
                else
                {
                    userPropertyComponent = new UserPropertyComponent(userId);
                    if (txtEmail.Text != string.Empty)
                    {
                        UserInfo myDnnUser = DotNetNuke.Entities.Users.UserController.GetUser(PortalSettings.PortalId, userId, true);
                        myDnnUser.Profile.InitialiseProfile(myDnnUser.PortalID);
                        myDnnUser.Profile.SetProfileProperty("FirstName", txtFirstName.Text);
                        myDnnUser.Profile.SetProfileProperty("LastName", txtLastName.Text);

                        if (!myDnnUser.IsInRole("Administrators"))
                        {
                            if (txtPassword.Text != string.Empty)
                            {
                                MembershipUser usr = Membership.GetUser(myDnnUser.Username, false);
                                if(usr.IsLockedOut ==true)
                                {
                                    usr.UnlockUser();
                                }
                                string resetPassword = usr.ResetPassword();
                                bool sw = usr.ChangePassword(resetPassword, txtPassword.Text);
                            }
                        }
                        // myDnnUser.Profile.SetProfileProperty("Password", txtPassword.Text);
                        UserController.UpdateUser(myDnnUser.PortalID, myDnnUser);
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
                userPropertyComponent.UserProperty.FirstName = txtFirstName.Text;
                userPropertyComponent.UserProperty.LastName = txtLastName.Text;
                userPropertyComponent.UserProperty.Telephone = txtPhone.Text;
                userPropertyComponent.UserProperty.email = txtEmail.Text;
                userPropertyComponent.UserProperty.SkypeName = txtSkype.Text;
                userPropertyComponent.UserProperty.Twitter = txtTwitter.Text;
                userPropertyComponent.UserProperty.FaceBook = txtFacebook.Text;
                userPropertyComponent.UserProperty.Google = txtGoogle.Text;
                userPropertyComponent.UserProperty.LinkedIn = txtLinkedIn.Text;
                userPropertyComponent.UserProperty.Address = txtAddress.Text;
                userPropertyComponent.UserProperty.Agreement = "A001";
                userPropertyComponent.UserProperty.AllowNexsoNotifications = Convert.ToInt32(chkNotifications.Checked);

                if (ddCustomerType.SelectedValue != string.Empty)
                    userPropertyComponent.UserProperty.CustomerType = Convert.ToInt32(ddCustomerType.SelectedValue);
                if (ddNexsoEnrolment.SelectedValue != string.Empty)
                    userPropertyComponent.UserProperty.NexsoEnrolment = Convert.ToInt32(ddNexsoEnrolment.SelectedValue);
                if (ddLanguage.SelectedValue != string.Empty)
                    userPropertyComponent.UserProperty.Language = Convert.ToInt32(ddLanguage.SelectedValue);

                if (userPropertyComponent.Save() > 0)
                {
                    SaveChkControl("Theme", ddUserTheme, userPropertyComponent.UserProperty.UserId);
                    SaveChkControl("Beneficiaries", ddUserBeneficiaries, userPropertyComponent.UserProperty.UserId);
                    SaveChkControl("Sector", ddUserSector, userPropertyComponent.UserProperty.UserId);
                }
                if (editItem.ItemIndex != -1)
                    this.grdManageUsers.MasterTableView.Items[editItem.ItemIndex].Edit = false;
                else
                    e.Item.OwnerTableView.IsItemInserted = false;

                this.grdManageUsers.MasterTableView.Rebind();
            }
        }
    }

    /// <summary>
    /// Load the information of the selected user to edit (edit button) in controls
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RadGrid1_ItemDataBound(object sender, Telerik.Web.UI.GridItemEventArgs e)
    {
        if (e.Item is GridEditFormItem && e.Item.IsInEditMode)
        {
            GridEditFormItem edititem = (GridEditFormItem)e.Item;

            RadComboBox ddLanguage = (RadComboBox)edititem.FindControl("ddLanguage");
            var list = ListComponent.GetListPerCategory("Language", Thread.CurrentThread.CurrentCulture.Name).ToList();
            ddLanguage.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
            ddLanguage.DataSource = list;
            ddLanguage.DataBind();

            RadComboBox ddCustomerType = (RadComboBox)edititem.FindControl("ddCustomerType");
            list = ListComponent.GetListPerCategory("WhoAreYou", Thread.CurrentThread.CurrentCulture.Name).ToList();
            ddCustomerType.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
            ddCustomerType.DataSource = list;
            ddCustomerType.DataBind();

            RadComboBox ddNexsoEnrolment = (RadComboBox)edititem.FindControl("ddNexsoEnrolment");
            list = ListComponent.GetListPerCategory("Source", Thread.CurrentThread.CurrentCulture.Name).ToList();
            ddNexsoEnrolment.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
            ddNexsoEnrolment.DataSource = list;
            ddNexsoEnrolment.DataBind();

            RadComboBox ddUserTheme = (RadComboBox)edititem.FindControl("ddUserTheme");
            list = ListComponent.GetListPerCategory("Theme", Thread.CurrentThread.CurrentCulture.Name).ToList();
            ddUserTheme.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
            ddUserTheme.DataSource = list;
            ddUserTheme.DataBind();

            RadComboBox ddUserBeneficiaries = (RadComboBox)edititem.FindControl("ddUserBeneficiaries");
            list = ListComponent.GetListPerCategory("Beneficiaries", Thread.CurrentThread.CurrentCulture.Name).ToList();
            ddUserBeneficiaries.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
            ddUserBeneficiaries.DataSource = list;
            ddUserBeneficiaries.DataBind();

            RadComboBox ddUserSector = (RadComboBox)edititem.FindControl("ddUserSector");
            list = ListComponent.GetListPerCategory("Sector", Thread.CurrentThread.CurrentCulture.Name).ToList();
            ddUserSector.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
            ddUserSector.DataSource = list;
            ddUserSector.DataBind();

            if (!(e.Item is GridEditFormInsertItem))
            {
                try
                {
                    int UserId = Convert.ToInt32(DataBinder.Eval(e.Item.DataItem, "UserId"));
                    currentUser = DotNetNuke.Entities.Users.UserController.GetUser(PortalSettings.PortalId, UserId, true);
                    RadTextBox txtEmail = (RadTextBox)edititem.FindControl("txtEmail");
                    txtEmail.Text = currentUser.Email;
                    var list2 = UserPropertiesListComponent.GetListPerCategory(UserId, "Theme");
                    foreach (var itemL in list2)
                    {
                        var itemm = (RadComboBoxItem)ddUserTheme.Items.FindItemByValue(itemL.Key);

                        if (itemm != null)
                            itemm.Checked = true;
                    }
                    list2 = UserPropertiesListComponent.GetListPerCategory(UserId, "Beneficiaries");
                    foreach (var itemL in list2)
                    {
                        var itemm = (RadComboBoxItem)ddUserBeneficiaries.Items.FindItemByValue(itemL.Key);

                        if (itemm != null)
                            itemm.Checked = true;
                    }
                    list2 = UserPropertiesListComponent.GetListPerCategory(UserId, "Sector");
                    foreach (var itemL in list2)
                    {
                        var itemm = (RadComboBoxItem)ddUserSector.Items.FindItemByValue(itemL.Key);
                        if (itemm != null)
                            itemm.Checked = true;
                    }

                    if (DataBinder.Eval(e.Item.DataItem, "AllowNexsoNotifications") != null)
                    {
                        int AllowNexsoNotifications = Convert.ToInt32(DataBinder.Eval(e.Item.DataItem, "AllowNexsoNotifications"));
                        CheckBox chkNotifications = (CheckBox)edititem.FindControl("chkNotifications");
                        chkNotifications.Checked = Convert.ToBoolean(AllowNexsoNotifications);
                    }

                    if (DataBinder.Eval(e.Item.DataItem, "Language") != null)
                        ddLanguage.SelectedValue = DataBinder.Eval(e.Item.DataItem, "Language").ToString();

                    if (DataBinder.Eval(e.Item.DataItem, "CustomerType") != null)
                    {
                        RadComboBoxItem itemCustomerType = ddCustomerType.Items.FindItemByValue(DataBinder.Eval(e.Item.DataItem, "CustomerType").ToString());
                        if (itemCustomerType != null)
                            ddCustomerType.SelectedValue = DataBinder.Eval(e.Item.DataItem, "NexsoEnrolment").ToString();
                    }

                    if (DataBinder.Eval(e.Item.DataItem, "NexsoEnrolment") != null)
                    {
                        RadComboBoxItem itemNexsoEnrolment = ddNexsoEnrolment.Items.FindItemByValue(DataBinder.Eval(e.Item.DataItem, "NexsoEnrolment").ToString());
                        if (itemNexsoEnrolment != null)
                            ddNexsoEnrolment.SelectedValue = DataBinder.Eval(e.Item.DataItem, "NexsoEnrolment").ToString();
                    }
                }
                catch
                {
                }
                //Hide Password in editing mode
                RadTextBox txtEmail2 = (RadTextBox)edititem.FindControl("txtEmail");
                txtEmail2.Enabled = false;
                RequiredFieldValidator rfvEmail = (RequiredFieldValidator)edititem.FindControl("rfvEmail");
                rfvEmail.Visible = false;
                rfvEmail.ValidationGroup = string.Empty;
                RequiredFieldValidator rvPassword = (RequiredFieldValidator)edititem.FindControl("rvPassword");
                rvPassword.Visible = false;
                rvPassword.ValidationGroup = string.Empty;
            }
        }
    }

    /// <summary>
    /// Update current user. Only available for administrators
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnUpdateBatch_Click(object sender, EventArgs e)
    {
        MIFNEXSOEntities nx = new MIFNEXSOEntities();
        foreach (var user in nx.UserProperties)
        {
            var userDNN = UserController.GetUserById(PortalId, user.UserId);
            if (userDNN != null)
            {
                user.email = userDNN.Email;
            }
        }
        nx.SaveChanges();
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