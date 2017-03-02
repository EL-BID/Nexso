using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Security;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Entities.Users;
using DotNetNuke.Services.Localization;
using Telerik.Web.UI;
using NexsoProBLL;
using NexsoProDAL;
using DotNetNuke.Services.Exceptions;
/// <summary>
/// BACKEND
/// This modulo is control grid of telerik. for judes administration for challenge.
/// Judes Asigning permission, rules and solutions
/// https://www.nexso.org/en-us/Backend/ChallengeEngine/AdminJudges/cll/EconomiaNaranja
/// </summary>
public partial class NZJudgesChallenge : PortalModuleBase, IActionable
{
    #region Private Member Variables
    private ChallengeJudgeComponent challengeJudgeComponent;
    private string challenge;
    #endregion

    #region Private Properties


    #endregion

    #region Private Methods
    /// <summary>
    /// Load name of challenge via querystring
    /// </summary>
    private void LoadParams()
    {
        if (string.IsNullOrEmpty(challenge))
        {
            if (Request.QueryString["cll"] != string.Empty)
                try
                {
                    challenge = Request.QueryString["cll"];
                }
                catch
                {
                    challenge = string.Empty;

                }

            else
                challenge = string.Empty;
        }
    }

    /// <summary>
    /// Set solution checkbox
    /// </summary>
    /// <param name="list"></param>
    /// <param name="checkBoxList"></param>
    private void SetChkControl(List<JudgesAssignation> list, CheckBoxList checkBoxList)
    {
        StringBuilder str = new StringBuilder();
        ListItem item;
        foreach (var itemL in list)
        {
            item = checkBoxList.Items.FindByValue(itemL.SolutionId.ToString());
            if (item != null)
            {
                item.Selected = true;
            }
        }

    }

    /// <summary>
    /// GetSolutions per judge
    /// </summary>
    /// <param name="list"></param>
    /// <returns></returns>
    private string GetAssignedSolutions(List<JudgesAssignation> list)
    {

        string txt = string.Empty;

        var listSolutionsAux = SolutionComponent.GetPublishSolutionPerChallenge(challenge).Where(x => x.Deleted == false || x.Deleted == null).OrderBy(x => x.Title).ToList();

        int count = 1;
        foreach (var item in listSolutionsAux)
        {
            var existItem = list.Exists(x => x.SolutionId == item.SolutionId);
            if (existItem)
                txt = txt + "<span style=\"margin-right:1em;\"><b>" + count.ToString() + ".</b></span><a href='" + NexsoHelper.GetCulturedUrlByTabName("solprofile") + "/sl/" + item.SolutionId + "' Target=\"_blank\" style=\"color:#3786bd;\">" + item.Title + "<a> - " + item.Language + " - " + NexsoHelper.GetCulturedUrlByTabName("solprofile") + "/sl/" + item.SolutionId + "<br/>";

            count++;
        }

        return txt;
    }

    /// <summary>
    /// Delete and assign solutions to jury
    /// </summary>
    /// <param name="challengeJudgeId"></param>
    /// <param name="checkBoxList"></param>
    /// <returns></returns>
    private bool SaveChkControl(Guid challengeJudgeId, CheckBoxList checkBoxList)
    {
        if (JudgesAssignationComponent.deleteListPerChallengeJudgeId(challengeJudgeId))
        {
            string result = string.Empty;
            foreach (ListItem item in checkBoxList.Items)
            {
                if (item.Selected)
                {
                    JudgesAssignationComponent judgesAssignationComponent = new JudgesAssignationComponent();
                    judgesAssignationComponent.JudgesAssignation.ChallengeJudgeId = challengeJudgeId;
                    judgesAssignationComponent.JudgesAssignation.SolutionId = new Guid(item.Value);
                    judgesAssignationComponent.JudgesAssignation.JudgeAssigantionId = Guid.NewGuid();
                    judgesAssignationComponent.Save();

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
    /// Load Judge and solutions per judge
    /// </summary>
    public void DataBind()
    {
        var list = ChallengeJudgeComponent.GetChallengeJudges(challenge);

        List<JudgeChallenge> listJudgesChallenge = new List<JudgeChallenge>();
        foreach (var item in list)
        {

            var userProfile = new UserPropertyComponent(item.UserId);

            listJudgesChallenge.Add(new JudgeChallenge
            {
                ChallengeJudgeId = item.ChallengeJudgeId,
                UserId = Convert.ToInt32(userProfile.UserProperty.UserId),
                FirstName = userProfile.UserProperty.FirstName + " " + userProfile.UserProperty.LastName,
                Email = userProfile.UserProperty.email,
                PermisionLevel = item.PermisionLevel,
                FromDate = Convert.ToDateTime(item.FromDate),
                ToDate = Convert.ToDateTime(item.ToDate),
                AssignedSolutions = GetAssignedSolutions(item.JudgesAssignations.OrderBy(x => x.Solution.Title).ToList())
            });

        }
        if (listJudgesChallenge.Count() == 0)
            btnExport.Visible = false;

        grdManageJudge.DataSource = listJudgesChallenge;

    }

    /// <summary>
    /// Load ALl users in the platform
    /// </summary>
    /// <returns></returns>
    public List<UserProperty> BindUsers()
    {
        try
        {
            MIFNEXSOEntities nx = new MIFNEXSOEntities();
            return nx.UserProperties.ToList();
        }
        catch (Exception x)
        {
            return null;
        }
    }

    /// <summary>
    /// Export items in grid to excel
    /// </summary>
    public void ConfigureExport()
    {
        grdManageJudge.ExportSettings.ExportOnlyData = true;
        grdManageJudge.ExportSettings.IgnorePaging = true;
        grdManageJudge.ExportSettings.OpenInNewWindow = true;
        grdManageJudge.ExportSettings.UseItemStyles = true;
        grdManageJudge.ExportSettings.FileName = string.Format("ReportJudges_{0}_{1}", challenge, DateTime.Now);


    }

    #endregion

    #region Protected Methods


    #endregion

    #region Subclasses
    public class JudgeChallenge
    {

        public Guid ChallengeJudgeId { get; set; }
        public int UserId { get; set; }
        public string FirstName { get; set; }
        public string Email { get; set; }
        public string PermisionLevel { get; set; }
        public DateTime FromDate { get; set; }
        public DateTime ToDate { get; set; }
        public string AssignedSolutions { get; set; }

    }
    public class Generic
    {
        public Guid Id { get; set; }
        public string Text { get; set; }
    }


    #endregion

    #region Events
    /// <summary>
    /// Verifiy if Current user is NexsoSupport or Administrator
    /// </summary>
    /// <param name="e"></param>
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        LoadParams();
        if (!IsPostBack)
        {
            if (!UserController.GetCurrentUserInfo().IsInRole("Administrators") && !UserController.GetCurrentUserInfo().IsInRole("NexsoSupport"))
            {
                Exceptions.ProcessModuleLoadException(this, new Exception("UserID: " + UserController.GetCurrentUserInfo().UserID + " - Email: " + UserController.GetCurrentUserInfo().Email + " - " + DateTime.Now + " - Security Issue"));
                Response.Redirect("/error/403.html");
            }
            hlPdf.NavigateUrl = "/portals/" + PortalId + "/Challenges/Administracion-jueces.pdf";
        }
    }
    protected void RadGrid1_NeedDataSource(object sender, GridNeedDataSourceEventArgs e)
    {
        DataBind();
    }

    /// <summary>
    /// Load information to the grid. This method allows you to filter and sort the grid by various parameters (fisrtname, email, permissions, todate, fromdate).
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RadGrid1_ItemDataBound(object sender, Telerik.Web.UI.GridItemEventArgs e)
    {

        if (e.Item is GridEditFormItem && e.Item.IsInEditMode)
        {

            GridEditFormItem edititem = (GridEditFormItem)e.Item;

            RadComboBox rdEmail = (RadComboBox)edititem.FindControl("rdEmail");

            MIFNEXSOEntities nx = new MIFNEXSOEntities();

            rdEmail.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
            rdEmail.DataSource = nx.UserProperties.ToList();
            rdEmail.DataBind();


            RadComboBox rdPermisionLevel = (RadComboBox)edititem.FindControl("rdPermisionLevel");
            var list = ListComponent.GetListPerCategory("PermisionLevel", Thread.CurrentThread.CurrentCulture.Name).ToList();
            rdPermisionLevel.EmptyMessage = Localization.GetString("SelectItem", this.LocalResourceFile);
            rdPermisionLevel.DataSource = list;
            rdPermisionLevel.DataBind();


            CheckBoxList cblSolutions = (CheckBoxList)edititem.FindControl("cblSolutions");

            var listSolutionsAux = SolutionComponent.GetPublishSolutionPerChallenge(challenge).Where(x => x.Deleted == false || x.Deleted == null).OrderBy(x => x.Title);
            List<Generic> listGeneric = new List<Generic>();

            int count = 1;
            foreach (var item in listSolutionsAux)
            {

                var text = "<span style=\"margin-right:1em;\"><b>" + count.ToString() + ".</b></span><a href='" + NexsoHelper.GetCulturedUrlByTabName("solprofile") + "/sl/" + item.SolutionId + "' Target=\"_blank\" style=\"color:#3786bd;\">" + item.Title + "<a> - " + item.Language;


                listGeneric.Add(new Generic { Id = item.SolutionId, Text = text });
                count++;
            }

            cblSolutions.DataSource = listGeneric;
            cblSolutions.DataBind();


            if (!(e.Item is GridEditFormInsertItem))
            {

                try
                {

                    int UserId = Convert.ToInt32(DataBinder.Eval(e.Item.DataItem, "UserId"));

                    var userProfile = new UserPropertyComponent(UserId);

                    string challengeJudgeId = DataBinder.Eval(e.Item.DataItem, "ChallengeJudgeId").ToString();
                    challengeJudgeComponent = new ChallengeJudgeComponent(new Guid(challengeJudgeId));

                    TextBox txtEmail = (TextBox)edititem.FindControl("txtEmail");
                    txtEmail.Text = userProfile.UserProperty.email;
                    txtEmail.Enabled = false;
                    txtEmail.Visible = true;
                    rdEmail.Visible = false;
                    RequiredFieldValidator rfvrdEmail = (RequiredFieldValidator)edititem.FindControl("rfvrdEmail");
                    rfvrdEmail.Visible = false;
                    rfvrdEmail.ValidationGroup = string.Empty;
                    var itemm = (RadComboBoxItem)rdPermisionLevel.Items.FindItemByValue(challengeJudgeComponent.ChallengeJudge.PermisionLevel);
                    if (itemm != null)
                    {
                        itemm.Selected = true;
                        itemm.Checked = true;
                    }



                    var itemmaux = (RadComboBoxItem)rdEmail.Items.FindItemByValue(userProfile.UserProperty.UserId.ToString());
                    if (itemmaux != null)
                    {
                        itemmaux.Selected = true;
                        itemmaux.Checked = true;
                    }


                    RadDatePicker dtFromDate = (RadDatePicker)edititem.FindControl("dtFromDate");
                    dtFromDate.SelectedDate = Convert.ToDateTime(challengeJudgeComponent.ChallengeJudge.FromDate);

                    RadDatePicker dtToDate = (RadDatePicker)edititem.FindControl("dtToDate");
                    dtToDate.SelectedDate = Convert.ToDateTime(challengeJudgeComponent.ChallengeJudge.ToDate);


                    var listJudgesAssignations = challengeJudgeComponent.ChallengeJudge.JudgesAssignations.ToList();



                    SetChkControl(listJudgesAssignations, cblSolutions);
                }
                catch
                {

                }

            }
        }
    }

    /// <summary>
    /// Update information about juries (permissions), Also is possible to update the solution per jury
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
                TextBox txtChallengeJudgeId = (TextBox)editItem.FindControl("txtChallengeJudgeId");
                string challengeJudgeId = txtChallengeJudgeId.Text;
                RadComboBox rdEmail = (RadComboBox)editItem.FindControl("rdEmail");
                RadComboBox rdPermisionLevel = (RadComboBox)editItem.FindControl("rdPermisionLevel");
                RadDatePicker dtFromDate = (RadDatePicker)editItem.FindControl("dtFromDate");
                RadDatePicker dtToDate = (RadDatePicker)editItem.FindControl("dtToDate");
                HiddenField hfuserId = (HiddenField)editItem.FindControl("hfuserId");
                CheckBoxList cblSolutions = (CheckBoxList)editItem.FindControl("cblSolutions");


                int intValue;
                int userId = -1;
                if (Int32.TryParse(rdEmail.SelectedValue, out intValue))
                {
                    userId = Int32.Parse(rdEmail.SelectedValue);
                }
                if (userId != -1)
                {
                    if (string.IsNullOrEmpty(challengeJudgeId))
                    {
                        challengeJudgeComponent = new ChallengeJudgeComponent();
                        challengeJudgeComponent.ChallengeJudge.ChallengeReference = challenge;
                        challengeJudgeComponent.ChallengeJudge.UserId = userId;
                    }
                    else
                    {
                        challengeJudgeComponent = new ChallengeJudgeComponent(new Guid(challengeJudgeId));
                    }

                    if (rdPermisionLevel.SelectedValue != string.Empty)
                        challengeJudgeComponent.ChallengeJudge.PermisionLevel = rdPermisionLevel.SelectedValue;




                    challengeJudgeComponent.ChallengeJudge.FromDate = dtFromDate.SelectedDate;
                    challengeJudgeComponent.ChallengeJudge.ToDate = dtToDate.SelectedDate;


                    if (challengeJudgeComponent.Save() > 0)
                    {


                        if (!SaveChkControl(challengeJudgeComponent.ChallengeJudge.ChallengeJudgeId, cblSolutions))
                        {
                            return;
                        }

                        if (editItem.ItemIndex != -1)
                            this.grdManageJudge.MasterTableView.Items[editItem.ItemIndex].Edit = false;
                        else
                            e.Item.OwnerTableView.IsItemInserted = false;

                        this.grdManageJudge.MasterTableView.Rebind();
                    }
                }
                else
                {
                    RequiredFieldValidator rfvrdEmail = (RequiredFieldValidator)editItem.FindControl("rfvrdEmail");
                    rfvrdEmail.IsValid = false;
                }
            }
        }
    }

    /// <summary>
    /// Delete Judge
    /// </summary>
    /// <param name="source"></param>
    /// <param name="e"></param>
    protected void RadGrid1_DeleteCommand(object source, Telerik.Web.UI.GridCommandEventArgs e)
    {
        string ID = e.Item.OwnerTableView.DataKeyValues[e.Item.ItemIndex]["ChallengeJudgeId"].ToString();
        challengeJudgeComponent = new ChallengeJudgeComponent(new Guid(ID));

        JudgesAssignationComponent.deleteListPerChallengeJudgeId(challengeJudgeComponent.ChallengeJudge.ChallengeJudgeId);
        challengeJudgeComponent.Delete();

        this.grdManageJudge.MasterTableView.Rebind();
    }

    /// <summary>
    /// Export to Excel
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnExport_Click(object sender, EventArgs e)
    {

        this.grdManageJudge.MasterTableView.Columns.FindByUniqueName("EditCommandColumn").Visible = false;
        this.grdManageJudge.MasterTableView.Columns.FindByUniqueName("DeleteColumn").Visible = false;

        this.grdManageJudge.MasterTableView.Columns.FindByUniqueName("AssignedSolutions").Visible = true;


        ConfigureExport();

        grdManageJudge.MasterTableView.ExportToExcel();



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
