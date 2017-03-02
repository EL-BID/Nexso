using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using DotNetNuke.Entities.Modules;
using NexsoProBLL;
using NexsoProDAL;
using System.IO;
using System.Threading;
using DotNetNuke.Entities.Users;
using DotNetNuke.Services.Localization;
using DotNetNuke.Services.Exceptions;
using GhostscriptSharp;

/// <summary>
/// This controls is for load archives in the system. All, this moment in implement in the sulution create.
/// User FileUploader.js
/// </summary>
public partial class FileUploaderWizard : PortalModuleBase
{

    #region Private Member Variables

    private Guid documentId;
    #endregion

    #region Private Properties


    #endregion

    #region Private Methods

    /// <summary>
    /// Registers the client script with the Page object using a key and a URL, which enables the script to be called from the client.
    /// </summary>
    private void RegisterScripts()
    {
        if (!IsPostBack)
        {
            Page.ClientScript.RegisterClientScriptInclude(
                this.GetType(), "fileUploader", ControlPath + "resources/js/FileUploader.js");



            string script = "<script> function onClientFileUploaded" + ClientID + "(sender, args) {" +
                                "document.getElementById('" + RadButton1.ClientID + "').click();}"
                                +


                                " function OnClientValidationFailed" + ClientID + "(sender,args) {" +
                                    " processException(sender,args,'" + ClientID + "'); " +
                                    "}" +
                                " function openPopUpPdfViewer(id)" +
        "{$(\"#dialog-modal-file\").html('<iframe src=\"/DesktopModules/Nexso/nxothercontrols/pdfviewer/viewer.html?file=/cheese/file/' + id + '\" style=\"border:0px #FFFFFF none;\" name=\"myiFrame\" scrolling=\"no\" frameborder=\"0\" marginheight=\"0px\" marginwidth=\"0px\" height=\"100%\" width=\"100%\"></iframe>');" +
        "$(\"#dialog-modal-file\").dialog({ height: $(window).height() * .9, width: $(window).width() * .9, modal: true, dialogClass: \"ui-dialog ui-widget ui-widget-content ui-corner-all ui-front dnnFormPopup ui-draggable ui-resizable\"" +
        " }); }" + "</script>";


            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "script" + ClientID, script);
        }

    }
    protected string GetTextCategory(string key)
    {

        if (IsChallengeFiles)
        {
            return ListComponent.GetLabelFromListKey("ChallengeFile", System.Threading.Thread.CurrentThread.CurrentCulture.Name, key);
        }
        else
        {
            return ListComponent.GetLabelFromListKey("FileCategory", System.Threading.Thread.CurrentThread.CurrentCulture.Name, key);
        }
    }

    /// <summary>
    /// Enable labels and buttons. For upload files
    /// </summary>
    private void PopulateLabels()
    {
        rgvtxtDescription.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
        rgvtxtFileName.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
        rgvtxtTitle.ErrorMessage = Localization.GetString("InvalidFormat", LocalResourceFile);
        aUploadFile.Localization.Select = Localization.GetString("btnUpload", this.LocalResourceFile);
        if (!string.IsNullOrEmpty(DocumentDefaultMode))
        {
            rdbScope.Visible = false;
            lblScope.Visible = false;
            rdbScope.SelectedValue = DocumentDefaultMode;
        }

        if (!ShowFileCategories)
        {
            lblCategory.Visible = false;
            ddCategory.Visible = false;
            rfvddCategoryDocument.Visible = false;
            if (DefaultCategory != string.Empty)
                ddCategory.SelectedValue = DefaultCategory;
            else
                ddCategory.SelectedValue = "Other";
        }
        SolutionComponent solution = new SolutionComponent(SolutionId);
        if (solution.Solution.SolutionId != Guid.Empty)
        {
            if (UserId == solution.Solution.CreatedUserId || UserController.GetCurrentUserInfo().IsInRole("Administrators") || UserController.GetCurrentUserInfo().IsInRole("NexsoSupport"))
            {
                aUploadFile.Visible = true;
                rdProgressAreaUploadFile.Visible = true;
            }
        }
        if (IsChallengeFiles)
        {
            aUploadFile.Visible = true;
            rdProgressAreaUploadFile.Visible = true;
        }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="title"></param>
    /// <param name="name"></param>
    /// <param name="fileType"></param>
    /// <returns>Title of the document</returns>
    protected string TitleDocument(string title, string name, string fileType)
    {
        string titleDocument = string.Empty;

        if (!string.IsNullOrEmpty(title))
        {
            if (!string.IsNullOrEmpty(name))
            {
                return titleDocument = title + " (" + name + fileType + ")";
            }
            else
            {
                return titleDocument = title + " (" + title + fileType + ")";
            }
        }
        else
        {
            if (!string.IsNullOrEmpty(name))
            {
                return titleDocument = name + fileType;
            }
            else
                return titleDocument = "File" + fileType;
        }
    }
    #endregion

    #region Constructors



    #endregion

    #region Public Member Variables
    public DocumentComponent documentComponent;
    public ChallengeFileComponent challengeFileComponent;
    #endregion

    #region Public Properties
    public int DocumentsLoaded
    {

        get
        {
            if (ViewState["DocumentsLoaded"] != null)
                return (int)ViewState["DocumentsLoaded"];
            else
                return 0;
        }
        set { ViewState["DocumentsLoaded"] = value; }
    }

    public byte[] Bytes
    {
        get { return (byte[])ViewState["Bytes"]; }
        set { ViewState["Bytes"] = value; }
    }
    public string FileName
    {
        get { return (string)ViewState["FileName"]; }
        set { ViewState["FileName"] = value; }
    }
    public int FileSize
    {
        get { return (int)ViewState["FileSize"]; }
        set { ViewState["FileSize"] = value; }
    }
    public string ExtensionName
    {
        get { return (string)ViewState["ExtensionName"]; }
        set { ViewState["ExtensionName"] = value; }
    }
    public Guid DocumentId
    {
        get { return (Guid)ViewState["DocumentId"]; }
        set { ViewState["DocumentId"] = value; }
    }
    public int Count
    {
        get { return (int)ViewState["Count"]; }
        set { ViewState["Count"] = value; }
    }

    public bool ShowFileCategories
    {
        get
        {
            if (ViewState["ShowFileCategories"] != null)
                return (bool)ViewState["ShowFileCategories"];
            else
                return true;
        }
        set { ViewState["ShowFileCategories"] = value; }
    }

    public string DefaultCategory
    {
        get { return (string)ViewState["DefaultCategory"]; }
        set { ViewState["DefaultCategory"] = value; }
    }

    public int Maximum
    {

        get
        {
            if (ViewState["Maximum"] != null)
                return (int)ViewState["Maximum"];
            else
                return 0;
        }
        set { ViewState["Maximum"] = value; }
    }
    public Guid SolutionId
    {
        get
        {
            try
            {
                return (Guid)ViewState["SoliId"];
            }
            catch
            {
                return Guid.Empty;
            }
        }

        set { ViewState["SoliId"] = value; }
    }

    public string DocumentDefaultMode
    {
        get { return ViewState["DocumentDefaultMode"].ToString(); }
        set { ViewState["DocumentDefaultMode"] = value; }
    }

    public string Folder
    {
        get { return ViewState["Folder"].ToString(); }
        set { ViewState["Folder"] = value; }
    }
    public List<string> Folders
    {
        get
        {
            if (ViewState["Folders"] != null)
            {
                return (List<string>)ViewState["Folders"];
            }
            else
                return null;
        }
        set { ViewState["Folders"] = value; }
    }

    public bool IsChallengeFiles
    {
        get
        {
            if (ViewState["IsChallengeFiles"] != null)
                return (bool)ViewState["IsChallengeFiles"];
            else
                return false;
        }
        set { ViewState["IsChallengeFiles"] = value; }
    }
    public string ChallengeReference
    {
        get
        {
            if (ViewState["ChallengeReference"] != null)
                return ViewState["ChallengeReference"].ToString();
            else
                return null;
        }

        set { ViewState["ChallengeReference"] = value; }
    }

    public string TextTitle
    {
        get
        {
            if (ViewState["TextTitle"] != null)
                return ViewState["TextTitle"].ToString();
            else
                return Localization.GetString("Title", LocalResourceFile);
        }

        set { ViewState["TextTitle"] = value; }
    }
    public string TextTitleValidator
    {
        get
        {
            if (ViewState["TextTitleValidator"] != null)
                return ViewState["TextTitleValidator"].ToString();
            else
                return Localization.GetString("rfvtxtTitle", LocalResourceFile);
        }

        set { ViewState["TextTitleValidator"] = value; }
    }
    public string Language
    {
        get
        {
            if (ViewState["Language"] != null) return ViewState["Language"].ToString();
            else
                return "en-US";
        }
        set { ViewState["Language"] = value; }
    }
    IList<Telerik.Web.UI.UploadedFile> files;


    #endregion

    #region Public Methods

    /// <summary>
    /// Load information to the controls (textbox and dropdownlist)
    /// </summary>
    public void BindData()
    {
        var listEmptyItem = new NexsoProDAL.List();
        listEmptyItem.Key = "0";
        listEmptyItem.Label = Localization.GetString("SelectItem", LocalResourceFile);
        var list = ListComponent.GetListPerCategory("FileCategory", Thread.CurrentThread.CurrentCulture.Name).ToList();
        if (IsChallengeFiles)
        {

            list = ListComponent.GetListPerCategory("ChallengeFile", Thread.CurrentThread.CurrentCulture.Name).ToList();
            list.Insert(0, listEmptyItem);
            ddCategory.DataSource = list;
            ddCategory.DataBind();
            txtTitle.Visible = true;
            lblTitle.Visible = true;
            lblDescription.Visible = false;
            txtDescription.Visible = false;
            RadButton1.ValidationGroup = "ChallengeFiles";
            btnBackUpdate.ValidationGroup = "ChallengeFiles";
            btnBackUpdate.ValidationGroup = "ChallengeFiles";
            if (string.IsNullOrEmpty(ChallengeReference))
            {
                aUploadFile.Enabled = false;
                rdProgressAreaUploadFile.Visible = false;
            }
            else
            {
                aUploadFile.Enabled = true;
                rdProgressAreaUploadFile.Visible = true;
            }
        }
        else
        {
            list.Insert(0, listEmptyItem);
            ddCategory.DataSource = list;
            ddCategory.DataBind();
        }
        FillDataRepeater();
        list = ListComponent.GetListPerCategory("FileScope", Thread.CurrentThread.CurrentCulture.Name).ToList();
        rdbScope.DataSource = list;
        rdbScope.DataBind();
        lblTitle.Text = TextTitle;
        rfvtxtTitle.Text = TextTitleValidator;
    }

    /// <summary>
    /// Load categories to the dropdownlist
    /// </summary>
    public void FillDataRepeater()
    {
        if (IsChallengeFiles)
        {
            List<NestedFile> nestedFiles = new List<NestedFile>();
            List<List> list = ListComponent.GetListPerCategory("ChallengeFile", Thread.CurrentThread.CurrentCulture.Name).ToList();
            List<ChallengeFile> fileList = null;
            DocumentsLoaded = 0;
            foreach (var item in list)
            {
                fileList = ChallengeFileComponent.GetFilesForChallenge(ChallengeReference, item.Label).ToList().Where(a => a.Delete == false || a.Delete == null).ToList();
                if (fileList.Count > 0)
                {
                    nestedFiles.Add(new NestedFile() { files = fileList, list = item });
                    DocumentsLoaded = DocumentsLoaded + fileList.Count;
                }
            }
            if (nestedFiles.Count > 0)
                lblEmptyMessage.Visible = false;
            else
                lblEmptyMessage.Visible = true;

            rCategory.DataSource = nestedFiles;
            rCategory.DataBind();
        }
        else
        {
            List<NestedDocument> nestedDocuments = new List<NestedDocument>();
            List<List> list = ListComponent.GetListPerCategory("FileCategory", Thread.CurrentThread.CurrentCulture.Name).ToList();
            List<Document> documentList = null;
            DocumentsLoaded = 0;
            foreach (var item in list)
            {
                if (Folders != null)
                {
                    foreach (var item2 in Folders)
                    {
                        documentList = DocumentComponent.GetDocuments(SolutionId, item.Key, item2);
                        if (documentList.Count > 0)
                        {
                            nestedDocuments.Add(new NestedDocument() { documents = documentList, list = item });
                            DocumentsLoaded = DocumentsLoaded + documentList.Count;
                        }
                    }
                }
                else
                {
                    documentList = DocumentComponent.GetDocuments(SolutionId, item.Key, Folder);
                    if (documentList.Count > 0)
                    {
                        nestedDocuments.Add(new NestedDocument() { documents = documentList, list = item });
                        DocumentsLoaded = DocumentsLoaded + documentList.Count;
                    }
                }

            }
            if (nestedDocuments.Count > 0)
                lblEmptyMessage.Visible = false;
            else
                lblEmptyMessage.Visible = true;

            rCategory.DataSource = nestedDocuments;
            rCategory.DataBind();
        }
    }

    /// <summary>
    /// Clear textbox and dropdownlist
    /// </summary>
    public void Clear()
    {
        ddCategory.SelectedValue = "0";
        txtDescription.Text = string.Empty;
        txtFileName.Text = FileName;
        txtTitle.Text = string.Empty;
        lblExtension.Text = ExtensionName;
        rdbScope.Items[0].Selected = true;
    }
    #endregion

    #region Events




    #endregion

    #region Subclasses
    public class NestedDocument
    {
        public NexsoProDAL.List list { get; set; }
        public List<Document> documents { get; set; }
    }
    public class NestedFile
    {
        public NexsoProDAL.List list { get; set; }
        public List<ChallengeFile> files { get; set; }
    }


    #endregion

    #region Events
    /// <summary>
    /// Load settings of the module
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Page_Load(object sender, EventArgs e)
    {
        aUploadFile.OnClientFileUploaded = "onClientFileUploaded" + ClientID;
        aUploadFile.OnClientValidationFailed = "OnClientValidationFailed" + ClientID;
        //if (DefaultCategory == "Blueprint") Allow files for 10MB size
        aUploadFile.MaxFileSize = 10240000;   
        RegisterScripts();
    }

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PopulateLabels();
        if (!IsPostBack)
        {
            BindData();
        }
    }

    /// <summary>
    /// Load settings of the module
    /// </summary>
    /// <param name="e"></param>
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

    /// <summary>
    /// This event is raised for the header, the footer, separators, and items. Execute the following logic for Items and Alternating Items.
    /// </summary>
    /// <param name="Sender"></param>
    /// <param name="e"></param>
    protected void ItemDataBound(Object Sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            if (IsChallengeFiles)
            {
                var imageControl = (LinkButton)e.Item.FindControl("ibtnEditFile");
                imageControl.ToolTip = Localization.GetString("lnkEdit", LocalResourceFile);
                imageControl.Visible = true;
                imageControl.ValidationGroup = "ChallengeFiles";
            }
            else
            {
                Document man = (Document)e.Item.DataItem;
                if (man != null)
                {
                    var imageControl = (LinkButton)e.Item.FindControl("ibtnEdit");
                    imageControl.ToolTip = Localization.GetString("lnkEdit", LocalResourceFile);
                    if (man.CreatedBy != UserController.GetCurrentUserInfo().UserID)
                        imageControl.Visible = false;
                }
            }
        }
    }

    protected void aUploadFileUpdate_FileUploaded(object sender, Telerik.Web.UI.FileUploadedEventArgs e)
    {

    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="id"></param>
    /// <param name="category"></param>
    /// <returns>Thumb Image</returns>
    protected string GetThumbImage(Guid id, string category)
    {
        if (category == "Blueprint")
        {
            if (File.Exists(MapPath("/Portals/0/ModIma/ThumbImages/pdf-" + id.ToString() + ".jpg")))
                return "/Portals/0/ModIma/ThumbImages/pdf-" + id.ToString() + ".jpg";
            return string.Empty;
        }
        return string.Empty;
    }

    /// <summary>
    /// Upload file to the server
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RadAsyncUpload1_FileUploaded(object sender, Telerik.Web.UI.FileUploadedEventArgs e)
    {
        if (aUploadFile.UploadedFiles.Count > 0)
        {
            WizardFile.MoveTo(WizardStep2);
            FileName = Path.GetFileNameWithoutExtension(aUploadFile.UploadedFiles[0].FileName);
            ExtensionName = Path.GetExtension(aUploadFile.UploadedFiles[0].FileName);
            FileSize = Convert.ToInt32(aUploadFile.UploadedFiles[0].ContentLength);
            Bytes = new byte[aUploadFile.UploadedFiles[0].InputStream.Length];
            aUploadFile.UploadedFiles[0].InputStream.Read(Bytes, 0, (int)aUploadFile.UploadedFiles[0].InputStream.Length);
            String pathServerTemp = Server.MapPath("Portals/0/Images/Temp/");
            if (!Directory.Exists(pathServerTemp))
                Directory.CreateDirectory(pathServerTemp);
            try
            {
                File.WriteAllBytes(pathServerTemp + FileName + ExtensionName, Bytes);
            }
            catch (Exception ex)
            {
            }
            WizardFile.ActiveStepIndex = 1;
            Clear();
            CreateFile.Visible = true;
            UpdateFile.Visible = false;
        }
    }

    /// <summary>
    /// Update information of the file in the database
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnUpdate_Click(object sender, EventArgs e)
    {
        try
        {
            if (IsChallengeFiles)
            {
                challengeFileComponent = new ChallengeFileComponent(DocumentId);
                challengeFileComponent.ChallengeFile.Updated = DateTime.Now;
                challengeFileComponent.ChallengeFile.ObjectName = ValidateSecurity.ValidateString(txtTitle.Text, false);
                challengeFileComponent.ChallengeFile.ObjectType = ddCategory.SelectedItem.Text;
                try
                {
                    string pathServer = Server.MapPath(ddCategory.SelectedValue);
                    string sourceFile = System.IO.Path.Combine(Server.MapPath(challengeFileComponent.ChallengeFile.ObjectLocation));
                    string destFile = System.IO.Path.Combine(pathServer, ValidateSecurity.ValidateString(txtFileName.Text, false) + ValidateSecurity.ValidateString(lblExtension.Text, false));
                    if (!Directory.Exists(pathServer))
                        Directory.CreateDirectory(pathServer);
                    if (System.IO.File.Exists(sourceFile))
                    {
                        if (!System.IO.File.Exists(destFile))
                            System.IO.File.Move(sourceFile, destFile);
                        else
                        {
                            System.IO.File.Delete(destFile);
                            System.IO.File.Move(sourceFile, destFile);
                        }
                    }
                    challengeFileComponent.ChallengeFile.ObjectLocation = ddCategory.SelectedValue + ValidateSecurity.ValidateString(txtFileName.Text, false) + ValidateSecurity.ValidateString(lblExtension.Text, false);
                    challengeFileComponent.Save();
                }
                catch { }
            }
            else
            {
                documentComponent = new DocumentComponent(DocumentId);
                documentComponent.Document.Updated = DateTime.Now;
                documentComponent.Document.UploadedBy = UserId;
                documentComponent.Document.Version++;
                documentComponent.Document.Title = ValidateSecurity.ValidateString(txtTitle.Text, false);
                documentComponent.Document.Name = ValidateSecurity.ValidateString(txtFileName.Text, false);
                documentComponent.Document.Description = ValidateSecurity.ValidateString(txtDescription.Text, false);
                documentComponent.Document.Scope = rdbScope.SelectedValue;
                documentComponent.Document.Category = ddCategory.SelectedValue;
                documentComponent.Save();
            }
            FillDataRepeater();
            Count = 0;
            WizardFile.ActiveStepIndex = 0;
        }
        catch (Exception exc)
        {
            Exceptions.
                ProcessModuleLoadException(
                this, exc);
        }
    }

    /// <summary>
    /// Save document in the server
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSave_Click(object sender, EventArgs e)
    {
        try
        {
            string pathServerTemp = Server.MapPath("Portals/0/Images/Temp/");
            string pathServerThumbImages = Server.MapPath("Portals/0/ModIma/ThumbImages/");
            if (IsChallengeFiles)
            {
                if (string.IsNullOrEmpty(ValidateSecurity.ValidateString(txtTitle.Text, false)))
                {
                    rgvtxtTitle.IsValid = false;
                    return;
                }
                //Information of the document
                challengeFileComponent = new ChallengeFileComponent(Guid.NewGuid());
                challengeFileComponent.ChallengeFile.Created = DateTime.Now;
                challengeFileComponent.ChallengeFile.Updated = challengeFileComponent.ChallengeFile.Created;
                challengeFileComponent.ChallengeFile.ObjectName = txtFileName.Text;
                challengeFileComponent.ChallengeFile.ObjectType = ddCategory.SelectedItem.Text;
                challengeFileComponent.ChallengeFile.Size = FileSize;
                challengeFileComponent.ChallengeFile.ObjectExtension = ExtensionName;
                challengeFileComponent.ChallengeFile.Language = Language;
                challengeFileComponent.ChallengeFile.ChallengeReferenceId = ChallengeReference;
                try
                {
                    string pathServer = Server.MapPath(ddCategory.SelectedValue);
                    string sourceFile = System.IO.Path.Combine(pathServerTemp, FileName + ExtensionName);
                    string destFile = System.IO.Path.Combine(pathServer, ValidateSecurity.ValidateString(txtFileName.Text, false) + ValidateSecurity.ValidateString(lblExtension.Text, false));

                    if (!Directory.Exists(pathServer))
                        Directory.CreateDirectory(pathServer);
                    if (System.IO.File.Exists(sourceFile))
                    {
                        if (!System.IO.File.Exists(destFile))
                            System.IO.File.Move(sourceFile, destFile);
                        else
                        {
                            System.IO.File.Delete(destFile);
                            System.IO.File.Move(sourceFile, destFile);
                        }
                    }

                    //Save document information in the database
                    challengeFileComponent.ChallengeFile.ObjectLocation = ddCategory.SelectedValue + ValidateSecurity.ValidateString(txtFileName.Text, false) + ValidateSecurity.ValidateString(lblExtension.Text, false);
                    challengeFileComponent.Save();
                }
                catch { }
            }
            else
            {
                documentComponent = new DocumentComponent(Guid.NewGuid());
                UserPropertyComponent user = new UserPropertyComponent(UserId);
                documentComponent.Document.Created = DateTime.Now;
                documentComponent.Document.CreatedBy = UserId;
                documentComponent.Document.Updated = documentComponent.Document.Created;
                documentComponent.Document.Views = 0;
                documentComponent.Document.Version = 1;
                documentComponent.Document.UploadedBy = user.UserProperty.UserId;
                documentComponent.Document.Author = string.Empty;// user.UserProperty.FirstName + " " + user.UserProperty.LastName;
                documentComponent.Document.Name = ValidateSecurity.ValidateString(txtFileName.Text, false);
                documentComponent.Document.Title = ValidateSecurity.ValidateString(txtTitle.Text, false);
                documentComponent.Document.FileType = ExtensionName;
                documentComponent.Document.Deleted = false;
                documentComponent.Document.Description = ValidateSecurity.ValidateString(txtDescription.Text, false);
                documentComponent.Document.Size = FileSize;
                documentComponent.Document.Permission = "0";
                documentComponent.Document.Scope = rdbScope.SelectedValue;
                documentComponent.Document.Status = "published";
                documentComponent.Document.Category = ddCategory.SelectedValue;
                documentComponent.Document.DocumentObject = Bytes;
                documentComponent.Document.ExternalReference = SolutionId;
                documentComponent.Document.Folder = Folder;
                //Save information of the document
                if (documentComponent.Save() < 0)
                {
                    throw new Exception();
                }
                if (ExtensionName.ToUpper() == ".PDF")
                    GhostscriptWrapper.GeneratePageThumb(pathServerTemp + FileName + ExtensionName, pathServerThumbImages + "pdf-" + documentComponent.Document.DocumentId.ToString() + ".jpg", 1, 150, 150, 300, 300);

            }
            FillDataRepeater();
            WizardFile.ActiveStepIndex = 0;
        }
        catch (Exception exc)
        {
            Exceptions.
                ProcessModuleLoadException(
                this, exc);
        }
    }

    protected void ibtnEdit_Click(object sender, EventArgs e)
    {
        if (IsChallengeFiles)
        {
            LinkButton ee = (LinkButton)sender;
            string documentId = (string)ee.CommandArgument;
            DocumentId = new Guid(documentId);
            challengeFileComponent = new ChallengeFileComponent(new Guid(documentId));
            WizardFile.ActiveStepIndex = 1;
            txtFileName.Text = challengeFileComponent.ChallengeFile.ObjectName;
            lblExtension.Text = challengeFileComponent.ChallengeFile.ObjectExtension;
            var list = ListComponent.GetListPerCategory("ChallengeFile", Thread.CurrentThread.CurrentCulture.Name).FirstOrDefault(a => a.Label == challengeFileComponent.ChallengeFile.ObjectType);
            ddCategory.SelectedValue = list.Key;
        }
        else
        {
            LinkButton ee = (LinkButton)sender;
            string documentId = (string)ee.CommandArgument;
            DocumentId = new Guid(documentId);
            documentComponent = new DocumentComponent(new Guid(documentId));
            WizardFile.ActiveStepIndex = 1;
            ddCategory.SelectedValue = documentComponent.Document.Category;
            txtTitle.Text = documentComponent.Document.Title;
            txtFileName.Text = documentComponent.Document.Name;
            lblExtension.Text = documentComponent.Document.FileType;
            txtDescription.Text = documentComponent.Document.Description;
            rdbScope.SelectedValue = documentComponent.Document.Scope;
        }
        UpdateFile.Visible = true;
        CreateFile.Visible = false;
    }

    protected void btnBack_Click(object sender, EventArgs e)
    {
        WizardFile.ActiveStepIndex = 0;
        Count = 0;
    }

    /// <summary>
    /// Delete document row of the database
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDeleteUpdate_Click(object sender, EventArgs e)
    {
        if (IsChallengeFiles)
        {
            //Logical delete
            challengeFileComponent = new ChallengeFileComponent(DocumentId);
            challengeFileComponent.ChallengeFile.Updated = DateTime.Now;
            challengeFileComponent.ChallengeFile.Delete = true;
            challengeFileComponent.Save();
        }
        else
        {
            //physical delete
            documentComponent = new DocumentComponent(DocumentId);
            documentComponent.Delete();
        }
        FillDataRepeater();
        WizardFile.ActiveStepIndex = 0;
    }

    /// <summary>
    /// Select category of the document: awards, certifications, images, press
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void rCategory_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        //Challenge engine wizard
        if (IsChallengeFiles)
        {
            NestedFile files = (NestedFile)e.Item.DataItem;
            if (files != null)
            {
                Repeater rptModelsFile = (Repeater)e.Item.FindControl("rFile");
                Repeater rptModels = (Repeater)e.Item.FindControl("rDocument");
                rptModels.Visible = false;
                rptModelsFile.DataSource = files.files;
                rptModelsFile.DataBind();
            }
        }
        else
        {
            NestedDocument man = (NestedDocument)e.Item.DataItem;
            if (man != null)
            {
                Repeater rptModels = (Repeater)e.Item.FindControl("rDocument");
                Repeater rptModelsFile = (Repeater)e.Item.FindControl("rFile");
                rptModelsFile.Visible = true;

                rptModels.DataSource = man.documents;
                rptModels.DataBind();

                if (Maximum > 0)
                {
                    if (Maximum == man.documents.Count() || Maximum < man.documents.Count())
                    {
                        aUploadFile.Visible = false;
                        aUploadFile.Enabled = false;
                    }
                    else
                    {
                        aUploadFile.Visible = true;
                        aUploadFile.Enabled = true;
                    }
                }
            }
        }
    }
    #endregion
}