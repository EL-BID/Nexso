<%@ control language="C#" autoeventwireup="true" inherits="EasyDNNSolutions.Modules.EasyDNNNews.RSSImport, App_Web_rssimport.ascx.d988a5ac" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<style type="text/css">
	.style1 {
		width: 100%;
	}

	.style3 {
		width: 240px;
	}

	.style4 {
		width: 118px;
		height: 30px;
	}

	.style5 {
		height: 30px;
	}
</style>
<script type="text/javascript">
	function ConfirmDelete() {
		return confirm('<%=Localization.GetString("Areyousure.Text", this.LocalResourceFile)%>');
	}
</script>
<asp:Panel ID="pnlMainWrap" runat="server">
	<div id="EDNadmin">
		<div class="module_action_title_box">
			<asp:Panel ID="pnlTopNavigation" runat="server">
				<ul class="module_navigation_menu">
					<li>
						<asp:LinkButton ID="lbModuleNavigationAddArticle" runat="server" ToolTip="Add article" OnClick="lbModuleNavigationAddArticle_Click" resourcekey="lbModuleNavigationAddArticleResource1"><img src="<%=ModulePath %>images/icons/paper_and_pencil.png" alt="" /></asp:LinkButton></li>
					<li>
						<asp:LinkButton ID="lbModuleNavigationArticleEditor" runat="server" ToolTip="Article editor" OnClick="lbModuleNavigationArticleEditor_Click" resourcekey="lbModuleNavigationArticleEditorResource1"><img src="<%=ModulePath %>images/icons/papers_and_pencil.png" alt="" /></asp:LinkButton></li>
					<li>
						<asp:LinkButton ID="lbModuleNavigationCategoryEditor" runat="server" ToolTip="Category editor" OnClick="lbModuleNavigationCategoryEditor_Click" resourcekey="lbModuleNavigationCategoryEditorResource1"><img src="<%=ModulePath %>images/icons/categories.png" alt="" /></asp:LinkButton></li>
					<li>
						<asp:LinkButton ID="lbModuleNavigationApproveComments" runat="server" ToolTip="Approve comments" OnClick="lbModuleNavigationApproveComments_Click" resourcekey="lbModuleNavigationApproveCommentsResource1"><img src="<%=ModulePath %>images/icons/conversation.png" alt="" /></asp:LinkButton></li>
					<li>
						<asp:LinkButton ID="lbModuleNavigationDashboard" runat="server" ToolTip="Dashboard" OnClick="lbModuleNavigationDashboard_Click" resourcekey="lbModuleNavigationDashboardResource1"><img src="<%=ModulePath %>images/icons/lcd.png" alt="" /></asp:LinkButton></li>
					<li class="power_off">
						<asp:LinkButton ID="lbPowerOff" runat="server" ToolTip="Close" OnClick="lbPowerOff_Click" resourcekey="lbPowerOffResource1"><img src="<%=ModulePath %>images/icons/power_off.png" alt="" /></asp:LinkButton></li>
				</ul>
			</asp:Panel>
			<h1>
				<%=strRSSImport%></h1>
		</div>
		<div class="main_content token_editor">
			<div class="tabbed_container">
				<asp:Panel ID="pnlAuthorProfiles" runat="server">
					<div class="content">
						<asp:Panel ID="pnlProfileEditorHeader" runat="server">
							<div class="main_content gridview_content_manager tag_editor" style="padding: 0;">
								<div class="content_wrapper">
									<asp:GridView ID="gvFeeds" runat="server" AllowPaging="True" AllowSorting="True" AutoGenerateColumns="False" CellPadding="0" DataSourceID="odsFeeds" EnableModelValidation="True" GridLines="None" OnPreRender="gvTokens_PreRender" ShowFooter="True" DataKeyNames="RSSID"
										OnRowCommand="gvFeeds_RowCommand" CssClass="grid_view_table">
										<AlternatingRowStyle CssClass="second row" />
										<Columns>
											<asp:TemplateField ShowHeader="False">
												<ItemTemplate>
													<asp:LinkButton ID="LinkButton2" runat="server" CausesValidation="False" CommandArgument='<%# Eval("RSSID") %>' CommandName="EditRSS" CssClass="action_set pair edit" resourcekey="LinkButton2Resource1" ToolTip="<%#EditText%>"></asp:LinkButton>
													<asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="False" CommandName="Delete" CssClass="action_set pair delete" resourcekey="LinkButton1Resource1" OnClientClick="return ConfirmDelete();" ToolTip="<%#Delete%>"></asp:LinkButton>
													<asp:LinkButton ID="lbDeleteAllArticlesByFees" runat="server" CausesValidation="False" CommandArgument='<%# Eval("RSSID") %>' CommandName="DeleteArticlesByFeed" resourcekey="lbDeleteAllArticlesByFeesResource1" OnClientClick="return ConfirmDelete();" Style="clear: both; margin-top: 0; padding: 0; font-size: 10px; display: block;"
														Text="Delete all articles added by this feed"></asp:LinkButton>
												</ItemTemplate>
												<HeaderStyle Width="100px" />
											</asp:TemplateField>
											<asp:BoundField DataField="RSSID" HeaderText="ID">
												<ControlStyle Width="40px" />
												<HeaderStyle Width="40px" />
												<ItemStyle Width="40px" />
											</asp:BoundField>
											<asp:BoundField DataField="RSSURL" HeaderText="RSS URL">
												<ControlStyle Width="190px" />
												<HeaderStyle Width="190px" />
												<ItemStyle Width="190px" />
											</asp:BoundField>
											<asp:TemplateField HeaderText="Author">
												<EditItemTemplate>
													<asp:TextBox ID="TextBox1" runat="server" Text='<%# Bind("UserID") %>'></asp:TextBox>
												</EditItemTemplate>
												<ItemTemplate>
													<asp:Label ID="lblAuthor" runat="server" resourcekey="lblAuthorResource1" Text='<%# GetUserNameDisplay(Eval("UserID")) %>'></asp:Label>
												</ItemTemplate>
												<ControlStyle Width="70px" />
												<HeaderStyle Width="70px" />
												<ItemStyle Width="70px" />
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Category">
												<EditItemTemplate>
													<asp:TextBox ID="TextBox2" runat="server" Text='<%# Bind("CategoryID") %>'></asp:TextBox>
												</EditItemTemplate>
												<ItemTemplate>
													<asp:Label ID="lblCategoryName" runat="server" Text='<%# Bind("CategoryName") %>' />
												</ItemTemplate>
												<ControlStyle Width="100px" />
												<HeaderStyle Width="100px" />
												<ItemStyle Width="100px" />
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Download Images">
												<EditItemTemplate>
													<asp:TextBox ID="TextBox3" runat="server" Text='<%# Bind("DownloadImages") %>'></asp:TextBox>
												</EditItemTemplate>
												<ItemTemplate>
													<asp:CheckBox ID="cbDownloadImages" runat="server" Checked='<%# Bind("DownloadImages") %>' Enabled="False" resourcekey="cbDownloadImagesResource1" />
												</ItemTemplate>
												<ControlStyle Width="60px" />
												<HeaderStyle Width="60px" />
												<ItemStyle HorizontalAlign="Center" Width="60px" />
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Active">
												<EditItemTemplate>
													<asp:TextBox ID="TextBox3" runat="server" Text='<%# Bind("Active") %>'></asp:TextBox>
												</EditItemTemplate>
												<ItemTemplate>
													<asp:CheckBox ID="cbActive" runat="server" Checked='<%# Bind("Active") %>' Enabled="False" resourcekey="cbActiveResource1" />
												</ItemTemplate>
												<ControlStyle Width="45px" />
												<HeaderStyle Width="45px" />
												<ItemStyle Width="45px" />
											</asp:TemplateField>
										</Columns>
										<HeaderStyle CssClass="header_row" />
										<RowStyle CssClass="row" />
									</asp:GridView>
								</div>
							</div>
						</asp:Panel>
						<asp:Panel ID="pnlSchedulerIfo" runat="server" Style="text-align: center; color: #199F18; margin: 10px 0 0;">
							<asp:Label ID="lblSchedulerInfo" runat="server" resourcekey="lblSchedulerInfoResource1"></asp:Label>
						</asp:Panel>
						<asp:Panel ID="pnlAddToken" CssClass="section_box grey white_border_1" runat="server">
							<h1 class="section_box_title">
								<asp:Label ID="lblAddEditRSS" runat="server" Text="Import RSS" resourcekey="lblAddEditRSSResource1"></asp:Label>
							</h1>
							<div class="content">
								<div class="padded_wrapper">
									<div class="text_input_set">
										<table class="style1">
											<tr>
												<td class="style3">
													<dnn:Label ID="lblFeedURL" runat="server" Text="Feed URL:" HelpText="Enter the full URL to the RSS or Atom feed:" HelpKey="lblFeedURL.HelpText" ResourceKey="lblFeedURL"></dnn:Label>
												</td>
												<td>
													<asp:TextBox ID="tbFeedURL" runat="server" Width="350px" CssClass="text" ValidationGroup="vgRSSImport"></asp:TextBox>
													<asp:RequiredFieldValidator ID="rfvFeedURL" runat="server" ControlToValidate="tbFeedURL" ErrorMessage="Please enter feed URL." ValidationGroup="vgRSSImport" Display="Dynamic" resourcekey="rfvFeedURLResource1.ErrorMessage"></asp:RequiredFieldValidator>
													<asp:RegularExpressionValidator ID="revFeedURL" runat="server" ControlToValidate="tbFeedURL" Display="Dynamic" ErrorMessage="Please enter valid URL." ValidationExpression="http(s)?://([\w-])+[\w-]+(/[\w- ./?%&amp;=]*)?" ValidationGroup="vgRSSImport"
														resourcekey="revFeedURLResource1.ErrorMessage" Enabled="False"></asp:RegularExpressionValidator>
												</td>
											</tr>
											<tr>
												<td class="style4">
													<dnn:Label ID="lblSelectFeedAuthor" runat="server" Text="Feed author:" HelpText="Select the user which will be added as author of imported feed articles:" HelpKey="lblSelectFeedAuthor.HelpText" ResourceKey="lblSelectFeedAuthor"></dnn:Label>
												</td>
												<td class="style5">
													<asp:DropDownList ID="ddlRoles" runat="server" AppendDataBoundItems="True" AutoPostBack="True" CssClass="ddlgeneral" OnSelectedIndexChanged="ddlRoles_SelectedIndexChanged">
														<asp:ListItem Value="-1" resourcekey="ListItemResource1">Select role</asp:ListItem>
													</asp:DropDownList>
													<asp:DropDownList ID="ddlAuthors" runat="server" AppendDataBoundItems="True" CssClass="ddlgeneral">
														<asp:ListItem Value="0" resourcekey="ListItemResource2">Select author</asp:ListItem>
													</asp:DropDownList>
													<asp:CompareValidator ID="CompareValidator1" runat="server" ControlToValidate="ddlAuthors" Display="Dynamic" ErrorMessage="Please select Author" Operator="NotEqual" ValidationGroup="vgRSSImport" ValueToCompare="0" resourcekey="CompareValidator1Resource1.ErrorMessage"></asp:CompareValidator>
												</td>
											</tr>
											<tr>
												<td class="style3">
													<dnn:Label ID="lblSelectFeedCategory" runat="server" Text="Category to import feed to:" HelpText="Select the category in which the feed will be imported:" HelpKey="lblSelectFeedCategory.HelpText" ResourceKey="lblSelectFeedCategory"></dnn:Label>
												</td>
												<td>
													<asp:DropDownList ID="ddlFeedCategorySelect" runat="server">
														<asp:ListItem Value="0" resourcekey="ListItemResource3">Select category</asp:ListItem>
													</asp:DropDownList>
													<asp:CompareValidator ID="CompareValidator2" runat="server" ControlToValidate="ddlFeedCategorySelect" Display="Dynamic" ErrorMessage="Please select category" Operator="NotEqual" ValidationGroup="vgRSSImport" ValueToCompare="0" resourcekey="CompareValidator2Resource1.ErrorMessage"></asp:CompareValidator>
												</td>
											</tr>
											<tr>
												<td class="style3">
													<dnn:Label ID="lblDownloadImages" runat="server" Text="Download images and use them as article image:" HelpKey="lblDownloadImages.HelpText" ResourceKey="lblDownloadImages"></dnn:Label>
												</td>
												<td>
													<asp:CheckBox ID="cbDownloadImages" runat="server" Checked="True" />
												</td>
											</tr>
											<tr>
												<td class="style3">
													<dnn:Label ID="lblLimitNumberofArticles" runat="server" Text="Limit number of articles:" HelpText="Enter the limit of articles number to be stored for this feed. If number of articles from the feed is greater than entered number older articles will be deleted. Enter 0 to store all articles."
														HelpKey="lblLimitNumberofArticles.HelpText" ResourceKey="lblLimitNumberofArticles"></dnn:Label>
												</td>
												<td>
													<asp:TextBox ID="tbLimitNumberOfArticles" runat="server" CssClass="text" Width="50px" resourcekey="tbLimitNumberOfArticlesResource1">0</asp:TextBox>
													<asp:RequiredFieldValidator ID="rfvLimitContent" runat="server" ControlToValidate="tbLimitNumberOfArticles" Display="Dynamic" ErrorMessage="Please enter article limit number." ValidationGroup="vgRSSImport" resourcekey="rfvLimitContentResource1.ErrorMessage"></asp:RequiredFieldValidator>
													<asp:CompareValidator ID="cvLimitNumberOfArticles" runat="server" ControlToValidate="tbLimitNumberOfArticles" Display="Dynamic" ErrorMessage="Please enter number. " Operator="DataTypeCheck" SetFocusOnError="True" Type="Integer" ValidationGroup="vgRSSImport"
														resourcekey="cvLimitNumberOfArticlesResource1.ErrorMessage"></asp:CompareValidator>
												</td>
											</tr>
											<tr>
												<td class="style3">
													<dnn:Label ID="lblLimitSummaryCharImport" runat="server" Text="Limit number of characters imported into summary:" HelpText="Limit number of characters imported into summary. Enter 0 for no limit."></dnn:Label>
												</td>
												<td>
													<asp:TextBox ID="tbLimitImportIntoSummary" runat="server" CssClass="text" Width="50px">0</asp:TextBox>
													<asp:RequiredFieldValidator ID="rfvLimitContent0" runat="server" ControlToValidate="tbLimitImportIntoSummary" Display="Dynamic" ErrorMessage="Please enter article limit number." resourcekey="rfvLimitContentResource1.ErrorMessage" ValidationGroup="vgRSSImport"></asp:RequiredFieldValidator>
													<asp:CompareValidator ID="cvLimitNumberOfArticles0" runat="server" ControlToValidate="tbLimitImportIntoSummary" Display="Dynamic" ErrorMessage="Please enter number. " Operator="DataTypeCheck" resourcekey="cvLimitNumberOfArticlesResource1.ErrorMessage"
														SetFocusOnError="True" Type="Integer" ValidationGroup="vgRSSImport"></asp:CompareValidator>
												</td>
											</tr>
											<tr>
												<td class="style3">
													<dnn:Label ID="lblFeedActive" runat="server" Text="Active:" HelpText="Active:" HelpKey="lblFeedActive.HelpText" ResourceKey="lblFeedActive"></dnn:Label>
												</td>
												<td>
													<asp:CheckBox ID="cbFeedActive" runat="server" Checked="True" />
												</td>
											</tr>
											<tr>
												<td class="style3">
													<dnn:Label ID="lblFeedType" runat="server" HelpText="Feed type:" Text="Feed type:" HelpKey="lblFeedType.HelpText" ResourceKey="lblFeedType" />
												</td>
												<td>
													<asp:DropDownList ID="ddlFeedType" runat="server">
														<asp:ListItem resourcekey="liStandard" Value="Standard">Standard</asp:ListItem>
														<asp:ListItem resourcekey="liYouTube" Value="YouTube">YouTube feed</asp:ListItem>
														<asp:ListItem resourcekey="liVimeo" Value="Vimeo">Vimeo feed</asp:ListItem>
														<asp:ListItem resourcekey="liiCalendar" Value="iCalendar">iCalendar Import</asp:ListItem>
													</asp:DropDownList>
												</td>
											</tr>
											<tr>
												<td class="style3">&nbsp;
												</td>
												<td>
													<asp:Label ID="lblMessage" runat="server" resourcekey="lblMessageResource1"></asp:Label>
												</td>
											</tr>
											<tr>
												<td class="style3">&nbsp;
												</td>
												<td>
													<asp:Button ID="btnSaveFeedSettings" runat="server" OnClick="btnSaveFeedSettings_Click" Text="Add RSS import" ValidationGroup="vgRSSImport" resourcekey="btnSaveFeedSettingsResource1" />
													<asp:Button ID="btnUpdateFeed" runat="server" OnClick="btnUpdateFeed_Click" Text="Update RSS import" ValidationGroup="vgRSSImport" Visible="False" resourcekey="btnUpdateFeedResource1" />
													<asp:Button ID="btnCancelEditing" runat="server" OnClick="btnCancelEditing_Click" Text="Cancel" resourcekey="btnCancelEditingResource1" />
												</td>
											</tr>
										</table>
									</div>
								</div>
							</div>
						</asp:Panel>
					</div>
				</asp:Panel>
			</div>
		</div>
	</div>
	<asp:ObjectDataSource ID="odsFeeds" runat="server" SelectMethod="GetAllRSSFeedsInPortal" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.DataAccess" DeleteMethod="DeleteRSSFeed">
		<DeleteParameters>
			<asp:Parameter Name="RSSID" Type="Int32" />
		</DeleteParameters>
		<SelectParameters>
			<asp:Parameter Name="PortalID" Type="Int32" />
		</SelectParameters>
	</asp:ObjectDataSource>
	<asp:HiddenField ID="hfRSSFeedID" runat="server" />
</asp:Panel>
