using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Runtime.Serialization.Json;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Services.Localization;
using MIFWebServices;
using NexsoProBLL;
using NexsoProDAL;
using MIFWebServices;

public partial class controls_LocationList : PortalModuleBase
{


    #region Private Member Variables
    private Guid solutionId;
    private List<SolutionLocation> solutionLocationList;

    #endregion

    #region Private Properties


    #endregion

    #region Private Methods

    private void PopulateLabels()
    {
        btnAddToList.Text = Localization.GetString("AddCountry",
                                                         LocalResourceFile);
    }

    #endregion

    #region Public Properties

    public bool EditMode { get; set; }
    public Guid SolutionId
    {
        get { return solutionId; }
        set { solutionId = value; }
    }
    

    #endregion

    #region Public Methods

    public void LoadData()
    {
        solutionLocationList = SolutionLocationComponent.GetSolutionLocationsPerSolution(solutionId).ToList();
        locationRepeater.DataSource = solutionLocationList;
        locationRepeater.EditIndex = -1;
        locationRepeater.DataBind();
    }
    public void DataBind()
    {

    }

    #endregion

    #region Subclasses



    #endregion

    #region Events
    protected void Page_Load(object sender, EventArgs e)
    {


    }
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        CountryStateCity1.WURL = ConfigurationManager.AppSettings["MifWebServiceUrl"];
        CountryStateCity1.EditMode = true;
        CountryStateCity1.ShowCitties = false;
        CountryStateCity1.ShowRegions = false;

        if (!IsPostBack)
        {
            PopulateLabels();
            if (solutionId != Guid.Empty)
            {



                LoadData();


            }
            CountryStateCity1.DataBind();

        }

        selectPanel.Visible = EditMode;

        locationRepeater.Columns[2].Visible = EditMode;


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
    protected void btnAddToList_Click(object sender, EventArgs e)
    {
        try
        {
            if (CountryStateCity1.SelectedCountry != string.Empty)
            {


                SolutionLocationComponent location = new SolutionLocationComponent(solutionId,
                                                                                   CountryStateCity1.SelectedCountry,
                                                                                   CountryStateCity1.SelectedState,
                                                                                   CountryStateCity1.SelectedCity);
                int dd = location.Save();
                LoadData();
            }
        }
        catch (Exception ee)
        {
            {
            }
            throw;
        }
    }
    protected void locationRepeater_SelectedIndexChanging(object sender, ListViewSelectEventArgs e)
    {
        ((ListView)sender).SelectedIndex = e.NewSelectedIndex;
    }
    protected void locationRepeater_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {

    }
    protected void locationRepeater_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "DELETE")
        {
            SolutionLocationComponent sol = new SolutionLocationComponent(new Guid(e.CommandArgument.ToString()));
            if (sol.SolutionLocation.SolutionLocationId != Guid.Empty)
                sol.Delete();

        }

        LoadData();
    }
    protected void locationRepeater_RowDataBound(object sender, EventArgs e)
    {

    }
    protected void locationRepeater_RowDataBound1(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.DataItem != null)
        {


            var varr = (SolutionLocation)e.Row.DataItem;


            //(<><NexsoProDAL.Organization,NexsoProDAL.Solution>)


            LinkButton linkButton = (LinkButton)e.Row.FindControl("btnDelete");
            linkButton.CommandArgument = varr.SolutionLocationId.ToString();
        }
    }

    #endregion




    
   
   
   
   

   
}

