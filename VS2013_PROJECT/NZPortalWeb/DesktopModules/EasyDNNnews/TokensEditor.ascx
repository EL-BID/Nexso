<%@ control language="C#" autoeventwireup="true" inherits="EasyDNNSolutions.Modules.EasyDNNNews.TokensEditor, App_Web_tokenseditor.ascx.d988a5ac" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<%@ Register TagPrefix="dnn" TagName="TextEditor" Src="~/controls/TextEditor.ascx" %>
<div id="EDNadmin">
	<asp:HiddenField ID="hfArticleID" runat="server" />
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
			<%=TokenEditor%></h1>
	</div>
	<div class="main_content token_editor">
		<div class="tabbed_container">
			<div class="tabs">
				<asp:LinkButton ID="lbUserDefinedTokens" runat="server" OnClick="lbUserDefinedTokens_Click" CssClass="active" resourcekey="lbUserDefinedTokensResource1">User defined tokens</asp:LinkButton>
				<asp:LinkButton ID="lbSystemTokens" runat="server" OnClick="lbSystemTokens_Click" resourcekey="lbSystemTokensResource1">System tokens</asp:LinkButton>
			</div>
			<div class="content">
				<asp:GridView ID="gvTokens" runat="server" EnableModelValidation="True" AutoGenerateColumns="False" CellPadding="0" DataSourceID="odsTokens" OnPreRender="gvTokens_PreRender" GridLines="None" DataKeyNames="TokenID" CssClass="grid_view_table" ShowFooter="True"
					OnDataBound="gvTokens_DataBound" AllowPaging="False">
					<Columns>
						<asp:TemplateField ShowHeader="False" ItemStyle-CssClass="actions" HeaderStyle-CssClass="actions" FooterStyle-CssClass="footer_actions">
							<EditItemTemplate>
								<asp:LinkButton ID="lbTokenUpdateEdit" runat="server" CommandName="Update" CssClass="action_btn save" ToolTip="Save changes" resourcekey="lbTokenUpdateEditResource1" />
								<asp:LinkButton ID="lbTokenCancelEdit" runat="server" CausesValidation="False" CommandName="Cancel" CssClass="action_btn cancel" ToolTip="Discard changes" resourcekey="lbTokenCancelEditResource1" />
							</EditItemTemplate>
							<ItemTemplate>
								<asp:LinkButton ID="lbTokenEditGrid" runat="server" CausesValidation="False" CommandName="Edit" CssClass="action_btn edit" ToolTip="Edit this token" resourcekey="lbTokenEditGridResource1" />
								<asp:LinkButton ID="lbTokenDeleteGrid" runat="server" CausesValidation="False" OnClientClick="return confirm('Are you certain you want to delete this token?');" CommandName="Delete" CssClass="action_btn red_x" ToolTip="Delete this token" resourcekey="lbTokenDeleteGridResource1" />
							</ItemTemplate>
							<FooterTemplate>
								<div class="nomber_of_rows_selection">
									<asp:Label ID="lblNUmberOfTokensperPage" AssociatedControlID="ddlTokensPerPage" runat="server" Text="Number of tokens pre page:" resourcekey="lblNUmberOfTokensperPageResource1" />
									<asp:DropDownList ID="ddlTokensPerPage" runat="server" OnSelectedIndexChanged="dllTokensPerPage_SelectedIndexChanged" AutoPostBack="True" resourcekey="ddlTokensPerPageResource1">
										<asp:ListItem resourcekey="ListItemResource1">10</asp:ListItem>
										<asp:ListItem resourcekey="ListItemResource2">20</asp:ListItem>
										<asp:ListItem resourcekey="ListItemResource3">30</asp:ListItem>
										<asp:ListItem resourcekey="ListItemResource4">50</asp:ListItem>
										<asp:ListItem resourcekey="ListItemResource5">100</asp:ListItem>
									</asp:DropDownList>
								</div>
							</FooterTemplate>
							<FooterStyle CssClass="footer_actions"></FooterStyle>
							<HeaderStyle CssClass="actions"></HeaderStyle>
							<ItemStyle CssClass="actions"></ItemStyle>
						</asp:TemplateField>
						<asp:TemplateField HeaderText="Token" SortExpression="TokenTitle" ItemStyle-CssClass="token_info">
							<EditItemTemplate>
								<asp:TextBox ID="TextBox1" runat="server" Text='<%# Bind("TokenTitle") %>' />
								<dnn:TextEditor ID="txtTokenContentGrid" runat="server" Text='<%# Bind("TokenContent")%>' Height="250" Width="520" />
							</EditItemTemplate>
							<ItemTemplate>
								<p class="title">
									<%# Eval("TokenTitle") %></p>
								<p>
									<asp:TextBox ID="tbCustomToken" runat="server" CssClass="token" Text='<%# Eval("TokenTitle", "[EasyDNNnewsToken:{0}]") %>' ReadOnly="True" resourcekey="tbCustomTokenResource1" /></p>
								<p>
									<textarea name="txtTokenContentGridView" cols="4" rows="3" readonly="readonly"><%# Eval("TokenContent") %></textarea></p>
							</ItemTemplate>
							<ItemStyle CssClass="token_info"></ItemStyle>
						</asp:TemplateField>
					</Columns>
					<AlternatingRowStyle CssClass="second" />
					<HeaderStyle CssClass="header_row" />
				</asp:GridView>
				<asp:Label ID="lbluserTokens" runat="server" Text="There are no user tokes defined." Font-Bold="True" Font-Size="Medium" Visible="False" resourcekey="lbluserTokensResource1"></asp:Label>
				<asp:GridView ID="gvSystemTokens" runat="server" DataSourceID="odsSystemTokens" EnableModelValidation="True" AutoGenerateColumns="False" CellPadding="0" OnPreRender="gvSystemTokens_OnPreRender" DataKeyNames="EntryID" GridLines="None" CssClass="grid_view_table"
					ShowFooter="True" OnRowCommand="gvSystemTokens_RowCommand" Visible="False" resourcekey="gvSystemTokensResource1">
					<Columns>
						<asp:TemplateField ItemStyle-CssClass="actions" HeaderStyle-CssClass="actions" FooterStyle-CssClass="footer_actions">
							<ItemTemplate>
								<asp:LinkButton ID="lbAddAsNewToken" runat="server" CommandArgument='<%# Eval("EntryID") %>' CommandName="AddAsNewToken" resourcekey="lbAddAsNewTokenResource1">Add as new token and edit</asp:LinkButton>
							</ItemTemplate>
							<FooterStyle CssClass="footer_actions"></FooterStyle>
							<HeaderStyle CssClass="actions"></HeaderStyle>
							<ItemStyle CssClass="actions"></ItemStyle>
						</asp:TemplateField>
						<asp:TemplateField HeaderText="Token" SortExpression="TokenTitle" ItemStyle-CssClass="token_info">
							<ItemTemplate>
								<p class="title">
									<%# Eval("TokenTitle") %></p>
								<p>
									<%# Eval("Description") %></p>
								<p>
									<asp:TextBox ID="tbCustomToken" runat="server" CssClass="token" Text='<%# Eval("TokenTitle", "[EasyDNNnewsSystemToken:{0}]") %>' ReadOnly="True" resourcekey="tbCustomTokenResource2" /></p>
								<p>
									<textarea name="txtTokenContentGridView" cols="4" rows="3" readonly="readonly"><%# Eval("TokenContent") %></textarea></p>
							</ItemTemplate>
							<ItemStyle CssClass="token_info"></ItemStyle>
						</asp:TemplateField>
					</Columns>
					<PagerStyle CssClass="pagination" />
					<AlternatingRowStyle CssClass="second" />
					<HeaderStyle CssClass="header_row" />
				</asp:GridView>
			</div>
		</div>
		<asp:Panel ID="pnlAddToken" CssClass="section_box grey white_border_1" runat="server">
			<h1 class="section_box_title">
				<span>
					<%=Addnewtoken%></span></h1>
			<div class="content">
				<div class="padded_wrapper">
					<div class="text_input_set">
						<label for="<%=tbTokenTitle.ClientID %>">
							<%=Tokentitle%></label>
						<asp:TextBox ID="tbTokenTitle" CssClass="text" runat="server" MaxLength="100" ValidationGroup="vgTokenInsert" />
						<asp:RequiredFieldValidator ID="rfvTokenTitle" runat="server" ControlToValidate="tbTokenTitle" ErrorMessage="This field is required." ValidationGroup="vgTokenInsert" resourcekey="rfvTokenTitleResource1" />
					</div>
					<div class="text_input_set">
						<label for="<%=tbTokenTitle.ClientID %>">
							<%=Tokencontent %></label>
						<dnn:TextEditor ID="txtSummary" runat="server" Height="400" Width="710" />
					</div>
					<asp:Label ID="lblTokenExistError" runat="server" ForeColor="Red" Text="A token with this title already exist. Please enter a new title." Visible="False" resourcekey="lblTokenExistErrorResource1" />
					<asp:Label ID="lblTokenSaved" runat="server" Text="Token saved." Visible="False" resourcekey="lblTokenSavedResource1" />
					<div class="main_actions">
						<asp:LinkButton ID="lbSaveSettings" runat="server" OnClick="lbSaveSettings_Click" ValidationGroup="vgCreateCat" CssClass="submit_btn" resourcekey="lbSaveSettingsResource1"><span>Save token</span></asp:LinkButton>
					</div>
				</div>
			</div>
		</asp:Panel>
	</div>
</div>
<asp:ObjectDataSource ID="odsTokens" runat="server" SelectMethod="GetAllTokens" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.DataAccess" DeleteMethod="DeleteToken" UpdateMethod="UpdateToken">
	<DeleteParameters>
		<asp:Parameter Name="TokenID" Type="Int32" />
	</DeleteParameters>
	<SelectParameters>
		<asp:Parameter Name="PortalID" Type="Int32" />
	</SelectParameters>
	<UpdateParameters>
		<asp:Parameter Name="TokenID" Type="Int32" />
		<asp:Parameter Name="TokenTitle" Type="String" />
		<asp:Parameter Name="TokenContent" Type="String" />
	</UpdateParameters>
</asp:ObjectDataSource>
<asp:ObjectDataSource ID="odsSystemTokens" runat="server" SelectMethod="GetAllSystemTokens" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.DataAccess"></asp:ObjectDataSource>
