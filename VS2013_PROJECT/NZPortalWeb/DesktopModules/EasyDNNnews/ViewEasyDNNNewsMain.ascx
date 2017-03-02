<%@ control language="C#" inherits="EasyDNNSolutions.Modules.EasyDNNNews.ViewEasyDNNNewsMain, App_Web_vieweasydnnnewsmain.ascx.d988a5ac" autoeventwireup="true" enableviewstate="true" %>
<asp:PlaceHolder ID="phArtContaioner" runat="server" />
<asp:Panel ID="pnlFirstRun" runat="server" Visible="False" EnableViewState="false">
	<h3>Welcome to the EasyDNNnews module</h3>
	<asp:Panel ID="pnlFREditSettings" runat="server">
		Click here to setup the module and start adding articles: <asp:HyperLink ID="hlFirstSaveSettings" runat="server" Font-Bold="True">Start adding articles</asp:HyperLink>
	</asp:Panel>
	<asp:Panel ID="pnlUseGeneralSettings" runat="server" Visible="False">
		Edit and save settings: <asp:HyperLink ID="hlEditeSaveSettings" runat="server" Font-Bold="True">Open</asp:HyperLink>
		<br />
		Default settings exist:
		<asp:LinkButton ID="lbUsedefaultsettings" runat="server" OnClick="btnUseDefaultSettings_Click" Font-Bold="True">Use default settings</asp:LinkButton>
	</asp:Panel>
</asp:Panel>
<asp:Label ID="lblErrorInfo" runat="server" Visible="false" EnableViewState="false"/>