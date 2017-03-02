<%@ control language="C#" inherits="EasyDNN.Modules.EasyDNNNewsTagCloud.EditEasyDNNNewsTagCloud, App_Web_editeasydnnnewstagcloud.ascx.c28fc201" autoeventwireup="true" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<script type="text/javascript">
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
		}
	}
</script>
<div id="EDNadmin">
	<div class="module_settings">
		<div class="settings_category_container last">
			<div class="category_toggle">
				<h2>
					<%=Tagcloudsettings%></h2>
			</div>
			<div class="category_content">
				<div id="pnlSocialInstance" runat="server" style="display: none;">
					<table class="settings_table" cellpadding="0" cellspacing="0">
						<tr runat="server" style="background: #D1EBFA;">
							<td class="left" style="border: 1px solid #AAD6F1; border-right: 0;">
								<dnn:Label ID="lblIsSocialInstance" runat="server" Text="Community mode:" HelpText="Displays user's and group's articles on the Activity feed. The articles are filtered by the UserID or GroupID querystring. If this option is enabled and the querystring UserID or GroupID is missing, then the articles won't show up."
									ControlName="cbIsSocialInstance" />
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
									<asp:ListItem resourcekey="liCurrentPortal" Value="-1" Text="Current portal" />
								</asp:DropDownList>
							</td>
						</tr>
					</table>
				</div>
				<h3 class="subsections">
					<%=Permissions%></h3>
				<asp:UpdatePanel ID="upPermissionSettings" runat="server">
					<ContentTemplate>
						<div class="edn_admin_progress_overlay_container">
							<asp:UpdateProgress ID="uppPermissionSettings" runat="server" AssociatedUpdatePanelID="upPermissionSettings" DisplayAfter="100" DynamicLayout="true">
								<ProgressTemplate>
									<div class="edn_admin_progress_overlay">
									</div>
								</ProgressTemplate>
							</asp:UpdateProgress>
							<table class="settings_table" cellpadding="0" cellspacing="0">
								<tr class="second">
									<td class="left">
										<dnn:Label ID="lblPermissionSource" runat="server" Text="Select permission source:" HelpText="Category menu will inherit permission from selected source. Tags from allowed categories will show in module." HelpKey="lblPermissionSource.HelpText" ResourceKey="lblPermissionSource" />
									</td>
									<td class="right">
										<asp:RadioButtonList ID="rblCategoryPermissionSource" runat="server" OnSelectedIndexChanged="rblCategoryPermissionSource_SelectedIndexChanged" AutoPostBack="True" RepeatDirection="Horizontal">
											<asp:ListItem Selected="True" Text="None" Value="0" resourcekey="ListItemResource1" />
											<asp:ListItem Text="Portal" Value="1" resourcekey="ListItemResource2" />
											<asp:ListItem Text="Module" Value="2" resourcekey="ListItemResource3" />
										</asp:RadioButtonList>
										<asp:Panel ID="pnlCategoryModuleInherite" runat="server" Visible="False">
											<asp:DropDownList ID="ddlPermFromModuleInstance" runat="server" />
										</asp:Panel>
									</td>
								</tr>
							</table>
						</div>
					</ContentTemplate>
				</asp:UpdatePanel>
				<h3 class="subsections">
					<%=TagCouldOptions%></h3>
				<table class="settings_table" cellpadding="0" cellspacing="0">
					<tr class="second">
						<td class="left">
							<dnn:Label ID="lblNumberOfTags" runat="server" Text="Number of tags:" HelpText="Number of tags to display. 0 to display all tags." HelpKey="lblNumberOfTags.HelpText" ResourceKey="lblNumberOfTags" />
						</td>
						<td class="right">
							<asp:TextBox ID="tbNumberOfTags" runat="server" Width="50px" ValidationGroup="vgSave" resourcekey="tbNumberOfTagsResource1" Text="10" />
							<asp:RequiredFieldValidator ID="rfvNumberOfTags" runat="server" ForeColor="Red" ControlToValidate="tbNumberOfTags" Display="Dynamic" ErrorMessage="This filed is required." ValidationGroup="vgSave" resourcekey="rfvNumberOfTagsResource1" />
							<asp:CompareValidator ID="cvNumberOfTags" runat="server" ForeColor="Red" ControlToValidate="tbNumberOfTags" Display="Dynamic" ErrorMessage="Enter number only." Operator="DataTypeCheck" Type="Integer" ValidationGroup="vgSave" resourcekey="cvNumberOfTagsResource1" />
						</td>
					</tr>
					<tr>
						<td class="left">
							<dnn:Label ID="lblSorting" runat="server" Text="Sorting:" HelpText="Tag sorting type:" HelpKey="lblSorting.HelpText" ResourceKey="lblSorting" />
						</td>
						<td class="right">
							<asp:DropDownList ID="ddlSorting" runat="server">
								<asp:ListItem Value="TagName" Text="Tag name" resourcekey="ListItemResource4" />
								<asp:ListItem Value="Number" Text="Number of posts" resourcekey="ListItemResource5" />
							</asp:DropDownList>
						</td>
					</tr>
					<tr class="second">
						<td class="left">
							<dnn:Label ID="lblShowTagCount" runat="server" Text="Show tag count:" HelpText="Shows number of tag appearance." HelpKey="lblShowTagCount.HelpText" ResourceKey="lblShowTagCount" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbShowTagCount" runat="server" Checked="False" />
						</td>
					</tr>
					<tr>
						<td class="left">
							<dnn:Label ID="lblModuleToOpen" runat="server" Text="Open in:" HelpText="Select news module instance or page to open articles:" HelpKey="lblModuleToOpen.HelpText" ResourceKey="lblModuleToOpen" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbModules" Style="display: none" runat="server" AutoPostBack="True" Checked="True" OnCheckedChanged="cbModules_CheckedChanged" />
							<asp:DropDownList ID="ddlOpenDetails" runat="server" />
						</td>
					</tr>
					<tr class="second" style="display: none">
						<td class="left"></td>
						<td class="right">
							<asp:CheckBox ID="cbPage" runat="server" AutoPostBack="True" OnCheckedChanged="cbPage_CheckedChanged" Text="Page" resourcekey="cbPageResource1" />
							<asp:DropDownList ID="ddlPageOpenDetails" runat="server" />
						</td>
					</tr>
					<tr class="second">
						<td class="left">
							<dnn:Label ID="lblDisplayHeader" runat="server" Text="Display header:" HelpText="Display header:" HelpKey="lblDisplayHeader.HelpText" ResourceKey="lblDisplayHeader" Visible="True" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbDisplayHeader" runat="server" Checked="True" />
						</td>
					</tr>
					<tr>
						<td class="left">
							<dnn:Label ID="lblTagsByCategory" runat="server" Text="Dynamically display tags from the selected category:" HelpText="While navigating through multiple categories, only the currently selected category's tags are displayed." HelpKey="lblTagsByCategory.HelpText"
								ResourceKey="lblTagsByCategory" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbTagsByCategory" runat="server" Checked="False" />
						</td>
					</tr>
					<tr class="second">
						<td colspan="2" style="text-align: center; color: Red;">
							<asp:Label ID="lblTagCloudInfo" runat="server" EnableViewState="False" />
						</td>
					</tr>
				</table>
				<h3 class="subsections">
					<%=Themeandtemplate%></h3>
				<asp:UpdatePanel ID="upModuleTheme" runat="server">
					<ContentTemplate>
						<div class="edn_admin_progress_overlay_container">
							<asp:UpdateProgress ID="uppModuleTheme" runat="server" AssociatedUpdatePanelID="upModuleTheme" DisplayAfter="100" DynamicLayout="true">
								<ProgressTemplate>
									<div class="edn_admin_progress_overlay">
									</div>
								</ProgressTemplate>
							</asp:UpdateProgress>
							<table class="settings_table" cellpadding="0" cellspacing="0">
								<tr class="second">
									<td class="left">
										<dnn:Label ID="lblTagsTheme" runat="server" Text="Module theme:" ControlName="ddlTheme" HelpText="Select theme." HelpKey="lblTagsTheme.HelpText" ResourceKey="lblTagsTheme" />
									</td>
									<td class="right">
										<asp:DropDownList ID="ddlTheme" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlTemplates_SelectedIndexChanged" ValidationGroup="vgSave" />
										<asp:CompareValidator ID="cvThemeSelect" runat="server" ForeColor="Red" ControlToValidate="ddlTheme" Display="Dynamic" ErrorMessage=" Please select theme" Operator="NotEqual" ValidationGroup="vgSave" ValueToCompare="0" resourcekey="cvThemeSelectResource1.ErrorMessage" />
									</td>
								</tr>
								<tr>
									<td class="left">
										<dnn:Label ID="lblSelectDisplayStyle" runat="server" Text="Module display style:" HelpText="Select display style." HelpKey="lblSelectDisplayStyle.HelpText" ResourceKey="lblSelectDisplayStyle" />
									</td>
									<td class="right">
										<asp:DropDownList ID="ddlDisplayStyle" runat="server" ValidationGroup="vgSave" />
									</td>
								</tr>
								<tr class="second">
									<td class="left">
										<dnn:Label ID="lblHtmTemplate" runat="server" Text="Module htm template:" HelpText="Htm template." HelpKey="lblHtmTemplate.HelpText" ResourceKey="lblHtmTemplate" />
									</td>
									<td class="right">
										<asp:DropDownList ID="ddlHtmTemplate" runat="server" ValidationGroup="vgSave" />
									</td>
								</tr>
							</table>
						</div>
					</ContentTemplate>
				</asp:UpdatePanel>
				<h3 class="subsections">
					<%=Filter%></h3>
				<asp:UpdatePanel ID="upCategoriesfilter" runat="server">
					<ContentTemplate>
						<div class="edn_admin_progress_overlay_container">
							<asp:UpdateProgress ID="uppCategoriesfilter" runat="server" AssociatedUpdatePanelID="upCategoriesfilter" DisplayAfter="100" DynamicLayout="true">
								<ProgressTemplate>
									<div class="edn_admin_progress_overlay">
									</div>
								</ProgressTemplate>
							</asp:UpdateProgress>
							<table class="settings_table" cellpadding="0" cellspacing="0">
								<tr class="second">
									<td class="left">
										<dnn:Label ID="lblTagsFilterBy" runat="server" Text="Display articles and events:" HelpText="This option allows for displaying articles only, or events only, or both." HelpKey="lblTagsFilterBy.HelpText" ResourceKey="lblTagsFilterBy" />
									</td>
									<td class="right">
										<asp:CheckBox ID="cbFilterByArticles" runat="server" Text="Articles" Checked="True" />
										<asp:CheckBox ID="cbFilterByEvents" runat="server" Text="Events" Checked="True" AutoPostBack="true" OnCheckedChanged="cbFilterByEvents_CheckedChanged" />
									</td>
								</tr>
								<tr>
									<td class="left">
										<dnn:Label ID="lblShowOnlyEventsLimit" runat="server" HelpText="Set the criteria to display events whose start date has ended. The option 'Show all' will display all events, disregarding the fact that they have already ended. We can enter the number of days to be set in the past for past events in the field 'Limit to number of days in the past'. If the set value is 0, the criterion for the event's listing will be the current date. In that case, neither of the past events will be displayed." Text="Displaying of past events:" HelpKey="lblShowOnlyEventsLimit.HelpText" ResourceKey="lblShowOnlyEventsLimit" />
									</td>
									<td class="right">
										<asp:RadioButtonList ID="rblLimitBackEvents" runat="server" Style="float: left" RepeatDirection="Horizontal">
											<asp:ListItem Value="0" Text="ShowAll" />
											<asp:ListItem Value="1" Text="Limit to number of days:" Selected="True" />
										</asp:RadioButtonList>
										<asp:TextBox Style="float: left" ID="tbPastEventLimit" runat="server" Width="25px" Text="0" />
										<asp:RequiredFieldValidator ID="rfvPastEventLimit" runat="server" ControlToValidate="tbPastEventLimit" Display="Dynamic" ErrorMessage="This filed is required." SetFocusOnError="True" ValidationGroup="vgSave" />
										<asp:CompareValidator ID="cvPastEventLimit" runat="server" ControlToValidate="tbPastEventLimit" Display="Dynamic" ErrorMessage="Please enter number only." Operator="DataTypeCheck" Type="Integer" ValidationGroup="vgSave" />
									</td>
								</tr>
								<tr>
									<td class="left">
										<dnn:Label ID="lblCelectCats" runat="server" Text="Select categories to display tags from:" HelpText="Show all categories or make category selection in the tree view selection list." HelpKey="lblCelectCats.HelpText" ResourceKey="lblCelectCats" />
									</td>
									<td class="right">
										<asp:CheckBox ID="cbdisplayallcats" runat="server" AutoPostBack="True" Checked="True" OnCheckedChanged="cbdisplayallcats_CheckedChanged" Text="Display tags from all categories" resourcekey="cbdisplayallcatsResource1" />
									</td>
								</tr>
							</table>
							<table id="tblSelectCategories" runat="server" visible="false" class="settings_table" cellpadding="0" cellspacing="0" style="margin-left: auto; margin-right: auto;">
								<tr class="second">
									<td class="left"></td>
									<td class="right">
										<asp:CheckBox ID="cbAutoAddCatChilds" runat="server" Text="Auto select all child categories." resourcekey="cbAutoAddCatChildsResource1" />
									</td>
								</tr>
								<tr>
									<td class="left"></td>
									<td class="right">
										<asp:TreeView ID="tvCatAndSubCat" CssClass="categories_to_display" runat="server" ForeColor="Black" ShowCheckBoxes="All" ShowExpandCollapse="False" ShowLines="True" resourcekey="tvCatAndSubCatResource1" />
										<asp:CustomValidator ID="cvCategoriesTreeview" runat="server" ForeColor="Red" ClientValidationFunction="ClientValidate" ErrorMessage="Please select at least one category." Display="Dynamic" Enabled="False" resourcekey="cvCategoriesTreeview.ErrorMessage"
											ValidationGroup="vgSave" />
									</td>
								</tr>
							</table>
						</div>
					</ContentTemplate>
				</asp:UpdatePanel>
				<asp:UpdatePanel ID="upAuthorsFilter" runat="server">
					<ContentTemplate>
						<div class="edn_admin_progress_overlay_container">
							<asp:UpdateProgress ID="uppAuthorsFilter" runat="server" AssociatedUpdatePanelID="upAuthorsFilter" DisplayAfter="100" DynamicLayout="true">
								<ProgressTemplate>
									<div class="edn_admin_progress_overlay">
									</div>
								</ProgressTemplate>
							</asp:UpdateProgress>
							<table class="settings_table" cellpadding="0" cellspacing="0">
								<tr class="second">
									<td class="left">
										<dnn:Label ID="lblFilterAuthors" runat="server" Text="Display articles from all authors in the portal:" HelpText="Display articles from all authors in the portal:" ControlName="cbFilterCategories" HelpKey="lblFilterAuthors.HelpText" ResourceKey="lblFilterAuthors" />
									</td>
									<td class="right">
										<asp:CheckBox ID="cbDisplayAllAuthors" runat="server" AutoPostBack="True" OnCheckedChanged="cbDisplayAllAuthors_CheckedChanged" Checked="True" />
									</td>
								</tr>
								<tr>
									<td class="left"></td>
									<td class="right">
										<asp:TreeView ID="tvAuthorAndGroupSelection" runat="server" ForeColor="Black" ImageSet="Contacts" ShowCheckBoxes="All" NodeIndent="25" Visible="false">
											<HoverNodeStyle Font-Underline="False" />
											<NodeStyle Font-Names="Verdana" Font-Size="8pt" ForeColor="Black" HorizontalPadding="5px" NodeSpacing="0px" VerticalPadding="0px" />
											<ParentNodeStyle Font-Bold="True" ForeColor="#5555DD" />
											<SelectedNodeStyle Font-Underline="True" HorizontalPadding="0px" VerticalPadding="0px" />
										</asp:TreeView>
										<asp:CustomValidator ID="cvAuthorsTreeview" runat="server" ForeColor="Red" ClientValidationFunction="ClientValidateAuthors" Display="Dynamic" Enabled="False" ErrorMessage="Please select at least one author." resourcekey="cvAuthorsTreeview.ErrorMessage"
											ValidationGroup="vgSave" />
									</td>
								</tr>
							</table>
						</div>
					</ContentTemplate>
				</asp:UpdatePanel>
				<asp:Panel ID="pnlLocalization" runat="server" Visible="false">
					<h3 class="subsections">
						<%=LocalizationText%></h3>
					<table class="settings_table" cellpadding="0" cellspacing="0">
						<tr>
							<td class="left">
								<dnn:Label ID="lblHideUnlocalizedItems" runat="server" Text="Don't show unlocalized items:" HelpText="Articles, events that are unlocalized won't show when localization selected." HelpKey="lblHideUnlocalizedItems.HelpText" ResourceKey="lblHideUnlocalizedItems" />
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
				<asp:Button ID="btnSaveSettings" runat="server" OnClick="btnSaveSettings_Click" Text="Save" ValidationGroup="vgSave" resourcekey="btnSaveSettingsResource1" />
				<asp:Button ID="btnSaveClose" runat="server" OnClick="btnSaveClose_Click" Text="Save &amp; Close" ValidationGroup="vgSave" resourcekey="btnSaveCloseResource1" />
				<asp:Button ID="btnCancel" runat="server" OnClick="btnCancel_Click" Text="Close" resourcekey="btnCancelResource1" />
			</div>
		</div>
	</div>
</div>
