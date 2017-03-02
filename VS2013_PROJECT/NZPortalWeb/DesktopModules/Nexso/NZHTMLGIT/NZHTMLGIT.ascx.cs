using System;
using System.Web;
using DotNetNuke.Common;
using DotNetNuke.Common.Utilities;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Entities.Users;
using DotNetNuke.Entities.Users.Membership;
using DotNetNuke.Instrumentation;
using DotNetNuke.Security;
using DotNetNuke.Security.Membership;
using DotNetNuke.Services.Localization;
using DotNetNuke.Services.Log.EventLog;
using DotNetNuke.Security;
using DotNetNuke.Entities.Modules.Actions;
using System.Net;
using System.Runtime.Serialization.Json;
using System.Collections.Generic;
using System.Text;
using System.IO;

/// <summary>
/// No Working
/// </summary>
public partial class NZHTMLGIT : UserUserControlBase, IActionable
{
    #region Private Member Variables

    #endregion

    #region Private Properties


    #endregion

    #region Private Methods
    private string readUrl(Uri uri, string userAgent, string ContentType)
    {
        try
        {
            var webClient = new WebClient();
            if (Settings["Proxy"] != null)
            {
                var proxy = new WebProxy(Settings["Proxy"].ToString());
                webClient.Proxy = proxy;

            }
            else
            {
                // webClient.Proxy = GlobalProxySelection.GetEmptyWebProxy(); 
            }
            webClient.Credentials = CredentialCache.DefaultNetworkCredentials;
            webClient.Proxy.Credentials = CredentialCache.DefaultNetworkCredentials;
            webClient.Encoding = Encoding.UTF8;
            webClient.Headers.Add("user-agent", userAgent);
            webClient.Headers.Add("Content-Type", ContentType);
            var reader = new StreamReader(webClient.OpenRead(uri));
            var return_ = reader.ReadToEnd();
            reader.Close();
            webClient.Dispose();
            return return_;
        }
        catch
        {
            throw;
        }
    }

    private string readUrl2(Uri uri, string userAgent, string ContentType)
    {

        WebRequest request = WebRequest.Create(uri);
        request.UseDefaultCredentials = true;
        WebResponse ws = request.GetResponse();
        var reader = new StreamReader(ws.GetResponseStream());
        var return_ = reader.ReadToEnd();
        reader.Close();

        return return_;

    }


    #endregion

    #region Public Properties



    #endregion

    #region Public Methods




    #endregion

    #region Subclasses

    public class ResponseGitHub
    {
        public string type { get; set; }
        public string encoding { get; set; }
        public string size { get; set; }
        public string name { get; set; }
        public string path { get; set; }
        public string content { get; set; }
        public string sha { get; set; }
        public string url { get; set; }
        public string git_url { get; set; }
        public string html_url { get; set; }
        public string download_url { get; set; }
        public List<_links> _links { get; set; }



    }
    public class _links
    {
        public string git { get; set; }
        public string self { get; set; }
        public string html { get; set; }
    }

    #endregion

    #region Events

    protected void Page_Load(object sender, EventArgs e)
    {
        string url = "";
        try
        {
            url = "https://api.github.com/repos/" + Settings["Repo"].ToString() + "/contents/" + Settings["Content"].ToString() + "?access_token=" + Settings["AccessToken"].ToString() + "&ref=" + Settings["Branch"].ToString();

            var uri = new Uri(url);

            ltResult.Text = readUrl(uri, "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; .NET CLR 1.0.3705;)", "application/json");
            /*dynamic resource = Newtonsoft.Json.JsonConvert.DeserializeObject(readUrl(uri, "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; .NET CLR 1.0.3705;)",
                "application/json"));
            string contentFile = Encoding.UTF8.GetString(Convert.FromBase64String(resource.content.ToString()));

            if (Settings["Cache"].ToString() == "False")
            {
                ltResult.Text = contentFile; 
            }
            else
            {
                ltResult.Text = "pending cache";
            }*/


        }
        catch (Exception ee)
        {
            ltResult.Text = Localization.GetString("ErrorMessage", LocalResourceFile);

            Exception hh = new Exception(ee.Message + " URL: " + url);


            DotNetNuke.Services.Exceptions.Exceptions.LogException(hh);
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