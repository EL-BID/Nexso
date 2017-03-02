using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Runtime.Serialization.Json;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Services.Localization;
using MIFWebServices;

public partial class controls_CountryStateCity : PortalModuleBase
{

    #region Private Member Variables

    #endregion

    #region Private Properties


    #endregion

    #region Private Methods

    /// <summary>
    /// Method that fill the DropDown Cities, getting the information from Json
    /// </summary>
    /// <param name="code"></param>
    private void fillCities(int code)
    {
        try
        {



            string url = WURL + "/cities/" + code;
            WebRequest request = WebRequest.Create(url);
            WebResponse ws = request.GetResponse();
            DataContractJsonSerializer jsonSerializer = new DataContractJsonSerializer(typeof(List<City>));
            List<City> photos = (List<City>)jsonSerializer.ReadObject(ws.GetResponseStream());
            photos.Add(new City()
            {
                city = Localization.GetString("OtherCity", LocalResourceFile),
                code = "0"
            });
            if (photos.Count <= 1)
            {
                if (ShowCitties)
                {
                    dvCity.Visible = true;

                }
                else
                {
                    dvCity.Visible = false;
                }
                //hfCity.Value = "0";
                //txtCityDd.Text = string.Empty;
            }
            else
            {
                dvCity.Visible = false;
            }
            ddCities.DataSource = photos;
            ddCities.DataBind();

        }
        catch (Exception e)
        {

        }
    }

    /// <summary>
    /// Method that fill the Dropdown Region getting data from Jason
    /// </summary>
    /// <param name="code"></param>
    private void fillRegions(string code)
    {
        try
        {


            string url = WURL + "/states/" + code;
            WebRequest request = WebRequest.Create(url);
            WebResponse ws = request.GetResponse();
            DataContractJsonSerializer jsonSerializer = new DataContractJsonSerializer(typeof(List<State>));
            List<State> photos = (List<State>)jsonSerializer.ReadObject(ws.GetResponseStream());
            photos.Add(new State()
            {
                code = "0",
                state = Localization.GetString("OtherState", LocalResourceFile)
            });
            ddRegion.DataSource = photos;
            ddRegion.DataBind();

        }
        catch (Exception e)
        {

        }
    }

    /// <summary>
    /// internal method for filling the dropdowns
    /// </summary>
    private void fillCountries()
    {

        try
        {

            string url = WURL + "/countries";
            WebRequest request = WebRequest.Create(url);
            WebResponse ws = request.GetResponse();
            DataContractJsonSerializer jsonSerializer = new DataContractJsonSerializer(typeof(List<Country>));
            List<Country> photos = (List<Country>)jsonSerializer.ReadObject(ws.GetResponseStream());
            photos.Insert(0, new Country()
            {
                code = "0",
                country = Localization.GetString("OtherCountry", LocalResourceFile)
            });
            ddCountry.DataSource = photos;
            ddCountry.DataBind();

        }
        catch (Exception e)
        {

        }
    }



    private void ShowControl(bool editMode)
    {
        pnlEdit.Visible = editMode;
        pnlShow.Visible = !editMode;

        lblCity.Visible = TextBoxMode;
        lblRegion.Visible = TextBoxMode;
        lblCountry.Visible = TextBoxMode;

        lblCity2.Visible = !TextBoxMode;
        lblRegion2.Visible = !TextBoxMode;
        lblCountry2.Visible = !TextBoxMode;

        if (editMode)
        {
            lblStateRegionCaption.Visible = ShowRegions;
            ddRegion.Visible = ShowRegions;
            lblCityCaption.Visible = ShowCitties;
            ddCities.Visible = ShowCitties;
        }


    }

    #endregion

    #region Public Properties

    public bool EnableValidation
    {
        set { rfvddCountry.Enabled = value; }
        get { return rfvddCountry.Enabled; }
    }
    public string ValidationGroup
    {
        set { rfvddCountry.ValidationGroup = value; }
        get { return rfvddCountry.ValidationGroup; }
    }
    public bool ShowRegions { get; set; }
    public bool ShowCitties { get; set; }
    public string TitleCountry { get; set; }
    public string TitleState { get; set; }
    public string TitleCity { get; set; }
    public string Language { get; set; }
    public string WURL { get; set; }
    public string SelectedCountry { get { return hfCountry.Value; } set { hfCountry.Value = value; } }
    public string SelectedState { get { return hfRegion.Value; } set { hfRegion.Value = value; } }
    public string SelectedCity
    {
        get
        {

            if (hfCity.Value == "0")
                return txtCityDd.Text;
            return hfCity.Value;

        }
        set { hfCity.Value = value; }
    }
    public string SelectedCityName
    {

        get
        {
            try
            {
                try
                {
                    int u = int.Parse(SelectedCity);

                }
                catch (Exception)
                {
                    return SelectedCity;

                }

                return LocationService.GetCityName(Convert.ToInt32(SelectedCity));

            }
            catch
            {
                return String.Empty;
            }
        }

    }
    public string SelectedStateName
    {
        get
        {
            try
            {
                return LocationService.GetStateName(Convert.ToInt32(SelectedState));
            }
            catch
            {
                return String.Empty;
            }
        }
    }
    public string SelectedCountryName
    {
        get
        {
            try
            {
                return LocationService.GetCountryName(SelectedCountry);
            }
            catch
            {
                return String.Empty;
            }
        }
    }
    public bool EditMode { get; set; }
    public bool TextBoxMode { get; set; }


    #endregion

    #region Public Methods
    public void DataBind()
    {
        ShowControl(EditMode);
        if (EditMode)
        {
            LoadControl();
        }
        else
        {
            if (SelectedCountry != string.Empty)
            {
                lblCountry.Text = LocationService.GetCountryName(SelectedCountry);
                lblCountry2.Text = lblCountry.Text;
            }
            if (SelectedState != string.Empty)
            {
                try
                {
                    lblRegion.Text = LocationService.GetStateName(Convert.ToInt32(SelectedState));
                    lblRegion2.Text = lblRegion.Text;
                }
                catch
                {
                    lblRegion.Text = SelectedState;
                    lblRegion2.Text = lblRegion.Text;
                }
            }
            if (hfCity.Value != string.Empty)
            {
                try
                {
                    lblCity.Text = LocationService.GetCityName(Convert.ToInt32(hfCity.Value));
                    ddCities.SelectedValue = hfCity.Value;
                    lblCity2.Text = lblCity.Text;
                }
                catch
                {
                    lblCity.Text = hfCity.Value;
                    lblCity2.Text = lblCity.Text;
                    txtCityDd.Text = hfCity.Value;
                }

            }
        }
    }
    public void LoadControl()
    {
        try
        {


            fillCountries();
            if (hfCountry.Value != string.Empty)
            {
                if (ddCountry.Items.FindByValue(hfCountry.Value) != null)
                {
                    ddCountry.SelectedValue = hfCountry.Value;
                    if (hfRegion.Value != string.Empty)
                    {
                        fillRegions(hfCountry.Value);
                        ddRegion.SelectedValue = hfRegion.Value;
                        fillCities(Convert.ToInt32(hfRegion.Value));
                        try
                        {
                            int.Parse(hfCity.Value);


                            ddCities.SelectedValue = hfCity.Value;

                        }
                        catch (Exception)
                        {

                            ddCities.SelectedValue = "0";
                            dvCity.Visible = true;
                            txtCityDd.Text = hfCity.Value;
                        }


                    }
                }
            }
        }
        catch (Exception)
        {


        }
    }


    #endregion

    #region Subclasses

    /// <summary>
    /// class estructure compatible with Json
    /// </summary>
    public class Country
    {
        public string country { get; set; }
        public string code { get; set; }

    }

    /// <summary>
    /// class structure compatible with Json
    /// </summary>
    public class State
    {
        public string state { get; set; }
        public string code { get; set; }

    }

    /// <summary>
    /// class structure compatible with Json
    /// </summary>
    public class City
    {
        public string city { get; set; }
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
            ServicePointManager.ServerCertificateValidationCallback += (sender, certificate, chain, sslPolicyErrors) => true;

            ShowControl(EditMode);
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
        ShowCitties = true;
        ShowRegions = true;
    }

    /// <summary>
    /// on selecting index change for Region DropDown
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ddRegion_SelectedIndexChanged(object sender, System.EventArgs e)
    {
        hfRegion.Value = ddRegion.SelectedValue;
        fillCities(Convert.ToInt32(ddRegion.SelectedValue));
        hfCity.Value = ddCities.SelectedValue;
    }

    /// <summary>
    /// on selecting index change for the country control
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ddCountry_SelectedIndexChanged(object sender, System.EventArgs e)
    {
        try
        {
            hfCountry.Value = ddCountry.SelectedValue;
            fillRegions(ddCountry.SelectedValue);
            hfRegion.Value = ddRegion.SelectedValue;
            fillCities(int.Parse(ddRegion.SelectedValue));
            hfCity.Value = ddCities.SelectedValue;

        }
        catch (Exception)
        {

            throw;
        }

    }

    /// <summary>
    /// On selecting index change for the Cities Dropdown
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ddCities_SelectedIndexChanged(object sender, System.EventArgs e)
    {
        hfCity.Value = ddCities.SelectedValue;
        if (ddCities.SelectedValue == "0")
        {
            dvCity.Visible = true;
            txtCityDd.Text = string.Empty;

        }
        else
        {
            dvCity.Visible = false;
            txtCityDd.Text = string.Empty;
        }
    }
    #endregion




    

  
   

   


    

    

    

   

  


   
}

