using System;
using System.Data;
using System.Data.OleDb;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading;
using System.Runtime.Serialization.Json;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Services.Localization;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Security;
using Telerik.Web.UI;
using NexsoProDAL;
using NexsoProBLL;
using System.Net;
using DotNetNuke.Services.Exceptions;
using DotNetNuke.Entities.Users;


/// <summary>
/// BACKEND = Potential User
/// this control register potential user one of one, but permit load archive excel.
/// https://www.nexso.org/en-us/Backend/PotentialUsers
/// </summary>
public partial class NZPotentialUsers : UserUserControlBase, IActionable
{
    #region Public Member Variables
    public PotentialUserComponent potentialUserComponent;
    public bool ExistEmail = false;
    public bool NewOragnizationType = false;
    public MIFNEXSOEntities GetPotentialUsers = new MIFNEXSOEntities();
    #endregion
    #region Private Member Variables
    private string gridMessage = null;
    #endregion

    #region Private Properties


    #endregion

    #region Private Methods
    private void DisplayMessage(string text)
    {
        grdPreUsers.Controls.Add(new LiteralControl(string.Format("<span style='color:red'>{0}</span>", text)));
    }

    private void SetMessage(string message)
    {
        gridMessage = message;
    }
    #endregion

    #region Public Properties



    #endregion

    #region Public Methods

    /// <summary>
    /// Get all potential user
    /// </summary>
    public void DataBind()
    {
        //var query = GetPotentialUsers.PotentialUsers.OrderBy(a => a.FirstName).Where(x=>x.Deleted==null||x.Deleted==false);
        var query = PotentialUserComponent.GetPotentialUsers().OrderBy(x => x.FirstName).Where(x => x.Deleted == null || x.Deleted == false);
        grdPreUsers.DataSource = query;
    }

    /// <summary>
    /// Get all countries around the world
    /// </summary>
    /// <returns></returns>
    public void fillCountries(RadComboBox ddCountry)
    {
        try
        {
            string WURL = System.Configuration.ConfigurationManager.AppSettings["MifWebServiceUrl"].ToString();
            string url = WURL + "/countries?id=borrowers";
            WebRequest request = WebRequest.Create(url);
            WebResponse ws = request.GetResponse();
            DataContractJsonSerializer jsonSerializer = new DataContractJsonSerializer(typeof(List<Country>));
            List<Country> photos = (List<Country>)jsonSerializer.ReadObject(ws.GetResponseStream());
            ddCountry.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
            ddCountry.DataSource = photos;
            ddCountry.DataBind();
        }
        catch (Exception e)
        {

        }
    }
    public bool MessageExistEmail()
    {
        return ExistEmail;

    }

    /// <summary>
    /// Configure export to excel
    /// </summary>
    public void ConfigureExport()
    {

        grdPreUsers.ExportSettings.ExportOnlyData = true;
        grdPreUsers.ExportSettings.IgnorePaging = true;
        grdPreUsers.ExportSettings.OpenInNewWindow = true;
        grdPreUsers.ExportSettings.UseItemStyles = true;
        grdPreUsers.ExportSettings.FileName = string.Format("ReportPotentialUsers_{0}", DateTime.Now);


    }
    #endregion

    #region Protected Methods


    #endregion

    #region Subclasses
    public class Country
    {
        public string country { get; set; }
        public string code { get; set; }

    }

    #endregion

    #region Events
    /// <summary>
    /// Verify if the current user is administrator
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
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
    /// Upload Excel file
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void aUploadFile_FileUploaded(object sender, Telerik.Web.UI.FileUploadedEventArgs e)
    {
        try
        {
            int counter = 0;
            int counterSuccess = 0;
            int counterRepeat = 0;

            if (aUploadFile.UploadedFiles.Count > 0)
            {
                string FileName = Path.GetFileName(aUploadFile.UploadedFiles[0].FileName);
                string extensionName = Path.GetExtension(aUploadFile.UploadedFiles[0].FileName);
                FileName = Guid.NewGuid().ToString();
                aUploadFile.UploadedFiles[0].SaveAs(
                    Server.MapPath(PortalSettings.HomeDirectory + "tmpfiles/" + FileName + extensionName));


                string connString = "";
                string strFileType = extensionName.ToLower();
                string path = Server.MapPath(PortalSettings.HomeDirectory + "tmpfiles/" + FileName + extensionName);
                //Connection String to Excel Workbook
                if (strFileType.Trim() == ".xls")
                {
                    connString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + path +
                                 ";Extended Properties=\"Excel 8.0;HDR=Yes;IMEX=2\"";
                }
                else if (strFileType.Trim() == ".xlsx")
                {
                    connString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + path +
                                 ";Extended Properties=\"Excel 12.0;HDR=Yes;IMEX=2\"";
                }
                string query = "SELECT *  FROM [Sheet1$]";
                OleDbConnection conn = new OleDbConnection(connString);
                if (conn.State == ConnectionState.Closed)
                    conn.Open();
                OleDbCommand cmd = new OleDbCommand(query, conn);
                OleDbDataAdapter da = new OleDbDataAdapter(cmd);


                DataSet ds = new DataSet();


                da.Fill(ds);

                // List<PotentialUser> potentialUsers=new List<PotentialUser>();
                PotentialUserComponent tmpPotentialUser;
                long batch = DateTime.Now.Ticks;
                foreach (DataRow dr in ds.Tables[0].Rows)
                {
                    counter++;
                    if (ds.Tables[0].Columns.Contains("Email"))
                    {
                        if (!string.IsNullOrEmpty(dr["Email"].ToString().Replace(" ", "")))
                        {
                            tmpPotentialUser = new PotentialUserComponent(dr["Email"].ToString().Replace(" ", ""));
                            if (tmpPotentialUser.PotentialUser.PotentialUserId == Guid.Empty)
                            {
                                tmpPotentialUser.PotentialUser.Created = DateTime.Now;
                                tmpPotentialUser.PotentialUser.Updated = tmpPotentialUser.PotentialUser.Created;
                                tmpPotentialUser.PotentialUser.Deleted = false;
                            }
                            tmpPotentialUser.PotentialUser.Updated = DateTime.Now;
                            tmpPotentialUser.PotentialUser.Batch = batch.ToString();

                            if (ds.Tables[0].Columns.Contains("FirstName"))
                                tmpPotentialUser.PotentialUser.FirstName = dr["FirstName"].ToString();
                            if (ds.Tables[0].Columns.Contains("LastName"))
                                tmpPotentialUser.PotentialUser.LastName = dr["LastName"].ToString();
                            if (ds.Tables[0].Columns.Contains("MiddleName"))
                                tmpPotentialUser.PotentialUser.MiddleName = dr["MiddleName"].ToString();
                            if (ds.Tables[0].Columns.Contains("Phone"))
                                tmpPotentialUser.PotentialUser.Phone = dr["Phone"].ToString();
                            if (ds.Tables[0].Columns.Contains("Address"))
                                tmpPotentialUser.PotentialUser.Address = dr["Address"].ToString();
                            if (ds.Tables[0].Columns.Contains("Country"))
                                tmpPotentialUser.PotentialUser.Country = dr["Country"].ToString();
                            if (ds.Tables[0].Columns.Contains("Region"))
                                tmpPotentialUser.PotentialUser.Region = dr["Region"].ToString();
                            if (ds.Tables[0].Columns.Contains("City"))
                                tmpPotentialUser.PotentialUser.City = dr["City"].ToString();
                            if (ds.Tables[0].Columns.Contains("Language"))
                                tmpPotentialUser.PotentialUser.Language = dr["Language"].ToString();
                            if (ds.Tables[0].Columns.Contains("OrganizationName"))
                                tmpPotentialUser.PotentialUser.OrganizationName = dr["OrganizationName"].ToString();
                            if (ds.Tables[0].Columns.Contains("OrganizationType"))
                                tmpPotentialUser.PotentialUser.OrganizationType = dr["OrganizationType"].ToString();
                            if (ds.Tables[0].Columns.Contains("Qualification"))
                                tmpPotentialUser.PotentialUser.Qualification = dr["Qualification"].ToString();
                            if (ds.Tables[0].Columns.Contains("Source"))
                                tmpPotentialUser.PotentialUser.Source = dr["Source"].ToString();
                            if (ds.Tables[0].Columns.Contains("Source"))
                                tmpPotentialUser.PotentialUser.Source = dr["Source"].ToString();
                            try
                            {
                                if (ds.Tables[0].Columns.Contains("Latitude"))
                                    tmpPotentialUser.PotentialUser.Latitude = Convert.ToDecimal(dr["Latitude"]);
                                if (ds.Tables[0].Columns.Contains("Longitude"))
                                    tmpPotentialUser.PotentialUser.Longitude = Convert.ToDecimal(dr["Longitude"]);
                            }

                            catch (Exception)
                            {

                            }
                            if (ds.Tables[0].Columns.Contains("CustomField1"))
                                tmpPotentialUser.PotentialUser.CustomField1 = dr["CustomField1"].ToString();
                            if (ds.Tables[0].Columns.Contains("CustomField2"))
                                tmpPotentialUser.PotentialUser.CustomField2 = dr["CustomField2"].ToString();
                            if (ds.Tables[0].Columns.Contains("Title"))
                                tmpPotentialUser.PotentialUser.Title = dr["Title"].ToString();
                            if (ds.Tables[0].Columns.Contains("ZipCode"))
                                tmpPotentialUser.PotentialUser.ZipCode = dr["ZipCode"].ToString();
                            if (ds.Tables[0].Columns.Contains("WebSite"))
                                tmpPotentialUser.PotentialUser.WebSite = dr["WebSite"].ToString();
                            if (ds.Tables[0].Columns.Contains("LinkedIn"))
                                tmpPotentialUser.PotentialUser.LinkedIn = dr["LinkedIn"].ToString();
                            if (ds.Tables[0].Columns.Contains("GooglePlus"))
                                tmpPotentialUser.PotentialUser.GooglePlus = dr["GooglePlus"].ToString();
                            if (ds.Tables[0].Columns.Contains("Twitter"))
                                tmpPotentialUser.PotentialUser.Twitter = dr["Twitter"].ToString();
                            if (ds.Tables[0].Columns.Contains("Facebook"))
                                tmpPotentialUser.PotentialUser.Facebook = dr["Facebook"].ToString();
                            if (ds.Tables[0].Columns.Contains("Skype"))
                                tmpPotentialUser.PotentialUser.Skype = dr["Skype"].ToString();
                            if (ds.Tables[0].Columns.Contains("Sector"))
                                tmpPotentialUser.PotentialUser.Sector = dr["Sector"].ToString();
                            if (tmpPotentialUser.PotentialUser.PotentialUserId != Guid.Empty)
                            {
                                counterRepeat++;
                                if (chkUpdate.Checked)
                                {

                                    counterSuccess += tmpPotentialUser.Save();
                                }
                            }
                            else
                            {
                                counterSuccess += tmpPotentialUser.Save();
                            }

                        }

                    }

                }

                MIFNEXSOEntities nx = new MIFNEXSOEntities();
                grdPreUsers.DataSource = nx.PotentialUsers;
                grdPreUsers.DataBind();
                da.Dispose();
                conn.Close();
                conn.Dispose();

            }
            lblResult.Text = String.Format("Uploading contact done Succesfutl ({0}), Repeats ({1}) Errors ({2})", counterSuccess, counterRepeat,
                                           counter);
        }
        catch (Exception ee)
        {
            lblResult.Text = "Exception: " + ee.ToString();
        }
    }
    protected void RadGrid1_ItemInserted(object source, GridInsertedEventArgs e)
    {
        if (e.Exception != null)
        {

            e.ExceptionHandled = true;
            SetMessage("Customer cannot be inserted. Reason: " + e.Exception.Message);

        }
        else
        {
            SetMessage("New customer is inserted!");
        }
    }
    protected void RadGrid1_PreRender(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(gridMessage))
        {
            DisplayMessage(gridMessage);
        }
    }
    protected void RadGrid1_NeedDataSource(object sender, GridNeedDataSourceEventArgs e)
    {

        DataBind();
    }

    /// <summary>
    /// Load the information of the selected user to edit (edit button) in controls
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RadGrid1_ItemCreatedAndEdit(object sender, Telerik.Web.UI.GridItemEventArgs e)
    {
        if (e.Item is GridEditFormItem && e.Item.IsInEditMode)
        {
            GridEditFormItem edititem = (GridEditFormItem)e.Item;
            RadComboBox ddOrganizationType = (RadComboBox)edititem.FindControl("ddOrganizationType");
            var list2 = ListComponent.GetListPerCategory("Beneficiaries", Thread.CurrentThread.CurrentCulture.Name).ToList();
            ddOrganizationType.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);

            List<List> list = new List<List>();
            List listad = new List();
            listad.Culture = Localization.GetString("NewOrganizationType", this.LocalResourceFile);
            listad.Label = Localization.GetString("NewOrganizationType", this.LocalResourceFile);
            listad.Key = Localization.GetString("NewOrganizationType", this.LocalResourceFile);
            listad.Value = "0";
            list.Add(listad);
            list.AddRange(ListComponent.GetListPerCategory("Beneficiaries", Thread.CurrentThread.CurrentCulture.Name).ToList());

            ddOrganizationType.DataSource = list;
            ddOrganizationType.DataBind();
            ddOrganizationType.Items.Insert(0, new RadComboBoxItem(Localization.GetString("NewOrganizationType", this.LocalResourceFile), string.Empty));

            RadComboBox ddLanguage = (RadComboBox)edititem.FindControl("ddLanguage");
            list = ListComponent.GetListPerCategory("Language", Thread.CurrentThread.CurrentCulture.Name).ToList();
            ddLanguage.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
            ddLanguage.DataSource = list;
            ddLanguage.DataBind();
            ddLanguage.Items.Insert(0, new RadComboBoxItem(Localization.GetString("NewOrganizationType", this.LocalResourceFile), string.Empty));

            RadComboBox ddCountry = (RadComboBox)edititem.FindControl("ddCountry");
            fillCountries(ddCountry);




            if (!(e.Item is IGridInsertItem))
            {
                foreach (RadComboBoxItem item in ddOrganizationType.Items)
                {
                    try
                    {
                        string OrganizationType = DataBinder.Eval(e.Item.DataItem, "OrganizationType").ToString();
                        string itemText = item.Text;
                        if (OrganizationType != string.Empty)
                        {

                            if (OrganizationType == itemText)
                            {
                                NewOragnizationType = false;
                                ddOrganizationType.SelectedValue = DataBinder.Eval(e.Item.DataItem, "OrganizationType").ToString();
                                return;
                            }
                            else
                                NewOragnizationType = true;

                        }
                    }
                    catch { }
                }

                if (DataBinder.Eval(e.Item.DataItem, "Language") != null)
                    ddLanguage.SelectedValue = DataBinder.Eval(e.Item.DataItem, "Language").ToString();
                if (DataBinder.Eval(e.Item.DataItem, "Country") != null)
                {

                    try
                    {
                        foreach (RadComboBoxItem item in ddCountry.Items)
                        {

                            if (item.Text == DataBinder.Eval(e.Item.DataItem, "Country").ToString())
                            {
                                ddCountry.Text = item.Text;
                                item.Checked = true;
                                item.Selected = true;

                            }
                            if (item.Value == DataBinder.Eval(e.Item.DataItem, "Country").ToString())
                            {

                                ddCountry.SelectedValue = DataBinder.Eval(e.Item.DataItem, "Country").ToString();

                            }



                        }

                    }
                    catch { }



                }





                RadTextBox txtNewOrganizationType = (RadTextBox)edititem.FindControl("txtNewOrganizationType");
                if (NewOragnizationType == true)
                {
                    ddOrganizationType.SelectedValue = Localization.GetString("NewOrganizationType", this.LocalResourceFile).ToString();
                    ddOrganizationType.Text = Localization.GetString("NewOrganizationType", this.LocalResourceFile).ToString();
                    txtNewOrganizationType.Text = DataBinder.Eval(e.Item.DataItem, "OrganizationType").ToString();
                    txtNewOrganizationType.Style.Add("display", "block!important");
                }
                else

                    txtNewOrganizationType.Style.Add("display", "none!important");
            }
        }

    }

    /// <summary>
    /// Select New Organization
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RadComboBox_SelectedIndexChanged(object sender, RadComboBoxSelectedIndexChangedEventArgs e)
    {
        RadComboBox combo = (RadComboBox)sender;
        RadTextBox txtNewOrganizationType = (RadTextBox)combo.Parent.FindControl("txtNewOrganizationType");
        string nameOrganizationType = e.Text;
        if (nameOrganizationType.Equals(Localization.GetString("NewOrganizationType", this.LocalResourceFile)))
            txtNewOrganizationType.Style.Add("display", "block!important");
        else
            txtNewOrganizationType.Style.Add("display", "none!important");
    }

    /// <summary>
    /// Update information of the Potential user
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
                RadTextBox txtEmail = (RadTextBox)editItem.FindControl("txtEmail");
                if (txtEmail.Text != string.Empty)
                {
                    //get information from the controls
                    TextBox txtPotentialUserId = (TextBox)editItem.FindControl("txtPotentialUserId");
                    RadTextBox txtFirstName = (RadTextBox)editItem.FindControl("txtFirstName");
                    RadTextBox txtLastName = (RadTextBox)editItem.FindControl("txtLastName");
                    RadTextBox txtOrganizationName = (RadTextBox)editItem.FindControl("txtOrganizationName");
                    RadTextBox txtPhone = (RadTextBox)editItem.FindControl("txtPhone");
                    RadTextBox txtAddress = (RadTextBox)editItem.FindControl("txtAddress");
                    RadTextBox txtMiddleName = (RadTextBox)editItem.FindControl("txtMiddleName");
                    RadTextBox txtQualification = (RadTextBox)editItem.FindControl("txtQualification");
                    RadTextBox txtSource = (RadTextBox)editItem.FindControl("txtSource");
                    RadTextBox txtSector = (RadTextBox)editItem.FindControl("txtSector");
                    RadTextBox txtBatch = (RadTextBox)editItem.FindControl("txtBatch");
                    RadTextBox txtTitle = (RadTextBox)editItem.FindControl("txtTitle");
                    RadTextBox txtZipCode = (RadTextBox)editItem.FindControl("txtZipCode");
                    RadTextBox txtWebSite = (RadTextBox)editItem.FindControl("txtWebSite");
                    RadTextBox txtLinkedIn = (RadTextBox)editItem.FindControl("txtLinkedIn");
                    RadTextBox txtGooglePlus = (RadTextBox)editItem.FindControl("txtGooglePlus");
                    RadTextBox txtTwitter = (RadTextBox)editItem.FindControl("txtTwitter");
                    RadTextBox txtFacebook = (RadTextBox)editItem.FindControl("txtFacebook");
                    RadTextBox txtSkype = (RadTextBox)editItem.FindControl("txtSkype");
                    RadComboBox ddLanguage = (RadComboBox)editItem.FindControl("ddLanguage");
                    RadComboBox ddOrganizationType = (RadComboBox)editItem.FindControl("ddOrganizationType");
                    RadTextBox txtNewOrganizationType = (RadTextBox)editItem.FindControl("txtNewOrganizationType");
                    RadComboBox ddCountry = (RadComboBox)editItem.FindControl("ddCountry");

                    bool sw = false;
                    potentialUserComponent = new PotentialUserComponent(txtEmail.Text);

                    //If is new potential user
                    if (potentialUserComponent.PotentialUser.PotentialUserId == Guid.Empty)
                    {
                        potentialUserComponent.PotentialUser.Created = DateTime.Now;
                        potentialUserComponent.PotentialUser.Updated = potentialUserComponent.PotentialUser.Created;

                        sw = true;

                        ExistEmail = false;

                    }
                    else
                    {
                        if (txtPotentialUserId.Text != string.Empty)
                        {
                            if (potentialUserComponent.PotentialUser.PotentialUserId == (new Guid(txtPotentialUserId.Text)))
                            {
                                //update Date
                                potentialUserComponent.PotentialUser.Updated = DateTime.Now;

                                sw = true;

                                ExistEmail = false;

                            }
                            else
                                ExistEmail = true;

                        }
                        else
                            ExistEmail = true;


                    }

                    //Update information for the existing user
                    if (sw == true)
                    {
                        potentialUserComponent.PotentialUser.Email = txtEmail.Text;
                        potentialUserComponent.PotentialUser.FirstName = txtFirstName.Text;
                        potentialUserComponent.PotentialUser.LastName = txtLastName.Text;
                        potentialUserComponent.PotentialUser.OrganizationName = txtOrganizationName.Text;
                        potentialUserComponent.PotentialUser.Phone = txtPhone.Text;
                        potentialUserComponent.PotentialUser.Address = txtAddress.Text;
                        potentialUserComponent.PotentialUser.MiddleName = txtMiddleName.Text;
                        potentialUserComponent.PotentialUser.Qualification = txtQualification.Text;
                        potentialUserComponent.PotentialUser.Source = txtSource.Text;
                        potentialUserComponent.PotentialUser.Sector = txtSector.Text;
                        potentialUserComponent.PotentialUser.Batch = txtBatch.Text;
                        potentialUserComponent.PotentialUser.Title = txtTitle.Text;
                        potentialUserComponent.PotentialUser.ZipCode = txtZipCode.Text;
                        potentialUserComponent.PotentialUser.WebSite = txtWebSite.Text;
                        potentialUserComponent.PotentialUser.LinkedIn = txtLinkedIn.Text;
                        potentialUserComponent.PotentialUser.GooglePlus = txtGooglePlus.Text;
                        potentialUserComponent.PotentialUser.Twitter = txtTwitter.Text;
                        potentialUserComponent.PotentialUser.Facebook = txtFacebook.Text;
                        potentialUserComponent.PotentialUser.Skype = txtSkype.Text;
                        potentialUserComponent.PotentialUser.Language = ddLanguage.SelectedValue;
                        potentialUserComponent.PotentialUser.Country = ddCountry.SelectedValue;

                        string newOrgType = Localization.GetString("NewOrganizationType", this.LocalResourceFile).ToString();
                        if (ddOrganizationType.SelectedValue == newOrgType)
                        {
                            if (txtNewOrganizationType.Text != string.Empty)
                                potentialUserComponent.PotentialUser.OrganizationType = txtNewOrganizationType.Text;
                        }
                        else
                            potentialUserComponent.PotentialUser.OrganizationType = ddOrganizationType.SelectedValue;

                        potentialUserComponent.Save();
                        if (editItem.ItemIndex != -1)
                            this.grdPreUsers.MasterTableView.Items[editItem.ItemIndex].Edit = false;
                        else
                            this.grdPreUsers.MasterTableView.Rebind();
                        e.Item.OwnerTableView.IsItemInserted = false;


                    }
                }


            }
        }
    }

    /// <summary>
    /// Delete selected user (delete button) in controls
    /// </summary>
    /// <param name="source"></param>
    /// <param name="e"></param>
    protected void RadGrid1_DeleteCommand(object source, GridCommandEventArgs e)
    {
        string PotentialUserId = e.Item.OwnerTableView.DataKeyValues[e.Item.ItemIndex]["PotentialUserId"].ToString();

        potentialUserComponent = new PotentialUserComponent(new Guid(PotentialUserId));
        potentialUserComponent.PotentialUser.Deleted = true;
        potentialUserComponent.Save();
        DataBind();

    }

    /// <summary>
    /// Export information from grid to excel
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnExport_Click(object sender, EventArgs e)
    {
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("PotentialUserId2").Visible = true;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("EditCommandColumn").Visible = false;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("DeleteCommandColumn").Visible = false;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("Region").Visible = true;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("City").Visible = true;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("Language").Visible = true;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("Qualification").Visible = true;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("Latitude").Visible = true;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("Longitude").Visible = true;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("Batch").Visible = true;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("Created").Visible = true;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("Updated").Visible = true;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("Deleted").Visible = true;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("GoogleLocation").Visible = true;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("CustomField1").Visible = true;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("CustomField2").Visible = true;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("ZipCode").Visible = true;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("LinkedIn").Visible = true;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("GooglePlus").Visible = true;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("Twitter").Visible = true;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("Facebook").Visible = true;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("Skype").Visible = true;
        this.grdPreUsers.MasterTableView.Columns.FindByUniqueName("WebSite").Visible = true;
        ConfigureExport();
        grdPreUsers.MasterTableView.ExportToExcel();



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