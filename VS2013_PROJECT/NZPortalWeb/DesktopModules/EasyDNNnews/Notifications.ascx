<%@ control language="C#" autoeventwireup="true" inherits="EasyDNNSolutions.Modules.EasyDNNNews.Notifications, App_Web_notifications.ascx.d988a5ac" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<style type="text/css">
	td > .dnnTooltip label {
		text-align: left;
	}

	.auto-style1 {
		height: 21px;
	}
</style>

<script type="text/javascript">
	//<![CDATA[

	jQuery(function ($) {
		$('#EDNadmin .first_coll_fixed_table .fixed_table td > p').qtip();
	});


	var edn_all_categories = <%=GetAllCategoriesObject() %>;

	var generate_category_list_items = function (selected_categories, items) {
		var all_categories = jQuery.extend(true, [], items),
			category_list = '',
			i = 0,
			selected;

		for (; i < all_categories.length; i++) {
			selected = selected_categories.indexOf(',' + all_categories[i].id + ',') != -1;
			category_list += '<li style="margin-left: ' + (all_categories[i].level * 15) + 'px"><label><input type="checkbox"' + (selected ? ' checked="checked"' : '') + ' name="edn_permission_for_category_' + all_categories[i].id + '" value="' + all_categories[i].id + '" /><span>' + all_categories[i].name + '</span></label></li>';
		}

		return category_list;
	}

	var generate_add_edit_list_items = function (selected_categories, items) {
		var all_categories = jQuery.extend(true, [], items),
			category_list = '',
			i = 0,
			selected_html,
			hide_checkbox = false;

		for (; i < all_categories.length; i++) {
			selected_html = '';

			if (all_categories[i].id == 'Title' || all_categories[i].id == 'Categories') {
				selected_html = ' checked="checked" disabled="disabled"';
			} else {
				if (selected_categories.indexOf(',' + all_categories[i].id + ',') != -1)
					selected_html = ' checked="checked"';
			}

			if (all_categories[i].id == 'DetailType' || all_categories[i].id == 'Gallery' || all_categories[i].id == 'AdvancedSettings')
				hide_checkbox = true;
			else
				hide_checkbox = false;

			category_list += '<li style="margin-left: ' + (all_categories[i].level * 15) + 'px;' + (hide_checkbox ? ' margin-top: 5px;' : '') + '"><label><input type="checkbox"' + selected_html + (hide_checkbox ? ' style="display: none;"' : '') + ' name="edn_permission_for_category_' + all_categories[i].id + '" value="' + all_categories[i].id + '" /><span>' + all_categories[i].name + '</span></label></li>';
		}

		return category_list;
	}

	jQuery().ready(function ($) {

		var $permissions_show_all_items = $('.permissions_show_all_items > input'),
			$permissions_show_manual_item_selection = $('.permissions_show_manual_item_selection > input'),
			$permissions_show_no_items = $('.permissions_show_no_items > input'),
			$edn_permission_selection_dialog = $('.permission_selection_dialog'),
			$permission_list_items = $edn_permission_selection_dialog.find('> ul'),
			$permissions_show_selection_dialog = $('a.permissions_show_selection_dialog'),
			$customize_add_edit_show_selection_dialog = $('a.customize_add_edit_show_selection_dialog');

		$edn_permission_selection_dialog
			.dialog({
				autoOpen: false,
				buttons: { 'Close': function () { $(this).dialog('close'); } },
				resizable: false,
				width: 'auto'
			});

		$permissions_show_all_items.change(function () {
			var $this = $(this),
				$parent = $this.parent(),
				$permissions_manual_item_selection = $this.parent().siblings('.permissions_manual_item_selection');

			$permissions_manual_item_selection
				.hide(200, function () {
					$('#EDNadmin .first_coll_fixed_table .second_table_viewport .settings_table tr')
						.each(function (i) {
							align_fixed_table_row($(this));
						});
				})
				.children('input[type="hidden"]').val('')
				.siblings('textarea').val('');

			$edn_permission_selection_dialog.dialog('close');

			if ($parent.hasClass('add_edit'))
				$('> a.customize_add_edit_show_selection_dialog', $parent.parent().siblings()).css('visibility', 'visible');
		});

		$permissions_show_manual_item_selection.change(function () {
			var $this = $(this),
				$parent = $this.parent(),
				$permissions_manual_item_selection = $parent.siblings('.permissions_manual_item_selection');

			$permissions_manual_item_selection.show(200, function () {
				$('#EDNadmin .first_coll_fixed_table .second_table_viewport .settings_table tr')
                    .each(function (i) {
                    	align_fixed_table_row($(this));
                    });
			});

			$edn_permission_selection_dialog.dialog('close');

			if ($parent.hasClass('add_edit'))
				$('> a.customize_add_edit_show_selection_dialog', $parent.parent().siblings()).css('visibility', 'hidden');
		});

		$permissions_show_no_items.change(function () {
			var $this = $(this),
				$parent = $this.parent(),
				$permissions_manual_item_selection = $parent.siblings('.permissions_manual_item_selection');

			$permissions_manual_item_selection.find('> input[type="hidden"]').val('');
			$permissions_manual_item_selection.find('> .selected_categories').html('');

			$permissions_manual_item_selection.hide(200, function () {
				$('#EDNadmin .first_coll_fixed_table .second_table_viewport .settings_table tr')
                    .each(function (i) {
                    	align_fixed_table_row($(this));
                    });
			});

			$edn_permission_selection_dialog.dialog('close');

			if ($parent.hasClass('add_edit'))
				$('> a.customize_add_edit_show_selection_dialog', $parent.parent().siblings()).css('visibility', 'hidden');
		});

		$permissions_show_selection_dialog.click(function () {
			var $clicked = $(this),
				$parent = $clicked.parent(),
				$selected_categories_field = $clicked.siblings('input[type="hidden"]'),
				$selected_categories_text = $parent.find('textarea.selected_categories'),
				$add_edit_field_selection_trigger;

			$add_edit_field_selection_trigger = $parent.hasClass('add_edit') ? $('> .customize_add_edit_show_selection_dialog', $parent.parent().siblings()) : $();

			$permission_list_items
				.html(generate_category_list_items($selected_categories_field.attr('value'), ($clicked.hasClass('custom_fields') ? edn_all_custom_fields : edn_all_categories)))
				.find('input[type="checkbox"]')
					.change(function () {
						var $selected_categories = $permission_list_items.find('input[type="checkbox"]:checked'),
							selected_ids = ',',
							selected_categories_names = '';

						if ($selected_categories.length) {
							$selected_categories.each(function () {
								var $this = $(this);

								selected_ids += $this.val() + ',';
								selected_categories_names += $this.siblings('span:first').html() + ', ';
							});
							$selected_categories_field.attr('value', selected_ids);
							$selected_categories_text.html(selected_categories_names.substring(0, selected_categories_names.length - 2));

							$add_edit_field_selection_trigger.css('visibility', 'visible');
						} else {
							$selected_categories_field.attr('value', '');
							$selected_categories_text.html('');

							$add_edit_field_selection_trigger.css('visibility', 'hidden');
						}
					});

			$edn_permission_selection_dialog
				.dialog('open');

			return false;
		});

		$customize_add_edit_show_selection_dialog.click(function () {
			var $clicked = $(this),
				$selected_categories_field = $clicked.siblings('input[type="hidden"]'),
				$selected_categories_text = $clicked.parent().find('textarea.selected_categories');

			$permission_list_items
				.html(generate_add_edit_list_items($selected_categories_field.attr('value'), edn_customize_add_edit))
				.find('input[type="checkbox"]')
					.change(function () {
						var $selected_categories = $permission_list_items.find('input[type="checkbox"]:checked'),
							selected_ids = ',',
							selected_categories_names = '';

						if ($selected_categories.length) {
							$selected_categories.each(function () {
								var $this = $(this);

								selected_ids += $this.val() + ',';
								selected_categories_names += $this.siblings('span:first').html() + ', ';
							});
							$selected_categories_field.attr('value', selected_ids);
							$selected_categories_text.html(selected_categories_names.substring(0, selected_categories_names.length - 2));
						} else {
							$selected_categories_field.attr('value', '');
							$selected_categories_text.html('');
						}
					});

			$edn_permission_selection_dialog
				.dialog('open');

			return false;
		});

		eds1_8('#EDNadmin .first_coll_fixed_table .fixed_table td > p').qtip();

	});

	//]]>
</script>

<asp:Panel ID="pnlMain" runat="server">
	<div id="EDNadmin">
		<div class="module_action_title_box">
			<ul class="module_navigation_menu">
				<li>
					<asp:LinkButton ID="lbModuleNavigationAddArticle" runat="server" ToolTip="Add article" OnClick="lbModuleNavigationAddArticle_Click" meta:resourcekey="lbModuleNavigationAddArticleResource1"><img src="<%=ModulePath %>images/icons/paper_and_pencil.png" alt="" /></asp:LinkButton></li>
				<li>
					<asp:LinkButton ID="lbModuleNavigationArticleEditor" runat="server" ToolTip="Article editor" OnClick="lbModuleNavigationArticleEditor_Click" meta:resourcekey="lbModuleNavigationArticleEditorResource1"><img src="<%=ModulePath %>images/icons/papers_and_pencil.png" alt="" /></asp:LinkButton></li>
				<li>
					<asp:LinkButton ID="lbModuleNavigationCategoryEditor" runat="server" ToolTip="Category editor" OnClick="lbModuleNavigationCategoryEditor_Click" meta:resourcekey="lbModuleNavigationCategoryEditorResource1"><img src="<%=ModulePath %>images/icons/categories.png" alt="" /></asp:LinkButton></li>
				<li>
					<asp:LinkButton ID="lbModuleNavigationApproveComments" runat="server" ToolTip="Approve comments" OnClick="lbModuleNavigationApproveComments_Click" meta:resourcekey="lbModuleNavigationApproveCommentsResource1"><img src="<%=ModulePath %>images/icons/conversation.png" alt="" /></asp:LinkButton></li>
				<li>
					<asp:LinkButton ID="lbModuleNavigationDashboard" runat="server" ToolTip="Dashboard" OnClick="lbModuleNavigationDashboard_Click" meta:resourcekey="lbModuleNavigationDashboardResource1"><img src="<%=ModulePath %>images/icons/lcd.png" alt="" /></asp:LinkButton></li>
				<li class="power_off">
					<asp:LinkButton ID="lbPowerOff" runat="server" ToolTip="Close" meta:resourcekey="lbPowerOffResource1"><img src="<%=ModulePath %>images/icons/power_off.png" alt="" /></asp:LinkButton></li>
			</ul>
			<h1>
				<%=TopTitle%></h1>
		</div>
		<div class="main_content">
			<div class="tabbed_container">
				<br />
				<div id="pnlAllSettings" class="module_settings" runat="server" resourcekey="pnlAllSettingsResource1">
					<div id="pnlPermissions" runat="server" cssclass="settings_category_container">
						<div class="category_content">
							<div class="permission_selection_dialog" title="Select items">
								<ul>
								</ul>
							</div>
							<div class="first_coll_fixed_table permissionsNotifications">
								<asp:GridView ID="gvRoleNames" runat="server" CssClass="settings_table fixed_table permissionsNotifications" AutoGenerateColumns="False" DataKeyNames="RoleID" CellPadding="0" resourcekey="gvRolePremissionsLabelsResource1">
									<AlternatingRowStyle CssClass="second" />
									<Columns>
										<asp:TemplateField HeaderText="Roles" HeaderStyle-Height="30px">
											<ItemTemplate>
												<p title="<%#Eval("RoleName")%>">
													<asp:Label ID="lblRoleName" runat="server" Text='<%#Eval("RoleName")%>' resourcekey="lblRoleNameResource1"></asp:Label>
												</p>
											</ItemTemplate>
											<HeaderStyle CssClass="header_cell" />
										</asp:TemplateField>
									</Columns>
								</asp:GridView>
								<div class="second_table_viewport">
									<asp:GridView ID="gvRoleNotificationSettings" runat="server" CssClass="settings_table permissionsNotifications" AutoGenerateColumns="False" DataKeyNames="RoleID" CellPadding="0" OnRowDataBound="gvRoleNotificationSettings_RowDataBound">
										<AlternatingRowStyle CssClass="second" />
										<Columns>
											<asp:TemplateField HeaderText="New article notification">
												<ItemTemplate>
													<asp:HiddenField ID="hfRoleID" runat="server" Value='<%# Eval("RoleID") %>' />
													<asp:HiddenField ID="hfRoleName" runat="server" Value='<%# Eval("RoleName") %>' />
													<asp:CheckBox ID="cbNewArticle" runat="server" Checked='<%#Convert.ToBoolean(Eval("NewArticle"))%>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="New event notification">
												<ItemTemplate>
													<asp:CheckBox ID="cbNewEvent" runat="server" Checked='<%#Convert.ToBoolean(Eval("Newevent"))%>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Edit article notification">
												<ItemTemplate>
													<asp:CheckBox ID="cbEditArticle" runat="server" Checked='<%#Convert.ToBoolean(Eval("EditArticle"))%>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Request for approve article">
												<ItemTemplate>
													<asp:CheckBox ID="cbApproveArticle" runat="server" Checked='<%#Convert.ToBoolean(Eval("ApproveArticle"))%>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="New comment notification">
												<ItemTemplate>
													<asp:CheckBox ID="cbNewComment" runat="server" Checked='<%#Convert.ToBoolean(Eval("NewComment"))%>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Request for approve comment">
												<ItemTemplate>
													<asp:CheckBox ID="cbApproveComment" runat="server" Checked='<%#Convert.ToBoolean(Eval("ApproveComment"))%>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Event registration">
												<ItemTemplate>
													<asp:CheckBox ID="cbEventRegistration" runat="server" Checked='<%#Convert.ToBoolean(Eval("EventRegistration"))%>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Select categories">
												<ItemTemplate>
													<asp:RadioButton ID="rbAllCategories" runat="server" Checked='<%# Convert.ToBoolean(Eval("SendToAllCategories")) %>' CssClass="permissions_show_all_items" GroupName="roleCategoryPermissions" Text="All categories" />
													<asp:RadioButton ID="rbManualCategories" runat="server" Checked='<%# !Convert.ToBoolean(Eval("SendToAllCategories")) %>' CssClass="permissions_show_manual_item_selection" GroupName="roleCategoryPermissions" Text="Select categories" />
													<asp:RadioButton ID="rbRoleNoneShow" runat="server" Checked='<%# !Convert.ToBoolean(Eval("SendToAllCategories")) %>' CssClass="permissions_show_no_items" GroupName="roleCategoryPermissions" Text="None" />
													<asp:Panel runat="server" ID="pnlShowCatsManualSelection" CssClass="permissions_manual_item_selection" Style="display: none">
														<asp:HiddenField ID="hfCategoriesToShow" runat="server" />
														<asp:LinkButton ID="lbManualySelectCategories" runat="server" CssClass="permissions_show_selection_dialog" Text="Select categories" />
														<asp:TextBox ID="tbRolesCatsToShow" runat="server" Columns="50" CssClass="selected_categories" TextMode="MultiLine" onkeypress="javascript:return false;" />
													</asp:Panel>
												</ItemTemplate>
												<ItemStyle HorizontalAlign="Center" />
											</asp:TemplateField>
											<asp:TemplateField HeaderText="">
												<ItemTemplate>
												</ItemTemplate>
											</asp:TemplateField>
										</Columns>
									</asp:GridView>
								</div>
							</div>
							<div class="first_coll_fixed_table permissionsNotifications">
								<asp:GridView ID="gvUserNames" runat="server" CssClass="settings_table fixed_table permissionsNotifications" AutoGenerateColumns="False" DataKeyNames="UserID" CellPadding="0" OnRowCommand="gvUserNames_RowCommand">
									<AlternatingRowStyle CssClass="second" />
									<Columns>
										<asp:TemplateField HeaderText="Users" HeaderStyle-Height="30px">
											<ItemTemplate>
												<p title="<%#Eval("UserName")%>">
													<asp:Label ID="lblUserName" runat="server" Text='<%#Eval("UserName")%>' resourcekey="lblRoleNameResource1"></asp:Label><br />
													<asp:LinkButton ID="lbUserNotificationsRemove" resourcekey="lbUserNotificationsRemove" runat="server" CausesValidation="False" CommandArgument='<%#Eval("UserID")%>' CommandName="Remove" OnClientClick="return confirm('Are you sure you want to remove this user notifications?');" Text="Remove"></asp:LinkButton>
												</p>
											</ItemTemplate>
											<HeaderStyle CssClass="header_cell" />
										</asp:TemplateField>
									</Columns>
								</asp:GridView>
								<div class="second_table_viewport">
									<asp:GridView ID="gvUserNotificationSettings" runat="server" CssClass="settings_table permissionsNotifications" AutoGenerateColumns="False" DataKeyNames="UserID" CellPadding="0" OnRowDataBound="gvUserNotificationSettings_RowDataBound">
										<AlternatingRowStyle CssClass="second" />
										<Columns>
											<asp:TemplateField HeaderText="New article notification">
												<ItemTemplate>
													<asp:HiddenField ID="hfUserID" runat="server" Value='<%# Eval("UserID") %>' />
													<asp:HiddenField ID="hfUsername" runat="server" Value='<%# Eval("Username") %>' />
													<asp:CheckBox ID="cbNewArticle" runat="server" Checked='<%#Convert.ToBoolean(Eval("NewArticle"))%>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="New event notification">
												<ItemTemplate>
													<asp:CheckBox ID="cbNewEvent" runat="server" Checked='<%#Convert.ToBoolean(Eval("Newevent"))%>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Edit article notification">
												<ItemTemplate>
													<asp:CheckBox ID="cbEditArticle" runat="server" Checked='<%#Convert.ToBoolean(Eval("EditArticle"))%>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Request for approve article">
												<ItemTemplate>
													<asp:CheckBox ID="cbApproveArticle" runat="server" Checked='<%#Convert.ToBoolean(Eval("ApproveArticle"))%>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="New comment notification">
												<ItemTemplate>
													<asp:CheckBox ID="cbNewComment" runat="server" Checked='<%#Convert.ToBoolean(Eval("NewComment"))%>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Request for approve comment">
												<ItemTemplate>
													<asp:CheckBox ID="cbApproveComment" runat="server" Checked='<%#Convert.ToBoolean(Eval("ApproveComment"))%>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Event registration">
												<ItemTemplate>
													<asp:CheckBox ID="cbEventRegistration" runat="server" Checked='<%#Convert.ToBoolean(Eval("EventRegistration"))%>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Select categories">
												<ItemTemplate>
													<asp:RadioButton ID="rbUserAllCategories" runat="server" Checked='<%# Convert.ToBoolean(Eval("SendToAllCategories")) %>' CssClass="permissions_show_all_items" GroupName="userCategoryPermissions" Text="All categories" />
													<asp:RadioButton ID="rbUserManualCategories" runat="server" Checked='<%# !Convert.ToBoolean(Eval("SendToAllCategories")) %>' CssClass="permissions_show_manual_item_selection" GroupName="userCategoryPermissions" Text="Select categories" />
													<asp:RadioButton ID="rbUserNoneShow" runat="server" Checked='<%# !Convert.ToBoolean(Eval("SendToAllCategories")) %>' CssClass="permissions_show_no_items" GroupName="userCategoryPermissions" Text="None" />
													<asp:Panel runat="server" ID="pnlUserShowCatsManualSelection" CssClass="permissions_manual_item_selection" Style="display: none">
														<asp:HiddenField ID="hfUserCategoriesToShow" runat="server" />
														<asp:LinkButton ID="lbUserManualySelectCategories" runat="server" CssClass="permissions_show_selection_dialog" Text="Select categories" />
														<asp:TextBox ID="tbUserCatsToShow" runat="server" Columns="50" CssClass="selected_categories" TextMode="MultiLine" onkeypress="javascript:return false;" />
													</asp:Panel>
												</ItemTemplate>
												<HeaderStyle HorizontalAlign="Center" />
											</asp:TemplateField>
											<asp:TemplateField HeaderText="">
												<ItemTemplate>
												</ItemTemplate>
											</asp:TemplateField>
										</Columns>
									</asp:GridView>
								</div>
							</div>
						</div>
					</div>
				</div>
				<asp:Label ID="lblAdduserMessage" runat="server" EnableViewState="False" ForeColor="Red" />
				<table class="permissions_table" style="margin-top: 10px;">
					<tr>
						<td class="subject">
							<asp:Label ID="lblUsernameToAdd" resourcekey="lblUsernameToAdd" runat="server" Text="Add user by username:" Font-Bold="True" />
						</td>
						<td style="width: 250px; text-align: left;">
							<asp:TextBox ID="tbUserNameToAdd" runat="server" />
							<asp:LinkButton ID="lbUsernameAdd" resourcekey="lbUsernameAdd" runat="server" OnClick="lbUsernameAdd_Click" Text="Add" />
						</td>
					</tr>
				</table>
			</div>
			<br />
			<br />
			<table class="settings_table" cellpadding="0" cellspacing="0">
				<tr>
					<td class="left">
						<asp:CheckBox ID="cbArticleApproveConfirmation" runat="server" />
					</td>
					<td class="right">
						<dnn:Label ID="lblArticleApproveConfirmation" runat="server" Text="Send notification to author of article when article is approved or denied" ControlName="cbArticleApproveConfirmation"
							HelpText="Send notification to author of article when article is approved or denied" HelpKey="lblArticleApproveConfirmation.HelpText" ResourceKey="lblArticleApproveConfirmation" />
					</td>
				</tr>
				<tr>
					<td class="left">
						<asp:CheckBox ID="cbCommentApproveConfirmation" runat="server" />
					</td>
					<td class="right">
						<dnn:Label ID="lblCommentApproveConfirmation" runat="server" Text="Send notification to author of comment when comment is approved or denied" ControlName="cbCommentApproveConfirmation"
							HelpText="Send notification to author of comment when comment is approved or denied" HelpKey="lblCommentApproveConfirmation.HelpText" ResourceKey="lblCommentApproveConfirmation" />
					</td>
				</tr>
				<tr>
					<td class="left">
						<asp:CheckBox ID="cbArticleAuthorCommentApproveConfirm" runat="server" />
					</td>
					<td class="right">
						<dnn:Label ID="lblcbArticleAuthorCommentApproveConfirm" runat="server" Text="Send notification to author of article when comment is posted to their article." ControlName="cbCommentApproveConfirmation"
							HelpText="Send notification to author of article when comment is posted to their article." />
					</td>
				</tr>
				<tr>
					<td class="left">
						<asp:CheckBox ID="cbSendEventRegistrationInfoToArticleAuthor" runat="server" />
					</td>
					<td class="right">
						<dnn:Label ID="lblSendEventRegistrationInfoToArticleAuthor" runat="server" Text="Send notification to author of article when someone registers to event." ControlName="cbSendEventRegistrationInfoToArticleAuthor"
							HelpText="Send notification to author of article when someone registers to event." />
					</td>
				</tr>
				<tr>
					<td colspan="2" style="text-align: center" align="center">
						<asp:Label ID="lblsaveInfo" runat="server" EnableViewState="False" />
					</td>
				</tr>
				<tr>
					<td align="center" colspan="2" style="text-align: center">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" style="text-align: center">
						<asp:Button ID="btnSave" resourcekey="btnSave" runat="server" OnClick="btnSave_Click" Text="Save" />
						<asp:Button ID="btnClose" resourcekey="btnClose" runat="server" OnClick="btnClose_Click" Text="Close" /><br />
					</td>
				</tr>
			</table>
			<br />
			<br />
		</div>
	</div>
</asp:Panel>
