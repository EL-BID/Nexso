using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Configuration;
using DotNetNuke;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Web.DDRMenu;
using DotNetNuke.Framework;
using DotNetNuke.Common;
using DotNetNuke.Entities.Tabs;
using DotNetNuke.Entities.Users;
using DotNetNuke.Services.Exceptions;
using DotNetNuke.Services.Localization;
using DotNetNuke.Security;
using DotNetNuke.Entities.Modules.Actions;
using NexsoProDAL; 


public partial class NZSocialMediaSharingModule : PortalModuleBase, IActionable
{

    #region Private Member Variables    
	
    /// <summary>
    /// Current guid to the comments.
    /// </summary>
    private static Guid param;

    static MIFNEXSOEntities entityCommentComponent;

    #endregion

    #region Private Properties      
    private struct MetaTags
    {
        public string Url;
        public string Name;
        public string Type;
        public string Title;
        public string Image;
        public string Description;
        public string AppId;
    }
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
    /// Query the information for the solution or the organization
    /// </summary>
    /// <returns></returns>
    private MetaTags GetSolutioOrOrganizationInfo()
    {
        MetaTags metaTags = new MetaTags { Url = "", Name = "", Type = "", Title = "", Image = "", Description = "", AppId = "" };

        if (Param != Guid.Empty)
        {
            var queryOR = (from organizationQuery1 in entityCommentComponent.Organizations.AsEnumerable()
                           where organizationQuery1.OrganizationID == param
                           select new
                           {
                               organizationQuery1.Name,
                               organizationQuery1.Description,
                               organizationQuery1.Website

                           }).FirstOrDefault();

            if (queryOR == null)
            {
                var querySL = (from solution in entityCommentComponent.Solution.AsEnumerable()
                               join organizationQuery in entityCommentComponent.Organizations.AsEnumerable()
                                   on solution.OrganizationId equals organizationQuery.OrganizationID
                               where solution.SolutionId == param
                               select new
                               {
                                   solution.Title,
                                   solution.Challenge,
                                   organizationQuery.Website
                               }).FirstOrDefault();

                if (querySL != null)
                {
                    metaTags.Url = querySL.Website;
                    metaTags.Name = querySL.Title;
                    metaTags.Description = querySL.Challenge;
                }
            }
            else
            {
                metaTags.Url = queryOR.Website;
                metaTags.Name = queryOR.Name;
                metaTags.Description = queryOR.Description;
            }
        }

        return metaTags;
    }        	
    #endregion

    #region Constructors                	
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

    #endregion

    #region Public Methods              	
    #endregion

    #region Subclasses                  	
    #endregion
   
	#region Events 

    public DotNetNuke.Framework.CDefault BasePage
    {
        get
        {
            return (DotNetNuke.Framework.CDefault)(Page);
        }
    }

	protected override void OnInit(EventArgs e)
	{
		base.OnInit(e);

		LoadParams();
		entityCommentComponent = new MIFNEXSOEntities();

		MetaTags metadata = GetSolutioOrOrganizationInfo();

		//BasePage.Author = "John Doe"; 
		//BasePage.Comment = "Some Comment"; 
		//BasePage.Copyright = "Some Organization"; 
		BasePage.Description = metadata.Description;
		//BasePage.Generator = "Some Generator";
		//BasePage.KeyWords = "Keyword A, Keyword B"; 
		BasePage.Title = metadata.Name;
		//TO DO: BORRAR
		//lblTest.Text = LocalizeString("Some.Text");
	}

	/// <summary>
	/// Event load of the current page.
	/// </summary>
	/// <param name="sender">object sender</param>
	/// <param name="e">EventArgs e</param>
	protected void Page_Load(object sender, EventArgs e)
	{
		if (!IsPostBack)
		{
			RadSocialShare1.UrlToShare = Request.Url.ToString();
            if (UserInfo.Email != null)
            {
            RadSocialShare1.EmailSettings.FromEmail = UserInfo.Email;
			//RadSocialShare1.EmailSettings.SMTPServer = DotNetNuke.Entities.Host.HostSettings.GetHostSetting("SMTPServer");
                }
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