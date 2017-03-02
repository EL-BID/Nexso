using System;
using System.Activities.Expressions;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DotNetNuke.Entities.Modules;
using System.Web.Services;
using NexsoProDAL;
using NexsoProBLL;
using System.Configuration;
using System.Text;
using DotNetNuke.Common;
using DotNetNuke.UI.Utilities;
using DotNetNuke.Services.Exceptions;
using DotNetNuke.Services.Localization;
using DotNetNuke.Security;
using DotNetNuke.Entities.Modules.Actions;

/// <summary>
/// This control is obsoleto, but is a map with localization of organizations.
/// It's not work
/// http://backend.nexso.org/en-us/Mapview
/// </summary>
public partial class NZMapModule : PortalModuleBase, IActionable
{

    #region Private Member Variables
    /// <summary>
    /// Current guid to the comments.
    /// </summary>
    private static Guid param;

    static MIFNEXSOEntities entityCommentComponent;
    //Defaul values....
    protected string DefaultLatitude = "10.900385";
    protected string DefaultLongitude = "-76.996295";
    protected string DefaultZoom = "3";
    protected string ZoomToOrganization = "7";//This is the default zoom if that is the organization.
    protected string minHeight = "600";


    protected string iconPin = string.Empty;

    #endregion

    #region Private Properties


    #endregion

    #region Private Methods
    /// <summary>
    /// Get from querystring the guid of the current app.
    /// </summary>
    private void LoadParams()
    {
        //When is solition.
        if (!string.IsNullOrEmpty(Request.QueryString["sl"]))
        {
            try
            {
                param = new Guid(Request.QueryString["sl"]);
            }
            catch (Exception)
            {
                param = Guid.Empty;
            }
        }
        else
        {
            param = Guid.Empty;


            //When id Organization.
            if (!string.IsNullOrEmpty(Request.QueryString["in"]))
            {
                try
                {
                    param = new Guid(Request.QueryString["in"]);
                }
                catch (Exception)
                {
                    param = Guid.Empty;
                }
            }
            else
            {
                param = Guid.Empty;
            }
        }
    }

    /// <summary>
    /// This method Fill the current corrdenates of the organization.
    /// </summary>
    private void LoadCoordinates()
    {
        CurrentZoom = DefaultZoom;
        CurrentLatitude = DefaultLatitude;
        CurrentLongitude = DefaultLongitude;
        if (Param != Guid.Empty)
        {
            var queryOR = (from organizationQuery1 in entityCommentComponent.Organization.AsEnumerable()
                           where organizationQuery1.OrganizationID == param
                           select new
                           {
                               organizationQuery1.Latitude,
                               organizationQuery1.Longitude
                           }).FirstOrDefault();

            if (queryOR == null)
            {
                var querySL = (from solution in entityCommentComponent.Solution.AsEnumerable()
                               join organizationQuery in entityCommentComponent.Organization.AsEnumerable()
                                   on solution.OrganizationId equals organizationQuery.OrganizationID
                               where solution.SolutionId == param
                               select new
                               {
                                   organizationQuery.Latitude,
                                   organizationQuery.Longitude
                               }).FirstOrDefault();

                if (querySL != null)
                {
                    CurrentLatitude = querySL.Latitude.GetValueOrDefault(0).ToString("0.0000000", CultureInfo.InvariantCulture);//Format
                    CurrentLongitude = querySL.Longitude.GetValueOrDefault(0).ToString("0.0000000", CultureInfo.InvariantCulture);//Format
                    CurrentZoom = ZoomToOrganization;
                }
                else
                {
                    CurrentLatitude = DefaultLatitude;
                    CurrentLongitude = DefaultLongitude;
                    CurrentZoom = DefaultZoom;
                }
            }
            else
            {
                CurrentLatitude = queryOR.Latitude.GetValueOrDefault(0).ToString("0.0000000", CultureInfo.InvariantCulture);//Format
                CurrentLongitude = queryOR.Longitude.GetValueOrDefault(0).ToString("0.0000000", CultureInfo.InvariantCulture);//Format
                CurrentZoom = ZoomToOrganization;
            }
        }
    }


    //Get the marks for a Organization object in JSON format.
    private string GetMarkData(Organization org, string lastHTMLInfo, string initialCharacter)
    {
        string strMarkData = string.Format("{0}code:'{2}', name:'{3}', lat:{4}, lon:{5}, aditionalInfo:'{6}'{1}",
                                initialCharacter, "}",
                                (org.Code ?? string.Empty).Replace("'", "&#39;"),
                                (org.Name ?? string.Empty).Replace("'", "&#39;"),
                                org.Latitude.Value.ToString("0.0000000", CultureInfo.InvariantCulture),
                                org.Longitude.Value.ToString("0.0000000", CultureInfo.InvariantCulture),
                                (lastHTMLInfo ?? string.Empty).Replace("'", "&#39;"));
        return strMarkData;
    }

    protected string GetExploreMapButton()
    {

        return Localization.GetString("btnExploreMap", LocalResourceFile);

    }

    #endregion    

    #region Public Properties
    /// <summary>
    /// Keeps the current guid When is soution.
    /// </summary>
    public static Guid Param
    {
        get { return param; }
        set { param = value; }
    }

    /// <summary>
    /// Keeps the current latitude for the Current organization.
    /// </summary>
    public string CurrentLatitude
    {
        get;
        set;
    }

    ///// <summary>
    ///// Keeps the all locations for show on map.
    ///// </summary>
    public string Locations
    {
        get;
        set;
    }

    /// <summary>
    /// Keeps the all locations for show on map.
    /// </summary>
    //public string Locations
    //{
    //    get{ if (Session["MapLocations"] ==null)
    //            return (Session["MapLocations"] = "")as string; 
    //        return (Session["MapLocations"] as string);
    //    }
    //    set{Session["MapLocations"] = value;}
    //}

    public string MinHeight
    {
        get { return minHeight; }
        set { minHeight = value; }
    }

    /// <summary>
    /// Keeps the current latitude for the Current organization.
    /// </summary>
    public string CurrentLongitude
    {
        get;
        set;
    }

    /// <summary>
    /// Keeps the current zoom for the Current organization.
    /// </summary>
    public string CurrentZoom
    {
        get;
        set;
    }



    #endregion

    #region Public Methods
    //Replaces special characters with their HTML format
    public static String ReplaceChars(string textToReplace)
    {
        return textToReplace.Replace("\r", "<br />")
                            .Replace("\n", "<br />")
                            .Replace("'", "&#8217;")
                            .Replace("\"", "&quot;")
                            .Replace("\t", "&nbsp;")
                            .Replace("\\", "&#92;")
                            .Replace("\b", "&nbsp;")
                            .Replace("\f", "&nbsp;");
    }

    //Gets each POI and make the format required by the map.
    public string GetAllLocations()
    {

        StringBuilder retstrmarks = new StringBuilder();
        string initialCharacter = string.Empty;
        Organization lastMapNxPoiMap = null;
        string lastHTMLInfo = string.Empty;
        var organizationQuery = (from org in entityCommentComponent.Organization
                                 orderby org.Latitude, org.Longitude
                                 where org.Latitude != null && org.Longitude != null && org.Latitude != 0 && org.Longitude != 0
                                 select org
                                ).OrderBy(o => o.Latitude).ToList();

        foreach (var item in organizationQuery)
        {
            string curHTMLInfo = string.Empty;//Contains the HTML for detail solutions

            StringBuilder html = new StringBuilder("");

            var listSolution = item.Solutions.Where(n => n.SolutionState >= 1000 && (n.Deleted == false || n.Deleted == null)).ToList();

            if (listSolution.Count > 0)
            {
                html.Append("<a href=\"" + NexsoHelper.GetCulturedUrlByTabName("insprofile") + "/in/" +
                              item.OrganizationID + "\"><h3 class='gg'>" + ReplaceChars(ReplaceChars(item.Name)) + "</h3></a>");

                html.Append("<ul class=\"title-map\">");

                foreach (var item2 in listSolution)
                {

                    html.Append("<li  class=\"item-map\"><a href=\"" +
                                NexsoHelper.GetCulturedUrlByTabName("solprofile") +
                                "/sl/" + item2.SolutionId.ToString() + "\">" + ReplaceChars(item2.Title) + "</a></li>");

                }

                html.Append("</ul>");


                curHTMLInfo = html.ToString();

                if (lastMapNxPoiMap != null)
                {

                    if (retstrmarks.ToString().Length == 0)
                        initialCharacter = "{";
                    else
                        initialCharacter = ",{";
                    //If there are organizations in the same geographic point.
                    if (lastMapNxPoiMap.Latitude.Equals(item.Latitude) &&
                        lastMapNxPoiMap.Longitude.Equals(item.Longitude))
                    {
                        lastMapNxPoiMap.Code = string.Format("{0} - {1}", lastMapNxPoiMap.Code, item.Code);
                        lastHTMLInfo = string.Format("{0}{1}", lastHTMLInfo, curHTMLInfo);
                        lastMapNxPoiMap.Name = string.Format("{0} - {1}", lastMapNxPoiMap.Name, ReplaceChars(item.Name));
                    }
                    else
                    {
                        //Get the marks for a Organization object in JSON format.
                        string strMarkData = GetMarkData(lastMapNxPoiMap, lastHTMLInfo, initialCharacter);
                        retstrmarks.Append(strMarkData);
                        lastMapNxPoiMap = item;
                        lastHTMLInfo = curHTMLInfo;
                    }
                }
                else
                {
                    lastMapNxPoiMap = item;
                    lastHTMLInfo = curHTMLInfo;
                }
            }
        }

        //Set last POI
        if (lastMapNxPoiMap != null)
        {
            if (retstrmarks.ToString().Length == 0)
                initialCharacter = "{";
            else
                initialCharacter = ",{";
            //Get the marks for a Organization object in JSON format.
            string marks = GetMarkData(lastMapNxPoiMap, lastHTMLInfo, initialCharacter);

            retstrmarks.Append(marks);

        }

        //Complete list of objects in JSON format
        string retstrAllObject = string.Format("{0}{2}{1}", "[", "];", retstrmarks.ToString());


        return retstrAllObject;
    }

    public void BindData()
    {
        iconPin = String.Format("{0}Images/marker-gray.png", PortalSettings.HomeDirectory);
        LoadParams();
        LoadCoordinates();
        Locations = GetAllLocations();
    }

    #endregion

    #region Subclasses



    #endregion

    #region Events

    /// <summary>
    /// Override Event OnInit
    /// </summary>
    /// <param name="e">EventArgs e</param>
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        DotNetNuke.Framework.jQuery.RequestDnnPluginsRegistration();
        ClientAPI.RegisterClientReference(this.Page, ClientAPI.ClientNamespaceReferences.dnn);
        entityCommentComponent = new MIFNEXSOEntities();
    }

    /// <summary>
    /// Event Load of the current Page.
    /// </summary>
    /// <param name="sender">Object sender.</param>
    /// <param name="e">EventArgs e</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            if (!IsPostBack)
            {
                BindData();
            }
        }
        catch (Exception exc) //Module failed to load
        {
            Exceptions.ProcessModuleLoadException(this, exc);
        }
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