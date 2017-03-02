<%@ Control Language="C#" AutoEventWireup="true" Explicit="true" Inherits="DotNetNuke.UI.Skins.Skin" %>
<%@ Register TagPrefix="dnn" TagName="LANGUAGE" Src="~/Admin/Skins/LanguageNexso.ascx" %>
<%@ Register TagPrefix="dnn" TagName="WD" Src="~/Admin/Nexso/NexsoDogWatcher.ascx" %>
<%@ Register TagPrefix="ddr" TagName="MENU" Src="~/DesktopModules/DDRMenu/Menu.ascx" %>
<%@ Register TagPrefix="dnn" TagName="USER" Src="~/Admin/Skins/UserNexso.ascx" %>
<%@ Register TagPrefix="dnn" Namespace="DotNetNuke.Web.Client.ClientResourceManagement" Assembly="DotNetNuke.Web.Client" %>
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

    public List<string> SessionList
    {
        get
        {
            if (Session["token"] != null)
            {
                return (List<string>)Session["token"];
            }
            else
            {
                return new List<string>();
            }
        }

        set
        {
            Session["token"] = value;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (System.Configuration.ConfigurationManager.AppSettings["RunningEnviroment"] == "TEST")
        {
            if (SessionList.Count() == 0)
            {
                SessionList.Add("check");
                Session["token"] = SessionList;
                Response.Redirect(NexsoHelper.GetCulturedUrlByTabName("LoginToken"), true);
            }
        }

                       
        string textHtml = @"<!-- Created by Anaya --><meta name=""viewport"" content=""width=device-width"">" +
                "<link href='https://fonts.googleapis.com/css?family=Open+Sans:400italic,400,700' rel='stylesheet' type='text/css' />" +
                "<input type=\"hidden\" value=\"" + System.Threading.Thread.CurrentThread.CurrentCulture.Name + "\" name=\"CurrentLanguage\"/>"+
                "<input type=\"hidden\" value=\"" + UserController.GetCurrentUserInfo().UserID.ToString() + "\" name=\"CurrentUserId\"/>";
        
        var headText = new Literal()
            {
                Text = textHtml
            };

        Page.Header.Controls.Add(headText);

        var favicon = new HtmlLink { Href = SkinPath + "favicon.ico" };
        favicon.Attributes.Add("rel", "shortcut icon");
        Page.Header.Controls.Add(favicon);
        imgLogo.Src = SkinPath + Localization.GetString("Logo.Image", LocalResourceFile);
        imgLogo.Attributes["title"] = Localization.GetString("Logo", LocalResourceFile);
        if(UserController.GetCurrentUserInfo().UserID>0)
        {
            liMySolutions.Visible = true;
        }
        else
        {
            liMySolutions.Visible = false;
        }
    }


</script>
<script type="text/javascript">
        var ua = window.navigator.userAgent;
        var msie = ua.indexOf("MSIE ");
        if (msie > 0) // If Internet Explorer, return version number
        {
            var version = parseInt(ua.substring(msie + 5, ua.indexOf(".", msie)));
            if (version <= 10)
            {
            window.location = "<%=NexsoHelper.GetCulturedUrlByTabName("NotCompatibility")%>";
            }
        }
            var match = navigator.userAgent.match(/Trident\/7\./);
            if(match)
            {
                 window.location = "<%=NexsoHelper.GetCulturedUrlByTabName("NotCompatibility")%>";
            }
</script>

<dnn:DnnCssInclude  runat="server" PathNameAlias="SkinPath" FilePath="oldCompatibiliy/fonts/font-awesome/css/font-awesome.min.css" />
<dnn:DnnCssInclude  runat="server" PathNameAlias="SkinPath" FilePath="oldCompatibiliy/fonts/geomicons/ss-geomicons-squared.css" />

<dnn:DnnJsInclude runat="server" PathNameAlias="SkinPath" FilePath="scripts/nexso-deps.min.js" Priority="90" />
<dnn:DnnJsInclude runat="server" PathNameAlias="SkinPath" FilePath="scripts/nexso_i18n.js" Priority="95" />
<dnn:DnnJsInclude runat="server" PathNameAlias="SkinPath" FilePath="scripts/nexso.v2.min.js" Priority="100" />
<dnn:DnnJsInclude runat="server" PathNameAlias="SkinPath" FilePath="scripts/nexso.min.js" Priority="105" />


<dnn:DnnCssInclude  runat="server" PathNameAlias="SkinPath" FilePath="flexible.css" />




<dnn:WD runat="server" ID="dnnWD"></dnn:WD>
<div id="site-canvas">
  <div class="off-canvas-wrap">
    <div class="inner-wrap">
        <header id="site-hdr">

          <div class="inner-hdr">
            <div class="logo">
              <h1 id="site-title">
                <a href="/default.aspx" ><img runat="server" id="imgLogo" /><span class="visually-hidden">Nexso</span></a>
              </h1>
              <a class="right-off-canvas-toggle" ><span class="visually-hidden"><%=Localization.GetString("Menu",LocalResourceFile)%></span></a>
            </div>
            <div class="right-off-canvas-menu">
              <nav class="primary">
                <ul>
                  <li class="browse"><a href="<%=NexsoHelper.GetCulturedUrlByTabName("explore")%>"><%=Localization.GetString("Explore",LocalResourceFile)%></a></li>
                  <!--<li class="share"><a href="<%=NexsoHelper.GetCulturedUrlByTabName("challenges")%>"><%=Localization.GetString("Promote",LocalResourceFile)%></a></li>-->
                

                </ul>
              </nav>
              <nav class="secondary">
                <ul>
                  <li class="search">
                    <a href="#" class="toggle"><span class="text"><%=Localization.GetString("Search",LocalResourceFile)%></span></a>
                    <div class="drop clearfix">
                        <input id="searchContent" type="search"/>
                      <a id="searchItem" ><span class="visually-hidden"><%=Localization.GetString("Search",LocalResourceFile)%></span></a>
                    </div>
                  </li>
                  <dnn:LANGUAGE runat="server" CssClass="language-object" ID="dnnLANGUAGE" ShowCountry="False" ShowLinks="True" ShowMenu="False" />
               
              
               <dnn:USER ID="dnnUser" runat="server" LegacyMode="false" ShowUnreadMessages="false" ShowAvatar="false"  />
                    <li runat="server" visible="false" id="liMySolutions" class="solutions">
                        <a href="<%=NexsoHelper.GetCulturedUrlByTabName("MySolutions")+"/ui/"+UserController.GetCurrentUserInfo().UserID.ToString()%>" ><%=Localization.GetString("MySolutions",LocalResourceFile)%></a>
                    </li>
                </ul>
              </nav>    
            </div>
          </div>
        </header>
            <main>
        <div id="ContentPane" runat="server" style="width: 100%;"  ></div>
      <div id="ContentPaneTop" runat="server"  ></div>
      <div id="ContentPane1" runat="server"></div>
      <div id="ContentPane2" runat="server"></div>
      <div id="ContentPane3" runat="server"></div>
      <div id="ContentPaneBottom" runat="server"></div>
     
    </main>
            <footer id="site-ftr">
      <div class="row">
        <div class="inner" class="clearfix">
          <nav class="secondary first clearfix">
            <h1><%=Localization.GetString("AboutNexso",LocalResourceFile)%></h1>
            <ddr:MENU ID="MENU1" MenuStyle="NEXSOMenu" runat="server" />
          </nav>
          <nav class="secondary clearfix">
            <h1><%=Localization.GetString("Support",LocalResourceFile)%></h1>
            <ul>
              <li><a href="<%=Localization.GetString("PrivacyPolicy.Link",LocalResourceFile)%>"><%=Localization.GetString("PrivacyPolicy",LocalResourceFile)%></a></li>
              <li><a href="<%=Localization.GetString("UserAgreement.Link",LocalResourceFile)%>"><%=Localization.GetString("UserAgreement",LocalResourceFile)%></a></li>
            </ul>
          </nav>
          <nav class="secondary clearfix">
            <h1><%=Localization.GetString("ConnectMedia",LocalResourceFile)%></h1>
            <ul>
              <li><a target="_blank" href="https://www.facebook.com/nexso.org">Facebook</a></li>
              <li><a target="_blank" href="https://twitter.com/nexso_org">Twitter</a></li>
            </ul>
          </nav>
        </div>
        <div class="project-by">
          <ul class="clearfix">
           <li class="idb"><a target="_blank" href="http://www.iadb.org"><img src="<%=SkinPath%><%=Localization.GetString("LogoIDB.Image",LocalResourceFile)%>" /></a></li>
            <li class="fomin"><a target="_blank" href="http://www.fomin.org"><img src="<%=SkinPath%><%=Localization.GetString("LogoMIF.Image",LocalResourceFile)%>" /></a></li>  </ul>
          <div class="attribution">
            <%=Localization.GetString("MIFCredits", LocalResourceFile)%>
          </div>
          <ul>
          </ul>
        </div>
      </div>
    </footer>
            <a class="exit-off-canvas"></a>
        </div>
    </div>
</div>



<script>
    $(document).ready(function () {

        function searchLang() {
            window.location.href = '<%=NexsoHelper.GetCulturedUrlByTabName("explore") %>/search/' + $('#searchContent').val();
        }
        $('#searchItem').on('click', searchLang);
    });




</script>