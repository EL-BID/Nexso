<%@ control language="C#" autoeventwireup="true" inherits="EasyDNNSolutions.Modules.EasyDNNNews.Widgets.SettingsFilterMenu, App_Web_settings.ascx.90a72b57" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<script type="text/javascript">

	function CategoryClientValidate(source, arguments) {
		if ($('#<%=cbFilterMenudisplayallcats2.ClientID%>')[0].checked) {
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
		var treeView = document.getElementById("<%= tvAuthorAndGroupSelection2.ClientID %>");
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
		var cbAutoAddCat3 = document.getElementById('<%=cbAutoAddCatChilds2.ClientID%>');
		if (cbAutoAddCat3 != null) {
			$('#advanced_tree_view_categor_selector').EDS_TreeViewSelector({
				state_checkbox: $('#<%=cbAutoAddCatChilds2.ClientID %>')
			});
		}
	});

	function pageLoad(sender, args) {
		if (args.get_isPartialLoad()) {

			function CategoryClientValidate(source, arguments) {
				if ($('#<%=cbFilterMenudisplayallcats2.ClientID%>')[0].checked) {
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
				var treeView = document.getElementById("<%= tvAuthorAndGroupSelection2.ClientID %>");
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

				var cbAutoAddCat4 = document.getElementById('<%=cbAutoAddCatChilds2.ClientID%>');
				if (cbAutoAddCat4 != null) {
					$('#advanced_tree_view_categor_selector').EDS_TreeViewSelector({
						state_checkbox: $('#<%=cbAutoAddCatChilds2.ClientID %>')
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
								<dnn:Label ID="lblFilterBy2" runat="server" Text="Display articles and events:" HelpText="This option allows for displaying articles only, or events only, or both." HelpKey="lblFilterBy.HelpText" ResourceKey="lblFilterBy" />
							</td>
							<td class="right">
								<asp:CheckBox ID="cbFilterByArticles2" runat="server" Text="Articles" Checked="True" />
								<asp:CheckBox ID="cbFilterByEvents2" runat="server" Text="Events" Checked="True" AutoPostBack="true" OnCheckedChanged="cbFilterByEvents2_CheckedChanged" />
							</td>
						</tr>
						<tr>
							<td class="left">
								<dnn:Label ID="lblFilterByEventsLimit2" runat="server" HelpText="Set the criteria to display events whose start date has ended. The option 'Show all' will display all events, disregarding the fact that they have already ended. We can enter the number of days to be set in the past for past events in the field 'Limit to number of days in the past'. If the set value is 0, the criterion for the event's listing will be the current date. In that case, neither of the past events will be displayed." Text="Displaying of past events:" HelpKey="lblShowOnlyEventsLimit.HelpText" ResourceKey="lblShowOnlyEventsLimit" />
							</td>
							<td class="right">
								<asp:RadioButtonList ID="rblLimitBackEvents2" runat="server" Style="float: left" RepeatDirection="Horizontal">
									<asp:ListItem Value="0" Text="ShowAll" />
									<asp:ListItem Value="1" Text="Limit to number of days:" Selected="True" />
								</asp:RadioButtonList>
								<asp:TextBox Style="float: left" ID="tbPastEventLimit2" runat="server" Width="25px" Text="0" />
								<asp:RequiredFieldValidator ID="rfvPastEventLimit2" runat="server" ControlToValidate="tbPastEventLimit2" Display="Dynamic" ErrorMessage="This filed is required." SetFocusOnError="True" ValidationGroup="vgCatMenuSettings2" />
								<asp:CompareValidator ID="cvPastEventLimit2" runat="server" ControlToValidate="tbPastEventLimit2" Display="Dynamic" ErrorMessage="Please enter number only." Operator="DataTypeCheck" Type="Integer" ValidationGroup="vgCatMenuSettings2" />
							</td>
						</tr>
					</table>
				</div>
				<div id="pnlSocialInstance2" runat="server" style="display: none;">
					<h3 class="subsections">Social settings</h3>
					<table class="settings_table" cellpadding="0" cellspacing="0">
						<tr id="Tr12" runat="server" style="background: #D1EBFA;">
							<td class="left" style="border: 1px solid #AAD6F1; border-right: 0;">
								<dnn:Label ID="lblIsSocialInstance2" runat="server" Text="Community mode:" HelpText="Displays user's and group's articles on the Activity feed. The articles are filtered by the UserID or GroupID querystring. If this option is enabled and the querystring UserID or GroupID is missing, then the articles won't show up."
									ControlName="cbIsSocialInstance2" ResourceKey="lblIsSocialInstance" />
							</td>
							<td class="right" style="border: 1px solid #AAD6F1; border-left: 0;">
								<asp:CheckBox ID="cbIsSocialInstance2" runat="server" Checked="false" OnCheckedChanged="cbIsSocialInstance_CheckedChanged" AutoPostBack="true" />
							</td>
						</tr>
					</table>
				</div>
				<div id="pnlPortalSharing2" runat="server">
					<h3 class="subsections">
						<%=Portalsharing%></h3>
					<table class="settings_table" cellpadding="0" cellspacing="0">
						<tr>
							<td class="left">
								<dnn:Label ID="lblPortalSharing" runat="server" Text="Select portal:" HelpText="Select data source portal." ControlName="ddlPortalSharing2" ResourceKey="lblPortalSharing" />
							</td>
							<td class="right">
								<asp:DropDownList ID="ddlPortalSharing2" runat="server" AppendDataBoundItems="True" AutoPostBack="True" DataTextField="PortalName" DataValueField="PortalIDFrom" CssClass="ddlcategorysettings" OnSelectedIndexChanged="ddlPortalSharing_SelectedIndexChanged">
									<asp:ListItem ResourceKey="liCurrentportal" Value="-1" Text="Current portal" />
								</asp:DropDownList>
							</td>
						</tr>
					</table>
				</div>
				<h3 class="subsections">
					<%=Menuspecificoptions%></h3>
				<table class="settings_table" cellpadding="0" cellspacing="0">
					<%--					<tr class="second">
						<td class="left">
							<dnn:Label ID="lblDisplayHeader" runat="server" Text="Display header:" HelpText="Display header." ResourceKey="lblDisplayHeader" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbDisplayHeader2" runat="server" Checked="True" />
						</td>
					</tr>--%>
					<tr>
						<td class="left">
							<dnn:Label ID="lblSelectModule" runat="server" Text="Select module to display results:" HelpText="Select news module instance to open articles." ControlName="ddlOpenDetails2" ResourceKey="lblSelectModule" />
						</td>
						<td class="right">
							<asp:DropDownList ID="ddlOpenDetails2" runat="server" />
						</td>
					</tr>
				</table>
				<h3 class="subsections">
					<%=Theme%></h3>
				<asp:UpdatePanel ID="upModuleTheme2" runat="server">
					<ContentTemplate>
						<table class="settings_table" cellpadding="0" cellspacing="0">
							<tr class="second">
								<td class="left">
									<dnn:Label ID="lblTheme" runat="server" Text="Theme:" ControlName="ddlTheme2" HelpText="Select theme." ResourceKey="lblTheme" />
								</td>
								<td class="right">
									<asp:DropDownList ID="ddlTheme2" runat="server" OnSelectedIndexChanged="ddlTheme_SelectedIndexChanged" AutoPostBack="True" ValidationGroup="vgCatMenuSettings2" />
									<asp:CompareValidator ID="cvThemeSelect2" resourcekey="cvThemeSelect.ErrorMessage" runat="server" ForeColor="Red" ControlToValidate="ddlTheme2" Display="Dynamic" ErrorMessage=" Please select theme." Operator="NotEqual" ValidationGroup="vgCatMenuSettings2"
										ValueToCompare="" />
								</td>
							</tr>
							<tr class="second">
								<td class="left">
									<dnn:Label ID="lblThemeStyle2" ResourceKey="lblThemeStyle2" runat="server" Text="Theme style:" ControlName="ddlThemeStyle2" HelpText="Theme style." />
								</td>
								<td class="right">
									<asp:DropDownList ID="ddlThemeStyle2" runat="server" />
								</td>
							</tr>
							<tr>
								<td class="left">
									<dnn:Label ID="lblThemeHTMLTemplate" ResourceKey="lblThemeHTMLTemplate" runat="server" Text="HTML template:" HelpText="Select HTML template." ControlName="ddlThemeHTMLTemplate2" />
								</td>
								<td class="right">
									<asp:DropDownList ID="ddlThemeHTMLTemplate2" runat="server" ValidationGroup="vgCatMenuSettings2" />
									<asp:CompareValidator ID="cvThemeHTMLTemplate" runat="server" ForeColor="Red" ControlToValidate="ddlThemeHTMLTemplate2" Display="Dynamic" ErrorMessage=" Please select HTML template" Operator="NotEqual" ValidationGroup="vgCatMenuSettings2" ValueToCompare="" />
								</td>
							</tr>
						</table>
					</ContentTemplate>
				</asp:UpdatePanel>
				<asp:UpdateProgress ID="uppTheme2" runat="server" AssociatedUpdatePanelID="upModuleTheme2" DisplayAfter="100" DynamicLayout="true">
					<ProgressTemplate>
						<img src="<%=ModulePath.Replace("EasyDNNnewsWidgets/Controls/FilterMenu/Settings", "EasyDNNnews")%>images/settings/ajaxLoading.gif" />
					</ProgressTemplate>
				</asp:UpdateProgress>
				<h3 class="subsections">
					<%=Filter%></h3>
				<asp:UpdatePanel ID="upCategoriesfilter2" runat="server">
					<ContentTemplate>
						<table class="settings_table" cellpadding="0" cellspacing="0">
							<tr class="second">
								<td class="left">
									<dnn:Label ID="lblShowCategoryFilter2" ResourceKey="lblShowCategoryFilter2" runat="server" Text="Show category filter:" ControlName="cbShowCategoryFilter2" HelpText="Show category filter." />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbShowCategoryFilter2" runat="server" Checked="True" OnCheckedChanged="cbShowCategoryFilter2_CheckedChanged" AutoPostBack="true" />
								</td>
							</tr>
						</table>
						<table class="settings_table" cellpadding="0" cellspacing="0" runat="server" id="tblCategoryFilter2">
							<tr>
								<td class="left">
									<dnn:Label ID="lblUseAndOperatorByCategory2" ResourceKey="lblUseAndOperatorByCategory2" runat="server" Text="Use AND operator when filtering:" ControlName="cbUseAndOperatorByCategory2" HelpText="Content must be in all selected categories if AND operator is used." />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbUseAndOperatorByCategory2" runat="server" Checked="false" />
								</td>
							</tr>
							<tr>
								<td class="left">
									<dnn:Label ID="lblExpandAllCategories2" ResourceKey="lblExpandAllCategories2" runat="server" Text="Expand all categories:" ControlName="cbExpandAllCategories2" HelpText="All categories are expanded." />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbExpandAllCategories2" runat="server" Checked="false" />
								</td>
							</tr>
							<tr class="second">
								<td class="left">
									<dnn:Label ID="lblShowCategoryArticleCount2" ResourceKey="lblShowCategoryArticleCount2" runat="server" Text="Show count:" HelpText="Show article count by author." ControlName="cbShowCategoryArticleCount2" />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbShowCategoryArticleCount2" runat="server" Checked="false" />
								</td>
							</tr>
							<tr>
								<td class="left">
									<dnn:Label ID="lblSelectCats" runat="server" ResourceKey="lblSelectCats" Text="Select categories to display:" ControlName="cbFilterMenudisplayallcats2" HelpText="Show all categories or make category selection in the tree view selection list." />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbFilterMenudisplayallcats2" resourcekey="cbdisplayallcats" runat="server" AutoPostBack="True" Checked="True" OnCheckedChanged="cbdisplayallcats_CheckedChanged" Text="Display all categories and subcategories" />
								</td>
							</tr>
							<tr runat="server" id="rowSelectCategories2" visible="false">
								<td colspan="2">
									<table class="settings_table" cellpadding="0" cellspacing="0" style="margin-left: auto; margin-right: auto;">
										<tr class="second">
											<td class="left"></td>
											<td class="right">
												<asp:CheckBox ID="cbAutoAddCatChilds2" resourcekey="cbAutoAddCatChilds" runat="server" Text="Auto select all child categories." />
											</td>
										</tr>
										<tr>
											<td colspan="2">
												<asp:PlaceHolder ID="pnlDinamicTreeView2" runat="server" />
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</ContentTemplate>
				</asp:UpdatePanel>
				<asp:UpdateProgress ID="uppCategoriesfilter2" runat="server" AssociatedUpdatePanelID="upCategoriesfilter2" DisplayAfter="100" DynamicLayout="true">
					<ProgressTemplate>
						<img src="<%=ModulePath.Replace("EasyDNNnewsWidgets/Controls/FilterMenu/Settings", "EasyDNNnews")%>images/settings/ajaxLoading.gif" />
					</ProgressTemplate>
				</asp:UpdateProgress>
				<asp:UpdatePanel ID="upAuthorsFilter2" runat="server">
					<ContentTemplate>
						<table class="settings_table" cellpadding="0" cellspacing="0">
							<tr class="second">
								<td class="left">
									<dnn:Label ID="lblShowAuthorFilter2" ResourceKey="lblShowAuthorFilter2" runat="server" Text="Show author filter:" ControlName="cbShowAuthorFilter2" HelpText="Show author filter." />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbShowAuthorFilter2" runat="server" Checked="True" OnCheckedChanged="cbShowAuthorFilter2_CheckedChanged" AutoPostBack="true" />
								</td>
							</tr>
						</table>
						<table class="settings_table" cellpadding="0" cellspacing="0" runat="server" id="tblShowAuthorFilter2">
							<tr>
								<td class="left">
									<dnn:Label ID="lblExpandAllAuthors2" ResourceKey="lblExpandAllAuthors2" runat="server" Text="Expand all author groups:" ControlName="cbExpandAllAuthors2" HelpText="All author groups are expanded." />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbExpandAllAuthors2" runat="server" Checked="false" />
								</td>
							</tr>
							<tr class="second">
								<td class="left">
									<dnn:Label ID="lblShowAuthorsArticleCount2" ResourceKey="lblShowAuthorsArticleCount2" runat="server" Text="Show count:" HelpText="Show article count by category." ControlName="ShowAuthorsArticleCount2" />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbShowAuthorsArticleCount2" runat="server" Checked="false" />
								</td>
							</tr>
							<tr>
								<td class="left">
									<dnn:Label ID="lblAuthorFilter" ResourceKey="lblAuthorFilter" runat="server" Text="All Authors:" HelpText="Filter by author." ControlName="cbDisplayAllAuthors2" />
								</td>
								<td>
									<asp:CheckBox ID="cbDisplayAllAuthors2" runat="server" AutoPostBack="True" Checked="True" OnCheckedChanged="cbDisplayAllAuthors_CheckedChanged" />
								</td>
							</tr>
							<tr class="second">
								<td class="left">&nbsp;
								</td>
								<td class="right">
									<asp:TreeView ID="tvAuthorAndGroupSelection2" runat="server" ForeColor="Black" ShowCheckBoxes="All" Visible="False" ImageSet="Contacts" NodeIndent="25">
										<HoverNodeStyle Font-Underline="False" />
										<NodeStyle Font-Names="Verdana" Font-Size="8pt" ForeColor="Black" HorizontalPadding="5px" NodeSpacing="0px" VerticalPadding="0px" />
										<ParentNodeStyle Font-Bold="True" ForeColor="#5555DD" />
										<SelectedNodeStyle Font-Underline="True" HorizontalPadding="0px" VerticalPadding="0px" />
									</asp:TreeView>
									<asp:CustomValidator ID="cvAuthorsTreeview2" resourcekey="cvAuthorsTreeview.ErrorMessage" runat="server" ForeColor="Red" ClientValidationFunction="ClientValidateAuthors" Display="Dynamic" Enabled="False" ErrorMessage="Please select at least one author."
										ValidationGroup="vgCatMenuSettings2" />
								</td>
							</tr>
						</table>
					</ContentTemplate>
				</asp:UpdatePanel>
				<asp:UpdateProgress ID="uppAuthorsFilter2" runat="server" AssociatedUpdatePanelID="upAuthorsFilter2" DisplayAfter="100" DynamicLayout="true">
					<ProgressTemplate>
						<img src="<%=ModulePath.Replace("EasyDNNnewsWidgets/Controls/FilterMenu/Settings", "EasyDNNnews")%>images/settings/ajaxLoading.gif" />
					</ProgressTemplate>
				</asp:UpdateProgress>
				<table class="settings_table" cellpadding="0" cellspacing="0">
					<%--					<tr class="second">
						<td class="left">
							<dnn:Label ID="lblFilterSelectionType2" runat="server" Text="Filter selection type:" HelpText="Choose type of selection." />
						</td>
						<td class="right">
							<asp:RadioButtonList ID="rblFilterSelectionType2" runat="server">
								<asp:ListItem Text="CheckBoxList" Value="0" Selected="True" />
								<asp:ListItem Text="DropDownList" Value="1" />
							</asp:RadioButtonList>
						</td>
					</tr>--%>
					<tr>
						<td class="left">
							<dnn:Label ID="lblPostBackType2" ResourceKey="lblPostBackType2" runat="server" Text="Do postback on:" ControlName="rblPostBackType2" HelpText="Choose type of filter menu post back." />
						</td>
						<td class="right">
							<asp:RadioButtonList ID="rblPostBackType2" runat="server">
								<asp:ListItem resourcekey="liPerSelection" Text="Per selection" Value="0" Selected="True" />
								<asp:ListItem resourcekey="liButtonClick" Text="Button click" Value="1" />
							</asp:RadioButtonList>
						</td>
					</tr>
				</table>
				<h3 class="subsections">
					<%=OrderBy%></h3>
				<asp:UpdatePanel ID="upOrderBySection2" runat="server">
					<ContentTemplate>
						<table class="settings_table" cellpadding="0" cellspacing="0">
							<tr class="second">
								<td class="left">
									<dnn:Label ID="lblOrderBySection2" ResourceKey="lblOrderBySection2" runat="server" Text="Display order by section:" ControlName="cbOrderBySection2" HelpText="Display order by section only if template contains walid token." />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbOrderBySection2" runat="server" Checked="True" AutoPostBack="true" OnCheckedChanged="cbOrderBySection2_CheckedChanged" />
								</td>
							</tr>
							<tr runat="server" id="rowOrderBySelection2">
								<td colspan="2">
									<asp:GridView ID="gvOrderBySelection2" runat="server" AutoGenerateColumns="False" CellPadding="0" GridLines="None" HorizontalAlign="Center">
										<AlternatingRowStyle CssClass="second" />
										<Columns>
											<asp:TemplateField>
												<ItemTemplate>
													<asp:Label ID="lblOrderByName2" runat="server" Text='<%# Eval("OrderByName") %>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField>
												<ItemTemplate>
													<asp:HiddenField ID="hfOrderByID2" runat="server" Value='<%# Eval("OrderByID") %>' />
													<asp:CheckBox ID="cbSelected2" runat="server" Checked='<%# Eval("Selected") %>' />
												</ItemTemplate>
											</asp:TemplateField>
										</Columns>
									</asp:GridView>
								</td>
							</tr>
						</table>
					</ContentTemplate>
				</asp:UpdatePanel>
				<asp:UpdateProgress ID="uupOrderBySection2" runat="server" AssociatedUpdatePanelID="upOrderBySection2" DisplayAfter="100" DynamicLayout="true">
					<ProgressTemplate>
						<img src="<%=ModulePath.Replace("EasyDNNnewsWidgets/Controls/FilterMenu/Settings", "EasyDNNnews")%>images/settings/ajaxLoading.gif" />
					</ProgressTemplate>
				</asp:UpdateProgress>
				<table class="settings_table" cellpadding="0" cellspacing="0">
					<tr>
						<td colspan="2" style="text-align: center; color: Red;">
							<asp:Label ID="lblCategoriesMenuInfo" runat="server" EnableViewState="False" />
						</td>
					</tr>
				</table>
			</div>
		</div>
		<div class="main_actions">
			<p>
				<asp:Label ID="lblMainMessage" runat="server" EnableViewState="false" />
				<asp:CustomValidator ID="cvCategoriesTreeview2" resourcekey="cvCategoriesTreeview.ErrorMessage" runat="server" ForeColor="Red" ClientValidationFunction="CategoryClientValidate" Display="Dynamic" Enabled="False" ErrorMessage="Please select at least one category."
					ValidationGroup="vgCatMenuSettings2" />
			</p>
			<div class="buttons">
				<asp:Button ID="btnSaveSettings" resourcekey="btnSaveSettings" runat="server" OnClick="btnSaveSettings_Click" Text="Save" ValidationGroup="vgCatMenuSettings2" />
				<asp:Button ID="btnSaveClose" resourcekey="btnSaveClose" runat="server" OnClick="btnSaveClose_Click" Text="Save &amp; Close" ValidationGroup="vgCatMenuSettings2" />
				<asp:Button ID="btnCancel" resourcekey="btnCancel" runat="server" OnClick="btnCancel_Click" Text="Close" />
			</div>
			<br />
			<br />
		</div>
	</div>
</div>
