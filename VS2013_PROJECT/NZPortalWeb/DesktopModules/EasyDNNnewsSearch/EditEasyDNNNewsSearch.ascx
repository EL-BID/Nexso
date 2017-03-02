<%@ control language="C#" inherits="EasyDNNSolutions.Modules.EasyDNNNewsSearch.EditEasyDNNNewsSearch, App_Web_editeasydnnnewssearch.ascx.75700bee" autoeventwireup="true" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<script type="text/javascript">
	jQuery().ready(function ($) {
		$('#<%=tvCatAndSubCat.ClientID%>').EDS_TreeViewSelector({
			state_checkbox: $('#<%=cbAutoAddCatChilds.ClientID %>')
		});

		toogleAdvancedCategoryPanels();

		$('#<%=cbCategoryCFGroupItems.ClientID%>').change(function () {
			toogleAdvancedCategoryPanels();
		});

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

	});

	function toogleAdvancedCategoryPanels() {
		if ($("#<%=cbCategoryCFGroupItems.ClientID%>").is(':checked'))
			$("#<%=rowCategoryCFGroupItems.ClientID%>").show();
		else
			$("#<%=rowCategoryCFGroupItems.ClientID%>").hide();
	}

	function ClientValidate(source, arguments) {
		var treeView = document.getElementById("<%= tvCatAndSubCat.ClientID %>");
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

	function pageLoad(sender, args) {
		if (args.get_isPartialLoad()) {
			jQuery().ready(function ($) {
				$('#<%=tvCatAndSubCat.ClientID %>').EDS_TreeViewSelector({
					state_checkbox: $('#<%=cbAutoAddCatChilds.ClientID %>')
				});
			});
			function ClientValidate(source, arguments) {
				var treeView = document.getElementById("<%= tvCatAndSubCat.ClientID %>");
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

			}
		}
</script>
<div id="EDNadmin">
	<div class="module_settings">
		<div class="settings_category_container last">
			<div class="category_toggle">
				<h2>
					<%=Searchsettings%></h2>
			</div>
			<div class="category_content">
				<table class="settings_table" cellpadding="0" cellspacing="0">
					<tr runat="server" id="tblRowIsSocialInstance" style="background: #D1EBFA; display: none;">
						<td class="left" style="border: 1px solid #AAD6F1; border-right: 0;">
							<dnn:Label ID="lblIsSocialInstance" runat="server" Text="Community mode:" HelpText="Displays user's and group's articles on the Activity feed. The articles are filtered by the UserID or GroupID querystring. If this option is enabled and the querystring UserID or GroupID is missing, then the articles won't show up."
								ControlName="cbIsSocialInstance" />
						</td>
						<td class="right" style="border: 1px solid #AAD6F1; border-left: 0;">
							<asp:CheckBox ID="cbIsSocialInstance" runat="server" Checked="false" OnCheckedChanged="cbIsSocialInstance_CheckedChanged" AutoPostBack="true" />
						</td>
					</tr>
					<tr id="trPortalSharing" runat="server">
						<td class="left">
							<dnn:Label ID="lblPortalSharing" runat="server" Text="Portal sharing:" HelpText="Select data source portal." ControlName="ddlPortalSharing" HelpKey="lblPortalSharing.HelpText" ResourceKey="lblPortalSharing" />
						</td>
						<td class="right">
							<asp:DropDownList ID="ddlPortalSharing" runat="server" AppendDataBoundItems="True" AutoPostBack="True" DataTextField="PortalName" DataValueField="PortalIDFrom" CssClass="ddlcategorysettings" OnSelectedIndexChanged="ddlPortalSharing_SelectedIndexChanged">
								<asp:ListItem resourcekey="liCurrentPortal" Value="-1">Current portal</asp:ListItem>
							</asp:DropDownList>
						</td>
					</tr>
				</table>
				<asp:Panel ID="pnlSerchForm" runat="server">
					<asp:Panel ID="pnlDisplayInNews" runat="server">
						<table class="settings_table" cellpadding="0" cellspacing="0">
							<tr>
								<td class="left" style="width: 350px">
									<dnn:Label ID="lblSelectNewsModule" runat="server" ControlName="ddlSelectNewsModuleToDisplayResults" HelpText="Search results will open in selected module instance." Text="Select EasyDNNnews module to open search results:" HelpKey="lblSelectNewsModule.HelpText" ResourceKey="lblSelectNewsModule" />
								</td>
								<td class="right">
									<asp:DropDownList ID="ddlSelectNewsModuleToDisplayResults" runat="server" ValidationGroup="VgSaveSetting" resourcekey="ddlSelectNewsModuleToDisplayResultsResource1" />
								</td>
							</tr>
						</table>
					</asp:Panel>
				</asp:Panel>
				<h3 class="subsections">
					<%=Searchspecificoptions%></h3>
				<table class="settings_table" cellpadding="0" cellspacing="0">
					<tr>
						<td colspan="2" align="center">
							<asp:RadioButtonList ID="rblSearchCustomFields" runat="server" AutoPostBack="true" RepeatDirection="Horizontal" OnSelectedIndexChanged="rblSearchCustomFields_SelectedIndexChanged">
								<asp:ListItem Value="False" Text="Simple search" resourcekey="liSimpleSearch" Selected="True" />
								<asp:ListItem Value="True" Text="Advanced search" resourcekey="liAdvancedSearch" />
							</asp:RadioButtonList>
						</td>
					</tr>
				</table>
				<table id="tblSimpleSearch" runat="server" class="settings_table" cellpadding="0" cellspacing="0">
					<tr class="second">
						<td class="left">
							<dnn:Label ID="lblSearchButtonPosition" runat="server" Text="Serach button position:" ControlName="ddlSearchPosition" HelpText="Button position." HelpKey="lblSearchButtonPosition.HelpText" ResourceKey="lblSearchButtonPosition" />
						</td>
						<td class="right">
							<asp:DropDownList ID="ddlSearchPosition" runat="server" resourcekey="ddlSearchPositionResource1">
								<asp:ListItem Value="button_outside" resourcekey="ListItemResource8">Outside search textbox</asp:ListItem>
								<asp:ListItem Value="-1" resourcekey="ListItemResource9">Inside search textbox</asp:ListItem>
							</asp:DropDownList>
						</td>
					</tr>
					<tr>
						<td class="left">
							<dnn:Label ID="lblSearchWay" runat="server" Text="Search options:" ControlName="rblSearchWay" HelpText="Select search options." HelpKey="lblSearchWay.HelpText" ResourceKey="lblSearchWay" />
						</td>
						<td class="right">
							<asp:RadioButtonList ID="rblSearchWay" runat="server" resourcekey="rblSearchWayResource1">
								<asp:ListItem Selected="True" Value="title" resourcekey="ListItemResource10" Text="Search title and subtitle" />
								<asp:ListItem Value="article" resourcekey="ListItemResource11" Text="Search article" />
								<asp:ListItem Value="titleandarticle" resourcekey="ListItemResource12" Text="Search title, subtitle and article" />
							</asp:RadioButtonList>
						</td>
					</tr>
					<tr id="trAutoComplete" runat="server" class="second">
						<td class="left" style="width: 350px">
							<dnn:Label ID="lblAutoComplete" runat="server" Text="Auto complete box:" HelpText="Auto complete box when typing search term." ControlName="cbAutoComplete" HelpKey="lblAutoComplete.HelpText" ResourceKey="lblAutoComplete" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbAutoComplete" runat="server" Checked="True" />
						</td>
					</tr>
				</table>
				<table id="tblAdvancedSearch" runat="server" class="settings_table" cellpadding="0" cellspacing="0">
					<tr class="second">
						<td class="left" style="width: 350px">
							<dnn:Label ID="lblDisplayHeader" runat="server" Text="Display header:" HelpText="Displays header text from resource file (AdvancedSearchHeader.Text)." ControlName="cbDisplayHeader" HelpKey="lblDisplayHeader.HelpText" ResourceKey="lblDisplayHeader" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbDisplayHeader" runat="server" Checked="false" />
						</td>
					</tr>
					<tr>
						<td class="left" style="width: 350px">
							<dnn:Label ID="lblcfgroupselect" runat="server" Text="Select custom field group:" ControlName="ddlCfGroupSelect" HelpText="Select custom field group." HelpKey="lblcfgroupselect.HelpText" ResourceKey="lblcfgroupselect" />
						</td>
						<td class="right">
							<asp:DropDownList ID="ddlCfGroupSelect" runat="server" ValidationGroup="VgSaveSetting" resourcekey="ddlCfGroupSelectResource1" />
						</td>
					</tr>
					<tr class="second">
						<td class="left">
							<dnn:Label ID="lblSearchOnlySelectedCFGroup" runat="server" ControlName="cbSearchOnlySelectedCFGroup" Text="Search only articles in selected CF group:" HelpText="Only the articles in the selected Custom fields group will be searched. If this option is uncheched then all articles will be searched by the custom field, but the custom field group will not be taken into account." HelpKey="lblSearchOnlySelectedCFGroup.HelpText" ResourceKey="lblSearchOnlySelectedCFGroup" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbSearchOnlySelectedCFGroup" runat="server" Checked="false" />
						</td>
					</tr>
					<tr>
						<td class="left">
							<dnn:Label ID="lblCategoryCFGroupItems" runat="server" ControlName="cbCategoryCFGroupItems" Text="Connect news categories to custom field groups:" HelpText="Enable connection between news category and custom field group by passing query string." HelpKey="lblCategoryCFGroupItems.HelpText" ResourceKey="lblCategoryCFGroupItems" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbCategoryCFGroupItems" runat="server" Checked="false" />
						</td>
					</tr>
					<tr runat="server" id="rowCategoryCFGroupItems" style="display: none;">
						<td colspan="2">
							<asp:PlaceHolder ID="phCategoryCFGroupItems" runat="server" />
						</td>
					</tr>
				</table>
				<table class="settings_table" cellpadding="0" cellspacing="0">
					<tr>
						<td colspan="2" style="text-align: center; color: Red;">
							<asp:Label ID="lblSearchInfo" runat="server" EnableViewState="False" />
						</td>
					</tr>
				</table>
				<h3 class="subsections">
					<%=Themeandtemplate%></h3>
				<asp:UpdatePanel ID="upModuleTheme" runat="server">
					<ContentTemplate>
						<table class="settings_table" cellpadding="0" cellspacing="0">
							<tr>
								<td class="left">
									<dnn:Label ID="lblSelectTemplate" runat="server" ControlName="ddlTheme" Text="Module theme:" HelpText="Select theme." HelpKey="lblSelectTemplate.HelpText" ResourceKey="lblSelectTemplate" />
								</td>
								<td class="right">
									<asp:DropDownList ID="ddlTheme" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlTemplates_SelectedIndexChanged" />
									<asp:CompareValidator ID="cvThemeSelect" runat="server" ForeColor="Red" ControlToValidate="ddlTheme" Display="Dynamic" ErrorMessage=" Please select theme" Operator="NotEqual" ValidationGroup="VgSaveSetting" ValueToCompare="0" resourcekey="cvThemeSelectResource1.ErrorMessage" />
								</td>
							</tr>
							<tr class="second">
								<td class="left">
									<dnn:Label ID="lblSelectDisplayStyle" runat="server" Text="Module display style:" ControlName="ddlDisplayStyle" HelpText="Select display style." HelpKey="lblSelectDisplayStyle.HelpText" ResourceKey="lblSelectDisplayStyle" />
								</td>
								<td class="right">
									<asp:DropDownList ID="ddlDisplayStyle" runat="server" />
								</td>
							</tr>
							<tr id="trModuleTemplate" runat="server" visible="false">
								<td class="left">
									<dnn:Label ID="SelectHTMLTemplate" runat="server" Text="Module template:" ControlName="ddlHTMLTemplates" HelpText="Select template." HelpKey="SelectHTMLTemplate.HelpText" ResourceKey="SelectHTMLTemplate" />
								</td>
								<td class="right">
									<asp:DropDownList ID="ddlHTMLTemplates" runat="server" />
								</td>
							</tr>
						</table>
					</ContentTemplate>
				</asp:UpdatePanel>
				<asp:UpdateProgress ID="uppTheme" runat="server" AssociatedUpdatePanelID="upModuleTheme" DisplayAfter="100" DynamicLayout="true">
					<ProgressTemplate>
						<img src="<%=ModulePath.ToLower().Replace("easydnnnewssearch", "easydnnnews")%>images/settings/ajaxLoading.gif" alt="loading content" />
					</ProgressTemplate>
				</asp:UpdateProgress>
				<h3 class="subsections">
					<%=Filter%></h3>
				<asp:UpdatePanel ID="upCategoriesfilter" runat="server">
					<ContentTemplate>
						<table class="settings_table" cellpadding="0" cellspacing="0">
							<tr class="second">
								<td class="left">
									<dnn:Label ID="lblSearchFilterBy" runat="server" Text="Search articles and events" HelpText="This option allows for searching articles only, or events only, or both." HelpKey="lblSearchFilterBy.HelpText" ResourceKey="lblSearchFilterBy" />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbSearchArticles" runat="server" Text="Articles" Checked="True" />
									<asp:CheckBox ID="cbSearchEvents" runat="server" Text="Events" Checked="True" AutoPostBack="true" OnCheckedChanged="cbSearchEvents_CheckedChanged" />
								</td>
							</tr>
							<tr>
								<td class="left">
									<dnn:Label ID="lblShowOnlyEventsLimit" runat="server" HelpText="Set the criteria to search events whose start date has ended. The option 'Show all' will search all events, disregarding the fact that they have already ended. We can enter the number of days to be set in the past for past events in the field 'Limit to number of days in the past'. If the set value is 0, the criterion for the event's listing will be the current date. In that case, neither of the past events will be searched." Text="Searching of past events:" HelpKey="lblShowOnlyEventsLimit.HelpText" ResourceKey="lblShowOnlyEventsLimit" />
								</td>
								<td class="right">
									<asp:RadioButtonList ID="rblLimitBackEvents" runat="server" Style="float: left" RepeatDirection="Horizontal">
										<asp:ListItem Value="0" Text="ShowAll" />
										<asp:ListItem Value="1" Text="Limit to number of days:" Selected="True" />
									</asp:RadioButtonList>
									<asp:TextBox Style="float: left" ID="tbPastEventLimit" runat="server" Width="25px" Text="0" />
									<asp:RequiredFieldValidator ID="rfvPastEventLimit" runat="server" ControlToValidate="tbPastEventLimit" Display="Dynamic" ErrorMessage="This filed is required." SetFocusOnError="True" ValidationGroup="VgSaveSetting" />
									<asp:CompareValidator ID="cvPastEventLimit" runat="server" ControlToValidate="tbPastEventLimit" Display="Dynamic" ErrorMessage="Please enter number only." Operator="DataTypeCheck" Type="Integer" ValidationGroup="VgSaveSetting" />
								</td>
							</tr>
							<tr class="second">
								<td class="left" style="width: 350px">
									<dnn:Label ID="lblFilterCategories" runat="server" Text="Search all categories on portal:" HelpText="Show all categories in search menu, or filter by category." ControlName="cbFilterCategories" HelpKey="lblFilterCategories.HelpText" ResourceKey="lblFilterCategories" />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbdisplayallcats" runat="server" Checked="True" OnCheckedChanged="cbFilterCategories_CheckedChanged" AutoPostBack="True" resourcekey="cbdisplayallcatsResource1" />
								</td>
							</tr>
						</table>
						<table id="tblSelectCategories" runat="server" visible="false" class="settings_table" cellpadding="0" cellspacing="0" style="margin-left: auto; margin-right: auto;">
							<tr>
								<td class="left" style="width: 350px"></td>
								<td class="right">
									<asp:CheckBox ID="cbAutoAddCatChilds" runat="server" Text="Auto select all child categories." resourcekey="cbAutoAddCatChildsResource1" />
								</td>
							</tr>
							<tr class="second">
								<td class="left">
									<dnn:Label ID="lbltvCategories" runat="server" Text="Manage category filter:" HelpText="Enable/disable category." ControlName="tvCategories" HelpKey="lbltvCategories.Helptext" ResourceKey="lbltvCategories" />
								</td>
								<td class="right">
									<asp:TreeView ID="tvCatAndSubCat" runat="server" ForeColor="Black" ShowCheckBoxes="All" ShowExpandCollapse="False" ShowLines="True" />
									<asp:CustomValidator ID="cvCategoriesTreeview" runat="server" ForeColor="Red" ClientValidationFunction="ClientValidate" Display="Dynamic" Enabled="False" ErrorMessage="Please select at least one category." ValidationGroup="VgSaveSetting" resourcekey="cvCategoriesTreeview.ErrorMessage" />
								</td>
							</tr>
						</table>
					</ContentTemplate>
				</asp:UpdatePanel>
				<asp:UpdateProgress ID="uppCategoriesfilter" runat="server" AssociatedUpdatePanelID="upCategoriesfilter" DisplayAfter="100" DynamicLayout="true">
					<ProgressTemplate>
						<img src="<%=ModulePath.ToLower().Replace("easydnnnewssearch", "easydnnnews")%>images/settings/ajaxLoading.gif" alt="loading content" />
					</ProgressTemplate>
				</asp:UpdateProgress>
				<asp:UpdatePanel ID="upAuthorsFilter" runat="server">
					<ContentTemplate>
						<table id="tblAuthorSelection" runat="server" class="settings_table" cellpadding="0" cellspacing="0">
							<tr>
								<td class="left" style="width: 350px">
									<dnn:Label ID="lblFilterAuthors" runat="server" Text="Search all authors on portal:" HelpText="Show all authors in search menu, or filter by author." ControlName="cbFilterCategories" HelpKey="lblFilterAuthors" ResourceKey="lblFilterAuthors" />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbDisplayAllAuthors" runat="server" AutoPostBack="True" OnCheckedChanged="cbDisplayAllAuthors_CheckedChanged" Checked="True" resourcekey="cbDisplayAllAuthorsResource1" />
								</td>
							</tr>
							<tr id="rowAuthorsFilter" runat="server" visible="false" class="second">
								<td class="left" style="width: 350px" runat="server">
									<dnn:Label ID="lblAuthorSelection" runat="server" Text="Select authors to include in search:" HelpText="Select authors to include in search." HelpKey="lblAuthorSelection.HelpText" ResourceKey="lblAuthorSelection" />
								</td>
								<td class="right" runat="server">
									<asp:TreeView ID="tvAuthorAndGroupSelection" runat="server" ForeColor="Black" ImageSet="Contacts" ShowCheckBoxes="All" NodeIndent="25">
										<HoverNodeStyle Font-Underline="False" />
										<NodeStyle Font-Names="Verdana" Font-Size="8pt" ForeColor="Black" HorizontalPadding="5px" NodeSpacing="0px" VerticalPadding="0px" />
										<ParentNodeStyle Font-Bold="True" ForeColor="#5555DD" />
										<SelectedNodeStyle Font-Underline="True" HorizontalPadding="0px" VerticalPadding="0px" />
									</asp:TreeView>
									<asp:CustomValidator ID="cvAuthorsTreeview" runat="server" ForeColor="Red" ClientValidationFunction="ClientValidateAuthors" Display="Dynamic" Enabled="False" ErrorMessage="Please select at least one author." ValidationGroup="VgSaveSetting" resourcekey="cvAuthorsTreeview.ErrorMessage" />
								</td>
							</tr>
						</table>
					</ContentTemplate>
				</asp:UpdatePanel>
				<asp:UpdateProgress ID="uppAuthorsFilter" runat="server" AssociatedUpdatePanelID="upAuthorsFilter" DisplayAfter="100" DynamicLayout="true">
					<ProgressTemplate>
						<img src="<%=ModulePath.ToLower().Replace("easydnnnewssearch", "easydnnnews")%>images/settings/ajaxLoading.gif" alt="loading content" />
					</ProgressTemplate>
				</asp:UpdateProgress>
				<asp:Panel ID="pnlLocalization" runat="server" Visible="false">
					<%--				<h3 class="subsections">
					Localization:</h3>--%>
					<table class="settings_table" cellpadding="0" cellspacing="0" style="display: none">
						<tr>
							<td class="left">
								<dnn:Label ID="lblHideUnlocalizedItems" runat="server" Text="Don't show unlocalized items:" HelpText="Articles, events that are unlocalized won't show when localization selected." />
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
			</p>
			<div class="buttons">
				<asp:Button ID="btnSaveSettings" runat="server" OnClick="btnSaveSettings_Click" Text="Save" ValidationGroup="VgSaveSetting" resourcekey="btnSaveSettingsResource1" />
				<asp:Button ID="btnSaveClose" runat="server" OnClick="btnSaveClose_Click" Text="Save &amp; Close" resourcekey="btnSaveCloseResource1" ValidationGroup="VgSaveSetting" />
				<asp:Button ID="btnCancel" runat="server" OnClick="btnCancel_Click" Text="Close" resourcekey="btnCancelResource1" />
			</div>
		</div>
	</div>
</div>
