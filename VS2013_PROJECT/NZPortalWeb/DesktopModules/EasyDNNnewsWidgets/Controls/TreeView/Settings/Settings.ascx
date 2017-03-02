<%@ control language="C#" autoeventwireup="true" inherits="EasyDNNSolutions.Modules.EasyDNNNews.Widgets.SettingsTreeView, App_Web_settings.ascx.432bf0fe" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<script type="text/javascript">

	function CategoryClientValidate(source, arguments) {
		if ($('#<%=cbdisplayallcats.ClientID%>')[0].checked) {
			arguments.IsValid = true;
			return;
		}

		if ($('#advanced_tree_view_categor_selector').find('input[type="checkbox"]').filter(':checked').length > 0) {
			arguments.IsValid = true;
		} else {
			arguments.IsValid = false;
		}
	}

	function ClientValidateAuthors(source, arguments) {
		var treeView = document.getElementById("<%= tvAuthorAndGroupSelection.ClientID %>");
		var checkBoxes = treeView.getElementsByTagName("input");
		var checkedCount = 0;
		for (var i = 0; i < checkBoxes.length; i++) {
			if (checkBoxes[i].checked) {
				checkedCount++;
				break;
			}
		}
		if (checkedCount > 0) {
			arguments.IsValid = true;
		} else {
			arguments.IsValid = false;
		}
	}


	jQuery(function ($) {
		var cbAutoAddCat1 = document.getElementById('<%=cbAutoAddCatChilds.ClientID%>');
		if (cbAutoAddCat1 != null) {
			$('#advanced_tree_view_categor_selector').EDS_TreeViewSelector({
				state_checkbox: $('#<%=cbAutoAddCatChilds.ClientID %>')
			});
		}
	});
	function pageLoad(sender, args) {
		if (args.get_isPartialLoad()) {

			function CategoryClientValidate(source, arguments) {
				if ($('#<%=cbdisplayallcats.ClientID%>')[0].checked) {
					arguments.IsValid = true;
					return;
				}

				if ($('#advanced_tree_view_categor_selector').find('input[type="checkbox"]').filter(':checked').length > 0) {
					arguments.IsValid = true;
				} else {
					arguments.IsValid = false;
				}
			}

			function ClientValidateAuthors(source, arguments) {
				var treeView = document.getElementById("<%= tvAuthorAndGroupSelection.ClientID %>");
				var checkBoxes = treeView.getElementsByTagName("input");
				var checkedCount = 0;
				for (var i = 0; i < checkBoxes.length; i++) {
					if (checkBoxes[i].checked) {
						checkedCount++;
						break;
					}
				}
				if (checkedCount > 0) {
					arguments.IsValid = true;
				} else {
					arguments.IsValid = false;
				}
			}

			jQuery(function ($) {
				var cbAutoAddCat2 = document.getElementById('<%=cbAutoAddCatChilds.ClientID%>');
				if (cbAutoAddCat2 != null) {
					$('#advanced_tree_view_categor_selector').EDS_TreeViewSelector({
						state_checkbox: $('#<%=cbAutoAddCatChilds.ClientID %>')
					});
				}
			});
		}
	}
</script>
<div id="EDNadmin">
	<div class="module_settings">
		<div class="settings_category_container">
			<div class="category_toggle">
				<h2>
					<%=SettingsTitle%></h2>
			</div>
			<div class="category_content">
				<div id="pnlContentSelection" runat="server">
					<h3 class="subsections">Content selection</h3>
					<table class="settings_table" cellpadding="0" cellspacing="0">
						<tr class="second">
							<td class="left">
								<dnn:Label ID="lblFilterBy" runat="server" Text="Display articles and events:" HelpText="This option allows for displaying articles only, or events only, or both." HelpKey="lblFilterBy.HelpText" ResourceKey="lblFilterBy" />
							</td>
							<td class="right">
								<asp:CheckBox ID="cbFilterByArticles" runat="server" Text="Articles" Checked="True" />
								<asp:CheckBox ID="cbFilterByEvents" runat="server" Text="Events" Checked="True" AutoPostBack="true" OnCheckedChanged="cbFilterByEvents_CheckedChanged" />
							</td>
						</tr>
						<tr>
							<td class="left">
								<dnn:Label ID="lblFilterByEventsLimit" runat="server" HelpText="Set the criteria to display events whose start date has ended. The option 'Show all' will display all events, disregarding the fact that they have already ended. We can enter the number of days to be set in the past for past events in the field 'Limit to number of days in the past'. If the set value is 0, the criterion for the event's listing will be the current date. In that case, neither of the past events will be displayed." Text="Displaying of past events:" HelpKey="lblShowOnlyEventsLimit.HelpText" ResourceKey="lblShowOnlyEventsLimit" />
							</td>
							<td class="right">
								<asp:RadioButtonList ID="rblLimitBackEvents" runat="server" Style="float: left" RepeatDirection="Horizontal">
									<asp:ListItem Value="0" Text="ShowAll" />
									<asp:ListItem Value="1" Text="Limit to number of days:" Selected="True" />
								</asp:RadioButtonList>
								<asp:TextBox Style="float: left" ID="tbPastEventLimit" runat="server" Width="25px" Text="0" />
								<asp:RequiredFieldValidator ID="rfvPastEventLimit" runat="server" ControlToValidate="tbPastEventLimit" Display="Dynamic" ErrorMessage="This filed is required." SetFocusOnError="True" ValidationGroup="vgCatMenuSettings" />
								<asp:CompareValidator ID="cvPastEventLimit" runat="server" ControlToValidate="tbPastEventLimit" Display="Dynamic" ErrorMessage="Please enter number only." Operator="DataTypeCheck" Type="Integer" ValidationGroup="vgCatMenuSettings" />
							</td>
						</tr>
					</table>
				</div>
				<div id="pnlSocialInstance" runat="server" style="display: none;">
					<h3 class="subsections">Social settings</h3>
					<table class="settings_table" cellpadding="0" cellspacing="0">
						<tr id="Tr1" runat="server" style="background: #D1EBFA;">
							<td class="left" style="border: 1px solid #AAD6F1; border-right: 0;">
								<dnn:Label ID="lblIsSocialInstance" runat="server" Text="Community mode:" HelpText="Displays user's and group's articles on the Activity feed. The articles are filtered by the UserID or GroupID querystring. If this option is enabled and the querystring UserID or GroupID is missing, then the articles won't show up."
									ControlName="cbIsSocialInstance" ResourceKey="lblIsSocialInstance" />
							</td>
							<td class="right" style="border: 1px solid #AAD6F1; border-left: 0;">
								<asp:CheckBox ID="cbIsSocialInstance" runat="server" Checked="false" OnCheckedChanged="cbIsSocialInstance_CheckedChanged" AutoPostBack="true" />
							</td>
						</tr>
					</table>
				</div>
				<div id="pnlPortalSharing" runat="server">
					<h3 class="subsections">
						<%=Portalsharing%></h3>
					<table class="settings_table" cellpadding="0" cellspacing="0">
						<tr>
							<td class="left">
								<dnn:Label ID="lblPortalSharing" runat="server" Text="Select portal:" HelpText="Select data source portal." ControlName="ddlPortalSharing" ResourceKey="lblPortalSharing" />
							</td>
							<td class="right">
								<asp:DropDownList ID="ddlPortalSharing" runat="server" AppendDataBoundItems="True" AutoPostBack="True" DataTextField="PortalName" DataValueField="PortalIDFrom" CssClass="ddlcategorysettings" OnSelectedIndexChanged="ddlPortalSharing_SelectedIndexChanged">
									<asp:ListItem ResourceKey="liCurrentportal" Value="-1" Text="Current portal" />
								</asp:DropDownList>
							</td>
						</tr>
					</table>
				</div>
				<h3 class="subsections">
					<%=Permissions%></h3>
				<asp:UpdatePanel ID="upPermissionSettings" runat="server">
					<ContentTemplate>
						<table class="settings_table" cellpadding="0" cellspacing="0">
							<tr class="second">
								<td class="left">
									<dnn:Label ID="lblPermissionSource" runat="server" Text="Select permission source:" HelpText="Category menu will inherite permission from selected value. Only allowed categories will show in menu." ResourceKey="lblPermissionSource" />
								</td>
								<td class="right">
									<asp:RadioButtonList ID="rblCategoryPermissionSource" runat="server" OnSelectedIndexChanged="rblCategoryPermissionSource_SelectedIndexChanged" AutoPostBack="True" RepeatDirection="Horizontal">
										<asp:ListItem ResourceKey="liNone" Selected="True" Text="None" Value="0" />
										<asp:ListItem ResourceKey="liPortal" Text="Portal" Value="1" />
										<asp:ListItem ResourceKey="liModule" Text="Module" Value="2" />
									</asp:RadioButtonList>
									<asp:Panel ID="pnlCategoryModuleInherite" runat="server" Visible="False">
										<asp:DropDownList ID="ddlPermFromModuleInstance" runat="server" />
									</asp:Panel>
								</td>
							</tr>
						</table>
					</ContentTemplate>
				</asp:UpdatePanel>
				<asp:UpdateProgress ID="uppPermissionSettings" runat="server" AssociatedUpdatePanelID="upPermissionSettings" DisplayAfter="100" DynamicLayout="true">
					<ProgressTemplate>
						<img src="<%=ModulePath.Replace("EasyDNNnewsWidgets/Controls/TreeView/Settings", "EasyDNNnews")%>images/settings/ajaxLoading.gif" />
					</ProgressTemplate>
				</asp:UpdateProgress>
				<h3 class="subsections">
					<%=Menuspecificoptions%></h3>
				<table class="settings_table" cellpadding="0" cellspacing="0">
					<tr class="second">
						<td class="left">
							<dnn:Label ID="lblDisplayHeader" runat="server" Text="Display header:" HelpText="Display header." ResourceKey="lblDisplayHeader" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbDisplayHeader" runat="server" Checked="True" />
						</td>
					</tr>
					<tr>
						<td class="left">
							<dnn:Label ID="lblSelectModule" runat="server" Text="Select module to display results:" HelpText="Select news module instance to open articles." ResourceKey="lblSelectModule" />
						</td>
						<td class="right">
							<asp:DropDownList ID="ddlOpenDetails" runat="server" />
						</td>
					</tr>
					<tr class="second">
						<td class="left">
							<dnn:Label ID="lblExpandAllCategories" runat="server" Text="Expand all:" HelpText="Expand (open) all items." ResourceKey="lblExpandAllCategories" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbExpandAll" runat="server" OnCheckedChanged="cbExpandAll_CheckedChanged" AutoPostBack="true" />
						</td>
					</tr>
					<tr style="display: none;">
						<td class="left">
							<dnn:Label ID="lblnodeExpandToLevel" runat="server" Text="Expand to level:" HelpText="Expand (open) nodes to some level." ResourceKey="lblnodeExpandToLevel" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbnodeExpandToLevel" runat="server" OnCheckedChanged="cbnodeExpandToLevel_CheckedChanged" AutoPostBack="true" />
							<asp:TextBox ID="tbxnodeExpandLevel" runat="server" MaxLength="1" ValidationGroup="vgCatMenuSettings" Width="20px" Text="1" />
							<asp:RequiredFieldValidator ID="rfvnodeExpandLevel" runat="server" ForeColor="Red" ErrorMessage="This filed is required." ControlToValidate="tbxnodeExpandLevel" ValidationGroup="vgCatMenuSettings" />
							<asp:RangeValidator ID="rvnodeExpandLevel" runat="server" ForeColor="Red" ErrorMessage="Enter value between 1 - 9." ControlToValidate="tbxnodeExpandLevel" ValidationGroup="vgCatMenuSettings" Display="Dynamic" MaximumValue="9" MinimumValue="1" Type="Integer" />
						</td>
					</tr>
					<tr class="second">
						<td class="left">
							<dnn:Label ID="lblShowArticles" runat="server" Text="Show articles:" HelpText="Show articles under category." ResourceKey="lblShowArticles" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbShowArticles" runat="server" Checked="True" />
						</td>
					</tr>
					<tr>
						<td class="left">
							<dnn:Label ID="lblPassAuthorUserID" runat="server" Text="Pass author userid in query string:" HelpText="Pass author userid in query string." ResourceKey="lblPassAuthorUserID" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbPassAuthorUserID" runat="server" Checked="false" />
						</td>
					</tr>
				</table>
				<h3 class="subsections">
					<%=Theme%></h3>
				<asp:UpdatePanel ID="upModuleTheme" runat="server">
					<ContentTemplate>
						<table class="settings_table" cellpadding="0" cellspacing="0">
							<tr class="second">
								<td class="left">
									<dnn:Label ID="lblTheme" runat="server" Text="Theme:" ControlName="ddlTheme" HelpText="Select theme." ResourceKey="lblTheme" />
								</td>
								<td class="right">
									<asp:DropDownList ID="ddlTheme" runat="server" OnSelectedIndexChanged="ddlTheme_SelectedIndexChanged" AutoPostBack="True" ValidationGroup="vgCatMenuSettings" />
									<asp:CompareValidator ID="cvThemeSelect" resourcekey="cvThemeSelect.ErrorMessage" runat="server" ForeColor="Red" ControlToValidate="ddlTheme" Display="Dynamic" ErrorMessage=" Please select theme." Operator="NotEqual" ValidationGroup="vgCatMenuSettings"
										ValueToCompare="" />
								</td>
							</tr>
							<tr>
								<td class="left">
									<dnn:Label ID="lblThemeStyle" runat="server" Text="Theme style:" HelpText="Select display style." ResourceKey="lblThemeStyle" />
								</td>
								<td class="right">
									<asp:DropDownList ID="ddlThemeStyle" runat="server" ValidationGroup="vgCatMenuSettings" />
									<asp:CompareValidator ID="cvdisplayStyleSelect" runat="server" ForeColor="Red" ControlToValidate="ddlThemeStyle" Display="Dynamic" ErrorMessage=" Please select theme style" Operator="NotEqual" ValidationGroup="vgCatMenuSettings" ValueToCompare="" />
								</td>
							</tr>
						</table>
					</ContentTemplate>
				</asp:UpdatePanel>
				<asp:UpdateProgress ID="uppTheme" runat="server" AssociatedUpdatePanelID="upModuleTheme" DisplayAfter="100" DynamicLayout="true">
					<ProgressTemplate>
						<img src="<%=ModulePath.Replace("EasyDNNnewsWidgets/Controls/TreeView/Settings", "EasyDNNnews")%>images/settings/ajaxLoading.gif" />
					</ProgressTemplate>
				</asp:UpdateProgress>
				<h3 class="subsections">
					<%=Filter%></h3>
				<asp:UpdatePanel ID="upCategoriesfilter" runat="server">
					<ContentTemplate>
						<table class="settings_table" cellpadding="0" cellspacing="0">
							<tr class="second">
								<td class="left">
									<dnn:Label ID="lblCelectCats" runat="server" Text="Select categories to display:" HelpText="Show all categories or make category selection in the tree view selection list." ResourceKey="lblCelectCats" />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbdisplayallcats" resourcekey="cbdisplayallcats" runat="server" AutoPostBack="True" Checked="True" OnCheckedChanged="cbdisplayallcats_CheckedChanged" Text="Display all categories and subcategories" />
								</td>
							</tr>
							<tr runat="server" id="rowSelectCategories" visible="false">
								<td colspan="2">
									<table class="settings_table" cellpadding="0" cellspacing="0" style="margin-left: auto; margin-right: auto;">
										<tr>
											<td class="left"></td>
											<td class="right">
												<asp:CheckBox ID="cbAutoAddCatChilds" resourcekey="cbAutoAddCatChilds" runat="server" Text="Auto select all child categories." />
											</td>
										</tr>
										<tr>
											<td colspan="2">
												<asp:PlaceHolder ID="pnlDinamicTreeView" runat="server" />
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</ContentTemplate>
				</asp:UpdatePanel>
				<asp:UpdateProgress ID="uppCategoriesfilter" runat="server" AssociatedUpdatePanelID="upCategoriesfilter" DisplayAfter="100" DynamicLayout="true">
					<ProgressTemplate>
						<img src="<%=ModulePath.Replace("EasyDNNnewsWidgets/Controls/TreeView/Settings", "EasyDNNnews")%>images/settings/ajaxLoading.gif" />
					</ProgressTemplate>
				</asp:UpdateProgress>
				<asp:UpdatePanel ID="upAuthorsFilter" runat="server">
					<ContentTemplate>
						<table class="settings_table" cellpadding="0" cellspacing="0">
							<tr>
								<td class="left">
									<dnn:Label ID="lblAuthorFilter" runat="server" Text="All Authors:" HelpText="Filter by author." ResourceKey="lblAuthorFilter" />
								</td>
								<td>
									<asp:CheckBox ID="cbDisplayAllAuthors" runat="server" AutoPostBack="True" Checked="True" OnCheckedChanged="cbDisplayAllAuthors_CheckedChanged" />
								</td>
							</tr>
							<tr class="second">
								<td class="left">&nbsp;
								</td>
								<td class="right">
									<asp:TreeView ID="tvAuthorAndGroupSelection" runat="server" ForeColor="Black" ShowCheckBoxes="All" Visible="False" ImageSet="Contacts" NodeIndent="25">
										<HoverNodeStyle Font-Underline="False" />
										<NodeStyle Font-Names="Verdana" Font-Size="8pt" ForeColor="Black" HorizontalPadding="5px" NodeSpacing="0px" VerticalPadding="0px" />
										<ParentNodeStyle Font-Bold="True" ForeColor="#5555DD" />
										<SelectedNodeStyle Font-Underline="True" HorizontalPadding="0px" VerticalPadding="0px" />
									</asp:TreeView>
									<asp:CustomValidator ID="cvAuthorsTreeview" resourcekey="cvAuthorsTreeview.ErrorMessage" runat="server" ForeColor="Red" ClientValidationFunction="ClientValidateAuthors" Display="Dynamic" Enabled="False" ErrorMessage="Please select at least one author."
										ValidationGroup="vgCatMenuSettings" />
								</td>
							</tr>
						</table>
					</ContentTemplate>
				</asp:UpdatePanel>
				<asp:UpdateProgress ID="uppAuthorsFilter" runat="server" AssociatedUpdatePanelID="upAuthorsFilter" DisplayAfter="100" DynamicLayout="true">
					<ProgressTemplate>
						<img src="<%=ModulePath.Replace("EasyDNNnewsWidgets/Controls/TreeView/Settings", "EasyDNNnews")%>images/settings/ajaxLoading.gif" />
					</ProgressTemplate>
				</asp:UpdateProgress>
				<table class="settings_table" cellpadding="0" cellspacing="0">
					<tr>
						<td colspan="2" style="text-align: center; color: Red;">
							<asp:Label ID="lblCategoriesMenuInfo" runat="server" EnableViewState="False" />
						</td>
					</tr>
				</table>
				<asp:Panel ID="pnlLocalization" runat="server" Visible="false">
					<h3 class="subsections">
						<%=LocalizationText%></h3>
					<table class="settings_table" cellpadding="0" cellspacing="0">
						<tr>
							<td class="left">
								<dnn:Label ID="lblHideUnlocalizedItems" runat="server" Text="Don't show unlocalized items:" HelpText="Articles, events that are unlocalized won't show when localization selected. Does't include categories localization." ResourceKey="lblHideUnlocalizedItems" />
							</td>
							<td class="right">
								<asp:CheckBox ID="cbHideUnlocalizedItems" runat="server" />
							</td>
						</tr>
					</table>
				</asp:Panel>
			</div>
		</div>
		<div class="main_actions">
			<p>
				<asp:Label ID="lblMainMessage" runat="server" EnableViewState="false" />
				<asp:CustomValidator ID="cvCategoriesTreeview" resourcekey="cvCategoriesTreeview.ErrorMessage" runat="server" ForeColor="Red" ClientValidationFunction="CategoryClientValidate" Display="Dynamic" Enabled="False" ErrorMessage="Please select at least one category."
					ValidationGroup="vgCatMenuSettings" />
			</p>
			<div class="buttons">
				<asp:Button ID="btnSaveSettings" resourcekey="btnSaveSettings" runat="server" OnClick="btnSaveSettings_Click" Text="Save" ValidationGroup="vgCatMenuSettings" />
				<asp:Button ID="btnSaveClose" resourcekey="btnSaveClose" runat="server" OnClick="btnSaveClose_Click" Text="Save &amp; Close" ValidationGroup="vgCatMenuSettings" />
				<asp:Button ID="btnCancel" resourcekey="btnCancel" runat="server" OnClick="btnCancel_Click" Text="Close" />
			</div>
			<br />
			<br />
		</div>
	</div>
</div>
