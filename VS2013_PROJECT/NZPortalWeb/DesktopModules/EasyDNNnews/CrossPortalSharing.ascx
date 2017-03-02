<%@ control language="C#" inherits="EasyDNNSolutions.Modules.EasyDNNNews.CrossPortalSharing, App_Web_crossportalsharing.ascx.d988a5ac" autoeventwireup="true" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<script type="text/javascript">
//<![CDATA[
	if ('<%=ViewState["jQuery"]%>' == 'jQuery') {
		jQuery.noConflict();
	}
	var edn_all_categories = <%=GetAllPortalsObject()%>;

	var generate_category_list_items = function (selected_categories, items, exclude_id) {
		var all_categories = jQuery.extend(true, {}, items),
			selected_categories_ids,
			category_list = '';

		if (selected_categories) {
			selected_categories_ids = selected_categories.split(',');

			for (i in selected_categories_ids) {
				if (typeof all_categories[selected_categories_ids[i]] == 'object') {
					all_categories[selected_categories_ids[i]].selected = true;
				}
			}
		}

		for (cat in all_categories)
			if (cat != exclude_id)
				category_list += '<li style="margin-left: ' + (all_categories[cat].level * 15) + 'px; list-style: none"><label><input type="checkbox"' + (all_categories[cat].selected ? ' checked="checked"' : '') + ' name="edn_permission_for_category_' + cat + '" value="' + cat + '" /><span>' + all_categories[cat].name + '</span></label></li>'

		return category_list;
	}

	jQuery().ready(function ($) {
		var $permissions_show_all_items = $('.permissions_show_all_items > input'),
			$permissions_show_manual_item_selection = $('.permissions_show_manual_item_selection > input'),
			$permissions_show_no_items = $('.permissions_show_no_items > input'),
			$edn_portal_selection_dialog = $('.portal_selection_dialog'),
			$permission_list_items = $edn_portal_selection_dialog.find('> ul'),
			$permissions_show_selection_dialog = $('a.permissions_show_selection_dialog');

		$edn_portal_selection_dialog
			.dialog({
				autoOpen: false,
				buttons: { '<%=strClose%>': function () { $(this).dialog('close'); } },
				resizable: false,
				width: 'auto'
			});

		$permissions_show_all_items.change(function () {
			var $this = $(this),
				$permissions_manual_item_selection = $this.parent().siblings('.permissions_manual_item_selection');

			$permissions_manual_item_selection
				.hide(200)
				.children('input[type="hidden"]').val('');

			$edn_portal_selection_dialog.dialog('close');
		});

		$permissions_show_manual_item_selection.change(function () {
			var $this = $(this),
				$permissions_manual_item_selection = $this.parent().siblings('.permissions_manual_item_selection');

			$permissions_manual_item_selection.show(200);
			$edn_portal_selection_dialog.dialog('close');
		});

		$permissions_show_no_items.change(function () {
			var $this = $(this),
				$permissions_manual_item_selection = $this.parent().siblings('.permissions_manual_item_selection');

			$permissions_manual_item_selection.find('> input[type="hidden"]').val('');
			$permissions_manual_item_selection.find('> .selected_categories').html('');

			$permissions_manual_item_selection.hide(200);

			$edn_portal_selection_dialog.dialog('close');
		});

		$permissions_show_selection_dialog.click(function () {
			var $clicked = $(this),
				$selected_categories_field = $clicked.parent().siblings('input[type="hidden"]'),
				$selected_categories_text = $clicked.parent().siblings('p.selected_categories'),
				parent_portal_id = parseInt($clicked.parent().parent().siblings('input[type="hidden"]').val());

			$permission_list_items
				.html(generate_category_list_items($selected_categories_field.attr('value'), edn_all_categories, parent_portal_id))
				.find('input[type="checkbox"]')
					.change(function () {
						var $selected_categories = $permission_list_items.find('input[type="checkbox"]:checked'),
							selected_ids = '',
							selected_categories_names = '';

						if ($selected_categories.length) {
							$selected_categories.each(function () {
								var $this = $(this);

								selected_ids += $this.val() + ',';
								selected_categories_names += $this.siblings('span:first').html() + ', ';
							});
							$selected_categories_field.attr('value', selected_ids.substring(0, selected_ids.length - 1));
							$selected_categories_text.html(selected_categories_names.substring(0, selected_categories_names.length - 2));
						} else {
							$selected_categories_field.attr('value', '');
							$selected_categories_text.html('');
						}
					});

			$edn_portal_selection_dialog
				.dialog('open');

			return false;
		});
	});
//]]>
</script>
<div id="EDNadmin">
	<div class="module_action_title_box">
		<h1>
			<%=CrossPortalsharing%></h1>
	</div>
	<div class="main_content token_editor">
		<div class="tabbed_container">
			<div class="portal_sharing_container">
				<h1>
					<asp:Label ID="lblPortalSharing" runat="server" Text="Portal sharing options" resourcekey="lblPortalSharing"></asp:Label></h1>
				<div class="portal_selection_dialog" title="<%=strSelectportals%>">
					<ul>
					</ul>
				</div>
				<asp:GridView ID="gvPortalSharing" runat="server" AutoGenerateColumns="False" GridLines="None" CssClass="shared_portals" resourcekey="gvPortalSharingResource1" OnRowDataBound="gvPortalSharing_RowDataBound">
					<Columns>
						<asp:TemplateField HeaderText="Portal" HeaderStyle-CssClass="left_side" ItemStyle-CssClass="left_side">
							<ItemTemplate>
								<asp:Label ID="Label1" runat="server" Text='<%# String.Format("{0} (Id:{1})", Eval("PortalName"), Eval("PortalID")) %>' resourcekey="Label1Resource1"></asp:Label>
							</ItemTemplate>
							<HeaderStyle CssClass="left_side"></HeaderStyle>
							<ItemStyle CssClass="left_side"></ItemStyle>
						</asp:TemplateField>
						<asp:TemplateField HeaderText="Shared on portals" HeaderStyle-CssClass="right_side" ItemStyle-CssClass="right_side">
							<ItemTemplate>
								<asp:HiddenField ID="hfPortalID" runat="server" Value='<%# Eval("PortalID") %>' />
								<asp:RadioButton ID="rbPortalsSelect" runat="server" CssClass="permissions_show_manual_item_selection" GroupName="portalsShareSelection" Text="Select portals" resourcekey="rbPortalsSelectResource1" />
								<asp:RadioButton ID="rbPortalsNone" runat="server" Checked='True' CssClass="permissions_show_no_items" GroupName="portalsShareSelection" Text="None" resourcekey="rbPortalsNoneResource1" />
								<asp:Panel runat="server" ID="pnlAddToCatsManualSelection" Style="display: none;" CssClass="permissions_manual_item_selection" resourcekey="pnlAddToCatsManualSelectionResource1">
									<asp:HiddenField ID="hfPortalsToShareTo" runat="server" />
									<p>
										<asp:LinkButton ID="lbPortalsToShareTo" runat="server" CssClass="permissions_show_selection_dialog" Text="Select portals" resourcekey="lbPortalsToShareToResource1" /></p>
									<p id="ptagSelectedPortalNames" runat="server" class="selected_categories">
									</p>
								</asp:Panel>
							</ItemTemplate>
							<HeaderStyle CssClass="right_side"></HeaderStyle>
							<ItemStyle CssClass="right_side"></ItemStyle>
						</asp:TemplateField>
					</Columns>
					<RowStyle CssClass="row" />
					<AlternatingRowStyle CssClass="second row" />
				</asp:GridView>
				<p class="main_actions">
					<asp:Button ID="btnSaveSettings" runat="server" OnClick="btnSaveSettings_Click" Text="Save" resourcekey="btnSaveSettingsResource1" />
					<asp:Button ID="btnSaveClose" runat="server" OnClick="btnSaveClose_Click" Text="Save &amp; Close" resourcekey="btnSaveCloseResource1" />
					<asp:Button ID="btnClose" resourcekey="btnClose" runat="server" Text="Close" OnClick="btnClose_Click" />
				</p>
			</div>
			<p>
				<asp:Label ID="lblPortalSharingMessage" runat="server" Visible="False" resourcekey="lblPortalSharingMessageResource1">Settings saved.</asp:Label></p>
		</div>
	</div>
</div>
