using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Globalization;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Services.Localization;
using Newtonsoft.Json;
using MIFWebServices;

using NexsoProDAL;

/// <summary>
/// Este control se utiliza para la creacion o registro de la direccion en diferentes partes del codigo
/// Un ejmeplo se encuentra cuando el usuario esta registrando en el sistema y le solicta la direccion y la ubica en el mapa.
/// Utiliza el js CountryStateCity.js contenido en el modulo
/// </summary>
public partial class CountryStateCityV2 : PortalModuleBase
{

    #region Private Member Variables
    private List<Location> locations;

    private string val = "";
    #endregion

    #region Private Properties


    #endregion

    #region Private Methods


    /// <summary>
    /// Deserialize JSON with information of location selected by the user
    /// </summary>
    private void DeserializeJson()
    {
        var culture = new CultureInfo("en-US");
        if (hdVal1.Value != string.Empty)
        {
            dynamic JsonDe = JsonConvert.DeserializeObject(hdVal1.Value);
            Location location = new Location();
            if (JsonDe != null)
            {


                foreach (dynamic element in JsonDe)
                {
                    location = new Location()
                    {
                        country = element["country"].ToString(),
                        countryShort = element["countryShort"].ToString(),
                        administrative_area_level_1 = element["administrative_area_level_1"].ToString(),
                        administrative_area_level_2 = element["administrative_area_level_2"].ToString(),
                        administrative_area_level_3 = element["administrative_area_level_3"].ToString(),
                        locality = element["locality"].ToString(),
                        street_number = element["street_number"].ToString(),
                        route = element["route"].ToString(),
                        postal_code = element["postal_code"].ToString(),
                        formatted_address = element["formatted_address"].ToString(),
                        latitude = Convert.ToDecimal(((string)element["latitude"]), culture),
                        longitude = Convert.ToDecimal(((string)element["longitude"]), culture),
                        icon = element["icon"].ToString(),
                        inputCityStateCountry = element["inputCityStateCountry"].ToString(),
                        inputAddress = element["inputAddress"].ToString(),
                        city = element["city"].ToString(),
                        state = element["state"].ToString(),
                        type = element["type"] != null ? element["type"].ToString() : string.Empty
                    };
                    locations.Add(location);


                }

            }

            if (MultiSelect)
            {

            }
            else
            {
                //  List<SearchCityDTO> geoObj = LocationService.Geocode(location.country, location.state, location.city,
                //                                                location.latitude, location.longitude);

                //if (geoObj != null)
                //{
                //    if (geoObj.Count > 0)
                //    {
                //        SelectedCountry = geoObj[1].Country_Code;
                //        SelectedState = geoObj[1].State_Code.ToString();
                //        SelectedCity = geoObj[1].City_Code.ToString();
                //        SelectedLatitude = location.latitude;
                //        SelectedLongitude = location.longitude;
                //        SelectedAddress = location.inputAddress;
                //    }
                //}
                //else
                //{
                SelectedCountry = location.country;
                SelectedState = location.state;
                SelectedCity = location.city;
                SelectedLatitude = location.latitude;
                SelectedLongitude = location.longitude;
                SelectedAddress = location.inputAddress;
                //}

            }
        }
    }


    /// <summary>
    /// Serialize JSON with information of location selected by the user
    /// </summary>
    private void SerializedJson()
    {
        if (MultiSelect)
        {
            foreach (var location in locations)
            {
                try
                {
                    int u = int.Parse(location.city);
                    location.city = LocationService.GetCityName(u);
                }
                catch
                {

                }
                try
                {
                    int u = int.Parse(location.state);
                    location.state = LocationService.GetStateName(u);
                }
                catch
                {

                }
                try
                {

                    location.country = LocationService.GetCountryName(location.country);
                }
                catch
                {

                }

            }
        }
        else
        {
            locations = new List<Location>();
            var countryname = SelectedCountryName;
            var cityname = SelectedCityName;
            var statename = SelectedStateName;

            locations.Add(new Location()
            {
                country = countryname,
                countryShort = SelectedCountry,
                administrative_area_level_1 = "",
                administrative_area_level_2 = "",
                administrative_area_level_3 = "",
                locality = "",
                street_number = "",
                route = "",
                postal_code = "",
                formatted_address = "",
                latitude = SelectedLatitude,
                longitude = SelectedLongitude,
                icon = "",
                inputCityStateCountry = cityname + " " + statename + ", " + countryname,
                inputAddress = SelectedAddress,
                city = cityname,
                state = statename,
                type = ""
            }
                );
        }
        var ret = JsonConvert.SerializeObject(locations);
        hdVal1.Value = ret;
    }


    /// <summary>
    /// Load validation message
    /// </summary>
    private void PopulateLabels()
    {
        rgvtxtaddress.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
    }

    /// <summary>
    /// Registers the client script with the Page object using a key and a URL, which enables the script to be called from the client.
    /// </summary>
    private void RegisterScripts()
    {
        if (!IsPostBack)
        {
            string OrganizationName = string.Empty;
            string ProfileOrg = string.Empty;
            if (Organization != null)
            {
                ProfileOrg = NexsoHelper.GetCulturedUrlByTabName("insprofile") + "/in/" + Organization.OrganizationID;
                OrganizationName = Organization.Name;
            }

            Page.ClientScript.RegisterClientScriptInclude(
                this.GetType(), "countryStateCity", ControlPath + "resources/js/countryStateCity.js");

            if (address.Value != string.Empty)
            {
                if (string.IsNullOrEmpty(ValidateSecurity.ValidateString(address.Value,false)))
                {
                    lblMessage.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
                    lblMessage.IsValid = false;
                    return;
                }
            
            }
            string script = "<script>" +

                            "var iconGenOrg" + this.ClientID + "='" + String.Format("{0}Images/organizationbldg.png", PortalSettings.HomeDirectory) + "';"
                            +
                            "var iconGenTestLocation" + this.ClientID + "='" + String.Format("{0}Images/testlocationcrc.png", PortalSettings.HomeDirectory) + "';"
                            +
                            "var profileOrg" + this.ClientID + "='" + ProfileOrg.ToString().ToLower() + "';"
                            +
                            "var orgName" + this.ClientID + "='" + OrganizationName.ToLower() + "';"
                            +
                            "var iconGenIni" + this.ClientID + "='" + String.Format("{0}Images/marker-yellow.png", PortalSettings.HomeDirectory) + "';"
                            +
                //"var iconGenOrg" + this.ClientID + "='" + String.Format("{0}Images/marker-blue.png", PortalSettings.HomeDirectory) + "';"
                //+                                            
                            "var multiSelectIni" + this.ClientID + "=" + MultiSelect.ToString().ToLower() + ";"
                             +
                            "var addressRequiredIni" + this.ClientID + "=" + AddressRequired.ToString().ToLower() + ";"

                            +
                             "var viewInEditModeIni" + this.ClientID + "=" + ViewInEditMode.ToString().ToLower() + ";"
                            +
                            "var addressPlaceHolderIni" + this.ClientID + "='" + GetLabelAddresPlaceHolder() + "';"
                            +
                            "var cscPlaceHolderIni" + this.ClientID + "='" + GetLabelCityStateCountryPlaceHolder() + "';"
                            +
                            "function load" + ClientID + "(){initializemap(document.getElementById('map_canvas" +
                            ClientID + "'), document.getElementById('" + pac_input.ClientID +
                            "'), document.getElementById('" + address.ClientID +
                            "'),document.getElementById('btnGeocode" + ClientID + "'),document.getElementById('" +
                            hdVal1.ClientID + "'),'" + this.ClientID + "');}" +

                            "$(document).ready(function () {Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(load" +
                            ClientID + ");Sys.WebForms.PageRequestManager.getInstance().add_endRequest(load" + ClientID +
                            ");});" +


                            "</script>";


            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "script" + ClientID, script);
            rfvAddress.Visible = LocationRequired;
        }
    }

    #endregion

    #region Public Properties

    public string Language { get; set; }
    public string SelectedCountry
    {
        get { return (String)ViewState["country"]; }
        set { ViewState["country"] = value; }
    }
    public string SelectedState
    {
        get { return (String)ViewState["state"]; }
        set { ViewState["state"] = value; }
    }
    public string SelectedCity
    {
        get { return (String)ViewState["city"]; }
        set { ViewState["city"] = value; }
    }
    public string SelectedAddress
    {
        get { return (String)ViewState["address"]; }
        set { ViewState["address"] = value; }
    }
    public decimal SelectedLatitude
    {
        get
        {
            if (ViewState["latitude"] != null)
            {
                return (Decimal)ViewState["latitude"];
            }
            else
            {
                return 0;
            }


        }
        set { ViewState["latitude"] = value; }

    }
    public decimal SelectedLongitude
    {
        get
        {
            if (ViewState["longitude"] != null)
            {
                return (Decimal)ViewState["longitude"];
            }
            else
            {
                return 0;
            }


        }
        set { ViewState["longitude"] = value; }
    }

    public string LocationPanelTitle
    {
        get
        {
            if (ViewState["LocationPanelTitle"] != null)
            {
                return ViewState["LocationPanelTitle"].ToString();
            }
            else
            {
                return string.Empty;
            }


        }
        set { ViewState["LocationPanelTitle"] = value; }
    }

    public string EmptyMessage
    {
        get
        {
            if (ViewState["EmptyMessage"] != null)
            {
                return ViewState["EmptyMessage"].ToString();
            }
            else
            {
                return string.Empty;
            }


        }
        set { ViewState["EmptyMessage"] = value; }
    }

    public bool LocationRequired { get; set; }
    public bool AddressRequired { get; set; }
    public bool ViewInEditMode { get; set; }
    public bool MultiSelect { get; set; }
    public string GoogleLocation { get; set; }
    public string SelectedPostalCode { get; set; }
    public Organization Organization
    {
        get
        {
            if (ViewState["Organization"] != null)

                return (Organization)ViewState["Organization"];

            else
                return null;

        }
        set { ViewState["Organization"] = value; }
    }
    public List<Location> Locations
    {
        get
        {
            return locations;
        }
        set { locations = value; }

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
                try
                {
                    int u = int.Parse(SelectedState);

                }
                catch (Exception)
                {
                    return SelectedState;

                }

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
                if (SelectedCountry.Length == 2)
                {
                    return LocationService.GetCountryName(SelectedCountry);
                }
                else
                {
                    return SelectedCountry;
                }
            }
            catch
            {
                return String.Empty;
            }
        }
    }


    #endregion

    #region Public Methods

    public void UpdateMap()
    {
        SerializedJson();
    }


    #endregion

    #region Subclasses
    public class Location
    {
        public string country;
        public string countryShort;
        public string administrative_area_level_1;
        public string administrative_area_level_2;
        public string administrative_area_level_3;
        public string locality;
        public string street_number;
        public string route;
        public string postal_code;
        public string formatted_address;
        public decimal latitude;
        public decimal longitude;
        public string icon;
        public string inputCityStateCountry;
        public string inputAddress;
        public string city;
        public string state;
        public string type;


    }



    #endregion

    #region Protected Methods

    /// <summary>
    /// Get text for the button
    /// </summary>
    /// <returns></returns>
    protected string GetLabelGeocodeButton()
    {
        if (MultiSelect)
        {
            return Localization.GetString("BtnAddLocation", LocalResourceFile);
        }
        else
        {
            return Localization.GetString("BtnGeocode", LocalResourceFile);
        }
    }

    /// <summary>
    /// Get text for the title (MAP)
    /// </summary>
    /// <returns></returns>
    protected string GetLocationPanelTitle()
    {
        if (LocationPanelTitle != string.Empty)
            return LocationPanelTitle;
        return Localization.GetString("pnlLocations", LocalResourceFile);
    }

    /// <summary>
    /// This message is displayed when isn't locations to show.
    /// </summary>
    /// <returns></returns>
    protected string GetEmptyMessage()
    {
        if (EmptyMessage != string.Empty)
            return EmptyMessage;
        return Localization.GetString("EmptyMessage", LocalResourceFile);
    }

    /// <summary>
    /// The text is show in the textbox PlaceHolder (Enter addres, Street addres)
    /// </summary>
    /// <returns></returns>
    protected string GetLabelAddresPlaceHolder()
    {

        if (AddressRequired)
        {
            return Localization.GetString("PlhAddressRequired", LocalResourceFile);
        }
        else
        {
            return Localization.GetString("PlhAddressNonRequired", LocalResourceFile);
        }

    }


    /// <summary>
    /// The text is show in the textbox PlaceHolder (country/state/city)
    /// </summary>
    /// <returns></returns>
    protected string GetLabelCityStateCountryPlaceHolder()
    {


        return Localization.GetString("PlhCityStateCountry", LocalResourceFile);

    }

    #endregion

    #region Events



    protected void Page_Load(object sender, EventArgs e)
    {

        locations = new List<Location>();
        PopulateLabels();
        DeserializeJson();

        SerializedJson();

        if (ViewInEditMode)
        {
            pac_input.Visible = true;
            address.Visible = true;
        }
        else
        {
            pac_input.Visible = false;
            address.Visible = false;
        }
        RegisterScripts();


      
    }


    protected override void OnLoad(EventArgs e)
    {

        base.OnLoad(e);

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

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);


    }

    #endregion

}