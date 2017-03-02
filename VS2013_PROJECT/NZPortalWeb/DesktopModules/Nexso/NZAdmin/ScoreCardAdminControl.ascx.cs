using System;
using System.Collections.Generic;
using System.Data.Objects.DataClasses;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Entities.Users;
using NexsoProDAL;
using NexsoProBLL;
using Telerik.Web.UI;
using DotNetNuke.Services.Localization;
using System.Threading;



public partial class ScoreCardAdminControl : PortalModuleBase
{

    #region Private Member Variables
    
    #endregion

    #region Private Properties


    #endregion

    #region Private Methods
     private void BindData()
    {
        MIFNEXSOEntities entities = new MIFNEXSOEntities();

        grdRecentSolution.DataSource = entities.Solution.Where(a => a.SolutionState == 1000 && a.Language != null && (a.Deleted == false || a.Deleted == null));

    }
  

    #endregion

    #region Public Properties



    #endregion

    #region Public Methods
    

    #endregion

    #region Protected Methods
     protected string GetScore(object scores)
    {
        EntityCollection<Score> scoreList = (EntityCollection<Score>)scores;

        StringBuilder return_ = new StringBuilder();

        double acumulate = 0;

        if (scoreList.Count > 0)
        {
            foreach (var score in scoreList)
            {
                var user = UserController.GetUserById(PortalId, score.UserId);
                if (user != null)
                {
                    return_.Append("<div>" +
                    user.DisplayName + " ( " + score.ComputedValue + " )</div>")
                    ;
                    acumulate += score.ComputedValue.GetValueOrDefault(0);
                }
                else
                {
                    return_.Append("<div>" +
                    "Anonymous" + " ( " + score.ComputedValue + " )</div>")
                    ;
                    acumulate += score.ComputedValue.GetValueOrDefault(0);
                }
            }
            acumulate = acumulate / scoreList.Count;
            return_.Append("<div><strong> Total Score (" + acumulate + ")</strong></div>");
        }
        else
        {
            return_.Append("Not Scored");
        }
        return return_.ToString();
    }

    #endregion

    #region Subclasses



    #endregion

    #region Events

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            BindData();
            grdRecentSolution.DataBind();

        }

    }
     protected void RadGrid1_NeedDataSource(object sender, GridNeedDataSourceEventArgs e)
    {
        BindData();

    }

    protected void grdRecentSolution_SortCommand(object source, GridSortCommandEventArgs e)
    {
        string orderByFormat = string.Empty;
        switch (e.NewSortOrder)
        {
            case GridSortOrder.Ascending:
                orderByFormat = "ORDER BY {0} ASC";
                break;
            case GridSortOrder.Descending:
                orderByFormat = "ORDER BY {0} DESC";
                break;
        }
        e.Item.OwnerTableView.Rebind();


    }
    #endregion

   
}

