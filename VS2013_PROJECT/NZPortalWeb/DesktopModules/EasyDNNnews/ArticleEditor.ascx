<%@ control language="C#" inherits="EasyDNNSolutions.Modules.EasyDNNNews.ArticleEditor, App_Web_articleeditor.ascx.d988a5ac" autoeventwireup="true" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<asp:Panel ID="pnlMainWrapper" runat="server">
	<div id="EDNadmin">
		<div class="module_action_title_box">
			<asp:PlaceHolder ID="phAdminNavigation" runat="server" />
			<h1>
				<%=ArticleManager%></h1>
		</div>
		<div class="main_content gridview_content_manager article_manager">
			<asp:UpdatePanel ID="upMainAjax" runat="server">
				<ContentTemplate>
					<div class="edn_admin_progress_overlay_container">
						<asp:UpdateProgress ID="uppMainAjax" runat="server" AssociatedUpdatePanelID="upMainAjax" DisplayAfter="100" DynamicLayout="true">
							<ProgressTemplate>
								<div class="edn_admin_progress_overlay"></div>
							</ProgressTemplate>
						</asp:UpdateProgress>
						<asp:Panel ID="pnlArticleListWrapper" CssClass="content_wrapper" runat="server">
							<div class="content_filter_toggle">
								<asp:HyperLink ID="hlArticleFilterToggle" CssClass="filter_toggle" href="#" runat="server" Text="Show filter settings" resourcekey="hlArticleFilterToggleResource1" />
							</div>
							<asp:Panel ID="pnlArticleFilterSettings" runat="server" CssClass="content_filter_settings">
								<div class="filter_list">
									<div class="enbl_box">
										<%=Filterby%>
									</div>
									<asp:Panel ID="pnlCategoryFilter" runat="server" CssClass="dis_box">
										<asp:CheckBox ID="cbFilterByCategory" runat="server" Text="Category" CssClass="checkbox" OnCheckedChanged="cbFilterByCategory_CheckedChanged" AutoPostBack="True" resourcekey="cbFilterByCategoryResource1" />
										<asp:DropDownList ID="ddlFilterCategorySelect" runat="server" DataTextField="CategoryName" DataValueField="CategoryID" AppendDataBoundItems="True" Enabled="False" resourcekey="ddlFilterCategorySelectResource1">
											<asp:ListItem Value="-1" resourcekey="ListItemResource2" Text="Select category" />
										</asp:DropDownList>
									</asp:Panel>
									<asp:Panel ID="pnlGroupOrAuthorFilter" runat="server" CssClass="dis_box">
										<asp:CheckBox ID="cbFilterByGroupOrAuthor" runat="server" Text="Group or Author" CssClass="checkbox" OnCheckedChanged="cbFilterByGroupOrAuthor_CheckedChanged" AutoPostBack="True" resourcekey="cbFilterByGroupOrAuthor" />
										<asp:DropDownList ID="ddlFilterByGroupOrAuthor" runat="server" Enabled="False">
											<asp:ListItem Value="-1" Text="Select group or author" />
										</asp:DropDownList>
									</asp:Panel>
									<asp:Panel ID="pnlPublishFilter" runat="server" CssClass="dis_box">
										<asp:CheckBox ID="cbFilterByPublish" runat="server" AutoPostBack="True" CssClass="checkbox" Text="Published" OnCheckedChanged="cbFilterByPublish_CheckedChanged" resourcekey="cbFilterByPublishResource1" />
										<asp:DropDownList ID="ddlFilterByPublish" runat="server" AutoPostBack="True" Enabled="False">
											<asp:ListItem Value="True" resourcekey="ListItemResource5" Text="Published" />
											<asp:ListItem Value="False" resourcekey="ListItemResource6" Text="Unpublished" />
										</asp:DropDownList>
									</asp:Panel>
									<asp:Panel ID="pnlApprovedFilter" runat="server" CssClass="dis_box">
										<asp:CheckBox ID="cbFilterByApproved" runat="server" CssClass="checkbox" Text="Approved" AutoPostBack="True" OnCheckedChanged="cbFilterByApproved_CheckedChanged" resourcekey="cbFilterByApprovedResource1" />
										<asp:DropDownList ID="ddlFilterByApproved" runat="server" Enabled="False">
											<asp:ListItem Value="True" resourcekey="ListItemResource7" Text="Approved " />
											<asp:ListItem Value="False" resourcekey="ListItemResource8" Text="Unapproved" />
										</asp:DropDownList>
									</asp:Panel>
									<asp:Panel ID="pnlFeaturedFilter" runat="server" CssClass="dis_box">
										<asp:CheckBox ID="cbFilterByFeatured" runat="server" CssClass="checkbox" Text="Featured" AutoPostBack="True" OnCheckedChanged="cbFilterByFeatured_CheckedChanged" resourcekey="cbFilterByFeaturedResource1" />
										<asp:DropDownList ID="ddlFilterByFeatured" runat="server" Enabled="False">
											<asp:ListItem Value="True" resourcekey="ListItemResource9" Text="Featured" />
											<asp:ListItem Value="False" resourcekey="ListItemResource10" Text="Unfeatured" />
										</asp:DropDownList>
									</asp:Panel>
									<asp:Panel ID="pnlArticleTypeFilter" runat="server" CssClass="dis_box">
										<asp:CheckBox ID="cbFilterByArticleType" runat="server" CssClass="checkbox" Text="Article type" AutoPostBack="True" OnCheckedChanged="cbFilterByArticleType_CheckedChanged" resourcekey="cbFilterByArticleType" />
										<asp:DropDownList ID="ddlFilterByArticleType" runat="server" Enabled="False">
											<asp:ListItem resourcekey="liNews" Value="News" Text="News" />
											<asp:ListItem resourcekey="liEvents" Value="Events" Text="Events" />
										</asp:DropDownList>
									</asp:Panel>
									<asp:Panel ID="pnlPermissionsByArticleFilter" runat="server" CssClass="dis_box">
										<asp:CheckBox ID="cbFilterByPermissionsByArticle" runat="server" CssClass="checkbox" Text="Permissions per article" AutoPostBack="True" OnCheckedChanged="cbFilterByPermissionsByArticle_CheckedChanged" resourcekey="cbFilterByPermissionsByArticle" />
										<asp:DropDownList ID="ddlFilterByPermissionsByArticle" runat="server" Enabled="False">
											<asp:ListItem Value="True" resourcekey="liEnabled" Text="Enabled" />
											<asp:ListItem Value="False" resourcekey="liDisabled" Text="Disabled" />
										</asp:DropDownList>
									</asp:Panel>
								</div>
								<div class="order_list">
									<p>
										<asp:Label ID="lblOrderBy" runat="server" Text="Order by:" AssociatedControlID="ddlOrderBy" resourcekey="lblOrderByResource1" />
										<asp:DropDownList ID="ddlOrderBy" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlOrderBy_SelectedIndexChanged">
											<asp:ListItem Value="-1" resourcekey="ListItemResource11">Order by</asp:ListItem>
											<asp:ListItem Value="PublishDate" resourcekey="ListItemResource12">Publish date</asp:ListItem>
											<asp:ListItem Value="NumberofViews" resourcekey="ListItemResource13">Number of Views</asp:ListItem>
											<asp:ListItem Value="RatingValue" resourcekey="ListItemResource14">Rating</asp:ListItem>
											<asp:ListItem Value="DateAdded" resourcekey="ListItemResource15">Date added</asp:ListItem>
											<asp:ListItem Value="ExpireDate" resourcekey="ListItemResource16">Expire date</asp:ListItem>
											<asp:ListItem Value="LastModified" resourcekey="ListItemResource17">Last modified</asp:ListItem>
											<asp:ListItem Value="NumberOfComments" resourcekey="ListItemResource18">Number of comments</asp:ListItem>
											<asp:ListItem Value="Title" resourcekey="ListItemResource19">Title</asp:ListItem>
										</asp:DropDownList>
									</p>
									<p>
										<asp:Label ID="lblOrdertype" runat="server" Text="Order type:" resourcekey="lblOrdertypeResource1" />
										<asp:DropDownList ID="ddlOrderType" runat="server">
											<asp:ListItem Value="ASC" resourcekey="ListItemResource20">Ascending</asp:ListItem>
											<asp:ListItem Value="DESC" resourcekey="ListItemResource21">Descending</asp:ListItem>
										</asp:DropDownList>
									</p>
									<p>
										<asp:Label ID="lblOrderBySecond" runat="server" Text="Order by:" AssociatedControlID="ddlOrderBySecond" resourcekey="lblOrderBySecondResource1" />
										<asp:DropDownList ID="ddlOrderBySecond" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlOrderBySecond_SelectedIndexChanged">
											<asp:ListItem Value="-1" resourcekey="ListItemResource22">Order by</asp:ListItem>
											<asp:ListItem Value="PublishDate" resourcekey="ListItemResource23">Publish date</asp:ListItem>
											<asp:ListItem Value="NumberofViews" resourcekey="ListItemResource24">Number of Views</asp:ListItem>
											<asp:ListItem Value="RatingValue" resourcekey="ListItemResource25">Rating</asp:ListItem>
											<asp:ListItem Value="DateAdded" resourcekey="ListItemResource26">Date added</asp:ListItem>
											<asp:ListItem Value="ExpireDate" resourcekey="ListItemResource27">Expire date</asp:ListItem>
											<asp:ListItem Value="LastModified" resourcekey="ListItemResource28">Last modified</asp:ListItem>
											<asp:ListItem Value="NumberOfComments" resourcekey="ListItemResource29">Number of comments</asp:ListItem>
											<asp:ListItem Value="Title" resourcekey="ListItemResource30">Title</asp:ListItem>
										</asp:DropDownList>
									</p>
									<p>
										<asp:Label ID="lblOrdertypeSecond" runat="server" Text="Order type:" resourcekey="lblOrdertypeSecondResource1" />
										<asp:DropDownList ID="ddlOrderTypeSecond" runat="server">
											<asp:ListItem Value="ASC" resourcekey="ListItemResource31">Ascending</asp:ListItem>
											<asp:ListItem Value="DESC" resourcekey="ListItemResource32">Descending</asp:ListItem>
										</asp:DropDownList>
									</p>
									<div class="actions">
										<asp:LinkButton ID="btnFilerArticles" class="silver_button" runat="server" OnClick="btnFilerArticles_Click" resourcekey="btnFilerArticlesResource1"><span>Filter</span></asp:LinkButton>
									</div>
								</div>
								<asp:HiddenField ID="hfFilterSettingsState" runat="server" Value="closed" />
							</asp:Panel>
							<asp:GridView ID="gvArticleList" runat="server" AllowPaging="True" AllowSorting="True" AutoGenerateColumns="False" CellPadding="0" GridLines="Horizontal" BorderWidth="0px" DataKeyNames="ArticleID" DataSourceID="odsGetPagedArticlesByUser" EnableModelValidation="True"
								OnRowCommand="gvArticleList_RowCommand" ShowFooter="True" OnPreRender="gvArticleList_PreRender" CssClass="grid_view_table">
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
											<asp:DropDownList ID="ddlFotterActionForSelected" runat="server" Visible="<%#!ApproveMode%>" AutoPostBack="true" OnSelectedIndexChanged="ddlFotterActionForSelected_SelectedIndexChanged">
												<asp:ListItem resourcekey="liSelectAction" Value="-1" Text="Select action" />
												<asp:ListItem resourcekey="ListItemResource33" Value="Publish" Text="Publish" />
												<asp:ListItem resourcekey="ListItemResource34" Value="Unpublish" Text="Unpublish" />
												<asp:ListItem resourcekey="ListItemResource35" Value="Delete" Text="Delete" />
												<asp:ListItem resourcekey="ListItemResource36" Value="Approve" Text="Approve" />
												<asp:ListItem resourcekey="ListItemResource37" Value="Unapprove" Text="Unapprove" />
												<asp:ListItem resourcekey="ListItemResource38" Value="Feature" Text="Feature" />
												<asp:ListItem resourcekey="ListItemResource39" Value="Unfeature" Text="Unfeature" />
												<asp:ListItem resourcekey="liChangePublishDate" Value="ChangePublishDate" Text="Change publish date" />
												<asp:ListItem resourcekey="liChangeExpireDate" Value="ChangeExpireDate" Text="Change expire date" />
											</asp:DropDownList>
											<asp:DropDownList ID="ddlFotterActionForSelectedApprove" runat="server" Visible="<%#ApproveMode%>">
												<asp:ListItem resourcekey="liSelectAction" Value="-1" Text="Select action" />
												<asp:ListItem resourcekey="ListItemResource36" Value="Approve" Text="Approve" />
												<asp:ListItem resourcekey="ListItemResource37" Value="Unapprove" Text="Unapprove" />
											</asp:DropDownList>
											<asp:Panel ID="pnlPublishExpireDate" class="expirepublish" runat="server" Visible="false">
												<asp:TextBox ID="tbxPublishExpireDate" runat="server" CssClass="text_generic center" ValidationGroup="vgGVArticleListFutter" Width="90px" />
												<asp:RequiredFieldValidator ID="rfvPublishExpireDate" runat="server" ControlToValidate="tbxPublishExpireDate" CssClass="NormalRed" Display="Dynamic" ErrorMessage="Date required." ValidationGroup="vgGVArticleListFutter" />
												<asp:Label ID="lblPubDateError" ResourceKey="lblPubDateError" runat="server" ForeColor="Red" Text="Invalid date." Visible="false" />
												<asp:TextBox ID="tbxPublishExpireTime" runat="server" ValidationGroup="vgGVArticleListFutter" Width="50px" CssClass="text_generic center" />
												<asp:RequiredFieldValidator ID="rfvPublishExpireTime" runat="server" ControlToValidate="tbxPublishExpireTime" CssClass="NormalRed" Display="Dynamic" ErrorMessage="Time required." ValidationGroup="vgGVArticleListFutter" />
												<asp:RegularExpressionValidator ID="revPublishExpireTime" runat="server" ControlToValidate="tbxPublishExpireTime" EnableClientScript="true" ErrorMessage="hh:mm" ValidationExpression="([0-1]?[0-9]|2[0-3]):([0-5][0-9])" ValidationGroup="vgGVArticleListFutter" />
											</asp:Panel>
											<asp:Button ID="ibFooterOK" runat="server" CssClass="run_action" resourcekey="ibFooterOKResource1" ValidationGroup="vgGVArticleListFutter" CausesValidation="true" OnClick="ibFooterOK_Click" OnClientClick="return ShowValue();" />
											<div style="float: right; color: white; font-weight: bold; font-size: 12px; margin-top: 10px; margin-right: 10px;">
												<%#TotalCount%>
											</div>
										</FooterTemplate>
										<ItemTemplate>
											<asp:HiddenField ID="hfMainArticleID" runat="server" Value='<%# Bind("ArticleID") %>' />
											<asp:CheckBox ID="cbSelectRow" runat="server" resourcekey="cbSelectRowResource1" />
										</ItemTemplate>
										<FooterStyle CssClass="footer_actions" />
										<HeaderStyle CssClass="check_content" />
										<ItemStyle CssClass="check_content" />
									</asp:TemplateField>
									<asp:TemplateField HeaderText="Action">
										<ItemTemplate>
											<div class="clear_floated">
												<asp:LinkButton ID="lbEditThisArticle" runat="server" CausesValidation="False" CommandArgument='<%# Eval("ArticleID") %>' CommandName="EditArticle" CssClass="action_set tripple edit" resourcekey="lbEditThisArticleResource1" ToolTip="<%#EditToolTip%>"
													Visible="<%#!ApproveMode%>" />
												<asp:LinkButton ID="lbDeleteArticle" runat="server" CausesValidation="False" CommandArgument='<%# Eval("ArticleID") %>' CommandName="DeleteArticle" CssClass="action_set tripple delete" resourcekey="lbDeleteArticleResource1" OnClientClick="return confirm('Are you certain you want to delete this article?');"
													ToolTip="<%#DeleteTooltip%>" Visible="<%#!ApproveMode%>" />
												<asp:HyperLink ID="hlPreviewArticle" runat="server" CssClass="action_set tripple view" resourcekey="hlPreviewArticleResource1" NavigateUrl='<%# GetArticleUrl(Eval("ArticleID")) %>' Target="_blank" ToolTip="<%#ViewTooltip%>"></asp:HyperLink>
												<div class="action_set underbuttons">
													<asp:HyperLink ID="hlEditComments" runat="server" CssClass="tripple comments" resourcekey="hlEditCommentsResource1" NavigateUrl='<%# GetEditCommentsUrl(Eval("ArticleID")) %>' Target="_self" ToolTip="<%#ViewCommentsTooltip%>" Visible="<%#!ApproveMode%>" />
													<asp:HyperLink ID="hlCreateNewArticle" runat="server" CssClass="tripple create_as_new" resourcekey="hlCreateNewArticleResource1" NavigateUrl='<%# GetCreateNewUrl(Eval("ArticleID")) %>' Target="_blank" ToolTip="<%#CopyArticleTooltip%>" Visible="<%#!ApproveMode%>" />
													<asp:LinkButton ID="hlLocalizeArticle" runat="server" CausesValidation="False" CommandArgument='<%# Eval("ArticleID") %>' CommandName="LocalizeArticle" CssClass="tripple localization" resourcekey="hlLocalizeArticleResource1" ToolTip="<%#LocalizeArticleToolTip%>"
														Visible="<%#!ApproveMode%>" />
												</div>
											</div>
										</ItemTemplate>
										<HeaderStyle CssClass="actions" />
										<ItemStyle CssClass="actions" />
									</asp:TemplateField>
									<asp:TemplateField HeaderText="Title" SortExpression="Title">
										<ItemTemplate>
											<asp:Panel ID="pnlArticleImage" runat="server" CssClass="article_img" resourcekey="pnlArticleImageResource1" Visible='<%# GetArticleImageURLVisible(Eval("ArticleID"),Eval("ArticleImage")) %>'>
												<asp:Image ID="imgArticleImage" runat="server" ImageUrl='<%# GetArticleImageURL(Eval("ArticleID"),Eval("ArticleImage")) %>' resourcekey="imgArticleImageResource1" />
											</asp:Panel>
											<asp:Label ID="Label3" runat="server" resourcekey="Label3Resource1" Text='<%# Bind("Title") %>'></asp:Label>
										</ItemTemplate>
										<HeaderStyle CssClass="title" />
										<ItemStyle CssClass="title" />
									</asp:TemplateField>
									<asp:TemplateField HeaderText="Article dates" SortExpression="PublishDate">
										<ItemTemplate>
											<p class="date">
												<asp:Label ID="lblArticleListPubDate" runat="server" CssClass="icon" Text='<%# GetFormatedDate(Eval("PublishDate"))%>' ToolTip="<%#PublishDateTooltip%>" />
											</p>
											<p class="date">
												<asp:Label ID="lblArticleListExpireDate" runat="server" CssClass="icon red" Text='<%# GetFormatedDate(Eval("ExpireDate"))%>' ToolTip="<%#ExpireDateToolTip%>" />
											</p>
											<p class="date">
												<asp:Label ID="lblArticleListLastModified" runat="server" CssClass="icon blue" Text='<%# GetFormatedDate(Eval("LastModified"))%>' ToolTip="<%#LastModifiedTooltip%>" />
											</p>
											<%# GetStartFormatedDate(Eval("EventStartDate"), Eval("IsRecurring"))%>
										</ItemTemplate>
										<HeaderStyle CssClass="dates" />
										<ItemStyle CssClass="dates" />
									</asp:TemplateField>
									<asp:TemplateField HeaderText="Info" SortExpression="UserID">
										<ItemTemplate>
											<div class="user" title="<%#AuthorTooltip%>">
												<%# Eval("DisplayName")%>
											</div>
											<asp:Label ID="lblIsEvent" resourcekey="lblIsEvent" runat="server" CssClass="EventArticle" Visible='<%#Convert.ToBoolean(Eval("EventArticle"))%>' ToolTip="Event" Text="Event" />
											<asp:Label ID="lblPermissionsPerArticle" CssClass="PermissionsPerArticle" runat="server" Visible='<%#Convert.ToBoolean(Eval("HasPermissions"))%>' ToolTip="Permissions per article" Text="Permissions" />
										</ItemTemplate>
										<HeaderStyle CssClass="author" />
										<ItemStyle CssClass="author" />
									</asp:TemplateField>
									<asp:TemplateField HeaderText="Stats">
										<ItemTemplate>
											<p class="stat">
												<asp:Label ID="lblArticleListViewCount" runat="server" CssClass="icon views" Text='<%# Bind("NumberOfViews") %>' ToolTip="<%#NumberOfViewTooltip%>"></asp:Label>
											</p>
											<p class="stat">
												<asp:Label ID="lblArticleListCurrentRating" runat="server" CssClass="icon stars" Text='<%# String.Format("{0:.00}",Eval("RatingValue")) %>' ToolTip="<%#RatigTooltip%>"></asp:Label>
											</p>
											<p class="stat">
												<asp:Label ID="lblArticleListCommentCount" runat="server" CssClass="icon comments" Text='<%# Bind("NumberOfCOmments") %>' ToolTip="<%#NumberOfCommentsTooltip%>"></asp:Label>
											</p>
										</ItemTemplate>
										<HeaderStyle CssClass="stats" />
										<ItemStyle CssClass="stats" />
									</asp:TemplateField>
									<asp:TemplateField HeaderText="Action">
										<ItemTemplate>
											<asp:LinkButton ID="lbArticleListPublished" runat="server" CommandArgument='<%# Eval("ArticleID") %>' CommandName="Publish" CssClass="checkbox_action" resourcekey="lbArticleListPublishedResource1" Visible="<%#!ApproveMode%>">
												<asp:Label runat="server" Text="Published" CssClass='<%# GetIconClas(Eval("Active")) %>' ID="lblArticleListPublished" resourcekey="lblArticleListPublishedResource1" />
											</asp:LinkButton><asp:LinkButton ID="lbArticleListApproved" runat="server" CommandArgument='<%# Eval("ArticleID") %>' CommandName="Approve" CssClass="checkbox_action" Enabled="<%# EnableApprove() %>" resourcekey="lbArticleListApprovedResource1">
												<asp:Label runat="server" Text="Approved" CssClass='<%# GetIconClas(Eval("Approved")) %>' ID="lblArticleListApproved" resourcekey="lblArticleListApprovedResource1"></asp:Label>
											</asp:LinkButton><asp:LinkButton ID="lbArticleListFeatured" runat="server" CommandArgument='<%# Eval("ArticleID") %>' CommandName="Feature" CssClass="checkbox_action" resourcekey="lbArticleListFeaturedResource1" Visible="<%#!ApproveMode%>">
												<asp:Label runat="server" Text="Featured" CssClass='<%# GetIconClas(Eval("Featured")) %>' ID="lblArticleListFeatured" resourcekey="lblArticleListFeaturedResource1" />
											</asp:LinkButton><asp:LinkButton ID="lbArticleListReject" resourcekey="lbArticleListReject" Visible='<%# GetRejectVisible(Eval("Approved"),Eval("Active")) %>' runat="server" CommandArgument='<%# Eval("ArticleID") %>' CommandName="Reject" CssClass="checkbox_action button"
												Enabled="<%# EnableApprove() %>">
												<asp:Label runat="server" Text="Reject" CssClass="icon" ID="lblArticleListReject" />
											</asp:LinkButton><asp:Panel runat="server" ID="pnlRejectMessage" Visible="false" Height="120px">
												<asp:Label ID="lblRejectMessage" runat="server" Text="Explain why the article was rejected:"></asp:Label><asp:TextBox ID="tbRejectMessage" runat="server" TextMode="MultiLine" Style="width: 650px; height: 40px; font: 12px Arial; line-height: 1.3;"></asp:TextBox>
												<p>
													<asp:LinkButton ID="lbRejectWMwssage" CommandArgument='<%# Eval("ArticleID") %>' CommandName="RejectWithMessage" runat="server" Font-Bold="True">Reject </asp:LinkButton>&nbsp;
													<asp:LinkButton ID="lbCancelRejectWMwssage" CommandName="Cancel" Font-Bold="True" runat="server">Cancel </asp:LinkButton>
												</p>
											</asp:Panel>
										</ItemTemplate>
										<HeaderStyle CssClass="state_actions" />
										<ItemStyle CssClass="state_actions" />
									</asp:TemplateField>
								</Columns>
								<EditRowStyle BackColor="#E2EDF4" />
								<HeaderStyle CssClass="header_row" />
								<PagerStyle CssClass="pagination" />
								<RowStyle CssClass="row" />
							</asp:GridView>
							<div class="nomber_of_rows_selection" style="margin-top: 5px; margin-bottom: 5px; float: right;">
								<asp:Label ID="lblFooterSelectNumberOfRows" AssociatedControlID="ddlFooterNumberOfRows" runat="server" Text="Number of rows:" resourcekey="lblFooterSelectNumberOfRowsResource1" />
								<asp:DropDownList ID="ddlFooterNumberOfRows" runat="server" OnSelectedIndexChanged="ddlFooterNumberOfRows_SelectedIndexChanged" AutoPostBack="True">
									<asp:ListItem resourcekey="ListItemResource40" Text="10" />
									<asp:ListItem resourcekey="ListItemResource41" Text="20" />
									<asp:ListItem resourcekey="ListItemResource42" Text="30" />
									<asp:ListItem resourcekey="ListItemResource43" Text="50" />
									<asp:ListItem resourcekey="ListItemResource44" Text="100" />
								</asp:DropDownList>
							</div>
							<asp:Panel ID="pnlNoArticlesMatched" runat="server" class="no_content_matched_filter" Visible="False">
								<asp:Literal ID="liInfoArticleCount" runat="server" />
							</asp:Panel>
						</asp:Panel>
						<asp:Panel ID="pnlNoArticles" CssClass="standalone_message" runat="server" Visible="False">
							<asp:Literal ID="liInfoArticleCount2" runat="server" />
							<asp:HyperLink ID="hlAddNewArticle" runat="server" CssClass="silver_button" resourcekey="hlAddNewArticleResource1"><span>Add an article</span></asp:HyperLink>
						</asp:Panel>
					</div>
				</ContentTemplate>
			</asp:UpdatePanel>
		</div>
	</div>
</asp:Panel>
<asp:Literal ID="generatedHtm" runat="server" Visible="False" />
<script type="text/javascript">
	if ('<%=jQuery%>' == 'jQuery') {
		jQuery.noConflict();
	}
	function ShowValue() {
		var dropdownList;
		if ('<%=!ApproveMode%>' == 'True') {
			jQuery("#<%=gvArticleList.ClientID %> select[id*='ddlFotterActionForSelected']").each(function (index) {
				dropdownList = jQuery(this);
			});
		}
		else {
			jQuery("#<%=gvArticleList.ClientID %> select[id*='ddlFotterActionForSelectedApprove']").each(function (index) {
				dropdownList = jQuery(this);
			});
		}
		if (dropdownList.val() == '-1') {
			alert('<%=selectAction%>');
		}
		else {
			return confirm('<%=Confirmation%>');
		}
	}

	jQuery(document).ready(function ($) {
		$('#<%=upMainAjax.ClientID%>').delegate('#<%=hlArticleFilterToggle.ClientID %>', 'click', function () {
			var toggle = $(this),
			filter_settings = $('#<%=pnlArticleFilterSettings.ClientID %>'),
			filter_settings_state = $('#<%=hfFilterSettingsState.ClientID %>');

			if (toggle.hasClass('open')) {
				toggle.removeClass('open');
				filter_settings.slideUp(200);
				filter_settings_state.val('closed');
			} else {
				toggle.addClass('open');
				filter_settings.slideDown(200);
				filter_settings_state.val('open');
			}
			return false;
		});
	});

	var hfSharedGalleryID = document.getElementById('<%=tbxPublishExpireDateClientID%>');
	if (hfSharedGalleryID != null) {
		$('#<%=tbxPublishExpireDateClientID%>').datepick({ dateFormat: "<%=dateFormat%>" });
	}
	function pageLoad(sender, args) {
		if (args.get_isPartialLoad()) {
			var hfSharedGalleryID = document.getElementById('<%=tbxPublishExpireDateClientID%>');
			if (hfSharedGalleryID != null) {
				jQuery('#<%=tbxPublishExpireDateClientID%>').datepick({ dateFormat: "<%=dateFormat%>" });
			}
		}
	}

</script>
<asp:ObjectDataSource ID="odsGetPagedArticlesByUser" runat="server" SelectMethod="GetItemsForArticleEditor" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.NewsDataDB" EnablePaging="True" MaximumRowsParameterName="numberOfPostsperPage" SelectCountMethod="CountItemsForArticleEditor"
	StartRowIndexParameterName="startingArticle" OnSelecting="odsGetPagedArticlesByUser_Selecting" OnSelected="odsGetPagedArticlesByUser_Selected">
	<SelectParameters>
		<asp:Parameter Name="PortalID" Type="Int32" />
		<asp:Parameter Name="ModuleID" Type="Int32" />
		<asp:Parameter Name="UserID" Type="Int32" />
		<asp:Parameter Name="OnlyOneCategory" Type="Int32" />
		<asp:Parameter Name="FilterByAuthor" Type="Int32" />
		<asp:Parameter Name="FilterByGroupID" Type="Int32" />
		<asp:Parameter Name="EditOnlyAsOwner" Type="Boolean" />
		<asp:Parameter Name="UserCanApprove" Type="Boolean" />
		<asp:Parameter Name="Perm_ViewAllCategores" Type="Boolean" />
		<asp:Parameter Name="Perm_EditAllCategores" Type="Boolean" />
		<asp:Parameter Name="AdminOrSuperUser" Type="Boolean" />
		<asp:Parameter Name="PermissionSettingsSource" Type="Boolean" />
		<asp:Parameter Name="OrderBy" Type="String" />
		<asp:Parameter Name="OrderBy2" Type="String" />
		<asp:Parameter Name="Featured" Type="Int32" />
		<asp:Parameter Name="Published" Type="Int32" />
		<asp:Parameter Name="Approved" Type="Int32" />
		<asp:Parameter Name="ArticleType" Type="Int32" />
		<asp:Parameter Name="PermissionsByArticle" Type="Int32" />
		<asp:Parameter Name="startingArticle" Type="Int32" />
		<asp:Parameter Name="numberOfPostsperPage" Type="Int32" />
	</SelectParameters>
</asp:ObjectDataSource>
