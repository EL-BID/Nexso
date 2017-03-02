<%@ control language="C#" autoeventwireup="true" inherits="EasyDNNSolutions.Modules.EasyDNNNews.TagEditor, App_Web_tageditor.ascx.d988a5ac" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<script type="text/javascript">
	function ConfirmDelete() {
		return confirm('<%=Localization.GetString("Areyousure.Text", this.LocalResourceFile)%>');
	}
</script>
<asp:Panel ID="pnlMain" runat="server" resourcekey="pnlMainResource1">
	<div id="EDNadmin">
		<div class="module_action_title_box">
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
			<h1>
				<%=TagEditorTitle%></h1>
		</div>
		<asp:Panel ID="pnlTagsGridView" runat="server" Visible="true">
			<div class="main_content token_editor">
				<div class="tabbed_container">
					<div class="main_content gridview_content_manager tag_editor">
						<asp:GridView ID="gvTags" runat="server" EnableModelValidation="True" AutoGenerateColumns="False" CellPadding="0" DataSourceID="odsTags" GridLines="None" CssClass="grid_view_table" DataKeyNames="TagID" OnRowCommand="gvTags_RowCommand"
							AllowPaging="True" OnPageIndexChanging="gvTags_PageIndexChanging" resourcekey="gvTagsResource1">
							<AlternatingRowStyle CssClass="row second" />
							<Columns>
								<asp:TemplateField ShowHeader="False">
									<EditItemTemplate>
										<asp:LinkButton ID="LinkButton1" runat="server" CommandName="Update" resourcekey="LinkButton1Resource2" Text="Update" />
										&nbsp;<asp:LinkButton ID="LinkButton2" runat="server" CausesValidation="False" CommandName="Cancel" resourcekey="LinkButton2Resource2" Text="Cancel" />
									</EditItemTemplate>
									<ItemTemplate>
										<asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="False" CommandName="Edit" resourcekey="LinkButton1Resource1" Text="Edit" />
										&nbsp;<asp:LinkButton ID="LinkButton2" runat="server" CausesValidation="False" CommandName="Delete" resourcekey="LinkButton2Resource1" Text="Delete" OnClientClick="return ConfirmDelete();" />
										&nbsp;<asp:LinkButton ID="lbLocalizeimage" runat="server" CommandArgument='<%# Eval("TagID") %>' resourcekey="lbLocalizeimage" CssClass="image_localization" CommandName="Localize" Visible='<%#EnableLocalization%>' Text="Localize" />
									</ItemTemplate>
									<FooterStyle CssClass="footer_actions" />
								</asp:TemplateField>
								<asp:TemplateField HeaderText="Tag" SortExpression="Name">
									<EditItemTemplate>
										<asp:TextBox ID="TextBox1" runat="server" Text='<%# Bind("Name") %>'></asp:TextBox>
									</EditItemTemplate>
									<ItemTemplate>
										<asp:Label ID="Label1" runat="server" Text='<%# Bind("Name") %>'></asp:Label>
									</ItemTemplate>
								</asp:TemplateField>
								<asp:TemplateField HeaderText="Number of articles" SortExpression="CountNumber">
									<ItemTemplate>
										<asp:Label ID="lblCountNumber" runat="server" Text='<%# Bind("CountNumber") %>'></asp:Label>
									</ItemTemplate>
								</asp:TemplateField>
								<asp:TemplateField HeaderText="Localized">
									<ItemTemplate>
										<asp:Label ID="lblLocalizedList" runat="server" Text='<%# Bind("Localized") %>'></asp:Label>
									</ItemTemplate>
								</asp:TemplateField>
							</Columns>
							<EditRowStyle BackColor="#E2EDF4" />
							<HeaderStyle CssClass="header_row" />
							<PagerStyle CssClass="pagination" />
							<RowStyle CssClass="row" />
						</asp:GridView>
						<div class="nomber_of_rows_selection" style="margin-top: 5px; margin-bottom: 5px; float: right;">
							<asp:Label ID="lblFooterSelectNumberOfRows" runat="server" AssociatedControlID="ddlFooterNumberOfRows" resourcekey="lblFooterSelectNumberOfRowsResource1" Text="Number of rows:"></asp:Label>
							<asp:DropDownList ID="ddlFooterNumberOfRows" runat="server" AutoPostBack="True" resourcekey="ddlFooterNumberOfRowsResource1" OnSelectedIndexChanged="ddlFooterNumberOfRows_SelectedIndexChanged">
								<asp:ListItem resourcekey="ListItemResource40" Value="10">10</asp:ListItem>
								<asp:ListItem resourcekey="ListItemResource41" Value="20">20</asp:ListItem>
								<asp:ListItem resourcekey="ListItemResource42" Value="30">30</asp:ListItem>
								<asp:ListItem resourcekey="ListItemResource43" Value="50">50</asp:ListItem>
								<asp:ListItem resourcekey="ListItemResource44" Value="100">100</asp:ListItem>
							</asp:DropDownList>
						</div>
					</div>
				</div>
			</div>
		</asp:Panel>
		<asp:Panel ID="pnlTagLocalization" CssClass="main_content" runat="server" Visible="false">
			<asp:HiddenField ID="hfTagID" runat="server" />
			<table class="settings_table" cellpadding="0" cellspacing="0">
				<tr>
					<td class="left">
						<asp:Label ID="lblContentLocalizationMediaTitle" resourcekey="lblContentLocalizationMediaTitle" runat="server" Font-Bold="True" Text="Tag:" />
					</td>
					<td class="right">
						<asp:Label ID="lblContentLocalizationMediaTitleOriginal" runat="server" />
					</td>
				</tr>
				<tr>
					<td class="left">
						<asp:Label ID="lblPortalDefLanguage" runat="server" Text="Poratal default language:" resourcekey="lblPortalDefLanguageResource1" />
					</td>
					<td class="right">
						<asp:Label ID="lblDefaultPortalLangugageImage" runat="server" />
					</td>
				</tr>
				<tr>
					<td class="left">
						<asp:Label ID="lblContentLocalizationLocalizedLanguages" runat="server" Text="Localized languages:" resourcekey="lblContentLocalizationLocalizedLanguages" />
					</td>
					<td class="right">
						<asp:Label ID="lblContentLocalizationLocalizedLanguagesList" runat="server" />
					</td>
				</tr>
			</table>
			<div class="text_input_set">
				<dnn:Label ID="lblContentLocalizationSelectLanguage" runat="server" HelpKey="lblContentLocalizationSelectLanguage.HelpText" HelpText="Select the languange you want to edit. There is no need to edit dafault language." Text="Select language:" ResourceKey="lblContentLocalizationSelectLanguage" />
				<asp:DropDownList ID="ddlContentLocalizationSelectLanguage" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlContentLocalizationSelectLanguage_SelectedIndexChanged" />
				<asp:LinkButton ID="btnContentLocalizationCopyDefault" resourcekey="btnContentLocalizationCopyDefault" CssClass="silver_button" Style="float: right;" runat="server" OnClick="btnContentLocalizationCopyDefault_Click"><span>Copy default values</span></asp:LinkButton>
				<asp:LinkButton ID="btnDeleteLocalization" resourcekey="btnDeleteLocalization" CssClass="silver_button" Style="float: right;" runat="server" OnClick="btnDeleteLocalization_Click" OnClientClick="return ConfirmDelete();"><span>Delete selected tag locale</span></asp:LinkButton>
			</div>
			<div class="text_input_set overflow_visible">
				<dnn:Label ID="lblContentLocalizationTitle" ResourceKey="lblContentLocalizationTitle" runat="server" HelpText="Tag text." Text="Tag:" HelpKey="lblContentLocalizationTitle.HelpText" />
				<asp:TextBox ID="tbxLocalizedTag" runat="server" CssClass="text s18" />
			</div>
			<div class="text_input_set">
				<asp:LinkButton ID="btnContentLocalizationUpdate" resourcekey="btnContentLocalizationUpdate" CssClass="silver_button" runat="server" OnClick="btnContentLocalizationUpdate_Click"><span>Save/Update localization</span></asp:LinkButton>
				<asp:LinkButton ID="btnContentLocalizationClose" resourcekey="btnContentLocalizationClose" CssClass="silver_button" runat="server" OnClick="btnContentLocalizationClose_Click"><span>Close</span></asp:LinkButton>
			</div>
			<asp:Label ID="lblErrorInfoMsg" runat="server" EnableViewState="false" Visible="false" />
		</asp:Panel>
	</div>
</asp:Panel>
<asp:ObjectDataSource ID="odsTags" runat="server" SelectMethod="GetAllNewTags" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.DataAccess" UpdateMethod="UpdateNewTagName" DeleteMethod="DeleteNewTag" EnablePaging="True" SelectCountMethod="GetAllNewTagsTotalTags">
	<DeleteParameters>
		<asp:Parameter Name="TagID" Type="Int32" />
	</DeleteParameters>
	<SelectParameters>
		<asp:Parameter Name="PortalID" Type="Int32" />
		<asp:Parameter Name="maximumRows" Type="Int32" />
		<asp:Parameter Name="startRowIndex" Type="Int32" />
	</SelectParameters>
	<UpdateParameters>
		<asp:Parameter Name="TagID" Type="Int32" />
		<asp:Parameter Name="Name" Type="String" />
		<asp:Parameter Name="CountNumber" Type="Int32" />
		<asp:Parameter Name="Localized" Type="String" />
	</UpdateParameters>
</asp:ObjectDataSource>
