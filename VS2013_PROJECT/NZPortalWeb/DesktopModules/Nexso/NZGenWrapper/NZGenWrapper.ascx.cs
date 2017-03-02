using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Services.Localization;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Security;
using NexsoProDAL;
using NexsoProBLL;
using System.Net;

/// <summary>
/// This module has two functions:
/// Download documents
/// 1) This componet if  download the documents.
/// https://www.nexso.org/cheese/file/e3155a53-b8ae-4f25-8391-7548dda41738
/// Obtaining information reading an email sent by NexsoChimp
/// 2) Get information log of emails sending for the aplication
/// https://www.nexso.org/cheese/clog/e3155a53-b8ae-4f25-8391-7548dda41738
/// </summary>
public partial class NZGenWrapper : UserUserControlBase, IActionable
{

    #region Private Member Variables
    private Guid fileId;
    private Guid campaignLog;
    #endregion

    #region Private Properties


    #endregion

    #region Private Methods

    /// <summary>
    /// Check via query string if a file or email
    /// </summary>
    private void LoadParams()
    {
        if (!string.IsNullOrEmpty(Request.QueryString["file"]))
        {
            try
            {
                fileId = new Guid(Request.QueryString["file"]);
            }
            catch (Exception e)
            {
                throw;
            }
        }
        if (!string.IsNullOrEmpty(Request.QueryString["clog"]))
        {
            try
            {
                campaignLog = new Guid(Request.QueryString["clog"]);
            }
            catch (Exception e)
            {
                throw;
            }
        }
    }

    /// <summary>
    /// Update the log of the email: Change status to read, obtain information to the hour, date, ip and place. 
    /// </summary>
    private void ProcessCampaignTracker()
    {
        try
        {
            HttpRequest request = base.Request;
            string ip = request.UserHostAddress;
            var req = Request;
            CampaignLogComponent campaignLogComponent = new CampaignLogComponent(campaignLog);
            campaignLogComponent.CampaignLog.ReadOn = DateTime.Now;
            campaignLogComponent.CampaignLog.Status = "READ";
            campaignLogComponent.Save();
            //end the resposne
            var ipLocation = MIFWebServices.IpLocationService.getIpLocation(ip);
            if (ipLocation.isp == null)
            {
                IPHostEntry ipEntry = Dns.GetHostEntry(Dns.GetHostName());
                IPAddress[] addr = ipEntry.AddressList;
                ip = addr[1].ToString();
                ipLocation = MIFWebServices.IpLocationService.getIpLocation(ip);
            }
            string device = "DESKTOP";
            if (Request.Browser.IsMobileDevice)
                device = "MOBILE";
            MailTrackerLogComponent mailTrackerLog = new MailTrackerLogComponent();
            mailTrackerLog.MailTrackerLog.CampaingLogId = campaignLogComponent.CampaignLog.CampaignLogId;
            mailTrackerLog.MailTrackerLog.Browser = Request.Browser.Browser;
            mailTrackerLog.MailTrackerLog.Country = ipLocation.country;
            mailTrackerLog.MailTrackerLog.City = ipLocation.city;
            mailTrackerLog.MailTrackerLog.Latitude = Convert.ToDecimal(ipLocation.latitude);
            mailTrackerLog.MailTrackerLog.Longitude = Convert.ToDecimal(ipLocation.longitude);
            mailTrackerLog.MailTrackerLog.Device = device;
            mailTrackerLog.MailTrackerLog.IP = ipLocation.ip;
            if (Request.UserLanguages != null)
            {
                if (Request.UserLanguages.Count() > 0)
                    mailTrackerLog.MailTrackerLog.Language = Request.UserLanguages[0];
            }
            mailTrackerLog.MailTrackerLog.Network = ipLocation.isp;

            mailTrackerLog.Save();
        }
        catch
        {

        }
        Response.ContentType = "image/png";
        Response.WriteFile(MapPath(ControlPath + "/images/i_dn.png"));
        Response.End();

    }
    #endregion

    #region Public Properties



    #endregion

    #region Public Methods

    /// <summary>
    /// Download the file and accumulates the number of downloads 
    /// </summary>
    public void DownloadFile()
    {
        byte[] objectFile;
        DocumentComponent documentComponent = new DocumentComponent(fileId);
        if (documentComponent.Document.DocumentId != Guid.Empty)
        {

            string filename = string.Empty;
            if (!string.IsNullOrEmpty(documentComponent.Document.Name))
                filename = documentComponent.Document.Name + documentComponent.Document.FileType;
            else
            {
                if (!string.IsNullOrEmpty(documentComponent.Document.Title))
                    filename = documentComponent.Document.Title + documentComponent.Document.FileType;
                else
                    filename = "File" + documentComponent.Document.FileType;
            }

            if (documentComponent.Document.Scope == "1")
            {
                documentComponent.Document.Views = documentComponent.Document.Views + 1;
                documentComponent.Document.Read = DateTime.Now;
                documentComponent.Save();
                objectFile = documentComponent.Document.DocumentObject;
                Response.Clear();
                Response.ClearContent();
                Response.ClearHeaders();
                Response.Buffer = true;
                Response.AppendHeader("content-disposition", "attachment; filename=\"" + filename + "\"");
                Response.BinaryWrite(objectFile);
                Response.Flush();
                Response.End();
            }
            if (documentComponent.Document.Scope == "2")//issue seg
            {
                documentComponent.Document.Views = documentComponent.Document.Views + 1;
                documentComponent.Document.Read = DateTime.Now;
                documentComponent.Save();
                objectFile = documentComponent.Document.DocumentObject;
                Response.Clear();
                Response.ClearContent();
                Response.ClearHeaders();
                Response.Buffer = true;
                Response.AppendHeader("content-disposition", "attachment; filename=\"" + filename + "\"");
                Response.BinaryWrite(objectFile);
                Response.Flush();
                Response.End();
            }
            lblMessage.Text = Localization.GetString("Rights", LocalResourceFile);

        }
        lblMessage.Text = Localization.GetString("Error", LocalResourceFile);


    }



    #endregion

    #region Subclasses



    #endregion

    #region Events

    protected void Page_Load(object sender, EventArgs e)
    {
        LoadParams();
        if (fileId != Guid.Empty)
        {
            lblMessage.Text = Localization.GetString("Download", LocalResourceFile);
            DownloadFile();
        }
        else if (campaignLog != Guid.Empty)
        {
            ProcessCampaignTracker();

        }
        else
        {
            lblMessage.Text = Localization.GetString("Error", LocalResourceFile);
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