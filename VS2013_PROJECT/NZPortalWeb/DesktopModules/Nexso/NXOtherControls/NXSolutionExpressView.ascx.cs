using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DotNetNuke.Common;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Entities.Tabs;
using NexsoProBLL;
using NexsoProDAL;
using NexsoServices;

public partial class NXSolutionExpressView : PortalModuleBase
{


    #region Private Member Variables
    private Guid solutionId;
    #endregion

    #region Private Properties


    #endregion

    #region Private Methods

    private void FillFormat()
    {
        var list = SolutionListComponent.GetListPerCategory(solutionId, "DeliveryFormat");
        StringBuilder str = new StringBuilder();
        str.Append("<ul>");
        foreach (var item in list)
        {
            str.Append("<li>" + NexsoProBLL.ListComponent.GetLabelFromListKey("DeliveryFormat", Thread.CurrentThread.CurrentCulture.Name, item.Key) + "</li>");
        }
        str.Append("</ul>");
        lblFormat.Text = str.ToString();
    }
    private void FillBeneficiaries()
    {
        var list = SolutionListComponent.GetListPerCategory(solutionId, "Beneficiaries");
        StringBuilder str = new StringBuilder();
        str.Append("<ul>");
        foreach (var item in list)
        {
            str.Append("<li>" + NexsoProBLL.ListComponent.GetLabelFromListKey("Beneficiaries", Thread.CurrentThread.CurrentCulture.Name, item.Key) + "</li>");
        }
        str.Append("</ul>");
        lblBeneficiaries.Text = str.ToString();
    }
    private void FillThemes()
    {
        var list = SolutionListComponent.GetListPerCategory(solutionId, "Theme");
        StringBuilder str = new StringBuilder();
        str.Append("<ul>");
        foreach (var item in list)
        {
            str.Append("<li>" + NexsoProBLL.ListComponent.GetLabelFromListKey("Theme", Thread.CurrentThread.CurrentCulture.Name, item.Key) + "</li>");
        }
        str.Append("</ul>");
        lblTheme.Text = str.ToString();
    }

    //private void FillAvailableResources()
    //{
    //    var list = SolutionListComponent.GetListPerCategory(solutionId, "AvailableResource");
    //    StringBuilder str = new StringBuilder();
    //    str.Append("<ul>");
    //    foreach (var item in list)
    //    {
    //        str.Append("<li>" + NexsoProBLL.ListComponent.GetLabelFromListKey("AvailableResource", Thread.CurrentThread.CurrentCulture.Name, item.Key) + "</li>");
    //    }
    //    str.Append("</ul>");
    //    lblAvailableResources.Text = str.ToString();
    //}
    #endregion

    #region Public Member Variables
    TabController objTabController;
    #endregion

    #region Public Properties

    public Guid SolutionId
    {
        get { return solutionId; }
        set { solutionId = value; }
    }

    #endregion

    #region Public Methods
    public void ShowData()
    {
        objTabController = new TabController();
        if (solutionId != Guid.Empty)
        {
            SolutionComponent solutionComponent = new SolutionComponent(solutionId);
            lnkSolutionName.Text = solutionComponent.Solution.Title;
            lnkSolutionName.NavigateUrl = NexsoHelper.GetCulturedUrlByTabName("solprofile") + "/sl/" + solutionId.ToString();
            OrganizationComponent organizationComponent = new OrganizationComponent(solutionComponent.Solution.OrganizationId);
            lnkInstitutionName.Text = organizationComponent.Organization.Name;
            lnkInstitutionName.NavigateUrl = NexsoHelper.GetCulturedUrlByTabName("insprofile") + "/in/" + organizationComponent.Organization.OrganizationID;

            lblSolutionshortDescription.Text = solutionComponent.Solution.TagLine;


            lblduration.Text = ListComponent.GetLabelFromListValue("ProjectDuration", Thread.CurrentThread.CurrentCulture.Name, solutionComponent.Solution.Duration.ToString());
            // lblFormat.Text = ListComponent.GetLabelFromListValue("DeliveryFormat", Thread.CurrentThread.CurrentCulture.Name, solutionComponent.Solution.DeliveryFormat.ToString());
            FillBeneficiaries();
            FillThemes();
            FillFormat();
            LocationList1.SolutionId = solutionComponent.Solution.SolutionId;
            LocationList1.EditMode = false;
            mainPanel.Visible = true;
            EmptyPanel.Visible = false;
            LocationList1.LoadData();

            if (!string.IsNullOrEmpty(organizationComponent.Organization.Logo))
            {
                imgOrganizationLogo.ImageUrl = PortalSettings.HomeDirectory + "ModIma/Images/" +
                                          organizationComponent.Organization.Logo;

            }
            else
            {
                imgOrganizationLogo.ImageUrl = PortalSettings.HomeDirectory + "ModIma/Images/noImage.png";
            }

            imgThemeIcon.ImageUrl = Request.Url.AbsoluteUri.Replace(Request.Url.PathAndQuery, "") + ControlPath +
                                    "images/theme.png";
            imgBeneficiariesIcon.ImageUrl = Request.Url.AbsoluteUri.Replace(Request.Url.PathAndQuery, "") + ControlPath +
                                            "images/beneficiaries.png";
            btnView.CommandArgument = solutionId.ToString();
        }
        else
        {
            mainPanel.Visible = false;
            EmptyPanel.Visible = true;
        }

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
        objTabController = new TabController();
        if (!IsPostBack)
        {
            ServicePointManager.ServerCertificateValidationCallback += (sender, certificate, chain, sslPolicyErrors) => true;
            btnView.CommandArgument = solutionId.ToString();

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
    protected void btnView_Click1(object sender, EventArgs e)
    {
        Response.Redirect(NexsoHelper.GetCulturedUrlByTabName("solprofile") + "/sl/" + ((Button)sender).CommandArgument);
    }


    #endregion


}