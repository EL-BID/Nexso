<%@ control language="C#" inherits="EasyDNNSolutions.Modules.EasyDNNNews.ViewEasyDNNNewsCatalog, App_Web_vieweasydnnnewscatalog.ascx.d988a5ac" autoeventwireup="true" enableviewstate="true" %>
<%@ Register TagPrefix="dnnCTRL" Assembly="DotNetNuke" Namespace="DotNetNuke.UI.WebControls" %>
<script type="text/javascript">
	/*<![CDATA[*/
	<%=includeprettyPhotoJS%>;
	<%=includeGetNewsArticlesJS%>;
	<%=includeCommentArticlesJS%>;
	<%=includePrintJS%>;
	<%=includeRegistrationCusotmFieldsJS%>;
	<%=includeCoreInit%>;

	eds1_8(function ($) {
		if (typeof edn_fluidvids != 'undefined')
			edn_fluidvids.init({
				selector: ['.edn_fluidVideo iframe'],
				players: ['www.youtube.com', 'player.vimeo.com']
			});
		<%=includeOpenEventRegistrationModalBox%>;
	});
	/*]]>*/
</script>
<%=includeAddThisJS%>
<asp:Literal ID="countfacebookJS" runat="server" EnableViewState="false" />
<div id="<%=MainDivID%>" class="<%=MainDivClass%>">
	<p id="themeDeveloperModeActive" runat="server" enableviewstate="false" visible="false" class="eds_themeDeveloperModeActive"><span id="themeDeveloperModeActiveText" runat="server"></span></p>
	<asp:Panel ID="pnlUserDashBoard" runat="server" Visible="False" CssClass="user_dashboard" EnableViewState="false">
		<asp:HyperLink ID="lbAddArticles" runat="server" Visible="false" CssClass="add_article"><%=Localization.GetString("lbAddArticles.Text", this.LocalResourceFile + "ViewEasyDNNNews.ascx.resx")%></asp:HyperLink>
		<asp:HyperLink ID="lbArticleEditor" runat="server" Visible="false" CssClass="article_manager"><%=Localization.GetString("lbArticleEditor.Text", this.LocalResourceFile + "ViewEasyDNNNews.ascx.resx")%></asp:HyperLink>
		<asp:HyperLink ID="lbEventsManager" runat="server" Visible="false" CssClass="event_manager"><%=Localization.GetString("lbEventsManager.Text", this.LocalResourceFile + "ViewEasyDNNNews.ascx.resx")%></asp:HyperLink>
		<asp:HyperLink ID="lbApproveComments" runat="server" Visible="false" CssClass="approve_comments"><%=Localization.GetString("lbApproveComments.Text", this.LocalResourceFile + "ViewEasyDNNNews.ascx.resx")%></asp:HyperLink>
		<asp:HyperLink ID="lbCategoryEdit" runat="server" Visible="false" CssClass="category_manager"><%=Localization.GetString("lbCategoryEdit.Text", this.LocalResourceFile + "ViewEasyDNNNews.ascx.resx")%></asp:HyperLink>
		<asp:HyperLink ID="lbApproveRoles" runat="server" Visible="false" CssClass="approve_articles"><%=Localization.GetString("lbApproveRoles.Text", this.LocalResourceFile + "ViewEasyDNNNews.ascx.resx")%></asp:HyperLink>
		<asp:HyperLink ID="lbDashboard" runat="server" Visible="false" CssClass="dashboard"><%=Localization.GetString("lbDashboard.Text", this.LocalResourceFile + "ViewEasyDNNNews.ascx.resx")%></asp:HyperLink>
		<asp:HyperLink ID="lbModuleSettings" runat="server" Visible="false" CssClass="settings"><%=Localization.GetString("lbDBSettings.Text", this.LocalResourceFile + "ViewEasyDNNNews.ascx.resx")%></asp:HyperLink>
		<asp:HyperLink ID="lbAboutMe" runat="server" Visible="false" CssClass="author_profile"><%=Localization.GetString("lbAboutMe.Text", this.LocalResourceFile + "ViewEasyDNNNews.ascx.resx")%></asp:HyperLink>
	</asp:Panel>
	<asp:Panel ID="pnlListArticles" runat="server">
		<p class="bread_crumbs">
			<asp:Literal runat="server" ID="breadCrumbsHTML" EnableViewState="false" />
		</p>
		<%=DisplayBeforeMulti()%>
		<%=DisplayCatalogHeader()%>
		<asp:Panel ID="pnlListCategories" runat="server" CssClass="child_categories">
			<asp:DataList ID="dlCatList" runat="server" RepeatDirection="Horizontal" EnableViewState="false">
				<ItemStyle VerticalAlign="Top" />
				<ItemTemplate>
					<%#Eval("categoryhtml")%>
				</ItemTemplate>
			</asp:DataList>
		</asp:Panel>

		<asp:Literal ID="litSearchInfo" runat="server" Visible="false" EnableViewState="false"></asp:Literal>

		<asp:Literal ID="litListContent" runat="server" EnableViewState="false" />

		<%=DisplayAfterMulti()%>
		<asp:Panel ID="pnlArticlePager" runat="server" CssClass="article_pager" EnableViewState="false">
			<asp:LinkButton ID="ibFirst" CssClass="first" runat="server" OnClick="ibFirst_Click" Visible="False"><%=Localization.GetString("First.Text", this.LocalResourceFile + "ViewEasyDNNNews.ascx.resx")%></asp:LinkButton>
			<asp:LinkButton ID="ibLeft" runat="server" CssClass="prev" OnClick="ibLeft_Click" Visible="False"><%=Localization.GetString("Previous.Text", this.LocalResourceFile + "ViewEasyDNNNews.ascx.resx")%></asp:LinkButton>
			<asp:PlaceHolder ID="PaggingHTML" runat="server" />
			<asp:LinkButton ID="ibRight" runat="server" CssClass="next" OnClick="ibRight_Click" Visible="False"><%=Localization.GetString("Next.Text", this.LocalResourceFile + "ViewEasyDNNNews.ascx.resx")%></asp:LinkButton>
			<asp:LinkButton ID="ibLast" CssClass="last" runat="server" OnClick="ibLast_Click" Visible="False"><%=Localization.GetString("Last.Text", this.LocalResourceFile + "ViewEasyDNNNews.ascx.resx")%></asp:LinkButton>
		</asp:Panel>
	</asp:Panel>
	<asp:Literal ID="liDynamicScrollingMarkup" runat="server" Visible="false" />
	<asp:Panel ID="pnlViewArticle" runat="server">
		<p class="bread_crumbs">
			<%=generateArticleBreadCrumbs()%>
		</p>
		<%=editLink("admin_action edit")%>
		<asp:LinkButton ID="lbPublishArticle" CssClass="admin_action publish_article" OnClick="lbPublishArticle_Click" Visible="false" runat="server">Published</asp:LinkButton>
		<asp:LinkButton ID="lbApproveArticle" CssClass="admin_action publish_article" OnClick="lbApproveArticle_Click" Visible="false" runat="server">Approve</asp:LinkButton>
		<%=generateArticleHtml("EDNHeader")%>
		<asp:UpdatePanel ID="upHeader" runat="server" UpdateMode="Conditional">
			<ContentTemplate>
				<asp:GridView ID="gvHeaderArtPagging" runat="server" EnableModelValidation="True" AutoGenerateColumns="False" AllowPaging="True" PageSize="1" BorderStyle="None" BorderWidth="0px" CellPadding="0" GridLines="None" ShowHeader="False" OnPageIndexChanging="gvHeaderArtPagging_PageIndexChanging"
					EnableViewState="false">
					<Columns>
						<asp:TemplateField HeaderText="Article" ShowHeader="False">
							<ItemTemplate>
								<%# Eval("Article") %>
							</ItemTemplate>
						</asp:TemplateField>
					</Columns>
					<PagerStyle HorizontalAlign="Center" />
				</asp:GridView>
			</ContentTemplate>
		</asp:UpdatePanel>
		<asp:PlaceHolder ID="plTopGallery" runat="server"></asp:PlaceHolder>
		<%=generateArticleHtml("EDNContentTop")%>
		<%=generateArticleHtml("EDNContent")%>
		<asp:UpdatePanel ID="upArticle" runat="server" UpdateMode="Conditional">
			<ContentTemplate>
				<%=generateArticleHtml("EDNContent")%>
				<asp:GridView ID="gvArticlePagging" runat="server" EnableModelValidation="True" AutoGenerateColumns="False" AllowPaging="True" PageSize="1" BorderStyle="None" BorderWidth="0px" CellPadding="0" GridLines="None" OnPageIndexChanging="gvArticlePagging_PageIndexChanging"
					ShowHeader="False" EnableViewState="false">
					<Columns>
						<asp:TemplateField HeaderText="Article" ShowHeader="False">
							<ItemTemplate>
								<%# Eval("Article") %>
							</ItemTemplate>
						</asp:TemplateField>
					</Columns>
					<PagerSettings Mode="NumericFirstLast" />
					<PagerStyle HorizontalAlign="Center" CssClass="article_pagination" />
				</asp:GridView>
			</ContentTemplate>
		</asp:UpdatePanel>
		<%=generateArticleHtml("EDNContentBottom")%>
		<asp:PlaceHolder ID="plBottomGallery" runat="server"></asp:PlaceHolder>
		<%=generateArticleHtml("EDNFooter")%>
		<asp:Panel ID="pnlArticelImagesGallery" runat="server" class="edn_article_gallery">
			<ul>
				<asp:Repeater ID="repArticleImages" runat="server" EnableViewState="false">
					<ItemTemplate>
						<li><a href='<%#Eval("FileName")%>' pptitle='<%#Eval("Description")%>' rel="ednprettyPhoto_M<%=ModuleId%>">
							<asp:Image alt='<%#Eval("Title")%>' ID="imgArticleGalleryImage" ImageUrl='<%#Eval("Thumburl")%>' runat="server" /></a> </li>
					</ItemTemplate>
				</asp:Repeater>
			</ul>
		</asp:Panel>
		<%=editLink("admin_action edit")%>
		<script type="text/javascript">
			eds1_8(document).ready(function ($) {
				var $rate_it = $("#<%=MainDivID%> .EDN_article_rateit");
				$rate_it.bind('rated reset', function (e) {
					var ri = $(this);
					var value = ri.rateit('value');
					var articleid = <%=publicOpenArticleID%>;
					$rate_it.rateit('readonly', true);
					ri.rateit('readonly', true);
					$.cookie("<%=EDNViewArticleID%>", "true");
					document.getElementById("<%=hfRate.ClientID %>").value= value;
					$.ajax(
					{
						url: "<%=ModulePath %>Rater.aspx",
						type: "POST",
						data: {artid: articleid, rating: value},
						success: function (data)
						{
							ri.siblings('.current_rating').text(data);
						}
					});
				})
					.rateit('value', document.getElementById("<%=hfRate.ClientID %>").value)
					.rateit('readonly', $.cookie("<%=EDNViewArticleID%>"))
					.rateit('step',1);
			});
		</script>
		<asp:HiddenField ID="hfRate" runat="server" />
		<script type="text/javascript">
			// <![CDATA[
			eds1_8(function ($) {
				$('#<%=upPanelComments.ClientID %>').on('click', '#<%=lbAddComment.ClientID %>', function () {
					var $lbAddComment = $('#<%=lbAddComment.ClientID %>'),
						noErrors = true,

						$authorNameInput = $('#<%=tbAddCommentName.ClientID %>'),
						$authorEmailInput = $('#<%=tbAddCommentEmail.ClientID %>'),

						authorName,
						authorEmail,
						comment = $('#<%=tbAddComment.ClientID %>').val(),

						$noAuthorName = $('#<%=lblAddCommentNameError.ClientID %>'),
						$noAuthorEmail = $('#<%=lblAddCommentEmailError.ClientID %>'),
						$authorEmailNotValid = $('#<%=lblAddCommentEmailValid.ClientID %>'),
						$noComment = $('#<%=lblAddCommentError.ClientID %>'),

						emailRegex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

					if ($lbAddComment.data('disable'))
						return false;

					if ($authorNameInput.length > 0) {
						authorName = $authorNameInput.val();

						$noAuthorName.css('display', 'none');

						if (authorName == '') {
							$noAuthorName.css('display', 'block');
							noErrors = false;
						}
					}

					if ($authorEmailInput.length > 0) {
						authorEmail = $authorEmailInput.val();

						$noAuthorEmail.css('display', 'none');
						$authorEmailNotValid.css('display', 'none');

						if (authorEmail == '') {
							$noAuthorEmail.css('display', 'block');
							noErrors = false;
						} else if (!emailRegex.test(authorEmail)) {
							$authorEmailNotValid.css('display', 'block');
							noErrors = false;
						}
					}

					if (comment == '') {
						$noComment.css('display', 'block');
						noErrors = false;
					} else
						$noComment.css('display', 'none');

					if (noErrors)
						$lbAddComment.data('disable', true);
					else
						return false;
				});
			});
			//*/ ]]>
		</script>
		<asp:UpdatePanel ID="upPanelComments" runat="server">
			<ContentTemplate>
				<asp:Panel ID="pnlComments" runat="server" CssClass="article_comments" Visible="false">
					<asp:Literal ID="numberOfCommentsHTML" runat="server" />
					<asp:DataList ID="dlComments" runat="server" DataKeyField="CommentID" OnItemCommand="dlComments_ItemCommand" CssClass="comment_list" RepeatLayout="Flow" EnableViewState="false">
						<ItemTemplate>
							<div class="comment level<%#NestedCommentClass(Eval("ReplayLevel"))%>">
								<asp:Panel ID="pnlCommentRating" runat="server" CssClass="votes" Visible='<%#ShowCommentsRatingascx%>'>
									<div>
										<asp:ImageButton ID="imgBGoodVotes" runat="server" ImageUrl='~/DesktopModules/EasyDNNNews/images/upvote.png' CommandArgument="<%# ((DataListItem) Container).ItemIndex %>" CommandName="GoodVote" CausesValidation="false" />
										<asp:Label ID="lblGoodVotes" runat="server" Text='<%#Eval("GoodVotes")%>' />
									</div>
									<div>
										<asp:ImageButton ID="imgBBadVotes" runat="server" ImageUrl="~/DesktopModules/EasyDNNNews/images/downvote.png" CommandArgument="<%# ((DataListItem) Container).ItemIndex %>" CommandName="BadVote" />
										<asp:Label ID="lblBadVotes" runat="server" Text='<%#Eval("BadVotes")%>' />
									</div>
								</asp:Panel>
								<div class="right_side">
									<%#DisplayComments(Eval("CommentID"),Eval("CommentersEmail"),Eval("ArticleID"),Eval("UserID"),Eval("AnonymName"),Eval("Comment"),Eval("DateAdded"), Eval("GoodVotes"),Eval("BadVotes"),Eval("Approved"),Eval("CommentersEmail")) %>
									<div class="actions">
										<asp:LinkButton ID="lbReplayToComment" CssClass="reply" runat="server" OnClientClick="setFocusComment();" Text='<%#lbReplayToCommentloc%>' CommandName="ReplayToCommet" CommandArgument='<%#Eval("CommentID")%>' Visible='<%#DisplayReplayTo%>' />
										<asp:LinkButton ID="lbDeleteComment" CssClass="delete" runat="server" Text="Delete comment" OnClientClick='<%#CommentDeleteConfirm%>' CommandName="DeleteComment" CommandArgument='<%#Eval("CommentID")%>' Visible="<%#IsComentModerator()%>" />
										<asp:LinkButton ID="lbEditComment" CssClass="edit" runat="server" Text="Edit comment" CommandName="EditComment" CommandArgument='<%#Eval("CommentID")%>' Visible="<%#Convert.ToBoolean(IsComentModerator())%>" />
									</div>
									<asp:HiddenField ID="hfCommentID" Value='<%#Eval("CommentID")%>' runat="server" />
								</div>
								<asp:Panel ID="pnlEditComments" runat="server" Visible="false" class="edit_comment">
									<asp:TextBox ID="tbEditComment" Text='<%#Eval("Comment")%>' runat="server" TextMode="MultiLine" />
									<div class="actions">
										<asp:LinkButton ID="lbUpdateComment" runat="server" CommandArgument='<%#Eval("CommentID")%>' CommandName="UpdateComment"><span>Update</span></asp:LinkButton>
										<asp:LinkButton ID="lbCancelUpdateComment" runat="server" CommandArgument='<%#Eval("CommentID")%>' CommandName="CancelEdit"><span>Cancel</span></asp:LinkButton>
									</div>
								</asp:Panel>
							</div>
						</ItemTemplate>
					</asp:DataList>
					<asp:Panel ID="pnlAddComments" runat="server" CssClass="add_comment">
						<h3>
							<%=LeaveAComment%></h3>
						<div class="add_article_box">
							<asp:Panel ID="pnlReplayToComment" runat="server" CssClass="comment_info" Visible="false">
								<asp:Label ID="lblReplayToComment" runat="server" Text="" />
							</asp:Panel>
							<asp:Panel ID="pnlCommentsNameEmail" runat="server">
								<table cellspacing="0" cellpadding="0">
									<tr>
										<td class="left">
											<asp:Label ID="lblAddCommentName" runat="server" Text="Name:" />
										</td>
										<td class="right">
											<asp:TextBox ID="tbAddCommentName" runat="server" CssClass="text" MaxLength="50" ValidationGroup="vgAddArtComment" />
											<asp:Label ID="lblAddCommentNameError" runat="server" Text="Please enter your name." Style="color: red; display: none;" />
										</td>
									</tr>
									<tr>
										<td class="left">
											<asp:Label ID="lblAddCommentEmail" runat="server" Text="Email:" />
										</td>
										<td class="right">
											<asp:TextBox ID="tbAddCommentEmail" runat="server" CssClass="text" MaxLength="50" ValidationGroup="vgAddArtComment" />
											<asp:Label ID="lblAddCommentEmailError" runat="server" Text="Please enter email." Style="color: red; display: none;" />
											<asp:Label ID="lblAddCommentEmailValid" runat="server" Text="Please enter valid email." Style="color: red; display: none;" />
										</td>
									</tr>
								</table>
							</asp:Panel>
							<table cellspacing="0" cellpadding="0">
								<tr>
									<td class="left">
										<asp:Label ID="lblAddComment" runat="server" Text="Comment:"></asp:Label>
									</td>
									<td class="right">
										<asp:TextBox ID="tbAddComment" runat="server" TextMode="MultiLine" MaxLength="10000" ValidationGroup="vgAddArtComment" />
										<asp:Label ID="lblAddCommentError" runat="server" Text="Please enter comment." Style="color: red; display: none;" />
									</td>
								</tr>
							</table>
							<asp:Panel ID="pnlCaptcha" runat="server" Visible="False">
								<table cellspacing="0" cellpadding="0">
									<tr>
										<td class="left"></td>
										<td class="right">
											<dnnCTRL:CaptchaControl ID="ctlCaptcha" runat="server" CaptchaHeight="50px" CaptchaLength="5" CaptchaWidth="300px" CssClass="Normal" Enabled="true" ErrorStyle-CssClass="NormalRed" Expiration="600" BorderColor="Black" />
											<asp:Label ID="lblCaptchaError" runat="server" ForeColor="Red" Text="The typed code must match the image, please try again" Visible="False" />
										</td>
									</tr>
								</table>
							</asp:Panel>
							<table cellspacing="0" cellpadding="0">
								<tr>
									<td class="left"></td>
									<td class="right bottom">
										<asp:LinkButton ID="lbAddComment" runat="server" OnClick="lbAddComment_Click" resourcekey="lbAddComentResource" CssClass="submit" ValidationGroup="vgAddArtComment"><span><%=AddComment%></span></asp:LinkButton>
									</td>
								</tr>
							</table>
						</div>
					</asp:Panel>
				</asp:Panel>
				<asp:Panel ID="pnlCommentInfo" runat="server" CssClass="article_comments" Visible="false" EnableViewState="false" />
				<asp:HiddenField ID="hfReplayToComment" runat="server" />
			</ContentTemplate>
		</asp:UpdatePanel>
		<asp:Literal ID="socComments" runat="server" EnableViewState="False" Visible="False"></asp:Literal>
		<%=generateArticleHtml("EDNBottom")%>
	</asp:Panel>
	<asp:Label ID="lblInfoMassage" runat="server" Style="font-weight: bold" EnableViewState="false" Visible="false" />
</div>

<div id="pnlEventRegistrationForm" runat="server" class="eds_modalWrapper">
	<div class="eds_modalContent eds_animated">
		<h3><%=Localization.GetString("RegistrationForm.Text", this.LocalResourceFile + "EventRegistration.resx")%></h3>
		<div>
			<div runat="server" id="pnlRegistrationForm">
				<asp:Panel ID="pnlEventRegistrationLogedInUser" runat="server" Visible="false">
					<p>
						<label>
							<asp:Label ID="lblFirstNameLogedIn" runat="server"><%=Localization.GetString("lbRegFirstName.Text", this.LocalResourceFile + "EventRegistration.resx")%></asp:Label></label>
						<asp:TextBox ID="lblFirstNameLogedInValue" runat="server" CausesValidation="false" Enabled="false"></asp:TextBox>
					</p>
					<p>
						<label>
							<asp:Label ID="lblLastNameLogedIn" runat="server"><%=Localization.GetString("lbRegLastName.Text", this.LocalResourceFile + "EventRegistration.resx")%></asp:Label></label>
						<asp:TextBox ID="lblLastNameLogedInValue" runat="server" CausesValidation="false" Enabled="false"></asp:TextBox>
					</p>
					<p>
						<label>
							<asp:Label ID="lblEmailLogedIn" runat="server"><%=Localization.GetString("lbRegEmail.Text", this.LocalResourceFile + "EventRegistration.resx")%></asp:Label></label>
						<asp:TextBox ID="lblEmailLogedInValue" runat="server" CausesValidation="false" Enabled="false"></asp:TextBox>
					</p>
				</asp:Panel>
				<asp:Panel ID="pnlEventRegistrationUnVerified" runat="server">
					<p>
						<label>
							<asp:Label ID="lblFirstName" runat="server"><%=Localization.GetString("lbRegFirstName.Text", this.LocalResourceFile + "EventRegistration.resx")%></asp:Label></label>
						<asp:TextBox ID="tbxFirstName" runat="server" ValidationGroup="vgEventRegistration" MaxLength="50" CausesValidation="true"></asp:TextBox>
						<asp:RequiredFieldValidator ID="rfvFirstName" runat="server" ControlToValidate="tbxFirstName" ErrorMessage="Required!" ValidationGroup="vgEventRegistration" Display="Dynamic" SetFocusOnError="True" />
					</p>
					<p>
						<label>
							<asp:Label ID="lblLastName" runat="server"><%=Localization.GetString("lbRegLastName.Text", this.LocalResourceFile + "EventRegistration.resx")%></asp:Label></label>
						<asp:TextBox ID="tbxLastName" runat="server" ValidationGroup="vgEventRegistration" MaxLength="50"></asp:TextBox>
						<asp:RequiredFieldValidator ID="rfvLastName" runat="server" ControlToValidate="tbxLastName" ErrorMessage="Required!" ValidationGroup="vgEventRegistration" Display="Dynamic" SetFocusOnError="True" />
					</p>
					<p>
						<label>
							<asp:Label ID="lblEmail" runat="server"><%=Localization.GetString("lbRegEmail.Text", this.LocalResourceFile + "EventRegistration.resx")%></asp:Label></label>
						<asp:TextBox ID="tbxEmail" runat="server" ValidationGroup="vgEventRegistration" MaxLength="256"></asp:TextBox>
						<asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="tbxEmail" ErrorMessage="Required!" ValidationGroup="vgEventRegistration" Display="Dynamic" SetFocusOnError="True" />
						<asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="tbxEmail" Display="Dynamic" ErrorMessage="Please enter a valid email address." ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" ValidationGroup="vgEventRegistration" SetFocusOnError="True" />
					</p>
				</asp:Panel>
				<p runat="server" id="sectionNumberOfTickets">
					<label>
						<asp:Label ID="lblNumberOfTickets" runat="server"><%=Localization.GetString("lbRegNumberOfSeats.Text", this.LocalResourceFile + "EventRegistration.resx")%></asp:Label></label>
					<asp:TextBox ID="tbxNumberOfTickets" runat="server" MaxLength="4" Text="1" CausesValidation="True" ValidationGroup="vgEventRegistration"></asp:TextBox>
					<asp:RequiredFieldValidator ID="rfvNumberOfTickets" runat="server" ControlToValidate="tbxNumberOfTickets" ValidationGroup="vgEventRegistration" ErrorMessage="Required!" Display="Dynamic" SetFocusOnError="True" CssClass="edn_errorMessage" />
					<asp:CompareValidator ID="cvNumberOfTickets" runat="server" ControlToValidate="tbxNumberOfTickets" ValidationGroup="vgEventRegistration" ErrorMessage="Must be a number!" Operator="DataTypeCheck" Type="Integer" Display="Dynamic" SetFocusOnError="True" CssClass="edn_errorMessage" />
				</p>
				<asp:UpdatePanel ID="upEventRegistration" runat="server" UpdateMode="Always">
					<ContentTemplate>
						<asp:PlaceHolder ID="phCustomFields" runat="server" Visible="false">
							<asp:HiddenField runat="server" ID="hfParenSelectedValue" />
							<asp:HiddenField runat="server" ID="hfLastSelectedIndexChanged" />
							<asp:HiddenField runat="server" ID="hfCFLastTriggerdByList" />
							<asp:HiddenField runat="server" ID="hfPreviousCFTemplateID" />
						</asp:PlaceHolder>
					</ContentTemplate>
				</asp:UpdatePanel>
				<p>
					<label>
						<asp:Label ID="lblMessage" runat="server"><%=Localization.GetString("lbRegAdditionalInformation.Text", this.LocalResourceFile + "EventRegistration.resx")%></asp:Label></label>
					<asp:TextBox ID="tbxMessage" runat="server" MaxLength="1024" TextMode="MultiLine" Rows="5"></asp:TextBox>
				</p>
				<p class="edn_btnRegisterEventWrapper">
					<asp:Button ID="btnRegisterEvent" runat="server" Text="Register" OnClick="btnRegisterEvent_Click" ValidationGroup="vgEventRegistration" CausesValidation="true" />
				</p>
			</div>
			<asp:Label ID="lblRegistrationInfo" runat="server" EnableViewState="false" CssClass="eds_lblRegistrationInfo" Visible="false" />
			<asp:UpdateProgress ID="uppEventRegistration" runat="server" AssociatedUpdatePanelID="upEventRegistration" DisplayAfter="100" DynamicLayout="true">
				<ProgressTemplate>
					<div class="eds_eventRegistrationLoading">
					</div>
				</ProgressTemplate>
			</asp:UpdateProgress>
		</div>
		<span class="eds_modalClose eds_closeWindowButtonOuter" data-target-id='<%=pnlEventRegistrationForm.ClientID%>'>x</span>
	</div>
</div>

<asp:Literal ID="ltPPbioInit" runat="server" Visible="False" />
<asp:HiddenField ID="hfViewed" runat="server" />
<asp:Literal ID="countdisqusJS" runat="server" EnableViewState="false" />
