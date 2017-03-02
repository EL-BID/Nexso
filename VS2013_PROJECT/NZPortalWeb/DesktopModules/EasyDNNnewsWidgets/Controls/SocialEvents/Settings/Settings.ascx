<%@ control language="C#" autoeventwireup="true" inherits="EasyDNNSolutions.Modules.EasyDNNNews.Widgets.SettingsSocialEvents, App_Web_settings.ascx.ba6e357c" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>

<div id="EDNadmin">
	<div class="module_settings">
		<div class="settings_category_container">
			<div class="category_toggle">
				<h2>
					<%=SettingsTitle%></h2>
			</div>
			<div class="category_content">
				<h3 class="subsections">
					<%=Theme%></h3>
				<asp:UpdatePanel ID="upModuleTheme4" runat="server">
					<ContentTemplate>
						<table class="settings_table" cellpadding="0" cellspacing="0">
							<tr class="second">
								<td class="left">
									<dnn:Label ID="lblNewsModuleConnection" runat="server" Text="News module:" ControlName="ddlNewsModuleConnection" HelpText="Select news module." ResourceKey="nema" />
								</td>
								<td class="right">
									<asp:DropDownList ID="ddlNewsModuleConnection" runat="server" ValidationGroup="vgCatMenuSettings4" />
									<asp:CompareValidator ID="cvNewsModuleConnection" runat="server" ForeColor="Red" ControlToValidate="ddlNewsModuleConnection" Display="Dynamic" ErrorMessage=" Please select news module." Operator="NotEqual" ValidationGroup="vgCatMenuSettings4"
										ValueToCompare="" />
								</td>
							</tr>
							<tr class="second">
								<td class="left">
									<dnn:Label ID="lblTheme" runat="server" Text="Theme:" ControlName="ddlTheme4" HelpText="Select theme." ResourceKey="lblTheme" />
								</td>
								<td class="right">
									<asp:DropDownList ID="ddlTheme4" runat="server" OnSelectedIndexChanged="ddlTheme_SelectedIndexChanged" AutoPostBack="True" ValidationGroup="vgCatMenuSettings4" />
									<asp:CompareValidator ID="cvThemeSelect4" runat="server" ForeColor="Red" ControlToValidate="ddlTheme4" Display="Dynamic" ErrorMessage=" Please select theme." Operator="NotEqual" ValidationGroup="vgCatMenuSettings4"
										ValueToCompare="" />
								</td>
							</tr>
							<tr class="second">
								<td class="left">
									<dnn:Label ID="lblThemeStyle4" ResourceKey="lblThemeStyle4" runat="server" Text="Theme style:" ControlName="ddlThemeStyle4" HelpText="Theme style." />
								</td>
								<td class="right">
									<asp:DropDownList ID="ddlThemeStyle4" runat="server" />
								</td>
							</tr>
							<tr>
								<td class="left">
									<dnn:Label ID="lblThemeHTMLTemplate" ResourceKey="lblThemeHTMLTemplate" runat="server" Text="HTML template:" HelpText="Select HTML template." ControlName="ddlThemeHTMLTemplate4" />
								</td>
								<td class="right">
									<asp:DropDownList ID="ddlThemeHTMLTemplate4" runat="server" ValidationGroup="vgCatMenuSettings4" />
									<asp:CompareValidator ID="cvThemeHTMLTemplate" runat="server" ForeColor="Red" ControlToValidate="ddlThemeHTMLTemplate4" Display="Dynamic" ErrorMessage=" Please select HTML template" Operator="NotEqual" ValidationGroup="vgCatMenuSettings4" ValueToCompare="" />
								</td>
							</tr>
							<tr>
								<td class="left">
									<dnn:Label ID="lblShowSignUpActionBar" ResourceKey="lblShowSignUpActionBar" runat="server" Text="Show sign up action bar:" HelpText="Show sign up action bar." ControlName="cbShowSignUpActionBar" />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbShowSignUpActionBar" runat="server" />
								</td>
							</tr>
							<tr>
								<td class="left">
									<dnn:Label ID="lblShowGoingUsers" ResourceKey="lblShowGoingUsers" runat="server" Text="Show going users:" HelpText="Show going users." ControlName="cbShowGoingUsers" />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbShowGoingUsers" runat="server" />
								</td>
							</tr>
							<tr>
								<td class="left">
									<dnn:Label ID="lblShowNotGoingUsers" ResourceKey="lblShowNotGoingUsers" runat="server" Text="Show not going users:" HelpText="Show not going users." ControlName="cbShowNotGoingUsers" />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbShowNotGoingUsers" runat="server" />
								</td>
							</tr>
							<tr>
								<td class="left">
									<dnn:Label ID="lblShowMayBeGoingUsers" ResourceKey="lblShowNotGoingUsers" runat="server" Text="Show maybe going users:" HelpText="Show maybe going users." ControlName="cbShowMayBeGoingUsers" />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbShowMayBeGoingUsers" runat="server" />
								</td>
							</tr>
						</table>
					</ContentTemplate>
				</asp:UpdatePanel>
			</div>
		</div>
		<div class="main_actions">
			<p>
				<asp:Label ID="lblMainMessage" runat="server" EnableViewState="false" />
			</p>
			<div class="buttons">
				<asp:Button ID="btnSaveSettings" resourcekey="btnSaveSettings" runat="server" OnClick="btnSaveSettings_Click" Text="Save" ValidationGroup="vgCatMenuSettings4" />
				<asp:Button ID="btnSaveClose" resourcekey="btnSaveClose" runat="server" OnClick="btnSaveClose_Click" Text="Save &amp; Close" ValidationGroup="vgCatMenuSettings4" />
				<asp:Button ID="btnCancel" resourcekey="btnCancel" runat="server" OnClick="btnCancel_Click" Text="Close" />
			</div>
			<br />
			<br />
		</div>
	</div>
</div>
