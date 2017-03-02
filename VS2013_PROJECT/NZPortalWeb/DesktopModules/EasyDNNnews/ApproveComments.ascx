<%@ control language="C#" inherits="EasyDNNSolutions.Modules.EasyDNNNews.ApproveComments, App_Web_approvecomments.ascx.d988a5ac" autoeventwireup="true" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<script type="text/javascript">
	function ShowValue() {
		var dropdownList;
		eds1_8("#<%=gvComments.ClientID %> select[id*='ddlFotterActionForSelected']").each(function (index) {
			dropdownList = eds1_8(this);
		});
		if (dropdownList.val() == '-1') {
			alert('<%=Localization.GetString("selectAction.Text", this.LocalResourceFile)%>');
		}
		else {
			return confirm('<%=Localization.GetString("Areyousure.Text", this.LocalResourceFile)%>');
		}
	}
</script>
<asp:Label ID="lblApproveMessage" runat="server" Text="You are not allowed to approve comments." Visible="False" resourcekey="lblApproveMessageResource1"></asp:Label>
<asp:Panel ID="pnlMainWrapper" runat="server">
	<div id="EDNadmin">
		<div class="module_action_title_box">
			<asp:PlaceHolder ID="phAdminNavigation" runat="server"></asp:PlaceHolder>
			<h1>
				<%=ApproveCommentsTitle%></h1>
		</div>
		<div class="main_content gridview_content_manager approve_comments">
			<div class="content_wrapper">
				<div class="content_filter_toggle">
					<asp:HyperLink ID="hlCommentFilterToggle" CssClass="filter_toggle" href="#" runat="server" Text="Show filter settings" resourcekey="hlCommentFilterToggleResource1" />
				</div>
				<asp:Panel ID="pnlCommentFilterSettings" runat="server" CssClass="content_filter_settings">
					<div class="filter_list">
						<div class="enbl_box">
							<%=Filterby%>
						</div>
						<asp:Panel ID="pnlCategoryFilter" runat="server" CssClass="dis_box">
							<asp:CheckBox ID="cbFilterByCategory" runat="server" Text="Category" CssClass="checkbox" OnCheckedChanged="cbFilterByCategory_CheckedChanged" AutoPostBack="True" resourcekey="cbFilterByCategoryResource1" />
							<asp:DropDownList ID="ddlCategorySelect" runat="server" AppendDataBoundItems="True" DataTextField="CategoryName" DataValueField="CategoryID" Enabled="False" OnSelectedIndexChanged="ddlCategorySelect_SelectedIndexChanged" AutoPostBack="True">
								<asp:ListItem Value="-1" resourcekey="ListItemResource3">Select category</asp:ListItem>
							</asp:DropDownList>
						</asp:Panel>
					</div>
					<asp:HiddenField ID="hfFilterSettingsState" runat="server" Value="closed" />
				</asp:Panel>
				<asp:GridView ID="gvComments" runat="server" AllowPaging="True" AllowSorting="True" AutoGenerateColumns="False" DataKeyNames="CommentID" DataSourceID="odsGetComments" EnableModelValidation="True" GridLines="Horizontal" OnRowCommand="gvComments_RowCommand"
					OnRowDeleting="gvComments_RowDeleting" CssClass="grid_view_table" ShowFooter="True" OnPreRender="gvComments_PreRender">
					<AlternatingRowStyle CssClass="row second" />
					<Columns>
						<asp:TemplateField>
							<FooterTemplate>
								<div class="arrow_icon">
								</div>
								<asp:LinkButton ID="ibFooterSelectAll" runat="server" CommandName="SelectAll" CssClass="silver_button" resourcekey="ibFooterSelectAllResource1"><span>Select all</span></asp:LinkButton>
								<asp:LinkButton ID="ibFooterUnSelectAll" runat="server" CommandName="UnselectAll" CssClass="silver_button" resourcekey="ibFooterUnSelectAllResource1"><span>Unselect all</span></asp:LinkButton>
								<div class="seperator">
								</div>
								<asp:DropDownList ID="ddlFotterActionForSelected" runat="server">
									<asp:ListItem resourcekey="liSelectAction" Value="-1">Select action</asp:ListItem>
									<asp:ListItem Value="Delete" resourcekey="ListItemResource4">Delete</asp:ListItem>
								</asp:DropDownList>
								<asp:Button ID="ibFooterOK" runat="server" CssClass="run_action" resourcekey="ibFooterOKResource1" OnClick="ibFooterOK_Click" OnClientClick="return ShowValue();" />
								<div class="nomber_of_rows_selection">
									<asp:Label ID="lblFooterSelectNumberOfRows" runat="server" AssociatedControlID="ddlFooterNumberOfRows" resourcekey="lblFooterSelectNumberOfRowsResource1" Text="Number of rows:"></asp:Label>
									<asp:DropDownList ID="ddlFooterNumberOfRows" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlFooterNumberOfRows_SelectedIndexChanged">
										<asp:ListItem Value="10" resourcekey="ListItemResource5">10</asp:ListItem>
										<asp:ListItem Value="20" resourcekey="ListItemResource6">20</asp:ListItem>
										<asp:ListItem Value="30" resourcekey="ListItemResource7">30</asp:ListItem>
										<asp:ListItem Value="50" resourcekey="ListItemResource8">50</asp:ListItem>
										<asp:ListItem Value="100" resourcekey="ListItemResource9">100</asp:ListItem>
									</asp:DropDownList>
								</div>
							</FooterTemplate>
							<ItemTemplate>
								<asp:CheckBox ID="cbSelectRow" runat="server" />
							</ItemTemplate>
							<FooterStyle CssClass="footer_actions" />
							<HeaderStyle CssClass="check_content" />
							<ItemStyle CssClass="check_content" />
						</asp:TemplateField>
						<asp:TemplateField ShowHeader="False">
							<EditItemTemplate>
								<asp:LinkButton ID="LinkButton1" runat="server" CommandName="Update" CssClass="action_set pair save" resourcekey="LinkButton1Resource2" ToolTip="Save changes"></asp:LinkButton>
								<asp:LinkButton ID="LinkButton2" runat="server" CausesValidation="False" CommandName="Cancel" CssClass="action_set pair cancel" resourcekey="LinkButton2Resource2" ToolTip="Cancel update"></asp:LinkButton>
							</EditItemTemplate>
							<ItemTemplate>
								<div class="clear_floated">
									<asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="False" CommandName="Edit" CssClass="action_set pair edit" resourcekey="LinkButton1Resource1" ToolTip="<%#Editcomment%>"></asp:LinkButton>
									<asp:LinkButton ID="LinkButton2" runat="server" CausesValidation="False" CommandName="Delete" CssClass="action_set pair delete" resourcekey="LinkButton2Resource1" OnClientClick="return confirm('Do you realy want to delete this comment?');" ToolTip="<%#Deletecomment%>"></asp:LinkButton>
								</div>
								<asp:LinkButton ID="lbApprove" runat="server" CommandArgument='<%# Eval("CommentID") %>' CommandName="Approve" CssClass="checkbox_action" resourcekey="lbApproveResource1" ToolTip="Approve" Visible='<%#!Convert.ToBoolean(Eval("Approved")) %>'><span 
									class="icon unchecked">Approved</span></asp:LinkButton>
								<asp:LinkButton ID="lbDisApprove" runat="server" CommandArgument='<%# Eval("CommentID") %>' CommandName="DisApprove" CssClass="checkbox_action" resourcekey="lbDisApproveResource1" ToolTip="DisApprove" Visible='<%# Convert.ToBoolean(Eval("Approved")) %>'><span 
									class="icon checked">Approved</span></asp:LinkButton>
							</ItemTemplate>
							<HeaderStyle CssClass="actions" />
						</asp:TemplateField>
						<asp:TemplateField HeaderText="Author">
							<ItemTemplate>
								<asp:Label ID="lblAuthor" runat="server" Text='<%# String.Format("<a href=\"mailto:{0}\" >{1}</a>",Eval("CommentersEmail"),Eval("CommentersName"))%>'></asp:Label>
							</ItemTemplate>
							<HeaderStyle CssClass="author" />
						</asp:TemplateField>
						<asp:TemplateField HeaderText="Comment">
							<EditItemTemplate>
								<asp:TextBox ID="TextBox1" runat="server" MaxLength="10000" Text='<%# Bind("Comment") %>' TextMode="MultiLine"></asp:TextBox>
							</EditItemTemplate>
							<ItemTemplate>
								<asp:Label ID="Label1" runat="server" Text='<%# Bind("Comment") %>'></asp:Label>
							</ItemTemplate>
							<HeaderStyle CssClass="comment" />
							<ItemStyle CssClass="comment" />
						</asp:TemplateField>
						<asp:TemplateField HeaderText="Stats" SortExpression="DateAdded">
							<ItemTemplate>
								<p>
									<strong>
										<%=Created%></strong>
									<%# GetCommentDate(Eval("DateAdded"))%>
								</p>
								<p>
									<strong>
										<%=Upvotes%></strong>
									<%# Eval("GoodVotes") %>
								</p>
								<p>
									<strong>
										<%=Downvotes%></strong>
									<%# Eval("BadVotes") %>
								</p>
							</ItemTemplate>
							<HeaderStyle CssClass="stats" />
						</asp:TemplateField>
						<asp:TemplateField HeaderText="Article title">
							<ItemTemplate>
								<asp:HyperLink ID="hlViewArticle" runat="server" NavigateUrl='<%#GetAricleUrl(Eval("Articleid"), Eval("Title"), Eval("TitleLink"), Eval("DetailType"), Eval("DetailTypeData"))%>' Target="_blank"><%# Eval("Title") %></asp:HyperLink>
							</ItemTemplate>
							<HeaderStyle CssClass="article_title" />
						</asp:TemplateField>
					</Columns>
					<HeaderStyle CssClass="header_row" />
					<PagerStyle CssClass="pagination" />
					<RowStyle CssClass="row" />
				</asp:GridView>
				<asp:Panel ID="pnlNoCommentsMatched" runat="server" class="no_content_matched_filter" Visible="False">
					<%=Therearentany%>
				</asp:Panel>
			</div>
		</div>
	</div>
</asp:Panel>
<asp:ObjectDataSource ID="odsGetComments" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.DataAccess" runat="server" SelectMethod="GetAllComments" DeleteMethod="DeleteComment" UpdateMethod="UpdateComment" EnablePaging="True" SelectCountMethod="SelectTotalNumberOfComments">
	<DeleteParameters>
		<asp:Parameter Name="CommentID" Type="Int32" />
	</DeleteParameters>
	<UpdateParameters>
		<asp:Parameter Name="CommentID" Type="Int32" />
		<asp:Parameter Name="Comment" Type="String" />
	</UpdateParameters>
	<SelectParameters>
		<asp:Parameter Name="PortalID" Type="Int32" />
		<asp:Parameter Name="maximumRows" Type="Int32" DefaultValue="1" />
		<asp:Parameter Name="startRowIndex" Type="Int32" DefaultValue="10" />
	</SelectParameters>
</asp:ObjectDataSource>
<asp:ObjectDataSource ID="odsGetCommentsByCategoryID" runat="server" DeleteMethod="DeleteComment" EnablePaging="True" SelectCountMethod="SelectTotalNumberOfCommentsByCategoryID" SelectMethod="GetCommentsByCategoryID" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.DataAccess" UpdateMethod="UpdateComment">
	<DeleteParameters>
		<asp:Parameter Name="CommentID" Type="Int32" />
	</DeleteParameters>
	<UpdateParameters>
		<asp:Parameter Name="CommentID" Type="Int32" />
		<asp:Parameter Name="Comment" Type="String" />
	</UpdateParameters>
	<SelectParameters>
		<asp:Parameter Name="CategoryID" Type="Int32" />
		<asp:Parameter Name="maximumRows" Type="Int32" DefaultValue="1" />
		<asp:Parameter Name="startRowIndex" Type="Int32" DefaultValue="10" />
	</SelectParameters>
</asp:ObjectDataSource>
<asp:ObjectDataSource ID="odsGetCommentsByArticleID" runat="server" DeleteMethod="DeleteComment" EnablePaging="True" SelectCountMethod="SelectNumberOfCommentsByArticleID" SelectMethod="GetCommentsByArticleID" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.DataAccess" UpdateMethod="UpdateComment">
	<DeleteParameters>
		<asp:Parameter Name="CommentID" Type="Int32" />
	</DeleteParameters>
	<UpdateParameters>
		<asp:Parameter Name="CommentID" Type="Int32" />
		<asp:Parameter Name="Comment" Type="String" />
	</UpdateParameters>
	<SelectParameters>
		<asp:Parameter Name="ArticleID" Type="Int32" />
		<asp:Parameter Name="maximumRows" Type="Int32" DefaultValue="1" />
		<asp:Parameter Name="startRowIndex" Type="Int32" DefaultValue="10" />
	</SelectParameters>
</asp:ObjectDataSource>
