<%@ control language="C#" inherits="EasyDNN.Modules.EasyDNNNewsCategories.ViewEasyDNNNewsCategories, App_Web_vieweasydnnnewscategories.ascx.565cbe7e" autoeventwireup="true" enableviewstate="false" %>
<asp:Label ID="lblSettingsInfo" runat="server" Visible="false" />
<div id="<%=MainDivID%>" class="<%=MainDivClass%>">
	<asp:PlaceHolder ID="ednMenu" runat="server" />
</div>
<asp:Label ID="lblCatMessage" runat="server" resourcekey="lblCatMessage" Text="Please edit and save settings." Visible="false" />