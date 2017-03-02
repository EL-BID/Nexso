using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Services.Exceptions;
using DotNetNuke.Entities.Users;
using NexsoProBLL;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Security;
using System.Xml;
using System.Text;

public partial class NZElegibility : PortalModuleBase, IActionable
{


    #region Private Member Variables
    protected ChallengeCustomDataComponent challengeCustomDataComponent;
    protected string Language = System.Globalization.CultureInfo.CurrentUICulture.Name;
    protected SolutionComponent solutionComponent;

    private Guid solutionId;
    #endregion

    #region Private Properties


    #endregion

    #region Private Methods
    /// <summary>
    /// The id of the solution that is sent as a parameter is obtained by URL
    /// </summary>
    private void LoadParams()
    {
        if (!string.IsNullOrEmpty(Request.QueryString["sl"]))
        {
            try
            {
                solutionId = new Guid(Request.QueryString["sl"]);
            }
            catch (Exception e)
            {
                throw;
            }
        }
    }

    /// <summary>
    /// Get List eligibility criteria 
    /// </summary>
    protected void FillData()
    {
        //condition to verify if "EligibilityTemplate" is not null and it is assigned to the control
        if (challengeCustomDataComponent != null)
        {
            if (challengeCustomDataComponent.ChallengeCustomData.EligibilityTemplate != null)
            {

                var list = GetListELIGIBILITY(challengeCustomDataComponent.ChallengeCustomData.EligibilityTemplate);
                HTMLControls(list.OrderBy(x => x.position).ToList());

            }
        }

        //Is assigned to the button text as configured in the module "ButtonText"
        if (Settings.Contains("ButtonText"))
            btnContinue.Text = Settings["ButtonText"].ToString();


    }

    /// <summary>
    /// Append to the HTML the items of the list  (controls  check or Text)
    /// </summary>
    /// <param name="list"></param>
    protected void HTMLControls(List<ListGeneric> list)
    {
        StringBuilder str = new StringBuilder();
        foreach (var item in list)
        {
            switch (item.value1)
            {
                case "Check":
                    str.Append("<input type=\"checkbox\" name=\"" + item.id + "\" value=\"" + item.value2 + "\"> " + item.value2 + "</input></br>");
                    break;
                case "Text":
                    str.Append("<label> " + item.value2 + "</label> </br><input type=\"textbox\" id=\"" + item.id + "\"></input></br>");
                    break;
            }
        }
        lHtml.Text = str.ToString();
    }

    /// <summary>
    /// Load the validation's script NZElegibility.js
    /// </summary>
    private void RegisterScripts()
    {
        Page.ClientScript.RegisterClientScriptInclude(
             this.GetType(), "NZElegibility", ControlPath + "js/NZElegibility.js");
        string script = "<script>" +
             "var ResponseHTML = '" + ResponseHTML.ClientID + "';"
             + "var lHtml = '" + lHtml.ClientID + "';"
        + "</script>";
        Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Script22", script);
    }

    #endregion

    #region Public Properties
    public Guid SolutionId
    {
        get { return solutionId; }
        set { solutionId = value; }
    }
    #endregion

    #region Public Methods

    /// <summary>
    /// Get list of ELEGIBILITY from the XML
    /// </summary>
    /// <param name="xmlData"></param>
    /// <returns></returns>
    public List<ListGeneric> GetListELIGIBILITY(string xmlData)
    {
        List<ListGeneric> list = new List<ListGeneric>();
        if (!string.IsNullOrEmpty(xmlData))
        {
            var errorString = string.Empty;
            byte[] byteArray = new byte[xmlData.Length];
            System.Text.Encoding encoding = System.Text.Encoding.Unicode;
            byteArray = encoding.GetBytes(xmlData);
            // Load the memory stream
            MemoryStream memoryStream = new MemoryStream(byteArray);
            //XmlDocument doc = new XmlDocument();
            memoryStream.Seek(0, SeekOrigin.Begin);
            string TEXT, TYPE, ID, POSITION;
            if (byteArray.Length > 0)
            {
                try
                {
                    var reader = XmlReader.Create(memoryStream);
                    reader.MoveToContent();
                    while (reader.Read())
                    {
                        TEXT = TYPE = ID = POSITION = string.Empty;

                        if (reader.NodeType == XmlNodeType.Element
                            && reader.Name == "FIELD")
                        {
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "ID")
                                {
                                    ID = reader.ReadString();
                                    break;
                                }
                            }
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "TYPE")
                                {
                                    TYPE = reader.ReadString();
                                    break;
                                }
                            }
                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "TEXT")
                                {
                                    TEXT = reader.ReadString();
                                    break;
                                }
                            }


                            while (reader.Read())
                            {
                                if (reader.NodeType == XmlNodeType.Element &&
                                    reader.Name == "POSITION")
                                {
                                    POSITION = reader.ReadString();
                                    break;
                                }
                            }

                            if (!string.IsNullOrEmpty(TYPE) && !string.IsNullOrEmpty(TEXT))
                            {

                                list.Add(new ListGeneric { id = new Guid(ID), value1 = TYPE, value2 = TEXT, position = Convert.ToInt32(POSITION) });
                            }
                        }
                    }
                }
                catch
                {

                }
            }
        }
        return list.OrderBy(x => x.position).ToList();
    }


    #endregion

    #region Subclasses
    public class ListGeneric
    {
        public Guid id { get; set; }
        public string value1 { get; set; }
        public string value2 { get; set; }
        public string value3 { get; set; }
        public int position { get; set; }
    }


    #endregion

    #region Events
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            //The object of the solution is obtained
            if (Settings.Contains("ChallengeReference"))
            {
                challengeCustomDataComponent = new ChallengeCustomDataComponent(Settings["ChallengeReference"].ToString(), Language);
            }
            else
            {
                challengeCustomDataComponent = new ChallengeCustomDataComponent();
            }

            //The object of the corresponding solution is obtained
            solutionComponent = new SolutionComponent(SolutionId);
            if (!IsPostBack)
            {
                RegisterScripts();
                //data upload
                FillData();
                
            }

        }
        catch (Exception exc) //Module failed to load
        {
            Exceptions.ProcessModuleLoadException(this, exc);
        }
    }
    
    //Continue Button Event
    protected void btnContinue_Click(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(ResponseHTML.Value) && solutionComponent != null)
        {
            //The customDataLogComponent object is created and the user register is saved
            CustomDataLogComponent customDataLogComponent = new CustomDataLogComponent();
            customDataLogComponent.CustomDataLog.CustomData = ValidateSecurity.ValidateString(ResponseHTML.Value, true);
            customDataLogComponent.CustomDataLog.SolutionId = solutionComponent.Solution.SolutionId;
            customDataLogComponent.CustomDataLog.Created = DateTime.Now;
            customDataLogComponent.CustomDataLog.Updated = customDataLogComponent.CustomDataLog.Created;
            customDataLogComponent.CustomDataLog.UserId = UserController.GetCurrentUserInfo().UserID;
            customDataLogComponent.CustomDataLog.CustomDataType = "eligibilityTemplate";
            customDataLogComponent.CustomDataLog.CustomaDataSchema = challengeCustomDataComponent.ChallengeCustomData.EligibilityTemplate;
            customDataLogComponent.Save();
        }

        //redirect according module configuration, "RedirectPage". And send id solution like parameter 
        if (Settings.Contains("RedirectPage"))
            Response.Redirect(Settings["RedirectPage"].ToString() + "/sl/" + solutionComponent.Solution.SolutionId);
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