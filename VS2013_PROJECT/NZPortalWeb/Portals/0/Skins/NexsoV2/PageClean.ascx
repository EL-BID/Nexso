<%@ Control Language="C#" AutoEventWireup="true" Explicit="true" Inherits="DotNetNuke.UI.Skins.Skin" %>



<script runat="server">

    private string LocalResourceFile = string.Empty;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        string FileName = System.IO.Path.GetFileNameWithoutExtension(this.AppRelativeVirtualPath);
        this.LocalResourceFile = SkinPath + "/App_LocalResources/" + this.LocalResourceFile + FileName + ".ascx.resx";
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        var page = this.Page;

        var body = page.FindControl("Body");

        if (null != body)
        {
            //  ((HtmlControl)body).Attributes.Add("class", "dnn6");
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
           string textHtml = @"<!-- Created by Anaya --><meta name=""viewport"" content=""width=device-width"">" +
                  "<input type=\"hidden\" value=\"" + System.Threading.Thread.CurrentThread.CurrentCulture.Name + "\" name=\"CurrentLanguage\"/>" +
                  "<input type=\"hidden\" value=\"" + UserController.GetCurrentUserInfo().UserID.ToString() + "\" name=\"CurrentUserId\"/>";

          var headText = new Literal()
          {
              Text = textHtml
          };

        Page.Header.Controls.Add(headText);

        var favicon = new HtmlLink { Href = SkinPath + "favicon.ico" };
        favicon.Attributes.Add("rel", "shortcut icon");
        Page.Header.Controls.Add(favicon);
      
    }


</script>



<div>
       
          
        <div id="ContentPane" runat="server" style="width: 100%;"  ></div>
      <div id="ContentPaneTop" runat="server"  ></div>
      <div id="ContentPane1" runat="server"></div>
      <div id="ContentPane2" runat="server"></div>
      <div id="ContentPane3" runat="server"></div>
      <div id="ContentPaneBottom" runat="server"></div>
     
    </div>
    