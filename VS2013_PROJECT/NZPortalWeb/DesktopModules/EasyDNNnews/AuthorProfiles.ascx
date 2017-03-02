<%@ control language="C#" autoeventwireup="true" inherits="EasyDNNSolutions.Modules.EasyDNNNews.AuthorProfiles, App_Web_authorprofiles.ascx.d988a5ac" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<%@ Register TagPrefix="dnn" TagName="TextEditor" Src="~/controls/TextEditor.ascx" %>
<script type="text/javascript">
	function ConfirmDelete() {
		return confirm('<%=Localization.GetString("Areyousure.Text", this.LocalResourceFile)%>');
	}
</script>
<asp:Panel ID="pnlMainWrap" runat="server">
	<div id="EDNadmin">
		<asp:HiddenField ID="hfUserEdit" runat="server" Value="False" />
		<div class="module_action_title_box">
			<asp:PlaceHolder ID="phAdminNavigation" runat="server"></asp:PlaceHolder>
			<h1>
				<%=strAuthorProfiles%></h1>
		</div>
		<div class="main_content token_editor">
			<div class="tabbed_container">
				<div class="tabs">
					<asp:LinkButton ID="lbAuthorProfiles" runat="server" CssClass="active" OnClick="lbAuthorProfiles_Click" resourcekey="lbAuthorProfilesResource1">Author profiles</asp:LinkButton>
					<asp:LinkButton ID="lbProfileGropus" runat="server" OnClick="lbProfileGropus_Click" resourcekey="lbProfileGropusResource1">Profile groups</asp:LinkButton>
				</div>
				<asp:Panel ID="pnlAuthorProfiles" runat="server">
					<div class="content">
						<asp:Panel ID="pnlProfileEditorHeader" runat="server">
							<div class="main_content gridview_content_manager tag_editor" style="padding: 0;">
								<div class="content_wrapper">
									<asp:GridView ID="gvAuthors" runat="server" EnableModelValidation="True" AutoGenerateColumns="False" CellPadding="0" DataSourceID="odsAuthors" OnPreRender="gvAuthors_PreRender" GridLines="None" CssClass="grid_view_table" ShowFooter="True" DataKeyNames="UserID"
										AllowPaging="True" AllowSorting="True" OnRowCommand="gvAuthors_RowCommand" OnRowDeleted="gvAuthors_RowDeleted" OnPageIndexChanging="gvAuthors_PageIndexChanging">
										<AlternatingRowStyle BorderWidth="0px" CssClass="row second" />
										<Columns>
											<asp:TemplateField ShowHeader="False">
												<FooterTemplate>
													<div class="nomber_of_rows_selection">
														<asp:Label ID="lblFooterSelectNumberOfRows" runat="server" AssociatedControlID="ddlFooterNumberOfRows" resourcekey="lblFooterSelectNumberOfRowsResource1" Text="Number of rows:" />
														<asp:DropDownList ID="ddlFooterNumberOfRows" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlFooterNumberOfRows_SelectedIndexChanged">
															<asp:ListItem resourcekey="ListItemResource1">10</asp:ListItem>
															<asp:ListItem resourcekey="ListItemResource2">20</asp:ListItem>
															<asp:ListItem resourcekey="ListItemResource3">30</asp:ListItem>
															<asp:ListItem resourcekey="ListItemResource4">50</asp:ListItem>
															<asp:ListItem resourcekey="ListItemResource5">100</asp:ListItem>
														</asp:DropDownList>
													</div>
												</FooterTemplate>
												<ItemTemplate>
													<asp:LinkButton ID="lbEditProfile" runat="server" CausesValidation="False" CommandArgument='<%# Eval("UserID") %>' CommandName="EditProfile" CssClass="action_set pair edit" resourcekey="lbEditProfileResource1" ToolTip="Edit"></asp:LinkButton>
													<asp:LinkButton ID="lbDeleteProfile" runat="server" CausesValidation="False" CommandName="Delete" CssClass="action_set pair delete" resourcekey="lbDeleteProfileResource1" OnClientClick="return ConfirmDelete();" ToolTip="Delete"></asp:LinkButton>
												</ItemTemplate>
												<FooterStyle CssClass="footer_actions" />
												<HeaderStyle Width="60px" />
											</asp:TemplateField>
											<asp:TemplateField HeaderText="UserID">
												<EditItemTemplate>
													<asp:TextBox ID="TextBox1" runat="server" resourcekey="TextBox1Resource1" Text='<%# Bind("UserID") %>'></asp:TextBox>
												</EditItemTemplate>
												<ItemTemplate>
													<p>
														<%=strUserID%>
														<strong>
															<%#Eval("UserID") %></strong>
													</p>
													<p>
														<%=strUserName%>
														<strong>
															<%#Eval("Username")%></strong>
													</p>
													<p>
														<%=strFirstName%>
														<strong>
															<%#Eval("FirstName")%></strong>
													</p>
													<p>
														<%=strLastName%>
														<strong>
															<%#Eval("LastName") %></strong>
													</p>
													<p>
														<%=strDisplayName%>
														<strong>
															<%#Eval("DisplayName")%></strong>
													</p>
													<p>
														<%=strArticleCount%>
														<strong>
															<%#Eval("ArticleCount") %></strong>
													</p>
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Short Info">
												<ItemTemplate>
													<asp:Label ID="lblShortInfoDate" runat="server" Style="font-size: 10px; line-height: 13px;" Text='<%# Eval("ShortInfo") %>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Date added">
												<ItemTemplate>
												<%#GetDateAdded(Eval("DateAdded"))%>
												</ItemTemplate>
												<ControlStyle Width="70px" />
												<ItemStyle Width="70px" />
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Image">
												<ItemTemplate>
													<asp:Image ID="imggvProfileImage" runat="server" ImageUrl='<%# GetAuthorImageURL(Eval("ProfileImage"),Eval("UserID")) %>' Visible='<%# IsImageVisible(Eval("ProfileImage")) %>' />
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Group name">
												<ItemTemplate>
													<asp:Label ID="Label1" runat="server" Text='<%# GetAuthorGroups(Eval("AuthorProfileID")) %>' />
												</ItemTemplate>
											</asp:TemplateField>
										</Columns>
										<HeaderStyle CssClass="header_row" />
										<PagerStyle CssClass="pagination" />
										<RowStyle BorderWidth="0px" CssClass="row" />
									</asp:GridView>
								</div>
							</div>
						</asp:Panel>
						<asp:Panel ID="pnlAddToken" CssClass="section_box grey white_border_1" runat="server">
							<h1 class="section_box_title">
								<asp:Label ID="lblAddEditProfile" runat="server" Text="Add new author profile" />
								<asp:HiddenField ID="hfAuthorProfileID" runat="server" />
							</h1>
							<div class="content">
								<div class="padded_wrapper">
									<div class="text_input_set">
										<table>
											<tr runat="server" id="rowSelectUser" visible="true">
												<td>
													<asp:Label ID="lblSelectUSer" runat="server" resourcekey="lblSelectUSer" Text="Select user:" />
												</td>
												<td>
													<asp:DropDownList ID="ddlRoles" runat="server" AppendDataBoundItems="True" AutoPostBack="True" CssClass="ddlgeneral" OnSelectedIndexChanged="ddlRoles_SelectedIndexChanged">
														<asp:ListItem Value="-1" resourcekey="ListItemResource6">Select role</asp:ListItem>
													</asp:DropDownList>
													<asp:DropDownList ID="ddlAuthors" runat="server" AppendDataBoundItems="True" AutoPostBack="True" CssClass="ddlgeneral" OnSelectedIndexChanged="ddlAuthors_SelectedIndexChanged">
														<asp:ListItem Value="0" resourcekey="ListItemResource7">Select author</asp:ListItem>
													</asp:DropDownList>
												</td>
											</tr>
											<tr>
												<td>
													<asp:Label ID="lblFirstNameInfo" runat="server" Text="First name:" resourcekey="lblFirstNameInfoResource1" />
												</td>
												<td>
													<asp:TextBox ID="tbFirstName" runat="server" Enabled="False" Width="250px" CssClass="text" />
												</td>
											</tr>
											<tr>
												<td>
													<asp:Label ID="lblLastNameInfo" runat="server" Text="Last name:" resourcekey="lblLastNameInfoResource1" />
												</td>
												<td>
													<asp:TextBox ID="tbLastName" runat="server" Enabled="False" Width="250px" CssClass="text" />
												</td>
											</tr>
											<tr>
												<td>
													<asp:Label ID="lblDisplayName" runat="server" Text="Display name:" resourcekey="lblDisplayNameResource1" />
												</td>
												<td>
													<asp:TextBox ID="tbDisplayName" runat="server" Enabled="False" Width="250px" CssClass="text" />
												</td>
											</tr>
											<tr>
												<td>
													<asp:Label ID="lblShortInfo" runat="server" Text="Short info:" resourcekey="lblShortInfoResource1" />
												</td>
												<td>
													<asp:TextBox ID="tbShortInfo" runat="server" Height="80px" MaxLength="300" TextMode="MultiLine" Width="350px" />
												</td>
											</tr>
											<tr>
												<td>
													<asp:Label ID="lblFullBio" runat="server" Text="Full info:" resourcekey="lblFullBioResource1"></asp:Label>
												</td>
												<td>
													<asp:TextBox ID="tbFullInfo" runat="server" Height="120px" MaxLength="1200" TextMode="MultiLine" Width="350px" />
												</td>
											</tr>
											<tr>
												<td>
													<asp:Label ID="lblFacebookURL" runat="server" Text="Facebook URL:" resourcekey="lblFacebookURLResource1" />
												</td>
												<td>
													<asp:TextBox ID="tbFacebookURL" runat="server" Width="350px" CssClass="text" />
												</td>
											</tr>
											<tr>
												<td>
													<asp:Label ID="lblTwitterURL" runat="server" Text="Twitter URL:" resourcekey="lblTwitterURLResource1" />
												</td>
												<td>
													<asp:TextBox ID="tbTwitterURL" runat="server" Width="350px" CssClass="text" />
												</td>
											</tr>
											<tr>
												<td>
													<asp:Label ID="lblGooglePlus" runat="server" Text="Google + URL:" resourcekey="lblGooglePlusResource1" />
												</td>
												<td>
													<asp:TextBox ID="tbGooglePlusURL" runat="server" Width="350px" CssClass="text" />
												</td>
											</tr>
											<tr>
												<td>
													<asp:Label ID="lblLinkedInURL" runat="server" Text="LinkedIn URL:" resourcekey="lblLinkedInURLResource1" />
												</td>
												<td>
													<asp:TextBox ID="tbLinkedInURL" runat="server" Width="350px" CssClass="text" />
												</td>
											</tr>
											<tr>
												<td>
													<asp:Label ID="lblProfileGroup" runat="server" Text="Profile group:" resourcekey="lblProfileGroupResource1" />
												</td>
												<td>
													<asp:DropDownList ID="ddlProfileGroups" runat="server" AppendDataBoundItems="True" DataTextField="GroupName" DataValueField="GroupID">
														<asp:ListItem Value="0" resourcekey="ListItemResource8" Text="Select group" />
													</asp:DropDownList>
												</td>
											</tr>
											<tr>
												<td>
													<asp:Label ID="lblProfileImage" runat="server" Text="Image:" resourcekey="lblProfileImageResource1" />
												</td>
												<td>
													<asp:Image ID="imgProfileImage" runat="server" Visible="False" />
													<br />
													<asp:FileUpload ID="fuProfileImage" runat="server" />
												</td>
											</tr>
											<tr id="rowAuthorURL" runat="server">
												<td>
													<asp:Label ID="lblAuthorURL" runat="server" Text="Author URL:" />
												</td>
												<td>
													<asp:RadioButtonList ID="rblAuthorUrlAdd" runat="server" AutoPostBack="True" OnSelectedIndexChanged="rblAuthorUrlAdd_SelectedIndexChanged" RepeatDirection="Horizontal">
														<asp:ListItem resourcekey="liNone" Selected="True" Value="0" Text="None" />
														<asp:ListItem resourcekey="liLink" Value="1" Text="Link" />
													</asp:RadioButtonList>
													<asp:TextBox ID="tbxAuthorURLAdd" runat="server" Width="500px" Visible="false" />
												</td>
											</tr>
											<tr>
												<td>
													&nbsp;
												</td>
												<td>
													<asp:Label ID="lblProfileAdded" runat="server" EnableViewState="false" />
												</td>
											</tr>
											<tr>
												<td>
													&nbsp;
												</td>
												<td>
													<asp:Button ID="btnAddNewProfile" runat="server" OnClick="btnAddNewProfile_Click" Text="Add new profile" resourcekey="btnAddNewProfileResource1" />
													<asp:Button ID="btnUpdateProfile" runat="server" OnClick="btnUpdateProfile_Click" Text="Update profile" Visible="False" resourcekey="btnUpdateProfileResource1" />
													<asp:Button ID="btnCancel" runat="server" OnClick="btnCancel_Click" Text="Cancel" resourcekey="btnCancelResource1" />
												</td>
											</tr>
										</table>
									</div>
								</div>
							</div>
						</asp:Panel>
					</div>
				</asp:Panel>
				<asp:Panel ID="pnlProfileGroups" runat="server" Visible="False">
					<div class="content">
						<div class="main_content gridview_content_manager tag_editor" style="padding: 0;">
							<div class="content_wrapper">
								<asp:GridView ID="gvProfileGropus" runat="server" EnableModelValidation="True" AutoGenerateColumns="False" CellPadding="0" DataSourceID="odsGetGroups" GridLines="None" CssClass="grid_view_table" ShowFooter="True" DataKeyNames="GroupID" AllowPaging="True"
									AllowSorting="True" OnRowCommand="gvProfileGropus_RowCommand" OnRowDeleted="gvProfileGropus_RowDeleted" OnDataBound="gvProfileGropus_DataBound" OnPreRender="gvProfileGropus_PreRender">
									<AlternatingRowStyle BorderWidth="0px" CssClass="row second" />
									<Columns>
										<asp:TemplateField ShowHeader="False">
											<FooterTemplate>
												<div class="nomber_of_rows_selection">
													<asp:Label ID="lblFooterSelectNumberOfRows" runat="server" AssociatedControlID="ddlFooterNumberOfRows" resourcekey="lblFooterSelectNumberOfRowsResource2" Text="Number of rows:"></asp:Label>
													<asp:DropDownList ID="ddlFooterNumberOfRows" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlFooterNumberOfRows_SelectedIndexChangedGroups">
														<asp:ListItem resourcekey="ListItemResource9">10</asp:ListItem>
														<asp:ListItem resourcekey="ListItemResource10">20</asp:ListItem>
														<asp:ListItem resourcekey="ListItemResource11">30</asp:ListItem>
														<asp:ListItem resourcekey="ListItemResource12">50</asp:ListItem>
														<asp:ListItem resourcekey="ListItemResource13">100</asp:ListItem>
													</asp:DropDownList>
												</div>
											</FooterTemplate>
											<ItemTemplate>
												<asp:LinkButton ID="lbEditGroup" runat="server" CausesValidation="False" CommandArgument='<%# Eval("GroupID") %>' CommandName="EditGroup" CssClass="action_set pair edit" resourcekey="lbEditGroupResource1" ToolTip="Edit"></asp:LinkButton>
												<asp:LinkButton ID="lbDeleteGroup" runat="server" CausesValidation="False" CommandName="Delete" CssClass="action_set pair delete" resourcekey="lbDeleteGroupResource1" OnClientClick="return ConfirmDelete();" ToolTip="Delete"></asp:LinkButton>
											</ItemTemplate>
											<FooterStyle CssClass="footer_actions" />
										</asp:TemplateField>
										<asp:BoundField DataField="GroupID" HeaderText="GroupID" />
										<asp:TemplateField HeaderText="Group name">
											<ItemTemplate>
												<asp:Label ID="lblGroupName" runat="server" Text='<%# Eval("GroupName") %>'></asp:Label>
											</ItemTemplate>
										</asp:TemplateField>
										<asp:TemplateField HeaderText="Image">
											<ItemTemplate>
												<asp:Image ID="imggvGroupImage" runat="server" ImageUrl='<%# GetGroupImageURL(Eval("GroupImage"),Eval("GroupID")) %>' Visible='<%# IsImageVisible(Eval("GroupImage")) %>' />
											</ItemTemplate>
										</asp:TemplateField>
										<asp:TemplateField HeaderText="Info">
											<ItemTemplate>
												<asp:Label ID="lblInfo" runat="server" Text='<%# Eval("GroupInfo") %>'></asp:Label>
											</ItemTemplate>
										</asp:TemplateField>
										<asp:TemplateField HeaderText="Position">
											<EditItemTemplate>
												<asp:TextBox ID="TextBox1" runat="server" Text='<%# Bind("Position") %>'></asp:TextBox>
											</EditItemTemplate>
											<ItemTemplate>
												<asp:Label ID="lblPosition" runat="server" Text='<%# Bind("Position") %>'></asp:Label>
												<br />
												<asp:ImageButton ID="imgCategoryUp" runat="server" CausesValidation="False" CommandArgument= '<%# Eval("GroupID")%>' CommandName="Up" ImageUrl="~/images/action_up.gif" resourcekey="imgGroupUp" Text="Up" />
												</div>
												<div>
													<asp:ImageButton ID="imgCategoryDown" runat="server" CausesValidation="False" CommandArgument= '<%# Eval("GroupID")%>' CommandName="Down" ImageUrl="~/images/action_down.gif" resourcekey="imgGroupDown" Text="Down" />
												</div>
											</ItemTemplate>
										</asp:TemplateField>
									</Columns>
									<HeaderStyle CssClass="header_row" />
									<PagerStyle CssClass="pagination" />
									<RowStyle BorderWidth="0px" CssClass="row" />
								</asp:GridView>
							</div>
						</div>
						<asp:Panel ID="pnlAddGroup" CssClass="section_box grey white_border_1" runat="server">
							<asp:HiddenField ID="hfGroupID" runat="server" />
							<h1 class="section_box_title">
								<asp:Label ID="lblGroup" runat="server" Text="Add new group" />
							</h1>
							<div class="content">
								<div class="padded_wrapper">
									<div class="text_input_set">
										<table>
											<tr>
												<td>
													<asp:Label ID="lblGrouopName" runat="server" Text="Group name:" resourcekey="lblGrouopNameResource1" />
												</td>
												<td>
													<asp:TextBox ID="tbGroupName" runat="server" Width="200px" ValidationGroup="vgProfileGroups" CssClass="text" />
													<asp:RequiredFieldValidator ID="rfvGroupName" runat="server" ControlToValidate="tbGroupName" ErrorMessage="Please enter group name" ValidationGroup="vgProfileGroups" resourcekey="rfvGroupNameResource1" />
												</td>
											</tr>
											<tr>
												<td>
													<asp:Label ID="lblGroupInfo" runat="server" Text="Short info:" resourcekey="lblGroupInfoResource1" />
												</td>
												<td>
													<asp:TextBox ID="tbGroupInfo" runat="server" Height="80px" MaxLength="300" TextMode="MultiLine" Width="350px" />
												</td>
											</tr>
											<tr>
												<td>
													<asp:Label ID="lblGroupFacebookURL" runat="server" Text="Facebook URL:" resourcekey="lblGroupFacebookURLResource1" />
												</td>
												<td>
													<asp:TextBox ID="tbGroupFacebookURL" runat="server" Width="350px" CssClass="text" />
												</td>
											</tr>
											<tr>
												<td>
													<asp:Label ID="lblGroupTwitterURL" runat="server" Text="Twitter URL:" resourcekey="lblGroupTwitterURLResource1" />
												</td>
												<td>
													<asp:TextBox ID="tbGroupTwitterURL" runat="server" Width="350px" CssClass="text" />
												</td>
											</tr>
											<tr>
												<td>
													<asp:Label ID="lblGroupGoogleURL" runat="server" Text="Google + URL:" resourcekey="lblGroupGoogleURLResource1" />
												</td>
												<td>
													<asp:TextBox ID="tbGroupGoogleURL" runat="server" Width="350px" CssClass="text" />
												</td>
											</tr>
											<tr>
												<td>
													<asp:Label ID="Label10" runat="server" Text="LinkedIn URL:" resourcekey="Label10Resource1" />
												</td>
												<td>
													<asp:TextBox ID="tbGroupLinkedIn" runat="server" Width="350px" CssClass="text" />
												</td>
											</tr>
											<tr>
												<td>
													<asp:Label ID="Label11" runat="server" Text="Group contact email:" resourcekey="Label11Resource1" />
												</td>
												<td>
													<asp:TextBox ID="tbGroupContactEmail" runat="server" ValidationGroup="vgProfileGroups" Width="350px" CssClass="text" />
													<asp:RegularExpressionValidator ID="rfvGroupContactEmail" runat="server" ControlToValidate="tbGroupContactEmail" ErrorMessage="Please enter valid email" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" ValidationGroup="vgProfileGroups"
														resourcekey="rfvGroupContactEmailResource1" />
												</td>
											</tr>
											<tr>
												<td>
													<asp:Label ID="lblGroupImage" runat="server" Text="Group image:" resourcekey="lblGroupImageResource1" />
												</td>
												<td>
													<asp:Image ID="imgGroupImage" runat="server" Visible="False" />
													<br />
													<asp:FileUpload ID="fuGroupImage" runat="server" />
												</td>
											</tr>
											<tr>
												<td>
													<asp:Label ID="lblGroupURL" runat="server" Text="Group URL:" />
												</td>
												<td>
													<asp:RadioButtonList ID="rblSelectUrlAdd" runat="server" AutoPostBack="True" OnSelectedIndexChanged="rblSelectUrlAdd_SelectedIndexChanged" RepeatDirection="Horizontal">
														<asp:ListItem resourcekey="liNone" Selected="True" Value="0" Text="None" />
														<asp:ListItem resourcekey="liLink" Value="1" Text="Link" />
													</asp:RadioButtonList>
													<asp:TextBox ID="tbCatURLAdd" runat="server" Width="500px" Visible="False" />
												</td>
											</tr>
											<tr>
												<td>
													&nbsp;
												</td>
												<td>
													<asp:Label ID="lblGroupAddMessage" runat="server" EnableViewState="false" />
												</td>
											</tr>
											<tr>
												<td>
													&nbsp;
												</td>
												<td>
													<asp:Button ID="btnAddNewGroup" runat="server" OnClick="btnAddNewGroup_Click" Text="Add new group" ValidationGroup="vgProfileGroups" resourcekey="btnAddNewGroupResource1" />
													<asp:Button ID="btnUpdateGroup" runat="server" OnClick="btnUpdateGroup_Click" Text="Update group" Visible="False" ValidationGroup="vgProfileGroups" resourcekey="btnUpdateGroupResource1" />
													<asp:Button ID="btnGroupCancel" runat="server" OnClick="btnGroupCancel_Click" Text="Cancel" resourcekey="btnGroupCancelResource1" Style="height: 26px" />
												</td>
											</tr>
										</table>
									</div>
								</div>
							</div>
						</asp:Panel>
					</div>
				</asp:Panel>
			</div>
		</div>
	</div>
	<asp:ObjectDataSource ID="odsAuthors" runat="server" SelectMethod="GetAllAuthorProfilesInPortalODS" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.DataAccess" DeleteMethod="DeleteAuthorProfile" EnablePaging="True" SelectCountMethod="SelectTotalNumberAuthorsINportalODs">
		<DeleteParameters>
			<asp:Parameter Name="UserID" Type="Int32" />
		</DeleteParameters>
		<SelectParameters>
			<asp:Parameter Name="PortalID" Type="Int32" />
			<asp:Parameter Name="maximumRows" Type="Int32" />
			<asp:Parameter Name="startRowIndex" Type="Int32" />
		</SelectParameters>
	</asp:ObjectDataSource>
	<asp:ObjectDataSource ID="odsGetGroups" runat="server" SelectMethod="GetAllProfileGroupsInPortal" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.DataAccess" DeleteMethod="DeleteProfileGroup">
		<DeleteParameters>
			<asp:Parameter Name="GroupID" Type="Int32" />
		</DeleteParameters>
		<SelectParameters>
			<asp:Parameter Name="PortalID" Type="Int32" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Panel>
