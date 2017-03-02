<%@ control language="C#" inherits="EasyDNNSolutions.Modules.EasyDNNNews.EventManager, App_Web_eventmanager.ascx.b9f6810f" autoeventwireup="true" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<%@ Register TagPrefix="dnn" TagName="TextEditor" Src="~/controls/TextEditor.ascx" %>

<asp:Panel ID="pnlMainWrapper" runat="server">
	<div id="EDNadmin" style="width: 1100px">
		<div class="module_action_title_box">
			<asp:PlaceHolder ID="phAdminNavigation" runat="server" />
			<h1><%=topControlTitle%></h1>
		</div>
		<div class="main_content gridview_content_manager article_manager">
			<asp:UpdatePanel ID="upMainAjax" runat="server">
				<ContentTemplate>
					<asp:Literal ID="liAdminNAvigation" runat="server"></asp:Literal>

					<asp:UpdateProgress ID="uppMainAjax" runat="server" AssociatedUpdatePanelID="upMainAjax" DisplayAfter="100" DynamicLayout="true">
						<ProgressTemplate>
							<div class="edn_admin_progress_overlay"></div>
						</ProgressTemplate>
					</asp:UpdateProgress>

					<div id="pnlEventDetailInfo" class="eventmanager">
						<div class="eventtitle">
							<asp:Literal ID="liEventTitle" runat="server"></asp:Literal>
						</div>
						<div class="controltitle">
							<asp:Literal ID="liControlTitle" runat="server"></asp:Literal>
						</div>
						<div class="breadcrumbs">
							<asp:Literal ID="liBreadCrumbs" runat="server"></asp:Literal>
						</div>
					</div>

					<asp:Panel ID="pnlListOfEventsWithEnabledRegistration" runat="server">
						<div class="edn_admin_progress_overlay_container">
							<asp:Panel ID="pnlArticleListWrapper" CssClass="content_wrapper" runat="server">
								<div class="content_filter_toggle">
									<asp:HyperLink ID="hlArticleFilterToggle" CssClass="filter_toggle" href="#" runat="server" Text="Show filter settings" resourcekey="hlArticleFilterToggle" />
								</div>
								<asp:Panel ID="pnlArticleFilterSettings" runat="server" CssClass="content_filter_settings">
									<div class="filter_list">
										<div class="enbl_box">
											<%=filterBy%>
										</div>
										<asp:Panel ID="pnlCategoryFilter" runat="server" CssClass="dis_box">
											<asp:CheckBox ID="cbFilterByCategory" runat="server" Text="Category" CssClass="checkbox" OnCheckedChanged="cbFilterByCategory_CheckedChanged" AutoPostBack="True" resourcekey="cbFilterByCategory" />
											<asp:DropDownList ID="ddlFilterCategorySelect" runat="server" DataTextField="CategoryName" DataValueField="CategoryID" AppendDataBoundItems="True" Enabled="False">
												<asp:ListItem Value="-1" resourcekey="liSelectCategory" Text="Select category" />
											</asp:DropDownList>
										</asp:Panel>
										<asp:Panel ID="pnlGroupOrAuthorFilter" runat="server" CssClass="dis_box">
											<asp:CheckBox ID="cbFilterByGroupOrAuthor" runat="server" Text="Group or Author" CssClass="checkbox" OnCheckedChanged="cbFilterByGroupOrAuthor_CheckedChanged" AutoPostBack="True" resourcekey="cbFilterByGroupOrAuthor" />
											<asp:DropDownList ID="ddlFilterByGroupOrAuthor" runat="server" Enabled="False">
												<asp:ListItem Value="-1" resourcekey="liSelectgrouporauthor" Text="Select group or author" />
											</asp:DropDownList>
										</asp:Panel>
										<asp:Panel ID="pnlPublishFilter" runat="server" CssClass="dis_box">
											<asp:CheckBox ID="cbFilterByPublish" runat="server" AutoPostBack="True" CssClass="checkbox" Text="Published" OnCheckedChanged="cbFilterByPublish_CheckedChanged" resourcekey="cbFilterByPublish" />
											<asp:DropDownList ID="ddlFilterByPublish" runat="server" AutoPostBack="True" Enabled="False">
												<asp:ListItem Value="True" resourcekey="liPublished" Text="Published" />
												<asp:ListItem Value="False" resourcekey="liUnpublished" Text="Unpublished" />
											</asp:DropDownList>
										</asp:Panel>
										<asp:Panel ID="pnlFeaturedFilter" runat="server" CssClass="dis_box">
											<asp:CheckBox ID="cbFilterByFeatured" runat="server" CssClass="checkbox" Text="Featured" AutoPostBack="True" OnCheckedChanged="cbFilterByFeatured_CheckedChanged" resourcekey="cbFilterByFeatured" />
											<asp:DropDownList ID="ddlFilterByFeatured" runat="server" Enabled="False">
												<asp:ListItem Value="True" resourcekey="liFeatured" Text="Featured" />
												<asp:ListItem Value="False" resourcekey="liUnfeatured" Text="Unfeatured" />
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
											<asp:Label ID="lblOrderBy" runat="server" Text="Order by:" AssociatedControlID="ddlOrderBy" resourcekey="lblOrderBy" />
											<asp:DropDownList ID="ddlOrderBy" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlOrderBy_SelectedIndexChanged">
												<asp:ListItem Value="-1" resourcekey="liOrderby">Order by</asp:ListItem>
												<asp:ListItem Value="StartDate" resourcekey="liStartdate">Start date</asp:ListItem>
												<asp:ListItem Value="PublishDate" resourcekey="liPublishdate">Publish date</asp:ListItem>
												<asp:ListItem Value="NumberofViews" resourcekey="liNumberofViews">Number of Views</asp:ListItem>
												<asp:ListItem Value="RatingValue" resourcekey="liRating">Rating</asp:ListItem>
												<asp:ListItem Value="DateAdded" resourcekey="liDateAdded">Date added</asp:ListItem>
												<asp:ListItem Value="ExpireDate" resourcekey="liExpireDate">Expire date</asp:ListItem>
												<asp:ListItem Value="LastModified" resourcekey="liLastmodified">Last modified</asp:ListItem>
												<asp:ListItem Value="NumberOfComments" resourcekey="liNumberOfCmments">Number of comments</asp:ListItem>
												<asp:ListItem Value="Title" resourcekey="liTitle">Title</asp:ListItem>
											</asp:DropDownList>
										</p>
										<p>
											<asp:Label ID="lblOrdertype" runat="server" Text="Order type:" resourcekey="lblOrdertype" />
											<asp:DropDownList ID="ddlOrderType" runat="server">
												<asp:ListItem Value="ASC" resourcekey="liAscending">Ascending</asp:ListItem>
												<asp:ListItem Value="DESC" resourcekey="liDescending">Descending</asp:ListItem>
											</asp:DropDownList>
										</p>
										<p>
											<asp:Label ID="lblOrderBySecond" runat="server" Text="Order by:" AssociatedControlID="ddlOrderBySecond" resourcekey="lblOrderBySecond" />
											<asp:DropDownList ID="ddlOrderBySecond" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlOrderBySecond_SelectedIndexChanged">
												<asp:ListItem Value="-1" resourcekey="liOrderby">Order by</asp:ListItem>
												<asp:ListItem Value="StartDate" resourcekey="liStartdate">Start date</asp:ListItem>
												<asp:ListItem Value="PublishDate" resourcekey="liPublishdate">Publish date</asp:ListItem>
												<asp:ListItem Value="NumberofViews" resourcekey="liNumberofViews">Number of Views</asp:ListItem>
												<asp:ListItem Value="RatingValue" resourcekey="liRating">Rating</asp:ListItem>
												<asp:ListItem Value="DateAdded" resourcekey="liDateAdded">Date added</asp:ListItem>
												<asp:ListItem Value="ExpireDate" resourcekey="liExpireDate">Expire date</asp:ListItem>
												<asp:ListItem Value="LastModified" resourcekey="liLastmodified">Last modified</asp:ListItem>
												<asp:ListItem Value="NumberOfComments" resourcekey="liNumberOfCmments">Number of comments</asp:ListItem>
												<asp:ListItem Value="Title" resourcekey="liTitle">Title</asp:ListItem>
											</asp:DropDownList>
										</p>
										<p>
											<asp:Label ID="lblOrdertypeSecond" runat="server" Text="Order type:" resourcekey="lblOrdertype" />
											<asp:DropDownList ID="ddlOrderTypeSecond" runat="server">
												<asp:ListItem Value="ASC" resourcekey="liAscending">Ascending</asp:ListItem>
												<asp:ListItem Value="DESC" resourcekey="liDescending">Descending</asp:ListItem>
											</asp:DropDownList>
										</p>
										<p>
											<asp:Label ID="lblFilterStartDate" runat="server" Text="Start date:" resourcekey="lblFilterStartDate" />
											<asp:TextBox ID="tbxFilterStartDate" runat="server" ValidationGroup="vgEditArticle" Width="90px" />
											<asp:RequiredFieldValidator ID="rfvEventStartDate" runat="server" ControlToValidate="tbxFilterStartDate" CssClass="NormalRed" Display="Dynamic" Enabled="false" ErrorMessage="Date required." ValidationGroup="vgEditArticle" resourcekey="rfvEventStartDateResource1" />
										</p>
										<div class="actions">
											<asp:LinkButton ID="btnFilerArticles" class="silver_button" runat="server" OnClick="btnFilerArticles_Click" resourcekey="btnFilerArticles" Text="<span>Filter</span>"></asp:LinkButton>
										</div>
									</div>
									<asp:HiddenField ID="hfFilterSettingsState" runat="server" Value="closed" />
								</asp:Panel>
								<asp:GridView ID="gvArticleList" runat="server" AllowPaging="True" AllowSorting="True" AutoGenerateColumns="False" CellPadding="0" GridLines="Horizontal" BorderWidth="0px" DataKeyNames="ArticleID" DataSourceID="odsGetPagedArticlesByUser" EnableModelValidation="True"
									OnRowCommand="gvArticleList_RowCommand" ShowFooter="True" OnPreRender="gvArticleList_PreRender" CssClass="grid_view_table eventmanager">
									<AlternatingRowStyle CssClass="row second" />
									<Columns>
										<asp:TemplateField>
											<FooterTemplate>
												<div class="arrow_icon">
												</div>
												<asp:LinkButton ID="ibFooterSelectAll" runat="server" CommandName="SelectAll" CssClass="silver_button" resourcekey="ibFooterSelectAll" Text="<span>Select all</span>"></asp:LinkButton>
												<asp:LinkButton ID="ibFooterUnSelectAll" runat="server" CommandName="UnselectAll" CssClass="silver_button" resourcekey="ibFooterUnSelectAll" Text="<span>Unselect all</span>"></asp:LinkButton>
												<div class="seperator">
												</div>
												<asp:DropDownList ID="ddlFotterActionForSelected" runat="server">
													<asp:ListItem resourcekey="liSelectAction" Value="-1" Text="Select action" />
													<asp:ListItem resourcekey="liDelete" Value="Delete" Text="Delete" />
												</asp:DropDownList>
												<asp:Button ID="ibFooterOK" runat="server" CssClass="run_action" ValidationGroup="vgGVArticleListFutter" CausesValidation="true" OnClick="ibFooterOK_Click" OnClientClick="return ShowValue();" />
												<div style="float: right; color: white; font-weight: bold; font-size: 12px; margin-top: 10px; margin-right: 10px;">
													<%#TotalCount%>
												</div>
											</FooterTemplate>
											<ItemTemplate>
												<asp:HiddenField ID="hfMainArticleID" runat="server" Value='<%# Bind("ArticleID") %>' />
												<asp:HiddenField ID="hfMainRecurringID" runat="server" Value='<%# Bind("RecurringID") %>' />
												<asp:CheckBox ID="cbSelectRow" runat="server" />
											</ItemTemplate>
											<FooterStyle CssClass="footer_actions" />
											<HeaderStyle CssClass="check_content" />
											<ItemStyle CssClass="check_content" />
										</asp:TemplateField>
										<asp:TemplateField HeaderText="Action">
											<ItemTemplate>
												<div class="clear_floated">
													<asp:LinkButton ID="lbEditThisArticle" runat="server" Text="Edit event" CausesValidation="False" CommandArgument='<%# Eval("ArticleID") + ";" + Eval("RecurringID") %>' CommandName="EditArticle" ToolTip='<%#Localization.GetString("Editevent.Text", LocalResourceFile)%>' resourcekey="lbEditThisArticle" /><br />
													<asp:HyperLink runat="server" ID="hlEditAttendees" resourcekey="hlEditAttendees" NavigateUrl='<%# createLinkForListAttendees(Eval("ArticleID"),Eval("RecurringID")) %>' Text="Edit attendees" Enabled='<%# HasAttendees(Eval("HasAttendees")) %>'></asp:HyperLink><br />
													<asp:HyperLink runat="server" ID="hlAddAttendee" resourcekey="hlAddAttendee" NavigateUrl='<%# createLinkForAddAttendee(Eval("ArticleID"),Eval("RecurringID")) %>' Text="Add attendees" Visible='<%# CanAddAttendee %>'></asp:HyperLink><%=CanAddAttendee ? "<br/>" : "" %>
													<asp:HyperLink runat="server" ID="hlEditInvitations" resourcekey="hlEditInvitations" NavigateUrl='<%# createLinkForSendInvitations(Eval("ArticleID"),Eval("RecurringID")) %>' Text="Edit invitations"></asp:HyperLink><br />
													<asp:HyperLink runat="server" ID="hlEditReminders" resourcekey="hlEditReminders" NavigateUrl='<%# createLinkForSendReminders(Eval("ArticleID"),Eval("RecurringID")) %>' Text="Edit reminders"></asp:HyperLink><br />
												</div>
											</ItemTemplate>
											<HeaderStyle CssClass="actions" />
											<ItemStyle CssClass="actions" />
										</asp:TemplateField>
										<asp:TemplateField HeaderText="Event Title" SortExpression="Title">
											<ItemTemplate>
												<asp:Panel ID="pnlArticleImage" runat="server" CssClass="article_img" Visible='<%# GetArticleImageURLVisible(Eval("ArticleID"),Eval("ArticleImage")) %>'>
													<asp:Image ID="imgArticleImage" runat="server" ImageUrl='<%# GetArticleImageURL(Eval("ArticleID"),Eval("ArticleImage")) %>' />
												</asp:Panel>
												<asp:Label ID="lblEventTitle" runat="server" Text='<%# Bind("Title") %>'></asp:Label>
											</ItemTemplate>
											<HeaderStyle CssClass="title" />
											<ItemStyle CssClass="title" />
										</asp:TemplateField>
										<asp:TemplateField HeaderText="Event Dates" SortExpression="PublishDate">
											<ItemTemplate>
												<%--												<p class="date">
													<asp:Label ID="lblEventPublishDate" runat="server" CssClass="icon" Text='<%# GetFormatedDate(Eval("PublishDate"))%>' ToolTip="<%#PublishDateTooltip%>" />
												</p>--%>
												<p class="date">
													<asp:Label ID="lblEventStartDate" runat="server" CssClass="icon red" Text='<%# GetFormatedDate(Eval("StartDate"))%>' ToolTip='<%#Localization.GetString("Startdate.Text", LocalResourceFile)%>' />
												</p>
												<p class="date">
													<asp:Label ID="lblEventEndDate" runat="server" CssClass="icon blue" Text='<%# GetFormatedDate(Eval("EndDate"))%>' ToolTip='<%#Localization.GetString("Enddate.Text", LocalResourceFile)%>' />
												</p>
											</ItemTemplate>
											<HeaderStyle CssClass="dates" />
											<ItemStyle CssClass="dates" />
										</asp:TemplateField>
										<asp:TemplateField HeaderText="Seats">
											<ItemTemplate>
												<asp:Label ID="lblReserved" runat="server" ToolTip='<%#Localization.GetString("Isreccuringevent.Text", LocalResourceFile)%>' Text='<%# GetReserved(Eval("RegistratedCount"))%>' />
												<br />
												<asp:Label ID="lblTotalPlaces" resourcekey="lblTotalPlaces" runat="server" Text='<%# GetMaxNumberOfTickets(Eval("MaxNumberOfTickets")) %>' ToolTip='<%#Localization.GetString("Totalseats.Text", LocalResourceFile)%>' /><br />
												<asp:Label ID="lblRemaining" runat="server" ToolTip='<%#Localization.GetString("Remaining.Text", LocalResourceFile)%>'  Text='<%# GetRemainingTickets(Eval("MaxNumberOfTickets"), Eval("RegistratedCount")) %>' />
											</ItemTemplate>
											<HeaderStyle CssClass="author" />
											<ItemStyle CssClass="author" />
										</asp:TemplateField>
										<asp:TemplateField HeaderText="Info" SortExpression="UserID" HeaderStyle-Width="100px">
											<ItemTemplate>
												<asp:Label ID="lblIsRecurring" runat="server" ToolTip='<%#Localization.GetString("Isrecurringevent.Text", LocalResourceFile)%>' Text='<%# GetRecurringText(Eval("Recurring")) %>' /><br />
												<asp:Label ID="lblRecurringID" runat="server" Text='<%# GetRecurringID(Eval("RecurringID")) %>' ToolTip='<%#Localization.GetString("RecurringID.Text", LocalResourceFile)%>' /><br />
												<asp:Label ID="lblOwner" runat="server" Text='<%# GetOwner(Eval("DisplayName")) %>' ToolTip='<%#Localization.GetString("Owner.Text", LocalResourceFile)%>' />
												<div style="color: #0D71C2; font-weight: bold;">
													<asp:Label ID="lblApproveAttendeeCount" runat="server" Text='<%# GetApproveAttendeeCount(Eval("ApproveAttendeeCount")) %>' ToolTip='<%#Localization.GetString("Waitingforapproval.Text", LocalResourceFile)%>'></asp:Label>
												</div>
											</ItemTemplate>
											<HeaderStyle CssClass="author" />
											<ItemStyle CssClass="author" />
										</asp:TemplateField>
										<asp:TemplateField>
											<ItemTemplate>
												<asp:Label ID="lblFee" runat="server" Text='<%# GetFee(Eval("EventType")) %>' ToolTip='<%#Localization.GetString("Fee.Text", LocalResourceFile)%>'></asp:Label><br />
												<asp:Label ID="lblModerated" runat="server" Text='<%# GetModerated(Eval("RegistrationApproval")) %>' ToolTip='<%#Localization.GetString("Moderated.Text", LocalResourceFile)%>'></asp:Label><br />
												<asp:Label ID="lblActiveRegistration" runat="server" Text='<%# GetActiveRegistration(Eval("DisableFurtherRegistration")) %>' ToolTip='<%#Localization.GetString("Activeregistration.Text", LocalResourceFile)%>'></asp:Label><br />

											</ItemTemplate>
											<HeaderStyle CssClass="stats" />
											<ItemStyle CssClass="stats" />
										</asp:TemplateField>
									</Columns>
									<EditRowStyle BackColor="#E2EDF4" />
									<HeaderStyle CssClass="header_row" />
									<PagerStyle CssClass="pagination" />
									<RowStyle CssClass="row" />
								</asp:GridView>
								<div class="nomber_of_rows_selection" style="margin-top: 5px; margin-bottom: 5px; float: right;">
									<asp:Label ID="lblFooterSelectNumberOfRows" AssociatedControlID="ddlEventListNumberOfRows" runat="server" Text="Number of rows:" resourcekey="lblFooterSelectNumberOfRowsResource1" />
									<asp:DropDownList ID="ddlEventListNumberOfRows" runat="server" OnSelectedIndexChanged="ddlEventListNumberOfRows_SelectedIndexChanged" AutoPostBack="True">
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
								<asp:HyperLink ID="hlAddNewArticle" runat="server" CssClass="silver_button" resourcekey="hlAddNewArticle"><span>Add an article</span></asp:HyperLink>
							</asp:Panel>
						</div>
					</asp:Panel>

					<asp:Panel ID="pnlListOfAttendess" runat="server" Visible="false">
						<div class="edn_admin_progress_overlay_container">
							<asp:Panel ID="pnlAttendeesListWrapper" CssClass="content_wrapper eventmanager" runat="server">
								<div class="content_filter_toggle" style="display: none;">
									<asp:HyperLink ID="hlAttendessFilterToggle" CssClass="filter_toggle" href="#" runat="server" Text="Show filter settings" resourcekey="hlArticleFilterToggleResource1" />
								</div>
								<asp:Panel ID="pnlAttendessFilterSettings" runat="server" CssClass="content_filter_settings" Visible="false">
									<div class="filter_list">
										<div class="enbl_box">
											<%=filterBy%>
										</div>
										<asp:Panel ID="Panel5" runat="server" CssClass="dis_box">
											<asp:CheckBox ID="cbAttendeesApproved" runat="server" AutoPostBack="True" CssClass="checkbox" Text="Approved" OnCheckedChanged="cbFilterByPublish_CheckedChanged" resourcekey="nema" />
											<asp:DropDownList ID="ddlAttendeesApproved" runat="server" AutoPostBack="True" Enabled="False">
												<asp:ListItem Value="Approved" Text="Approved" resourcekey="nema" />
												<asp:ListItem Value="Unapproved" Text="Unapproved" resourcekey="nema" />
												<asp:ListItem Value="AwaitingApproval" Text="Awaiting approval" resourcekey="nema" />
											</asp:DropDownList>
										</asp:Panel>
									</div>
									<div class="order_list">
										<p>
											<asp:Label ID="Label1" runat="server" Text="Order by:" AssociatedControlID="ddlOrderBy" resourcekey="lblOrderByResource1" />
											<asp:DropDownList ID="ddlAttendeesOrderby" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlOrderBy_SelectedIndexChanged">
												<asp:ListItem Value="-1" Text="Order by" resourcekey="ListItemResource11" />
												<asp:ListItem Value="CreatedOnDate" Text="Registration date" resourcekey="nema" />
												<asp:ListItem Value="NumberOfTickets" Text="Number of tickets" resourcekey="nema" />
											</asp:DropDownList>
										</p>
										<p>
											<asp:Label ID="Label2" runat="server" Text="Order type:" resourcekey="lblOrdertypeResource1" />
											<asp:DropDownList ID="DropDownList9" runat="server">
												<asp:ListItem Value="ASC" Text="Ascending" resourcekey="ListItemResource20" />
												<asp:ListItem Value="DESC" Text="Descending" resourcekey="ListItemResource21" />
											</asp:DropDownList>
										</p>
										<div class="actions">
											<asp:LinkButton ID="lbAttendeesFilter" class="silver_button" runat="server" OnClick="lbAttendeesFilter_Click" resourcekey="btnFilerArticlesResource1"><span>Filter</span></asp:LinkButton>
										</div>
									</div>
									<asp:HiddenField ID="hfAttendessFilterSettingsState" runat="server" Value="closed" />
								</asp:Panel>
								<asp:GridView ID="gvEventAttendess" runat="server" AllowPaging="True" AllowSorting="True" AutoGenerateColumns="False" CellPadding="0" GridLines="Horizontal" BorderWidth="0px" DataKeyNames="Id,ArticleID,RecurringID,EventUserID" DataSourceID="odsGetListOfAttendess" EnableModelValidation="True"
									OnRowCommand="gvEventAttendess_RowCommand" ShowFooter="True" OnPreRender="gvEventAttendess_PreRender" CssClass="grid_view_table eventmanager attendees" PageSize="10">
									<AlternatingRowStyle CssClass="row second" />
									<Columns>
										<asp:TemplateField>
											<FooterTemplate>
												<div class="arrow_icon">
												</div>
												<asp:LinkButton ID="ibFooterSelectAll" runat="server" CommandName="SelectAll" CssClass="silver_button" resourcekey="ibFooterSelectAll"><span>Select all</span></asp:LinkButton>
												<asp:LinkButton ID="ibFooterUnSelectAll" runat="server" CommandName="UnselectAll" CssClass="silver_button" resourcekey="ibFooterUnSelectAll"><span>Unselect all</span></asp:LinkButton>
												<div class="seperator">
												</div>
												<asp:DropDownList ID="ddlFotterActionForSelected" runat="server" AutoPostBack="true" OnSelectedIndexChanged="gvEventAttendessddlFotterAction_SelectedIndexChanged">
													<asp:ListItem resourcekey="liSelectAction" Value="-1" Text="Select action" />
													<asp:ListItem resourcekey="liDelete" Value="Delete" Text="Delete" />
													<asp:ListItem resourcekey="liApprove" Value="Approve" Text="Approve" />
													<asp:ListItem resourcekey="liUnapprove" Value="Unapprove" Text="Unapprove" />
												</asp:DropDownList>
												<asp:Button ID="ibFooterOK" runat="server" CssClass="run_action" resourcekey="ibFooterOKResource1" ValidationGroup="vgGVArticleListFutter" CausesValidation="true" OnClick="gvEventAttendessibFooterOK_Click" OnClientClick="return ShowValue();" />
												<div style="float: right; color: white; font-weight: bold; font-size: 12px; margin-top: 10px; margin-right: 10px;">
													<%#TotalCountListOfAttendess%>
												</div>
											</FooterTemplate>
											<ItemTemplate>
												<asp:HiddenField ID="hfMainArticleID" runat="server" Value='<%# Bind("ArticleID") %>' />
												<asp:HiddenField ID="hfMainRecurringID" runat="server" Value='<%# Bind("RecurringID") %>' />
												<asp:HiddenField ID="hfEventUserID" runat="server" Value='<%# Bind("EventUserID") %>' />
												<asp:CheckBox ID="cbSelectRow" runat="server" />
											</ItemTemplate>
											<FooterStyle CssClass="footer_actions" />
											<HeaderStyle CssClass="check_content" />
											<ItemStyle CssClass="check_content" />
										</asp:TemplateField>
										<asp:TemplateField HeaderText="Action">
											<ItemTemplate>
												<div class="clear_floated">
													<asp:HyperLink runat="server" ID="hlEditUser" resourcekey="hlEditUser" NavigateUrl='<%# createLinkForEditUser(Eval("ArticleID"),Eval("RecurringID"),Eval("EventUserID")) %>' Text="Edit user"></asp:HyperLink><br />
													<%--<asp:LinkButton ID="lblSendMessage" runat="server" Text="Send Message" CausesValidation="False" CommandArgument='<%# Eval("ArticleID") + ";" + Eval("RecurringID") %>' CommandName="SendMessage" ToolTip="Send Message" resourcekey="nema" /><br />--%>
													<%--<asp:LinkButton ID="lbEditThisArticle" runat="server" Text="Edit event" CausesValidation="False" CommandArgument='<%# Eval("ArticleID") + ";" + Eval("RecurringID") %>' CommandName="EditArticle" ToolTip="Edit event" resourcekey="nema" /><br />--%>
													<asp:LinkButton ID="lblDelateRegistration" resourcekey="lblDelateRegistration" runat="server" Text="Delete registration" CausesValidation="False" CommandArgument='<%# Container.DataItemIndex  %>' CommandName="DelateRegistration" ToolTip='<%#Localization.GetString("Delateregistration.Text", LocalResourceFile)%>' OnClientClick="return confirm('Are you sure you want to remove this attendee?');" />
												</div>
											</ItemTemplate>
											<HeaderStyle CssClass="actions" />
											<ItemStyle CssClass="actions" />
										</asp:TemplateField>
										<asp:TemplateField HeaderText="User" SortExpression="UserID">
											<ItemTemplate>
												<asp:Label ID="lblEventUserFullName" runat="server" Text='<%# GetUserFullName(Eval("FirstName"), Eval("LastName")) %>' ToolTip='<%#Localization.GetString("Userfullname.Text", LocalResourceFile)%>' /><br />
												<asp:Label ID="lblEventUserEmail" runat="server" Text='<%# Eval("Email") %>' ToolTip='<%#Localization.GetString("Usersemail.Text", LocalResourceFile)%>' /><br />
											</ItemTemplate>
											<HeaderStyle CssClass="author" />
											<ItemStyle CssClass="author" />
										</asp:TemplateField>
										<asp:TemplateField HeaderText="Qnt">
											<ItemTemplate>
												<asp:Label ID="lblQnt" resourcekey="lblQnt" runat="server" ToolTip='<%#Localization.GetString("Qnt.Text", LocalResourceFile)%>' Text='<%# Eval("NumberOfTickets")%>' />
											</ItemTemplate>
											<HeaderStyle CssClass="author" />
											<ItemStyle CssClass="author" HorizontalAlign="Center" />
										</asp:TemplateField>
										<asp:TemplateField HeaderText="Info" SortExpression="UserID">
											<ItemTemplate>
												<asp:Label ID="lblRegistrationDate" runat="server" Text='<%# GetRegistrationDate(Eval("CreatedOnDate")) %>' ToolTip='<%#Localization.GetString("Registrationdate.Text", LocalResourceFile)%>' /><br />
												<asp:Label ID="lblIsRecurring" runat="server" Text='<%# GetRecurringText(Eval("Recurring")) %>' ToolTip='<%#Localization.GetString("Isrecurringevent.Text", LocalResourceFile)%>' /><br />
												<asp:Label ID="lblRecurringID" runat="server" Text='<%# GetRecurringID(Eval("RecurringID")) %>' ToolTip='<%#Localization.GetString("RecurringID.Text", LocalResourceFile)%>' /><br />
												<div style="color: #0A85DC">
													<asp:Label ID="lblRegistrationID" runat="server" Text='<%# GetRegistrationID(Eval("RegistrationID"))%>' ToolTip='<%#Localization.GetString("RegistrationID.Text", LocalResourceFile)%>' />
												</div>
												<asp:Label ID="lblUserStatus" runat="server" Text='<%# GetUserStatus(Eval("UserStatus"),Eval("EventType")) %>' ToolTip='<%#Localization.GetString("RecurringID.Text", LocalResourceFile)%>' />
											</ItemTemplate>
											<HeaderStyle CssClass="author" />
											<ItemStyle CssClass="author" />
										</asp:TemplateField>
										<asp:TemplateField>
											<ItemTemplate>
												<asp:Label ID="lblFee" runat="server" Text='<%# GetFee(Eval("EventType")) %>' ToolTip='<%#Localization.GetString("Fee.Text", LocalResourceFile)%>'></asp:Label>
											</ItemTemplate>
											<HeaderStyle CssClass="stats" />
											<ItemStyle CssClass="stats" />
										</asp:TemplateField>
										<asp:TemplateField>
											<ItemTemplate>
												<asp:Panel runat="server" ID="pnlApproveAttende" Visible="true">
													<asp:LinkButton ID="lbApproveAttendee" runat="server" CommandArgument='<%# Container.DataItemIndex %>' CommandName="ApproveAttendee" CssClass="checkbox_action" OnClientClick="return confirm('Are you sure you want to approve/unapprove this attendee?');">
														<asp:Label runat="server" Text="Approved" CssClass='<%# GetIconClas(Eval("ApproveStatus")) %>' ID="lblArticleListApproved" resourcekey="lblArticleListApproved"></asp:Label>
													</asp:LinkButton>
													<asp:CheckBox runat="server" ID="cbApproved" Visible="false" Checked='<%# IsApproved(Eval("ApproveStatus")) %>'></asp:CheckBox>
													<div style="text-align: center">
														<asp:Literal ID="liMailVerified" runat="server" Text='<%# IsVerifyed(Eval("Verified")) %>'></asp:Literal>
														<asp:Literal ID="liAlreadyApprovedRegistration" runat="server" Visible='<%# IsAlreadyRejacted(Eval("ApproveStatus")) %>' Text="<%#alreadyRejected %>"></asp:Literal>
														<asp:LinkButton ID="lbRejectAttendee" resourcekey="lbRejectAttendee" runat="server" Visible='<%# !IsApproved(Eval("ApproveStatus")) %>' CommandArgument='<%# Container.DataItemIndex %>' CommandName="Reject" CssClass="checkbox_action" Text="Reject"></asp:LinkButton>
													</div>
												</asp:Panel>
												<asp:Panel runat="server" ID="pnlRejectMessage" Visible="false" Height="120px">
													<asp:Label ID="lblRejectMessage" resourcekey="lblRejectMessage" runat="server" Text="Explain why the attende was rejected:"></asp:Label><asp:TextBox ID="tbRejectMessage" runat="server" TextMode="MultiLine" Style="width: 650px; height: 40px; font: 12px Arial; line-height: 1.3;"></asp:TextBox>
													<p>
														<asp:LinkButton ID="lbRejectWMessage" resourcekey="lbRejectWMessage" CommandArgument='<%# Container.DataItemIndex %>' CommandName="RejectAttendee" runat="server" Font-Bold="True" Text="Reject" OnClientClick="return confirm('Are you sure you want to reject this attendee?');"> </asp:LinkButton>&nbsp;
														<asp:LinkButton ID="lbCancelRejectWMessage" resourcekey="lbCancelRejectWMessage" CommandName="Cancel" Font-Bold="True" runat="server" Text="Cancel"></asp:LinkButton>
													</p>
												</asp:Panel>
											</ItemTemplate>
											<HeaderStyle CssClass="stats" />
											<ItemStyle CssClass="stats" />
										</asp:TemplateField>
									</Columns>
									<EditRowStyle BackColor="#E2EDF4" />
									<HeaderStyle CssClass="header_row" />
									<PagerStyle CssClass="pagination" />
									<RowStyle CssClass="row" />
								</asp:GridView>
								<div class="nomber_of_rows_selection" style="margin-top: 5px; margin-bottom: 5px; float: right;">
									<asp:Label ID="lblFooterNumberOfRows" AssociatedControlID="gvEventAttendessNumberOfRows" runat="server" Text="Number of rows:" resourcekey="lblFooterNumberOfRows" />
									<asp:DropDownList ID="gvEventAttendessNumberOfRows" runat="server" OnSelectedIndexChanged="gvEventAttendessNumberOfRows_SelectedIndexChanged" AutoPostBack="True">
										<asp:ListItem resourcekey="ListItemResource40" Text="10" />
										<asp:ListItem resourcekey="ListItemResource41" Text="20" />
										<asp:ListItem resourcekey="ListItemResource42" Text="30" />
										<asp:ListItem resourcekey="ListItemResource43" Text="50" />
										<asp:ListItem resourcekey="ListItemResource44" Text="100" />
									</asp:DropDownList>
								</div>
								<asp:Panel ID="Panel10" runat="server" class="no_content_matched_filter" Visible="False">
									<asp:Literal ID="Literal1" runat="server" />
								</asp:Panel>
							</asp:Panel>
							<asp:Panel ID="pnlNoAttendees" CssClass="standalone_message" runat="server" Visible="False">
								<asp:Literal ID="liAttendeeInfo" runat="server" />
								<asp:HyperLink ID="HyperLink2" runat="server" CssClass="silver_button" resourcekey="hlAddNewArticleResource1"><span>Add an article</span></asp:HyperLink>
							</asp:Panel>
						</div>
					</asp:Panel>

					<asp:Panel ID="pnlUserData" runat="server" Visible="false" class="eventmanager">
						<div class="eventtitle"><%=eventRegistrationUserdata%></div>
						<table cellspacing="0" cellpadding="0" class="customfields-table" align="center">
							<tr>
								<td class="leftcol">
									<asp:Label ID="lblFirstName" resourcekey="lblFirstName" runat="server" Text="First name:" />
								</td>
								<td class="rightcol">
									<asp:TextBox ID="tbxFirstName" runat="server" ValidationGroup="vgUserData" MaxLength="50" CausesValidation="true"></asp:TextBox>
									<asp:RequiredFieldValidator ID="rfvFirstName" resourcekey="rfvFirstName.ErrorMessage" runat="server" ControlToValidate="tbxFirstName" ErrorMessage="Required!" ValidationGroup="vgUserData" Display="Dynamic" SetFocusOnError="True" />
								</td>
							</tr>
							<tr>
								<td class="leftcol">
									<asp:Label ID="lblLastName" resourcekey="lblLastName" runat="server" Text="Last name:" />
								</td>
								<td class="rightcol">
									<asp:TextBox ID="tbxLastName" runat="server" ValidationGroup="vgUserData" MaxLength="50" placeholder="Last name"></asp:TextBox>
									<asp:RequiredFieldValidator ID="rfvLastName" resourcekey="rfvLastName.ErrorMessage" runat="server" ControlToValidate="tbxLastName" ErrorMessage="Required!" ValidationGroup="vgUserData" Display="Dynamic" SetFocusOnError="True" />
								</td>
							</tr>
							<tr>
								<td class="leftcol">
									<asp:Label ID="lblEmail" resourcekey="lblEmail" runat="server" Text="E-mail:" />
								</td>
								<td class="rightcol">
									<asp:TextBox ID="tbxEmail" runat="server" ValidationGroup="vgUserData" MaxLength="256" placeholder="E-mail"></asp:TextBox>
									<asp:RequiredFieldValidator ID="rfvEmail" resourcekey="rfvEmail.ErrorMessage" runat="server" ControlToValidate="tbxEmail" ErrorMessage="Required!" ValidationGroup="vgUserData" Display="Dynamic" SetFocusOnError="True" />
									<asp:RegularExpressionValidator ID="revEmail" resourcekey="revEmail.ErrorMessage" runat="server" ControlToValidate="tbxEmail" Display="Dynamic" ErrorMessage="Please enter a valid email address." ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" ValidationGroup="vgUserData" SetFocusOnError="True" />
								</td>
							</tr>
							<tr runat="server" id="rowNumberOfTickets">
								<td class="leftcol">
									<asp:Label ID="lblNumberOfTickets" resourcekey="lblNumberOfTickets" runat="server" Text="Number of seats:" />
								</td>
								<td class="rightcol">
									<asp:TextBox ID="tbxNumberOfTickets" runat="server" MaxLength="4" placeholder="Number of tickets" Text="1"></asp:TextBox>
									<asp:RequiredFieldValidator ID="rfvNumberOfTickets" resourcekey="rfvNumberOfTickets.ErrorMessage" runat="server" ControlToValidate="tbxNumberOfTickets" ErrorMessage="Required!" ValidationGroup="vgUserData" Display="Dynamic" SetFocusOnError="True" />
									<asp:RangeValidator ID="rvNumberOfTickets" resourcekey="rvNumberOfTickets.ErrorMessage" runat="server" ControlToValidate="tbxNumberOfTickets" ErrorMessage="Value between" Type="Integer" SetFocusOnError="True" MaximumValue="5" MinimumValue="1" Display="Dynamic"></asp:RangeValidator>
								</td>
							</tr>
							<tr runat="server" id="rowuserStatus">
								<td class="leftcol">
									<asp:Label ID="lblUserStatus" resourcekey="lblUserStatus" runat="server" Text="Is user going:" />
								</td>
								<td class="rightcol">
									<asp:DropDownList ID="ddlIsUserGoing" runat="server">
										<asp:ListItem Value="1" resourcekey="liYes" Text="Yes" />
										<asp:ListItem Value="0" resourcekey="liNo" Text="No" />
										<asp:ListItem Value="2" resourcekey="liMaybe" Text="Maybe" />
									</asp:DropDownList>
								</td>
							</tr>
						</table>
						<div class="emanager">
							<asp:PlaceHolder ID="phCustomFields" runat="server" Visible="false">
								<asp:HiddenField runat="server" ID="hfParenSelectedValue" />
								<asp:HiddenField runat="server" ID="hfLastSelectedIndexChanged" />
								<asp:HiddenField runat="server" ID="hfCFLastTriggerdByList" />
								<asp:HiddenField runat="server" ID="hfPreviousCFTemplateID" />
							</asp:PlaceHolder>
						</div>

						<table cellspacing="0" cellpadding="0" class="customfields-table">
							<tr>
								<td class="leftcol">
									<asp:Label ID="lblMessage" resourcekey="lblMessage" runat="server" Text="Additional Information:" />
								</td>
								<td class="rightcol">
									<asp:TextBox ID="tbxMessage" runat="server" MaxLength="256" TextMode="MultiLine"></asp:TextBox>
								</td>
							</tr>
							<tr>
								<td>&nbsp;
								</td>
								<td>&nbsp;
								</td>
							</tr>
						</table>

						<table cellspacing="0" cellpadding="0">
							<tr>
								<td colspan="2">
									<asp:Label ID="lblregistrationUserDataUpdateInfo" runat="server" EnableViewState="false" />
								</td>
							</tr>
							<tr>
								<td align="center">
									<asp:Button ID="btnUpdateUserData" resourcekey="btnUpdateUserData" runat="server" Text="Update" OnClick="btnUpdateUserData_Click" ValidationGroup="vgUserData" />
									<asp:Button ID="btnCloseUserData" resourcekey="btnCloseUserData" runat="server" Text="Close" CausesValidation="false" OnClick="btnCloseUserData_Click" />
								</td>
							</tr>
						</table>
					</asp:Panel>

					<asp:Panel ID="pnlAddUserToEvent" runat="server" Visible="false">
						<asp:Literal ID="liRegistrationInfo" runat="server"></asp:Literal><br />
						<table cellspacing="0" cellpadding="0">
							<tr>
								<td class="leftcol">
									<dnn:Label ID="lblAddUsersFromRole" runat="server" Text="Add users from roles:" HelpText="With the help of this option members of DNN security roles can be added as attendees." />
								</td>
								<td class="rightcol">
									<asp:DropDownList ID="ddlAddUsersFromRole" runat="server"></asp:DropDownList>
									<asp:LinkButton ID="lbAddUsersFromRole" resourcekey="lbAddUsersFromRole" runat="server" OnClick="lbAddUsersFromRole_Click" Text="Add" />
								</td>
							</tr>
							<tr>
								<td></td>
								<td class="rightcol">
									<asp:GridView ID="gvAddusersFromRoles" runat="server" AutoGenerateColumns="false" CellPadding="0" CssClass="grid_view_table customfields" EnableModelValidation="True" GridLines="None" OnRowCommand="gvAddusersFromRoles_RowCommand" Width="350px">
										<AlternatingRowStyle CssClass="second" />
										<Columns>
											<asp:TemplateField HeaderText="Addusersfromroles">
												<ItemTemplate>
													<asp:HiddenField ID="hfRoleID" runat="server" Value='<%# Eval("RoleID") %>' />
													<asp:Label ID="lblRoleName" runat="server" Text='<%# Eval("RoleName") %>' />
												</ItemTemplate>
												<HeaderStyle CssClass="subject" />
												<ItemStyle CssClass="subject" />
											</asp:TemplateField>
											<asp:TemplateField>
												<ItemTemplate>
													<asp:LinkButton ID="lbRoleRemove" runat="server" CausesValidation="false" CommandArgument='<%# Eval("RoleID") %>' CommandName="Remove" OnClientClick="return confirm('Are you sure you want to remove this role?');" Text="Remove" resourcekey="lbRoleRemove"></asp:LinkButton>
												</ItemTemplate>
											</asp:TemplateField>
										</Columns>
										<HeaderStyle CssClass="header_row" />
									</asp:GridView>
								</td>
							</tr>
							<tr>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
							</tr>
							<tr>
								<td class="leftcol">
									<dnn:Label ID="lblSelectUserToAddToEvent" runat="server" Text="Add user:" HelpText="With the help of this option a DNN user can be added as an attendee. User name is necessary." />
								</td>
								<td class="rightcol">
									<asp:TextBox ID="tbxAddUserNameToEvent" runat="server"></asp:TextBox>
									<asp:LinkButton ID="lbAddUserNameToEvent" resourcekey="lbAddUserNameToEvent" runat="server" OnClick="lbAddUserNameToEvent_Click" Text="Add" />
								</td>
							</tr>

							<tr>
								<td class="leftcol"></td>
								<td class="rightcol">
									<asp:GridView ID="gvAddedUsersToEvent" runat="server" AutoGenerateColumns="false" CellPadding="0" CssClass="grid_view_table customfields" EnableModelValidation="True" GridLines="None" OnRowCommand="gvAddedUsersToEvent_RowCommand" Width="350">
										<AlternatingRowStyle CssClass="second" />
										<Columns>
											<asp:TemplateField HeaderText="Userstoadd">
												<ItemTemplate>
													<asp:HiddenField ID="hfUserID" runat="server" Value='<%# Eval("UserID") %>' />
													<asp:HiddenField ID="hfEmail" runat="server" Value='<%# Eval("Email") %>' />
													<asp:Label ID="lblUserName" runat="server" Text='<%# Eval("Name") %>' />
												</ItemTemplate>
												<HeaderStyle CssClass="subject" />
												<ItemStyle CssClass="subject" />
											</asp:TemplateField>
											<asp:TemplateField>
												<ItemTemplate>
													<asp:LinkButton ID="lbUserPremissionRemove" runat="server" CausesValidation="false" CommandArgument='<%# Eval("UserID") %>' CommandName="Remove" OnClientClick="return confirm('Are you sure you want to remove this user?');" Text="Remove" resourcekey="lbUserPremissionRemove"></asp:LinkButton>
												</ItemTemplate>
											</asp:TemplateField>
										</Columns>
										<HeaderStyle CssClass="header_row" />
									</asp:GridView>
								</td>
							</tr>
							<tr>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
							</tr>
							<tr>
								<td class="leftcol"></td>
								<td class="rightcol">
									<asp:Label ID="lblAddUsersToEventInfo" runat="server" EnableViewState="false" />
								</td>
							</tr>
							<tr>
								<td class="leftcol"></td>
								<td class="rightcol">
									<asp:Button ID="btnAddUsersToEvent" resourcekey="btnAddUsersToEvent" runat="server" Text="Add" OnClick="btnAddUsersToEvent_Click" ValidationGroup="vgAddUsersToEvent" />
									<asp:Button ID="btnCloseAddUsersToEvent" resourcekey="btnCloseAddUsersToEvent" runat="server" Text="Close" OnClick="btnCloseAddUsersToEvent_Click" />
								</td>
							</tr>
						</table>
					</asp:Panel>

					<asp:Panel ID="pnlPostSettings" runat="server" Visible="false">

						<asp:Panel ID="pnlAddPostSettings" runat="server" Visible="false" CssClass="settings_category_container">
							<table cellspacing="0" cellpadding="0" class="customfields-table" style="margin-top: 30px;">
								<tr>
									<td class="leftcol">
										<dnn:Label ID="lblEventPostName" runat="server" Text="Template name:" HelpText="Enter a name for a new invitation/reminder template." ControlName="tbxEventPostName" />
									</td>
									<td class="rightcol">
										<asp:TextBox ID="tbxEventPostName" runat="server" Width="450px"></asp:TextBox>
										<asp:RequiredFieldValidator ID="rfvEventPostName" resourcekey="rfvEventPostName.ErrorMessage" runat="server" ControlToValidate="tbxEventPostName" ErrorMessage="Required!" ValidationGroup="vgPostSettings" Display="Dynamic" SetFocusOnError="True" ForeColor="Red"></asp:RequiredFieldValidator>
									</td>
								</tr>
								<tr>
									<td class="leftcol">
										<dnn:Label ID="lblSendToDNNRole" runat="server" Text="Send to users in roles:" HelpText="Choose a security DNN role to which members the invitations/reminders will be sent. It is possible to add more DNN security roles." ControlName="ddlSendToDNNRole" />
									</td>
									<td class="rightcol">
										<asp:DropDownList ID="ddlSendToDNNRole" runat="server"></asp:DropDownList>
										<asp:LinkButton ID="lbSendToDNNRole" resourcekey="lbSendToDNNRole" runat="server" OnClick="lbRoleAdd_Click" Text="Add" />
									</td>
								</tr>
								<tr>
									<td></td>
									<td class="rightcol">
										<asp:GridView ID="gvSendToRoles" runat="server" AutoGenerateColumns="false" CellPadding="0" CssClass="grid_view_table customfields" EnableModelValidation="True" GridLines="None" OnRowCommand="gvSendToRoles_RowCommand" Width="350px">
											<AlternatingRowStyle CssClass="second" />
											<Columns>
												<asp:TemplateField HeaderText="Sendtorole">
													<ItemTemplate>
														<asp:HiddenField ID="hfRoleID" runat="server" Value='<%# Eval("RoleID") %>' />
														<asp:Label ID="lblRoleName" runat="server" Text='<%# Eval("RoleName") %>' />
													</ItemTemplate>
													<HeaderStyle CssClass="subject" />
													<ItemStyle CssClass="subject" />
												</asp:TemplateField>
												<asp:TemplateField>
													<ItemTemplate>
														<asp:LinkButton ID="lbRoleRemove" resourcekey="lbRoleRemove" runat="server" CausesValidation="false" CommandArgument='<%# Eval("RoleID") %>' CommandName="Remove" OnClientClick="return confirm('Are you sure you want to remove this role?');" Text="Remove"></asp:LinkButton>
													</ItemTemplate>
												</asp:TemplateField>
											</Columns>
											<HeaderStyle CssClass="header_row" />
										</asp:GridView>
									</td>
								</tr>
								<tr>
									<td class="leftcol">
										<dnn:Label ID="lblSendToUserName" runat="server" Text="Send to user" HelpText="Here you can choose a DNN user to whom the invitations/reminders will be sent." ControlName="tbxSendToUserName" />
									</td>
									<td class="rightcol">
										<asp:TextBox ID="tbxSendToUserName" runat="server"></asp:TextBox>
										<asp:LinkButton ID="lbUsernameAdd" resourcekey="lbUsernameAdd" runat="server" OnClick="lbUsernameAdd_Click" Text="Add" />
									</td>
								</tr>
								<tr>
									<td class="leftcol"></td>

									<td class="rightcol">
										<asp:GridView ID="gvSendToUsers" runat="server" AutoGenerateColumns="false" CellPadding="0" CssClass="grid_view_table customfields" EnableModelValidation="True" GridLines="None" OnRowCommand="gvSendToUsers_RowCommand" Width="350px">
											<AlternatingRowStyle CssClass="second" />
											<Columns>
												<asp:TemplateField HeaderText="Sendtousers" HeaderStyle-HorizontalAlign="Center">
													<ItemTemplate>
														<asp:Label ID="lblUserName" runat="server" Text='<%# Eval("Name") %>' />
														<asp:HiddenField ID="hfUserID" runat="server" Value='<%# Eval("UserID") %>' />
														<asp:HiddenField ID="hfEmail" runat="server" Value='<%# Eval("Email") %>' />
													</ItemTemplate>
													<ItemStyle CssClass="subject" />
												</asp:TemplateField>
												<asp:TemplateField>
													<ItemTemplate>
														<asp:LinkButton ID="lbUserPremissionRemove" resourcekey="lbUserPremissionRemove" runat="server" CausesValidation="false" CommandArgument='<%# Eval("UserID") %>' CommandName="Remove" OnClientClick="return confirm('Are you sure you want to remove this user?');" Text="Remove"></asp:LinkButton>
													</ItemTemplate>
												</asp:TemplateField>
											</Columns>
											<HeaderStyle CssClass="header_row" />
										</asp:GridView>
									</td>
								</tr>
								<tr style="display: none">
									<td class="leftcol">
										<dnn:Label ID="lblSendToEmail" runat="server" Text="Add e-mail:" HelpText="Add e-mail." ControlName="tbxSendToEmail" />
									</td>
									<td class="rightcol">
										<asp:TextBox ID="tbxSendToEmail" runat="server"></asp:TextBox>
										<asp:LinkButton ID="lbEmailAdd" resourcekey="lbEmailAdd" runat="server" OnClick="lbEmailAdd_Click" Text="Add" />
									</td>
								</tr>
								<tr style="display: none">
									<td colspan="2">
										<asp:GridView ID="gvSendToEmail" runat="server" AutoGenerateColumns="false" CellPadding="0" CssClass="permissions_table" EnableModelValidation="True" GridLines="None" OnRowCommand="gvSendToEmail_RowCommand">
											<AlternatingRowStyle CssClass="second" />
											<Columns>
												<asp:TemplateField HeaderText="Send to email/s:">
													<ItemTemplate>
														<asp:Label ID="lblEmail" runat="server" Text='<%# Eval("Email") %>' />
													</ItemTemplate>
													<HeaderStyle CssClass="subject" />
													<ItemStyle CssClass="subject" />
												</asp:TemplateField>
												<asp:TemplateField>
													<ItemTemplate>
														<asp:LinkButton ID="lbUserPremissionRemove" resourcekey="lbUserPremissionRemove" runat="server" CausesValidation="false" CommandArgument='<%# Eval("Email") %>' CommandName="Remove" OnClientClick="return confirm('Are you sure you want to remove this email?');" Text="Remove"></asp:LinkButton>
													</ItemTemplate>
												</asp:TemplateField>
											</Columns>
										</asp:GridView>
									</td>
								</tr>
								<tr runat="server" id="trSendToEventAttendees">
									<td class="leftcol">
										<dnn:Label ID="lblSendToEventAttendees" runat="server" Text="Send to event attendees:" HelpText="If this option is turned on then a reminder is sent to users who had registered to an event." ControlName="cbSendToEventAtendees" />
									</td>
									<td class="rightcol">
										<asp:CheckBox ID="cbSendToEventAtendees" runat="server" Checked="True" />
									</td>
								</tr>
								<tr>
									<td class="leftcol">
										<dnn:Label ID="lblEmailTemplateTheme" runat="server" Text="Predefined email template:" HelpText="Here you can choose a predefined theme for invitation/reminder email formatting." ControlName="ddlEmailTemplateTheme" />
									</td>
									<td class="rightcol">
										<asp:DropDownList ID="ddlEmailTemplateTheme" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlEmailTemplateTheme_SelectedIndexChanged"></asp:DropDownList>
										<%--   <dnn:Label ID="lblEmailTemplate" runat="server" Text="Template:" HelpText="Here you can choose a template for invitation/reminder email formatting." ResourceKey="nema" ControlName="ddlEmailTemplate" />--%>
										<asp:DropDownList ID="ddlEmailTemplate" runat="server"></asp:DropDownList>
										<asp:Button ID="btnEmailTemplate" resourcekey="btnEmailTemplate" runat="server" Text="Load" OnClick="btnEmailTemplate_Click" />
									</td>
								</tr>
								<tr>
									<td class="leftcol"></td>
									<td class="rightcol">
										<div runat="server" id="divCreateEmailTemplate" visible="false">
											<a id="toggleCreateEmail"><%#createEmailTemplate%></a>
											<%#fileName%>:<asp:TextBox ID="tbxTemplateName" runat="server"></asp:TextBox>
											<asp:Button ID="btnSaveEmailTemplate" resourcekey="btnSaveEmailTemplate" runat="server" Text="Save template to file" OnClick="btnSaveEmailTemplate_Click" ValidationGroup="vgSaveEmailTemplate" />
											<asp:Button ID="btnDeleteEmailTemplate" resourcekey="btnDeleteEmailTemplate" runat="server" Text="Delete selected template" OnClick="btnDeleteEmailTemplate_Click" ValidationGroup="vgSaveEmailTemplate" />
											<asp:Label ID="lblSaveEmailTemplateInfo" runat="server" EnableViewState="false"></asp:Label>
										</div>
									</td>
								</tr>
								<tr>
									<td class="leftcol">
										<dnn:Label ID="lblMailSubject" runat="server" Text="Email subject" HelpText="Enter a subject of invitation/reminder email." ControlName="tbxMailSubject" />
									</td>
									<td class="rightcol">
										<asp:TextBox ID="tbxMailSubject" runat="server" Width="450px"></asp:TextBox>
										<asp:RequiredFieldValidator ID="rfvMailSubject" resourcekey="rfvMailSubject.ErrorMessage" runat="server" ControlToValidate="tbxMailSubject" ErrorMessage="Required!" ValidationGroup="vgPostSettings" Display="Dynamic" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
									</td>
								</tr>
								<tr>
									<td class="leftcol">
										<dnn:Label ID="lblEmailTemplateContent" runat="server" Text="Email content:" HelpText="Here you can in details edit the message of invitation/reminder email." ControlName="tbxEmailTemplateContent" />
									</td>
									<td class="rightcol">
										<dnn:TextEditor ID="tbxEmailTemplateContent" runat="server" Height="450" Width="700" />

										<%--<asp:TextBox ID="tbxEmailTemplateContent" runat="server" TextMode="MultiLine" Width="600px" Height="400px"></asp:TextBox>--%>
									</td>
								</tr>
								<tr>
									<td class="leftcol">
										<dnn:Label ID="lblSendingTime" runat="server" Text="Sending options:" HelpText="If the option 'Instant' is chosen, then the invitation/reminder is sent immediately after adding an event. If the option 'Time' is chosen, then we can specify time in advance when to send the invitations/reminders for a holding event. Enter the number of days and hours before the start of the event when the invitation needs to be sent." ControlName="rblSendingTime" />
									</td>
									<td class="rightcol">
										<asp:RadioButtonList ID="rblSendingTime" runat="server" RepeatDirection="Horizontal" OnSelectedIndexChanged="rblSendingTime_SelectedIndexChanged" AutoPostBack="true">
											<asp:ListItem Value="0" resourcekey="liInstant" Text="Instant" Selected="True" />
											<asp:ListItem Value="1" resourcekey="liTime" Text="Time" />
										</asp:RadioButtonList>
										<div runat="server" id="divSendingTime" visible="false">
											<%#days%>
											<asp:TextBox ID="tbxSendingTimeDays" runat="server" Text="5" CssClass="interval" />
											<%#hours%>
											<asp:TextBox ID="tbxSendingTimeHours" runat="server" Text="0" CssClass="interval" />
											<%#minutes %>
											<asp:TextBox ID="tbxSendingTimeMinutes" runat="server" Text="0" CssClass="interval" />
										</div>
									</td>
								</tr>
								<tr>
									<td class="leftcol">
										<dnn:Label ID="lblPostSettingsActive" runat="server" Text="Active:" HelpText="If this option is turned on then this invitation/reminder template is active." ControlName="cblblPostSettingsActive" />
									</td>
									<td class="rightcol">
										<asp:CheckBox ID="cblblPostSettingsActive" runat="server" Checked="True" />
									</td>
								</tr>
								<tr>
									<td colspan="2">
										<asp:Label ID="lblSendInvitationsInfo" runat="server" EnableViewState="false" />
									</td>
								</tr>
								<tr>
									<td>&nbsp;</td>
									<td>&nbsp;</td>
								</tr>
								<tr>
									<td colspan="2" align="center">
										<asp:Button ID="btnAddPostSettings" resourcekey="btnAddPostSettings" runat="server" Text="Save" OnClick="btnAddPostSettings_Click" ValidationGroup="vgPostSettings" />
										<asp:HyperLink ID="btnCloseAddPostSettings" resourcekey="btnCloseAddPostSettings" runat="server" Text="Close" CssClass="link-button" />
									</td>
								</tr>
							</table>
						</asp:Panel>

						<asp:Panel ID="pnlPostSettingsList" runat="server" Visible="false">
							<asp:GridView ID="gvPostSettingsList" Width="1000px" runat="server" AllowPaging="True" AllowSorting="True" AutoGenerateColumns="False" CellPadding="0" GridLines="Horizontal" DataKeyNames="Id" DataSourceID="odsGetPostSettings" EnableModelValidation="True"
								OnPreRender="gvPostSettingsList_PreRender" CssClass="grid_view_table customfields">
								<AlternatingRowStyle CssClass="row second" />
								<Columns>
									<asp:TemplateField HeaderText="Action">
										<ItemTemplate>
											<div class="clear_floated">
												<asp:HyperLink runat="server" ID="hlEdit" resourcekey="hlEdit" NavigateUrl='<%# createLinkForEdit(Eval("Id"), Eval("PostType")) %>' Text="Edit"></asp:HyperLink>&nbsp;|&nbsp;
												<asp:LinkButton ID="lbDelete" resourcekey="lbDelete" runat="server" CausesValidation="False" CommandName="Delete" Text="Delete"></asp:LinkButton>
											</div>
										</ItemTemplate>
										<HeaderStyle CssClass="actions" />
										<ItemStyle CssClass="actions" />
									</asp:TemplateField>
									<asp:TemplateField HeaderText="Name">
										<ItemTemplate>
											<asp:Label ID="lblName" runat="server" Text='<%# Bind("Name") %>'></asp:Label>
										</ItemTemplate>
										<HeaderStyle CssClass="title" Width="280px" />
										<ItemStyle CssClass="title" />
									</asp:TemplateField>
									<asp:TemplateField HeaderText="Sendtype">
										<ItemTemplate>
											<asp:Label ID="lblSendType" runat="server" CssClass="icon blue" Text='<%# GetSendType(Eval("SendType"), Eval("SendIntervalValue"))%>' ToolTip='<%#Localization.GetString("Sendtype.Text", LocalResourceFile)%>' />
										</ItemTemplate>
										<HeaderStyle CssClass="dates" />
										<ItemStyle CssClass="dates" />
									</asp:TemplateField>
									<asp:TemplateField HeaderText="Status">
										<ItemTemplate>
											<asp:Label ID="lblStatus" runat="server" Text='<%# GetPostStatus(Eval("Finished"))%>' ToolTip='<%#Localization.GetString("Status.Text", LocalResourceFile)%>' />
										</ItemTemplate>
										<HeaderStyle CssClass="author" />
										<ItemStyle CssClass="author" />
									</asp:TemplateField>
									<asp:TemplateField HeaderText="Active">
										<ItemTemplate>
											<asp:Label ID="lblActive" runat="server" Text='<%# Eval("Active")%>' />
										</ItemTemplate>
										<HeaderStyle CssClass="author" />
										<ItemStyle CssClass="author" />
									</asp:TemplateField>
								</Columns>
								<EditRowStyle BackColor="#E2EDF4" />
								<HeaderStyle CssClass="header_row" />
								<PagerStyle CssClass="pagination" />
								<RowStyle CssClass="row" />
							</asp:GridView>

							<asp:HyperLink ID="hlAddNewPostSettings" runat="server" CssClass="link-button"></asp:HyperLink>

						</asp:Panel>

						<asp:Panel ID="pnlEmailSettings" Visible="false" class="module_settings" runat="server">

							<asp:Panel ID="pnlPostCategories" runat="server" CssClass="settings_category_container">
								<div class="category_toggle">
									<p class="section_number">
										1
									</p>
									<h2>
										<%=emailEventLinks%>
									</h2>
								</div>
								<table class="settings_table" cellpadding="0" cellspacing="0">
									<tr>
										<td class="left" style="width: 250px;">
											<dnn:Label ID="lblDefaultWhereToOpenContent" runat="server" Text="Module instance where links will be opened:" HelpText="Choose a module instance where the links from email will be opened (invitations, reminders and notifications)" ControlName="ddlDefaultWhereToOpenContent" />
										</td>
										<td class="right">
											<asp:DropDownList ID="ddlDefaultWhereToOpenContent" runat="server"></asp:DropDownList>
										</td>
									</tr>
								</table>
								<asp:PlaceHolder ID="pnlDinamicTreeView" runat="server"></asp:PlaceHolder>
							</asp:Panel>

							<asp:Panel ID="pnlEmailNotificationTemplates" runat="server" CssClass="settings_category_container">
								<div class="category_toggle">
									<p class="section_number">
										2
									</p>
									<h2>
										<%=emailNotificationTemplates%>
									</h2>
								</div>
								<table class="settings_table" cellpadding="0" cellspacing="0">
									<tr class="subheader">
										<td></td>
										<td>
											<h4 class="subsections"><%=approvalNeeded%></h4>
										</td>
									</tr>
									<tr class="second">
										<td class="left">
											<dnn:Label ID="lblapprovalNeededMailSubject" runat="server" Text="Subject:" HelpText="Here you can enter a subject of email notification which is sent when an approval is needed." ControlName="tbxapprovalNeededMailSubject" />
										</td>
										<td class="right">
											<asp:TextBox ID="tbxapprovalNeededMailSubject" runat="server" Width="600px" placeholder="e.g. Awaiting registration approval for [event title]..."></asp:TextBox>
											<asp:RequiredFieldValidator ID="rfvapprovalNeededMailSubject" resource="rfvapprovalNeededMailSubject.ErrorMessage" runat="server" ErrorMessage="Required!" ControlToValidate="tbxapprovalNeededMailSubject" Display="Dynamic" ValidationGroup="vgEmailSettings" SetFocusOnError="True" ForeColor="Red"></asp:RequiredFieldValidator>
										</td>
									</tr>
									<tr>
										<td class="left">
											<dnn:Label ID="lblapprovalNeededEmailTemplateTheme" runat="server" Text="Predefined email template:" HelpText="Select a theme for the content formatting of email notification which is sent when an approval is needed." ControlName="ddlapprovalNeededEmailTemplateTheme" />
										</td>
										<td class="right">
											<asp:DropDownList ID="ddlapprovalNeededEmailTemplateTheme" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlapprovalNeededEmailTemplateTheme_SelectedIndexChanged"></asp:DropDownList>
											<asp:DropDownList ID="ddlapprovalNeededEmailTemplate" runat="server"></asp:DropDownList>
											<asp:Button ID="btnapprovalNeededEmailTemplate" resourcekey="btnapprovalNeededEmailTemplate" runat="server" Text="Load" OnClick="btnapprovalNeededEmailTemplate_Click" Width="100px" />
										</td>
									</tr>
									<tr class="second">
										<td class="left">
											<%--											<dnn:Label ID="lblapprovalNeededEmailTemplate" runat="server" Text="Template:" HelpText="Select a template for the content formatting of email notification which is sent when an approval is needed." ResourceKey="nema" ControlName="ddlapprovalNeededEmailTemplate" />--%>
										</td>
										<td class="right"></td>
									</tr>
									<tr>
										<td class="left">
											<dnn:Label ID="lblapprovalNeededEmailTemplateContent" runat="server" Text="Email content:" HelpText="Here you can in details edit the message of email notification which is sent when an approval is needed." ControlName="tbxapprovalNeededEmailTemplateContent" />
										</td>
										<td class="right">
											<dnn:TextEditor ID="tbxapprovalNeededEmailTemplateContent" runat="server" Height="450" Width="700" />
											<%--<asp:TextBox ID="tbxapprovalNeededEmailTemplateContent" runat="server" TextMode="MultiLine" Width="600px" Height="400px"></asp:TextBox>--%>
										</td>
									</tr>
								</table>
								<table class="settings_table" cellpadding="0" cellspacing="0">
									<tr class="subheader">
										<td></td>
										<td>
											<h4 class="subsections"><%=newEventRegistration%></h4>
										</td>
									</tr>
									<tr class="second">
										<td class="left">
											<dnn:Label ID="lblnewEventRegistrationMailSubject" runat="server" Text="Subject:" HelpText="Here you can enter a subject of email notification which is sent after a new registration." ControlName="tbxnewEventRegistrationMailSubject" />
										</td>
										<td class="right">
											<asp:TextBox ID="tbxnewEventRegistrationMailSubject" runat="server" Width="600px"></asp:TextBox>
											<asp:RequiredFieldValidator ID="rfvnewEventRegistrationMailSubject" resoucekey="rfvnewEventRegistrationMailSubject.ErrorMessage" runat="server" ErrorMessage="Required!" ControlToValidate="tbxnewEventRegistrationMailSubject" Display="Dynamic" ValidationGroup="vgEmailSettings" SetFocusOnError="True" ForeColor="Red"></asp:RequiredFieldValidator>
										</td>
									</tr>
									<tr>
										<td class="left">
											<dnn:Label ID="lblnewEventRegistrationEmailTemplateTheme" runat="server" Text="Predefined email template:" HelpText="Select a theme for the formatting email notification which is sent after a new registration." ControlName="ddlnewEventRegistrationEmailTemplateTheme" />
										</td>
										<td class="right">
											<asp:DropDownList ID="ddlnewEventRegistrationEmailTemplateTheme" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlnewEventRegistrationEmailTemplateTheme_SelectedIndexChanged"></asp:DropDownList>
											<asp:DropDownList ID="ddlnewEventRegistrationEmailTemplate" runat="server"></asp:DropDownList>
											<asp:Button ID="btnnewEventRegistrationEmailTemplate" resourcekey="btnnewEventRegistrationEmailTemplate" runat="server" Text="Load" OnClick="btnnewEventRegistrationEmailTemplate_Click" Width="100px" />
										</td>
									</tr>
									<tr class="second">
										<td class="left">
											<%--											<dnn:Label ID="lblnewEventRegistrationEmailTemplate" runat="server" Text="Template:" HelpText="Select a template for the formatting email notification which is sent after a new registration." ResourceKey="nema" ControlName="ddlnewEventRegistrationEmailTemplate" />--%>
										</td>
										<td class="right"></td>
									</tr>
									<tr>
										<td class="left">
											<dnn:Label ID="lblnewEventRegistrationEmailTemplateContent" runat="server" Text="Email content:" HelpText="Here you can in details edit the message of email notification which is sent after a new registration." ControlName="tbxnewEventRegistrationEmailTemplateContent" />
										</td>
										<td class="right">
											<dnn:TextEditor ID="tbxnewEventRegistrationEmailTemplateContent" runat="server" Height="450" Width="700" />
											<%--	<asp:TextBox ID="tbxnewEventRegistrationEmailTemplateContent" runat="server" TextMode="MultiLine" Width="600px" Height="400px"></asp:TextBox>--%>
										</td>
									</tr>
								</table>
								<table class="settings_table" cellpadding="0" cellspacing="0">
									<tr class="subheader">
										<td></td>
										<td>
											<h4 class="subsections"><%=verifyingRegistrationForUnregisteredUsers%></h4>
										</td>
									</tr>
									<tr class="second">
										<td class="left">
											<dnn:Label ID="lblverifyingRegistrationForUnregisteredUsersMailSubject" runat="server" Text="Subject:" HelpText="Here you can enter a subject of email notification which is sent when a registration is waiting for an approval." ControlName="tbxverifyingRegistrationForUnregisteredUsersMailSubject" />
										</td>
										<td class="right">
											<asp:TextBox ID="tbxverifyingRegistrationForUnregisteredUsersMailSubject" runat="server" Width="600px"></asp:TextBox>
											<asp:RequiredFieldValidator ID="rfvverifyingRegistrationForUnregisteredUsersMailSubject" resourcekey="rfvverifyingRegistrationForUnregisteredUsersMailSubject.ErrorMessage" runat="server" ErrorMessage="Required!" ControlToValidate="tbxverifyingRegistrationForUnregisteredUsersMailSubject" Display="Dynamic" ValidationGroup="vgEmailSettings" SetFocusOnError="True" ForeColor="Red"></asp:RequiredFieldValidator>
										</td>
									</tr>
									<tr>
										<td class="left">
											<dnn:Label ID="lblverifyingRegistrationForUnregisteredUsersEmailTemplateTheme" runat="server" Text="Predefined email template:" HelpText="Select a theme for the formatting email notification which is sent when a registration is waiting for an approval." ControlName="ddlverifyingRegistrationForUnregisteredUsersEmailTemplateTheme" />
										</td>
										<td class="right">
											<asp:DropDownList ID="ddlverifyingRegistrationForUnregisteredUsersEmailTemplateTheme" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlverifyingRegistrationForUnregisteredUsersEmailTemplateTheme_SelectedIndexChanged"></asp:DropDownList>
											<asp:DropDownList ID="ddlverifyingRegistrationForUnregisteredUsersEmailTemplate" runat="server"></asp:DropDownList>
											<asp:Button ID="btnverifyingRegistrationForUnregisteredUsersEmailTemplate" resourcekey="btnverifyingRegistrationForUnregisteredUsersEmailTemplate" runat="server" Text="Load" OnClick="btnverifyingRegistrationForUnregisteredUsersEmailTemplate_Click" Width="100px" />
										</td>
									</tr>
									<tr class="second">
										<td class="left">
											<%--											<dnn:Label ID="lblverifyingRegistrationForUnregisteredUsersEmailTemplate" runat="server" Text="Template:" HelpText="Select a template for formatting email notification which is sent when a registration is waiting for an approval." ResourceKey="nema" ControlName="ddlverifyingRegistrationForUnregisteredUsersEmailTemplate" />--%>
										</td>
										<td class="right"></td>
									</tr>
									<tr>
										<td class="left">
											<dnn:Label ID="lblverifyingRegistrationForUnregisteredUsersEmailTemplateContent" runat="server" Text="Email content:" HelpText="Here you can in details edit the message of email notification which is sent when a registration is waiting for an approval." ControlName="tbxverifyingRegistrationForUnregisteredUsersEmailTemplateContent" />
										</td>
										<td class="right">
											<dnn:TextEditor ID="tbxverifyingRegistrationForUnregisteredUsersEmailTemplateContent" runat="server" Height="450" Width="700" />
											<%--<asp:TextBox ID="tbxverifyingRegistrationForUnregisteredUsersEmailTemplateContent" runat="server" TextMode="MultiLine" Width="600px" Height="400px"></asp:TextBox>--%>
										</td>
									</tr>
								</table>
								<table class="settings_table" cellpadding="0" cellspacing="0">
									<tr class="subheader">
										<td></td>
										<td>
											<h4 class="subsections"><%=awaitingRegistrationApproval%></h4>
										</td>
									</tr>
									<tr class="second">
										<td class="left">
											<dnn:Label ID="lblAwaitingRegistrationApprovalMailSubject" runat="server" Text="Subject:" HelpText="Enter a subject of email notification which is sent when a registration is rejected." ControlName="tbxAwaitingRegistrationApprovalMailSubject" />
										</td>
										<td class="right">
											<asp:TextBox ID="tbxAwaitingRegistrationApprovalMailSubject" runat="server" Width="600px"></asp:TextBox>
											<asp:RequiredFieldValidator ID="rfvAwaitingRegistrationApprovalMailSubject" resourcekey="rfvAwaitingRegistrationApprovalMailSubject.ErrorMessage" runat="server" ErrorMessage="Required!" ControlToValidate="tbxAwaitingRegistrationApprovalMailSubject" Display="Dynamic" ValidationGroup="vgEmailSettings" SetFocusOnError="True" ForeColor="Red"></asp:RequiredFieldValidator>
										</td>
									</tr>
									<tr>
										<td class="left">
											<dnn:Label ID="lblAwaitingRegistrationApprovalEmailTemplateTheme" runat="server" Text="Predefined email template:" HelpText="Select a theme for formatting email notification which is sent when a registration is rejected." ControlName="ddlAwaitingRegistrationApprovalEmailTemplateTheme" />
										</td>
										<td class="right">
											<asp:DropDownList ID="ddlAwaitingRegistrationApprovalEmailTemplateTheme" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlAwaitingRegistrationApprovalEmailTemplateTheme_SelectedIndexChanged"></asp:DropDownList>
											<asp:DropDownList ID="ddlAwaitingRegistrationApprovalEmailTemplate" runat="server"></asp:DropDownList>
											<asp:Button ID="btnAwaitingRegistrationApprovalEmailTemplate" resourcekey="btnAwaitingRegistrationApprovalEmailTemplate" runat="server" Text="Load" OnClick="btnAwaitingRegistrationApprovalEmailTemplate_Click" Width="100px" />
										</td>
									</tr>
									<tr class="second">
										<td class="left">
											<%--											<dnn:Label ID="lblAwaitingRegistrationApprovalEmailTemplate" runat="server" Text="Template:" HelpText="Select a template for formatting email notification which is sent when a registration is rejected." ResourceKey="nema" ControlName="ddlAwaitingRegistrationApprovalEmailTemplate" />--%>
										</td>
										<td class="right"></td>
									</tr>
									<tr>
										<td class="left">
											<dnn:Label ID="lblAwaitingRegistrationApprovalEmailTemplateContent" runat="server" Text="Email content:" HelpText="Here you can in details edit the message of notification email which is sent when a registration is rejected." ControlName="tbxAwaitingRegistrationApprovalEmailTemplateContent" />
										</td>
										<td class="right">
											<dnn:TextEditor ID="tbxAwaitingRegistrationApprovalEmailTemplateContent" runat="server" Height="450" Width="700" />
											<%--<asp:TextBox ID="tbxAwaitingRegistrationApprovalEmailTemplateContent" runat="server" TextMode="MultiLine" Width="600px" Height="400px"></asp:TextBox>--%>
										</td>
									</tr>
								</table>
								<table class="settings_table" cellpadding="0" cellspacing="0">
									<tr class="subheader">
										<td></td>
										<td>
											<h4 class="subsections"><%=rejectRegistration%></h4>
										</td>
									</tr>
									<tr class="second">
										<td class="left">
											<dnn:Label ID="lblrejectRegistrationMailSubject" runat="server" Text="Subject:" HelpText="Enter a subject of email notification which is sent when a registration is rejected." ControlName="tbxrejectRegistrationMailSubject" />
										</td>
										<td class="right">
											<asp:TextBox ID="tbxrejectRegistrationMailSubject" runat="server" Width="600px"></asp:TextBox>
											<asp:RequiredFieldValidator ID="rfvrejectRegistrationMailSubject" resourcekey="rfvrejectRegistrationMailSubject.ErrorMessage" runat="server" ErrorMessage="Required!" ControlToValidate="tbxrejectRegistrationMailSubject" Display="Dynamic" ValidationGroup="vgEmailSettings" SetFocusOnError="True" ForeColor="Red"></asp:RequiredFieldValidator>
										</td>
									</tr>
									<tr>
										<td class="left">
											<dnn:Label ID="lblrejectRegistrationEmailTemplateTheme" runat="server" Text="Predefined email template:" HelpText="Select a theme for formatting email notification which is sent when a registration is rejected." ControlName="ddlrejectRegistrationEmailTemplateTheme" />
										</td>
										<td class="right">
											<asp:DropDownList ID="ddlrejectRegistrationEmailTemplateTheme" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlrejectRegistrationEmailTemplateTheme_SelectedIndexChanged"></asp:DropDownList>
											<asp:DropDownList ID="ddlrejectRegistrationEmailTemplate" runat="server"></asp:DropDownList>
											<asp:Button ID="btnrejectRegistrationEmailTemplate" resourcekey="btnrejectRegistrationEmailTemplate" runat="server" Text="Load" OnClick="btnrejectRegistrationEmailTemplate_Click" Width="100px" />
										</td>
									</tr>
									<tr class="second">
										<td class="left">
											<%--											<dnn:Label ID="lblrejectRegistrationEmailTemplate" runat="server" Text="Template:" HelpText="Select a template for formatting email notification which is sent when a registration is rejected." ResourceKey="nema" ControlName="ddlrejectRegistrationEmailTemplate" />--%>
										</td>
										<td class="right"></td>
									</tr>
									<tr>
										<td class="left">
											<dnn:Label ID="lblrejectRegistrationEmailTemplateContent" runat="server" Text="Email content:" HelpText="Here you can in details edit the message of notification email which is sent when a registration is rejected." ControlName="tbxrejectRegistrationEmailTemplateContent" />
										</td>
										<td class="right">
											<dnn:TextEditor ID="tbxrejectRegistrationEmailTemplateContent" runat="server" Height="450" Width="700" />
											<%--<asp:TextBox ID="tbxrejectRegistrationEmailTemplateContent" runat="server" TextMode="MultiLine" Width="600px" Height="400px"></asp:TextBox>--%>
										</td>
									</tr>
								</table>
								<table class="settings_table" cellpadding="0" cellspacing="0">
									<tr class="subheader">
										<td></td>
										<td>
											<h4 class="subsections"><%=confirmRegistration%></h4>
										</td>
									</tr>
									<tr class="second">
										<td class="left">
											<dnn:Label ID="lblconfirmRegistrationMailSubject" runat="server" Text="Subject:" HelpText="Enter a subject of email notification which is sent after a successful registration." ControlName="tbxconfirmRegistrationMailSubject" />
										</td>
										<td class="right">
											<asp:TextBox ID="tbxconfirmRegistrationMailSubject" runat="server" Width="600px"></asp:TextBox>
											<asp:RequiredFieldValidator ID="rfvconfirmRegistrationMailSubject" resourcekey="rfvconfirmRegistrationMailSubject.ErrorMessage" runat="server" ErrorMessage="Required!" ControlToValidate="tbxconfirmRegistrationMailSubject" Display="Dynamic" ValidationGroup="vgEmailSettings" SetFocusOnError="True" ForeColor="Red"></asp:RequiredFieldValidator>
										</td>
									</tr>
									<tr>
										<td class="left">
											<dnn:Label ID="lblconfirmRegistrationEmailTemplateTheme" runat="server" Text="Predefined email template:" HelpText="Select a theme for formatting email notification which is sent after a successful registration." ControlName="ddlconfirmRegistrationEmailTemplateTheme" />
										</td>
										<td class="right">
											<asp:DropDownList ID="ddlconfirmRegistrationEmailTemplateTheme" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlconfirmRegistrationEmailTemplateTheme_SelectedIndexChanged"></asp:DropDownList>
											<asp:DropDownList ID="ddlconfirmRegistrationEmailTemplate" runat="server"></asp:DropDownList>
											<asp:Button ID="btnconfirmRegistrationEmailTemplate" resourcekey="btnconfirmRegistrationEmailTemplate" runat="server" Text="Load" OnClick="btnconfirmRegistrationEmailTemplate_Click" Width="100px" />
										</td>
									</tr>
									<tr class="second">
										<td class="left">
											<%--											<dnn:Label ID="lblconfirmRegistrationEmailTemplate" runat="server" Text="Template:" HelpText="Select a theme for formatting email notification which is sent after a successful registration." ResourceKey="nema" ControlName="ddlconfirmRegistrationEmailTemplate" />--%>
										</td>
										<td class="right"></td>
									</tr>
									<tr>
										<td class="left">
											<dnn:Label ID="lblconfirmRegistrationEmailTemplateContent" runat="server" Text="Email content:" HelpText="Here you can in details edit the message of notification email which is sent after successful registration." ControlName="tbxconfirmRegistrationEmailTemplateContent" />
										</td>
										<td class="right">
											<dnn:TextEditor ID="tbxconfirmRegistrationEmailTemplateContent" runat="server" Height="450" Width="700" />
											<%--<asp:TextBox ID="tbxconfirmRegistrationEmailTemplateContent" runat="server" TextMode="MultiLine" Width="600px" Height="400px"></asp:TextBox>--%>
										</td>
									</tr>
								</table>
							</asp:Panel>

							<asp:Panel ID="pnlSendEmailSettings" runat="server" CssClass="settings_category_container">
								<div class="category_toggle">
									<p class="section_number">
										3
									</p>
									<h2>
										<%=emailSettings%>
									</h2>
								</div>
								<table class="settings_table" cellpadding="0" cellspacing="0">
									<tr class="second">
										<td class="left">
											<dnn:Label ID="lblDefaultFromName" runat="server" Text="From name" HelpText="Enter a name which will be on your outgoing emails." ControlName="tbxDefaultFromName" />
										</td>
										<td class="right">
											<asp:TextBox ID="tbxDefaultFromName" runat="server" Width="450px"></asp:TextBox>
											<asp:RequiredFieldValidator ID="rfvDefaultFromName" resourcekey="rfvDefaultFromName.ErrorMessage" runat="server" ErrorMessage="Required!" ControlToValidate="tbxDefaultFromName" Display="Dynamic" ValidationGroup="vgEmailSettings" SetFocusOnError="True" ForeColor="Red"></asp:RequiredFieldValidator>
										</td>
									</tr>
									<tr>
										<td class="left">
											<dnn:Label ID="lblDefaultFromMail" runat="server" Text="From email:" HelpText="Enter your outgoing email." ControlName="tbxDefaultFromMail" />
										</td>
										<td class="right">
											<asp:TextBox ID="tbxDefaultFromMail" runat="server" Width="450px"></asp:TextBox>
											<asp:RequiredFieldValidator ID="rfvDefaultFromMail" resourcekey="rfvDefaultFromMail.ErrorMessage" runat="server" ErrorMessage="Required!" ControlToValidate="tbxDefaultFromMail" Display="Dynamic" ValidationGroup="vgEmailSettings" SetFocusOnError="True" ForeColor="Red"></asp:RequiredFieldValidator>
										</td>
									</tr>
									<tr class="second">
										<td class="left">
											<dnn:Label ID="lblDefaultReplyTo" runat="server" Text="Replay to:" HelpText="Enter a replay email here, if it is different from outgoing email." ControlName="tbxDefaultReplyTo" />
										</td>
										<td class="right">
											<asp:TextBox ID="tbxDefaultReplyTo" runat="server" Width="450px"></asp:TextBox>
											<asp:RequiredFieldValidator ID="rfvDefaultReplyTo" runat="server" ErrorMessage="Required!" ControlToValidate="tbxDefaultReplyTo" Display="Dynamic" ValidationGroup="vgEmailSettings" SetFocusOnError="True" ForeColor="Red"></asp:RequiredFieldValidator>
										</td>
									</tr>
								</table>
							</asp:Panel>

							<asp:Panel ID="pnlEmailLog" runat="server" CssClass="settings_category_container" Visible="false">
								<div class="category_toggle">
									<p class="section_number">
										4
									</p>
									<h2>
										<%=emailLog%>
									</h2>
								</div>
								<table class="settings_table" cellpadding="0" cellspacing="0">
									<tr>
										<td class="left">
											<dnn:Label ID="lblEnableLogFile" runat="server" Text="Enable log file:" HelpText="Enable log file." ResourceKey="nema" ControlName="cbEnableLogFile" />
										</td>
										<td class="right">
											<asp:CheckBox ID="cbEnableLogFile" runat="server" Width="450px" Checked="false"></asp:CheckBox>
										</td>
									</tr>
								</table>
							</asp:Panel>

							<div class="module_settings">
								<div class="main_actions">
									<div class="buttons">
										<asp:Button ID="btnSaveEmailSettings" resourcekey="btnSaveEmailSettings" runat="server" Text="Save settings" OnClick="btnSaveEmailSettings_Click" ValidationGroup="vgEmailSettings" CausesValidation="true" />
									</div>
								</div>
							</div>

							<asp:Label ID="lblEmailSettingsInfo" runat="server" EnableViewState="false" />

						</asp:Panel>

					</asp:Panel>

				</ContentTemplate>
			</asp:UpdatePanel>

		</div>
	</div>
</asp:Panel>
<asp:Literal ID="generatedHtm" runat="server" Visible="False" />
<script type="text/javascript">
	// <![CDATA[

	function ddlOnSelectedIndexChange(ControlClientID, cfid) {
		if (document.getElementById('<%=hfParenSelectedValue.ClientID%>') != null) {
			var e = document.getElementById(ControlClientID);
			var ParentElementID = e.options[e.selectedIndex].value;
			var hfValue = document.getElementById('<%=hfParenSelectedValue.ClientID%>').value;
    		if (hfValue.length != 0) {
    			var indexOd = hfValue.indexOf(ControlClientID + ';')
    			if (indexOd != -1) {
    				var pocetak = hfValue.substring(indexOd + ControlClientID.length + 1); // cut
    				var indexOdBroja = pocetak.indexOf('|');
    				var kraj = pocetak.substring(0, indexOdBroja);
    				hfValue = hfValue.replace(ControlClientID + ';' + kraj + '|', ''); // remove existing value
    			}
    			document.getElementById('<%=hfParenSelectedValue.ClientID%>').value = hfValue + ControlClientID + ';' + ParentElementID + '|';
	        	document.getElementById('<%=hfLastSelectedIndexChanged.ClientID%>').value = cfid;
	        }
	        else {
	        	document.getElementById('<%=hfParenSelectedValue.ClientID%>').value = ControlClientID + ';' + ParentElementID + '|';
	        	document.getElementById('<%=hfLastSelectedIndexChanged.ClientID%>').value = cfid;
	        }
		}
	}

	function cblOnSelectedIndexChange(ControlClientID, cfid) {
		if (document.getElementById('<%=hfParenSelectedValue.ClientID%>') != null) {
			var chkBox = document.getElementById(ControlClientID);
			var options = chkBox.getElementsByTagName('input');
			var checkedValues = '';
			for (var i = 0; i < options.length; i++) {
				if (options[i].checked) {
					checkedValues += options[i].value + ',';
				}
			}
			if (checkedValues.length > 0) {
				checkedValues = checkedValues.substring(0, checkedValues.length - 1);
				var hfValue = document.getElementById('<%=hfParenSelectedValue.ClientID%>').value;
    			if (hfValue.length != 0) {
    				var indexOd = hfValue.indexOf(ControlClientID + ';')
    				if (indexOd != -1) {
    					var pocetak = hfValue.substring(indexOd + ControlClientID.length + 1); // cut
    					var indexOdBroja = pocetak.indexOf('|');
    					var kraj = pocetak.substring(0, indexOdBroja);
    					hfValue = hfValue.replace(ControlClientID + ';' + kraj + '|', ''); // remove existing value
    				}
    				document.getElementById('<%=hfParenSelectedValue.ClientID%>').value = hfValue + ControlClientID + ';' + checkedValues + '|';
	            	document.getElementById('<%=hfLastSelectedIndexChanged.ClientID%>').value = cfid;
	            }
	            else {
	            	document.getElementById('<%=hfParenSelectedValue.ClientID%>').value = ControlClientID + ';' + checkedValues + '|';
	            	document.getElementById('<%=hfLastSelectedIndexChanged.ClientID%>').value = cfid;
	            }
			}
			else {
				var hfValue = document.getElementById('<%=hfParenSelectedValue.ClientID%>').value;
    			if (hfValue.length != 0) {
    				var indexOd = hfValue.indexOf(ControlClientID + ';')
    				if (indexOd != -1) {
    					var pocetak = hfValue.substring(indexOd + ControlClientID.length + 1); // cut
    					var indexOdBroja = pocetak.indexOf('|');
    					var kraj = pocetak.substring(0, indexOdBroja);
    					hfValue = hfValue.replace(ControlClientID + ';' + kraj + '|', ''); // remove existing value
    					document.getElementById('<%=hfParenSelectedValue.ClientID%>').value = hfValue
	        			document.getElementById('<%=hfLastSelectedIndexChanged.ClientID%>').value = cfid;
	        		}
				}
			}
		}
	}

	if ('<%=jQuery%>' == 'jQuery') {
		jQuery.noConflict();
	}
	function ShowValue() {
		var dropdownList;

		jQuery("#<%=gvArticleList.ClientID %> select[id*='ddlFotterActionForSelectedApprove']").each(function (index) {
			dropdownList = jQuery(this);
		});

		if (dropdownList.val() == '-1') {
			alert('<%=selectAction%>');
        }
        else {
        	return confirm('<%=confirmation%>');
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

		$('#<%=upMainAjax.ClientID%>').delegate('#<%=hlAttendessFilterToggle.ClientID %>', 'click', function () {
			var toggle = $(this),
			filter_settings = $('#<%=pnlAttendessFilterSettings.ClientID %>'),
			filter_settings_state = $('#<%=hfAttendessFilterSettingsState.ClientID %>');

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


	$('#<%=tbxFilterStartDate.ClientID%>').datepick({ dateFormat: "<%=dateFormat%>" });

	function pageLoad(sender, args) {
		if (args.get_isPartialLoad()) {
			$('#<%=tbxFilterStartDate.ClientID%>').datepick({ dateFormat: "<%=dateFormat%>" });
		}
	}
	// ]]>
</script>
<asp:ObjectDataSource ID="odsGetPagedArticlesByUser" runat="server" SelectMethod="GetEventsWithRegistration" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.EventsDataDB" EnablePaging="True" MaximumRowsParameterName="numberOfPostsperPage" SelectCountMethod="GetEventsWithRegistrationCount"
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
		<asp:Parameter Name="StartDate" Type="DateTime" />
		<asp:Parameter Name="startingArticle" Type="Int32" />
		<asp:Parameter Name="numberOfPostsperPage" Type="Int32" />
	</SelectParameters>
</asp:ObjectDataSource>
<asp:ObjectDataSource ID="odsGetPostSettings" runat="server" SelectMethod="GetPostSettings" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.EventsDataDB" EnablePaging="True" MaximumRowsParameterName="numberOfPostsperPage" SelectCountMethod="GetPostSettingsCount"
	StartRowIndexParameterName="startingArticle" OnSelecting="odsGetPostSettings_Selecting" OnSelected="odsGetPostSettings_Selected" DeleteMethod="DeleteEventPostSetting">
	<DeleteParameters>
		<asp:Parameter Name="Id" Type="Int32" />
	</DeleteParameters>
	<SelectParameters>
		<asp:Parameter Name="PortalID" Type="Int32" />
		<asp:Parameter Name="ArticleID" Type="Int32" />
		<asp:Parameter Name="RecurringID" Type="Int32" />
		<asp:Parameter Name="PostType" Type="Byte" />
		<asp:Parameter Name="startingArticle" Type="Int32" />
		<asp:Parameter Name="numberOfPostsperPage" Type="Int32" />
	</SelectParameters>
</asp:ObjectDataSource>
<asp:ObjectDataSource ID="odsGetListOfAttendess" runat="server" SelectMethod="GetEventAttendess" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.EventsDataDB" EnablePaging="True" MaximumRowsParameterName="numberOfPostsperPage" SelectCountMethod="GetEventAttendessCount"
	StartRowIndexParameterName="startingArticle" OnSelecting="odsGetListOfAttendess_Selecting" OnSelected="odsGetListOfAttendess_Selected">
	<SelectParameters>
		<asp:Parameter Name="ArticleID" Type="Int32" />
		<asp:Parameter Name="RecurringID" Type="Int32" />
		<asp:Parameter Name="startingArticle" Type="Int32" />
		<asp:Parameter Name="numberOfPostsperPage" Type="Int32" />
	</SelectParameters>
</asp:ObjectDataSource>
