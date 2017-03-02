<%@ control language="C#" autoeventwireup="true" inherits="EasyDNNSolutions.Modules.EasyDNNNews.GeneralSettings, App_Web_generalsettings.ascx.d988a5ac" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<div id="EDNadmin">
	<div class="module_settings">
		<div class="settings_category_container">
			<div class="category_toggle">
				<h2>
					<%=GeneralSettingsTitle%></h2>
			</div>
			<div class="category_content">
				<table class="settings_table" cellpadding="0" cellspacing="0">
					<tr>
						<td align="center" colspan="2">
							<asp:Label ID="lbljQueryConfig" runat="server" Text="Jquery Configuration" Font-Bold="True" Font-Size="Large" resourcekey="lbljQueryConfigResource1"></asp:Label>
						</td>
					</tr>
					<tr class="second">
						<td class="left">
							<asp:Label ID="lblIncludeJquery" runat="server" Text="Include jQuery:" resourcekey="lblIncludeJqueryResource1"></asp:Label>
						</td>
						<td class="right">
							<asp:CheckBox ID="cbIncludeJquery" runat="server" resourcekey="cbIncludeJqueryResource1" />
						</td>
					</tr>
					<tr class="second">
						<td class="left">
							&nbsp;
						</td>
						<td class="right">
							<asp:Label ID="lblJqueryWarning" runat="server" Text="Please do NOT include jQuery if you are using DotNetNuke version 6 and above." resourcekey="lblJqueryWarningResource1"></asp:Label>
						</td>
					</tr>
					<tr>
						<td class="left">
							<asp:Label ID="lbljQueryNoConflict" runat="server" Text="Run jQuery in no confilct mode:" resourcekey="lbljQueryNoConflictResource1"></asp:Label>
						</td>
						<td class="right">
							<asp:CheckBox ID="cbjQueryNoConflictMode" runat="server" resourcekey="cbjQueryNoConflictModeResource1" />
						</td>
					</tr>
					<tr>
						<td class="left">
							&nbsp;
						</td>
						<td class="right">
							<asp:Label ID="lblJqueryWarning0" runat="server" Text="Please do NOT run jQuery in conflict mode if you are using DotNetNuke version 6 and above." resourcekey="lblJqueryWarning0Resource1"></asp:Label>
						</td>
					</tr>
					<tr class="second">
						<td align="center" colspan="2">
							<asp:Label ID="lblArticlehistory" runat="server" Text="Article history" Font-Bold="True" Font-Size="Large" resourcekey="lblArticlehistoryResource1"></asp:Label>
						</td>
					</tr>
					<tr>
						<td class="left">
							<dnn:Label ID="lblArticleHistoryArchive" runat="server" Text="Number of article history versions:" HelpText="Set how many article history versions should be in archive:" HelpKey="lblArticleHistoryArchive.HelpText" ResourceKey="lblArticleHistoryArchive">
							</dnn:Label>
						</td>
						<td class="right">
							<asp:TextBox ID="tbArticleHistoryVersion" runat="server" Width="40px" ValidationGroup="vgGeneralSettings">10</asp:TextBox>
							&nbsp;<asp:RequiredFieldValidator ID="rfvArticleHistoryVersion" runat="server" ControlToValidate="tbArticleHistoryVersion" ErrorMessage="This filed is required." ValidationGroup="vgGeneralSettings" Visible="False" SetFocusOnError="True" resourcekey="rfvModuleWidthResource1"></asp:RequiredFieldValidator>
						</td>
					</tr>
					<tr class="second">
						<td class="left">
							&nbsp;
						</td>
						<td class="right">
							&nbsp;
						</td>
					</tr>
					<tr class="second">
						<td colspan="2" align="center">
							<asp:Label ID="lblPageTitleConfigTitle" runat="server" Text="Page title configuration" Font-Bold="True" Font-Size="Large" resourcekey="lblPageTitleConfigTitleResource1"></asp:Label>
						</td>
					</tr>
					<tr>
						<td class="left">
							<dnn:Label ID="lblPageTitleConfig" runat="server" Text="Configure article page title. Select the items and you want to appear in page title and set their positions. Below you can preview what each page title will look like." HelpText="Configure article page title. Select the items and you want to appear in page title and set their positions. Below you can preview what each page title will look like.">
							</dnn:Label>
						</td>
						<td class="right">
							<asp:GridView ID="gvPageTitleFormating" runat="server" AutoGenerateColumns="False" EnableModelValidation="True" CssClass="grid_view_table" OnRowCommand="gvPageTitleFormating_RowCommand" OnDataBound="gvPageTitleFormating_DataBound" Width="250px" resourcekey="gvPageTitleFormatingResource1">
								<Columns>
									<asp:TemplateField HeaderText="Item" HeaderStyle-CssClass="title" ItemStyle-CssClass="title" SortExpression="Title">
										<ItemTemplate>
											<asp:HiddenField ID="hfID" runat="server" Value='<%# Eval("ID") %>'></asp:HiddenField>
											<asp:Label ID="Label1" runat="server" Text='<%# Bind("Item") %>' resourcekey="Label1Resource1"></asp:Label>
										</ItemTemplate>
										<HeaderStyle CssClass="title"></HeaderStyle>
										<ItemStyle CssClass="title"></ItemStyle>
									</asp:TemplateField>
									<asp:TemplateField HeaderText="Visible" HeaderStyle-CssClass="title" ItemStyle-CssClass="title" SortExpression="Title">
										<ItemTemplate>
											<asp:CheckBox ID="cbVisible" runat="server" Checked='<%# Bind("Visible") %>' AutoPostBack="True" OnCheckedChanged="cbVisible_CheckedChanged" resourcekey="cbVisibleResource1"></asp:CheckBox>
										</ItemTemplate>
										<HeaderStyle CssClass="title"></HeaderStyle>
										<ItemStyle CssClass="title" HorizontalAlign="Center"></ItemStyle>
									</asp:TemplateField>
									<asp:TemplateField HeaderText="Position" HeaderStyle-CssClass="arrows" ItemStyle-CssClass="arrows">
										<ItemTemplate>
											<asp:HiddenField ID="hfPosition" runat="server" Value='<%# Eval("Position") %>'></asp:HiddenField>
											<asp:LinkButton ID="lbDocMoveDown" CommandArgument='<%# ((GridViewRow) Container).RowIndex %>' CommandName="Down" runat="server" CssClass="arrow down" resourcekey="lbDocMoveDownResource1">Down</asp:LinkButton>
											<asp:LinkButton ID="lbDocMoveUp" CommandArgument='<%# ((GridViewRow) Container).RowIndex %>' CommandName="Up" runat="server" CssClass="arrow up" resourcekey="lbDocMoveUpResource1">Up</asp:LinkButton>
										</ItemTemplate>
										<HeaderStyle CssClass="arrows"></HeaderStyle>
										<ItemStyle CssClass="arrows" HorizontalAlign="Center"></ItemStyle>
									</asp:TemplateField>
								</Columns>
								<AlternatingRowStyle CssClass="second" />
								<EditRowStyle />
								<HeaderStyle CssClass="header_row" HorizontalAlign="Center" />
								<PagerStyle />
								<RowStyle />
							</asp:GridView>
						</td>
					</tr>
					<tr>
						<td class="left">
							<dnn:Label ID="lblItemSeparator" runat="server" Text="Title item separator:" HelpText="Title item separator:"></dnn:Label>
						</td>
						<td class="right">
							<asp:TextBox ID="tbSeparator" runat="server" AutoPostBack="True" MaxLength="5" OnTextChanged="tbSeparator_TextChanged" Width="35px">-</asp:TextBox>
						</td>
					</tr>
					<tr>
						<td class="left">
							<dnn:Label ID="lblPreview" runat="server" Text="Page title preview when article is open:" HelpText="Page title preview when article is open:" HelpKey="lblPreview.HelpText" ResourceKey="lblPreview"></dnn:Label>
						</td>
						<td class="right">
							<asp:Label ID="lblPageTitlePreview" runat="server" resourcekey="lblPageTitlePreviewResource1"></asp:Label>
						</td>
					</tr>
					<tr>
						<td class="left">
							<dnn:Label ID="lblCatList" runat="server" Text="Page title preview when listing categories:" HelpText="Page title preview when listing categories:" HelpKey="lblCatList.HelpText" ResourceKey="lblCatList"></dnn:Label>
						</td>
						<td class="right">
							<asp:Label ID="lblPageCategoryTitlePreview" runat="server" resourcekey="lblPageCategoryTitlePreviewResource1"></asp:Label>
						</td>
					</tr>
					<tr>
						<td class="left">
							<dnn:Label ID="lblTagList" runat="server" Text="Page title preview when listing tags:" HelpText="Page title preview when listing tags:" HelpKey="lblTagList.HelpText" ResourceKey="lblTagList"></dnn:Label>
						</td>
						<td class="right">
							<asp:Label ID="lblPageTagTitlePreview" runat="server" resourcekey="lblPageTagTitlePreviewResource1"></asp:Label>
						</td>
					</tr>
					<tr>
						<td class="left">
							<dnn:Label ID="lblAuthorList" runat="server" Text="Page title preview when listing articles by author:" HelpText="Page title preview when listing articles by author:" HelpKey="lblAuthorList.HelpText" ResourceKey="lblAuthorList"></dnn:Label>
						</td>
						<td class="right">
							<asp:Label ID="lblPageAuthorTitlePreview" runat="server" resourcekey="lblPageAuthorTitlePreviewResource1"></asp:Label>
						</td>
					</tr>
					<tr id="trDaylightSavingTimeTitle" runat="server" class="second">
						<td colspan="2" align="center">
							<asp:Label ID="lblDaylightTime" runat="server" Text="Daylight saving time" Font-Bold="True" Font-Size="Large"></asp:Label>
						</td>
					</tr>
					<tr id="trDaylightSavingTime" runat="server">
						<td class="left">
							<dnn:Label ID="lblDaylightSavingTime" runat="server" Text="Use daylight saving time:" HelpText="Calculate DST shift into dates."></dnn:Label>
						</td>
						<td class="right">
							<asp:CheckBox ID="cbDaylightSavingTime" runat="server" />
						</td>
					</tr>
					<tr>
						<td class="left">
							&nbsp;
						</td>
						<td class="right">
							&nbsp;</td>
					</tr>
				</table>
				<asp:UpdatePanel ID="upPermissionSettings" runat="server">
					<ContentTemplate>
						<table class="settings_table" cellpadding="0" cellspacing="0">
							<tr>
								<td align="center" colspan="2">
									<asp:Label ID="lblPortalRoles" runat="server" resourcekey="lblPortalRoles" Text="Custom portal roles" Font-Bold="True" Font-Size="Large" />
								</td>
							</tr>
							<tr class="second">
								<td class="left">
									<dnn:Label ID="lblCustomRoles" resourcekey="lblCustomRoles" runat="server" Text="Manually select available Security Roles:" HelpText="Possibility to manually select which Security roles will be available in Settings > 1. Permissions. After adding or deleting a role it is necessary to save the settings." />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbCustomRoles" runat="server" OnCheckedChanged="cbCustomRoles_CheckedChanged" AutoPostBack="true" />
								</td>
							</tr>
						</table>
						<table id="idCustomRoles" runat="server" class="settings_table" cellpadding="0" cellspacing="0">
							<tr class="second">
								<td align="center" colspan="2">
									<asp:Label ID="lblRoleInfo" runat="server" Font-Bold="True" />
								</td>
							</tr>
							<tr class="second">
								<td class="left">
									<asp:Label ID="lblNotSelectedRolesTitle" resourcekey="lblNotSelectedRolesTitle" runat="server" Font-Bold="True" Text="Available Security Roles:" />
								</td>
								<td class="right">
									<asp:Label ID="lblSelectedRoles" resourcekey="lblSelectedRoles" runat="server" Font-Bold="True" Text="Selected Security Roles:" />
								</td>
							</tr>
							<tr class="second">
								<td class="left">
									<asp:ListBox ID="lboxNotSelectedRoles" runat="server" Style="min-width: 250px; min-height: 250px;" SelectionMode="Multiple" />
								</td>
								<td class="right">
									<asp:Button ID="btnRemoveRoleToPortal" runat="server" Text="<<" OnClick="lbRemoveRoleToPortal_Click" ToolTip="Remove" ValidationGroup="lboxSelectedRoles" CausesValidation="true" />
									<asp:Button ID="btnAddRoleToPortal" runat="server" Text=">>" OnClick="lbAddRoleToPortal_Click" ToolTip="Add" ValidationGroup="lboxNotSelectedRoles" CausesValidation="true" />
									<asp:ListBox ID="lboxSelectedRoles" runat="server" Style="min-width: 250px; min-height: 250px;" SelectionMode="Multiple" ValidationGroup="lboxSelectedRoles" />
								</td>
							</tr>
							<tr class="second">
								<td align="center" colspan="2">
									<asp:RequiredFieldValidator ID="rfvNotSelectedRoles" ValidationGroup="lboxNotSelectedRoles" ControlToValidate="lboxNotSelectedRoles" runat="server" ForeColor="Red" ErrorMessage="Please select role to add!" Display="Dynamic" SetFocusOnError="True" />
									<asp:RequiredFieldValidator ID="rfvSelectedRoles" ValidationGroup="lboxSelectedRoles" ControlToValidate="lboxSelectedRoles" runat="server" ForeColor="Red" ErrorMessage="Please select role to remove!" Display="Dynamic" SetFocusOnError="True" />
								</td>
							</tr>
						</table>
					</ContentTemplate>
				</asp:UpdatePanel>
				<asp:UpdateProgress ID="uppPermissionSettings" runat="server" AssociatedUpdatePanelID="upPermissionSettings" DisplayAfter="100" DynamicLayout="true">
					<ProgressTemplate>
						<img src="<%=ModulePath%>images/settings/ajaxLoading.gif" /></ProgressTemplate>
				</asp:UpdateProgress>
			</div>
		</div>
		<div>
		
							<asp:Label ID="lblMessage" runat="server" EnableViewState="False" Font-Bold="True" resourcekey="lblMessageResource1"></asp:Label>
		
		</div>
		<div class="main_actions">
			<div class="buttons">
				<asp:Button ID="btnSaveSettings" runat="server" OnClick="btnSaveSettings_Click" Text="Save settings" ValidationGroup="vgGeneralSettings" resourcekey="btnSaveSettingsResource1" />
				<asp:Button ID="btnClose" runat="server" OnClick="btnClose_Click" Text="Close" ValidationGroup="vgGeneralSettings" resourcekey="btnCloseResource1" />
			</div>
		</div>
	</div>
</div>
