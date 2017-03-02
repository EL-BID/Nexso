using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net;
using System.Runtime.Serialization.Json;
using DotNetNuke.Security;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Services.Localization;
using System.Threading;
using Telerik.Web.UI;
using NexsoProBLL;
using NexsoProDAL;

public partial class NZSubscriptionChallenge : PortalModuleBase, IActionable
{
    #region Private Member Variables
    protected string Language = System.Globalization.CultureInfo.CurrentUICulture.Name;
    private PotentialUserComponent potentialUserComponent;
    #endregion

    #region Private Properties
    #endregion

    #region Private Methods
    private void FillData()
    {
        rgvEmail.ErrorMessage = Localization.GetString("InvalidEmail", LocalResourceFile);
        //var list = ListComponent.GetListPerCategory("SectorJPO", Thread.CurrentThread.CurrentCulture.Name).ToList();
        ddSectorJPO.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        List<string> list = new List<string>();
        list.Add(Localization.GetString("SectorItem1", LocalResourceFile));
        list.Add(Localization.GetString("SectorItem2", LocalResourceFile));
        list.Add(Localization.GetString("SectorItem3", LocalResourceFile));
        list.Add(Localization.GetString("SectorItem4", LocalResourceFile));
        list.Add(Localization.GetString("SectorItem5", LocalResourceFile));
        list.Add(Localization.GetString("SectorItem6", LocalResourceFile));
        list.Add(Localization.GetString("SectorItem7", LocalResourceFile));
        list.Add(Localization.GetString("SectorItem8", LocalResourceFile));
        list.Add(Localization.GetString("SectorItem9", LocalResourceFile));
        list.Add(Localization.GetString("SectorItem10", LocalResourceFile));
        list.Add(Localization.GetString("SectorItem11", LocalResourceFile));
        list.Add(Localization.GetString("SectorItem12", LocalResourceFile));
        ddSectorJPO.DataSource = list;
        ddSectorJPO.DataBind();
        fillCountries();
        ddSectorItems.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        ddSectorItems.Enabled = false;
        rfvddSectorItems.Visible = false;
        rfvddSectorItems.Enabled = false;
        ddRegion.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        ddRegion.Enabled = false;
        ddCities.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
        ddCities.Enabled = false;
    }

    private void fillCountries()
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
        catch
        {
            
        }
    }

    private void fillRegions(string code)
    {
        try
        {
            string WURL = System.Configuration.ConfigurationManager.AppSettings["MifWebServiceUrl"].ToString();
            string url = WURL + "/states?id=" + code;
            WebRequest request = WebRequest.Create(url);
            WebResponse ws = request.GetResponse();
            DataContractJsonSerializer jsonSerializer = new DataContractJsonSerializer(typeof(List<State>));
            List<State> photos = (List<State>)jsonSerializer.ReadObject(ws.GetResponseStream());
            ddRegion.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
            if (photos.Count > 0)
            {
                ddRegion.Enabled = true;
            }
            else
            {
                ddRegion.Enabled = false;
            }
            ddRegion.DataSource = photos;
            ddRegion.DataBind();
        }
        catch 
        {
            ddRegion.Enabled = false;
        }
    }

    private void fillCities(int code)
    {
        try
        {
            string WURL = System.Configuration.ConfigurationManager.AppSettings["MifWebServiceUrl"].ToString();
            string url = WURL + "/cities?id=" + code;
            WebRequest request = WebRequest.Create(url);
            WebResponse ws = request.GetResponse();
            DataContractJsonSerializer jsonSerializer = new DataContractJsonSerializer(typeof(List<City>));
            List<City> photos = (List<City>)jsonSerializer.ReadObject(ws.GetResponseStream());
            ddCities.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
            if (photos.Count > 0)
            {
                ddCities.Enabled = true;
            }
            else
            {
                ddCities.Enabled = false;
            }
            ddCities.DataSource = photos;
            ddCities.DataBind();
        }
        catch
        {
            ddCities.Enabled = false;
        }
    }

    protected void LoadSector(string sector)
    {
        List<string> list = new List<string>();
        if (Localization.GetString("SectorItem1", LocalResourceFile) == sector)
        {
            list.Add(Localization.GetString("SectorItem1-1", LocalResourceFile));
            list.Add(Localization.GetString("SectorItem1-2", LocalResourceFile));
            list.Add(Localization.GetString("SectorItemOther", LocalResourceFile));
        }
        if (Localization.GetString("SectorItem3", LocalResourceFile) == sector)
        {
            list.Add(Localization.GetString("SectorItem3-1", LocalResourceFile));
            list.Add(Localization.GetString("SectorItemOther", LocalResourceFile));
        }
        if (Localization.GetString("SectorItem4", LocalResourceFile) == sector)
        {

            list.Add(Localization.GetString("SectorItem4-1", LocalResourceFile));
            list.Add(Localization.GetString("SectorItemOther", LocalResourceFile));

        }
        if (Localization.GetString("SectorItem5", LocalResourceFile) == sector)
        {
            list.Add(Localization.GetString("SectorItem5-1", LocalResourceFile));
            list.Add(Localization.GetString("SectorItemOther", LocalResourceFile));

        }
        if (Localization.GetString("SectorItem6", LocalResourceFile) == sector)
        {
            list.Add(Localization.GetString("SectorItem6-1", LocalResourceFile));
            list.Add(Localization.GetString("SectorItem6-2", LocalResourceFile));
            list.Add(Localization.GetString("SectorItem6-3", LocalResourceFile));
            list.Add(Localization.GetString("SectorItemOther", LocalResourceFile));
        }
        if (Localization.GetString("SectorItem7", LocalResourceFile) == sector)
        {
            list.Add(Localization.GetString("SectorItem7-1", LocalResourceFile));
            list.Add(Localization.GetString("SectorItem7-2", LocalResourceFile));
            list.Add(Localization.GetString("SectorItem7-3", LocalResourceFile));
            list.Add(Localization.GetString("SectorItem7-4", LocalResourceFile));
        }
        if (Localization.GetString("SectorItem8", LocalResourceFile) == sector)
        {
            list.Add(Localization.GetString("SectorItem8-1", LocalResourceFile));
            list.Add(Localization.GetString("SectorItem8-2", LocalResourceFile));
            list.Add(Localization.GetString("SectorItemOther", LocalResourceFile));
        }
        if (list.Count() > 0)
        {
            ddSectorItems.Enabled = true;
            rfvddSectorItems.Visible = true;
            rfvddSectorItems.Enabled = true;
        }
        else
        {
            ddSectorItems.Enabled = false;
            rfvddSectorItems.Visible = false;
            rfvddSectorItems.Enabled = false;
        }
        ddSectorItems.DataSource = list;
        ddSectorItems.DataBind();
    }

    private string getUserLanguage(string lang)
    {
        switch (lang)
        {
            case "en-US":
                return "en-US";
            case "es-ES":
                return "es-ES";
            case "pt-BR":
                return "pt-BR";
            default:
                return "en-US";
        }
    }

    private void RegisterScripts()
    {
        Page.ClientScript.RegisterClientScriptInclude(
             this.GetType(), "NZSubscriptionChallenge", ControlPath + "js/NZSubscriptionChallenge.js");
        string script = "<script>" +
             "var btnSubmit = '" + btnSubmit.ClientID + "';"
            + "var ckbAuthorization = '" + ckbAuthorization.ClientID + "';"
       + "</script>";
        Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Script22", script);
    }
    #endregion

    #region Constructors
    #endregion

    #region Public Properties
    #endregion

    #region Public Methods

    public void SendEmail(int ExistUser, string Email)
    {
        string MessageTitle = string.Empty;
        string MessageBody = string.Empty;
        if (ExistUser == 1)
        {
            MessageTitle = "MessageTitle";
            MessageBody = "MessageBody";
        }
        else
        {
            MessageTitle = "MessageTitleUpdateUser";
            MessageBody = "MessageBodyUpdateUser";
        }
        try
        {
            potentialUserComponent = new PotentialUserComponent(Email);
            DotNetNuke.Services.Mail.Mail.SendEmail("nexso@iadb.org",
                                                                     Email,
                                                                     string.Format(
                                                                         Localization.GetString(MessageTitle,
                                                                                                LocalResourceFile),
                                                                          potentialUserComponent.PotentialUser.LastName + " " + potentialUserComponent.PotentialUser.FirstName),
                                                                     string.Format(
                                                                         Localization.GetString(MessageBody,
                                                                                                LocalResourceFile),
                                                                         potentialUserComponent.PotentialUser.LastName + " " + potentialUserComponent.PotentialUser.FirstName
                                                                        ));
        }
        catch
        {
            throw;
        }
    }
    #endregion

    #region Subclasses

    public class listGeneric
    {
        public string Label { get; set; }
        public string Value { get; set; }
    }

    public class Country
    {
        public string country { get; set; }
        public string code { get; set; }
    }

    public class City
    {
        public string city { get; set; }
        public string code { get; set; }
    }

    public class State
    {
        public string state { get; set; }
        public string code { get; set; }
    }
    #endregion

    #region Events
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!IsPostBack)
        {
            RegisterScripts();
            FillData();
        }
        if (ckbAuthorization.Checked)
        {
            btnSubmit.Attributes.Remove("disabled");
            btnSubmit.Attributes.Add("disabled", "true");
        }
        else
        {
            btnSubmit.Attributes.Remove("disabled");
            btnSubmit.Attributes.Add("disabled", "false");
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

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        int ExistUser = 0;
        potentialUserComponent = new PotentialUserComponent(txtEmail.Text);
        if (potentialUserComponent.PotentialUser.PotentialUserId == Guid.Empty)
        {
            ExistUser = 1;
            potentialUserComponent.PotentialUser.Deleted = false;
            potentialUserComponent.PotentialUser.Created = DateTime.Now;
            potentialUserComponent.PotentialUser.Updated = potentialUserComponent.PotentialUser.Created;
        }
        else
        {
            potentialUserComponent.PotentialUser.Updated = DateTime.Now;
            ExistUser = 2;
        }
        potentialUserComponent.PotentialUser.Email = txtEmail.Text;
        potentialUserComponent.PotentialUser.FirstName = txtFirstName.Text;
        potentialUserComponent.PotentialUser.LastName = txtLastName.Text;
        potentialUserComponent.PotentialUser.Address = txtAddress.Text;
        potentialUserComponent.PotentialUser.Phone = txtPhone.Text;
        potentialUserComponent.PotentialUser.OrganizationName = txtOrganizationName.Text;
        potentialUserComponent.PotentialUser.Country = ddCountry.SelectedValue;
        potentialUserComponent.PotentialUser.Region = ddRegion.SelectedValue;
        potentialUserComponent.PotentialUser.City = ddCities.SelectedValue;
        var lan = "EN";
        if (Language == "pt-BR")
            lan = "PT";
        if (Language == "es-ES")
            lan = "ES";
        potentialUserComponent.PotentialUser.Source = "VPC2015FORM_" + lan;
        potentialUserComponent.PotentialUser.Title = txtTitle.Text;
        potentialUserComponent.PotentialUser.WebSite = txtWebSite.Text;
        potentialUserComponent.PotentialUser.LinkedIn = txtLinkedIn.Text;
        potentialUserComponent.PotentialUser.GooglePlus = txtGooglePlus.Text;
        potentialUserComponent.PotentialUser.Twitter = txtTwitter.Text;
        potentialUserComponent.PotentialUser.Facebook = txtFacebook.Text;
        potentialUserComponent.PotentialUser.Skype = txtSkype.Text;
        if (txtOther.Text != string.Empty)
        {
            potentialUserComponent.PotentialUser.Sector = txtOther.Text;
        }
        else
        {
            if (!string.IsNullOrEmpty(ddSectorItems.SelectedValue))
                potentialUserComponent.PotentialUser.Sector = ddSectorItems.SelectedValue;
            else
                potentialUserComponent.PotentialUser.Sector = ddSectorJPO.SelectedValue;
        }
        if (potentialUserComponent.Save() > 0)
        {
            pnlSubscription.Visible = false;
            pnlMessage.Visible = true;
        }
        //SendEmail(ExistUser, txtEmail.Text);
    }

    protected void ddRegion_SelectedIndexChanged(object sender, RadComboBoxSelectedIndexChangedEventArgs e)
    {
        ddCities.Text = "";
        try
        {
            int code = Convert.ToInt32(e.Value);
            fillCities(code);
        }
        catch { }
    }

    protected void ddCountry_SelectedIndexChanged(object sender, RadComboBoxSelectedIndexChangedEventArgs e)
    {
        ddCities.Text = "";
        ddRegion.Text = "";
        try
        {
            fillRegions(ddCountry.SelectedValue);
        }
        catch { }
    }

    protected void ddSectorItems_SelectedIndexChanged(object sender, RadComboBoxSelectedIndexChangedEventArgs e)
    {
        if (e.Value == Localization.GetString("SectorItemOther", LocalResourceFile))
            dvOther.Visible = true;
        else
        {
            txtOther.Text = string.Empty;
            dvOther.Visible = false;
        }
    }

    protected void ddSectorJPO_SelectedIndexChanged(object sender, RadComboBoxSelectedIndexChangedEventArgs e)
    {
        ddSectorItems.Text = "";
        txtOther.Text = string.Empty;
        dvOther.Visible = false;
        LoadSector(e.Value);
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