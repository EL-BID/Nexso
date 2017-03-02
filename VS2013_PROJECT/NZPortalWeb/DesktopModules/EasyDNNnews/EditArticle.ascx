<%@ control language="C#" inherits="EasyDNNSolutions.Modules.EasyDNNNews.EditArticle, App_Web_editarticle.ascx.d988a5ac" autoeventwireup="true" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<%@ Register TagPrefix="dnn" TagName="TextEditor" Src="~/controls/TextEditor.ascx" %>
<%@ Register TagPrefix="Portal" TagName="URL" Src="~/controls/URLControl.ascx" %>
<style type="text/css">
	.styleDisplayNone {
		display: none;
	}
</style>
<script type="text/javascript">
	function ConfirmDelete() {
		return confirm('<%=Localization.GetString("Areyousure.Text", this.LocalResourceFile)%>');
	}
</script>

<asp:Label ID="lblEditMessage" runat="server" Visible="false" />

<asp:Panel ID="pnlMainWrapper" runat="server">
	<asp:Panel ID="pnlEditArticle" runat="server">
		<div id="EDNadmin">
			<div class="module_action_title_box">
				<asp:PlaceHolder ID="phAdminNavigation" runat="server"></asp:PlaceHolder>
				<h1>
					<%=EditArticleTitle%></h1>
			</div>
			<asp:Panel ID="pnlImagelocalization" CssClass="main_content" runat="server" Visible="false">
				<asp:HiddenField ID="hfImageLocaPicID" runat="server" />
				<table class="settings_table" cellpadding="0" cellspacing="0">
					<tr>
						<td class="left">
							<asp:Label ID="lblContentLocalizationMediaTitle" runat="server" Font-Bold="True" Text="Media title:" resourcekey="lblContentLocalizationMediaTitleResource1" />
						</td>
						<td class="right">
							<asp:Label ID="lblContentLocalizationMediaTitleOriginal" runat="server" resourcekey="lblContentLocalizationMediaTitleOriginalResource1" />
						</td>
					</tr>
					<tr>
						<td class="left">
							<asp:Label ID="lblContentLocalizationMediaDescription" runat="server" Font-Bold="True" Text="Media description:" resourcekey="lblContentLocalizationMediaDescriptionResource1" />
						</td>
						<td class="right">
							<asp:Label ID="lblContentLocalizationMediaDescriptionOriginal" runat="server" resourcekey="lblContentLocalizationMediaDescriptionOriginalResource1" />
						</td>
					</tr>
					<tr>
						<td class="left">
							<asp:Label ID="lblPortalDefLanguage" runat="server" Text="Portal default language:" resourcekey="lblPortalDefLanguageResource1" />
						</td>
						<td class="right">
							<asp:Label ID="lblDefaultPortalLangugageImage" runat="server" resourcekey="lblDefaultPortalLangugageImageResource1" />
						</td>
					</tr>
					<tr>
						<td class="left">
							<asp:Label ID="lblContentLocalizationLocalizedLanguages" runat="server" Text="Localized languages:" resourcekey="lblContentLocalizationLocalizedLanguagesResource1" />
						</td>
						<td class="right">
							<asp:Label ID="lblContentLocalizationLocalizedLanguagesList" runat="server" resourcekey="lblContentLocalizationLocalizedLanguagesListResource1" />
						</td>
					</tr>
				</table>
				<div class="text_input_set">
					<dnn:Label ID="lblContentLocalizationSelectLanguage" runat="server" HelpKey="lblContentLocalizationSelectLanguage.HelpText" HelpText="Select the languange you want to edit. There is no need to edit dafault language." Text="Select language:" ResourceKey="lblContentLocalizationSelectLanguage"></dnn:Label>
					<asp:DropDownList ID="ddlContentLocalizationSelectLanguage" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlImageEditorContentLocalizationSelectLanguage_SelectedIndexChanged" />
					<asp:LinkButton ID="btnContentLocalizationCopyDefault" CssClass="silver_button" Style="float: right;" runat="server" OnClick="btnContentLocalizationCopyDefault_Click">
						<span>
							<%=Copydefaultvalues%></span></asp:LinkButton>
				</div>
				<div class="text_input_set overflow_visible">
					<dnn:Label ID="lblContentLocalizationTitle" runat="server" HelpKey="lblContentLocalizationTitle.HelpText" HelpText="Title:" Text="Title:" ResourceKey="lblContentLocalizationTitle" />
					<asp:TextBox ID="tbContentLocalizationTitle" runat="server" CssClass="text s18" />
				</div>
				<div class="text_input_set">
					<dnn:Label ID="lblContentLocalizationDescription" runat="server" HelpKey="lblContentLocalizationDescription.HelpText" HelpText="Description:" Text="Description:" ResourceKey="lblContentLocalizationDescription" />
					<dnn:TextEditor ID="txtContentLocalizationDescription" runat="server" Height="300" Width="700" />
				</div>
				<div class="text_input_set">
					<asp:LinkButton ID="btnContentLocalizationUpdate" CssClass="silver_button" runat="server" OnClick="btnImageEditorContentLocalizationUpdate_Click">
						<span>
							<%=Savelocalization%></span></asp:LinkButton>
					<asp:LinkButton ID="btnContentLocalizationClose" CssClass="silver_button" runat="server" OnClick="btnContentLocalizationClose_Click">
						<span>
							<%=Close%></span></asp:LinkButton>
				</div>
			</asp:Panel>
			<asp:Panel ID="pnlContentLocalizationDetails" CssClass="main_content" runat="server" Visible="false">
				<p style="margin-top: 20px;">
				</p>
				<b>
					<%=Defaultportallanguage%></b>
				<asp:Label ID="lblDefaultPortalLangugage" runat="server" resourcekey="lblDefaultPortalLangugageResource1" />
				<div class="text_input_set" style="margin-top: 0px; overflow: visible;">
					<asp:CheckBox ID="cbHideDefaultLocale" runat="server" /><dnn:Label ID="lblHideDefaultLocale" ResourceKey="lblHideDefaultLocale" runat="server" Text="Don't show default language article when localization not selected:" HelpText="Don't show default language article when localization not selected:"
						ControlName="cbHideDefaultLocale" />
				</div>
				<p>
				</p>
				<p>
					<b>
						<asp:Label ID="lblLocLangArticle" runat="server" resourcekey="lblLocLangArticleResource1" Text="Localized languages for this article:" />
					</b>
					<asp:Label ID="lblLocalizedLanguages" runat="server" Text="None" />
				</p>
				<div class="text_input_set">
					<asp:Label ID="lblCLSelectLanguage" runat="server" resourcekey="lblCLSelectLanguageResource1" Text="Select language:" />
					<asp:DropDownList ID="ddlCLLanguageSelect" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlCLLanguageSelect_SelectedIndexChanged" />
					<asp:LinkButton ID="lbCLCopyDefaults" runat="server" CssClass="silver_button" OnClick="lbCLCopyDefaults_Click" resourcekey="lbCLCopyDefaultsResource1" Style="float: right;">
						<span>
							<%=Copydefaultvalues%></span></asp:LinkButton>
					<asp:LinkButton ID="btnDeleteLocalization" runat="server" CssClass="silver_button" OnClick="btnDeleteLocalization_Click" resourcekey="btnDeleteLocalization" Style="float: right;">
						<span>Delete selected locale</span></asp:LinkButton>
				</div>
				<div class="text_input_set overflow_visible">
					<dnn:Label ID="lblCLTitle" runat="server" HelpKey="lblCLTitle.HelpText" HelpText="Title" ResourceKey="lblCLTitle" Text="Title" />
					<asp:TextBox ID="tbCLArticleTitle" runat="server" CssClass="text s18" />
					<asp:RequiredFieldValidator ID="rfvCLArticleTitle" runat="server" ControlToValidate="tbCLArticleTitle" CssClass="input_validation_error" Display="Dynamic" ErrorMessage="This field is required." resourcekey="rfvTitleResource1" SetFocusOnError="True" ValidationGroup="vgCLEditArticle" />
				</div>
				<div class="text_input_set overflow_visible">
					<dnn:Label ID="lblCLSubtitle" runat="server" HelpKey="lblCLSubtitle.HelpText" HelpText="Subtitle" ResourceKey="lblCLSubtitle" Text="Subtitle" />
					<asp:TextBox ID="tbCLArticleSubtitle" runat="server" CssClass="text" />
				</div>
				<div class="collapsible_box">
					<h1 class="collapsible_box_title">
						<%=SEOsettings%></h1>
					<div id="collapsible_CLseo_box_content" class="content">
						<div class="text_input_set">
							<div>
								<dnn:Label ID="lblCLArticleURL" runat="server" ControlName="tbxCLArticleURL" HelpKey="lblArticleURL.HelpText" HelpText="Article URL" ResourceKey="lblArticleURL" Text="Article URL" />
							</div>
							<asp:TextBox ID="tbxCLArticleURL" runat="server" CssClass="text narrow left" />
							<a id="EDN_btnCLReGenerateURL" class="reset_url_btn main_action_button grey" href="#"><span>
								<%=ResetarticleURL%></span></a>
						</div>
						<div class="text_input_set">
							<label>
								<%=METAdescription%>
							</label>
							<asp:TextBox ID="tbxCLMetaDescription" runat="server" TextMode="MultiLine" />
						</div>
						<div class="text_input_set">
							<label>
								<%=METAkeywords%>
							</label>
							<asp:TextBox ID="tbxCLMetaKeywords" runat="server" TextMode="MultiLine" />
						</div>
					</div>
				</div>
				<div class="text_input_set">
					<dnn:Label ID="lblCLSummary" runat="server" HelpKey="lblCLSummary.HelpText" HelpText="Summary" ResourceKey="lblCLSummary" Text="Summary" />
					<dnn:TextEditor ID="txtCLSummary" runat="server" Height="250" Width="700" />
				</div>
				<div class="text_input_set">
					<dnn:Label ID="lblCLArticle" runat="server" HelpKey="lblCLArticle.HelpText" HelpText="Article" ResourceKey="lblCLArticle.Text" Text="Article" />
					<dnn:TextEditor ID="txtCLArticle" runat="server" Height="250" Width="700" />
				</div>
				<asp:Panel ID="pnlMainImageLocalization" runat="server">
					<div class="text_input_set">
						<dnn:Label ID="lblMainImageTitleLozalization" runat="server" CssClass="text s18" HelpText="Main image title localization." ResourceKey="lblMainImageTitleLozalization" Text="Main image title:" />
						<asp:TextBox ID="tbMainImageTitleLozalization" runat="server" CssClass="text s18" MaxLength="500" Width="300px" />
					</div>
					<div class="text_input_set">
						<dnn:Label ID="lblMainImageDescriptionLozalization" runat="server" HelpText="Main image description localization." ResourceKey="lblMainImageDescriptionLozalization" Text="Main image description:" />
						<asp:TextBox ID="tbMainImageDescriptionLozalization" runat="server" Height="50px" MaxLength="2000" TextMode="MultiLine" Width="450px" />
					</div>
				</asp:Panel>
				<asp:Panel ID="pnlCustomFieldsLocalization" runat="server" Style="margin-top: 30px;" CssClass="collapsible_box">
					<div class="text_input_set">
						<div class="text s18" style="margin-bottom: 20px;">
							<dnn:Label ID="lblCustomFieldsLocalization" runat="server" CssClass="text s18" HelpText="Custom fields localization" ResourceKey="lblCustomFieldsLocalization" Text="Custom fields:" />
						</div>
						<asp:PlaceHolder ID="phCustomFieldsLocalization" runat="server" />
					</div>
				</asp:Panel>
				<div class="text_input_set">
					<p>
						<asp:Label ID="lblErrorInfoMsg" runat="server" EnableViewState="false" ForeColor="Red" Visible="false" />
					</p>
					<asp:LinkButton ID="lbCLSaveLocalization" runat="server" CausesValidation="true" CssClass="silver_button" OnClick="lbCLSaveLocalization_Click" resourcekey="lbCLSaveLocalizationResource1" ValidationGroup="vgCLEditArticle">
						<span>Save localization</span></asp:LinkButton>
					<asp:LinkButton ID="lbCancelLocalization" runat="server" CssClass="silver_button" OnClick="lbCancelLocalization_Click" resourcekey="lbCancelLocalizationResource1">
						<span>Close</span></asp:LinkButton>
				</div>
				<p>
				</p>
				<p>
				</p>
			</asp:Panel>
			<asp:Panel ID="pnlMainEdit" runat="server" CssClass="main_content">
				<div class="text_input_set">
					<asp:LinkButton ID="lbLocalizeContent" runat="server" OnClick="lbLocalizeContent_Click" CssClass="content_localization_btn" resourcekey="lbLocalizeContentResource1">
						<span>Content localization</span></asp:LinkButton>
				</div>
				<div class="text_input_set overflow_visible no_margin">
					<dnn:Label ID="lblArticleTitle" runat="server" Text="Title" HelpText="Article Title" HelpKey="lblArticleTitle.HelpText" ResourceKey="lblArticleTitle"></dnn:Label>
					<asp:RequiredFieldValidator ID="rfvTitle" runat="server" ErrorMessage="This field is required." ValidationGroup="vgEditArticle" ControlToValidate="tbArticleTitle" SetFocusOnError="True" CssClass="input_validation_error" Display="Dynamic" resourcekey="rfvTitleResource1" />
					<asp:TextBox ID="tbArticleTitle" runat="server" CssClass="text s18" MaxLength="200" />
				</div>
				<div id="pnlSubTitle" runat="server" class="text_input_set overflow_visible">
					<dnn:Label ID="lblSubtitle" runat="server" Text="Subtitle:" HelpText="Subtitle:" HelpKey="lblSubtitle.HelpText" ResourceKey="lblSubtitle" />
					<asp:TextBox ID="txtSubtitle" runat="server" CssClass="text" MaxLength="4000" />
				</div>
				<div id="pnlSEO" runat="server" class="collapsible_box">
					<h1 class="collapsible_box_title">
						<%=SEOsettings%></h1>
					<div class="content" id="collapsible_seo_box_content">
						<div class="text_input_set">
							<div>
								<dnn:Label ID="lblArticleURL" runat="server" HelpText="Article URL" Text="Article URL" ControlName="tbArticleURL" HelpKey="lblArticleURL.HelpText" ResourceKey="lblArticleURL" />
							</div>
							<asp:TextBox ID="tbArticleURL" runat="server" CssClass="text narrow left" />
							<a id="EDN_btnReGenerateURL" class="reset_url_btn main_action_button grey" href="#"><span>
								<%=ResetarticleURL%></span></a>
						</div>
						<div class="text_input_set">
							<label>
								<%=METAdescription%></label>
							<asp:TextBox ID="tbMetaDescription" runat="server" TextMode="MultiLine" />
						</div>
						<div class="text_input_set">
							<label>
								<%=METAkeywords%></label>
							<asp:TextBox ID="tbMetaKeywords" runat="server" TextMode="MultiLine" />
						</div>
					</div>
				</div>
				<div id="pnlCategoriesSelection" class="section_box white_border_1 cyan" runat="server">
					<h1 class="section_box_title">
						<span>
							<%=Categories%></span></h1>
					<div class="content category_selection">
						<asp:UpdatePanel ID="upCategorySelection" runat="server" UpdateMode="Conditional">
							<ContentTemplate>
								<div class="edn_admin_progress_overlay_container">
									<asp:UpdateProgress ID="uppCategorySelection" runat="server" AssociatedUpdatePanelID="upCategorySelection" DisplayAfter="100" DynamicLayout="true">
										<ProgressTemplate>
											<div class="edn_admin_progress_overlay">
											</div>
										</ProgressTemplate>
									</asp:UpdateProgress>
									<asp:Label ID="lblCategoryPermissionsInfo" runat="server" ForeColor="Red" Visible="false" resourcekey="lblCategoryPermissionsInfoResource1" />
									<asp:Label ID="lblCategorySelectError" runat="server" EnableViewState="false" ForeColor="Red" Text="Please select category." Visible="false" resourcekey="lblCategorySelectErrorResource1" />
									<p class="expand_collapse_container">
										<asp:LinkButton ID="lblCategorySelectionExpandAll" runat="server" Text="Expand all" OnClick="lblCategorySelectionExpandAll_Click" resourcekey="lblCategorySelectionExpandAll" />
										|
										<asp:LinkButton ID="lblCategorySelectionCollapseAll" runat="server" Text="Collapse all" OnClick="lblCategorySelectionCollapseAll_Click" resourcekey="lblCategorySelectionCollapseAll" />
									</p>
									<asp:TreeView ID="tvCatAndSubCat" runat="server" EnableViewState="true" ForeColor="Black" NodeWrap="True" ShowCheckBoxes="All" ShowLines="True" CssClass="category_tree_view" />
								</div>
							</ContentTemplate>
						</asp:UpdatePanel>
					</div>
				</div>
				<div id="pnlSummary" runat="server" class="text_input_set">
					<dnn:Label ID="lblArticleSummary" runat="server" Text="Summary:" HelpText="Article summary:" ControlName="txtSummary" HelpKey="lblArticleSummary.HelpText" ResourceKey="lblArticleSummary" Visible="True" />
					<dnn:TextEditor ID="txtSummary" runat="server" Height="250" Width="732" />
				</div>
				<div id="pnlDetailTypeSelection" runat="server" class="section_box white_border_1 cyan" style="border-bottom: 0;">
					<h1 class="section_box_title">
						<span>
							<%=Articledetailtype %></span></h1>
					<asp:RadioButtonList ID="rblDetailType" CssClass="radio_button_list" runat="server" AutoPostBack="True" OnSelectedIndexChanged="rblDetailType_SelectedIndexChanged" RepeatDirection="Horizontal">
						<asp:ListItem Value="Text" resourcekey="ListItemResource1" Text="Text/HTML" Selected="True" />
						<asp:ListItem Value="Page" resourcekey="ListItemResource2" Text="Page" />
						<asp:ListItem Value="File" resourcekey="ListItemResource3" Text="File" />
						<asp:ListItem Value="Link" resourcekey="ListItemResource4" Text="Link" />
						<asp:ListItem Value="None" resourcekey="ListItemResource5" Text="None" />
					</asp:RadioButtonList>
				</div>
				<div id="pnlDetailTypePanels" runat="server" class="section_box white_border_1 cyan" style="border-top: 0; margin: 0; background: #ebfafe;">
					<asp:Panel ID="pnlDetailTypeText" CssClass="text_input_set" runat="server">
						<div style="margin-left: 5px;">
							<dnn:Label ID="lblContent" runat="server" Text="Content:" HelpText="Article content:" ControlName="txtContent" HelpKey="lblContent.HelpText" ResourceKey="lblContent" />
						</div>
						<dnn:TextEditor ID="txtContent" runat="server" Height="500" Width="732" />
						<p class="article_content_bottom_actions">
							<a href="#" onclick="jQuery(this).parent().siblings('div.avalible_article_tokens').toggle(200); return false;">Show/Hide token list</a>
						</p>
						<div class="avalible_article_tokens">
							<asp:TextBox ID="tbTokenList" runat="server" ReadOnly="True" TextMode="MultiLine" Height="93px" Width="650px" />
						</div>
					</asp:Panel>
					<asp:Panel ID="pnlDetailTypePage" Style="width: 500px; margin: 15px auto 0;" runat="server" Visible="false">
						<Portal:URL ID="ctlURL" runat="server" Width="250" ShowNewWindow="false" ShowUsers="false" ShowFiles="false" ShowLog="false" ShowSecure="false" ShowTabs="false" ShowTrack="false" ShowUpLoad="false" ShowUrls="false" ShowDatabase="false" UrlType="U" />
						<asp:Label ID="lblSelectDetailTarget" runat="server" Text="Select target:" AssociatedControlID="ddlDetailTarget" resourcekey="lblSelectDetailTargetResource1" />
						<asp:DropDownList ID="ddlDetailTarget" runat="server">
							<asp:ListItem resourcekey="ListItemResource6" Value="_self" Text="_self" />
							<asp:ListItem resourcekey="ListItemResource7" Value="_blank" Text="_blank" />
							<asp:ListItem resourcekey="ListItemResource8" Value="_parent" Text="_parent" />
							<asp:ListItem resourcekey="ListItemResource9" Value="_top" Text="_top" />
						</asp:DropDownList>
					</asp:Panel>
				</div>
				<asp:UpdatePanel ID="upArticleTags" runat="server" UpdateMode="Conditional">
					<ContentTemplate>
						<div class="edn_admin_progress_overlay_container">
							<asp:UpdateProgress ID="uppArticleTags" runat="server" AssociatedUpdatePanelID="upArticleTags" DisplayAfter="100" DynamicLayout="true">
								<ProgressTemplate>
									<div class="edn_admin_progress_overlay">
									</div>
								</ProgressTemplate>
							</asp:UpdateProgress>
							<div class="text_input_set">
								<dnn:Label ID="lblArticleTags" runat="server" HelpText="Article tags separated by comma ( , ):" Text="Article tags:" ControlName="tbTags" HelpKey="lblArticleTags.HelpText" ResourceKey="lblArticleTags" />
								<asp:TextBox ID="tbTags" runat="server" CssClass="text" />
							</div>
							<div class="collapsible_box no_margin visible" id="add_existing_tags_box">
								<h1 class="collapsible_box_title close">
									<%=ADDEXISTINGTAGS%></h1>
								<div class="content">
									<div class="tag_collection">
										<ul class="tag_selection_menu">
											<li class="spaced">
												<asp:LinkButton ID="lbAllAddedTags" runat="server" OnClick="lbAllAddedTags_Click"><%=AllTags%></asp:LinkButton></li>
											<li class="spaced">
												<asp:LinkButton ID="lbMostPopularTags" runat="server" OnClick="lbMostPopularTags_Click" resourcekey="lbMostPopularTagsResource1">MOST POPULAR FIRST</asp:LinkButton></li>
											<li class="spaced">
												<asp:LinkButton ID="lbLastAddedTags" runat="server" OnClick="lbLastAddedTags_Click" resourcekey="lbLastAddedTagsResource1">LAST ADDED FIRST</asp:LinkButton></li>
										</ul>
										<asp:DataList ID="dlListOfExistingTags" runat="server" RepeatColumns="5" OnItemCommand="dlListOfExistingTags_ItemCommand" RepeatDirection="Horizontal" CssClass="existing_tag_list">
											<ItemTemplate>
												<asp:LinkButton ID="lbAddTag" runat="server" CommandName="AddTag" CommandArgument='<%# Eval("Name") %>' resourcekey="lbAddTagResource1" CssClass="tag_link"><%#Eval("Name")%><span class="addtag"></span></asp:LinkButton>
											</ItemTemplate>
										</asp:DataList>
										<asp:GridView ID="gvTagsPaging" runat="server" AllowPaging="True" AutoGenerateColumns="false" CellPadding="0" CssClass="existing_tag_list_pagination article_pager" DataSourceID="odsGetTagsByName" EnableModelValidation="True" GridLines="None" OnPageIndexChanged="gvTagsPaging_PageIndexChanged"
											OnPageIndexChanging="gvTagsPaging_PageIndexChanging" PageSize="50">
											<Columns>
												<asp:BoundField DataField="Name" Visible="false" />
											</Columns>
										</asp:GridView>
									</div>
								</div>
							</div>
						</div>
					</ContentTemplate>
				</asp:UpdatePanel>
				<div class="content_token_generator gallery_item">
				</div>
				<asp:UpdatePanel ID="upArticleImages" runat="server" UpdateMode="Conditional">
					<ContentTemplate>
						<div class="edn_admin_progress_overlay_container">
							<asp:Panel ID="pnlArticleImage" CssClass="section_box white_border_1 cyan" runat="server" Visible="false">
								<h1 class="section_box_title">
									<span>
										<%=Mainarticleimage %></span></h1>
								<div class="content main_article_image">
									<div class="left_col">
										<asp:Image ID="imgArticleImage" runat="server" resourcekey="imgArticleImageResource1" />
									</div>
									<div class="right_col">
										<asp:Label ID="lblSetImageMessage" runat="server" resourcekey="lblSetImageMessageResource1" />
										<p>
											<asp:CheckBox ID="cbShowMainArticleImageList" runat="server" Checked="True" Text="Show article image on article list" Width="300px" resourcekey="cbShowMainArticleImageListResource1" />
										</p>
										<p>
											<asp:CheckBox ID="cbShowMainArticleImage" runat="server" Checked="True" Text="Show main article image" resourcekey="cbShowMainArticleImageResource1" />
											<asp:RadioButtonList runat="server" ID="rblSelectMainImageEmbedType" RepeatDirection="Horizontal" Visible="false" Style="margin-left: 15px">
												<asp:ListItem resourcekey="liImage" Value="Image" Selected="True">Image</asp:ListItem>
												<asp:ListItem resourcekey="liVideo" Value="Video">Video</asp:ListItem>
											</asp:RadioButtonList>
										</p>
										<div class="info_box check_sign">
											<asp:LinkButton ID="btnRemoveArticleImage" runat="server" CssClass="action remove_btn" OnClick="btnRemoveArticleImage_Click" Text="Remove" resourcekey="btnRemoveArticleImageResource1" /><p>
												<%=ThisImage%>
											</p>
										</div>
									</div>
									<asp:Panel ID="pnlImageTitleDescription" CssClass="section_actions_mainimage" Style="clear: left;" runat="server">
										<asp:HyperLink ID="hlOpenImageTitleDescriptionOptions" runat="server" CssClass="icon down_arrows" NavigateUrl="#"><%=ImgeTitleDescriptionSettings%></asp:HyperLink>
										<asp:Panel ID="pnlImageTitleDescriptionOptions" runat="server" Style="display: none;">
											<div style="text-align: left; padding-left: 30px; padding-bottom: 20px;" class="edit_fields">
												<span style="display: block; padding-top: 5px;">
													<%=Title%>:</span>
												<asp:TextBox ID="tbMainImageTitle" runat="server" MaxLength="500" Width="300px" />
												<span style="display: block; padding-top: 10px;">
													<%=Description%>:</span>
												<asp:TextBox ID="tbMainImageDescription" runat="server" Height="50px" MaxLength="2000" TextMode="MultiLine" Width="450px" />
											</div>
										</asp:Panel>
									</asp:Panel>
								</div>
							</asp:Panel>
							<asp:Panel ID="pnlIncludedGalleries" CssClass="section_box white_border_1 dark_blue" runat="server" Visible="false">
								<h1 class="section_box_title">
									<span>
										<%=Galleriesincluded%></span></h1>
								<div class="content included_galleries">
									<ul id="EDN_admin_included_galleries">
										<asp:Repeater ID="repIncludedGalleries" runat="server" OnItemCommand="repIncludedGalleries_ItemCommand">
											<ItemTemplate>
												<li>
													<div class="left">
													</div>
													<div class="middle">
														<p class='gallery_title <%# GetDotClass(Eval("GalleryID")) %>'>
															<%#Eval("GalleryName")%>
															<asp:Label ID="lblIntGalCategoryName" runat="server" Text='<%# GetCategoryName(Eval("GalleryID")) %>' resourcekey="lblIntGalCategoryNameResource1" />
														</p>
														<p class="gallery_actions">
															<asp:HiddenField ID="hfGalIntID" runat="server" Value='<%# Eval("GalleryID") %>' />
															<asp:LinkButton ID="lbOpenIntegratedGallery" CssClass="gallery_settings" CommandName="OpenIntGallery" CommandArgument='<%# Eval("GalleryID") %>' ToolTip="Open this gallery" runat="server" resourcekey="lbOpenIntegratedGalleryResource1" />
															<span class="border"></span><a href="#" class="up_down_arrows" title="Rearange this gallery's position by dragging and droping it"></a><span class="border"></span>
															<asp:LinkButton ID="imbDeleteIntegratedArticle" CssClass="remove" CommandName="DeleteRow" CommandArgument='<%# Container.ItemIndex %>' ToolTip="Remove the gallery from this article" runat="server" resourcekey="imbDeleteIntegratedArticleResource1" />
															<input type="hidden" name="EDN_Included_Gals" value='<%# Eval("GalleryID") %>' />
														</p>
													</div>
													<div class="right">
													</div>
												</li>
											</ItemTemplate>
										</asp:Repeater>
									</ul>
									<asp:Panel ID="pnlViewGallerySettings" CssClass="section_actions" runat="server" Visible="false">
										<asp:HyperLink ID="lbGallerySettings" runat="server" CssClass="icon down_arrows" NavigateUrl="#" resourcekey="lbGallerySettingsResource1">View settings</asp:HyperLink>
										<asp:Panel ID="pnlGallerySettings" runat="server" Style="display: none;">
											<table style="width: 600px;" class="settings_table">
												<tr>
													<td>
														<dnn:Label ID="lblGIGalleryType" runat="server" HelpText="Gallery display type:" Text="Gallery display type:" ResourceKey="lblGIGalleryType" HelpKey="lblGIGalleryType.HelpText" />
													</td>
													<td class="text_left">
														<asp:DropDownList ID="ddlGalleryDisplayType" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlGalleryDisplayType_SelectedIndexChanged">
															<asp:ListItem Value="lightbox" resourcekey="ListItemResource10">Lightbox gallery</asp:ListItem>
															<asp:ListItem Value="audio" resourcekey="ListItemResource11">Audio gallery</asp:ListItem>
															<asp:ListItem resourcekey="ListItemResource12" Value="video">Video gallery</asp:ListItem>
														</asp:DropDownList>
													</td>
												</tr>
												<tr>
													<td>
														<dnn:Label ID="lblGIGalleryPosition" runat="server" HelpText="Gallery position:" Text="Gallery position:" ResourceKey="lblGIGalleryPosition" HelpKey="lblGIGalleryPosition.HelpText" Visible="True" />
													</td>
													<td class="text_left">
														<asp:DropDownList ID="ddlGalleryPosition" runat="server">
															<asp:ListItem Value="bottom" resourcekey="ListItemResource13" Selected="True">Bottom position</asp:ListItem>
															<asp:ListItem Value="top" resourcekey="ListItemResource14">Top position</asp:ListItem>
														</asp:DropDownList>
													</td>
												</tr>
												<tr>
													<td>
														<dnn:Label ID="lblFixedResponsiveLayout" runat="server" HelpText="Fixed or responsive layout:" Text="Fixed or responsive layout:" HelpKey="lblFixedResponsiveLayout.HelpText" ResourceKey="lblFixedResponsiveLayout" />
													</td>
													<td>
														<asp:RadioButtonList ID="rblFixedResponsiveLayoutTypeSelect" runat="server" AutoPostBack="True" RepeatDirection="Horizontal" OnSelectedIndexChanged="rblFixedResponsiveLayoutTypeSelect_SelectedIndexChanged">
															<asp:ListItem resourcekey="liFixed" Selected="True" Value="fixed">Fixed Layout</asp:ListItem>
															<asp:ListItem resourcekey="liResponsive" Value="responsive">Responsive Layout</asp:ListItem>
														</asp:RadioButtonList>
													</td>
												</tr>
												<tr runat="server" id="trGalleryLightboxSelection">
													<td>
														<dnn:Label ID="lblGalleryLightbox" runat="server" HelpText="Please select gallery lightbox type." Text="Select lightbox type:" />
													</td>
													<td>
														<asp:RadioButtonList ID="rblGalleryLightbox" runat="server" RepeatDirection="Horizontal">
															<asp:ListItem Value="0" Selected="True">PrettyPhoto</asp:ListItem>
															<asp:ListItem Value="1">SocialMediaBox Lite</asp:ListItem>
														</asp:RadioButtonList>
													</td>
												</tr>
												<tr>
													<td>
														<dnn:Label ID="lblGIPagerStyle" runat="server" HelpText="Pager style:" Text="Pager style:" Visible="false" />
													</td>
													<td class="text_left">
														<asp:DropDownList ID="ddlGIPagerStyle" runat="server" Visible="false">
															<asp:ListItem Value="Numeric" resourcekey="ListItemResource15">Numeric</asp:ListItem>
															<asp:ListItem Value="NextPrevious" resourcekey="ListItemResource16">Arrows (Next, Previous)</asp:ListItem>
															<asp:ListItem Value="NextPreviousFirstLast" resourcekey="ListItemResource17">Arrows (Next, Previous, First, Last)</asp:ListItem>
														</asp:DropDownList>
													</td>
												</tr>
											</table>
											<asp:Panel ID="pnlChameleonGallery" runat="server" Visible="false">
												<table style="width: 600px;" class="settings_table">
													<tr>
														<td>
															<dnn:Label ID="lblGalleryWidth" runat="server" HelpText="Gallery width." Text="Gallery width:" HelpKey="lblGalleryWidth.HelpText" ResourceKey="lblGalleryWidth" />
														</td>
														<td class="text_left">
															<asp:TextBox ID="tbxGalleryWidth" runat="server" Width="50px" Text="700" />
															<asp:Label ID="lblChamMainPanelWidthType" runat="server" Text="%" Visible="false" />
															<asp:RequiredFieldValidator ID="rfvRhumbImageWidth" runat="server" ControlToValidate="tbxGalleryWidth" ErrorMessage="This filed is required." SetFocusOnError="True" ValidationGroup="vgSettings" resourcekey="rfvRhumbImageWidth0Resource1" Display="Dynamic" />
															<asp:CompareValidator ID="cvLightBoxGalleryNumberOfItems" runat="server" ControlToValidate="tbxGalleryWidth" Display="Dynamic" ErrorMessage="Please enter number only." Operator="DataTypeCheck" Type="Integer" ValidationGroup="vgEditArticle" resourcekey="cvLightBoxGalleryNumberOfItemsResource1"
																SetFocusOnError="True" />
															<asp:RangeValidator ID="rvChameleonWidthPerct" runat="server" ControlToValidate="tbxGalleryWidth" Display="Dynamic" Enabled="false" ErrorMessage="Enter value between 0-100." MaximumValue="100" MinimumValue="0" resourcekey="rvChameleonWidthPerct.ErrorMessage"
																SetFocusOnError="True" Type="Integer" ValidationGroup="vgEditArticle" Visible="false" />
														</td>
													</tr>
													<tr id="trChameleonResponsiveMainImageWidth" runat="server">
														<td>
															<dnn:Label ID="lblChameleonResponsiveMainImageWidth" runat="server" HelpText="Max width used to generate main responsive image." Text="Main image width:" HelpKey="lblChameleonResponsiveMainImageWidth.HelpText" />
														</td>
														<td class="text_left">
															<asp:TextBox ID="tbxChameleonResponsiveMainImageWidth" runat="server" Width="50px" Text="600" />
															<asp:Label ID="lblChameleonResponsiveMainImageWidthPX" runat="server" Text="px" />
															<asp:RequiredFieldValidator ID="rfvtbxChameleonResponsiveMainImageWidth" runat="server" ControlToValidate="tbxChameleonResponsiveMainImageWidth" Display="Dynamic" ErrorMessage="This filed is required." resourcekey="rfvRhumbImageWidth1Resource1.ErrorMessage"
																SetFocusOnError="True" ValidationGroup="vgSettings" />
															<asp:CompareValidator ID="cvChameleonResponsiveMainImageWidth" runat="server" ControlToValidate="tbxChameleonResponsiveMainImageWidth" Display="Dynamic" ErrorMessage="Please enter number only." Operator="DataTypeCheck" resourcekey="cvLightBoxGalleryNumberOfItems0Resource1.ErrorMessage"
																Type="Integer" ValidationGroup="vgTGSettings" />
														</td>
													</tr>
													<tr>
														<td>
															<dnn:Label ID="lblGalleryHeight" runat="server" HelpText="Gallery height." Text="Gallery height:" ResourceKey="lblGalleryHeight" HelpKey="lblGalleryHeight.HelpText" />
														</td>
														<td class="text_left">
															<asp:TextBox ID="tbxGalleryHeight" runat="server" Width="50px" Text="600" />
															<asp:Label ID="lblChamMainPanelHeightType" runat="server" Text="px" Visible="false" />
															<asp:RequiredFieldValidator ID="rfvRhumbImageWidth1" runat="server" ControlToValidate="tbxGalleryHeight" ErrorMessage="This filed is required." SetFocusOnError="True" ValidationGroup="vgSettings" resourcekey="rfvRhumbImageWidth1Resource1" />
															<asp:CompareValidator ID="cvLightBoxGalleryHeight" runat="server" ControlToValidate="tbxGalleryHeight" Display="Dynamic" ErrorMessage="Please enter number only." Operator="DataTypeCheck" Type="Integer" ValidationGroup="vgEditArticle" resourcekey="cvLightBoxGalleryNumberOfItems0Resource1" />
														</td>
													</tr>
													<tr>
														<td>
															<dnn:Label ID="lblChameleonResizeMethod" runat="server" HelpText="Select resize method to use when generating thumbnails for imaes." Text="Thumbnail creation resize method:" HelpKey="lblLightboxGalleryResizeMethod.HelpText" ResourceKey="lblLightboxGalleryResizeMethod" />
														</td>
														<td class="text_left">
															<asp:RadioButtonList ID="rblChameleonResizeMethod" runat="server" AutoPostBack="True" RepeatDirection="Horizontal" OnSelectedIndexChanged="rblChameleonResizeMethod_SelectedIndexChanged">
																<asp:ListItem resourcekey="liCrop" Selected="True" Value="Crop">Resize and crop</asp:ListItem>
																<asp:ListItem resourcekey="liPropotional" Value="Proportional">Proportional resize</asp:ListItem>
																<asp:ListItem resourcekey="liCropAndPropotional" Value="CropHorizontalProportionalVertical">Resize and crop horizontal, proportionally resize vertical images</asp:ListItem>
															</asp:RadioButtonList>
														</td>
													</tr>
													<tr>
														<td>
															<dnn:Label ID="lblChameleonLayout" runat="server" HelpText="Gallery layout" Text="Gallery layout:" ResourceKey="lblChameleonLayout" HelpKey="lblChameleonLayout.HelpText" />
														</td>
														<td class="text_left">
															<asp:DropDownList ID="ddlChameleonLayout" runat="server">
															</asp:DropDownList>
														</td>
													</tr>
													<tr>
														<td>
															<dnn:Label ID="lblChameleonLayoutTheme" runat="server" HelpText="Chameleon theme:" Text="Chameleon theme:" ResourceKey="lblChameleonLayoutTheme" HelpKey="lblChameleonLayoutTheme.HelpText" />
														</td>
														<td class="text_left">
															<asp:DropDownList ID="ddlChameleonGalleryThemeSelect" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlChameleonGalleryThemeSelect_SelectedIndexChanged">
															</asp:DropDownList>
														</td>
													</tr>
													<tr>
														<td>
															<dnn:Label ID="lblChameleonLayoutThemeStyle" runat="server" HelpText="Chameleon theme style:" Text="Chameleon theme style:" ResourceKey="lblChameleonLayoutThemeStyle" HelpKey="lblChameleonLayoutThemeStyle.HelpText" />
														</td>
														<td class="text_left">
															<asp:DropDownList ID="ddlChameleonGalleryThemeSelectStyling" runat="server">
															</asp:DropDownList>
														</td>
													</tr>
												</table>
											</asp:Panel>
											<asp:Panel ID="pnlOldGalleryes" runat="server">
												<table style="width: 600px;" class="settings_table">
													<tr>
														<td>
															<dnn:Label ID="lblGIImagesResize" runat="server" HelpText="Resize and crop images. If un-checked images will be resized proportionaly.:" Text="Resize and crop images:" Visible="false" />
														</td>
														<td class="text_left">
															<asp:CheckBox ID="cbGICropImages" runat="server" resourcekey="cbGICropImagesResource1" Visible="false" />
														</td>
													</tr>
													<tr>
														<td>
															<dnn:Label ID="lblGIThumbWidth" runat="server" HelpText="Thumbnail width:" Text="Thumbnail width:" ResourceKey="lblGIThumbWidth" HelpKey="lblGIThumbWidth.HelpText" />
														</td>
														<td class="text_left">
															<asp:TextBox ID="tbGIThumbnailWidth" runat="server" Width="50px" Text="100" />
															<asp:RequiredFieldValidator ID="rfvGIThumbanilWidth" runat="server" ControlToValidate="tbGIThumbnailWidth" Display="Dynamic" ErrorMessage="This filed is required." resourcekey="rfvGIThumbanilWidthResource1" SetFocusOnError="True" ValidationGroup="vgAddArticle" />
															<asp:CompareValidator ID="cvGIThumbnailWidth" runat="server" ControlToValidate="tbGIThumbnailWidth" ErrorMessage="Please enter number." Operator="DataTypeCheck" resourcekey="cvGIThumbnailWidthResource1" Type="Integer" ValidationGroup="vgAddArticle"></asp:CompareValidator>
														</td>
													</tr>
													<tr>
														<td>
															<dnn:Label ID="lblGIThumbHeight" runat="server" HelpText="Thumbnail height:" Text="Thumbnail height:" ResourceKey="lblGIThumbHeight" HelpKey="lblGIThumbHeight.HelpText" />
														</td>
														<td class="text_left">
															<asp:TextBox ID="tbGIThumbnailHeight" runat="server" Width="50px" Text="100" />
															<asp:RequiredFieldValidator ID="rfvGIThumbanilHeight" runat="server" ControlToValidate="tbGIThumbnailHeight" Display="Dynamic" ErrorMessage="This filed is required." SetFocusOnError="True" ValidationGroup="vgAddArticle" resourcekey="rfvGIThumbanilHeightResource1" />
															<asp:CompareValidator ID="cvGIThumbnailHeight" runat="server" ControlToValidate="tbGIThumbnailHeight" ErrorMessage="Please enter number." Operator="DataTypeCheck" Type="Integer" ValidationGroup="vgAddArticle" resourcekey="cvGIThumbnailHeightResource1"></asp:CompareValidator>
														</td>
													</tr>
													<tr>
														<td>
															<dnn:Label ID="lblGIItemsPerPage" runat="server" HelpText="Items per page:" Text="Items per page:" HelpKey="lblGIItemsPerPage.HelpText" ResourceKey="lblGIItemsPerPage" />
														</td>
														<td class="text_left">
															<asp:TextBox ID="tbGIItemsPerPage" runat="server" Width="50px" resourcekey="tbGIItemsPerPageResource1" Text="4" />
															<asp:RequiredFieldValidator ID="rfvGIItemsPerPage" runat="server" ControlToValidate="tbGIItemsPerPage" Display="Dynamic" ErrorMessage="This filed is required." SetFocusOnError="True" ValidationGroup="vgAddArticle" resourcekey="rfvGIItemsPerPageResource1" />
															<asp:CompareValidator ID="cvGINumber" runat="server" ControlToValidate="tbGIItemsPerPage" ErrorMessage="Please enter number." Operator="DataTypeCheck" Type="Integer" ValidationGroup="vgAddArticle" resourcekey="cvGINumberResource1"></asp:CompareValidator>
														</td>
													</tr>
													<tr>
														<td>
															<dnn:Label ID="lblGINumberOfColumns" runat="server" HelpText="Number of columns:" Text="Number of columns:" HelpKey="lblGINumberOfColumns.HelpText" ResourceKey="lblGINumberOfColumns" />
														</td>
														<td class="text_left">
															<asp:TextBox ID="tbNumberOfColumns" runat="server" resourcekey="tbNumberOfColumnsResource1" Width="50px" Text="4" />
															<asp:RequiredFieldValidator ID="rfvGIItemsPerPage0" runat="server" ControlToValidate="tbNumberOfColumns" Display="Dynamic" ErrorMessage="This filed is required." resourcekey="rfvGIItemsPerPage0Resource1" SetFocusOnError="True" ValidationGroup="vgAddArticle" />
															<asp:CompareValidator ID="cvGINumber0" runat="server" ControlToValidate="tbNumberOfColumns" ErrorMessage="Please enter number." Operator="DataTypeCheck" resourcekey="cvGINumber0Resource1" Type="Integer" ValidationGroup="vgAddArticle"></asp:CompareValidator>
														</td>
													</tr>
													<tr>
														<td>
															<dnn:Label ID="lblLightboxGalleryResizeMethod" runat="server" HelpText="Select resize method to use when generating thumbnails for imaes." Text="Thumbnail creation resize method:" HelpKey="lblLightboxGalleryResizeMethod.HelpText" ResourceKey="lblLightboxGalleryResizeMethod" />
														</td>
														<td class="text_left">
															<asp:RadioButtonList ID="rblLightboxGalleryResizeMethod" runat="server" AutoPostBack="False" RepeatDirection="Horizontal">
																<asp:ListItem resourcekey="liCrop" Selected="True" Value="Crop">Resize and crop</asp:ListItem>
																<asp:ListItem resourcekey="liPropotional" Value="Proportional">Proportional resize</asp:ListItem>
															</asp:RadioButtonList>
														</td>
													</tr>
													<tr>
														<td>
															<dnn:Label ID="lblGIDisplayItemTitle" runat="server" HelpText="Display item title:" Text="Display item title:" ResourceKey="lblGIDisplayItemTitle" HelpKey="lblGIDisplayItemTitle.HelpText" />
														</td>
														<td class="text_left">
															<asp:CheckBox ID="cbGIDisplayItemTitle" runat="server" />
														</td>
													</tr>
													<tr id="rowOldGalleryTitleLightbox" runat="server">
														<td>
															<dnn:Label ID="lblGIDisplayItemTitleLightBox" runat="server" HelpText="Display item title in Lightbox:" Text="Display item title in Lightbox:" ResourceKey="lblGIDisplayItemTitleLightBox" HelpKey="lblGIDisplayItemTitleLightBox.HelpText" />
														</td>
														<td class="text_left">
															<asp:CheckBox ID="cbGIDisplayItemTitleLightBox" runat="server" />
														</td>
													</tr>
													<tr>
														<td>
															<dnn:Label ID="lblGIDisplayItemDescription" runat="server" HelpText="Display item description:" Text="Display item description:" HelpKey="lblGIDisplayItemDescription.HelpText" ResourceKey="lblGIDisplayItemDescription" />
														</td>
														<td class="text_left">
															<asp:CheckBox ID="cbGIDisplayItemDescription" runat="server" />
														</td>
													</tr>
													<tr id="rowOldGalleryDescriptionLightbox" runat="server">
														<td>
															<dnn:Label ID="lblGIDisplayItemDescriptionLightBox" runat="server" HelpText="Display item description in Lightbox:" Text="Display item description in Lightbox:" ResourceKey="lblGIDisplayItemDescriptionLightBox" HelpKey="lblGIDisplayItemDescriptionLightBox.HelpText" />
														</td>
														<td class="text_left">
															<asp:CheckBox ID="cbGIDisplayItemDescriptionLightBox" runat="server" resourcekey="cbGIDisplayItemDescriptionLightBoxResource1" />
														</td>
													</tr>
													<tr>
														<td>
															<dnn:Label ID="lblGIGalleryTheme" runat="server" HelpText="Gallery theme:" Text="Gallery theme:" ResourceKey="lblGIGalleryTheme" HelpKey="lblGIGalleryTheme.HelpText" />
														</td>
														<td class="text_left">
															<asp:DropDownList ID="ddlGalleryTheme" runat="server" />
														</td>
													</tr>
												</table>
											</asp:Panel>
										</asp:Panel>
									</asp:Panel>
								</div>
							</asp:Panel>
							<div class="section_box">
								<h1 class="section_box_title">
									<span>
										<%=GalleryPanel%></span></h1>
								<ul class="tabs">
									<li>
										<asp:LinkButton ID="lbArticleGalleryImages" runat="server" CssClass="btnArticleimages" OnClick="lbArticleGallery_Click" resourcekey="lbArticleGalleryImagesResource1">ARTICLE<span class="blue dot"></span></asp:LinkButton></li>
									<li>
										<asp:LinkButton ID="lbSharedArticleGalleryImages" runat="server" CssClass="btnArticleimages" OnClick="lbSharedArticleGallery_Click" resourcekey="lbSharedArticleGalleryImagesResource1">SHARED</asp:LinkButton></li>
									<li>
										<asp:LinkButton ID="lbCustomGallery" runat="server" CssClass="btnArticleimages" OnClick="lbCustomGallery_Click" resourcekey="lbCustomGalleryResource1">CUSTOM<span class="yellow dot"></span></asp:LinkButton></li>
								</ul>
								<div class="content tabbed dark_blue">
									<asp:Panel ID="pnlCustomIntegrationAndUpload" runat="server" Visible="false">
										<div class="edg_gallery_selection_container">
											<div class="category_and_gallery_selection">
												<div class="category selection">
													<asp:Label ID="lblCategorySelect" runat="server" Text="Select category:" resourcekey="lblCategorySelectResource1" />
													<asp:DropDownList ID="ddlCategories" runat="server" AppendDataBoundItems="True" AutoPostBack="True" DataTextField="CategoryName" DataValueField="CategoryID" OnDataBound="ddlCategories_DataBound" OnSelectedIndexChanged="ddlCategories_SelectedIndexChanged">
														<asp:ListItem Value="0" resourcekey="ListItemResource18">Select category</asp:ListItem>
													</asp:DropDownList>
												</div>
												<div class="gallery selection">
													<asp:Label ID="lblGallerySelect" runat="server" Text="Select gallery: " resourcekey="lblGallerySelectResource1" />
													<asp:DropDownList ID="ddlGaleries" runat="server" AppendDataBoundItems="True" AutoPostBack="True" DataTextField="GalleryName" DataValueField="GalleryID" OnDataBound="ddlGaleries_DataBound" OnSelectedIndexChanged="ddlGaleries_SelectedIndexChanged">
														<asp:ListItem Value="-2" resourcekey="ListItemResource19">Select gallery</asp:ListItem>
													</asp:DropDownList>
												</div>
												<asp:LinkButton ID="btnRefrehsData" runat="server" CssClass="refresh" OnClick="btnRefrehsData_Click" resourcekey="btnRefrehsDataResource1" />
											</div>
											<div class="actions">
												<asp:LinkButton ID="btnIntegGallery" runat="server" CssClass="add_gallery_to_article" OnClick="btnIntegGallery_Click" Text="Add gallery to article" resourcekey="btnIntegGalleryResource1" />
											</div>
										</div>
										<asp:Panel ID="pnlGalleryMediaUpload" runat="server" Visible="false">
											<div id="galleryUploadifyContainer" class="uploadify_container" runat="server">
												<div style="display: block; float: left; margin-left: 30px;">
													<asp:FileUpload ID="GalfileInput" runat="server" resourcekey="GalfileInputResource1" />
												</div>
												<div style="display: block; float: left; margin-left: 15px;">
													<a class="start_upload" href="javascript:<%=jQueryPrefix%>('#<%=GalfileInput.ClientID%>').uploadifySettings('scriptData', { 'galleryId': '<%=ddlGaleries.SelectedValue%>','resize':document.getElementById('<%=hfResize.ClientID%>').value, 'width': document.getElementById('<%=hfResizeWidth.ClientID%>').value,'height':document.getElementById('<%=hfResizeHeight.ClientID%>').value});<%=jQueryPrefix%>('#<%=GalfileInput.ClientID%>').uploadifyUpload();">
														<%=StartUpload%></a>
												</div>
											</div>
											<div id="galleryFineUploaderContainer" class="EDS_simpleFineUploader galleryFineUploader" visible="false" runat="server">
												<div class="uploader">
												</div>
												<div class="uploadControls">
													<div class="actions">
														<span class="action fileSelection">
															<asp:Label ID="galleryFineUploaderSelectFiles" runat="server" resourcekey="fineUploaderSelectFiles" Text="Select images" />
															<span class="dnnInputFileWrapper">
																<input type="file" value="" multiple="multiple" /></span> </span><span class="action upload">
																	<asp:Label ID="galleryFineUploaderStartUpload" runat="server" resourcekey="fineUploaderStartUpload" Text="Start upload" />
																</span>
													</div>
													<div class="dndContainer">
														<p>
															<asp:Label ID="galleryFineUploaderDragImagesHere" runat="server" resourcekey="fineUploaderDragImagesHere" Text="Drag images here" />
														</p>
													</div>
												</div>
												<div class="uploadDetails">
													<ol class="fileUploadList">
													</ol>
												</div>
											</div>
											<div class="add_video_by_url">
												<p>
													<asp:Label runat="server" resourcekey="addVideoFromYouTube" Text="Add video from YouTube or Vimeo:" ID="lblCustomAddEmbedToGallery" />
													<asp:TextBox runat="server" ID="tbCustomEmbedVideoURL" ValidationGroup="vgCustomAddEmbedVideo" onblur="if(this.value=='') {this.value=this.defaultValue;}" onfocus="if(this.defaultValue==this.value) {this.value = '';}" Text="Enter video URL..." />
													<asp:LinkButton runat="server" ID="lbCustomAddEmedVideoToGallery" CssClass="add_video" ValidationGroup="vgCustomAddEmbedVideo" OnClick="lbCustomAddEmedVideoToGallery_Click">Add video</asp:LinkButton>
												</p>
												<p class="validators">
													<asp:CustomValidator ID="cvCustomAddEmbedVideo" runat="server" ClientValidationFunction="ClientValidateEmbedURL" Display="Dynamic" ErrorMessage="Invalid URL." ValidationGroup="vgCustomAddEmbedVideo" ControlToValidate="tbCustomEmbedVideoURL" SetFocusOnError="True"></asp:CustomValidator>
													<asp:RequiredFieldValidator ID="rfvCustomAddEmbedVideoURL" runat="server" ControlToValidate="tbCustomEmbedVideoURL" Display="Dynamic" ErrorMessage="Please enter valid URL." SetFocusOnError="True" ValidationGroup="vgCustomAddEmbedVideo"></asp:RequiredFieldValidator>
												</p>
											</div>
										</asp:Panel>
									</asp:Panel>
									<asp:Panel ID="pnlArticleGalleryUpload" runat="server" Visible="false">
										<asp:Panel ID="pnlEmptyGallery" runat="server" CssClass="info_box attention add_gallery">
											<asp:LinkButton ID="ibAddImages" runat="server" OnClick="ibAddImages_Click" CssClass="action add_gallery" ValidationGroup="vgCreateGallery" resourcekey="ibAddImagesResource1">Add gallery</asp:LinkButton>
											<p>
												<%=Thegalleryisempty %>
											</p>
										</asp:Panel>
										<asp:Panel ID="pnlDisplayArticleGallery" runat="server" CssClass="info_box warning add_gallery">
											<asp:LinkButton ID="ibDisplayArticleGallery" runat="server" OnClick="lbDisplayArticleGallery_Click" CssClass="action add_gallery" resourcekey="ibDisplayArticleGalleryResource1">Display this gallery</asp:LinkButton>
											<p>
												<%=NotWithArticle %>
											</p>
										</asp:Panel>
										<asp:Panel ID="pnlRemoveArticleGallery" runat="server" CssClass="info_box attention add_gallery" Visible="false">
											<asp:LinkButton ID="lbRemoveDisplayArticleGallery" runat="server" CssClass="action remove_btn" OnClick="lbRemoveDisplayArticleGallery_Click" resourcekey="lbRemoveDisplayArticleGalleryResource1">Do not display gallery</asp:LinkButton>
											<p>
												<%=GalleryWithArticle%>
											</p>
										</asp:Panel>
										<asp:Panel ID="pnlArticleImageUpload" runat="server">
											<asp:CheckBox ID="cbShowGallery" runat="server" Text="Show gallery" Visible="false" resourcekey="cbShowGalleryResource1" />
											<div id="articleUploadifyContainer" class="uploadify_container" runat="server">
												<div style="display: block; float: left; margin-left: 30px;">
													<asp:FileUpload ID="fileInput" runat="server" resourcekey="fileInputResource2" />
												</div>
												<div style="display: block; float: left; margin-left: 15px;">
													<a class="start_upload" href="javascript:<%=jQueryPrefix%>('#<%=fileInput.ClientID%>').uploadifySettings('scriptData', {'resize':document.getElementById('<%=hfResize.ClientID%>').value, 'width': document.getElementById('<%=hfResizeWidth.ClientID%>').value,'height':document.getElementById('<%=hfResizeHeight.ClientID%>').value});<%=jQueryPrefix%>('#<%=fileInput.ClientID%>').uploadifyUpload();">
														<%=StartUpload %></a>
												</div>
											</div>
											<div id="articleFineUploaderContainer" class="EDS_simpleFineUploader galleryFineUploader" visible="false" runat="server">
												<div class="uploader">
												</div>
												<div class="uploadControls">
													<div class="actions">
														<span class="action fileSelection">
															<asp:Label ID="lblArticleFineUploaderSelectFiles" runat="server" resourcekey="fineUploaderSelectFiles" Text="Select images" />
															<span class="dnnInputFileWrapper">
																<input type="file" value="" multiple="multiple" /></span> </span><span class="action upload">
																	<asp:Label ID="lblArticleFineUploaderStartUpload" runat="server" resourcekey="fineUploaderStartUpload" Text="Start upload" />
																</span>
													</div>
													<div class="dndContainer">
														<p>
															<asp:Label ID="lblArticleFineUploaderDragImagesHere" runat="server" resourcekey="fineUploaderDragImagesHere" Text="Drag images here" />
														</p>
													</div>
												</div>
												<div class="uploadDetails">
													<ol class="fileUploadList">
													</ol>
												</div>
											</div>
											<div class="add_video_by_url">
												<p>
													<asp:Label runat="server" resourcekey="addVideoFromYouTube" Text="Add video from YouTube or Vimeo:" ID="lblAddEmbedToGallery" />
													<asp:TextBox runat="server" ID="tbEmbedVideoURL" ValidationGroup="vgAddEmbedVideo" onblur="if(this.value=='') {this.value=this.defaultValue;}" onfocus="if(this.defaultValue==this.value) {this.value = '';}" Text="Enter video URL..." />
													<asp:LinkButton runat="server" ID="lbAddEmedVideoToGallery" ValidationGroup="vgAddEmbedVideo" OnClick="lbAddEmedVideoToGallery_Click" CssClass="add_video">Add video</asp:LinkButton>
												</p>
												<p class="validators">
													<asp:CustomValidator ID="cvMainGalleryAddEmbedVideo" runat="server" ClientValidationFunction="ClientValidateEmbedURL" Display="Dynamic" ErrorMessage="Invalid URL." ValidationGroup="vgAddEmbedVideo" ControlToValidate="tbEmbedVideoURL" SetFocusOnError="True"></asp:CustomValidator>
													<asp:RequiredFieldValidator ID="rfvAddEmbedVideoURL" runat="server" ControlToValidate="tbEmbedVideoURL" Display="Dynamic" ErrorMessage="Please enter valid URL." SetFocusOnError="True" ValidationGroup="vgAddEmbedVideo"></asp:RequiredFieldValidator>
												</p>
											</div>
											<div runat="server" id="divUploadToWistiaService" class="add_video_by_url" visible="False">
												<p>
													<asp:Label runat="server" Text="Upload video to Wistia service:" ID="lblUploadToWistiaService" resourcekey="lblUploadToWistiaService" />
													<asp:FileUpload ID="fuWistiaVideoFileInput" runat="server" EnableTheming="True" />
													<asp:Button ID="btnWistiaSingleUpload" runat="server" resourcekey="btnWistiaSingleUpload" Text="Upload" OnClick="btnWistiaSingleUpload_Click" />
												</p>
												<p class="validators">
													<asp:Label ID="lblWistiaSingleUploadMessage" runat="server" EnableViewState="False"></asp:Label>
												</p>
											</div>
										</asp:Panel>
									</asp:Panel>
									<asp:Panel ID="pnlSharedGalleryUpload" runat="server" Visible="false">
										<div id="sharedUploadifyContainer" class="uploadify_container" runat="server">
											<div style="display: block; float: left; margin-left: 30px;">
												<asp:FileUpload ID="SharedfileInput" runat="server" />
											</div>
											<div style="display: block; float: left; margin-left: 15px;">
												<a class="start_upload" href="javascript:<%=jQueryPrefix%>('#<%=SharedfileInput.ClientID%>').uploadifySettings('scriptData', {'resize':document.getElementById('<%=hfResize.ClientID%>').value, 'width': document.getElementById('<%=hfResizeWidth.ClientID%>').value,'height':document.getElementById('<%=hfResizeHeight.ClientID%>').value});<%=jQueryPrefix%>('#<%=SharedfileInput.ClientID%>').uploadifyUpload();">
													<%=StartUpload %></a>
											</div>
										</div>
										<div id="sharedFineUploaderContainer" class="EDS_simpleFineUploader galleryFineUploader" visible="false" runat="server">
											<div class="uploader">
											</div>
											<div class="uploadControls">
												<div class="actions">
													<span class="action fileSelection">
														<asp:Label ID="sharedFineUploaderSelectFiles" runat="server" resourcekey="fineUploaderSelectFiles" Text="Select images" />
														<span class="dnnInputFileWrapper">
															<input type="file" value="" multiple="multiple" /></span> </span><span class="action upload">
																<asp:Label ID="sharedFineUploaderStartUpload" runat="server" resourcekey="fineUploaderStartUpload" Text="Start upload" />
															</span>
												</div>
												<div class="dndContainer">
													<p>
														<asp:Label ID="sharedFineUploaderDragImagesHere" runat="server" resourcekey="fineUploaderDragImagesHere" Text="Drag images here" />
													</p>
												</div>
											</div>
											<div class="uploadDetails">
												<ol class="fileUploadList">
												</ol>
											</div>
										</div>
										<div class="add_video_by_url">
											<p>
												<asp:Label runat="server" resourcekey="addVideoFromYouTube" Text="Add a video from YouTube or Vimeo:" ID="lblSharedAddEmbedToGallery" />
												<asp:TextBox runat="server" ID="tbSharedEmbedVideoURL" ValidationGroup="vgSharedAddEmbedVideo" onblur="if(this.value=='') {this.value=this.defaultValue;}" onfocus="if(this.defaultValue==this.value) {this.value = '';}" Text="Enter video URL..." />
												<asp:LinkButton runat="server" ID="lbSharedAddEmedVideoToGallery" ValidationGroup="vgSharedAddEmbedVideo" OnClick="lbSharedAddEmedVideoToGallery_Click" CssClass="add_video">Add video</asp:LinkButton>
											</p>
											<p class="validators">
												<asp:CustomValidator ID="cvSharedAddEmbedVideo" runat="server" ClientValidationFunction="ClientValidateEmbedURL" Display="Dynamic" ErrorMessage="Invalid URL." ValidationGroup="vgSharedAddEmbedVideo" ControlToValidate="tbSharedEmbedVideoURL" SetFocusOnError="True"></asp:CustomValidator>
												<asp:RequiredFieldValidator ID="rfvSharedAddEmbedVideoURL" runat="server" ControlToValidate="tbSharedEmbedVideoURL" Display="Dynamic" ErrorMessage="Please enter valid URL." SetFocusOnError="True" ValidationGroup="vgSharedAddEmbedVideo"></asp:RequiredFieldValidator>
											</p>
										</div>
									</asp:Panel>
									<asp:Button ID="galleryUploadComplete" runat="server" OnClick="galleryUploadComplete_Click" Text="Button" Style="display: none;" />
								</div>
							</div>
							<div class="section_box no_top_margin">
								<div class="content dark_blue">
									<div class="gallery_items_container">
										<asp:GridView ID="gvArticleMediaList" runat="server" AllowPaging="True" AutoGenerateColumns="false" Border="0" CellPadding="0" CssClass="gallery_items_table" DataKeyNames="PictureID" EnableModelValidation="True" HorizontalAlign="Center" OnDataBound="gvArticleMediaList_DataBound"
											OnRowCommand="gvArticleMediaList_RowCommand" OnRowDeleted="gvArticleMediaList_RowDeleted" OnRowDeleting="gvArticleMediaList_RowDeleting" ShowFooter="True" Width="700px" GridLines="None">
											<AlternatingRowStyle CssClass="main_row second" />
											<Columns>
												<asp:TemplateField HeaderText="Media list" SortExpression="Position">
													<EditItemTemplate>
														<table cellpadding="0" cellspacing="0" width="100%">
															<tr>
																<td class="action">
																	<asp:LinkButton ID="LinkButton5" runat="server" CommandName="Update" CssClass="action_btn update" resourcekey="LinkButton5Resource1"></asp:LinkButton>
																	<asp:LinkButton ID="LinkButton6" runat="server" CausesValidation="false" CommandName="Cancel" CssClass="action_btn cancel" resourcekey="LinkButton6Resource1"></asp:LinkButton>
																</td>
																<td class="edit_fields">
																	<asp:TextBox ID="TextBox3" runat="server" Text='<%# Bind("Title") %>' />
																</td>
																<td class="edit_fields">
																	<asp:TextBox ID="TextBox2" runat="server" Text='<%# Bind("Description") %>' TextMode="MultiLine" />
																</td>
															</tr>
														</table>
													</EditItemTemplate>
													<HeaderTemplate>
														<table cellpadding="0" cellspacing="0" width="100%">
															<tr>
																<td class="header_field action">
																	<%=Action %>
																</td>
																<td class="header_field image"></td>
																<td class="header_field title">
																	<%=Title%>
																</td>
																<td class="header_field description">
																	<%=Description %>
																</td>
																<td class="header_field"></td>
															</tr>
														</table>
													</HeaderTemplate>
													<ItemTemplate>
														<table cellpadding="0" cellspacing="0" width="100%">
															<tr>
																<td class="action">
																	<asp:LinkButton ID="lbSetArticleImageArtGallery" runat="server" CommandArgument='<%# Eval("PictureID") %>' CommandName="SetArticleImage" CssClass="action_btn article_img" resourcekey="lbSetArticleImageArtGalleryResource1">Set as main article image</asp:LinkButton>
																	<asp:LinkButton ID="LinkButton3" runat="server" CausesValidation="false" CommandName="Edit" CssClass="action_btn edit" resourcekey="LinkButton3Resource1"></asp:LinkButton>
																	<asp:LinkButton ID="LinkButton4" runat="server" CausesValidation="false" CommandName="Delete" CssClass="action_btn delete" resourcekey="LinkButton4Resource1"></asp:LinkButton>
																	<asp:LinkButton ID="lbLocalizeimage" runat="server" CommandArgument='<%# Eval("PictureID") %>' CommandName="LocalizeImage" CssClass="image_localization" resourcekey="lbLocalizeimageResource1" Visible='<%# LocalizationEnabled%>'>Localize content</asp:LinkButton>
																</td>
																<td class="image">
																	<div class="wrapper">
																		<a href='<%#Eval("MediaType").ToString()=="Image"?Eval("FileName").ToString():"#"%>' target="_blank">
																			<asp:Image ID="Image1" runat="server" ImageUrl='<%#FixImageUrl(Eval("ThumbUrl").ToString())%>' />
																		</a>
																	</div>
																</td>
																<td class="title">
																	<asp:Label ID="Label4" runat="server" resourcekey="Label4Resource1" Text='<%# Bind("Title") %>' />
																</td>
																<td class="description">
																	<asp:Label ID="Label6" runat="server" resourcekey="Label6Resource1" Text='<%# Bind("Description") %>' />
																</td>
																<td class="position_show_type">
																	<div class="action_box">
																		<div class="action_wrapper">
																			<asp:ImageButton ID="imbMediaUp" runat="server" CausesValidation="false" CommandArgument='<%# Eval("PictureID") %>' CommandName="Up" CssClass="position_btn up" ImageUrl="~/images/action_up.gif" />
																			<asp:ImageButton ID="imbMediaDown" runat="server" CausesValidation="false" CommandArgument='<%# Eval("PictureID") %>' CommandName="Down" CssClass="position_btn down" ImageUrl="~/images/action_down.gif" />
																		</div>
																		<span class="text">
																			<%=Position%></span>
																	</div>
																	<div class="action_box">
																		<div class="action_wrapper">
																			<asp:LinkButton ID="lbArticleGalleryItemState" runat="server" CommandArgument='<%# Eval("PictureID") %>' CommandName="ChangeShow" CssClass='<%# GetShowMediaClass(Eval("ShowMedia")) %>' resourcekey="lbArticleGalleryItemStateResource1"></asp:LinkButton>
																		</div>
																		<span class="text">
																			<%=Show%></span>
																	</div>
																	<div class="action_box">
																		<div class="action_wrapper">
																			<asp:Label ID="imgMediaType" runat="server" CssClass='<%# GetMediaTypeClass(Eval("MediaType")) %>' resourcekey="imgMediaTypeResource1" />
																		</div>
																		<span class="text">
																			<%=Media %></span>
																	</div>
																</td>
															</tr>
															<tr>
																<td class="token_wrapper" colspan="5">
																	<asp:TextBox ID="lblGalleryInsertArtGallery" runat="server" CssClass="token_box" ReadOnly="True" Text='<%# GenerateTokens(Eval("PictureID")) %>' />
																	<span class="start_token_generator">
																		<%=Customtoken %></span>
																</td>
															</tr>
														</table>
														<asp:HiddenField ID="hvPictureID" runat="server" Value='<%# Bind("PictureID") %>' />
													</ItemTemplate>
												</asp:TemplateField>
											</Columns>
											<HeaderStyle CssClass="main_table_header" />
											<PagerStyle CssClass="pagination" HorizontalAlign="Center" />
											<RowStyle CssClass="main_row" />
											<SelectedRowStyle CssClass="categorygridselected" />
										</asp:GridView>
									</div>
									<div id="mediaPageManagment" runat="server" class="padded" visible="false">
										<asp:Label ID="lblGalSetThenumberOfItems" runat="server" Text="Set the number of items per page:" resourcekey="lblGalSetThenumberOfItems0Resource1" />
										&nbsp;<asp:DropDownList ID="ddlArticleViewNumberOfItems" runat="server" AutoPostBack="True" CssClass="ddlpageitems" OnSelectedIndexChanged="ddlArticleViewNumberOfItems_SelectedIndexChanged">
											<asp:ListItem resourcekey="ListItemResource20" Text="10" Value="10" />
											<asp:ListItem resourcekey="ListItemResource21" Text="20" Value="10" />
											<asp:ListItem resourcekey="ListItemResource22" Text="30" Value="10" />
											<asp:ListItem resourcekey="ListItemResource23" Text="50" Value="10" />
											<asp:ListItem resourcekey="ListItemResource24" Text="100" Value="100" />
										</asp:DropDownList>
									</div>
									<asp:HiddenField ID="hfGalID" runat="server" />
									<asp:HiddenField ID="hfResizeHeight" runat="server" />
									<asp:HiddenField ID="hfResizeWidth" runat="server" />
									<asp:HiddenField ID="hfResize" runat="server" />
									<asp:HiddenField ID="hfSharedGalID" runat="server" />
									<asp:HiddenField ID="hfImageChanged" runat="server" Value="false" />
									<asp:HiddenField ID="hfMainArticlePictureID" runat="server" Value="0" />
									<asp:HiddenField ID="curentActiveGalleryId" runat="server" Value="1" />
								</div>
							</div>
							<asp:Panel runat="server" ID="pnlCustomGalleryManager" CssClass="section_box no_top_margin" Visible="false">
								<div class="content dark_blue">
									<div class="section_actions">
										<asp:HyperLink ID="hlOpenGallery" runat="server" CssClass="icon laptop" Target="_blank" resourcekey="hlOpenGalleryResource1">Open Media manager</asp:HyperLink>
									</div>
								</div>
							</asp:Panel>
							<asp:UpdateProgress ID="upArticleImagesProgress" runat="server" AssociatedUpdatePanelID="upArticleImages" DisplayAfter="200" DynamicLayout="true">
								<ProgressTemplate>
									<div class="edn_admin_progress_overlay" />
									</div>
								</ProgressTemplate>
							</asp:UpdateProgress>
						</div>
					</ContentTemplate>
					<Triggers>
						<asp:PostBackTrigger ControlID="btnWistiaSingleUpload" />
					</Triggers>
				</asp:UpdatePanel>
				<asp:Panel ID="pnlDocumentUpload" CssClass="section_box white_border_1 dark_grey" runat="server">
					<h1 class="section_box_title">
						<span>
							<%=DOCUMENTSincluded%></span></h1>
					<asp:RadioButtonList ID="rblAddDocumentType" CssClass="radio_button_list" runat="server" RepeatDirection="Horizontal" onclick="toogleDocumentPanels()">
						<asp:ListItem Value="0" Text="Upload new documents" Selected="True" resourcekey="rblAddDocumentType-newDocument" />
						<asp:ListItem Value="1" Text="Add existing document" resourcekey="rblAddDocumentType-existingDocument" />
					</asp:RadioButtonList>
					<div class="content document_upload">
						<div class="rounded3dBox">
							<asp:Panel ID="pnlAddDocument" runat="server">
								<div id="divAddDocumentFineUploader" runat="server" visible="false" class="EDS_simpleFineUploader documents_fine_uploader">
									<div class="uploader">
									</div>
									<div class="uploadControls">
										<div class="actions">
											<span class="action fileSelection rounded_button gradient icon document_in_folder">
												<asp:Label ID="lblDocumentFineUploaderSelect" runat="server" resourcekey="fineUploaderSelectDocuments" Text="Select documents" />
												<span class="dnnInputFileWrapper">
													<input type="file" value="" multiple="multiple" />
												</span></span><span class="action upload rounded_button gradient icon orange_plus">
													<asp:Label ID="lblDocumentFineUploaderStart" runat="server" resourcekey="fineUploaderUpload" Text="Upload" />
												</span>
										</div>
										<div class="dndContainer">
											<p>
												<asp:Label ID="lblDocumentFineUploaderDrag" runat="server" resourcekey="fineUploaderDragFilesHere" Text="Drag files here" />
											</p>
										</div>
									</div>
									<div class="uploadDetails">
										<ol class="fileUploadList">
										</ol>
									</div>
								</div>
								<div id="divAddDocumentStandardUploader" runat="server" visible="true" class="documents_standard_uploader">
									<asp:Label ID="lblDocUploadmessage" CssClass="upload_message" Visible="false" EnableViewState="false" runat="server" />
									<span class="file_selection rounded_button gradient icon document_in_folder">
										<asp:FileUpload ID="fuDocFileUpload" runat="server" />
									</span>
									<asp:LinkButton ID="btnDocUpload" runat="server" OnClick="btnDocUpload_Click" ValidationGroup="vgArticleDocs" resourcekey="btnDocUploadResource1" CssClass="action upload rounded_button gradient icon orange_plus"><span>Upload</span></asp:LinkButton>
								</div>
							</asp:Panel>
							<asp:Panel ID="pnlAddExistingDocument" runat="server" CssClass="documents_add_existing_container" Style="display: none;">
								<div class="messages">
									<asp:Label runat="server" ID="lblAddDocumentInfo" EnableViewState="false" Visible="false" CssClass="error" />
									<p>
										<asp:RequiredFieldValidator ID="rfvExistingDocumentID" resourcekey="rfvExistingDocumentID.ErrorMessage" runat="server" ControlToValidate="tbxExistingDocumentID" ErrorMessage="Document ID must be set" ValidationGroup="vgDocumentLinks" Display="Dynamic"
											CssClass="error" />
									</p>
									<p>
										<asp:CompareValidator ID="cvExistingDocumentID" resourcekey="cvExistingDocumentID.ErrorMessage" runat="server" ControlToValidate="tbxExistingDocumentID" ErrorMessage="Document ID must be an integer" Operator="DataTypeCheck" Type="Integer" ValidationGroup="vgDocumentLinks"
											Display="Dynamic" CssClass="error" />
									</p>
								</div>
								<div class="search_by_document_title">
									<p>
										<%=Searchdocuments%>
									</p>
									<asp:TextBox ID="tbxDocumentText" runat="server" AutoCompleteType="Search" CausesValidation="False" EnableViewState="false" CssClass="rounded_text_box" />
								</div>
								<div class="search_by_document_id">
									<p>
										<%=Documentid%>
									</p>
									<asp:TextBox ID="tbxExistingDocumentID" runat="server" CausesValidation="False" EnableViewState="false" CssClass="rounded_text_box grey" />
								</div>
								<asp:LinkButton ID="btnAddExistingDocument" runat="server" OnClick="lbAddExistingDocument_Click" ValidationGroup="vgDocumentLinks" CssClass="add_button rounded_button gradient icon orange_plus"><span><%=Add%></span></asp:LinkButton>
								<div class="clear_float">
								</div>
							</asp:Panel>
						</div>
						<asp:GridView ID="gvArticleDocuments" runat="server" AutoGenerateColumns="false" CellPadding="0" CssClass="grid_view_table" DataKeyNames="DocEntryID" EnableModelValidation="True" GridLines="None" OnRowCommand="gvArticleDocuments_RowCommand" OnRowEditing="gvArticleDocuments_RowEditing"
							OnRowCancelingEdit="gvArticleDocuments_RowCancelingEdit" OnRowUpdating="gvArticleDocuments_RowUpdating" OnRowUpdated="gvArticleDocuments_RowUpdated" OnRowDeleting="gvArticleDocuments_RowDeleting" OnRowDataBound="gvArticleDocuments_RowDataBound" OnPreRender="gvArticleDocuments_PreRender" OnPageIndexChanged="gvArticleDocuments_PageIndexChanged" OnPageIndexChanging="gvArticleDocuments_PageIndexChanging">
							<AlternatingRowStyle CssClass="second" />
							<Columns>
								<asp:TemplateField HeaderText="Actions">
									<EditItemTemplate>
										<asp:LinkButton ID="lbDocUpdate" runat="server" CausesValidation="true" CommandName="Update" CssClass="action_btn save" resourcekey="lbDocUpdateResource1" ToolTip="Save changes" CommandArgument='<%# ((GridViewRow) Container).RowIndex %>' />
										<asp:LinkButton ID="lbDocCancel" runat="server" CausesValidation="false" CommandName="Cancel" CssClass="action_btn cancel" resourcekey="LinkButton2Resource1" ToolTip="Discard changes" />
									</EditItemTemplate>
									<ItemTemplate>
										<asp:LinkButton ID="lbDocEdit" runat="server" CausesValidation="false" CommandName="Edit" CssClass="action_btn edit" resourcekey="LinkButton1Resource1" ToolTip="<%#Editthisdocument %>" />
										<asp:LinkButton ID="lbDocDelete" runat="server" CausesValidation="false" CommandName="Delete" CssClass="action_btn red_x" resourcekey="lbDeleteDocResource1" ToolTip="<%#Deletethisdocument%>" CommandArgument='<%# Eval("DocEntryID") %>' />
									</ItemTemplate>
									<HeaderStyle CssClass="actions" />
									<ItemStyle CssClass="actions" />
								</asp:TemplateField>
								<asp:TemplateField HeaderText="TitleDescription">
									<EditItemTemplate>
										<asp:TextBox ID="tbDocTitle" runat="server" Text='<%# Bind("Title") %>' CssClass="light" />
										<asp:TextBox ID="tbDocDescription" runat="server" Text='<%# Bind("Description") %>' CssClass="light" />
									</EditItemTemplate>
									<ItemTemplate>
										<asp:Label ID="lblDocUploadTitle" runat="server" CssClass="title" Text='<%# Bind("Title") %>' />
										<asp:Label ID="lblDocUploadDesc" runat="server" CssClass="description" Text='<%#Bind("Description") %>' />
										<input type="text" class="token light" value="<%# GenerateDocumentToken(Eval("DocEntryID")) %>" />
									</ItemTemplate>
									<HeaderStyle CssClass="title_dscription" />
									<ItemStyle CssClass="title_dscription" />
								</asp:TemplateField>
								<asp:TemplateField HeaderText="Info">
									<ItemTemplate>
										<p class="document_link <%#PrintAlreadyInUseClass((bool) Eval("InUseByOther")) %>">
											<%#GetDocumentDownloadLink(Eval("DocEntryID"), Eval("Filename"), Eval("FileExtension"))%>
										</p>
										<p>
											<asp:Label ID="lblDateUploaded" runat="server" Text='<%# Convert.ToDateTime(Eval("DateUploaded")).ToShortDateString() %>' />
											-
											<asp:Label ID="lblDocUploadAuthor" runat="server" Text='<%#Eval("DisplayName")%>' />
										</p>
										<p>
											<asp:Label ID="lblFileSize" runat="server" Text='<%# HumanReadableFileSize(Eval("FileSize")) %>' />
										</p>
										<p>
											<asp:Label ID="lblDownloads" runat="server" Text='<%# NumberOfDownloadsText(Eval("NumberOfDownloads")) %>' />
										</p>
									</ItemTemplate>
									<EditItemTemplate>
										<p>
											<asp:Label ID="lbFilenameEdit" runat="server" Text='<%# GetDocumentFilename(Eval("Filename"),Eval("FileExtension")) %>' />
										</p>
										<div id="divReplaceFileContainer" runat="server" class="replace_file">
											<p>
												<asp:Label ID="lblReplaceFile" runat="server" Text="Replace existing file:" resourcekey="lblDocumentsReplaceFile" />
											</p>
											<asp:FileUpload ID="fuReplaceFile" runat="server" />
										</div>
									</EditItemTemplate>
									<HeaderStyle CssClass="info" />
									<ItemStyle CssClass="info" />
								</asp:TemplateField>
								<asp:TemplateField HeaderText="Lang">
									<ItemTemplate>
										<asp:Label ID="lblLang" runat="server" Text='<%# GetDocumentLocalization(Eval("SelectedLocales")) %>' />
									</ItemTemplate>
									<EditItemTemplate>
										<div class="language_selection_container">
											<asp:ListBox ID="lbEditDocUploadLanguage" runat="server" SelectionMode="Multiple" />
										</div>
									</EditItemTemplate>
									<HeaderStyle CssClass="language" />
									<ItemStyle CssClass="language" />
								</asp:TemplateField>
								<asp:TemplateField HeaderText="Show">
									<ItemTemplate>
										<asp:CheckBox ID="CheckBox1" runat="server" Enabled="false" Checked='<%#Convert.ToBoolean(Eval("Visible"))%>' />
									</ItemTemplate>
									<EditItemTemplate>
										<asp:CheckBox runat="server" ID="cbDocumentVisible" Enabled="true" Checked='<%#Convert.ToBoolean(Eval("Visible"))%>' />
									</EditItemTemplate>
									<HeaderStyle CssClass="show" />
									<ItemStyle CssClass="show" />
								</asp:TemplateField>
								<asp:TemplateField ShowHeader="false">
									<ItemTemplate>
										<asp:Label ID="lblPosition" runat="server" Text='<%# Bind("Position") %>' CssClass="rounded_inset_text_box" />
									</ItemTemplate>
									<EditItemTemplate>
										<asp:TextBox ID="tbxPosition" runat="server" Text='<%# Bind("Position") %>' CssClass="light" />
									</EditItemTemplate>
									<HeaderStyle CssClass="position" />
									<ItemStyle CssClass="position" />
								</asp:TemplateField>
								<asp:TemplateField ShowHeader="false">
									<ItemTemplate>
										<asp:LinkButton ID="lbDocMoveDown" CommandArgument='<%# Bind("DocEntryID") %>' CommandName="Down" runat="server" CssClass="arrow down" resourcekey="lbDocMoveDownResource1" />
										<asp:LinkButton ID="lbDocMoveUp" CommandArgument='<%# Bind("DocEntryID") %>' CommandName="Up" runat="server" CssClass="arrow up" resourcekey="lbDocMoveUpResource1" />
									</ItemTemplate>
									<HeaderStyle CssClass="arrows" />
									<ItemStyle CssClass="arrows" />
								</asp:TemplateField>
							</Columns>
							<HeaderStyle CssClass="header_row" />
						</asp:GridView>
					</div>
					<asp:Button ID="btnDocUploadRefresh" runat="server" Text="refresf" Style="display: none;" OnClick="btnDocUploadRefresh_Click" />
				</asp:Panel>
				<asp:Panel ID="pnlLinksIncluded" CssClass="section_box white_border_1 dark_grey olive_green" runat="server">
					<asp:UpdatePanel ID="upLinksIncluded" runat="server">
						<ContentTemplate>
							<div class="edn_admin_progress_overlay_container">
								<asp:UpdateProgress ID="uppLinksIncluded" runat="server" AssociatedUpdatePanelID="upLinksIncluded" DisplayAfter="100" DynamicLayout="true">
									<ProgressTemplate>
										<div class="edn_admin_progress_overlay">
										</div>
									</ProgressTemplate>
								</asp:UpdateProgress>
								<asp:PlaceHolder ID="phincludeAutoComplete" runat="server" />
								<h1 class="section_box_title">
									<span>
										<%=Links%></span></h1>
								<asp:RadioButtonList ID="rblCreateLinkType" CssClass="radio_button_list" runat="server" RepeatDirection="Horizontal" AutoPostBack="true" OnSelectedIndexChanged="rblCreateLinkType_SelectedIndexChanged">
									<asp:ListItem Value="0" resourcekey="liCustomlink" Text="External link" Selected="True" />
									<asp:ListItem Value="1" resourcekey="liPage" Text="Page link" />
									<asp:ListItem Value="2" resourcekey="liNewsarticle" Text="Article link" />
									<asp:ListItem Value="3" resourcekey="liExistinglink" Text="Existing link" />
								</asp:RadioButtonList>
								<div class="content links_manager">
									<p class="user_messages">
										<asp:Label ID="lblLinksInfo" runat="server" EnableViewState="false" />
										<asp:RequiredFieldValidator ID="rfvtbxCustomLink" resourcekey="rfvtbxCustomLink.ErrorMessage" runat="server" ControlToValidate="tbxCustomLink" ErrorMessage="Please enter a URL." ValidationGroup="vgArticleLinks" Display="Dynamic" Visible="true" />
										<asp:RequiredFieldValidator ID="rfvNewsArticleID" resourcekey="rfvNewsArticleID.ErrorMessage" runat="server" ControlToValidate="tbxExistingArticleID" ErrorMessage="Please select a news article." ValidationGroup="vgArticleLinks" Display="Dynamic" Visible="false" />
										<asp:RequiredFieldValidator ID="rfvExistingLinksID" resourcekey="rfvExistingLinksID.ErrorMessage" runat="server" ControlToValidate="tbxExistingLinksID" ErrorMessage="Please specify an existing document ID." ValidationGroup="vgArticleLinks" Display="Dynamic"
											Visible="false" />
										<asp:CompareValidator ID="cvExistingLinksID" runat="server" resourcekey="cvExistingLinksID.ErrorMessage" ControlToValidate="tbxExistingLinksID" ErrorMessage="The existing link ID must be an integer." Operator="DataTypeCheck" Type="Integer" ValidationGroup="vgArticleLinks"
											Display="Dynamic" Visible="false" />
									</p>
									<div class="rounded3dBox">
										<div class="new_link_settings">
											<asp:Panel ID="pnlLinksCreateNewWrapper" runat="server" Visible="true" CssClass="custom">
												<asp:Panel ID="pnlAddCustomLink" runat="server" Visible="true" CssClass="field">
													<asp:Label ID="lblCustomLink" resourcekey="lblCustomLink" AssociatedControlID="tbxCustomLink" runat="server" Text="URL:" />
													<asp:TextBox ID="tbxCustomLink" runat="server" Text="" />
												</asp:Panel>
												<asp:Panel ID="pnlAddLinkPage" runat="server" Visible="false" CssClass="field">
													<Portal:URL ID="urlLinksIncluded" runat="server" ShowNewWindow="false" ShowUsers="false" ShowFiles="false" ShowLog="false" ShowSecure="false" ShowTabs="false" ShowTrack="false" ShowUpLoad="false" ShowUrls="false" ShowDatabase="false" UrlType="U" />
												</asp:Panel>
												<asp:Panel ID="pnlAddNewsArticleLink" runat="server" Visible="false" CssClass="field">
													<asp:Label ID="lblSearchArticleText" resourcekey="lblSearchArticleText" AssociatedControlID="tbxSearchText" runat="server" Text="Search news articles:" />
													<asp:TextBox ID="tbxSearchText" runat="server" AutoCompleteType="Search" CausesValidation="False" EnableViewState="false" />
													<asp:TextBox ID="tbxExistingArticleID" runat="server" CausesValidation="False" EnableViewState="false" Style="display: none;" />
												</asp:Panel>
												<div class="field title">
													<asp:Label ID="lblLinkTitle" resourcekey="lblLinkTitle" AssociatedControlID="tbxLinkTitle" runat="server" Text="Link title:" />
													<asp:TextBox ID="tbxLinkTitle" runat="server" />
												</div>
												<div class="field">
													<asp:Label ID="lblLinkDescription" resourcekey="lblLinkDescription" AssociatedControlID="tbxLinkDescription" runat="server" Text="Link description:" />
													<asp:TextBox ID="tbxLinkDescription" runat="server" />
												</div>
												<div style="clear: both;">
												</div>
											</asp:Panel>
											<asp:Panel ID="pnlLinksAddExistingLink" runat="server" Visible="false" CssClass="existing_link">
												<div class="field">
													<asp:Label ID="lblSearchLinkText" resourcekey="lblSearchLinkText" AssociatedControlID="tbxSearchLinkText" runat="server" Text="Search links:" />
													<asp:TextBox ID="tbxSearchLinkText" runat="server" AutoCompleteType="Search" CausesValidation="False" EnableViewState="false" />
												</div>
												<div class="field title">
													<asp:Label ID="lblExistingLinksID" resourcekey="lblExistingLinksID" AssociatedControlID="tbxExistingLinksID" runat="server" Text="Link id:" />
													<asp:TextBox ID="tbxExistingLinksID" runat="server" CausesValidation="true" EnableViewState="false" />
												</div>
												<div style="clear: both;">
												</div>
											</asp:Panel>
										</div>
										<asp:LinkButton ID="lbAddLink" runat="server" ValidationGroup="vgArticleLinks" OnClick="lbAddLink_Click" CausesValidation="true" CssClass="rounded_button gradient olive_green icon orange_plus"><span><%=Add%></span></asp:LinkButton>
										<div style="clear: both;">
										</div>
									</div>
									<asp:GridView ID="gvArticleLinks" runat="server" AutoGenerateColumns="false" CellPadding="0" CssClass="grid_view_table olive_green" DataKeyNames="LinkID" EnableModelValidation="True" GridLines="None" OnRowCancelingEdit="gvArticleLinks_RowCancelingEdit"
										OnRowCommand="gvArticleLinks_RowCommand" OnRowEditing="gvArticleLinks_RowEditing" OnRowUpdating="gvArticleLinks_RowUpdating" OnRowUpdated="gvArticleLinks_RowUpdated" OnRowDeleting="gvArticleLinks_RowDeleting" OnRowDataBound="gvArticleLinks_RowDataBound"
										OnPreRender="gvArticleLinks_PreRender">
										<Columns>
											<asp:TemplateField HeaderText="Actions">
												<EditItemTemplate>
													<asp:LinkButton ID="lbLinkUpdate" runat="server" CausesValidation="true" CommandName="Update" CssClass="action_btn save" resourcekey="lbDocUpdateResource1" ToolTip="Save changes" CommandArgument='<%# ((GridViewRow) Container).RowIndex %>' />
													<asp:LinkButton ID="lbLinkCancel" runat="server" CausesValidation="false" CommandName="Cancel" CssClass="action_btn cancel" resourcekey="LinkButton2Resource1" ToolTip="Discard changes" />
												</EditItemTemplate>
												<ItemTemplate>
													<asp:LinkButton ID="lbLinkEdit" CssClass="action_btn edit" runat="server" CausesValidation="false" CommandName="Edit" ToolTip="<%#Editthislink%>" />
													<asp:LinkButton ID="lbDeleteLink" CssClass="action_btn red_x" runat="server" CausesValidation="false" CommandName="Delete" ToolTip="<%#Deletethislink%>" CommandArgument='<%#Eval("LinkID")%>' />
												</ItemTemplate>
												<HeaderStyle CssClass="actions" />
												<ItemStyle CssClass="actions" />
											</asp:TemplateField>
											<asp:TemplateField HeaderText="TitleDescription">
												<EditItemTemplate>
													<asp:TextBox ID="tbxLinkTitle" runat="server" Text='<%# Bind("Title") %>' CssClass="light" />
													<asp:TextBox ID="tbxLinkDescription" runat="server" Text='<%# Bind("Description") %>' CssClass="light" />
												</EditItemTemplate>
												<ItemTemplate>
													<asp:Label ID="lblLinkUploadTitle" runat="server" Text='<%# Bind("Title") %>' CssClass="title" />
													<asp:Label ID="lblLinkUploadDesc" runat="server" Text='<%# Bind("Description") %>' CssClass="description" />
													<input type="text" class="token light" value="<%# GenerateLinkToken(Eval("LinkID")) %>" />
												</ItemTemplate>
												<HeaderStyle CssClass="title_description" />
												<ItemStyle CssClass="title_description" />
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Link">
												<EditItemTemplate>
													<asp:TextBox ID="tbxLink" runat="server" Text='<%# GetGeneratedLinkForEdit(Eval("Type"),Eval("URL"),Eval("Protocol"),Eval("ArticleID"),Eval("TabID"),Eval("ExistingArticleData")) %>' Visible="false" CssClass="light" />
													<Portal:URL ID="urlLinksIncluded" runat="server" Width="250" ShowNewWindow="false" ShowUsers="false" ShowFiles="false" ShowLog="false" ShowSecure="false" ShowTabs="false" ShowTrack="false" ShowUpLoad="false" ShowUrls="false" ShowDatabase="false" UrlType="U"
														Visible="false" />
												</EditItemTemplate>
												<ItemTemplate>
													<p class="link <%# PrintAlreadyInUseClass((bool) Eval("InUseByOther")) %>">
														<%# GetGeneratedLink(Eval("Type"),Eval("URL"),Eval("Protocol"),Eval("ArticleID"),Eval("TabID"),Eval("ExistingArticleData")) %>
													</p>
												</ItemTemplate>
												<HeaderStyle CssClass="link" />
												<ItemStyle CssClass="link" />
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Lang">
												<ItemTemplate>
													<asp:Label ID="lblLang" runat="server" Text='<%# GetDocumentLocalization(Eval("SelectedLocales")) %>' />
												</ItemTemplate>
												<EditItemTemplate>
													<div class="language_selection_container">
														<asp:ListBox ID="lbEditListUploadLanguage" runat="server" SelectionMode="Multiple" />
													</div>
												</EditItemTemplate>
												<HeaderStyle CssClass="language" />
												<ItemStyle CssClass="language" />
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Target">
												<EditItemTemplate>
													<asp:DropDownList ID="ddlLinkTarget" runat="server">
														<asp:ListItem Value="0" Text="_self" Selected="True" />
														<asp:ListItem Value="1" Text="_blank" />
														<asp:ListItem Value="2" Text="_parent" />
														<asp:ListItem Value="3" Text="_top" />
													</asp:DropDownList>
												</EditItemTemplate>
												<ItemTemplate>
													<asp:Label ID="lblTarget" runat="server" Text='<%# TargetToString(Eval("Target"))%>' />
												</ItemTemplate>
												<HeaderStyle CssClass="target" />
												<ItemStyle CssClass="target" />
											</asp:TemplateField>
											<asp:TemplateField ShowHeader="false">
												<ItemTemplate>
													<asp:Label ID="lblPosition" runat="server" Text='<%# Bind("Position") %>' CssClass="rounded_inset_text_box" />
												</ItemTemplate>
												<EditItemTemplate>
													<asp:TextBox ID="tbxPosition" runat="server" Text='<%# Bind("Position") %>' CssClass="light" />
												</EditItemTemplate>
												<HeaderStyle CssClass="position" />
												<ItemStyle CssClass="position" />
											</asp:TemplateField>
											<asp:TemplateField ShowHeader="false">
												<ItemTemplate>
													<asp:LinkButton ID="lbLinkMoveDown" CommandArgument='<%# Bind("LinkID") %>' CommandName="Down" runat="server" CssClass="arrow down" resourcekey="lbDocMoveDownResource1" />
													<asp:LinkButton ID="lbLinkMoveUp" CommandArgument='<%# Bind("LinkID") %>' CommandName="Up" runat="server" CssClass="arrow up" resourcekey="lbDocMoveUpResource1" />
												</ItemTemplate>
												<HeaderStyle CssClass="arrows" />
												<ItemStyle CssClass="arrows" />
											</asp:TemplateField>
										</Columns>
										<AlternatingRowStyle CssClass="second" />
										<HeaderStyle CssClass="header_row" />
									</asp:GridView>
								</div>
							</div>
						</ContentTemplate>
					</asp:UpdatePanel>
				</asp:Panel>
				<asp:Panel ID="google_maps_main" CssClass="section_box white_border_1 light_green green_globe google_maps_main" runat="server">
					<h1 class="section_box_title">
						<span>
							<%=Mainarticlemap %></span></h1>
					<div class="content google_maps">
						<asp:Literal runat="server" ID="googleMapsJS" />
						<div class="content_token_generator google_maps">
						</div>
						<asp:HiddenField ID="hfGooglemapTokenGenerated" runat="server" />
						<div id="idAddGmap" runat="server" class="info_box red_cross no_map">
							<a href="#" class="action add open_map_editor <%=hasGapiKey%>">
								<%=Addmap%></a>
							<p>
								<%=Mainarticlemapisnotset%>
							</p>
						</div>
						<div id="idRemoveGmap" runat="server" class="info_box check_sign map_set">
							<a href="#" class="action remove_btn remove_article_map">
								<%=Remove%></a> <a href="#" class="action edit open_map_editor <%=hasGapiKey%>">Edit map</a>
							<p>
								<%=Mainarticlemapisset%>
							</p>
						</div>
						<div class="section_actions">
							<a class="icon green_globe open_map_editor <%=hasGapiKey%>" href="#">
								<%=Mapeditor%></a>
						</div>
					</div>
				</asp:Panel>
				<div id="divAdvancedSettings" runat="server" class="collapsible_box advanced_settings">
					<h1 class="collapsible_box_title">
						<%=AdvancedSettings %></h1>
					<div class="content">
						<asp:UpdatePanel ID="upAdvancedSettings" runat="server">
							<ContentTemplate>
								<div class="edn_admin_progress_overlay_container">
									<asp:UpdateProgress ID="uppAdvancedSettings" runat="server" AssociatedUpdatePanelID="upAdvancedSettings" DisplayAfter="100" DynamicLayout="true">
										<ProgressTemplate>
											<div class="edn_admin_progress_overlay">
											</div>
										</ProgressTemplate>
									</asp:UpdateProgress>
									<asp:Panel ID="pnlChangeOwner" runat="server" Visible="false">
										<table class="settings_table w700">
											<tr>
												<td class="left">
													<dnn:Label ID="lblowner" runat="server" HelpText="Article Owner:" Text="Article Owner:" HelpKey="lblowner.HelpText" ResourceKey="lblowner" />
												</td>
												<td class="right">
													<asp:Label ID="tbArticleAuthorName" runat="server" resourcekey="tbArticleAuthorNameResource1" />
												</td>
											</tr>
											<tr id="trEnableAuthorProfile" runat="server" visible="false">
												<td class="left">
													<dnn:Label ID="lblAuthorAlias" runat="server" HelpText="Author alias:" Text="Author alias:" />
												</td>
												<td class="right">
													<asp:TextBox ID="tbAuthorAliasName" runat="server" MaxLength="100" Width="200px" />
												</td>
											</tr>
											<tr>
												<td class="left">
													<dnn:Label ID="lblChOwner" runat="server" HelpText="Change Owner:" Text="Change Owner:" HelpKey="lblChOwner.HelpText" ResourceKey="lblChOwner" />
												</td>
												<td class="right">
													<asp:DropDownList ID="ddlRoles" runat="server" AppendDataBoundItems="True" AutoPostBack="True" CssClass="ddlgeneral" OnSelectedIndexChanged="ddlRoles_SelectedIndexChanged" Visible="false">
														<asp:ListItem Value="-1" resourcekey="ListItemResource25">Select role</asp:ListItem>
													</asp:DropDownList>
													<asp:DropDownList ID="ddlAuthors" runat="server" AppendDataBoundItems="True" AutoPostBack="True" CssClass="ddlgeneral" OnSelectedIndexChanged="ddlAuthors_SelectedIndexChanged" Visible="false">
														<asp:ListItem Value="-1" resourcekey="ListItemResource26">Select author</asp:ListItem>
													</asp:DropDownList>
												</td>
											</tr>
										</table>
									</asp:Panel>
									<div id="divDefaultTemplate" runat="server">
										<table class="settings_table w700">
											<tr>
												<td class="left">
													<dnn:Label ID="lblUseDefaultTemplate" runat="server" HelpText="Use default template:" Text="Use default template:" HelpKey="lblUseDefaultTemplate.HelpText" ResourceKey="lblUseDefaultTemplate" />
												</td>
												<td class="right">
													<asp:CheckBox ID="cbUseDefaultTemplate" runat="server" AutoPostBack="True" Checked="True" OnCheckedChanged="cbUseDefaultTemplate_CheckedChanged" resourcekey="cbUseDefaultTemplateResource1" />
												</td>
											</tr>
										</table>
										<asp:Panel ID="pnlSelectThemes" runat="server" Visible="false">
											<table class="settings_table w700 no_margin">
												<tr>
													<td class="left">
														<dnn:Label ID="lblArticleDetailsTheme" runat="server" ControlName="ddlArticleDetailsTheme" HelpText="Article details theme:" Text="Article details theme:" HelpKey="lblArticleDetailsTheme.HelpText" ResourceKey="lblArticleDetailsTheme" />
													</td>
													<td class="right">
														<asp:DropDownList ID="ddlArticleDetailsTheme" runat="server" AutoPostBack="True" CausesValidation="True" CssClass="ddlgeneral" OnSelectedIndexChanged="ddlArticleDetailsFolder_SelectedIndexChanged" />
													</td>
												</tr>
												<tr>
													<td class="left">
														<dnn:Label ID="lblArticleCSSStyle" ControlName="ddlDisplayStyle" runat="server" HelpText="Display style:" Text="Display style:" HelpKey="lblArticleCSSStyle.HelpText" ResourceKey="lblArticleCSSStyle" />
													</td>
													<td class="right">
														<asp:DropDownList ID="ddlDisplayStyle" runat="server" />
													</td>
												</tr>
												<tr>
													<td class="left">
														<dnn:Label ID="lblArticleDetailsTemplate" runat="server" ControlName="ddlArticleDetailsTemplate" HelpText="Article details template:" Text="Article details template:" HelpKey="lblArticleDetailsTemplate.HelpText" ResourceKey="lblArticleDetailsTemplate" />
													</td>
													<td class="right">
														<asp:DropDownList ID="ddlArticleDetailsTemplate" runat="server" CssClass="ddlgeneral" />
													</td>
												</tr>
												<tr class="second">
													<td class="left">
														<dnn:Label ID="lblDetailsDocumentsTemplate" runat="server" ControlName="ddlDetailsDocumentsTemplate" HelpText="Details documents template." Text="Documents template:" HelpKey="lblDetailsDocumentsTemplate.HelpText" ResourceKey="lblDetailsDocumentsTemplate" />
													</td>
													<td class="right">
														<asp:DropDownList ID="ddlDetailsDocumentsTemplate" runat="server" />
													</td>
												</tr>
												<tr class="second">
													<td class="left">
														<dnn:Label ID="lblDetailsLinksTemplate" runat="server" ControlName="ddlDetailsLinksTemplate" HelpText="Details links template." Text="Links template:" HelpKey="lblDetailsLinksTemplate.HelpText" ResourceKey="lblDetailsLinksTemplate" />
													</td>
													<td class="right">
														<asp:DropDownList ID="ddlDetailsLinksTemplate" runat="server" />
													</td>
												</tr>
												<tr class="second">
													<td class="left">
														<dnn:Label ID="lblDetailsRelatedArticlesTemplate" runat="server" ControlName="ddlDetailsRelatedArticlesTemplate" HelpText="Details related articles template." Text="Related articles template:" HelpKey="lblDetailsRelatedArticlesTemplate.HelpText" ResourceKey="lblDetailsRelatedArticlesTemplate" />
													</td>
													<td class="right">
														<asp:DropDownList ID="ddlDetailsRelatedArticlesTemplate" runat="server" />
													</td>
												</tr>
												<tr>
													<td class="left">
														<dnn:Label ID="lblArticleCommentsTemplate" runat="server" ControlName="ddlCommentsTemplate" HelpText="Article comments template:" Text="Article comments template:" HelpKey="lblArticleCommentsTemplate.HelpText" ResourceKey="lblArticleCommentsTemplate" />
													</td>
													<td class="right">
														<asp:DropDownList ID="ddlCommentsTemplate" runat="server" CssClass="ddlgeneral" />
													</td>
												</tr>

											</table>
										</asp:Panel>
									</div>
								</div>
							</ContentTemplate>
						</asp:UpdatePanel>
					</div>
				</div>
				<asp:Panel ID="pnlEventManager" runat="server" CssClass="section_box white_border_1 dark_grey orange">
					<%--					<asp:UpdatePanel ID="upEventManager" runat="server" UpdateMode="Conditional">
						<ContentTemplate>--%>
					<div class="edn_admin_progress_overlay_container">
						<%--								<asp:UpdateProgress ID="uppEventManager" runat="server" AssociatedUpdatePanelID="upEventManager" DisplayAfter="100" DynamicLayout="true">
									<ProgressTemplate>
										<div class="edn_admin_progress_overlay">
										</div>
									</ProgressTemplate>
								</asp:UpdateProgress>--%>
						<h1 class="section_box_title">
							<asp:Label ID="lblIsArticleEvent" runat="server" Text="Add as event:" resourcekey="lblIsArticleEventResource1" /></h1>
						<div id="tblIsArticleEvent" runat="server" style="padding-top: 8px;">
							<asp:CheckBox ID="cbIsArticleEvent" runat="server" Style="padding-top: 10px; padding-left: 10px;" AutoPostBack="True" OnCheckedChanged="cbIsArticleEvent_CheckedChanged" />
						</div>
						<asp:Panel ID="pnlEventsData" runat="server" Visible="false" CssClass="content links_manager">

							<asp:Panel ID="pnlSimpleEvents" runat="server">
								<table class="settings_table w700 no_margin">
									<tr>
										<td colspan="3" style="text-align: center;">
											<asp:Label ID="lblEventDateError" runat="server" ForeColor="Red" Visible="false" EnableViewState="false" />
										</td>
									</tr>
									<tr>
										<td class="left" style="vertical-align: top; padding-top: 2px;">
											<dnn:Label ID="lblEventStartDateTime" runat="server" HelpText="Start date:" Text="Start date:" HelpKey="lblEventStartDateTime.HelpText" ResourceKey="lblEventStartDateTime" />
										</td>
										<td class="right" style="width: 225px;">
											<asp:TextBox ID="tbEventStartDate" runat="server" CssClass="text_generic center" ValidationGroup="vgEditArticle" Width="90px" />
											<img src="<%=ModulePath%>images/icons/calendar.png" alt="" style="position: relative; top: 2px" />
											<asp:RequiredFieldValidator ID="rfvEventStartDate" runat="server" ControlToValidate="tbEventStartDate" CssClass="NormalRed" Display="Dynamic" Enabled="false" ErrorMessage="Date required." ValidationGroup="vgEditArticle" resourcekey="rfvEventStartDateResource1" />
											<asp:Label ID="lblEvStartDateError" runat="server" ForeColor="Red" resourcekey="lblPubDateErrorResource1" Text="Invalid date." Visible="false" />
											<asp:TextBox ID="tbEventStartTime" runat="server" CssClass="text_generic center" ValidationGroup="vgAddArticle" Width="55px" />
											<img id="tbEventStartTimeIcon" src="#" alt="EventStartTimeIcon" runat="server" style="position: relative; top: 1px" />
											&nbsp;<asp:RegularExpressionValidator ID="revEventStartTime" runat="server" ControlToValidate="tbEventStartTime" Enabled="false" ErrorMessage="hh:mm" ValidationExpression="([0-1]?[0-9]|2[0-3]):([0-5][0-9])" ValidationGroup="vgEditArticle" Display="Dynamic"
												resourcekey="revEventStartTimeResource1" />
											<asp:RequiredFieldValidator ID="rfvEventStartTime" runat="server" ControlToValidate="tbEventStartTime" CssClass="NormalRed" Display="Dynamic" Enabled="false" ErrorMessage="Time required." ValidationGroup="vgEditArticle" resourcekey="rfvEventStartTimeResource1" />
										</td>
										<td rowspan="2">
											<p style="position: relative; top: 5px">
												<asp:CheckBox ID="cbAllDayEvent" runat="server" AutoPostBack="True" OnCheckedChanged="cbAllDayEvent_CheckedChanged" Text="All day event" resourcekey="cbAllDayEventResource1" />
											</p>
											<p style="position: relative; top: 5px">
												<asp:CheckBox ID="cbShowEndDate" resourcekey="cbShowEndDate" runat="server" Checked="True" Text="Show end date" />
											</p>
										</td>
									</tr>
									<tr>
										<td class="left" style="vertical-align: top; padding-top: 2px;">
											<dnn:Label ID="lblEventEndDateTime" runat="server" HelpText="End date:" Text="End date:" HelpKey="lblEventEndDateTime.HelpText" ResourceKey="lblEventEndDateTime" />
										</td>
										<td class="right">
											<asp:TextBox ID="tbEventEndDate" runat="server" CssClass="text_generic center" ValidationGroup="vgEditArticle" Width="90px" />
											<img src="<%=ModulePath%>images/icons/calendar.png" alt="" style="position: relative; top: 2px" />
											<asp:RequiredFieldValidator ID="rfvEventEndDate" runat="server" ControlToValidate="tbEventEndDate" CssClass="NormalRed" Display="Dynamic" Enabled="false" ErrorMessage="Date required." ValidationGroup="vgEditArticle" resourcekey="rfvEventEndDateResource1" />
											<asp:Label ID="lblEvEndDateError" runat="server" ForeColor="Red" resourcekey="lblExpireDateErrorResource1" Text="Invalid date." Visible="false" />
											<asp:TextBox ID="tbEventEndTime" runat="server" CssClass="text_generic center" ValidationGroup="vgEditArticle" Width="55px" />
											<img id="tbEventEndTimeIcon" runat="server" src="#" alt="" style="position: relative; top: 1px" />
											&nbsp;<asp:RegularExpressionValidator ID="revEventEndTIme" runat="server" ControlToValidate="tbEventEndTime" Enabled="false" ErrorMessage="hh:mm" ValidationExpression="([0-1]?[0-9]|2[0-3]):([0-5][0-9])" ValidationGroup="vgEditArticle" Display="Dynamic"
												resourcekey="revEventEndTImeResource1" />
											<asp:RequiredFieldValidator ID="rfvEventEnd" runat="server" ControlToValidate="tbEventEndTime" CssClass="NormalRed" Display="Dynamic" Enabled="false" ErrorMessage="Time required." ValidationGroup="vgEditArticle" resourcekey="rfvEventEndResource1" />
										</td>
									</tr>
									<tr>
										<td class="left">
											<dnn:Label ID="lblrecurringEvent" runat="server" Text="Recurrence:" HelpText="Create recurring event." />
										</td>
										<td class="right">
											<asp:CheckBox ID="cbRecurringEvent" runat="server" AutoPostBack="True" OnCheckedChanged="cbRecurringEvent_CheckedChanged" />
										</td>
									</tr>
								</table>
							</asp:Panel>

							<asp:Panel runat="server" ID="pnlRecurringEvent" Visible="false">
								<div class="rounded3dBox">

									<div runat="server" id="divEventRecurringOptionsPanel">

										<asp:Panel ID="pnlRecurringEditsSettings" runat="server">
											<table class="settings_table w700 no_margin" runat="server">
												<tr>
													<td class="left">
														<dnn:Label ID="lblRecurrenceType" runat="server" Text="Recurrence type:" HelpText="Select type of recurrence." />
													</td>
													<td class="right">
														<asp:RadioButtonList ID="rblRecurringEventType" runat="server" OnSelectedIndexChanged="rblRecurringEventType_SelectedIndexChanged" AutoPostBack="true" RepeatDirection="Horizontal">
															<asp:ListItem resourcekey="liDaily" Value="0" Text="Daily" Selected="True" />
															<asp:ListItem resourcekey="liWeekly" Value="1" Text="Weekly" />
															<asp:ListItem resourcekey="liMonthly" Value="2" Text="Monthly" />
															<asp:ListItem resourcekey="liYearly" Value="3" Text="Yearly" />
														</asp:RadioButtonList>
													</td>
												</tr>
												<tr>
													<td class="left"></td>
													<td class="right">
														<asp:Panel runat="server" ID="pnlDailyRecurringEvent" Visible="false">
															<asp:Label ID="lblRecurringEvery" resourcekey="lblRecurringEvery" runat="server" Text="Every:" />
															<asp:TextBox ID="tbxDailyRecurringEventDays" runat="server" Width="30px" Text="2" />
															<asp:Label ID="lblRecurringDays" resourcekey="lblRecurringDays" runat="server" Text="day(s)" />
															<asp:RequiredFieldValidator ID="rfvDailyRecurringEventDays" runat="server" ControlToValidate="tbxDailyRecurringEventDays" CssClass="NormalRed" Display="Dynamic" ErrorMessage="Days required." resourcekey="rfvDailyRecurringEventDays.ErrorMessage" ValidationGroup="vgEditArticle"
																SetFocusOnError="True" />
															<asp:CompareValidator ID="cvDailyRecurringEventDays" runat="server" ControlToValidate="tbxDailyRecurringEventDays" Display="Dynamic" resourcekey="cvDailyRecurringEventDays.ErrorMessage" ErrorMessage="Please enter number only." Operator="DataTypeCheck"
																Type="Integer" ValidationGroup="vgEditArticle" SetFocusOnError="True" />
														</asp:Panel>
														<asp:Panel runat="server" ID="pnlWeeklyRecurringEvent" Visible="false">
															<asp:Label ID="lblWeeklyRecurringEvery" resourcekey="lblWeeklyRecurringEvery" runat="server" Text="Recur every:" />
															<asp:TextBox ID="tbxWeeklyRecurringEventWeeks" runat="server" Width="30px" Text="1" />
															<asp:RequiredFieldValidator ID="rfvWeeklyRecurringEventWeeks" runat="server" resourcekey="rfvWeeklyRecurringEventWeeks.ErrorMessage" ControlToValidate="tbxWeeklyRecurringEventWeeks" CssClass="NormalRed" Display="Dynamic" ErrorMessage="Week required."
																ValidationGroup="vgEditArticle" SetFocusOnError="True" />
															<asp:CompareValidator ID="cvWeeklyRecurringEventWeeks" runat="server" resourcekey="cvWeeklyRecurringEventWeeks.ErrorMessage" ControlToValidate="tbxWeeklyRecurringEventWeeks" Display="Dynamic" ErrorMessage="Please enter number only." Operator="DataTypeCheck"
																Type="Integer" ValidationGroup="vgEditArticle" SetFocusOnError="True" />
															<asp:Label ID="lblRecurringWeeks" resourcekey="lblRecurringWeeks" runat="server" Text="weeks(s) on" />
															<asp:CheckBoxList ID="cblWeeklyRecurringEvent" runat="server">
																<asp:ListItem resourcekey="liMonday" Value="1" Text="Monday" />
																<asp:ListItem resourcekey="liThuesday" Value="2" Text="Tuesday" />
																<asp:ListItem resourcekey="liWednesday" Value="3" Text="Wednesday" />
																<asp:ListItem resourcekey="liThursday" Value="4" Text="Thursday" />
																<asp:ListItem resourcekey="liFriday" Value="5" Text="Friday" />
																<asp:ListItem resourcekey="liSaturday" Value="6" Text="Saturday" />
																<asp:ListItem resourcekey="liSunday" Value="7" Text="Sunday" />
															</asp:CheckBoxList>
														</asp:Panel>
														<asp:Panel runat="server" ID="pnlMonthlyRecurringEvent" Visible="false">
															<asp:RadioButtonList ID="rblMonthlyRecurringEventType" RepeatDirection="Horizontal" runat="server" OnSelectedIndexChanged="rblMonthlyRecurringEventType_SelectedIndexChanged" AutoPostBack="true">
																<asp:ListItem resourcekey="liRepeatedon" Value="0" Text="Repeated on:" Selected="True" />
																<asp:ListItem resourcekey="liRepeatedonday" Value="1" Text="Repeated on day:" />
															</asp:RadioButtonList>
															<div style="float: left;">
																<asp:Panel runat="server" ID="pnlRepeatedOn" Visible="true">
																	<asp:DropDownList ID="ddlRepeatedOnEvery" runat="server">
																		<asp:ListItem resourcekey="liFirst" Value="1" Text="First" Selected="True" />
																		<asp:ListItem resourcekey="liSecond" Value="2" Text="Second" />
																		<asp:ListItem resourcekey="liThird" Value="3" Text="Third" />
																		<asp:ListItem resourcekey="liFourth" Value="4" Text="Fourth" />
																		<asp:ListItem resourcekey="liLast" Value="5" Text="Last" />
																	</asp:DropDownList>
																	<asp:DropDownList ID="ddlRepeatedOnDay" runat="server">
																		<asp:ListItem resourcekey="liMonday" Value="1" Text="Monday" />
																		<asp:ListItem resourcekey="liThuesday" Value="2" Text="Tuesday" />
																		<asp:ListItem resourcekey="liWednesday" Value="3" Text="Wednesday" />
																		<asp:ListItem resourcekey="liThursday" Value="4" Text="Thursday" />
																		<asp:ListItem resourcekey="liFriday" Value="5" Text="Friday" />
																		<asp:ListItem resourcekey="liSaturday" Value="6" Text="Saturday" />
																		<asp:ListItem resourcekey="liSunday" Value="7" Text="Sunday" />
																	</asp:DropDownList>
																</asp:Panel>
																<asp:Panel runat="server" ID="pnlRepeatedOnDay" Visible="false" Style="margin-top: 3px">
																	<asp:TextBox ID="tbxRepeatedOnDay" runat="server" Width="30px" Text="1" />
																	<asp:RequiredFieldValidator ID="rfvRepeatedOnDay" resourcekey="rfvRepeatedOnDay.ErrorMessage" runat="server" ControlToValidate="tbxRepeatedOnDay" CssClass="NormalRed" Display="Dynamic" ErrorMessage="Day required." ValidationGroup="vgEditArticle" SetFocusOnError="True" />
																	<asp:CompareValidator ID="cvtbxRepeatedOnDay" resourcekey="cvtbxRepeatedOnDay.ErrorMessage" runat="server" ControlToValidate="tbxRepeatedOnDay" Display="Dynamic" ErrorMessage="Please enter number only." Operator="DataTypeCheck" Type="Integer" ValidationGroup="vgEditArticle" SetFocusOnError="True" />
																	<asp:RangeValidator ID="rvRepeatedOnDay" resourcekey="rvRepeatedOnDay.ErrorMessage" runat="server" MinimumValue="1" MaximumValue="31" ControlToValidate="tbxRepeatedOnDay" Display="Dynamic" ErrorMessage="Please enter number between 1-31." ValidationGroup="vgEditArticle" SetFocusOnError="True" Type="Integer" />
																</asp:Panel>
															</div>
															<div style="margin-top: 2px">
																<asp:Label ID="lblRecurringMonthEvery" resourcekey="lblRecurringMonthEvery" runat="server" Text="of every:" Style="margin-left: 5px;" />
																<asp:TextBox ID="tbxOfEveryMonth" runat="server" Width="30px" Text="1" />
																<asp:Label ID="lblRecurringMonth" resourcekey="lblRecurringMonth" runat="server" Text=" month(s)" />
															</div>
															<asp:RequiredFieldValidator ID="rfvOfEveryMonth" resourcekey="rfvOfEveryMonth.ErrorMessage" runat="server" ControlToValidate="tbxOfEveryMonth" CssClass="NormalRed" Display="Dynamic" ErrorMessage="Day required." ValidationGroup="vgEditArticle" SetFocusOnError="True" />
															<asp:CompareValidator ID="cvOfEveryMonth" resourcekey="cvOfEveryMonth.ErrorMessage" runat="server" ControlToValidate="tbxOfEveryMonth" Display="Dynamic" ErrorMessage="Please enter number only." Operator="DataTypeCheck" Type="Integer" ValidationGroup="vgEditArticle" SetFocusOnError="True" />
														</asp:Panel>
														<asp:Panel runat="server" ID="pnlYearlyRecurringEvent" Visible="false">
															<asp:RadioButtonList ID="rblYearlyRecurringEventType" RepeatDirection="Horizontal" runat="server" OnSelectedIndexChanged="rblYearlyRecurringEventType_SelectedIndexChanged" AutoPostBack="true">
																<asp:ListItem resourcekey="liEvery" Value="0" Text="Every:" Selected="True" />
																<asp:ListItem resourcekey="liThe" Value="1" Text="The:" />
															</asp:RadioButtonList>
															<asp:Panel runat="server" ID="pnlYearlyRecurringEventSimple" Visible="true">
																<asp:DropDownList ID="ddlSimpleMonthOfYear" runat="server">
																	<asp:ListItem resourcekey="liJanuary" Value="1" Text="January" Selected="True" />
																	<asp:ListItem resourcekey="liFebruary" Value="2" Text="February" />
																	<asp:ListItem resourcekey="liMarch" Value="3" Text="March" />
																	<asp:ListItem resourcekey="liApril" Value="4" Text="April" />
																	<asp:ListItem resourcekey="liMay" Value="5" Text="May" />
																	<asp:ListItem resourcekey="liJune" Value="6" Text="June" />
																	<asp:ListItem resourcekey="liJuly" Value="7" Text="July" />
																	<asp:ListItem resourcekey="liAugust" Value="8" Text="August" />
																	<asp:ListItem resourcekey="liSeptember" Value="9" Text="September" />
																	<asp:ListItem resourcekey="liOctober" Value="10" Text="October" />
																	<asp:ListItem resourcekey="liNovember" Value="11" Text="November" />
																	<asp:ListItem resourcekey="liDecember" Value="12" Text="December" />
																</asp:DropDownList>
																<asp:TextBox ID="tbxYearlyDayOfMonth" runat="server" Width="30px" Text="1" />
																<asp:RequiredFieldValidator ID="rfvDayOfMonth" resourcekey="rfvDayOfMonth.ErrorMessage" runat="server" ControlToValidate="tbxYearlyDayOfMonth" CssClass="NormalRed" Display="Dynamic" ErrorMessage="Day required." ValidationGroup="vgEditArticle" SetFocusOnError="True" />
																<asp:CompareValidator ID="cvDayOfMonth" resourcekey="cvDayOfMonth.ErrorMessage" runat="server" ControlToValidate="tbxYearlyDayOfMonth" Display="Dynamic" ErrorMessage="Please enter number only." Operator="DataTypeCheck" Type="Integer" ValidationGroup="vgEditArticle" SetFocusOnError="True" />
																<asp:RangeValidator ID="rvDayOfMonth" resourcekey="rvDayOfMonth.ErrorMessage" runat="server" MinimumValue="1" MaximumValue="31" ControlToValidate="tbxYearlyDayOfMonth" Display="Dynamic" ErrorMessage="Please enter number between 1-31." ValidationGroup="vgEditArticle" SetFocusOnError="True" Type="Integer" />
															</asp:Panel>
															<asp:Panel runat="server" ID="pnlYearlyRecurringEventComplex" Visible="false">
																<asp:DropDownList ID="ddlYearlyRepeatedOnEvery" runat="server">
																	<asp:ListItem resourcekey="liFirst" Value="1" Text="First" Selected="True" />
																	<asp:ListItem resourcekey="liSecond" Value="2" Text="Second" />
																	<asp:ListItem resourcekey="liThird" Value="3" Text="Third" />
																	<asp:ListItem resourcekey="liFourth" Value="4" Text="Fourth" />
																	<asp:ListItem resourcekey="liLast" Value="5" Text="Last" />
																</asp:DropDownList>
																<asp:DropDownList ID="ddlYearlyRepeatedOnDay" runat="server">
																	<asp:ListItem resourcekey="liMonday" Value="1" Text="Monday" />
																	<asp:ListItem resourcekey="liThuesday" Value="2" Text="Tuesday" />
																	<asp:ListItem resourcekey="liWednesday" Value="3" Text="Wednesday" />
																	<asp:ListItem resourcekey="liThursday" Value="4" Text="Thursday" />
																	<asp:ListItem resourcekey="liFriday" Value="5" Text="Friday" />
																	<asp:ListItem resourcekey="liSaturday" Value="6" Text="Saturday" />
																	<asp:ListItem resourcekey="liSunday" Value="7" Text="Sunday" />
																</asp:DropDownList>
																of
																<asp:DropDownList ID="ddlComplexMonthOfYear" runat="server">
																	<asp:ListItem resourcekey="liJanuary" Value="1" Text="January" Selected="True" />
																	<asp:ListItem resourcekey="liFebruary" Value="2" Text="February" />
																	<asp:ListItem resourcekey="liMarch" Value="3" Text="March" />
																	<asp:ListItem resourcekey="liApril" Value="4" Text="April" />
																	<asp:ListItem resourcekey="liMay" Value="5" Text="May" />
																	<asp:ListItem resourcekey="liJune" Value="6" Text="June" />
																	<asp:ListItem resourcekey="liJuly" Value="7" Text="July" />
																	<asp:ListItem resourcekey="liAugust" Value="8" Text="August" />
																	<asp:ListItem resourcekey="liSeptember" Value="9" Text="September" />
																	<asp:ListItem resourcekey="liOctober" Value="10" Text="October" />
																	<asp:ListItem resourcekey="liNovember" Value="11" Text="November" />
																	<asp:ListItem resourcekey="liDecember" Value="12" Text="December" />
																</asp:DropDownList>
															</asp:Panel>
														</asp:Panel>
														<asp:Panel runat="server" ID="pnlUpcomingOccurrences" Style="clear: both; margin-top: 10px; margin-bottom: 10px;">
															<asp:TextBox ID="tbxUpcomingOccurrences" runat="server" Width="30px" Text="1" />
															<asp:Label ID="lblUpcomingOccurrences" resourcekey="lblUpcomingOccurrences" runat="server" Text="Display upcoming occurrences" />
															<asp:RequiredFieldValidator ID="rfvUpcomingOccurrences" resourcekey="rfvUpcomingOccurrences.ErrorMessage" runat="server" ControlToValidate="tbxUpcomingOccurrences" CssClass="NormalRed" Display="Dynamic" ErrorMessage="Upcoming occurrences required." ValidationGroup="vgEditArticle" SetFocusOnError="True" />
															<asp:CompareValidator ID="cvUpcomingOccurrences" resourcekey="cvUpcomingOccurrences.ErrorMessage" runat="server" ControlToValidate="tbxUpcomingOccurrences" Display="Dynamic" ErrorMessage="Please enter number only." Operator="DataTypeCheck" Type="Integer" ValidationGroup="vgEditArticle" SetFocusOnError="True" />
															<asp:RegularExpressionValidator ID="revUpcomingOccurrences" resourcekey="revUpcomingOccurrences.ErrorMessage" runat="server" ErrorMessage="Only positive numbers. Zero is not allowed." ValidationExpression="^[1-9]([0-9]+)?" ControlToValidate="tbxUpcomingOccurrences" Display="Dynamic" ValidationGroup="vgEditArticle"
																SetFocusOnError="True" ForeColor="Red" />
														</asp:Panel>
														<asp:Panel runat="server" ID="pnlRecurringEndType">
															<asp:RadioButtonList ID="rblRecurringEndType" runat="server" RepeatDirection="Horizontal" AutoPostBack="true" OnSelectedIndexChanged="rblRecurringEndType_SelectedIndexChanged">
																<asp:ListItem resourcekey="liEndsafterocurrences" Value="1" Text="Ends after occurrences" Selected="True" />
																<asp:ListItem resourcekey="liEndbydate" Value="2" Text="End by date" />
															</asp:RadioButtonList>
															<asp:Panel runat="server" ID="pnlRecurringEndsAfterOcurrences">
																<asp:TextBox ID="tbxEndsAfterOcurrences" runat="server" Width="30px" Text="5" />
																<asp:RequiredFieldValidator ID="rfvEndsAfterOcurrences" resourcekey="rfvEndsAfterOcurrences.ErrorMessage" runat="server" ControlToValidate="tbxEndsAfterOcurrences" CssClass="NormalRed" Display="Dynamic" ErrorMessage="Occurrences required." ValidationGroup="vgEditArticle" SetFocusOnError="True" />
																<asp:CompareValidator ID="cvEndsAfterOcurrences" resourcekey="cvEndsAfterOcurrences.ErrorMessage" runat="server" ControlToValidate="tbxEndsAfterOcurrences" Display="Dynamic" ErrorMessage="Please enter number only." Operator="DataTypeCheck" Type="Integer" ValidationGroup="vgEditArticle" SetFocusOnError="True" />
																<asp:RegularExpressionValidator ID="revEndsAfterOcurrences" resourcekey="revEndsAfterOcurrences.ErrorMessage" runat="server" ErrorMessage="Only positive numbers. Zero is not allowed." ValidationExpression="^[1-9]([0-9]+)?" ControlToValidate="tbxEndsAfterOcurrences" Display="Dynamic" ValidationGroup="vgEditArticle"
																	SetFocusOnError="True" ForeColor="Red" />
															</asp:Panel>
															<asp:Panel runat="server" ID="pnlRecurringEndByDate" Visible="false">
																<asp:TextBox ID="tbxRecurringEndByDate" runat="server" CssClass="text_generic center" ValidationGroup="vgEditArticle" Width="90px" />
																<asp:RequiredFieldValidator ID="rfvRecurringEndByDate" resourcekey="rfvRecurringEndByDate.ErrorMessage" runat="server" ControlToValidate="tbxRecurringEndByDate" CssClass="NormalRed" Display="Dynamic" Enabled="false" ErrorMessage="Date required." ValidationGroup="vgEditArticle" />
															</asp:Panel>
														</asp:Panel>
													</td>
												</tr>
											</table>
										</asp:Panel>

										<asp:Label ID="lblInfoEventLock" runat="server"></asp:Label>

										<table class="settings_table w700 no_margin" runat="server" id="tblEnableEditOccurances">
											<tr>
												<td class="left">
													<dnn:Label ID="lblReccuringInEditMode" runat="server" Text="Edit single reccuring event:" HelpText="If this option is switched on, it is possible to edit a single reccuring event from a series of reccuring events. Warning: if this option is later switched off, all the changes applied to single reccuring events will be lost." />
												</td>
												<td class="right">
													<asp:CheckBox ID="cbReccuringInEditMode" runat="server" AutoPostBack="True" OnCheckedChanged="cbReccuringInEditMode_CheckedChanged" />
												</td>
											</tr>
										</table>

										<asp:Label ID="lblReccuringInEditModeInfo" runat="server"></asp:Label>

									</div>

									<asp:Panel runat="server" ID="pnlAddEditRecurringEvents" Visible="false">
										<asp:GridView ID="gvRecurringEvents" runat="server" AutoGenerateColumns="false" CellPadding="0" CssClass="grid_view_table row_editing" EnableModelValidation="True" GridLines="None" OnRowCommand="gvRecurringEvents_RowCommand" OnRowEditing="gvRecurringEvents_RowEditing" OnRowDeleting="gvRecurringEvents_RowDeleting">
											<Columns>
												<asp:TemplateField HeaderText="Actions" ItemStyle-Width="100px">
													<EditItemTemplate>
														<asp:LinkButton ID="lbRecurringEventUpdate" runat="server" CausesValidation="true" Text="Update" CommandName="Update" CssClass="action_btn save" resourcekey="lbDocUpdateResource1" ToolTip="Save changes" CommandArgument='<%# ((GridViewRow) Container).RowIndex %>' />
														<asp:LinkButton ID="lbRecurringEventCancel" runat="server" CausesValidation="false" Text="Cancel" CommandName="Cancel" CssClass="action_btn cancel" resourcekey="LinkButton2Resource1" ToolTip="Discard changes" />
													</EditItemTemplate>
													<ItemTemplate>
														<asp:LinkButton ID="lbRecurringEventEdit" runat="server" CausesValidation="false" CommandName="Edit" CssClass="action_btn tripple edit" resourcekey="LinkButton1Resource1" ToolTip="Edit content" CommandArgument='<%# Eval("RecurringID") %>' />
														<asp:LinkButton ID="lbEditRecurringDateTime" runat="server" CausesValidation="false" CommandName="EditDateTime" CssClass="action_btn tripple edittime" resourcekey="LinkButton1Resource1" ToolTip="Edit date/time" CommandArgument='<%# Eval("RecurringID") %>' />
														<asp:LinkButton ID="lbRecurringEventDelete" runat="server" CausesValidation="false" CommandName="Delete" CssClass="action_btn tripple delete" resourcekey="lbDeleteDocResource1" ToolTip="Delete this recurring event" CommandArgument='<%# Eval("RecurringID") %>' OnClientClick="return confirm('Are you sure you want to remove this event date?');" />
													</ItemTemplate>
													<HeaderStyle CssClass="actions reccuring" />
													<ItemStyle CssClass="actions reccuring" />
												</asp:TemplateField>
												<asp:TemplateField HeaderText="ID" Visible="false">
													<ItemTemplate>
														<asp:Label ID="lblRecurringID" runat="server" Text='<%# Bind("RecurringID") %>' CssClass="light" />
													</ItemTemplate>
													<HeaderStyle CssClass="title_description" />
													<ItemStyle CssClass="title_description" />
												</asp:TemplateField>
												<asp:TemplateField HeaderText="StartDateTime">
													<ItemTemplate>
														<asp:Label ID="lblLinkUploadTitle" runat="server" Text='<%# ConvertDateTimeFromUTCToPortalTimeZone(Eval("StartDateTime")) %>' CssClass="title" />
													</ItemTemplate>
													<HeaderStyle CssClass="title_description" />
													<ItemStyle CssClass="title_description" />
												</asp:TemplateField>
												<asp:TemplateField HeaderText="EndDateTime">
													<ItemTemplate>
														<asp:Label ID="lblLinkUploadDesc" runat="server" Text='<%# ConvertDateTimeFromUTCToPortalTimeZone(Eval("EndDateTime")) %>' CssClass="title" />
													</ItemTemplate>
													<HeaderStyle CssClass="title_description" />
													<ItemStyle CssClass="title_description" />
												</asp:TemplateField>
												<asp:TemplateField HeaderText="Attendees">
													<ItemTemplate>
														<asp:Label ID="lblAttendees" runat="server" Text='<%# Bind("Attendees") %>' CssClass="light" />
													</ItemTemplate>
													<HeaderStyle CssClass="title_description" />
													<ItemStyle CssClass="title_description" />
												</asp:TemplateField>
												<asp:TemplateField HeaderText="CustomContent">
													<ItemTemplate>
														<asp:Label ID="lblCustomContent" runat="server" Text='<%# GetRecurringEventLocalization(Eval("SelectedLocales")) %>' />
													</ItemTemplate>
													<HeaderStyle CssClass="language" />
													<ItemStyle CssClass="language" />
												</asp:TemplateField>
											</Columns>
											<AlternatingRowStyle CssClass="second" />
											<HeaderStyle CssClass="header_row" />
										</asp:GridView>
										<asp:Button ID="btnShowAddRecuringEvent" runat="server" Text="Add event" OnClick="btnShowAddRecuringEvent_Click" />
										<asp:Panel runat="server" ID="pnlAddRecurringEvent" Visible="false">
											<table class="settings_table w700 no_margin">
												<tr>
													<td class="left" style="vertical-align: top; padding-top: 2px;">
														<dnn:Label ID="lblRecurringEventStartDateTime" runat="server" HelpText="Start date:" Text="Start date:" HelpKey="lblEventStartDateTime.HelpText" ResourceKey="lblEventStartDateTime" />
													</td>
													<td class="right" style="width: 225px;">
														<asp:TextBox ID="tbxRecurringEventStartDate" runat="server" CssClass="text_generic center" ValidationGroup="vgAddRecurringEvent" Width="90px" />
														<img src="<%=ModulePath%>images/icons/calendar.png" alt="RecurringEventStartDate" style="position: relative; top: 2px" />
														<asp:RequiredFieldValidator ID="rfvRecurringEventStartDate" runat="server" ControlToValidate="tbxRecurringEventStartDate" CssClass="NormalRed" Display="Dynamic" Enabled="false" ErrorMessage="Date required." ValidationGroup="vgAddRecurringEvent" resourcekey="rfvEventStartDateResource1" />
														<asp:Label ID="lblRecurringEvStartDateError" runat="server" ForeColor="Red" resourcekey="lblPubDateErrorResource1" Text="Invalid date." Visible="false" />
														<asp:TextBox ID="tbxRecurringEventStartTime" runat="server" CssClass="text_generic center" ValidationGroup="vgAddArticle" Width="55px" />
														<img id="tbxRecurringEventStartTimeIcon" src="#" alt="RecurringEventStartTimeIcon" runat="server" style="position: relative; top: 1px" />
														&nbsp;<asp:RegularExpressionValidator ID="revRecurringEventStartTime" runat="server" ControlToValidate="tbxRecurringEventStartTime" Enabled="false" ErrorMessage="hh:mm" ValidationExpression="([0-1]?[0-9]|2[0-3]):([0-5][0-9])" ValidationGroup="vgAddRecurringEvent" Display="Dynamic"
															resourcekey="revEventStartTimeResource1" />
														<asp:RequiredFieldValidator ID="rfvRecurringEventStartTime" runat="server" ControlToValidate="tbxRecurringEventStartTime" CssClass="NormalRed" Display="Dynamic" Enabled="false" ErrorMessage="Time required." ValidationGroup="vgAddRecurringEvent" resourcekey="rfvEventStartTimeResource1" />
													</td>
												</tr>
												<tr>
													<td class="left" style="vertical-align: top; padding-top: 2px;">
														<dnn:Label ID="lblRecurringEventEndDateTime" runat="server" HelpText="End date:" Text="End date:" HelpKey="lblEventEndDateTime.HelpText" ResourceKey="lblEventEndDateTime" />
													</td>
													<td class="right">
														<asp:TextBox ID="tbxRecurringEventEndDate" runat="server" CssClass="text_generic center" ValidationGroup="vgAddRecurringEvent" Width="90px" />
														<img src="<%=ModulePath%>images/icons/calendar.png" alt="RecurringEventEndDate" style="position: relative; top: 2px" />
														<asp:RequiredFieldValidator ID="rfvRecurringEventEndDate" runat="server" ControlToValidate="tbxRecurringEventEndDate" CssClass="NormalRed" Display="Dynamic" Enabled="false" ErrorMessage="Date required." ValidationGroup="vgAddRecurringEvent" resourcekey="rfvEventEndDateResource1" />
														<asp:Label ID="lblRecurringEvEndDateError" runat="server" ForeColor="Red" resourcekey="lblExpireDateErrorResource1" Text="Invalid date." Visible="false" />
														<asp:TextBox ID="tbxRecurringEventEndTime" runat="server" CssClass="text_generic center" ValidationGroup="vgAddRecurringEvent" Width="55px" />
														<img id="tbxRecurringEventEndTimeIcon" runat="server" src="#" alt="RecurringEventEndTimeIcon" style="position: relative; top: 1px" />
														&nbsp;<asp:RegularExpressionValidator ID="revRecurringEventEndTime" runat="server" ControlToValidate="tbxRecurringEventEndTime" Enabled="false" ErrorMessage="hh:mm" ValidationExpression="([0-1]?[0-9]|2[0-3]):([0-5][0-9])" ValidationGroup="vgAddRecurringEvent" Display="Dynamic"
															resourcekey="revEventEndTImeResource1" />
														<asp:RequiredFieldValidator ID="rfvRecurringEventEndTime" runat="server" ControlToValidate="tbxRecurringEventEndTime" CssClass="NormalRed" Display="Dynamic" Enabled="false" ErrorMessage="Time required." ValidationGroup="vgAddRecurringEvent" resourcekey="rfvEventEndResource1" />
													</td>
												</tr>
											</table>
											<asp:Button ID="btnSaveRecuringEvent" runat="server" Text="Save" OnClick="btnSaveRecuringEvent_Click" ValidationGroup="vgAddRecurringEvent" />
											<asp:Button ID="btnUpdateRecuringEvent" runat="server" Text="Save" OnClick="btnUpdateRecuringEvent_Click" ValidationGroup="vgAddRecurringEvent" Visible="false" />
											<asp:Button ID="btnCloseRecuringEvent" runat="server" Text="Close" OnClick="btnCloseRecuringEvent_Click" />
											<asp:Label ID="lblSaveRecuringEventInfo" runat="server"></asp:Label>
										</asp:Panel>
									</asp:Panel>

									<asp:Panel runat="server" ID="pnlRecurringContentEdit" Visible="false">
										<table class="settings_table" cellpadding="0" cellspacing="0">
											<tr>
												<td class="left">
													<asp:Label ID="lblRecurringPortalDefLanguage" runat="server" Text="Portal default language:" resourcekey="lblPortalDefLanguageResource1" />
												</td>
												<td class="right">
													<asp:Label ID="lblRecurringDefaultPortalLangugageImage" runat="server" resourcekey="lblDefaultPortalLangugageImageResource1" />
												</td>
											</tr>
											<tr>
												<td class="left">
													<asp:Label ID="lblRecurringContentLocalizationLocalizedLanguages" runat="server" Text="Localized languages:" resourcekey="lblContentLocalizationLocalizedLanguagesResource1" />
												</td>
												<td class="right">
													<asp:Label ID="lblRecurringContentLocalizationLocalizedLanguagesList" runat="server" resourcekey="lblContentLocalizationLocalizedLanguagesListResource1" />
												</td>
											</tr>
										</table>
										<div class="text_input_set">
											<dnn:Label ID="Label1" runat="server" HelpKey="lblContentLocalizationSelectLanguage.HelpText" HelpText="Select the languange you want to edit. There is no need to edit dafault language." Text="Select language:" ResourceKey="lblContentLocalizationSelectLanguage" />
											<asp:DropDownList ID="ddlRecurringEventsLocales" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlRecurringEventsLocales_SelectedIndexChanged" />
											<asp:LinkButton ID="lbRecurringEventsDeleteContent" CssClass="silver_button" Style="float: right;" runat="server" OnClick="lbRecurringEventsDeleteContent_Click" OnClientClick="return confirm('Are you sure you want to delete selected content?');">
						<span>
							<%=RecurringEventsDeleteContent%></span></asp:LinkButton>
											<asp:LinkButton ID="lbRecurringEventsCopyContent" CssClass="silver_button" Style="float: right;" runat="server" OnClick="lbRecurringEventsCopyContent_Click">
						<span>
							<%=RecurringEventsCopyContent%></span></asp:LinkButton>
										</div>
										<div class="text_input_set">
											<dnn:Label ID="lblRecurringEventSummary" runat="server" HelpKey="lblRecurringEventSummary.HelpText" HelpText="Summary" ResourceKey="lblRecurringEventSummary" Text="Summary" />
											<dnn:TextEditor ID="teRecurringEventSummary" runat="server" Height="250" Width="700" />
										</div>
										<div class="text_input_set">
											<dnn:Label ID="lblRecurringEventArticle" runat="server" HelpKey="lblRecurringEventArticle.HelpText" HelpText="Article" ResourceKey="lblRecurringEventArticle.Text" Text="Article" />
											<dnn:TextEditor ID="teRecurringEventArticle" runat="server" Height="500" Width="732" />
										</div>

										<asp:Label ID="lblAddEventContentInfo" runat="server"></asp:Label>

										<asp:Panel ID="pnlRecurringEventDocumentUpload" CssClass="section_box white_border_1 dark_grey" runat="server">
											<h1 class="section_box_title">
												<span>
													<%=DOCUMENTSincluded%></span></h1>
											<asp:RadioButtonList ID="rblRecurringEventAddDocumentType" CssClass="radio_button_list" runat="server" RepeatDirection="Horizontal" onclick="toogleRecurringEventDocumentPanels()">
												<asp:ListItem Value="0" Text="Upload new documents" Selected="True" resourcekey="rblAddDocumentType-newDocument" />
												<asp:ListItem Value="1" Text="Add existing document" resourcekey="rblAddDocumentType-existingDocument" />
											</asp:RadioButtonList>
											<div class="content document_upload">
												<div class="rounded3dBox">
													<asp:Panel ID="pnlRecurringEventAddDocument" runat="server">
														<div id="divRecurringEventAddDocumentFineUploader" runat="server" visible="false" class="EDS_simpleFineUploader documents_fine_uploader">
															<div class="uploader">
															</div>
															<div class="uploadControls">
																<div class="actions">
																	<span class="action fileSelection rounded_button gradient icon document_in_folder">
																		<asp:Label ID="lblRecurringEventDocumentFineUploaderSelect" runat="server" resourcekey="fineUploaderSelectDocuments" Text="Select documents" />
																		<span class="dnnInputFileWrapper">
																			<input type="file" value="" multiple="multiple" />
																		</span></span><span class="action upload rounded_button gradient icon orange_plus">
																			<asp:Label ID="lblRecurringEventDocumentFineUploaderStart" runat="server" resourcekey="fineUploaderUpload" Text="Upload" />
																		</span>
																</div>
																<div class="dndContainer">
																	<p>
																		<asp:Label ID="lblRecurringEventDocumentFineUploaderDrag" runat="server" resourcekey="fineUploaderDragFilesHere" Text="Drag files here" />
																	</p>
																</div>
															</div>
															<div class="uploadDetails">
																<ol class="fileUploadList">
																</ol>
															</div>
														</div>
														<div id="divRecurringEventAddDocumentStandardUploader" runat="server" visible="true" class="documents_standard_uploader">
															<asp:Label ID="lblRecurringEventDocUploadmessage" CssClass="upload_message" Visible="false" EnableViewState="false" runat="server" />
															<span class="file_selection rounded_button gradient icon document_in_folder">
																<asp:FileUpload ID="fuRecurringEventDocFileUpload" runat="server" />
															</span>
															<asp:LinkButton ID="btnRecurringEventDocUpload" runat="server" OnClick="btnDocUpload_Click" ValidationGroup="vgArticleDocs" resourcekey="btnDocUploadResource1" CssClass="action upload rounded_button gradient icon orange_plus"><span>Upload</span></asp:LinkButton>
														</div>
													</asp:Panel>
													<asp:Panel ID="pnlRecurringEventAddExistingDocument" runat="server" CssClass="documents_add_existing_container" Style="display: none;">
														<div class="messages">
															<asp:Label runat="server" ID="lblRecurringEventAddDocumentInfo" EnableViewState="false" Visible="false" CssClass="error" />
															<p>
																<asp:RequiredFieldValidator ID="rfvRecurringEventExistingDocumentID" resourcekey="rfvExistingDocumentID.ErrorMessage" runat="server" ControlToValidate="tbxRecurringEventExistingDocumentID" ErrorMessage="Document ID must be set" ValidationGroup="vgRecurringEventDocumentLinks" Display="Dynamic"
																	CssClass="error" />
															</p>
															<p>
																<asp:CompareValidator ID="cvRecurringEventExistingDocumentID" resourcekey="cvExistingDocumentID.ErrorMessage" runat="server" ControlToValidate="tbxRecurringEventExistingDocumentID" ErrorMessage="Document ID must be an integer" Operator="DataTypeCheck" Type="Integer" ValidationGroup="vgRecurringEventDocumentLinks"
																	Display="Dynamic" CssClass="error" />
															</p>
														</div>
														<div class="search_by_document_title">
															<p>
																<%=Searchdocuments%>
															</p>
															<asp:TextBox ID="tbxRecurringEventDocumentText" runat="server" AutoCompleteType="Search" CausesValidation="False" EnableViewState="false" CssClass="rounded_text_box" />
														</div>
														<div class="search_by_document_id">
															<p>
																<%=Documentid%>
															</p>
															<asp:TextBox ID="tbxRecurringEventExistingDocumentID" runat="server" CausesValidation="False" EnableViewState="false" CssClass="rounded_text_box grey" />
														</div>
														<asp:LinkButton ID="btnRecurringEventAddExistingDocument" runat="server" OnClick="lbRecurringEventAddExistingDocument_Click" ValidationGroup="vgRecurringEventDocumentLinks" CssClass="add_button rounded_button gradient icon orange_plus"><span><%=Add%></span></asp:LinkButton>
														<div class="clear_float">
														</div>
													</asp:Panel>
												</div>
												<asp:GridView ID="gvRecurringEventDocuments" runat="server" AutoGenerateColumns="false" CellPadding="0" CssClass="grid_view_table" DataKeyNames="DocEntryID,RecurringID" EnableModelValidation="True" GridLines="None" OnRowCommand="gvRecurringEventDocuments_RowCommand" OnRowEditing="gvRecurringEventDocuments_RowEditing"
													OnRowCancelingEdit="gvRecurringEventDocuments_RowCancelingEdit" OnRowUpdating="gvRecurringEventDocuments_RowUpdating" OnRowUpdated="gvRecurringEventDocuments_RowUpdated" OnRowDeleting="gvRecurringEventDocuments_RowDeleting" OnRowDataBound="gvRecurringEventDocuments_RowDataBound" OnPreRender="gvRecurringEventDocuments_PreRender" OnPageIndexChanged="gvRecurringEventDocuments_PageIndexChanged" OnPageIndexChanging="gvRecurringEventDocuments_PageIndexChanging">
													<AlternatingRowStyle CssClass="second" />
													<Columns>
														<asp:TemplateField HeaderText="Actions">
															<EditItemTemplate>
																<asp:LinkButton ID="lbDocUpdate" runat="server" CausesValidation="true" CommandName="Update" CssClass="action_btn save" resourcekey="lbDocUpdateResource1" ToolTip="Save changes" CommandArgument='<%# ((GridViewRow) Container).RowIndex %>' />
																<asp:LinkButton ID="lbDocCancel" runat="server" CausesValidation="false" CommandName="Cancel" CssClass="action_btn cancel" resourcekey="LinkButton2Resource1" ToolTip="Discard changes" />
															</EditItemTemplate>
															<ItemTemplate>
																<asp:LinkButton ID="lbDocEdit" runat="server" CausesValidation="false" CommandName="Edit" CssClass="action_btn edit" resourcekey="LinkButton1Resource1" ToolTip="<%#Editthisdocument %>" />
																<asp:LinkButton ID="lbDocDelete" runat="server" CausesValidation="false" CommandName="Delete" CssClass="action_btn red_x" resourcekey="lbDeleteDocResource1" ToolTip="<%#Deletethisdocument%>" CommandArgument='<%# ((GridViewRow) Container).RowIndex %>' />
															</ItemTemplate>
															<HeaderStyle CssClass="actions" />
															<ItemStyle CssClass="actions" />
														</asp:TemplateField>
														<asp:TemplateField HeaderText="TitleDescription">
															<EditItemTemplate>
																<asp:TextBox ID="tbDocTitle" runat="server" Text='<%# Bind("Title") %>' CssClass="light" />
																<asp:TextBox ID="tbDocDescription" runat="server" Text='<%# Bind("Description") %>' CssClass="light" />
															</EditItemTemplate>
															<ItemTemplate>
																<asp:Label ID="lblDocUploadTitle" runat="server" CssClass="title" Text='<%# Bind("Title") %>' />
																<asp:Label ID="lblDocUploadDesc" runat="server" CssClass="description" Text='<%#Bind("Description") %>' />
																<input type="text" class="token light" value="<%# GenerateDocumentToken(Eval("DocEntryID")) %>" />
															</ItemTemplate>
															<HeaderStyle CssClass="title_dscription" />
															<ItemStyle CssClass="title_dscription" />
														</asp:TemplateField>
														<asp:TemplateField HeaderText="Info">
															<ItemTemplate>
																<p class="document_link <%#PrintAlreadyInUseClass((bool) Eval("InUseByOther")) %>">
																	<%#GetDocumentDownloadLink(Eval("DocEntryID"), Eval("Filename"), Eval("FileExtension"))%>
																</p>
																<p>
																	<asp:Label ID="lblDateUploaded" runat="server" Text='<%# Convert.ToDateTime(Eval("DateUploaded")).ToShortDateString() %>' />
																	-
																			<asp:Label ID="lblDocUploadAuthor" runat="server" Text='<%#Eval("DisplayName")%>' />
																</p>
																<p>
																	<asp:Label ID="lblFileSize" runat="server" Text='<%# HumanReadableFileSize(Eval("FileSize")) %>' />
																</p>
																<p>
																	<asp:Label ID="lblDownloads" runat="server" Text='<%# NumberOfDownloadsText(Eval("NumberOfDownloads")) %>' />
																</p>
															</ItemTemplate>
															<EditItemTemplate>
																<p>
																	<asp:Label ID="lbFilenameEdit" runat="server" Text='<%# GetDocumentFilename(Eval("Filename"),Eval("FileExtension")) %>' />
																</p>
																<div id="divReplaceFileContainer" runat="server" class="replace_file">
																	<p>
																		<asp:Label ID="lblReplaceFile" runat="server" Text="Replace existing file:" resourcekey="lblDocumentsReplaceFile" />
																	</p>
																	<asp:FileUpload ID="fuReplaceFile" runat="server" />
																</div>
															</EditItemTemplate>
															<HeaderStyle CssClass="info" />
															<ItemStyle CssClass="info" />
														</asp:TemplateField>
														<asp:TemplateField HeaderText="Lang">
															<ItemTemplate>
																<asp:Label ID="lblLang" runat="server" Text='<%# GetDocumentLocalization(Eval("SelectedLocales")) %>' />
															</ItemTemplate>
															<EditItemTemplate>
																<div class="language_selection_container">
																	<asp:ListBox ID="lbEditDocUploadLanguage" runat="server" SelectionMode="Multiple" />
																</div>
															</EditItemTemplate>
															<HeaderStyle CssClass="language" />
															<ItemStyle CssClass="language" />
														</asp:TemplateField>
														<asp:TemplateField HeaderText="Show">
															<ItemTemplate>
																<asp:CheckBox ID="CheckBox1" runat="server" Enabled="false" Checked='<%#Convert.ToBoolean(Eval("Visible"))%>' />
															</ItemTemplate>
															<EditItemTemplate>
																<asp:CheckBox runat="server" ID="cbDocumentVisible" Enabled="true" Checked='<%#Convert.ToBoolean(Eval("Visible"))%>' />
															</EditItemTemplate>
															<HeaderStyle CssClass="show" />
															<ItemStyle CssClass="show" />
														</asp:TemplateField>
														<asp:TemplateField ShowHeader="false">
															<ItemTemplate>
																<asp:Label ID="lblPosition" runat="server" Text='<%# Bind("Position") %>' CssClass="rounded_inset_text_box" />
															</ItemTemplate>
															<EditItemTemplate>
																<asp:TextBox ID="tbxPosition" runat="server" Text='<%# Bind("Position") %>' CssClass="light" />
															</EditItemTemplate>
															<HeaderStyle CssClass="position" />
															<ItemStyle CssClass="position" />
														</asp:TemplateField>
														<asp:TemplateField ShowHeader="false">
															<ItemTemplate>
																<asp:LinkButton ID="lbDocMoveDown" CommandArgument='<%# ((GridViewRow) Container).RowIndex %>' CommandName="Down" runat="server" CssClass="arrow down" resourcekey="lbDocMoveDownResource1" />
																<asp:LinkButton ID="lbDocMoveUp" CommandArgument='<%# ((GridViewRow) Container).RowIndex %>' CommandName="Up" runat="server" CssClass="arrow up" resourcekey="lbDocMoveUpResource1" />
															</ItemTemplate>
															<HeaderStyle CssClass="arrows" />
															<ItemStyle CssClass="arrows" />
														</asp:TemplateField>
													</Columns>
													<HeaderStyle CssClass="header_row" />
												</asp:GridView>
											</div>
											<asp:Button ID="btnRecurringEventDocUploadRefresh" runat="server" Text="refresf" Style="display: none;" OnClick="btnRecurringEventDocUploadRefresh_Click" />
										</asp:Panel>

										<br />
										<asp:Button ID="btnSaveRecurringEventContent" runat="server" Text="Save" OnClick="btnSaveRecurringEventContent_Click" />
										<asp:Button ID="btnSaveAndCloseRecurringEventContent" runat="server" Text="Save & Close" OnClick="btnSaveAndCloseRecurringEventContent_Click" />
										<asp:Button ID="btnCloseRecurringEventContent" runat="server" Text="Close" OnClick="btnCloseRecurringEventContent_Click" />
									</asp:Panel>
								</div>
							</asp:Panel>

							<table runat="server" id="tblEventRegistration" class="settings_table w700 no_margin">
								<tr>
									<td class="left">
										<dnn:Label ID="lblRegistrationOnEvent" runat="server" Text="Enable registrations:" HelpText="Turn this option on if you would like to enable the user registration to the event. This option is not possible to turn off afterwards if there is an existing registration to the event." />
									</td>
									<td class="right">
										<asp:CheckBox ID="cbRegistrationOnEvent" runat="server" AutoPostBack="True" OnCheckedChanged="cbRegistrationOnEvent_CheckedChanged" />
									</td>
								</tr>
							</table>

							<asp:Panel runat="server" ID="pnlEventRegistration" Visible="false">
								<div class="rounded3dBox">
									<table class="settings_table w700 no_margin eventregistration">
										<%--<tr id="rowRegistrationTypecol" runat="server" visible="false">
													<td class="left">
														<dnn:Label ID="lblEventType" runat="server" Text="Event type:" HelpText="Event type." />
													</td>
													<td class="right">
														<asp:RadioButtonList ID="rblEventType" runat="server" RepeatDirection="Horizontal">
															<asp:ListItem Value="0" Text="Free" Selected="True" />
															<asp:ListItem Value="1" Text="Paid" />
														</asp:RadioButtonList>
													</td>
												</tr>--%>
										<tr>
											<td class="left">
												<dnn:Label ID="lblEventRegistrationType" ResourceKey="liRegistrationType" runat="server" Text="Registration type:" />
											</td>
											<td class="right">
												<asp:RadioButtonList ID="rblEventRegistrationType" runat="server" RepeatDirection="Horizontal" AutoPostBack="true" OnSelectedIndexChanged="rblEventRegistrationType_SelectedIndexChanged">
													<asp:ListItem Value="0" resourcekey="liRegistrationTypeClassinc" Text="Classic" Selected="True" />
													<asp:ListItem Value="1" resourcekey="liRegistrationTypeSocial" Text="Social (only for registered users)" />
												</asp:RadioButtonList>
											</td>
										</tr>
										<tr runat="server" id="rowEventMaxNumberOfTickets">
											<td class="left">
												<dnn:Label ID="lblEventMaxNumberOfTickets" runat="server" Text="Number of seats:" HelpText="The maximum number of seats (attendants) who can apply for the event. 0 is unlimited." />
											</td>
											<td class="right">
												<asp:TextBox ID="tbxMaxNumberOfTickets" runat="server" Width="50px" Text="0" /><asp:Label ID="lblNumberofseatsunlimited" resourcekey="lblNumberofseatsunlimited.Text" runat="server" Text="(0 is unlimited)"></asp:Label>
												<asp:RequiredFieldValidator ID="rfvMaxNumberOfTickets" resourcekey="rfvMaxNumberOfTickets.ErrorMessage" runat="server" ControlToValidate="tbxMaxNumberOfTickets" CssClass="NormalRed" Display="Dynamic" ErrorMessage="Required." ValidationGroup="vgEditArticle" SetFocusOnError="True" />
												<asp:CompareValidator ID="cvMaxNumberOfTickets" resourcekey="cvMaxNumberOfTickets.ErrorMessage" runat="server" ControlToValidate="tbxMaxNumberOfTickets" Display="Dynamic" ErrorMessage="Please enter number only." Operator="DataTypeCheck" Type="Integer" ValidationGroup="vgEditArticle" SetFocusOnError="True" />
												<asp:RegularExpressionValidator ID="revMaxNumberOfTickets" resourcekey="revMaxNumberOfTickets.ErrorMessage" runat="server" ControlToValidate="tbxMaxNumberOfTickets" ErrorMessage="Only positive numbers. Zero is for all." ValidationExpression="^[0-9]*$" Display="Dynamic" ValidationGroup="vgEditArticle"
													SetFocusOnError="True" ForeColor="Red" />
											</td>
										</tr>
										<tr>
											<td class="left">
												<dnn:Label ID="lblEnableRegistration" runat="server" Text="Start of registration:" HelpText="Determine the time when the user registrations are enabled. The first possible choice is 'After publish date' which means that the registrations are possible immediately after publishing. The second choice is 'Number of days before event' where we can set the number of days before the beginning of an event when registration is enabled." />
											</td>
											<td class="right">
												<asp:RadioButtonList ID="rblEnableRegistrationType" runat="server" Style="float: left; margin-right: 5px;" RepeatDirection="Horizontal" AutoPostBack="true" OnSelectedIndexChanged="rblEnableRegistrationType_SelectedIndexChanged" RepeatLayout="Flow">
													<asp:ListItem Value="0" resourcekey="liAfterpublishdate" Text="After publish date" Selected="True" />
													<asp:ListItem Value="1" resourcekey="liNumberofdaysbeforeeventstartdate" Text="Number of days before event start date" />
												</asp:RadioButtonList>
												<asp:Panel runat="server" ID="pnlEnableRegistrationType" Visible="false">
													<asp:TextBox ID="tbxEnableDaysBeforeStartDate" runat="server" Width="30px" Text="10" />
													<asp:RequiredFieldValidator ID="rfvEnableDaysBeforeStartDate" resourcekey="rfvEnableDaysBeforeStartDate.ErrorMessage" runat="server" ControlToValidate="tbxEnableDaysBeforeStartDate" CssClass="NormalRed" Display="Dynamic" ErrorMessage="Required." ValidationGroup="vgEditArticle" SetFocusOnError="True" />
													<asp:CompareValidator ID="cvEnableDaysBeforeStartDate" resourcekey="cvEnableDaysBeforeStartDate.ErrorMessage" runat="server" ControlToValidate="tbxEnableDaysBeforeStartDate" Display="Dynamic" ErrorMessage="Please enter number only." Operator="DataTypeCheck" Type="Integer" ValidationGroup="vgEditArticle" SetFocusOnError="True" />
													<asp:RegularExpressionValidator ID="revEnableDaysBeforeStartDate" resourcekey="revEnableDaysBeforeStartDate.ErrorMessage" runat="server" ControlToValidate="tbxEnableDaysBeforeStartDate" ErrorMessage="Only positive numbers. Zero is for all." ValidationExpression="^[0-9]*$" Display="Dynamic" ValidationGroup="vgEditArticle"
														SetFocusOnError="True" ForeColor="Red" />
												</asp:Panel>
											</td>
										</tr>
										<tr>
											<td class="left">
												<dnn:Label ID="lblDisableRegistration" runat="server" Text="End of registration:" HelpText="Determine the time when the possibility of registration ends. The first possible choice is 'When events starts' which means that registrations are closed at the beginning of the holding event. The second possible day is 'Number of days before event' where we can set number of days before the event starts when the further registration will be disabled." />
											</td>
											<td class="right">
												<asp:RadioButtonList ID="rblDisableRegistrationType" runat="server" Style="float: left; margin-right: 5px;" RepeatDirection="Horizontal" AutoPostBack="true" OnSelectedIndexChanged="rblDisableRegistrationType_SelectedIndexChanged" RepeatLayout="Flow">
													<asp:ListItem Value="0" resourcekey="liWheneventstarts" Text="When event starts" Selected="True" />
													<asp:ListItem Value="1" resourcekey="liNumberofdaysbeforeeventstartdate" Text="Number of days before event start date" />
												</asp:RadioButtonList>
												<asp:Panel runat="server" ID="pnlDisableRegistrationType" Visible="false">
													<asp:TextBox ID="tbxDisableDaysBeforeStartDate" runat="server" Width="30px" Text="10" />
													<asp:RequiredFieldValidator ID="rfvDisableDaysBeforeStartDate" resourcekey="rfvDisableDaysBeforeStartDate.ErrorMessage" runat="server" ControlToValidate="tbxDisableDaysBeforeStartDate" CssClass="NormalRed" Display="Dynamic" ErrorMessage="Required." ValidationGroup="vgEditArticle" SetFocusOnError="True" />
													<asp:CompareValidator ID="cvDisableDaysBeforeStartDate" resourcekey="cvDisableDaysBeforeStartDate.ErrorMessage" runat="server" ControlToValidate="tbxDisableDaysBeforeStartDate" Display="Dynamic" ErrorMessage="Please enter number only." Operator="DataTypeCheck" Type="Integer" ValidationGroup="vgEditArticle" SetFocusOnError="True" />
													<asp:RegularExpressionValidator ID="revDisableDaysBeforeStartDate" resourcekey="revDisableDaysBeforeStartDate.ErrorMessage" runat="server" ControlToValidate="tbxDisableDaysBeforeStartDate" ErrorMessage="Only positive numbers. Zero is for all." ValidationExpression="^[0-9]*$" Display="Dynamic" ValidationGroup="vgEditArticle"
														SetFocusOnError="True" ForeColor="Red" />
												</asp:Panel>
											</td>
										</tr>
										<tr runat="server" id="rowTicketsUserCanRegister">
											<td class="left">
												<dnn:Label ID="lblTicketsUserCanRegister" runat="server" Text="Seat reservation per user:" HelpText="Here you can determine how many seats a single user can register. If the option 'Unlimited' is chosen, then the user can register unlimited number of seats. If the option 'Mix-Max value' is chosen then it is possible to set the minimum and maximum number of seats a single user can register." />
											</td>
											<td class="right">
												<asp:RadioButtonList ID="rblTicketsUserCanRegister" runat="server" RepeatDirection="Horizontal" Style="float: left; margin-right: 5px;" AutoPostBack="true" OnSelectedIndexChanged="rblTicketsUserCanRegister_SelectedIndexChanged">
													<asp:ListItem Value="0" resourcekey="liUnlimited" Text="Unlimited" Selected="True" />
													<asp:ListItem Value="1" resourcekey="liMinMaxvalue" Text="Min - Max value" />
												</asp:RadioButtonList>
												<asp:Panel runat="server" ID="pnlTicketsUserCanRegister" Visible="false">
													<asp:TextBox ID="tbxEventRegisterMinTickets" runat="server" Width="30px" Text="1" />
													<asp:RequiredFieldValidator ID="rfvEventRegisterMinTickets" resourcekey="rfvEventRegisterMinTickets.ErrorMessage" runat="server" ControlToValidate="tbxEventRegisterMinTickets" CssClass="NormalRed" Display="Dynamic" ErrorMessage="Required." ValidationGroup="vgEditArticle" SetFocusOnError="True" />
													<asp:CompareValidator ID="cvEventRegisterMinTickets" resourcekey="cvEventRegisterMinTickets.ErrorMessage" runat="server" ControlToValidate="tbxEventRegisterMinTickets" Display="Dynamic" ErrorMessage="Please enter number only." Operator="DataTypeCheck" Type="Integer" ValidationGroup="vgEditArticle" SetFocusOnError="True" />
													<asp:RegularExpressionValidator ID="revEventRegisterMinTickets" resourcekey="revEventRegisterMinTickets.ErrorMessage" runat="server" ControlToValidate="tbxEventRegisterMinTickets" ErrorMessage="Only positive numbers. Zero is for all." ValidationExpression="^[0-9]*$" Display="Dynamic" ValidationGroup="vgEditArticle" SetFocusOnError="True" ForeColor="Red" />
													<asp:TextBox ID="tbxEventRegisterMaxTickets" runat="server" Width="30px" Text="1" />
													<asp:RequiredFieldValidator ID="rfEventRegisterMaxTickets" resourcekey="rfEventRegisterMaxTickets.ErrorMessage" runat="server" ControlToValidate="tbxEventRegisterMaxTickets" CssClass="NormalRed" Display="Dynamic" ErrorMessage="Required." ValidationGroup="vgEditArticle" SetFocusOnError="True" />
													<asp:CompareValidator ID="cvEventRegisterMaxTickets" resourcekey="cvEventRegisterMaxTickets.ErrorMessage" runat="server" ControlToValidate="tbxEventRegisterMaxTickets" Display="Dynamic" ErrorMessage="Please enter number only." Operator="DataTypeCheck" Type="Integer" ValidationGroup="vgEditArticle" SetFocusOnError="True" />
													<asp:RegularExpressionValidator ID="revEventRegisterMaxTickets" resourcekey="revEventRegisterMaxTickets.ErrorMessage" runat="server" ControlToValidate="tbxEventRegisterMaxTickets" ErrorMessage="Only positive numbers. Zero is for all." ValidationExpression="^[0-9]*$" Display="Dynamic" ValidationGroup="vgEditArticle" SetFocusOnError="True" ForeColor="Red" />
												</asp:Panel>
											</td>
										</tr>
										<tr runat="server" id="rowRegistrationType">
											<td class="left">
												<dnn:Label ID="lblRegistrationType" runat="server" Text="Registration type:" HelpText="Here you can choose a type of registration. If the option 'Registration on site is necessary' is chosen then the user has to be registered on site or has to register. If the option 'Registration on site is not necessary' is chosen, then users can register to an event without the need to be registered on the site." />
											</td>
											<td class="right">
												<asp:RadioButtonList ID="rblRegistrationType" runat="server" RepeatDirection="Horizontal">
													<asp:ListItem Value="0" resourcekey="liRegistrationonsiteisnecessary" Text="Registration on site is necessary" Selected="True" />
													<asp:ListItem Value="1" resourcekey="liRegistrationonsiteisnotnecessary" Text="Registration on site is not necessary" />
												</asp:RadioButtonList>
											</td>
										</tr>
										<tr>
											<td class="left">
												<dnn:Label ID="lblEventRegistrationRole" runat="server" Text="Add registered users to role:" HelpText="Here we can set the possibility of adding a certain DNN security role for a user after the registration. If the selected option is 'None', then users is not added to a security role. If the option 'Select role' is marked, then we can choose a role to which user is added after the registration." />
											</td>
											<td class="right">
												<asp:RadioButtonList ID="rblEventRegistrationRole" runat="server" RepeatDirection="Horizontal" AutoPostBack="true" OnSelectedIndexChanged="rblEventRegistrationRole_SelectedIndexChanged">
													<asp:ListItem Value="0" resourcekey="liNone" Text="None" Selected="True" />
													<asp:ListItem Value="1" resourcekey="liSelectrole" Text="Select role" />
												</asp:RadioButtonList>
												<asp:Panel runat="server" ID="pnlEventRegistrationRole" Visible="false">
													<asp:DropDownList ID="ddlEventRegistrationRoles" runat="server"></asp:DropDownList>
												</asp:Panel>
											</td>
										</tr>
										<tr runat="server" id="rowRegistrationApproval">
											<td class="left">
												<dnn:Label ID="lblRegistrationApproval" runat="server" Text="Required approval:" HelpText="If this option is turned on then approval is required for the submitted registrations." />
											</td>
											<td class="right">
												<asp:CheckBox ID="cbRegistrationApproval" runat="server" />
											</td>
										</tr>
										<tr>
											<td class="left">
												<dnn:Label ID="lblDisableFurtherRegistration" runat="server" Text="Disable further registrations:" HelpText="If this option is turned on, further registrations are disabled regardless the duration set in the settings." />
											</td>
											<td class="right">
												<asp:CheckBox ID="cbDisableFurtherRegistration" runat="server" />
											</td>
										</tr>
										<tr>
											<td class="left">
												<dnn:Label ID="lblShowRegistredUsersRole" runat="server" Text="Visibility of attendants list:" HelpText="Here we can set to whom the list of registered users is visible. If the option 'None' is chosen, then the list is not visible to anyone. When the option 'All' is chosen, then the list is visible to all, and if the option 'Select role' is chosen, then we can choose a security role to which the list is visible." />
											</td>
											<td class="right">
												<asp:RadioButtonList ID="rblShowRegistredUsersTo" runat="server" RepeatDirection="Horizontal" AutoPostBack="true" OnSelectedIndexChanged="rblShowRegistredUsersTo_SelectedIndexChanged">
													<asp:ListItem Value="0" resourcekey="liNone" Text="None" />
													<asp:ListItem Value="1" resourcekey="liAll" Text="All" Selected="True" />
													<asp:ListItem Value="2" resourcekey="liSelectrole" Text="Select role" />
												</asp:RadioButtonList>
												<asp:DropDownList ID="ddlShowRegistredUsersRole" runat="server"></asp:DropDownList>
											</td>
										</tr>
										<tr runat="server" id="rowRegistrationCFtemplateID">
											<td class="left">
												<dnn:Label ID="lblRegistrationCFtemplateID" runat="server" Text="Field template of registration form:" HelpText="Here you can choose a group of custom fields for registration form. A group of custom fields is created in Dashboard > Custom fields." />
											</td>
											<td class="right">
												<asp:DropDownList ID="ddlRegistrationCFtemplateID" runat="server"></asp:DropDownList>
											</td>
										</tr>
									</table>
									<asp:Panel runat="server" ID="pnlPostSettings" Visible="true">
										<table class="settings_table w700 no_margin eventregistration">
											<tr>
												<td class="left">
													<dnn:Label ID="lblSendInvitations" runat="server" Text="Use default invitations:" HelpText="If this option is turned on, then the event will use the default settings for invitations. The default settings are valid for the whole portal. Additional changes and adjustments of the invitations are possible." />
												</td>
												<td class="right">
													<asp:CheckBox ID="cbSendInvitations" runat="server" />
												</td>
											</tr>
											<tr>
												<td class="left">
													<dnn:Label ID="lblSendReminders" runat="server" Text="Use default reminders:" HelpText="If this option is turned on, then the event will use the default settings for reminders. The default settings are valid for the whole portal. Additional changes and adjustments of reminders are possible." />
												</td>
												<td class="right">
													<asp:CheckBox ID="cbSendReminders" runat="server" />
												</td>
											</tr>
										</table>
									</asp:Panel>
								</div>

							</asp:Panel>

						</asp:Panel>
					</div>
					<%--						</ContentTemplate>
					</asp:UpdatePanel>--%>
				</asp:Panel>
				<table class="settings_table w700">
					<tr id="rowAllowComents" runat="server">
						<td class="left">
							<dnn:Label ID="lblAllowComments" runat="server" HelpText="Allow comments:" Text="Allow comments:" HelpKey="lblAllowComments.HelpText" ResourceKey="lblAllowComments" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbAllowComments" runat="server" />
						</td>
					</tr>
					<tr id="rowFeaturedArticle" runat="server">
						<td class="left">
							<dnn:Label ID="lblFeaturedArticle" runat="server" HelpText="Featured article:" Text="Featured article:" HelpKey="lblFeaturedArticle.HelpText" ResourceKey="lblFeaturedArticle" />
						</td>
						<td class="right">
							<asp:CheckBox ID="cbFeaturedArticle" runat="server" resourcekey="cbFeaturedArticleResource1" />
						</td>
					</tr>
					<tr id="rowPublishDate" runat="server">
						<td class="left">
							<dnn:Label ID="lblPublishDate" runat="server" HelpText="Publish date:" Text="Publish date:" HelpKey="lblPublishDate.HelpText" ResourceKey="lblPublishDate" />
						</td>
						<td class="right">
							<asp:TextBox ID="tbPublishDate" runat="server" CssClass="text_generic center" ValidationGroup="vgEditArticle" Width="90px" />
							<asp:RequiredFieldValidator ID="rfvArchiveDate" runat="server" ControlToValidate="tbPublishDate" CssClass="NormalRed" Display="Dynamic" ErrorMessage="Date required." ValidationGroup="vgEditArticle" resourcekey="rfvArchiveDateResource1" />
							<asp:CompareValidator ID="cvPublishDate" runat="server" ControlToValidate="tbPublishDate" Display="Dynamic" Enabled="false" ErrorMessage="Invalid date." Operator="DataTypeCheck" Type="Date" ValidationGroup="vgEditArticle" resourcekey="cvPublishDateResource1" />
							<asp:Label ID="lblPubDateError" runat="server" ForeColor="Red" Text="Invalid date." Visible="false" resourcekey="lblPubDateErrorResource1" />
							<asp:TextBox ID="tbPublishTime" runat="server" CssClass="text_generic center" ValidationGroup="vgEditArticle" Width="50px" />
							<asp:RegularExpressionValidator ID="revPublishTIme" runat="server" ControlToValidate="tbPublishTime" ErrorMessage="hh:mm" ValidationExpression="([0-1]?[0-9]|2[0-3]):([0-5][0-9])" ValidationGroup="vgEditArticle" resourcekey="revPublishTImeResource1" />
						</td>
					</tr>
					<tr id="rowExpireDate" runat="server">
						<td class="left">
							<dnn:Label ID="lblExpireDate" runat="server" HelpText="Expire date. Must be greather than publish date." Text="Expire date:" HelpKey="lblExpireDate.HelpText" ResourceKey="lblExpireDate" />
						</td>
						<td class="right">
							<asp:TextBox ID="tbExpireDate" runat="server" CssClass="text_generic center" ValidationGroup="vgEditArticle" Width="90px" />
							<asp:RequiredFieldValidator ID="rfvArchiveDate0" runat="server" ControlToValidate="tbExpireDate" CssClass="NormalRed" Display="Dynamic" ErrorMessage="Date required." ValidationGroup="vgEditArticle" resourcekey="rfvArchiveDate0Resource1" />
							<asp:CompareValidator ID="cvPublishDate0" runat="server" ControlToValidate="tbExpireDate" CultureInvariantValues="True" Display="Dynamic" Enabled="false" ErrorMessage="Invalid date." Operator="DataTypeCheck" Type="Date" ValidationGroup="vgEditArticle"
								resourcekey="cvPublishDate0Resource1" />
							<asp:Label ID="lblExpireDateError" runat="server" ForeColor="Red" Text="Invalid date." Visible="false" resourcekey="lblExpireDateErrorResource1" />
							<asp:TextBox ID="tbExpireTime" runat="server" CssClass="text_generic center" ValidationGroup="vgEditArticle" Width="50px" />
							<asp:RegularExpressionValidator ID="revPublishTIme0" runat="server" ControlToValidate="tbExpireTime" ErrorMessage="hh:mm" ValidationExpression="([0-1]?[0-9]|2[0-3]):([0-5][0-9])" ValidationGroup="vgEditArticle" resourcekey="revPublishTIme0Resource1" />
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<div class="timezoneinfo">
								<%=Timezone%>
								<asp:Label ID="lblTimeZone" runat="server" Text="" />
							</div>
						</td>
					</tr>
				</table>
				<asp:Panel ID="pnlCustomFieldsSelect" runat="server" Visible="false">
					<asp:UpdatePanel ID="upCustomFieldsSelect" runat="server">
						<ContentTemplate>
							<div class="edn_admin_progress_overlay_container">
								<asp:UpdateProgress ID="uppCustomFieldsSelect" runat="server" AssociatedUpdatePanelID="upCustomFieldsSelect" DisplayAfter="100" DynamicLayout="true">
									<ProgressTemplate>
										<div class="edn_admin_progress_overlay">
										</div>
									</ProgressTemplate>
								</asp:UpdateProgress>
								<table class="settings_table w700" runat="server" id="tblShowHideCustomFields" visible="false">
									<tr>
										<td class="left">
											<img src="<%=ModulePath%>images/icons/customfields_small.png" alt="" style="position: relative; top: 4px;" />
											<asp:Label ID="lblShowCustomFields" runat="server" Text="Custom fields:" ResourceKey="lblShowCustomFields" Style="font-weight: bold;" />
										</td>
										<td class="right">
											<asp:CheckBox ID="cbShowCustomFields" runat="server" AutoPostBack="True" OnCheckedChanged="cbShowCustomFields_CheckedChanged" />
										</td>
									</tr>
								</table>
								<asp:Panel ID="pnlCustomFieldsDisplay" runat="server" Visible="false">
									<table runat="server" id="tblCFGroupSelection" visible="false" class="customfields-group">
										<tr>
											<td class="leftcol">
												<dnn:Label ID="lblCFGroupSelection" runat="server" Text="Custom fields group:" style="font-weight: bold;" HelpText="Select custom fields group. Only one group per article can be selected and saved" HelpKey="lblCFGroupSelection.HelpText" ResourceKey="lblCFGroupSelection" />
											</td>
											<td class="rightcol">
												<asp:DropDownList ID="ddlCFgroup" runat="server" AutoPostBack="true" />
											</td>
										</tr>
									</table>
									<asp:PlaceHolder ID="phCustomFields" runat="server" Visible="false">
										<asp:HiddenField runat="server" ID="hfParenSelectedValue" />
										<asp:HiddenField runat="server" ID="hfLastSelectedIndexChanged" />
										<asp:HiddenField runat="server" ID="hfCFLastTriggerdByList" />
										<asp:HiddenField runat="server" ID="hfPreviousCFTemplateID" />
									</asp:PlaceHolder>
								</asp:Panel>
							</div>
						</ContentTemplate>
					</asp:UpdatePanel>
				</asp:Panel>
				<asp:Panel ID="pnlPerArticlePermissions" runat="server" Visible="false">
					<asp:UpdatePanel ID="upPerArticlePermissions" runat="server" UpdateMode="Conditional">
						<ContentTemplate>
							<div class="edn_admin_progress_overlay_container">
								<asp:UpdateProgress ID="uppPerArticlePermissions" runat="server" AssociatedUpdatePanelID="upPerArticlePermissions" DisplayAfter="100" DynamicLayout="true">
									<ProgressTemplate>
										<div class="edn_admin_progress_overlay">
										</div>
									</ProgressTemplate>
								</asp:UpdateProgress>
								<p style="margin: 0 0 3px;">
									<img src="<%=ModulePath%>images/icons/lock.png" alt="" style="position: relative; top: 4px; margin: 0 3px 0 0" />
									<asp:Label ID="lblAddPerArticlePermission" runat="server" Text="Permissions per article:" Style="font-size: 13px; line-height: 16px; font-weight: bold;" resourcekey="lblAddPerArticlePermissionResource1" />
									<asp:CheckBox ID="cbAddPerArticlePermissions" runat="server" AutoPostBack="True" OnCheckedChanged="cbAddPerArticlePermissions_CheckedChanged" />
								</p>
								<asp:Panel ID="pnlAddPerArticlePermissions" runat="server" Visible="false" CssClass="rounded_box grey per_article_permissions">
									<p class="permission_warning">
										<%=Permissionsperarticleoverride%>
									</p>
									<asp:GridView ID="gvPermissionDefault" runat="server" AutoGenerateColumns="false" CellPadding="0" CssClass="permissions_table" EnableModelValidation="True" GridLines="None">
										<AlternatingRowStyle CssClass="second" />
										<Columns>
											<asp:TemplateField HeaderText="Roles">
												<ItemTemplate>
													<asp:Label ID="lblRoleName" runat="server" Text='<%# Eval("Name") %>' />:
												</ItemTemplate>
												<HeaderStyle CssClass="subject" />
												<ItemStyle CssClass="subject" />
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Viewarticle">
												<ItemTemplate>
													<asp:HiddenField ID="hfRoleID" runat="server" Value='<%# Eval("RoleID") %>' />
													<asp:CheckBox ID="cbShowArticle" runat="server" Checked='<%# Eval("Show") %>' Enabled="false" />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Editarticle">
												<ItemTemplate>
													<asp:CheckBox ID="cbEditArticle" runat="server" Checked='<%# Eval("Edit") %>' Enabled="false" />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="EventRegistration">
												<ItemTemplate>
													<asp:CheckBox ID="cbEventRegistration" runat="server" Checked='<%# Eval("EventRegistration") %>' Enabled="false" />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="DocumentDownload">
												<ItemTemplate>
													<asp:CheckBox ID="cbDocumentDownload" runat="server" Checked='<%# Eval("DocumentDownload") %>' Enabled="false" />
												</ItemTemplate>
											</asp:TemplateField>
										</Columns>
									</asp:GridView>
									<asp:GridView ID="gvRolePremissions" runat="server" AutoGenerateColumns="false" CellPadding="0" CssClass="permissions_table" EnableModelValidation="True" GridLines="None" resourcekey="gvRolePremissionsResource1">
										<AlternatingRowStyle CssClass="second" />
										<Columns>
											<asp:TemplateField>
												<ItemTemplate>
													<asp:Label ID="lblRoleName" runat="server" Text='<%# Eval("Name") %>' />:
												</ItemTemplate>
												<HeaderStyle CssClass="subject" />
												<ItemStyle CssClass="subject" />
											</asp:TemplateField>
											<asp:TemplateField>
												<ItemTemplate>
													<asp:HiddenField ID="hfRoleID" runat="server" Value='<%# Eval("RoleID") %>' />
													<asp:CheckBox ID="cbShowArticle" runat="server" Checked='<%# Eval("Show") %>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField>
												<ItemTemplate>
													<asp:CheckBox ID="cbEditArticle" runat="server" Checked='<%# Eval("Edit") %>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField>
												<ItemTemplate>
													<asp:CheckBox ID="cbEventRegistration" runat="server" Checked='<%# Eval("EventRegistration") %>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField>
												<ItemTemplate>
													<asp:CheckBox ID="cbDocumentDownload" runat="server" Checked='<%# Eval("DocumentDownload") %>' />
												</ItemTemplate>
											</asp:TemplateField>
										</Columns>
									</asp:GridView>
									<div>
										<table class="permissions_table" cellspacing="0" cellpadding="0" border="0" style="position: relative; margin-bottom: 15px;">
											<tr>
												<td class="subject">
													<asp:Label ID="lblShowToUnauthorizedUser" runat="server" Text="Unauthorized users:" resourcekey="lblShowToUnauthorizedUserResource1" />
												</td>
												<td>
													<asp:CheckBox ID="cbShowToUnauthorizedUser" runat="server" Style="position: relative;" />
												</td>
												<td></td>
												<td>
													<asp:CheckBox ID="cbEventRegistrationToUnauthorizedUser" runat="server" Style="position: relative;" /></td>
												<td>
													<asp:CheckBox ID="cbDocumentDownloadToUnauthorizedUser" runat="server" Checked='<%# Eval("DocumentDownload") %>' />
												</td>
											</tr>
										</table>
									</div>
									<asp:GridView ID="gvUserPermissions" runat="server" AutoGenerateColumns="false" CellPadding="0" CssClass="permissions_table" EnableModelValidation="True" GridLines="None" OnRowCommand="gvUserPermissions_RowCommand">
										<AlternatingRowStyle CssClass="second" />
										<Columns>
											<asp:TemplateField HeaderText="Users">
												<ItemTemplate>
													<asp:Label ID="lblUserName" runat="server" Text='<%# Eval("Name") %>' />:
												</ItemTemplate>
												<HeaderStyle CssClass="subject" />
												<ItemStyle CssClass="subject" />
											</asp:TemplateField>
											<asp:TemplateField HeaderText="View article">
												<ItemTemplate>
													<asp:HiddenField ID="hfUserID" runat="server" Value='<%# Eval("UserID") %>' />
													<asp:CheckBox ID="cbShowArticle" runat="server" Checked='<%# Eval("Show") %>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Edit article">
												<ItemTemplate>
													<asp:CheckBox ID="cbEditArticle" runat="server" Checked='<%# Eval("Edit") %>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="EventRegistration">
												<ItemTemplate>
													<asp:CheckBox ID="cbEventRegistration" runat="server" Checked='<%# Eval("EventRegistration") %>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="DocumentDownload">
												<ItemTemplate>
													<asp:CheckBox ID="cbDocumentDownload" runat="server" Checked='<%# Eval("DocumentDownload") %>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField>
												<ItemTemplate>
													<asp:LinkButton ID="lbUserPremissionRemove" runat="server" CausesValidation="false" CommandArgument='<%# Eval("UserID") %>' CommandName="Remove" OnClientClick="return confirm('Are you sure you want to remove this user permissions?');" Text="Remove" resourcekey="lbUserPremissionRemoveResource1"></asp:LinkButton>
												</ItemTemplate>
											</asp:TemplateField>
										</Columns>
									</asp:GridView>
									<asp:Label ID="lblAdduserMessage" runat="server" EnableViewState="false" ForeColor="Red" resourcekey="lblAdduserMessageResource1" />
									<table class="permissions_table">
										<tr>
											<td class="subject">
												<asp:Label ID="lblUsernameToAdd" runat="server" Text="Add user by username:" resourcekey="lblUsernameToAddResource1" />
											</td>
											<td style="width: 150px; text-align: left;">
												<asp:TextBox ID="tbUserNameToAdd" runat="server" />
												<asp:LinkButton ID="lbUsernameAdd" runat="server" OnClick="lbUsernameAdd_Click" Text="Add" resourcekey="lbUsernameAddResource1" />
											</td>
										</tr>
									</table>
								</asp:Panel>
							</div>
						</ContentTemplate>
					</asp:UpdatePanel>
				</asp:Panel>
				<div class="main_action_buttons">
					<div id="pnlSocialSharing" class="social_sharing_box" runat="server" visible="false">
						<p id="lblSocialSharingTitle" runat="server" style="font-weight: bold;">
							<span style="color: red;">
								<%=Post%></span>
							<%= Articleto %>
						</p>
						<p id="pnlPostToFacebook" runat="server" visible="false">
							<asp:CheckBox ID="cbPostToFacebook" runat="server" /><asp:Label ID="lblPostToFacebook" runat="server" Text="Facebook" />
							<asp:DropDownList ID="ddlPostToFacebook" runat="server" CssClass="custom_drop_down_style" />
						</p>
						<p id="pnlPostToTwitter" runat="server" visible="false">
							<asp:CheckBox ID="cbPostToTwitter" runat="server" /><asp:Label ID="lblPostToTwitter" runat="server" Text="Twitter" />
							<asp:DropDownList ID="ddlPostToTwitter" runat="server" CssClass="custom_drop_down_style" />
						</p>
					</div>
					<div id="pnlSocialSecurity" class="social_sharing_box" runat="server" visible="true" style="right: 255px;">
						<p id="lblSocialSecurityTitle" runat="server" style="font-weight: bold;">
							<%=Social%>
							<span style="color: red;">
								<%=Security%></span>
						</p>
						<p id="pnlSocialSecuritySelect" runat="server">
							<asp:Label ID="lblSocialSecuritySelect" resourcekey="lblSocialSecuritySelect" runat="server" Text="View:" />
							<asp:DropDownList ID="ddlSocialSecuritySelect" runat="server" CssClass="custom_drop_down_style" />
						</p>
						<p>
							<asp:Label ID="lblSocialSecurityGroups" resourcekey="lblSocialSecurityGroups" runat="server" Text="Groups:" />
							<asp:ListBox ID="lbSocialSecurityGroups" runat="server" SelectionMode="Multiple" />
						</p>
						<p id="pnlPostToJournal" runat="server" style="display: none">
							<span style="width: 100%; height: 1px; background-color: #d1d0d0; border-bottom: 1px; border-bottom-color: #ffffff; border-bottom-style: solid; display: block; margin-bottom: 3px;"></span><span style="display: block; margin-left: 76px;">
								<asp:CheckBox ID="cbPostToJournal" runat="server" /><asp:Label ID="lblPostToJournal" resourcekey="lblPostToJournal" runat="server" Text="Post to Journal" /></span>
						</p>
					</div>

					<asp:RadioButtonList ID="rblDraftPublish" runat="server" CssClass="checkbox_list" RepeatDirection="Horizontal" Style="margin: 0 0 0 40px">
						<asp:ListItem Value="Draft" resourcekey="ListItemResource27" Selected="True">Draft Article</asp:ListItem>
						<asp:ListItem Value="Publish" resourcekey="ListItemResource28">Publish Article</asp:ListItem>
					</asp:RadioButtonList>

					<asp:Label ID="lblApprovingMessage" runat="server" CssClass="EDN_warning" Text="After update, article must be approved again." Style="display: none" resourcekey="lblApprovingMessageResource1" />

					<div class="button_list center w_565">
						<asp:LinkButton ID="btnUpdateArticle" runat="server" CssClass="main_action_button w140 red save_buttons" OnClick="btnUpdateArticle_Click" Text="&lt;span&gt;Update article&lt;/span&gt;" ValidationGroup="vgEditArticle" resourcekey="btnUpdateArticleResource1">
						</asp:LinkButton>
						<asp:LinkButton ID="btnUpdateClose" runat="server" CssClass="main_action_button w140 orange save_buttons" OnClick="btnUpdateClose_Click" Text="&lt;span&gt;Update &amp;amp; Close&lt;/span&gt;" ValidationGroup="vgEditArticle" resourcekey="btnUpdateCloseResource1">
						</asp:LinkButton>
						<asp:LinkButton ID="btnGoArticle" runat="server" CssClass="main_action_button w140 yellow save_buttons" OnClick="btnGoArticle_Click" Text="&lt;span&gt;Update &amp;amp; View&lt;/span&gt;" ValidationGroup="vgEditArticle" resourcekey="btnGoArticleResource1">
						</asp:LinkButton>
						<asp:LinkButton ID="btnCancel" runat="server" CssClass="main_action_button w100 grey" OnClick="btnCancel_Click" Text="&lt;span&gt;Cancel&lt;/span&gt;" CausesValidation="false" resourcekey="btnCancelResource1" />
					</div>
					<div class="button_list right">
						<asp:LinkButton ID="lbDeleteArticle" runat="server" CssClass="delete_article_btn" OnClick="lbDeleteArticle_Click" OnClientClick="return ConfirmDelete();" resourcekey="lbDeleteArticleResource1" ToolTip="Delete article">
								<span>Delete article</span></asp:LinkButton>
					</div>
					<div style="clear: both;">
					</div>
					<asp:Label ID="lblMainEditMessage" runat="server" EnableViewState="false" />
				</div>
			</asp:Panel>
			<asp:Literal ID="containerSocialSharingHistory" runat="server" />
			<asp:Panel ID="pnlPreviousVersions" runat="server" CssClass="collapsible_box top_margin_3">
				<h1 class="collapsible_box_title">
					<%=History%></h1>
				<div class="content article_history">
					<asp:Repeater ID="repPreviousVersions" runat="server" OnItemCommand="repPreviousVersions_ItemCommand">
						<ItemTemplate>
							<p>
								<strong>
									<%=Previousversionsaved%></strong>
								<%#Eval("LastModified")%>
								<asp:LinkButton ID="lbVersionRestore" runat="server" CssClass="icon load_version" Text="Restore article to this version" CommandName="RstoreVersion" CommandArgument='<%# Eval("HistoryEntryID") %>' resourcekey="lbVersionRestoreResource1" />
								<asp:LinkButton ID="lbDeleteThisVersion" runat="server" CssClass="icon delete_version" Text="Delete this version" OnClientClick="return confirm('Are you certain you want to delete this version?');" CommandName="DeleteVersion" CommandArgument='<%# Eval("HistoryEntryID") %>'
									resourcekey="lbDeleteThisVersionResource1" />
							</p>
						</ItemTemplate>
					</asp:Repeater>
				</div>
			</asp:Panel>
		</div>
		<asp:ObjectDataSource ID="odsArticleImages" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.DataAccess" runat="server" SelectMethod="GetImagesFromGallery" UpdateMethod="UpdatePictureTitleDescription" DeleteMethod="DeleteImage">
			<DeleteParameters>
				<asp:Parameter Name="PictureID" Type="Int32" />
			</DeleteParameters>
			<SelectParameters>
				<asp:Parameter Name="GalleryID" Type="Int32" />
			</SelectParameters>
			<UpdateParameters>
				<asp:Parameter Name="PictureID" Type="Int32" />
				<asp:Parameter Name="Title" Type="String" />
				<asp:Parameter Name="Description" Type="String" />
			</UpdateParameters>
		</asp:ObjectDataSource>
		<asp:ObjectDataSource ID="odsGalleryImages" runat="server" DeleteMethod="DeleteImage" SelectMethod="GetImagesFromGallery" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.DataAccess" UpdateMethod="UpdatePictureTitleDescription">
			<DeleteParameters>
				<asp:Parameter Name="PictureID" Type="Int32" />
			</DeleteParameters>
			<SelectParameters>
				<asp:Parameter Name="GalleryID" Type="Int32" />
			</SelectParameters>
			<UpdateParameters>
				<asp:Parameter Name="PictureID" Type="Int32" />
				<asp:Parameter Name="Title" Type="String" />
				<asp:Parameter Name="Description" Type="String" />
			</UpdateParameters>
		</asp:ObjectDataSource>
		<asp:ObjectDataSource ID="odsGetTagsByName" runat="server" EnablePaging="True" SelectCountMethod="GetCloudTagsSortByNameCount" SelectMethod="GetCloudTagsSortByName" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.DataAccess" MaximumRowsParameterName="To"
			StartRowIndexParameterName="From">
			<SelectParameters>
				<asp:Parameter Name="PortalID" Type="Int32" />
				<asp:Parameter Name="From" Type="Int32" />
				<asp:Parameter Name="To" Type="Int32" />
			</SelectParameters>
		</asp:ObjectDataSource>
		<asp:ObjectDataSource ID="odsGetTagsByModified" runat="server" SelectCountMethod="GetCloudTagsSortByNameCount" SelectMethod="GetCloudTagsSortByModified" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.DataAccess" EnablePaging="True" MaximumRowsParameterName="To"
			StartRowIndexParameterName="From">
			<SelectParameters>
				<asp:Parameter Name="PortalID" Type="Int32" />
				<asp:Parameter Name="From" Type="Int32" />
				<asp:Parameter Name="To" Type="Int32" />
			</SelectParameters>
		</asp:ObjectDataSource>
		<asp:ObjectDataSource ID="odsGetTagsByPopularity" runat="server" SelectCountMethod="GetCloudTagsSortByNameCount" SelectMethod="GetCloudTagsSortByPopular" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.DataAccess" EnablePaging="True" MaximumRowsParameterName="To"
			StartRowIndexParameterName="From">
			<SelectParameters>
				<asp:Parameter Name="PortalID" Type="Int32" />
				<asp:Parameter Name="From" Type="Int32" />
				<asp:Parameter Name="To" Type="Int32" />
			</SelectParameters>
		</asp:ObjectDataSource>
		<asp:ObjectDataSource ID="odsSharedImages" runat="server" DeleteMethod="DeleteImage" SelectMethod="GetImagesFromGalleryByUserID" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.DataAccess" UpdateMethod="UpdatePictureTitleDescription">
			<DeleteParameters>
				<asp:Parameter Name="PictureID" Type="Int32" />
			</DeleteParameters>
			<SelectParameters>
				<asp:Parameter Name="GalleryID" Type="Int32" />
				<asp:Parameter Name="ByUserID" Type="Boolean" />
				<asp:Parameter Name="UserID" Type="Int32" />
			</SelectParameters>
			<UpdateParameters>
				<asp:Parameter Name="PictureID" Type="Int32" />
				<asp:Parameter Name="Title" Type="String" />
				<asp:Parameter Name="Description" Type="String" />
			</UpdateParameters>
		</asp:ObjectDataSource>
	</asp:Panel>
</asp:Panel>
<asp:Panel ID="pnlErrorInfo" runat="server" Visible="false" EnableViewState="false">
	<%=Youdonothavepermision%>
</asp:Panel>
<script type="text/javascript">
	// <![CDATA[

	function ddlOnSelectedIndexChange(ControlClientID, cfid) {
		if (document.getElementById('<%=hfParenSelectedValue.ClientID%>') != null) {
			var e = document.getElementById(ControlClientID);
			var ParentElementID = e.options[e.selectedIndex].value;
			var hfValue = document.getElementById('<%=hfParenSelectedValue.ClientID%>').value;
			if (hfValue.length != 0) {
				var indexOd = hfValue.indexOf(ControlClientID + ';')
				if (indexOd != -1){
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
			for (var i = 0; i < options.length; i++)
			{
				if(options[i].checked)
				{
					checkedValues += options[i].value + ',';
				}
			}
			if(checkedValues.length > 0){
				checkedValues = checkedValues.substring(0, checkedValues.length - 1);
				var hfValue = document.getElementById('<%=hfParenSelectedValue.ClientID%>').value;
				if (hfValue.length != 0) {
					var indexOd = hfValue.indexOf(ControlClientID + ';')
					if (indexOd != -1){
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
			else{
				var hfValue = document.getElementById('<%=hfParenSelectedValue.ClientID%>').value;
				if (hfValue.length != 0) {
					var indexOd = hfValue.indexOf(ControlClientID + ';')
					if (indexOd != -1){
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

	var edn_admin_localization = {
		image_token_editor_title: '<%=Customizegalleryitemtoken%>',
		image_token_editor_close: '<%=Close%>',
		gmaps_token_editor_add_map: '<%=Addasarticlemap%>',
		gmaps_token_editor_close: '<%=Close%>',
		gmaps_token_editor_title: '<%=AddGoogleMapslocation%>',
		gmaps_token_editor_edit_marker: '<%=Edit%>',
		gmaps_token_editor_edit_marker_editor_title: '<%=Addmapmarker%>',
		gmaps_token_editor_edit_marker_latitude: '<%=Latitude%>:',
		gmaps_token_editor_edit_marker_langitude: '<%=Longitude%>',
		gmaps_token_editor_edit_marker_center: '<%=Centeronmap%>',
		gmaps_token_editor_edit_marker_title_required_warning: '<%=Atitleisrequired%>',
		gmaps_token_editor_edit_marker_marker_title: '<%=Title%>',
		gmaps_token_editor_edit_marker_marker_html: '<%=HTMoptional%>',
		gmaps_token_editor_edit_marker_button_confirm: '<%=Confirm%>',
		gmaps_token_editor_edit_marker_button_cancel: '<%=Cancel%>'
	},
	fineUploaderLocalization = function () {
		return <%=FineUploaderLocalizationJs()%>;
	},
	galleryFineUploaderSettings = function () {
		return {
			endpoint: '<%=ModulePath%>htmluploader.ashx?portalid=<%=PortalId%>',
			params: {
				moduleId: '<%=ModuleId%>',
				galleryId: document.getElementById('<%=curentActiveGalleryId.ClientID%>').value,
				resize: document.getElementById('<%=hfResize.ClientID%>').value,
				width: document.getElementById('<%=hfResizeWidth.ClientID%>').value,
				height: document.getElementById('<%=hfResizeHeight.ClientID%>').value,
				jsonResponse: true
			},
			onAllUploadsComplete: function () {
				document.getElementById('<%=galleryUploadComplete.ClientID%>').click();
			},
			localization: fineUploaderLocalization(),
			allowedExtensions: [
				'jpg',
				'jpeg',
				'gif',
				'png',
				'bmp'
			],
			allowPreviewThumbnails: true
		}
	},
	documentsFineUploaderSettings = function () {
		return {
			endpoint: '<%=ModulePath%>htmldocumentuploader.ashx?portalid=<%=PortalId%>',
			params: {
				articleid:'<%=editArticle.ArticleID%>',
				moduleId:'<%=ModuleId%>',
				jsonResponse: true
			},
			onAllUploadsComplete: function () {
				document.getElementById('<%=btnDocUploadRefresh.ClientID%>').click();
			},
			localization: fineUploaderLocalization(),
			allowedExtensions: [],
			allowPreviewThumbnails: true
		}
	},
	recurringDocumentsFineUploaderSettings = function () {
		return {
			endpoint: '<%=ModulePath%>htmldocumentuploader.ashx?portalid=<%=PortalId%>',
			params: {
				articleid:'<%=editArticle.ArticleID%>',
				recurringId: '<%=EditEventRecurringID%>',
				moduleId:'<%=ModuleId%>',
				jsonResponse: true
			},
			onAllUploadsComplete: function () {
				document.getElementById('<%=btnRecurringEventDocUploadRefresh.ClientID%>').click();
			},
			localization: fineUploaderLocalization(),
			allowedExtensions: [],
			allowPreviewThumbnails: true
		}
	};

	function ClientValidateEmbedURL(source, arguments) {
		var textBox = document.getElementById("<%=tbEmbedVideoURL.ClientID %>");
		if(source.id.indexOf("Shared")!=-1)
		{
			textBox = document.getElementById("<%=tbSharedEmbedVideoURL.ClientID %>");
		}
		else if (source.id.indexOf("Custom")!=-1)
		{
			textBox = document.getElementById("<%=tbCustomEmbedVideoURL.ClientID %>");
		}
	var s = textBox.value;
	if((s.indexOf("youtube.com") != -1 && s.indexOf("v=") != -1)||(s.indexOf("youtu.be/") != -1)||(s.indexOf("vimeo.com") != -1))
	{
		arguments.IsValid = true;
	}
	else
	{
		arguments.IsValid = false;
	}
}

window.edn_module_root = '<%=ModulePath%>';
	window.edn_geolocation_request = <%=askForLocation%>

	if ('<%=jQueryPrefix%>'=='jQuery') {
		jQuery.noConflict();
	}

	function initializeUploadify (inputId, galleryId) {
		(function ($) {
			if ($('#EDNadmin .uploadify_container').length == 0)
				return;

			$('#' + inputId).uploadify({
				'uploader': '<%=ModulePath%>js/uploadify.swf',
				'script': '<%=ModulePath%>UploadImages.ashx?tabid=<%=TabId%>',
				'scriptData': { 'moduleId': <%=ModuleId%>, 'galleryId': galleryId },
				'cancelImg': '<%=ModulePath%>images/cancel.png',
				'multi': true,
				'fileDesc': 'Image Files',
				'fileExt': '*.jpg;*.png;*.gif;*.bmp;*.jpeg',
				'queueSizeLimit': 100,
				'sizeLimit': 40000000,
				'buttonText': 'SELECT IMAGES FOR UPLOAD',
				'onAllComplete': function () {
					document.getElementById('<%=galleryUploadComplete.ClientID%>').click();
				},
				'onError': function (e, queueID, fileObj, errorObj) {
					var msg;
					if (errorObj.status == 404) {
						alert('Could not find upload script. Use a path relative to: ' + '<?= getcwd() ?>');
						msg = 'Could not find upload script.';
					} else if (errorObj.type === "HTTP")
						msg = errorObj.type + ": " + errorObj.status;
					else if (errorObj.type === "File Size")
						msg = fileObj.name + '<br>' + errorObj.type + ' Limit: ' + Math.round(errorObj.sizeLimit / 1024) + 'KB';
					else
						msg = errorObj.type + ": " + errorObj.text;
					$.jGrowl('<p></p>' + msg, {
						theme: 'error',
						header: 'ERROR',
						sticky: true
					});
					$('#' + inputId + queueID).fadeOut(250, function () { $('#' + inputId + queueID).remove() });
					return false;
				},
				'onComplete': function (a, b, c) {
					var size = Math.round(c.size / 1024);
					$.jGrowl(
						'<p></p>' + c.name + ' - ' + size + 'KB',
						{
							theme: 'success',
							header: '<%=UploadComplete%>',
							life: 3000,
							sticky: false
						}
				);
				}
			});
		})(<%=jQueryPrefix%>);
	}

	<%=initDocumentUploadRblSelection%>

	eds1_8(function ($) {
		var token_editors_initialized = false;

		$('#EDNadmin').bind('token_editor_initialized', function () {
			if (token_editors_initialized)
				return;

			token_editors_initialized = true;

			$('.content_token_generator.gallery_item').html('\
				<div class="dialog_wrapper">\
					<div class="token_area">\
						<textarea class="the_token" cols="50" rows="5"></textarea>\
						<p><%=CopyAndPaste%></p>\
					</div>\
					<h1><%=Itemtokensettings%></h1>\
					<p class="option">\
						<label for="gallery_item_token_width">\
							<%=Width%></label>\
						<input id="gallery_item_token_width" type="text" name="width" value="" /></p>\
					<p class="option">\
						<label for="gallery_item_token_height">\
							<%=Height %></label>\
						<input id="gallery_item_token_height" type="text" name="height" value="" /></p>\
					<p class="option">\
						<%=Sizing%><input type="radio" id="gallery_item_token_sizing_proportional" class="gallery_item_token_sizing" name="sizing" value="proportional" />\
						<label for="gallery_item_token_sizing_proportional">\
							<%=Proportional %></label>\
						<input type="radio" id="gallery_item_token_sizing_crop" class="gallery_item_token_sizing" name="sizing" value="crop" /><label for="gallery_item_token_sizing_crop"><%=Croptosize%></label></p>\
					<p class="option">\
						<%=Position%><input type="radio" id="gallery_item_token_position_left_clear" class="gallery_item_token_position" name="position" value="left_clear" />\
						<label for="gallery_item_token_position_left_clear">\
							<%=Leftclear%></label>\
						<input type="radio" id="gallery_item_token_position_left" class="gallery_item_token_position" name="position" value="left" />\
						<label for="gallery_item_token_position_left">\
							<%=Leftwrap%></label>\
						<input type="radio" id="gallery_item_token_position_right" class="gallery_item_token_position" name="position" value="right" />\
						<label for="gallery_item_token_position_right">\
							<%=Rightwrap%></label></p>\
					<p class="option">\
						<%=Onclickaction%>\
						<input type="radio" id="gallery_item_token_onclick_lightbox" class="gallery_item_token_onclick" name="onclick" value="lightbox" />\
						<label for="gallery_item_token_onclick_lightbox">\
							<%=Openiteminlightbox%></label>\
						<input type="radio" id="gallery_item_token_onclick_redirect" class="gallery_item_token_onclick" name="onclick" value="redirect" />\
						<label for="gallery_item_token_onclick_redirect">\
							<%=RedirecttosetURL%></label>\
						<input type="radio" id="gallery_item_token_onclick_nothing" class="gallery_item_token_onclick" name="onclick" value="nothing" />\
						<label for="gallery_item_token_onclick_nothing">\
							<%=None%></label></p>\
					<p class="option">\
						<input type="checkbox" id="gallery_item_token_title" name="title" value="true" />\
						<label for="gallery_item_token_title">\
							<%=Showtitle%></label></p>\
					<p class="option">\
						<input type="checkbox" id="gallery_item_token_description" name="description" value="true" />\
						<label for="gallery_item_token_description">\
							<%=Showdescription%></label></p>\
					<p class="option">\
						<input type="checkbox" id="gallery_item_token_as_text_link" name="as_text_link" value="true" />\
						<label for="gallery_item_token_as_text_link">\
							<%=Showastandardtextlink%></label></p>\
					<div class="indented" style="display: none;">\
						<p class="option no_margin">\
							<label for="gallery_item_token_link_text">\<%=Linktext%></label>\
							<input type="text" id="gallery_item_token_link_text" name="link_text" value="" /></p>\
						<p class="option no_margin small_grey"><%=Note%></p>\
					</div>\
				</div>');

			$('.content_token_generator.google_maps').html('\
						<div class="dialog_wrapper">\
							<div class="pages_container">\
								<div class="page">\
									<div class="location_search">\
										<%=Searchforlocation%>\
										<input type="text" name="search_input" id="map_location_search" value="" />\
									</div>\
									<div class="map_container">\
									</div>\
									<div class="token_settings">\
										<div class="settings_wrapper">\
											<div class="page general">\
												<p class="option">\
													<button type="button" class="generate_token ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only">\
														<%=Generatetoken%></button>\
												</p>\
												<h1>\
													<%=Generalsettings%></h1>\
												<p class="option">\
													<label for="edn_maps_token_map_type">\
														<%=Maptype%></label>\
													<select name="map_type" id="edn_maps_token_map_type">\
														<option value="roadmap">Roadmap</option>\
														<option value="satellite">Satellite</option>\
														<option value="hybrid">Hybrid</option>\
														<option value="terrain">Terrain</option>\
													</select>\
												</p>\
												<p class="option">\
													<label for="edn_maps_token_latitude">\
														<%=Latitude%></label>\
													<input type="text" name="latitude" id="edn_maps_token_latitude" value="" />\
												</p>\
												<p class="option">\
													<label for="edn_maps_token_longitude">\
														<%=Longitude%></label>\
													<input type="text" name="longitude" id="edn_maps_token_longitude" value="" />\
												</p>\
												<p class="option">\
													<label for="edn_maps_token_zoom">\
														<%=Zoom%></label>\
													<input type="text" name="zoom" id="edn_maps_token_zoom" value="" />\
												</p>\
												<p class="option">\
													<label for="edn_maps_token_width">\
														<%=WidthMap%></label>\
													<input type="text" name="width" id="edn_maps_token_width" value="" />\
												</p>\
												<p class="option">\
													<label for="edn_maps_token_height">\
														<%=HeightMap%></label>\
													<input type="text" name="height" id="edn_maps_token_height" value="" />\
												</p>\
												<p class="option">\
													<input type="checkbox" name="scrollwheel" id="edn_maps_token_scrollwheel" value="1" />\
													<label for="edn_maps_token_scrollwheel">\
														<%=Enablescrollwheelzoom%></label>\
												</p>\
												<p class="option">\
													<button type="button" class="add_marker_trigger ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only">\
														<%=Addmarker%></button>\
												</p>\
												<div class="map_marker_container">\
													<h2>\
														<%=Mapmarkers %></h2>\
													<a href="#" class="delete_selected">\
														<%=Delete%></a>\
													<div class="marker_list">\
													</div>\
												</div>\
											</div>\
										</div>\
									</div>\
									<div class="token_area">\
										<p class="token_message">\
											<%=CopyAndPasteToken %></p>\
										<div>\
											<textarea class="the_token" cols="10" rows="3"></textarea></div>\
										<button type="button" class="back_to_editor ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only">\
											<%=Backtoediting%></button>\
									</div>\
								</div>\
							</div>\
						</div>');
		});
	});

<%=jQueryPrefix%>(document).ready(function ($) {
	var $social_sharing_box = $('#<%=pnlSocialSharing.ClientID%>'),
		$PostToJournal = $('#<%=pnlPostToJournal.ClientID%>'),
		$draft_radio = $('#<%=rblDraftPublish.ClientID%>_0'),
		$publish_radio = $('#<%=rblDraftPublish.ClientID%>_1'),
		$approveMsg = $('#<%=lblApprovingMessage.ClientID%>');

	if ( typeof toogleDocumentPanels == 'function' )
	{
		toogleDocumentPanels();
	}
	if ( typeof toogleRecurringEventDocumentPanels == 'function' )
	{
		toogleRecurringEventDocumentPanels();
	}
	
	$draft_radio
		.bind('change', function () {
			$social_sharing_box.stop(true,true).fadeTo(200,0);
			$PostToJournal.stop(true,true).fadeTo(200,0);
			if(<%=ApproveUpdatedArticlesASCX.ToString().ToLower()%>) $approveMsg.stop(true,true).fadeTo(200,0);
		});

	$publish_radio
		.bind('change', function () {
			$social_sharing_box.stop(true,true).fadeTo(200,1);
			$PostToJournal.stop(true,true).fadeTo(200,1);
			if(<%=ApproveUpdatedArticlesASCX.ToString().ToLower()%>) $approveMsg.stop(true,true).fadeTo(200,1);
		});

	$('#<%=tbPublishDate.ClientID%>').datepick({dateFormat:"<%=dateFormat%>"});
	$('#<%=tbExpireDate.ClientID%>').datepick({dateFormat:"<%=dateFormat%>"});
	$('#<%=tbEventStartDate.ClientID%>').datepick({dateFormat:"<%=dateFormat%>"});
	$('#<%=tbEventEndDate.ClientID%>').datepick({dateFormat:"<%=dateFormat%>"});
	$('#<%=tbxRecurringEndByDate.ClientID%>').datepick({dateFormat:"<%=dateFormat%>"});

	$('#<%=tbxRecurringEventStartDate.ClientID%>').datepick({dateFormat:"<%=dateFormat%>"});
	$('#<%=tbxRecurringEventEndDate.ClientID%>').datepick({dateFormat:"<%=dateFormat%>"});

	$('#<%=tbEventStartTime.ClientID%>').timePicker({
		startTime: "00:00",
		endTime: new Date(0, 0, 0, 23, 59, 0),
		show24Hours: <%=time24h %>,
		separator: ':',
		step: 30});
	$('#<%=tbEventEndTime.ClientID%>').timePicker({
		startTime: "00:00",
		endTime: new Date(0, 0, 0, 23, 59, 0),
		show24Hours: <%=time24h %>,
		separator: ':',
		step: 30});

	$('#<%=tbxRecurringEventStartTime.ClientID%>').timePicker({
		startTime: "00:00",
		endTime: new Date(0, 0, 0, 23, 59, 0),
		show24Hours: <%=time24h %>,
		separator: ':',
		step: 30
	});
	$('#<%=tbxRecurringEventEndTime.ClientID%>').timePicker({
		startTime: "00:00",
		endTime: new Date(0, 0, 0, 23, 59, 0),
		show24Hours: <%=time24h %>,
		separator: ':',
		step: 30
	});

	$("#EDN_admin_included_galleries")
		.sortable()
		.disableSelection();
	$('#add_existing_tags_box > .content')
		.hide(0);
	$('#add_existing_tags_box > h1.collapsible_box_title.close')
		.removeClass('close');

	var toggleCollapsibleBox = function (e) {
		var clicked = $(e.target),
			target_content = clicked.parent().children('.content');

		if (target_content.is(':visible')) {
			target_content.slideUp(300);
			clicked.removeClass('close');
		} else {
			target_content.slideDown(300);
			clicked.addClass('close');
		}
	};

	$('#EDNadmin .main_content').delegate('h1.collapsible_box_title', 'click', toggleCollapsibleBox);
	$('#<%=pnlPreviousVersions.ClientID%>').click(toggleCollapsibleBox);
	$('#<%=tbArticleTitle.ClientID%>').EDNGenerateUrl('#<%=tbArticleURL.ClientID%>', {
	<%=ViewState["ReplaceChars"]%>
	});

	$('#EDNadmin .main_content').delegate('#<%=hlOpenImageTitleDescriptionOptions.ClientID%>', 'click', function () {
		var clickedLink = $(this),targetToOpen = $('#<%=pnlImageTitleDescriptionOptions.ClientID%>');
		if (targetToOpen.is(':visible')) {
			targetToOpen.slideUp(300);
			clickedLink.removeClass('close');
		} else {
			targetToOpen.slideDown(300);
			clickedLink.addClass('close');
		}
		return false;
	});

	$('#<%=tbCLArticleTitle.ClientID%>').EDNGenerateUrl('#<%=tbxCLArticleURL.ClientID%>', {
	<%=ViewState["ReplaceChars"]%>
	});

	$('#<%=upArticleImages.ClientID%>')
		.delegate('input.token_box', 'focusin', function () {
			var $clicked = $(this);
			$clicked.select()
		})
		.delegate('#<%=lbGallerySettings.ClientID%>', 'click', function () {
			var $toggle_button = $(this),
				$gal_settings_pnl = $('#<%=pnlGallerySettings.ClientID%>');
			if ($gal_settings_pnl.is(":visible")) {
				$gal_settings_pnl.stop(false, true).hide(300);
				$toggle_button
					.html('<%=Viewsettings%>')
					.removeClass('up_arrows')
					.addClass('down_arrows');
			} else {
				$gal_settings_pnl.stop(false, true).show(300);
				$toggle_button
					.html('<%=Closesettings%>')
					.removeClass('down_arrows')
					.addClass('up_arrows');
			}
			return false;
		});

	$('#EDN_btnReGenerateURL').click(function () {
		$('#<%=tbArticleTitle.ClientID%>').trigger('keyup');
		return false;
	});
	$('#EDN_btnCLReGenerateURL').click(function () {
		$('#<%=tbCLArticleTitle.ClientID%>').trigger('keyup');
		return false;
	});

	initializeUploadify(
		'<%=fileInput.ClientID%>',
		$('#<%=hfGalID.ClientID%>').val()
	);

	initializeUploadify(
		'<%=SharedfileInput.ClientID%>',
		$('#<%=hfSharedGalID.ClientID%>').val()
	);

	initializeUploadify(
		'<%=GalfileInput.ClientID%>',
		'1'
	);

	if (document.getElementById('<%=hfResize.ClientID%>') != null)
		eds1_10('.galleryFineUploader').edsFineUploader_1_2(galleryFineUploaderSettings());

	var $documentsFineUploader = eds1_10('#<%=divAddDocumentFineUploader.ClientID %>');
	if ($documentsFineUploader.length > 0)
		$documentsFineUploader.edsFineUploader_1_2(documentsFineUploaderSettings());

	var $recurringDocumentsFineUploader = eds1_10('#<%=divRecurringEventAddDocumentFineUploader.ClientID %>');
	if ($recurringDocumentsFineUploader.length > 0)
		$recurringDocumentsFineUploader.edsFineUploader_1_2(recurringDocumentsFineUploaderSettings());
});

eds1_8(function ($) {
	$('#EDNadmin').on('click', '.save_buttons', function () {
		var $this = $(this);

		if ($this.data('clicked'))
			return false;

		if (typeof(Page_ClientValidate) == 'function' && Page_ClientValidate('vgEditArticle') == true)
			$this.data('clicked', true);
	});

	$('#<%=lbSocialSecurityGroups.ClientID %>').dropdownchecklist({
		forceMultiple: true,
		minWidth: 106,
		width: 106,
		emptyText: '<span class="empty">None</span>'
	});
});

	<%=languageDropdownCheckbox%>
	<%=languageDropdownCheckboxGridViewJS%>
	<%=includeLanguageListboxFunctions%>
<%=includeDocumentLanguageJS%>

	function pageLoad(sender, args) {
		if (args.get_isPartialLoad()) {
			(function ($) {
				$('#<%=tbPublishDate.ClientID%>').datepick({dateFormat:'<%=dateFormat%>'});
				$('#<%=tbExpireDate.ClientID%>').datepick({dateFormat:'<%=dateFormat%>'});
				$('#<%=tbEventStartDate.ClientID%>').datepick({dateFormat:"<%=dateFormat%>"});
				$('#<%=tbEventEndDate.ClientID%>').datepick({dateFormat:"<%=dateFormat%>"});
				$('#<%=tbxRecurringEndByDate.ClientID%>').datepick({dateFormat:"<%=dateFormat%>"});

				$('#<%=tbxRecurringEventStartDate.ClientID%>').datepick({dateFormat:"<%=dateFormat%>"});
				$('#<%=tbxRecurringEventEndDate.ClientID%>').datepick({dateFormat:"<%=dateFormat%>"});

				$('#<%=tbEventStartTime.ClientID%>').timePicker({
					startTime: "00:00",
					endTime: new Date(0, 0, 0, 23, 59, 0),
					show24Hours: <%=time24h %>,
					separator: ':',
					step: 30
				});
				$('#<%=tbEventEndTime.ClientID%>').timePicker({
					startTime: "00:00",
					endTime: new Date(0, 0, 0, 23, 59, 0),
					show24Hours: <%=time24h %>,
					separator: ':',
					step: 30
				});

				$('#<%=tbxRecurringEventStartTime.ClientID%>').timePicker({
					startTime: "00:00",
					endTime: new Date(0, 0, 0, 23, 59, 0),
					show24Hours: <%=time24h %>,
					separator: ':',
					step: 30
				});
				$('#<%=tbxRecurringEventEndTime.ClientID%>').timePicker({
					startTime: "00:00",
					endTime: new Date(0, 0, 0, 23, 59, 0),
					show24Hours: <%=time24h %>,
					separator: ':',
					step: 30
				});

				if ($('#<%=upArticleImages.ClientID%> .uploadifyQueue').length == 0) {
					$("#EDN_admin_included_galleries")
						.sortable()
						.disableSelection();

					initializeUploadify(
						'<%=fileInput.ClientID%>',
				$('#<%=hfGalID.ClientID%>').val()
			);

					initializeUploadify(
						'<%=SharedfileInput.ClientID%>',
				$('#<%=hfSharedGalID.ClientID%>').val()
			);

					initializeUploadify(
						'<%=GalfileInput.ClientID%>',
				'1'
			);
				}

				if (document.getElementById('<%=hfResize.ClientID%>') != null)
					eds1_10('.galleryFineUploader').edsFineUploader_1_2(galleryFineUploaderSettings());
			})(<%=jQueryPrefix%>);
		}
	}
	// ]]>
</script>
