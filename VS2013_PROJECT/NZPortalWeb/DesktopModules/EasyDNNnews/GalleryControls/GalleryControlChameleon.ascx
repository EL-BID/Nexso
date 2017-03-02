<%@ control language="C#" autoeventwireup="true" inherits="EasyDNNSolutions.Modules.EasyDNNNews.GalleryControlChameleon, App_Web_gallerycontrolchameleon.ascx.1b1ab6" %>
<asp:Label ID="lblMessage" runat="server" Visible="False"></asp:Label>
<asp:Literal ID="ltchameleonJavaScript" runat="server" EnableViewState="False" Visible="True"></asp:Literal>
<div id="mainChameleonWrap" class="article_gallery" runat="server">
	<div id="ChameleonGallery">
		<div id="eds_sliderM<%=ModuleId%>" class="chameleon_slider <%=CSSThemeDisplayStyle%>">
		</div>
	</div>
</div>
