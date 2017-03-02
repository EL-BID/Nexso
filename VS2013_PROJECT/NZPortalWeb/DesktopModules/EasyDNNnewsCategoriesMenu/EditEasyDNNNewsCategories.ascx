<%@ control language="C#" inherits="EasyDNN.Modules.EasyDNNNewsCategories.EditEasyDNNNewsCategories, App_Web_editeasydnnnewscategories.ascx.565cbe7e" autoeventwireup="true" %>
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
		$('#advanced_tree_view_categor_selector').EDS_TreeViewSelector({
			state_checkbox: $('#<%=cbAutoAddCatChilds.ClientID %>')
		});

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

			var $category_menue_items = $('.edn_advanced_tree_view li');

			$category_menue_items.click(function (e) {
				var $target = $(e.target),
					$clicked,
					$child_list,
					$expand_collapse;

				if ($target.is('div') || $target.is('a.expand_collapse')) {
					$clicked = $(this);
					$child_list = $clicked.find('> ul');
					$expand_collapse = $clicked.find('> div > a.expand_collapse');

					if ($child_list.length == 1) {
						if ($child_list.is(':visible')) {
							$child_list.slideUp(200);
							$expand_collapse.removeClass('collapse');
						} else {
							$child_list.slideDown(200);
							$expand_collapse.addClass('collapse');
						}
					}

					return false;
				}
			});

			jQuery(function ($) {

				$('#advanced_tree_view_categor_selector').EDS_TreeViewSelector({
					state_checkbox: $('#<%=cbAutoAddCatChilds.ClientID %>')
				});

			});
		}
	}


</script>
<div id="EDNadmin">
	<div class="module_settings">
		<div class="settings_category_container">
			<div class="category_toggle">
				<h2>
					<%=NewsCategorymenu%></h2>
			</div>
			<div class="category_content">
				<div id="pnlSocialInstance" runat="server" style="display: none;">
					<table class="settings_table" cellpadding="0" cellspacing="0">
						<tr runat="server" style="background: #D1EBFA;">
							<td class="left" style="border: 1px solid #AAD6F1; border-right: 0;">
								<dnn:Label ID="lblIsSocialInstance" runat="server" Text="Community mode:" HelpText="Displays user's and group's articles on the Activity feed. The articles are filtered by the UserID or GroupID querystring. If this option is enabled and the querystring UserID or GroupID is missing, then the articles won't show up."
									ControlName="cbIsSocialInstance" ResourceKey="cbIsSocialInstance" HelpKey="cbIsSocialInstance.HelpText" />
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
								<dnn:Label ID="lblPortalSharing" runat="server" Text="Select portal:" HelpText="Select data source portal." ControlName="ddlPortalSharing" HelpKey="lblPortalSharing.HelpText" ResourceKey="lblPortalSharing" />
							</td>
							<td class="right">
								<asp:DropDownList ID="ddlPortalSharing" runat="server" AppendDataBoundItems="True" AutoPostBack="True" DataTextField="PortalName" DataValueField="PortalIDFrom" CssClass="ddlcategorysettings" OnSelectedIndexChanged="ddlPortalSharing_SelectedIndexChanged">
									<asp:ListItem resourcekey="liCurrentPortal" Value="-1">Current portal</asp:ListItem>
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
									<dnn:Label ID="lblPermissionSource" runat="server" Text="Select permission source:" HelpText="Category menu will inherite permission from selected value. Only allowed categories will show in menu." HelpKey="lblPermissionSource.HelpText" ResourceKey="lblPermissionSource" />
								</td>
								<td class="right">
									<asp:RadioButtonList ID="rblCategoryPermissionSource" runat="server" OnSelectedIndexChanged="rblCategoryPermissionSource_SelectedIndexChanged" AutoPostBack="True" RepeatDirection="Horizontal">
										<asp:ListItem Selected="True" Text="None" Value="0" resourcekey="ListItemResource1"></asp:ListItem>
										<asp:ListItem Text="Portal" Value="1" resourcekey="ListItemResource2"></asp:ListItem>
										<asp:ListItem Text="Module" Value="2" resourcekey="ListItemResource3"></asp:ListItem>
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
						<img src="<%=ModulePath.Replace("EasyDNNNewsCategoriesMenu", "EasyDNNnews")%>images/settings/ajaxLoading.gif" />
					</ProgressTemplate>
				</asp:UpdateProgress>
				<h3 class="subsections">
					<%=Menuspecificoptions%></h3>
				<table class="settings_table" cellpadding="0" cellspacing="0">
					<tr style="background: #D1EBFA;">
						<td class="left">
							<dnn:Label ID="lblSelectMenuType" runat="server" Text="Select menu type:" HelpText="Select the type of menu to display categories or authors." HelpKey="lblSelectMenuType.HelpText" ResourceKey="lblSelectMenuType" />
						</td>
						<td class="right">
							<asp:RadioButtonList ID="rblCathegoryMenuType" runat="server" AutoPostBack="True" OnSelectedIndexChanged="rblCathegoryMenuType_SelectedIndexChanged" RepeatDirection="Horizontal">
								<asp:ListItem Selected="True" Value="CategoryMenu" resourcekey="ListItemResource4">Category menu</asp:ListItem>
								<asp:ListItem Value="AuthorMenu" resourcekey="ListItemResource5">Author menu</asp:ListItem>
								<asp:ListItem Value="CalendarCategoryMenu" resourcekey="CalendarCategoryMenu">Calendar category menu</asp:ListItem>
							</asp:RadioButtonList>
						</td>
					</tr>
					<tr class="second">
						<td class="left">
							<dnn:Label ID="lblDisplayHeader" runat="server" Text="Display header:" HelpText="Display header:" HelpKey="lblDisplayHeader.HelpText" ResourceKey="lblDisplayHeader" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbDisplayHeader" runat="server" Checked="True" resourcekey="cbDisplayHeaderResource1" />
						</td>
					</tr>
					<tr>
						<td class="left">
							<dnn:Label ID="lblSelectModule" runat="server" Text="Select module to display results:" HelpText="Select news module instance to open articles:" HelpKey="lblSelectModule.HelpText" ResourceKey="lblSelectModule" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbModules" Style="display: none" runat="server" AutoPostBack="True" Checked="True" OnCheckedChanged="cbModules_CheckedChanged" Text="Module" resourcekey="cbModulesResource1" />
							<asp:DropDownList ID="ddlOpenDetails" runat="server" />
						</td>
					</tr>
					<tr style="display: none">
						<td class="left">
							<dnn:Label ID="lblSelectPage" runat="server" Text="Select page to display results:" HelpText="Select page to open articles:" HelpKey="lblSelectPage.HelpText" ResourceKey="lblSelectPage" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbPage" runat="server" AutoPostBack="True" OnCheckedChanged="cbPage_CheckedChanged" Text="Page" resourcekey="cbPageResource1" />
							<asp:DropDownList ID="ddlPageOpenDetails" runat="server" />
						</td>
					</tr>
					<tr id="trPassAuthorUserID" runat="server" class="second" visible="false">
						<td class="left">
							<dnn:Label ID="lblPassAuthorUserID" runat="server" Text="Pass author userid in query string:" HelpText="Pass author userid in query string." ResourceKey="lblPassAuthorUserID" HelpKey="lblPassAuthorUserID.HelpText" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbPassAuthorUserID" runat="server" Checked="false" />
						</td>
					</tr>
					<tr>
						<td class="left">
							<dnn:Label ID="lblExpandAllCategories" runat="server" Text="Expand all:" HelpText="Expand (open) all items:" HelpKey="lblExpandAllCategories.HelpText" ResourceKey="lblExpandAllCategories" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbExpandAll" runat="server" OnCheckedChanged="cbExpandAll_CheckedChanged" AutoPostBack="true" />
						</td>
					</tr>
					<tr id="trExpandToLevel" runat="server" class="second">
						<td class="left">
							<dnn:Label ID="lblnodeExpandToLevel" runat="server" Text="Expand to level:" HelpText="Expand (open) nodes to some level." ResourceKey="lblnodeExpandToLevel" HelpKey="lblnodeExpandToLevel.HelpText" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbnodeExpandToLevel" runat="server" OnCheckedChanged="cbnodeExpandToLevel_CheckedChanged" AutoPostBack="true" />
							<asp:TextBox ID="tbxnodeExpandLevel" runat="server" MaxLength="1" ValidationGroup="vgCatMenuSettings" Width="20px" Text="1" />
							<asp:RequiredFieldValidator ID="rfvnodeExpandLevel" runat="server" ForeColor="Red" ErrorMessage="This filed is required." ControlToValidate="tbxnodeExpandLevel" ValidationGroup="vgCatMenuSettings" />
							<asp:RangeValidator ID="rvnodeExpandLevel" runat="server" ForeColor="Red" ErrorMessage="Enter value between 1 - 9." ControlToValidate="tbxnodeExpandLevel" ValidationGroup="vgCatMenuSettings" Display="Dynamic" MaximumValue="9" MinimumValue="1" Type="Integer" />
						</td>
					</tr>
					<tr>
						<td class="left">
							<dnn:Label ID="lblShowEmptyCategories" runat="server" Text="Show empty categories:" HelpText="If category doesn't contain any content it will not be visible." HelpKey="lblShowEmptyCategories.HelpText" ResourceKey="lblShowEmptyCategories" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbShowEmptyCategories" runat="server" />
						</td>
					</tr>
				</table>
				<h3 class="subsections">
					<%=Themeandtemplate%></h3>
				<asp:UpdatePanel ID="upModuleTheme" runat="server">
					<ContentTemplate>
						<table class="settings_table" cellpadding="0" cellspacing="0">
							<tr class="second">
								<td class="left">
									<dnn:Label ID="lblModuleTemplate" runat="server" Text="Module theme:" ControlName="ddlTheme" HelpText="Select theme." HelpKey="lblModuleTemplate.HelpText" ResourceKey="lblModuleTemplate" />
								</td>
								<td class="right">
									<asp:DropDownList ID="ddlTheme" runat="server" OnSelectedIndexChanged="ddlModuleTemplate_SelectedIndexChanged" AutoPostBack="True" ValidationGroup="vgCatMenuSettings" />
									<asp:CompareValidator ID="cvThemeSelect" runat="server" ForeColor="Red" ControlToValidate="ddlTheme" Display="Dynamic" ErrorMessage=" Please select theme." Operator="NotEqual" ValidationGroup="vgCatMenuSettings" ValueToCompare="0" resourcekey="cvThemeSelectResource1.ErrorMessage" />
								</td>
							</tr>
							<tr>
								<td class="left">
									<dnn:Label ID="lblSelectDisplayStyle" runat="server" Text="Module display style:" HelpText="Select display style." HelpKey="lblSelectDisplayStyle.HelpText" ResourceKey="lblSelectDisplayStyle" />
								</td>
								<td class="right">
									<asp:DropDownList ID="ddlDisplayStyle" runat="server" ValidationGroup="vgCatMenuSettings" />
								</td>
							</tr>
							<tr class="second">
								<td class="left">
									<dnn:Label ID="lblModuleTheme" runat="server" Text="Module template:" HelpText="Select template." HelpKey="lblModuleTheme.HelpText" ResourceKey="lblModuleTheme" />
								</td>
								<td class="right">
									<asp:DropDownList ID="ddlHTMLTemplates" runat="server" />
									<asp:CompareValidator ID="cvHTMLTemplate" runat="server" ForeColor="Red" ControlToValidate="ddlHTMLTemplates" Display="Dynamic" ErrorMessage="Please select HTML template." Operator="NotEqual" ValidationGroup="vgCatMenuSettings" ValueToCompare="0" />
								</td>
							</tr>
						</table>
					</ContentTemplate>
				</asp:UpdatePanel>
				<asp:UpdateProgress ID="uppTheme" runat="server" AssociatedUpdatePanelID="upModuleTheme" DisplayAfter="100" DynamicLayout="true">
					<ProgressTemplate>
						<img src="<%=ModulePath.Replace("EasyDNNNewsCategoriesMenu", "EasyDNNnews")%>images/settings/ajaxLoading.gif" />
					</ProgressTemplate>
				</asp:UpdateProgress>
				<h3 class="subsections">
					<%=Filter%></h3>
				<table runat="server" id="tblFilterContentOptions" class="settings_table" cellpadding="0" cellspacing="0">
					<tr class="second">
						<td class="left">
							<dnn:Label ID="lblFilterBy" runat="server" Text="Display articles and events:" HelpText="This option allows for displaying articles only, or events only, or both." HelpKey="lblFilterBy.HelpText" ResourceKey="lblFilterBy" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbCountArticles" runat="server" Checked="True" Text="Articles" />
							<asp:CheckBox ID="cbCountEvents" runat="server" Text="Events" Checked="True" AutoPostBack="true" OnCheckedChanged="cbShowOnlyEvents_CheckedChanged" />
						</td>
					</tr>
					<tr class="second">
						<td class="left">
							<dnn:Label ID="lblShowOnlyEventsLimit" runat="server" HelpText="Set the criteria to display events whose start date has ended. The option 'Show all' will display all events, disregarding the fact that they have already ended. We can enter the number of days to be set in the past for past events in the field 'Limit to number of days in the past'. If the set value is 0, the criterion for the event's listing will be the current date. In that case, neither of the past events will be displayed." Text="Displaying of past events:" HelpKey="lblShowOnlyEventsLimit.HelpText" ResourceKey="lblShowOnlyEventsLimit" />
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
				<asp:UpdatePanel ID="upCategoriesfilter" runat="server">
					<ContentTemplate>
						<table class="settings_table" cellpadding="0" cellspacing="0">
							<tr class="second">
								<td class="left">
									<dnn:Label ID="lblCelectCats" runat="server" Text="Select categories to display:" HelpText="Show all categories or make category selection in the tree view selection list." HelpKey="lblCelectCats.HelpText" ResourceKey="lblCelectCats" />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbdisplayallcats" runat="server" AutoPostBack="True" Checked="True" OnCheckedChanged="cbdisplayallcats_CheckedChanged" Text="Display all categories and subcategories" resourcekey="cbdisplayallcatsResource1" />
								</td>
							</tr>
							<tr runat="server" id="rowSelectCategories" visible="false">
								<td colspan="2">
									<table class="settings_table" cellpadding="0" cellspacing="0" style="margin-left: auto; margin-right: auto;">
										<tr>
											<td class="left"></td>
											<td class="right">
												<asp:CheckBox ID="cbAutoAddCatChilds" runat="server" Text="Auto select all child categories." resourcekey="cbAutoAddCatChildsResource1" /></p>
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
						<img src="<%=ModulePath.Replace("EasyDNNNewsCategoriesMenu", "EasyDNNnews")%>images/settings/ajaxLoading.gif" />
					</ProgressTemplate>
				</asp:UpdateProgress>
				<asp:UpdatePanel ID="upAuthorsFilter" runat="server">
					<ContentTemplate>
						<table class="settings_table" cellpadding="0" cellspacing="0">
							<tr>
								<td class="left">
									<dnn:Label ID="lblAuthorFilter" runat="server" Text="All Authors:" HelpText="Filter by author." HelpKey="lblAuthorFilter.HelpText" ResourceKey="lblAuthorFilter" />
								</td>
								<td>
									<asp:CheckBox ID="cbDisplayAllAuthors" runat="server" AutoPostBack="True" Checked="True" OnCheckedChanged="cbDisplayAllAuthors_CheckedChanged" />
								</td>
							</tr>
							<tr class="second">
								<td class="left">&nbsp;
								</td>
								<td class="right">
									<asp:TreeView ID="tvAuthorAndGroupSelection" runat="server" ForeColor="Black" ShowCheckBoxes="All" Visible="False" ImageSet="Contacts" NodeIndent="25" resourcekey="tvAuthorAndGroupSelectionResource1">
										<HoverNodeStyle Font-Underline="False" />
										<NodeStyle Font-Names="Verdana" Font-Size="8pt" ForeColor="Black" HorizontalPadding="5px" NodeSpacing="0px" VerticalPadding="0px" />
										<ParentNodeStyle Font-Bold="True" ForeColor="#5555DD" />
										<SelectedNodeStyle Font-Underline="True" HorizontalPadding="0px" VerticalPadding="0px" />
									</asp:TreeView>
									<asp:CustomValidator ID="cvAuthorsTreeview" runat="server" ForeColor="Red" ClientValidationFunction="ClientValidateAuthors" Display="Dynamic" Enabled="False" ErrorMessage="Please select at least one author." ValidationGroup="vgCatMenuSettings" />
								</td>
							</tr>
							<tr>
								<td colspan="2" style="text-align: center; color: Red;">
									<asp:Label ID="lblCategoriesMenuInfo" runat="server" EnableViewState="False" resourcekey="lblCategoriesMenuInfoResource1"></asp:Label>
								</td>
							</tr>
						</table>
					</ContentTemplate>
				</asp:UpdatePanel>
				<asp:UpdateProgress ID="uppAuthorsFilter" runat="server" AssociatedUpdatePanelID="upAuthorsFilter" DisplayAfter="100" DynamicLayout="true">
					<ProgressTemplate>
						<img src="<%=ModulePath.Replace("EasyDNNNewsCategoriesMenu", "EasyDNNnews")%>images/settings/ajaxLoading.gif" />
					</ProgressTemplate>
				</asp:UpdateProgress>
				<asp:Panel ID="pnlLocalization" runat="server" Visible="false">
					<h3 class="subsections">
						<%=LocalizationText%></h3>
					<table class="settings_table" cellpadding="0" cellspacing="0">
						<tr>
							<td class="left">
								<dnn:Label ID="lblHideUnlocalizedItems" runat="server" Text="Don't show unlocalized items:" HelpText="Articles, events that are unlocalized won't show when localization selected." ResourceKey="lblHideUnlocalizedItems" HelpKey="lblHideUnlocalizedItems.HelpText" />
							</td>
							<td class="right">
								<asp:CheckBox ID="cbHideUnlocalizedItems" runat="server" />
							</td>
						</tr>
					</table>
				</asp:Panel>
				<h3 class="subsections">
					<%=Visibility%></h3>
				<table class="settings_table" cellpadding="0" cellspacing="0">
					<tr>
						<td class="left">
							<dnn:Label ID="lblModuleVisibility" runat="server" Text="Module visibility:" HelpText="Here you can set when you wish the module to be visible on the page. If 'Module always visible' option is selected, the module is visible all the time. If 'Show module only when the news module displays the list of articles' option is selected, the module will only be visible when the news module displays the list of articles, yet it won't be visible when article details are displayed. If 'Show module only when the news module displays article details' option is selected, the module will only be visible when article details are displayed, yet it won't be visible when the list of articles is displayed. Note: The module is always visible to admin and host users."
								ResourceKey="lblModuleVisibility" HelpKey="lblModuleVisibility.HelpText" />
						</td>
						<td class="right">
							<asp:RadioButtonList ID="rblModuleVisibility" runat="server">
								<asp:ListItem Selected="True" Text="Default (always show module)" Value="0" />
								<asp:ListItem Text="Visible only if article list mode" Value="1" />
								<asp:ListItem Text="Visible only if article details mode" Value="2" />
							</asp:RadioButtonList>
						</td>
					</tr>
				</table>
			</div>
		</div>
		<div class="main_actions">
			<p>
				<asp:Label ID="lblMainMessage" runat="server" EnableViewState="false" />
				<asp:CustomValidator ID="cvCategoriesTreeview" runat="server" ForeColor="Red" ClientValidationFunction="CategoryClientValidate" Display="Dynamic" Enabled="False" ErrorMessage="Please select at least one category." ValidationGroup="vgCatMenuSettings" />
			</p>
			<div class="buttons">
				<asp:Button ID="btnSaveSettings" runat="server" OnClick="btnSaveSettings_Click" Text="Save" ValidationGroup="vgCatMenuSettings" resourcekey="btnSaveSettingsResource1" />
				<asp:Button ID="btnSaveClose" runat="server" OnClick="btnSaveClose_Click" Text="Save &amp; Close" ValidationGroup="vgCatMenuSettings" resourcekey="btnSaveCloseResource1" />
				<asp:Button ID="btnCancel" runat="server" OnClick="btnCancel_Click" Text="Close" resourcekey="btnCancelResource1" />
			</div>
			<br />
			<br />
		</div>
	</div>
</div>
