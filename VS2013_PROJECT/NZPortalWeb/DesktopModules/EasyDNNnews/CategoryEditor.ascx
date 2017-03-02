<%@ control language="C#" inherits="EasyDNNSolutions.Modules.EasyDNNNews.CategoryEditor, App_Web_categoryeditor.ascx.d988a5ac" autoeventwireup="true" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<%@ Register TagPrefix="dnn" TagName="TextEditor" Src="~/controls/TextEditor.ascx" %>
<%@ Register Src="~/controls/URLControl.ascx" TagName="URL" TagPrefix="Portal" %>
<script type="text/javascript">
	function ShowValue() {
		return confirm('<%=Localization.GetString("Areyousure.Text", this.LocalResourceFile)%>');
	}
</script>
<asp:Panel ID="pnlMainWrapper" runat="server">
	<div id="EDNadmin">
		<div class="module_action_title_box">
			<asp:PlaceHolder ID="phAdminNavigation" runat="server"></asp:PlaceHolder>
			<h1>
				<%=CategoryManager%></h1>
		</div>
		<div class="main_content category_manager">
			<asp:Panel ID="pnlCatManagment" CssClass="list_and_actions" runat="server">
				<h1 class="title">
					<%=Categories%></h1>
				<asp:ListBox ID="lbCategoryList" runat="server" />
				<div class="actions">
					<asp:LinkButton ID="ibUP" runat="server" CssClass="move_up action" OnCommand="CategoryPositioning" CommandName="Up" resourcekey="ibUPResource1" />
					<div class="bottom_move_actions">
						<asp:LinkButton ID="ibLeft" runat="server" CssClass="move_left action" OnCommand="CategoryPositioning" CommandName="Left" resourcekey="ibLeftResource1" />
						<asp:LinkButton ID="ibDown" runat="server" CssClass="move_down action" OnCommand="CategoryPositioning" CommandName="Down" resourcekey="ibDownResource1" />
						<asp:LinkButton ID="inRight" runat="server" CssClass="move_right action" OnCommand="CategoryPositioning" CommandName="Right" resourcekey="inRightResource1" />
					</div>
					<asp:LinkButton ID="inEditItem" runat="server" CssClass="edit action" OnClick="inEditItem_Click" resourcekey="inEditItemResource1" />
					<asp:LinkButton ID="ibDelete" runat="server" CssClass="delete action" OnClientClick="return ShowValue();" OnClick="ibDelete_Click" resourcekey="ibDeleteResource1" />
					<asp:Label ID="lblDeleteMessage" CssClass="delete_msg" runat="server" EnableViewState="false" resourcekey="lblDeleteMessageResource1" />
				</div>
			</asp:Panel>
			<asp:Panel ID="pnlAddCategories" CssClass="section_box grey white_border_1" runat="server">
				<h1 class="section_box_title">
					<span>
						<%=AddCategory%></span></h1>
				<div class="content add_edit_category main_article_image">
					<div class="padded_wrapper">
						<div class="text_input_set">
							<label for="<%=tbCategoryName.ClientID %>">
								<%=Categoryname %></label>
							<asp:TextBox ID="tbCategoryName" CssClass="text" runat="server" MaxLength="100" ValidationGroup="vgCreateCat" />
							<asp:RequiredFieldValidator ID="rfvCatName" runat="server" ControlToValidate="tbCategoryName" ErrorMessage="Please enter a name." ValidationGroup="vgCreateCat" resourcekey="rfvCatNameResource1" />
						</div>
						<div class="text_input_set">
							<label for="<%=ddlParentCategoryList.ClientID%>">
								<%=Categoryparent%></label>
							<asp:DropDownList ID="ddlParentCategoryList" CssClass="dropdown" runat="server" AppendDataBoundItems="True" />
						</div>
						<div class="text_input_set">
							<label for="<%=txtCatText.ClientID %>">
								<%=Categorydescription%>
							</label>
							<dnn:TextEditor ID="txtCatText" runat="server" Height="300" Width="665" />
						</div>
						<div class="grey_box category_image">
							<h2>
								<%=Categoryimage %></h2>
							<div class="right_col">
								<div class="upload">
									<asp:FileUpload ID="fuCatImage" CssClass="image_selector" runat="server" resourcekey="fuCatImageResource1" />
								</div>
							</div>
						</div>
						<div class="grey_box category_link">
							<h2>
								<%=Categorylink%></h2>
							<asp:RadioButtonList ID="rblSelectUrlAdd" runat="server" AutoPostBack="True" OnSelectedIndexChanged="rblSelectUrlAdd_SelectedIndexChanged" RepeatDirection="Horizontal" resourcekey="rblSelectUrlAddResource1">
								<asp:ListItem Selected="True" Value="None" Text="None" resourcekey="ListItemResource2" />
								<asp:ListItem Value="URL" Text="Link" resourcekey="ListItemResource3" />
								<asp:ListItem Value="Page" Text="Page in the site" resourcekey="ListItemResource4" />
							</asp:RadioButtonList>
							<asp:TextBox ID="tbCatURLAdd" runat="server" Width="500px" Visible="false" resourcekey="tbCatURLAddResource1"></asp:TextBox>
							<Portal:URL ID="ctlURLAdd" runat="server" Width="250" ShowNewWindow="false" ShowUsers="false" ShowFiles="false" ShowLog="false" ShowSecure="false" ShowTabs="true" ShowTrack="false" ShowUpLoad="false" ShowUrls="false" ShowDatabase="false" UrlType="U" Visible="false" />
						</div>
						<asp:Label CssClass="added_msg" ID="lblCreateCatMessage" runat="server" EnableViewState="false" resourcekey="lblCreateCatMessageResource1" />
						<div class="main_actions">
							<asp:LinkButton ID="lbAddNewCategory" runat="server" CssClass="submit_btn" OnClick="lbAddNewCategory_Click" ValidationGroup="vgCreateCat" resourcekey="lbAddNewCategoryResource1"><span>ADD NEW CATEGORY</span></asp:LinkButton>
							&nbsp;<asp:LinkButton ID="lbClose" runat="server" CssClass="cancel_btn" OnClick="lbClose_Click" resourcekey="lbCloseResource1"><span>CLOSE</span></asp:LinkButton>
						</div>
					</div>
				</div>
			</asp:Panel>
			<asp:Panel ID="pnlEditCatItem" CssClass="section_box grey white_border_1" runat="server" Visible="False">
				<h1 class="section_box_title">
					<span>
						<%=EditCategory%></span></h1>
				<div class="content add_edit_category main_article_image">
					<div class="padded_wrapper">
						<div class="text_input_set">
							<asp:LinkButton ID="lbLocalizeContent" runat="server" OnClick="lbLocalizeContent_Click" CssClass="content_localization_btn" resourcekey="lbLocalizeContentResource1" Visible="false"><span>Category localization</span></asp:LinkButton>
						</div>
						<div class="text_input_set">
							<label for="<%=tbCategoryName.ClientID %>">
								<%=Categoryname%></label>
							<asp:TextBox ID="tbCategoryTitleUpdate" CssClass="text" runat="server" MaxLength="100" ValidationGroup="vgCatTitleUpdate" CausesValidation="true" />
							<asp:RequiredFieldValidator ID="rfvCategoryName" runat="server" ControlToValidate="tbCategoryTitleUpdate" ErrorMessage="This field is required." ValidationGroup="vgCatTitleUpdate" resourcekey="rfvCategoryNameResource1" />
						</div>
						<div class="text_input_set">
							<label for="<%=ddlParentCategoryEditList.ClientID%>">
								<%=Categoryparent%></label>
							<asp:DropDownList ID="ddlParentCategoryEditList" CssClass="dropdown" runat="server" AppendDataBoundItems="True" resourcekey="ddlParentCategoryEditListResource1">
								<asp:ListItem Value="-1" resourcekey="ListItemResource5">Select parent category</asp:ListItem>
								<asp:ListItem Value="0" resourcekey="ListItemResource6">No parent category</asp:ListItem>
							</asp:DropDownList>
							<asp:RadioButtonList ID="rblCategoriesMove" runat="server" AutoPostBack="True" OnSelectedIndexChanged="rblCategoriesMove_SelectedIndexChanged" RepeatDirection="Horizontal">
								<asp:ListItem resourcekey="liMoveAllCategories" Selected="True" Value="all">Move category with subcategories</asp:ListItem>
								<asp:ListItem resourcekey="liMoveOneCategory" Value="one">Move only one category</asp:ListItem>
							</asp:RadioButtonList>
						</div>
						<div class="text_input_set">
							<label for="<%=txtCatText.ClientID %>">
								<%=Categorydescription%></label>
							<dnn:TextEditor ID="txtCatDescriptionEdit" runat="server" Height="300" Width="665" />
						</div>
						<div class="grey_box category_image">
							<h2>
								<%=Categoryimage%></h2>
							<div class="left_col">
								<asp:Image ID="imgCatImageUpdate" runat="server" resourcekey="imgCatImageUpdateResource1" />
							</div>
							<div class="right_col">
								<div class="upload">
									<asp:FileUpload ID="fuCatReplaceImage" runat="server" resourcekey="fuCatReplaceImageResource1" />
								</div>
								<asp:Panel ID="pnlDeleteImage" runat="server" resourcekey="pnlDeleteImageResource1">
									<div class="info_box check_sign">
										<asp:LinkButton ID="lbRemoveImage" CssClass="action remove_btn" runat="server" OnClick="lbRemoveImage_Click" resourcekey="lbRemoveImageResource1">Delete</asp:LinkButton><p>
											<strong>This image</strong> is selected as the category's image
										</p>
									</div>
								</asp:Panel>
							</div>
						</div>
						<div class="grey_box category_link">
							<h2>
								<%=Categorylink%></h2>
							<asp:RadioButtonList ID="rblSelectUrl" runat="server" AutoPostBack="True" OnSelectedIndexChanged="rblSelectUrl_SelectedIndexChanged" RepeatDirection="Horizontal" resourcekey="rblSelectUrlResource1">
								<asp:ListItem Selected="True" resourcekey="ListItemResource7">None</asp:ListItem>
								<asp:ListItem Value="URL" resourcekey="ListItemResource8">Link</asp:ListItem>
								<asp:ListItem Value="Page" resourcekey="ListItemResource9">Page in the site</asp:ListItem>
							</asp:RadioButtonList>
							<asp:TextBox ID="tbCatURL" runat="server" Width="500px" resourcekey="tbCatURLResource1"></asp:TextBox>
							<Portal:URL ID="ctlURL" runat="server" Width="250" ShowNewWindow="False" ShowUsers="False" ShowFiles="False" ShowLog="False" ShowSecure="False" ShowTabs="True" ShowTrack="False" ShowUpLoad="False" ShowUrls="False" ShowDatabase="False" UrlType="U" />
						</div>
						<div class="main_actions">
							<asp:LinkButton ID="lbUpdateCategory" runat="server" CssClass="submit_btn" OnClick="lbUpdateCategory_Click" ValidationGroup="vgCatTitleUpdate" CausesValidation="true" resourcekey="lbUpdateCategoryResource1"><span>Update category</span></asp:LinkButton>
							<asp:LinkButton ID="lbCancel" runat="server" OnClick="lbCancel_Click" CssClass="cancel_btn" resourcekey="lbCancelResource1">Cancel</asp:LinkButton>
						</div>
					</div>
				</div>
			</asp:Panel>
			<asp:Panel ID="pnlCategoryLocalization" CssClass="section_box grey white_border_1" runat="server" Visible="False">
				<h1 class="section_box_title">
					<span>
						<%=CategoryLocalization%></span></h1>
				<div class="content add_edit_category main_article_image">
					<div class="padded_wrapper">
						<table class="settings_table" cellpadding="0" cellspacing="0">
							<tr>
								<td class="left">Title:
								</td>
								<td class="right">
									<asp:Label ID="lblCatTitle" runat="server" resourcekey="lblCatTitleResource1"></asp:Label>
								</td>
							</tr>
							<tr>
								<td class="left">
									<%=Defaultportallanguage%>
								</td>
								<td class="right">
									<asp:Label ID="lblDefaultPortalLangugage" runat="server" resourcekey="lblDefaultPortalLangugageResource1"></asp:Label>
								</td>
							</tr>
							<tr>
								<td class="left">
									<asp:Label ID="lblLocLangArticle" runat="server" Text="Localized languages for this article:" resourcekey="lblLocLangArticleResource1"></asp:Label>
								</td>
								<td class="right">
									<asp:Label ID="lblLocalizedLanguages" runat="server" Text="None"></asp:Label>
								</td>
							</tr>
							<tr>
								<td class="left">
									<asp:Label ID="lblCLSelectLanguage" runat="server" Text="Select language:" resourcekey="lblCLSelectLanguageResource1"></asp:Label>
								</td>
								<td class="right">
									<asp:DropDownList ID="ddlCLLanguageSelect" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlCLLanguageSelect_SelectedIndexChanged" resourcekey="ddlCLLanguageSelectResource1">
									</asp:DropDownList>
								</td>
							</tr>
							<tr>
								<td class="left"></td>
								<td class="right">
									<asp:LinkButton ID="lbCLCopyDefaults" resourcekey="lbCLCopyDefaults" CssClass="silver_button" Style="float: right;" runat="server" OnClick="lbCLCopyDefaults_Click"><span>Copy default values</span></asp:LinkButton>
									<asp:LinkButton ID="btnDeleteLocalization" resourcekey="btnDeleteLocalization" CssClass="silver_button" Style="float: right;" runat="server" OnClick="btnDeleteLocalization_Click"><span>Delete selected locale</span></asp:LinkButton>
								</td>
							</tr>
						</table>
						<div class="text_input_set">
							<label for="<%=tbCategoryName.ClientID %>">
								<%=Categoryname%></label>
							<asp:TextBox ID="tbCLCategoryTitle" CssClass="text" runat="server" MaxLength="200" ValidationGroup="vgCatTitleUpdate" CausesValidation="true" />
							<asp:RequiredFieldValidator ID="rfvCLCategoryTitle" runat="server" ControlToValidate="tbCLCategoryTitle" ErrorMessage="This field is required." ValidationGroup="vgCatTitleUpdate" resourcekey="rfvCategoryNameResource1" />
						</div>
						<div class="text_input_set">
							<label for="<%=txtCatText.ClientID %>">
								<%=Categorydescription%></label>
							<dnn:TextEditor ID="txtCatLocDescription" runat="server" Height="300" Width="665" />
						</div>
						<div class="main_actions">
							<asp:LinkButton ID="btnAddCoategoryLocalization" CssClass="submit_btn" runat="server" OnClick="btnAddCoategoryLocalization_Click" CausesValidation="true" ValidationGroup="vgLocCategory" resourcekey="btnAddCoategoryLocalizationResource1"><span>Save category localization</span></asp:LinkButton>
							<asp:LinkButton ID="btnCloseLocalization" CssClass="cancel_btn" runat="server" OnClick="btnCloseLocalization_Click" Text="Close" resourcekey="btnCloseLocalizationResource1" />
							<p>
								<asp:Label ID="lblErrorInfoMsg" runat="server" EnableViewState="false" Visible="false" />
							</p>
						</div>
					</div>
				</div>
			</asp:Panel>
		</div>
	</div>
</asp:Panel>
