<%@ control language="C#" autoeventwireup="true" inherits="EasyDNNSolutions.Modules.EasyDNNNews.CustomFieldsManager, App_Web_customfields.ascx.d988a5ac" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<%@ Register TagPrefix="dnn" TagName="TextEditor" Src="~/controls/TextEditor.ascx" %>
<style type="text/css">
	.centerInfos {
		width: 100%;
		margin-left: auto;
		margin-right: auto;
		text-align: center;
		color: red;
	}
</style>
<div id="EDNadmin">
	<div class="module_action_title_box">
		<ul class="module_navigation_menu">
			<li>
				<asp:LinkButton ID="lbModuleNavigationAddArticle" runat="server" ToolTip="Add article" OnClick="lbModuleNavigationAddArticle_Click"><img src="<%=ModulePath %>images/icons/paper_and_pencil.png" alt="" /></asp:LinkButton></li>
			<li>
				<asp:LinkButton ID="lbModuleNavigationArticleEditor" runat="server" ToolTip="Article editor" OnClick="lbModuleNavigationArticleEditor_Click"><img src="<%=ModulePath %>images/icons/papers_and_pencil.png" alt="" /></asp:LinkButton></li>
			<li>
				<asp:LinkButton ID="lbModuleNavigationCategoryEditor" runat="server" ToolTip="Category editor" OnClick="lbModuleNavigationCategoryEditor_Click"><img src="<%=ModulePath %>images/icons/categories.png" alt="" /></asp:LinkButton></li>
			<li>
				<asp:LinkButton ID="lbModuleNavigationApproveComments" runat="server" ToolTip="Approve comments" OnClick="lbModuleNavigationApproveComments_Click"><img src="<%=ModulePath %>images/icons/conversation.png" alt="" /></asp:LinkButton></li>
			<li>
				<asp:LinkButton ID="lbModuleNavigationDashboard" runat="server" ToolTip="Dashboard" OnClick="lbModuleNavigationDashboard_Click"><img src="<%=ModulePath %>images/icons/lcd.png" alt="" /></asp:LinkButton></li>
			<li class="power_off">
				<asp:LinkButton ID="lbPowerOff" runat="server" ToolTip="Close" OnClick="lbPowerOff_Click"><img src="<%=ModulePath %>images/icons/power_off.png" alt="" /></asp:LinkButton></li>
		</ul>
		<h1>
			<%=titleOfControle%></h1>
	</div>
	<div class="main_content dashboard customfields">
		<ul class="links">
			<li<%=mainTopNavigationActiveClassAdd %>>
				<asp:HyperLink runat="server" ID="lblCustomFieldsAdd" class="icon customfiledsadd" resourcekey="lblCustomFieldsAdd" Text="Add Custom Fields" /></li>
			<li<%=mainTopNavigationActiveClassEdit %>>
				<asp:HyperLink runat="server" ID="lblCustomFieldsEdit" class="icon customfileds" resourcekey="lblCustomFieldsEdit" Text="Edit Custom Fields" />
			</li>
			<li>
				<asp:HyperLink runat="server" ID="lblCustomFieldsTemplates" class="icon customfields_group" resourcekey="lblCustomFieldsTemplates" Text="Manage Custom Fields Groups" /></li>
			<li>
				<asp:HyperLink runat="server" ID="lblCurrencyManager" class="icon customfields_currency" resourcekey="lblCurrencyManager" Text="Currency Setup" /></li>
			<li>
				<asp:HyperLink runat="server" ID="lblImportExport" class="icon customfields_export" resourcekey="lblImportExport" Text="Import/Export" /></li>
		</ul>
	</div>
	<div class="main_content main_content gridview_content_manager article_manager">
		<div class="module_settings">
			<asp:Panel ID="pnlMainSelect" runat="server" Visible="true" CssClass="settings_category_container">
				<div class="category_toggle">
					<h2>
						<%=titleCreateNEWCF%>
					</h2>
				</div>
				<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
					<tr>
						<td class="left">
							<dnn:Label ID="lblFieldType" runat="server" Text="Field type:" ControlName="ddlFieldType" HelpText="Select the custom field type you wish to add. Possible choices include TextBox, CheckBox and MultiControls." ResourceKey="lblFieldType" HelpKey="lblFieldType.HelpText" />
						</td>
						<td class="right">
							<asp:DropDownList ID="ddlFieldType" runat="server" Width="200px" OnSelectedIndexChanged="ddlFieldType_SelectedIndexChanged" AutoPostBack="True">
								<asp:ListItem Value="0" ResourceKey="liSelect" Text="Select" Selected="True" />
								<asp:ListItem Value="1" ResourceKey="liTextBox" Text="TextBox" />
								<asp:ListItem Value="2" ResourceKey="liCheckBox" Text="CheckBox" />
								<asp:ListItem Value="3" ResourceKey="liMultiControls" Text="Multi Controls" />
								<%--<asp:ListItem Value="100" Text="Search Portal specific data fields"></asp:ListItem>--%>
								<%--<asp:ListItem Value="50" Text="Range search"></asp:ListItem>--%>
							</asp:DropDownList>
						</td>
					</tr>
				</table>
				<asp:Panel ID="pnlTextBoxData" runat="server" Visible="false" CssClass="settings_category_container">
					<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
						<tr class="second">
							<td class="left">
								<dnn:Label ID="lblDataType" runat="server" Text="TextBox data type:" ControlName="ddlTextBoxType" HelpText="Select TextBox data type.


Text – Only used for plain text.
RichText (HTML) –  Used for rich text or HTML.
Integer – Used for integer numbers.
Decimal – Used for decimal numbers.

Money – This type of data is used for entering monetary values (prices). Prior to creating this type of field, it is necessary to set the base currency in Currency setup interface."
									ResourceKey="lblDataType" HelpKey="lblDataType.HelpText" />
							</td>
							<td class="right">
								<asp:DropDownList ID="ddlTextBoxType" runat="server" Width="200px" AutoPostBack="True" OnSelectedIndexChanged="ddlDataType_SelectedIndexChanged">
									<asp:ListItem Value="0" ResourceKey="liSelect" Text="Select" Selected="True" />
									<asp:ListItem Value="1" ResourceKey="liText" Text="Text" />
									<asp:ListItem Value="2" ResourceKey="liRichText" Text="RichText (HTML)" />
									<asp:ListItem Value="3" ResourceKey="liInteger" Text="Integer" />
									<asp:ListItem Value="4" ResourceKey="liDecimal" Text="Decimal" />
									<asp:ListItem Value="5" ResourceKey="liMoney" Text="Money" />
									<%--<asp:ListItem Value="6" Text="Email"></asp:ListItem>
									<asp:ListItem Value="7" Text="Color Picker"></asp:ListItem>
									<asp:ListItem Value="8" Text="Password"></asp:ListItem>
									<asp:ListItem Value="9" Text="Date time picker"></asp:ListItem>--%>
								</asp:DropDownList>
							</td>
						</tr>
					</table>
				</asp:Panel>
				<asp:Label ID="lblInfoWhenControlSelected" runat="server" Visible="false" EnableViewState="false" />
				<asp:Panel ID="pnlMultiControlData" runat="server" Visible="false">
					<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
						<tr class="second">
							<td class="left">
								<dnn:Label ID="lblMultiControlType" runat="server" Text="Multi-control type:" ControlName="ddlMultiControlType" HelpText="Select the desired type of multi-control." ResourceKey="lblMultiControlType" HelpKey="lblMultiControlType.HelpText" />
							</td>
							<td class="right">
								<asp:DropDownList ID="ddlMultiControlType" runat="server" Width="200px" AutoPostBack="True" OnSelectedIndexChanged="ddlMultiControlType_SelectedIndexChanged">
									<asp:ListItem Value="0" ResourceKey="liSelect" Text="Select" Selected="True" />
									<asp:ListItem Value="20" ResourceKey="liDropDownList" Text="DropDownList" />
									<asp:ListItem Value="21" ResourceKey="liRadioButtonList" Text="RadioButtonList" />
									<%--<asp:ListItem Value="22" Text="ListBox"></asp:ListItem>--%>
									<asp:ListItem Value="23" ResourceKey="liCheckBoxList" Text="CheckBoxList" />
								</asp:DropDownList>
							</td>
						</tr>
					</table>
				</asp:Panel>
				<asp:Panel ID="pnlPortalSpecificData" runat="server" Visible="false" CssClass="settings_category_container">
					<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
						<tr class="second">
							<td class="left">
								<dnn:Label ID="lblPortalSpecificData" runat="server" Text="Select portal common data fields:" ControlName="ddlDataType" HelpText="Field type." />
							</td>
							<td class="right">
								<asp:DropDownList ID="ddlPortalSpecificData" runat="server" Width="200px" AutoPostBack="True" OnSelectedIndexChanged="ddlPortalSpecificData_SelectedIndexChanged">
									<asp:ListItem Value="0" Text="Select" Selected="True" />
									<asp:ListItem Value="101" Text="Categories" />
									<asp:ListItem Value="102" Text="Users" />
								</asp:DropDownList>
							</td>
						</tr>
					</table>
				</asp:Panel>
				<br />
			</asp:Panel>
		</div>
		<asp:Panel ID="pnlFieldsList" class="module_settings" runat="server">
			<asp:Panel ID="pnlFieldsListcss" runat="server" Visible="true" CssClass="settings_category_container">
				<div class="category_toggle">
					<h2>
						<%=titleExistingCF%>
					</h2>
					<h2 class="paging">
						<asp:DropDownList ID="ddlgvListOfCustomFieldsPageSize" runat="server" AutoPostBack="True" CssClass="ddlpageitems" OnSelectedIndexChanged="ddlgvListOfCustomFieldsPageSize_SelectedIndexChanged">
							<asp:ListItem Text="10" />
							<asp:ListItem Selected="True" Text="30" />
							<asp:ListItem Text="50" />
							<asp:ListItem Text="80" />
							<asp:ListItem Text="100" />
						</asp:DropDownList>
					</h2>
				</div>
				<asp:ObjectDataSource ID="odsListOfCustomFields" runat="server" DeleteMethod="DeleteCustomField" SelectMethod="GetCustomFields" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.CustomFieldsDB">
					<DeleteParameters>
						<asp:Parameter Name="CustomFieldID" Type="Int32" />
					</DeleteParameters>
					<SelectParameters>
						<asp:Parameter Name="PortalID" Type="Int32" />
						<asp:Parameter Name="IsSearchable" Type="Boolean" />
					</SelectParameters>
				</asp:ObjectDataSource>
				<asp:GridView ID="gvListOfCustomFields" runat="server" AllowPaging="True" AllowSorting="True" DataSourceID="odsListOfCustomFields" EnableModelValidation="True" DataKeyNames="CustomFieldID" OnRowCommand="gvListOfCustomFields_RowCommand" HorizontalAlign="Center"
					AutoGenerateColumns="False" OnRowDeleted="gvListOfCustomFields_RowDeleted" PageSize="30" Width="100%" CssClass="grid_view_table customfields" CellPadding="0" GridLines="None" BorderWidth="0px" OnRowDataBound="gvListOfCustomFields_RowDataBound">
					<AlternatingRowStyle CssClass="row second" />
					<Columns>
						<asp:TemplateField ShowHeader="True" HeaderText="gvListOfCustomFieldsAction">
							<ItemTemplate>
								<asp:LinkButton ID="lbListOfCustomFieldsEdit" runat="server" CausesValidation="false" CommandArgument='<%#Eval("CustomFieldID") %>' CommandName="Select" Text="Edit" ResourceKey="lbListOfCustomFieldsEdit" /><span style="color: #ccc"> | </span>
								<asp:LinkButton ID="lbListOfCustomFieldsDelete" runat="server" CausesValidation="false" CommandName="Delete" OnClientClick="return confirm('Are you sure you want to delete this item and ALL Values?');" Text="Delete" ResourceKey="lbListOfCustomFieldsDelete" />
							</ItemTemplate>
							<HeaderStyle Width="15%" />
						</asp:TemplateField>
						<asp:BoundField DataField="Type" HeaderText="gvListOfCustomFieldsType" />
						<asp:BoundField DataField="Name" HeaderText="gvListOfCustomFieldsName" />
						<asp:BoundField DataField="Token" DataFormatString="[EDNcf:{0}]" HeaderText="gvListOfCustomFieldsToken" />
					</Columns>
					<HeaderStyle HorizontalAlign="Left" />
					<EditRowStyle BackColor="#E2EDF4" />
					<HeaderStyle CssClass="header_row" />
					<PagerStyle CssClass="pagination" />
					<RowStyle CssClass="row" />
				</asp:GridView>
				<div class="centerInfos">
				</div>
				<div class="centerInfos">
					<asp:Label ID="lblCustomFieldsInfo" runat="server" Text="" EnableViewState="false" />
				</div>
			</asp:Panel>
		</asp:Panel>
		<asp:Panel ID="pnlAllSettings" class="module_settings" runat="server">
			<asp:Panel ID="pnlControlOptions" runat="server" Visible="false" CssClass="settings_category_container">
				<div class="category_toggle">
					<p class="section_number">
						1
					</p>
					<h2>
						<%=titleControlBasicSetup%>
					</h2>
				</div>
				<asp:Panel ID="pnlBasicOptions" runat="server" Visible="true" CssClass="settings_category_container">
					<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
						<tr>
							<td class="left">
								<dnn:Label ID="lblCustomFieldName" runat="server" Text="Custom field name:" ControlName="tbxCustomFieldName" HelpText="Enter a name for the custom field you wish to create." ResourceKey="lblCustomFieldName" HelpKey="lblCustomFieldName.HelpText" />
							</td>
							<td class="right">
								<asp:TextBox ID="tbxCustomFieldName" runat="server" Width="200px" CausesValidation="True" MaxLength="300" ValidationGroup="vgSaveField" />
								<asp:RequiredFieldValidator ID="rfvCustomFieldName" runat="server" ErrorMessage="Required field!" ControlToValidate="tbxCustomFieldName" Display="Dynamic" SetFocusOnError="True" ValidationGroup="vgSaveField" resourcekey="rfvCustomFieldName.ErrorMessage" />
							</td>
						</tr>
						<tr class="second">
							<td class="left">
								<dnn:Label ID="lblToken" runat="server" Text="Token ID:" ControlName="tbxToken" HelpText="Enter token ID. Token ID is a unique token identifier. It can be used in HTML templates. If the entered value for a token ID is name, for example, then its token will be [EDNcf:name]. Note: tokens are case sensitive. A token ID must be unique for each custom field, so you can check its availability by clicking on Check availability button, to ensure you're not using the same token for another custom field." ResourceKey="lblToken" HelpKey="lblToken.HelpText" />
							</td>
							<td class="right">
								<asp:TextBox ID="tbxToken" runat="server" Width="200px" CausesValidation="True" MaxLength="250" ValidationGroup="vgSaveField" />
								<asp:RequiredFieldValidator ID="rfvToken" runat="server" ErrorMessage="Required field!" ControlToValidate="tbxToken" Display="Dynamic" SetFocusOnError="True" ValidationGroup="vgSaveField" resourcekey="rfvCustomFieldName.ErrorMessage" />
								<asp:RequiredFieldValidator ID="rfvTokenExists" runat="server" ErrorMessage="Required field!" ControlToValidate="tbxToken" Display="Dynamic" SetFocusOnError="True" ValidationGroup="vgTokenExists" resourcekey="rfvCustomFieldName.ErrorMessage" />
								<asp:Button ID="btnCheckToken" runat="server" Text="Check availability" OnClick="btnCheckToken_Click" ValidationGroup="vgTokenExists" resourcekey="btnCheckToken" />
								<asp:Label ID="lblCheckToken" runat="server" EnableViewState="False" ForeColor="Red" />
							</td>
						</tr>
					</table>
					<asp:Panel ID="pnlTextBoxDefault" runat="server" Visible="false" CssClass="settings_category_container">
						<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
							<tr>
								<td class="left">
									<dnn:Label ID="lblDefaultValue" runat="server" Text="Default token value:" ControlName="tbxDefaultValue" HelpText="Here you can add default value of a particular token. When adding articles, this value will have already been added to the field, though it can be changed." ResourceKey="lblDefaultValue" HelpKey="lblDefaultValue.HelpText" />
								</td>
								<td class="right">
									<asp:TextBox ID="tbxDefaultValue" runat="server" Width="200px" />
								</td>
							</tr>
						</table>
					</asp:Panel>
					<asp:Panel ID="pnlTextBoxMoneyDef" runat="server" Visible="false" CssClass="settings_category_container">
						<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
							<tr>
								<td class="left">
									<dnn:Label ID="lblBasePortalCurrency" runat="server" Text="Base portal currency:" ControlName="lblBasePortalCurrencyValue" HelpText="Portal base currency set in Any news instance dashboard. Selected custom field currency is calculated base on portal curreny." ResourceKey="lblBasePortalCurrency" HelpKey="lblBasePortalCurrency.HelpText" />
								</td>
								<td class="right">
									<asp:Label ID="lblBasePortalCurrencyValue" runat="server" Text="" />
								</td>
							</tr>
							<tr>
								<td class="left">
									<dnn:Label ID="lblMoneyDefSelect" runat="server" Text="Custom field currency:" ControlName="MoneyDefSelect" HelpText="In add/edit this is base insert money type (ISO 4217). Other money exchange rates are based on this selection." ResourceKey="lblMoneyDefSelect" HelpKey="lblMoneyDefSelect.HelpText" />
								</td>
								<td class="right">
									<asp:DropDownList ID="ddlMoneyDefSelect" runat="server" Width="200px" AutoPostBack="true" ValidationGroup="vgSaveField" Enabled="false" OnSelectedIndexChanged="ddlMoneyDefSelect_SelectedIndexChanged" />
									<asp:DropDownList ID="ddlCurrencySimbol" runat="server" Width="200px" AutoPostBack="false" Enabled="true" EnableViewState="true" />
									<asp:RequiredFieldValidator ID="rfvMoneyDefSelect" runat="server" ErrorMessage="Required Field" ControlToValidate="ddlMoneyDefSelect" InitialValue="0" SetFocusOnError="True" ValidationGroup="vgSaveField" Display="Dynamic" resourcekey="rfvCustomFieldName.ErrorMessage" />
								</td>
							</tr>
						</table>
					</asp:Panel>
					<asp:Panel ID="pnlRichTextBoxDefault" runat="server" Visible="false" CssClass="settings_category_container">
						<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
							<tr>
								<td>
									<dnn:Label ID="lblRichTextBoxDefault" runat="server" Text="Default token value:" ControlName="rtbDefault" HelpText="Here you can add default value of a particular token. When adding articles, this value will have already been added to the field, though it can be changed." ResourceKey="lblRichTextBoxDefault" HelpKey="lblRichTextBoxDefault.HelpText" />
									<dnn:TextEditor ID="rtbDefault" runat="server" Height="500" Width="700" />
								</td>
							</tr>
						</table>
					</asp:Panel>
					<asp:Panel ID="pnlCheckBoxDefault" runat="server" Visible="false" CssClass="settings_category_container">
						<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
							<tr class="second">
								<td class="left">
									<dnn:Label ID="lblDefaultCheckBox" runat="server" Text="Default token value:" ControlName="tbxDefaultValue" HelpText="Here you can add default value of a particular token. When adding articles, this value will have already been added to the field, though it can be changed." ResourceKey="lblDefaultCheckBox" HelpKey="lblDefaultCheckBox.HelpText" />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbDefaultValue" runat="server" Checked="false" />
								</td>
							</tr>
						</table>
					</asp:Panel>
					<asp:Panel ID="pnlMultiControlsDefault" runat="server" Visible="false" CssClass="settings_category_container cfmultielements">
						<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
							<tr style="font-weight: bold; text-align: center;">
								<td style="font-size: 16px;">
									<br />
									<asp:Label ID="lblDefMulticontrol" runat="server" Text="Multi elements - ADMINISTRATION" ResourceKey="lblDefMulticontrol" />
								</td>
							</tr>
							<tr style="text-align: center;">
								<td style="font-size: 12px; color: Red;">
									<asp:Label ID="lblInfoMultiPreSave" runat="server" Text="" />
								</td>
							</tr>
							<tr style="text-align: center;">
								<td>&nbsp
								</td>
							</tr>
						</table>
						<asp:Panel ID="pnlIsParentOrChilde" runat="server" Visible="true" CssClass="settings_category_container">
							<table class="settings_table customfileds" cellpadding="0" cellspacing="0" runat="server" id="tblSelectParentChildeControlType">
								<tr>
									<td class="left">
										<dnn:Label ID="lblIsParentOrChilde" runat="server" Text="Element type:" ControlName="rblIsParentOrChilde" HelpText="Select the desired element type. Normal elements are not linked with other custom fields. Related elements are linked to other custom fields, such as their elements. An example: we have created a drop-down list Car maker with elements Audi, BMW, Mercedes. Then we created another drop-down list, Car model. In the latter drop-down list we can create related elements linked with elements from the Car maker drop-down list. Audi's models A4, A5, A6, A7, A8 that we create as related elements will be linked with the corresponding Audi element from the Car model drop-down list." ResourceKey="lblIsParentOrChilde" HelpKey="lblIsParentOrChilde.HelpText" />
									</td>
									<td class="right">
										<asp:RadioButtonList ID="rblIsParentOrChilde" runat="server" RepeatDirection="Horizontal" OnSelectedIndexChanged="rblIsParentOrChilde_SelectedIndexChanged" AutoPostBack="True">
											<asp:ListItem resourcekey="liNormal" Selected="True" Value="0" Text="Normal" />
											<%--<asp:ListItem Value="1" Text="Parent" />--%>
											<asp:ListItem resourcekey="liTriggeredbyparent" Value="2" Text="Related" />
										</asp:RadioButtonList>
									</td>
								</tr>
								<tr>
									<td colspan="2">
										<div style="padding-left: 20px; padding-right: 20px;">
											<asp:Label ID="lblMultiElementsMainInfo" runat="server" EnableViewState="true" ForeColor="Red" />
										</div>
									</td>
								</tr>
							</table>
							<asp:Panel ID="pnlStandardTypeSourceSelect" runat="server" Visible="false" CssClass="settings_category_container">
								<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
									<tr>
										<td class="left">
											<dnn:Label ID="lblStandardTypeSourceSelect" runat="server" Text="Select source type:" ControlName="rblStandardTypeSourceSelect" HelpText="Standard - create elements, Common portal items - select from already created news elements." />
										</td>
										<td class="right">
											<asp:RadioButtonList ID="rblStandardTypeSourceSelect" runat="server" RepeatDirection="Horizontal" OnSelectedIndexChanged="rblStandardTypeSourceSelect_SelectedIndexChanged" AutoPostBack="True">
												<asp:ListItem Selected="True" Value="0" Text="Manual create elements" />
												<asp:ListItem Value="1" Text="Automatically populate with common portal items" />
											</asp:RadioButtonList>
										</td>
									</tr>
								</table>
							</asp:Panel>
							<asp:Panel ID="pnlIsChilde" runat="server" Visible="false" CssClass="settings_category_container">
								<asp:Panel ID="pnlSelectParentID" runat="server" Visible="false">
									<asp:UpdatePanel ID="upCreateChildeElement" runat="server">
										<ContentTemplate>
											<table class="settings_table customfileds" cellpadding="3" cellspacing="0" style="border: 1px solid #999999; box-shadow: 3px 3px 2px -3px #000000; margin-left: 35px; border-radius: 5px; width: 670px;">
												<tr>
													<td class="left">
														<dnn:Label ID="lblParentSelect" runat="server" Text="Relate to field:" ControlName="ddlParentCFSelect" HelpText="Selected custom field will load own elements with witch you can create relationship." ResourceKey="lblParentSelect" HelpKey="lblParentSelect.HelpText" />
													</td>
													<td class="right">
														<asp:DropDownList ID="ddlParentCFSelect" runat="server" OnSelectedIndexChanged="ddlParentCFSelect_SelectedIndexChanged" AutoPostBack="True" />
														<%--<asp:LinkButton ID="lbResetParentCF" runat="server" Visible="False" ToolTip="List elements will lose parent link and won't be deleted." Text="Reset parent group" OnClientClick="return confirm('Are you sure you want to reset parent link values?');" OnClick="lbResetParentCF_Click" />--%>
													</td>
												</tr>
												<tr>
													<td class="left">
														<dnn:Label ID="lblSelectPerentElement" runat="server" Text="Relate to element:" ControlName="ddlSelectPerentElement" HelpText="Selected field element to create relationship with." ResourceKey="lblSelectPerentElement" HelpKey="lblSelectPerentElement.HelpText" />
													</td>
													<td class="right">
														<asp:DropDownList ID="ddlSelectPerentElement" runat="server" />
													</td>
												</tr>
												<tr class="second">
													<td class="left">
														<dnn:Label ID="lblCreateChildElement" runat="server" Text="Element text:" ControlName="tbxElementWithParentText" HelpText="Enter text value." />
													</td>
													<td class="right">
														<asp:TextBox ID="tbxElementWithParentText" runat="server" Width="300px" ValidationGroup="vgElementWithParentText" />
														<asp:Button ID="btnSaveElementWithParent" resourcekey="btnSaveElementWithParent" runat="server" Text="Create element" OnClick="btnSaveElementWithParent_Click" ValidationGroup="vgElementWithParentText" /><br />
														<asp:RequiredFieldValidator ID="rfvSaveElementWithParent" runat="server" ErrorMessage="Required field!" ControlToValidate="tbxElementWithParentText" Display="Dynamic" SetFocusOnError="True" ValidationGroup="vgElementWithParentText" resourcekey="rfvCustomFieldName.ErrorMessage" />
														<asp:Label ID="lblSaveElementWithParentInfo" runat="server" EnableViewState="False" ForeColor="#CC0000" />
													</td>
												</tr>
											</table>
										</ContentTemplate>
									</asp:UpdatePanel>
									<asp:UpdateProgress ID="uppCreateChildeElement" runat="server" AssociatedUpdatePanelID="upCreateChildeElement" DisplayAfter="100" DynamicLayout="true">
										<ProgressTemplate>
											<img src="<%=ModulePath%>images/settings/ajaxLoading.gif" alt="Loading..." />
										</ProgressTemplate>
									</asp:UpdateProgress>
								</asp:Panel>
								<asp:Panel ID="pnlChildeAdministration" runat="server" Visible="false">
									<asp:ObjectDataSource ID="odsChildeParentElements" runat="server" SelectMethod="GetElementsByFilter" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.CustomFieldsDB" UpdateMethod="IUMultiControlElementNEKORISTITI" DeleteMethod="DeleteMultiControlElement">
										<DeleteParameters>
											<asp:Parameter Name="FieldElementID" Type="Int32" />
											<asp:Parameter Name="CustomFieldID" Type="Int32" />
										</DeleteParameters>
										<SelectParameters>
											<asp:Parameter Name="CustomFieldID" Type="Int32" />
											<asp:Parameter Name="ParentCFID" Type="Int32" />
											<asp:Parameter Name="ParentCFELID" Type="Int32" />
										</SelectParameters>
										<UpdateParameters>
											<asp:Parameter Name="CustomFieldID" Type="Int32" />
											<asp:Parameter Name="FieldElementID" Type="Int32" />
											<asp:Parameter Name="FEParentID" Type="Int32" />
											<asp:Parameter Name="Text" Type="String" />
											<asp:Parameter Name="DefSelected" Type="Boolean" />
											<asp:Parameter Name="Position" Type="Int32" />
										</UpdateParameters>
									</asp:ObjectDataSource>
									<asp:UpdatePanel ID="upMultiElements" runat="server">
										<ContentTemplate>
											<table class="settings_table customfileds" cellpadding="0" cellspacing="0" style="width: 705px">
												<tr>

													<td colspan="2" style="text-align: right;">
														<asp:Label ID="lblFilterByParents" runat="server" Text="Filter by:" />
														<span style="margin-right: 5px;">
															<asp:DropDownList ID="ddlFilterByCFParentID" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlFilterByCFParentID_SelectedIndexChanged" /></span><asp:DropDownList ID="ddlFilterByCFELParentID" runat="server" OnSelectedIndexChanged="ddlFilterByCFELParentID_SelectedIndexChanged" AutoPostBack="True" />
													</td>
												</tr>
											</table>
											<asp:GridView ID="gvChildeParentElements" runat="server" DataSourceID="odsChildeParentElements" EnableModelValidation="True" AutoGenerateColumns="False" OnRowDataBound="gvChildeParentElements_RowDataBound" OnRowCommand="gvChildeParentElements_RowCommand" AllowPaging="True" AllowSorting="True" DataKeyNames="FieldElementID,CustomFieldID" GridLines="None" HorizontalAlign="Center" CssClass="grid_view_table customfields" Width="90%" Style="margin: auto"
												PageSize="20" OnRowUpdating="gvChildeParentElements_RowUpdating" OnRowEditing="gvChildeParentElements_RowEditing" OnDataBound="gvChildeParentElements_PreRender">
												<AlternatingRowStyle CssClass="row second" />
												<Columns>
													<asp:TemplateField ShowHeader="True" HeaderText="gvActionHeaderText" HeaderStyle-Width="140px">
														<EditItemTemplate>
															<asp:LinkButton ID="lbUpdate" runat="server" CausesValidation="True" CommandName="Update" Text="Update" /><span style="color: #ccc"> | </span>
															<asp:LinkButton ID="lbCancel" runat="server" CausesValidation="False" CommandName="Cancel" Text="Cancel" /><span style="color: #ccc"> | </span>
														</EditItemTemplate>
														<ItemTemplate>
															<asp:LinkButton ID="lbEdit" runat="server" CausesValidation="False" CommandName="Edit" Text="Edit" /><span style="color: #ccc"> | </span>
															<asp:LinkButton ID="lbDelete" runat="server" CausesValidation="False" CommandName="Delete" Text="Delete" OnClientClick="return confirm('Are you sure you want to delete this item and ALL values?');" /><span style="color: #ccc"> | </span>
															<asp:LinkButton ID="lblgvChildeParentElementsLocalize" runat="server" CausesValidation="False" CommandName="Localize" Text="Localize" ResourceKey="lbgvMultiControlElementsLocalize" />
														</ItemTemplate>
													</asp:TemplateField>
													<asp:BoundField DataField="FieldElementID" HeaderText="gvMultiControlElementsFieldElementID" ReadOnly="True" HeaderStyle-Width="30px" />
													<asp:BoundField DataField="CustomFieldID" HeaderText="gvMultiControlElementsCustomFieldID" ReadOnly="True" HeaderStyle-Width="30px" />
													<asp:TemplateField HeaderText="gvRelatedHeaderText">
														<ItemTemplate>
															<asp:Label ID="lblParentText" runat="server" Text='<%# GetParentName(Eval("ParentText"), Eval("ParentElementCFName"))%>' />
														</ItemTemplate>
														<EditItemTemplate>
															<asp:HiddenField runat="server" Value='<%#Eval("FEParentID") %>' ID="hfFEParentID" />
															<asp:DropDownList ID="ddlParentCustomFieldEdit" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlParentCustomFieldEdit_SelectedIndexChanged" />
															<asp:DropDownList ID="ddlParentElementEdit" runat="server" />
														</EditItemTemplate>
													</asp:TemplateField>
													<asp:TemplateField HeaderText="gvMultiControlElementsText">
														<EditItemTemplate>
															<asp:TextBox ID="tbxText" runat="server" Text='<%# Bind("Text") %>'></asp:TextBox>
														</EditItemTemplate>
														<ItemTemplate>
															<asp:Label ID="lblText" runat="server" Text='<%# Bind("Text") %>'></asp:Label>
														</ItemTemplate>
													</asp:TemplateField>
													<asp:TemplateField ShowHeader="True" HeaderText="gvLocalizeText" Visible="false">
														<ItemTemplate>
															<asp:DropDownList ID="ddlSelectLocale" runat="server" Visible="false" />
															<asp:LinkButton ID="lbLoadLocale" runat="server" CausesValidation="False" CommandName="LoadLocale" CommandArgument='<%#Eval("FieldElementID") %>' Text="Load locale" Visible="false" />
															<asp:TextBox ID="tbxLocalizedText" runat="server" Visible="false" />
															<asp:LinkButton ID="lbSaveLocale" runat="server" CausesValidation="False" CommandName="SaveLocale" CommandArgument='<%#Eval("FieldElementID") %>' Text="Save" Visible="false" />
															<asp:LinkButton ID="lbCloseLocale" runat="server" CausesValidation="False" CommandName="CloseLocale" Text="Close" Visible="false" />
															<asp:LinkButton ID="lbDeleteLocale" runat="server" CausesValidation="False" CommandName="DeleteLocale" CommandArgument='<%#Eval("FieldElementID") %>' Text="Delete" Visible="false" />
														</ItemTemplate>
													</asp:TemplateField>
													<asp:TemplateField HeaderText="gvMultiControlElementsPosition" HeaderStyle-HorizontalAlign="Center" HeaderStyle-Width="60px">
														<ItemTemplate>
															<table style="width: 50px; height: 30px">
																<tr>
																	<td id="Td1" runat="server" visible="false">
																		<asp:TextBox ID="tbxPositionValCategory" runat="server" CssClass="boxposition" Enabled="False" Font-Size="X-Small" Height="14px" ReadOnly="True" Text='<%# Bind("Position")%>' Visible="true" Width="25px" Style="width: 25px; height: 14px;" />
																	</td>
																	<td>
																		<asp:ImageButton ID="imgBtnUPElement" runat="server" CausesValidation="false" CommandArgument='<%#Eval("FieldElementID") %>' CommandName="imgBtnUPElement" ImageUrl="images/icons/arrow_up_green.png" />
																		<asp:ImageButton ID="imgBtnDownElement" runat="server" CausesValidation="false" CommandArgument='<%#Eval("FieldElementID") %>' CommandName="imgBtnDownElement" ImageUrl="images/icons/arrow_down_orange.png" />
																	</td>
																</tr>
															</table>
														</ItemTemplate>
														<HeaderStyle HorizontalAlign="Center" />
														<ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
													</asp:TemplateField>
													<asp:TemplateField HeaderText="DefSelected" Visible="false">
														<ItemTemplate>
															<asp:CheckBox ID="cbSelectedParent" runat="server" Checked='<%# Bind("DefSelected") %>' Enabled="false" ReadOnly="True" />
														</ItemTemplate>
													</asp:TemplateField>
												</Columns>
												<HeaderStyle HorizontalAlign="Left" />
												<EditRowStyle BackColor="#E2EDF4" />
												<HeaderStyle CssClass="header_row" />
												<PagerStyle CssClass="pagination" />
												<RowStyle CssClass="row" />
											</asp:GridView>
										</ContentTemplate>
									</asp:UpdatePanel>
									<asp:UpdateProgress ID="uppMultiElements" runat="server" AssociatedUpdatePanelID="upMultiElements" DisplayAfter="100" DynamicLayout="true">
										<ProgressTemplate>
											<img src="<%=ModulePath%>images/settings/ajaxLoading.gif" alt="Loading..." />
										</ProgressTemplate>
									</asp:UpdateProgress>
								</asp:Panel>
							</asp:Panel>
						</asp:Panel>
						<asp:Panel ID="pnlPortalCommonItems" runat="server" Visible="false" CssClass="settings_category_container">
							<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
								<tr>
									<td class="left">
										<dnn:Label ID="lblpnlPortalCommonItems" runat="server" Text="Select portal common data:" ControlName="rblCalculateFromDB" HelpText="Selected common portal data will show in search module throw created token." />
									</td>
									<td class="right">
										<asp:DropDownList ID="ddlPortalCommonData" runat="server" AutoPostBack="True">
											<asp:ListItem Selected="True" Value="101">Categories</asp:ListItem>
											<asp:ListItem Value="102">Users</asp:ListItem>
										</asp:DropDownList>
									</td>
								</tr>
							</table>
						</asp:Panel>
						<asp:Panel ID="pnlNormalMultiElementsAdministration" runat="server" Visible="false" CssClass="settings_category_container">
							<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
								<tr class="second">
									<td class="left">
										<dnn:Label ID="lblMultiControlElementText" runat="server" Text="Element:" ControlName="tbxMultiControlElementText" HelpText="Enter element drop-down lists and click on the Create element button." ResourceKey="lblMultiControlElementText" HelpKey="lblMultiControlElementText.HelpText" />
									</td>
									<td class="right">
										<asp:TextBox ID="tbxMultiControlElementText" runat="server" Width="350px" />
										<asp:Button ID="btnCreateDropDownElement" runat="server" Text="Create element" ResourceKey="btnCreateDropDownElement" OnClick="btnCreateDropDownElement_Click" /><br />
										<asp:Label ID="lblCreateMultiElementInfo" runat="server" EnableViewState="False" ForeColor="#CC0000" />
									</td>
								</tr>
							</table>
							<asp:Panel ID="pnlDropDownListDefault" runat="server" Visible="false" CssClass="settings_category_container">
								<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
									<tr>
										<td class="left">
											<dnn:Label ID="lblDropDownListDefault" runat="server" Text="Default value:" ControlName="tbxDefaultValue" HelpText="Select the element to be chosen by default." ResourceKey="lblDropDownListDefault" HelpKey="lblDropDownListDefault.HelpText" />
										</td>
										<td class="right">
											<asp:DropDownList ID="ddlDropDownListDefault" runat="server" OnDataBound="ddlDropDownListDefault_DataBound" />
										</td>
									</tr>
								</table>
							</asp:Panel>
							<asp:Panel ID="pnlRadioButtonListDefault" runat="server" Visible="false" CssClass="settings_category_container">
								<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
									<tr>
										<td class="left">
											<dnn:Label ID="lblRadioButtonListDefault" runat="server" Text="Default value:" ControlName="rblRadioButtonListDefault" HelpText="Default value of feild." ResourceKey="lblRadioButtonListDefault" HelpKey="lblRadioButtonListDefault.HelpText" />
										</td>
										<td class="right">
											<asp:RadioButtonList ID="rblRadioButtonListDefault" runat="server" />
										</td>
									</tr>
								</table>
							</asp:Panel>
							<asp:Panel ID="pnlCheckBoxListDefault" runat="server" Visible="false" CssClass="settings_category_container">
								<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
									<tr>
										<td class="left">
											<dnn:Label ID="lblCheckBoxListDefault" runat="server" Text="Default value:" ControlName="cblCheckBoxListDefault" HelpText="Default value of feild." ResourceKey="lblCheckBoxListDefault" HelpKey="lblCheckBoxListDefault.HelpText" />
										</td>
										<td class="right">
											<asp:CheckBoxList ID="cblCheckBoxListDefault" runat="server" />
										</td>
									</tr>
								</table>
							</asp:Panel>
							<asp:Panel ID="pnlMultiControlElements" runat="server" Visible="false" CssClass="settings_category_container">
								<asp:ObjectDataSource ID="odsMultiControlElements" runat="server" SelectMethod="GetMultiControlsElementsLoc" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.CustomFieldsDB" DeleteMethod="DeleteMultiControlElement" UpdateMethod="IUMultiControlElementNEKORISTITI">
									<DeleteParameters>
										<asp:Parameter Name="FieldElementID" Type="Int32" />
										<asp:Parameter Name="CustomFieldID" Type="Int32" />
									</DeleteParameters>
									<SelectParameters>
										<asp:Parameter Name="CustomFieldID" Type="Int32" />
										<asp:Parameter DefaultValue="" ConvertEmptyStringToNull="false" Name="LocaleCode" Type="String" />
									</SelectParameters>
									<UpdateParameters>
										<asp:Parameter Name="CustomFieldID" Type="Int32" />
										<asp:Parameter Name="FieldElementID" Type="Int32" />
										<asp:Parameter Name="FEParentID" Type="Int32" />
										<asp:Parameter Name="Text" Type="String" />
										<asp:Parameter Name="DefSelected" Type="Boolean" />
										<asp:Parameter Name="Position" Type="Int32" />
									</UpdateParameters>
								</asp:ObjectDataSource>
								<asp:GridView ID="gvMultiControlElements" runat="server" AllowPaging="True" DataSourceID="odsMultiControlElements" EnableModelValidation="True" AllowSorting="True" DataKeyNames="FieldElementID,CustomFieldID" AutoGenerateColumns="False" GridLines="None"
									OnRowDataBound="gvMultiControlElements_RowDataBound" OnRowUpdating="gvMultiControlElements_RowUpdating" OnDataBound="gvMultiControlElements_PreRender" OnRowCommand="gvMultiControlElements_RowCommand" HorizontalAlign="Center" CssClass="grid_view_table customfields" Width="90%" Style="margin: auto" OnRowUpdated="gvMultiControlElements_RowUpdated">
									<AlternatingRowStyle CssClass="row second" />
									<Columns>
										<asp:TemplateField ShowHeader="True" HeaderText="gvActionHeaderText" HeaderStyle-Width="140px">
											<ItemTemplate>
												<asp:LinkButton ID="lbgvMultiControlElementsEdit" runat="server" CausesValidation="False" CommandName="Edit" Text="Edit" ResourceKey="lbgvMultiControlElementsEdit" /><span style="color: #ccc"> | </span>
												<asp:LinkButton ID="lbgvMultiControlElementsDelete" runat="server" CausesValidation="False" CommandName="Delete" Text="Delete" ResourceKey="lbgvMultiControlElementsDelete" OnClientClick="return confirm('Are you sure you want to delete this item and ALL values?');" /><span style="color: #ccc"> | </span>
												<asp:LinkButton ID="lbgvMultiControlElementsLocalize" runat="server" CausesValidation="False" CommandName="Localize" Text="Localize" ResourceKey="lbgvMultiControlElementsLocalize" />
											</ItemTemplate>
											<EditItemTemplate>
												<asp:LinkButton ID="lbgvMultiControlElementsUpdate" runat="server" CausesValidation="True" CommandName="Update" Text="Update" ResourceKey="lbgvMultiControlElementsUpdate" /><span style="color: #ccc"> | </span>
												<asp:LinkButton ID="lbgvMultiControlElementsCancel" runat="server" CausesValidation="False" CommandName="Cancel" Text="Cancel" ResourceKey="lbgvMultiControlElementsCancel" />
											</EditItemTemplate>
										</asp:TemplateField>
										<asp:BoundField DataField="FieldElementID" HeaderText="gvMultiControlElementsFieldElementID" ReadOnly="True" HeaderStyle-Width="30px">
											<ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
										</asp:BoundField>
										<asp:BoundField DataField="CustomFieldID" HeaderText="gvMultiControlElementsCustomFieldID" ReadOnly="True" HeaderStyle-Width="30px">
											<ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
										</asp:BoundField>
										<asp:TemplateField HeaderText="gvMultiControlElementsText">
											<EditItemTemplate>
												<asp:TextBox ID="tbxText" runat="server" Text='<%# Bind("Text") %>' />
											</EditItemTemplate>
											<ItemTemplate>
												<asp:Label ID="tbxText" runat="server" Text='<%# Bind("Text") %>' />
											</ItemTemplate>
											<ItemStyle HorizontalAlign="Left" />
										</asp:TemplateField>
										<asp:TemplateField ShowHeader="True" HeaderText="gvLocalizeText" Visible="false">
											<ItemTemplate>
												<asp:DropDownList ID="ddlSelectLocale" runat="server" Visible="false" />
												<asp:LinkButton ID="lbLoadLocale" runat="server" CausesValidation="False" CommandName="LoadLocale" CommandArgument='<%#Eval("FieldElementID") %>' Text="Load locale" Visible="false" />
												<asp:TextBox ID="tbxLocalizedText" runat="server" Visible="false" />
												<asp:LinkButton ID="lbSaveLocale" runat="server" CausesValidation="False" CommandName="SaveLocale" CommandArgument='<%#Eval("FieldElementID") %>' Text="Save" Visible="false" />
												<asp:LinkButton ID="lbCloseLocale" runat="server" CausesValidation="False" CommandName="CloseLocale" Text="Close" Visible="false" />
												<asp:LinkButton ID="lbDeleteLocale" runat="server" CausesValidation="False" CommandName="DeleteLocale" CommandArgument='<%#Eval("FieldElementID") %>' Text="Delete" Visible="false" />
											</ItemTemplate>
										</asp:TemplateField>
										<asp:TemplateField HeaderText="Selected (Default)" Visible="False">
											<ItemTemplate>
												<asp:CheckBox ID="cbSelected" runat="server" Checked='<%# Bind("DefSelected") %>' Enabled="false" />
											</ItemTemplate>
											<ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
										</asp:TemplateField>
										<asp:TemplateField HeaderText="gvMultiControlElementsPosition" HeaderStyle-HorizontalAlign="Center" HeaderStyle-Width="60px">
											<ItemTemplate>
												<table style="width: 50px; height: 30px">
													<tr>
														<td runat="server" visible="false">
															<asp:TextBox ID="tbxPositionValCategory" runat="server" CssClass="boxposition" Enabled="False" Font-Size="X-Small" Height="14px" ReadOnly="True" Text='<%# Bind("Position")%>' Visible="true" Width="25px" Style="width: 25px; height: 14px;" />
														</td>
														<td>
															<asp:ImageButton ID="imgBtnUPElement" runat="server" CausesValidation="false" CommandArgument='<%#Eval("FieldElementID") %>' CommandName="imgBtnUPElement" ImageUrl="images/icons/arrow_up_green.png" />
															<asp:ImageButton ID="imgBtnDownElement" runat="server" CausesValidation="false" CommandArgument='<%#Eval("FieldElementID") %>' CommandName="imgBtnDownElement" ImageUrl="images/icons/arrow_down_orange.png" />
														</td>
													</tr>
												</table>
											</ItemTemplate>
											<HeaderStyle HorizontalAlign="Center" />
											<ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
										</asp:TemplateField>
									</Columns>
									<HeaderStyle HorizontalAlign="Left" />
									<EditRowStyle BackColor="#E2EDF4" />
									<HeaderStyle CssClass="header_row" />
									<PagerStyle CssClass="pagination" />
									<RowStyle CssClass="row" />
								</asp:GridView>
							</asp:Panel>
						</asp:Panel>
					</asp:Panel>
					<div class="category_toggle">
						<p class="section_number">
							2
						</p>
						<h2>
							<%=titleControlLabelOptions%>
						</h2>
					</div>
					<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
						<tr class="second">
							<td class="left">
								<dnn:Label ID="lblLabelVisible" runat="server" Text="Show label:" ControlName="cbLabelVisible" HelpText="If this option is checked, the label will be shown in the article's display." ResourceKey="lblLabelVisible" HelpKey="lblLabelVisible.HelpText" />
							</td>
							<td class="right">
								<asp:CheckBox ID="cbLabelVisible" runat="server" Checked="true" />
							</td>
						</tr>
						<tr>
							<td class="left">
								<dnn:Label ID="lblLabelOfTheFeild" runat="server" Text="Field label:" ControlName="tbxLabelOfTheFeild" HelpText="Enter custom field label." ResourceKey="lblLabelOfTheFeild" HelpKey="lblLabelOfTheFeild.HelpText" />
							</td>
							<td class="right">
								<asp:TextBox ID="tbxLabelOfTheFeild" runat="server" Width="350px" />
							</td>
						</tr>
						<tr class="second">
							<td class="left">
								<dnn:Label ID="lblLabelHelp" runat="server" Text="Field tooltip:" ControlName="tbxLabelHelp" HelpText="Enter custom field tooltip. Tooltip will be displayed when adding articles, and its purpose is to display help text to authors when they fill in custom fields. Tooltips will be displayed when the mouse is positioned above '!' sign." ResourceKey="tbxLabelHelp" HelpKey="tbxLabelHelp.HelpText" />
							</td>
							<td class="right">
								<asp:TextBox ID="tbxLabelHelp" runat="server" Width="350px" />
							</td>
						</tr>
						<tr class="second" runat="server" id="rowLabelLocalization" visible="false">
							<td colspan="2">
								<asp:UpdatePanel ID="uplbLabelLocalization" runat="server" UpdateMode="Conditional">
									<ContentTemplate>
										<div class="centerInfos" style="padding-top: 20px; padding-bottom: 20px;">
											<asp:Button ID="lbLabelLocalization" runat="server" Text="Localize" OnClick="lbLabelLocalization_Click" />
										</div>
									</ContentTemplate>
								</asp:UpdatePanel>
							</td>
						</tr>
						<tr runat="server" visible="false">
							<td class="left">
								<dnn:Label ID="lblLabelIcon" runat="server" Text="Label icon" ControlName="cbLabelIcon" HelpText="Display icon. Position icon in tamplate with tag [cf:ImageLabel]????,style picture with class=\'cfImageLabel\'" />
							</td>
							<td class="right">
								<asp:CheckBox ID="cbLabelIcon" runat="server" Checked="false" />
							</td>
						</tr>
					</table>
					<asp:UpdatePanel ID="upLabelLocalization" runat="server" UpdateMode="Conditional">
						<ContentTemplate>
							<asp:Panel ID="pnlLabelLocalization" runat="server" Visible="false" CssClass="settings_category_container">
								<div class="category_toggle">
									<h2>Label localization
									</h2>
								</div>
								<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
									<tr>
										<td class="left">
											<dnn:Label ID="lblSelectLanguage" runat="server" Text="Select language:" ControlName="ddlSelectLanguage" HelpText="Select language." />
										</td>
										<td class="right">
											<asp:DropDownList ID="ddlLabelSelectLanguage" runat="server" Width="350px" AutoPostBack="true" OnSelectedIndexChanged="ddlLabelSelectLanguage_SelectedIndexChanged" />
										</td>
									</tr>
									<tr>
										<td class="left">
											<dnn:Label ID="lblLabelOfTheFeildLoc" runat="server" Text="Field label:" ControlName="tbxLabelOfTheFeild" HelpText="Field label." ResourceKey="lblLabelOfTheFeild" HelpKey="lblLabelOfTheFeild.HelpText" />
										</td>
										<td class="right">
											<asp:TextBox ID="tbxLabelOfTheFeildLoc" runat="server" Width="350px" />
										</td>
									</tr>
									<tr class="second">
										<td class="left">
											<dnn:Label ID="lblLabelHelpLoc" runat="server" Text="Field help text:" ControlName="tbxLabelHelp" HelpText="Field help text." ResourceKey="tbxLabelHelp" HelpKey="tbxLabelHelp.HelpText" />
										</td>
										<td class="right">
											<asp:TextBox ID="tbxLabelHelpLoc" runat="server" Width="350px" />
										</td>
									</tr>
								</table>
								<div class="centerInfos" style="padding-top: 20px; padding-bottom: 20px;">
									<asp:Label ID="lblLabelLocalizationInfo" runat="server" EnableViewState="False" ForeColor="Red" /><br />
									<asp:Button ID="lbSaveLabelLocalization" runat="server" Text="Save locale" OnClick="lbSaveLabelLocalization_Click" />
									<asp:Button ID="lbCloseLabelLocalization" runat="server" Text="Close" OnClick="lbCloseLabelLocalization_Click" />
									<asp:Button ID="lbDeleteLabelLocalization" runat="server" Text="Delete" OnClick="lbDeleteLabelLocalization_Click" />
									<asp:Button ID="lbCopyLabelLocalization" runat="server" Text="Copy original" OnClick="lbCopyLabelLocalization_Click" />
								</div>
							</asp:Panel>
						</ContentTemplate>
					</asp:UpdatePanel>
					<asp:UpdateProgress ID="uppLabelLocalization" runat="server" AssociatedUpdatePanelID="upLabelLocalization" DisplayAfter="100" DynamicLayout="true">
						<ProgressTemplate>
							<img src="<%=ModulePath%>images/settings/ajaxLoading.gif" alt="Loading..." />
						</ProgressTemplate>
					</asp:UpdateProgress>
				</asp:Panel>
				<div class="category_toggle">
					<p class="section_number">
						3
					</p>
					<h2>
						<%=titleValidation%>
					</h2>
				</div>
				<asp:Panel ID="pnlValidation" runat="server" Visible="true" CssClass="settings_category_container">
					<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
						<tr>
							<td class="left">
								<dnn:Label ID="lblRequired" runat="server" Text="Field is required:" ControlName="cbRequired" HelpText="A field can be either required or optional. If this option is checked, the field becomes required and it needs to be added, or else the article can't be saved." ResourceKey="lblRequired" HelpKey="lblRequired.HelpText" />
							</td>
							<td class="right">
								<asp:CheckBox ID="cbRequired" runat="server" Checked="false" />
							</td>
						</tr>
						<tr class="second" runat="server" visible="false">
							<td class="left">
								<dnn:Label ID="lblValidationMsqDisplay" runat="server" Text="Display?" ControlName="ddlValidationMsqDisplay" HelpText="How the validator is displayed." />
							</td>
							<td class="right">
								<asp:DropDownList ID="ddlValidationMsqDisplay" runat="server">
									<asp:ListItem Selected="True" Value="Dynamic">Dynamic</asp:ListItem>
									<asp:ListItem Value="Static">Static</asp:ListItem>
									<asp:ListItem Value="None">None</asp:ListItem>
								</asp:DropDownList>
							</td>
						</tr>
						<tr>
							<td class="left">
								<dnn:Label ID="lblRequiredErrorMsg" runat="server" Text="Error message:" ControlName="tbxRequiredErrorMsg" HelpText="Enter message text to be displayed in case that a field is required, but hasn't been filled in." ResourceKey="lblRequiredErrorMsg" HelpKey="lblRequiredErrorMsg.HelpText" />
							</td>
							<td class="right">
								<asp:TextBox ID="tbxRequiredErrorMsg" runat="server" Width="350px" />
							</td>
						</tr>
						<tr class="second" runat="server" id="rowValidationLocalization" visible="false">
							<td colspan="2">
								<asp:UpdatePanel ID="uplbValidationLocalization" runat="server" UpdateMode="Conditional">
									<ContentTemplate>
										<div class="centerInfos" style="padding-top: 20px; padding-bottom: 20px;">
											<asp:Button ID="lbValidationLocalization" runat="server" Text="Localize" OnClick="lbValidationLocalization_Click" />
										</div>
									</ContentTemplate>
								</asp:UpdatePanel>
							</td>
						</tr>
						<tr class="second" runat="server" visible="false">
							<td class="left">
								<dnn:Label ID="lblRequiredSetFocusOn" runat="server" Text="Set focus on field?" ControlName="cbRequiredSetFocusOn" HelpText="If error set focus on field." />
							</td>
							<td class="right">
								<asp:CheckBox ID="cbRequiredSetFocusOn" runat="server" Checked="true" />
							</td>
						</tr>
					</table>
					<table class="settings_table customfileds" cellpadding="0" cellspacing="0" runat="server" visible="false">
						<tr>
							<td class="left">
								<dnn:Label ID="lblValidationType" runat="server" Text="Validation type:" ControlName="ddlValidationType" HelpText="Validation type." />
							</td>
							<td class="right">
								<asp:DropDownList ID="ddlValidationType" runat="server" Width="200px">
									<asp:ListItem Value="0" Text="None" Selected="True"></asp:ListItem>
									<asp:ListItem Value="1" Text="Currency"></asp:ListItem>
									<asp:ListItem Value="2" Text="Date"></asp:ListItem>
									<asp:ListItem Value="3" Text="Double"></asp:ListItem>
									<asp:ListItem Value="4" Text="Integer"></asp:ListItem>
									<asp:ListItem Value="5" Text="Email"></asp:ListItem>
									<asp:ListItem Value="6" Text="Regular Expression"></asp:ListItem>
								</asp:DropDownList>
							</td>
						</tr>
						<tr>
							<td class="left">
								<dnn:Label ID="lblRangeValidation" runat="server" Text="Range validation:" HelpText="Range validation." />
							</td>
							<td class="right">
								<asp:TextBox ID="tbxRangeFrom" runat="server" Width="50px" />
								<asp:TextBox ID="tbxRangeTo" runat="server" Width="50px" />
							</td>
						</tr>
						<tr class="second">
							<td class="left">
								<dnn:Label ID="lblRegularExpression" runat="server" Text="Regular Expression:" ControlName="tbxRegularExpression" HelpText="Regular Expression." />
							</td>
							<td class="right">
								<asp:TextBox ID="tbxRegularExpression" runat="server" Width="350px" />
							</td>
						</tr>
					</table>
					<asp:UpdatePanel ID="upValidationLocalization" runat="server" UpdateMode="Conditional">
						<ContentTemplate>
							<asp:Panel ID="pnlValidationLocalization" runat="server" Visible="false" CssClass="settings_category_container">
								<div class="category_toggle">
									<h2>Validation localization
									</h2>
								</div>
								<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
									<tr>
										<td class="left">
											<dnn:Label ID="lblValidationSelectLanguage" runat="server" Text="Select language:" ControlName="ddlSelectLanguage" HelpText="Select language." />
										</td>
										<td class="right">
											<asp:DropDownList ID="ddlValidationSelectLanguage" runat="server" Width="350px" AutoPostBack="true" OnSelectedIndexChanged="ddlValidationSelectLanguage_SelectedIndexChanged" />
										</td>
									</tr>
									<tr>
										<td class="left">
											<dnn:Label ID="lblRequiredErrorMsgLoc" runat="server" Text="Error message:" ControlName="tbxRequiredErrorMsg" HelpText="Error massage when error ocures." ResourceKey="lblRequiredErrorMsg" HelpKey="lblRequiredErrorMsg.HelpText" />
										</td>
										<td class="right">
											<asp:TextBox ID="tbxRequiredErrorMsgLoc" runat="server" Width="350px" />
										</td>
									</tr>
								</table>
								<div class="centerInfos" style="padding-top: 20px; padding-bottom: 20px;">
									<asp:Label ID="lblValidationLocalizationInfo" runat="server" EnableViewState="False" ForeColor="Red" /><br />
									<asp:Button ID="lbSaveValidationLocalization" runat="server" Text="Save locale" OnClick="lbSaveValidationLocalization_Click" />
									<asp:Button ID="lbCloseValidationLocalization" runat="server" Text="Close" OnClick="lbCloseValidationLocalization_Click" />
									<asp:Button ID="lbDeleteValidationLocalization" runat="server" Text="Delete" OnClick="lbDeleteValidationLocalization_Click" />
									<asp:Button ID="lbCopyValidationLocalization" runat="server" Text="Copy original" OnClick="lbCopyValidationLocalization_Click" />
								</div>
							</asp:Panel>
						</ContentTemplate>
					</asp:UpdatePanel>
					<asp:UpdateProgress ID="UpdateProgress1" runat="server" AssociatedUpdatePanelID="upLabelLocalization" DisplayAfter="100" DynamicLayout="true">
						<ProgressTemplate>
							<img src="<%=ModulePath%>images/settings/ajaxLoading.gif" alt="Loading..." />
						</ProgressTemplate>
					</asp:UpdateProgress>
				</asp:Panel>
				<div class="category_toggle">
					<p class="section_number">
						4
					</p>
					<h2>
						<%=titleOtherOptions%>
					</h2>
				</div>
				<asp:Panel ID="pnlOtherSettings" runat="server" Visible="true" CssClass="settings_category_container">
					<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
						<tr>
							<td class="left">
								<dnn:Label ID="lblIsPublished" runat="server" Text="Field is active:" ControlName="cbPublished" HelpText="If a field is active, values can be entered into it. It is not possible to enter values into inactive fields." ResourceKey="lblIsPublished" HelpKey="lblIsPublished.HelpText" />
							</td>
							<td class="right">
								<asp:CheckBox ID="cbIsPublished" runat="server" Checked="true" />
							</td>
						</tr>
						<tr>
							<td class="left">
								<dnn:Label ID="lblIsHidden" runat="server" Text="Field is hidden:" ControlName="cbIsHidden" HelpText="Hidden fields are not displayed in articles, but they can be added by authors. Hidden fields are normally used for information important to authors, but not meant to be publicized." ResourceKey="lblIsHidden" HelpKey="lblIsHidden.HelpText" />
							</td>
							<td class="right">
								<asp:CheckBox ID="cbIsHidden" runat="server" Checked="false" />
							</td>
						</tr>
					</table>
					<asp:Panel ID="pnlCBLOtherOptions" runat="server" Visible="true" CssClass="settings_category_container">
						<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
							<tr>
								<td class="left">
									<dnn:Label ID="lblShowAllMultiElements" runat="server" Text="Show all multi elements:" ControlName="cbShowAllMultiElements" HelpText="In view mode, not checked items are shown. If disabled, only checked items are shown." />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbShowAllMultiElements" runat="server" Checked="true" />
								</td>
							</tr>
						</table>
					</asp:Panel>
				</asp:Panel>

				<asp:Panel ID="pnlSearchable" runat="server" Visible="true">
					<div class="category_toggle">
						<p class="section_number">
							5
						</p>
						<h2><%=searchableOptions%>
						</h2>
					</div>
					<asp:Panel ID="pnlIsSearchable" runat="server" Visible="true" CssClass="settings_category_container">
						<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
							<tr>
								<td class="left">
									<dnn:Label ID="lblIsSearchable" runat="server" Text="Field is searchable:" ControlName="cbIsSearchable" HelpText="If this option is checked, the field is searchable in Advanced search mode of EasyDNNnews search module." />
								</td>
								<td class="right">
									<asp:CheckBox ID="cbIsSearchable" runat="server" Checked="false" OnCheckedChanged="cbIsSearchable_CheckedChanged" AutoPostBack="true" />
								</td>
							</tr>
							<tr runat="server" id="rowSearchLogicalOperator" visible="false">
								<td class="left">
									<dnn:Label ID="Label1" runat="server" Text="Logical operator:" ControlName="rblSearchLogicalOperator" HelpText="Use AND/OR logical operator when searching field." />
								</td>
								<td class="right">
									<asp:RadioButtonList ID="rblSearchLogicalOperator" runat="server" RepeatDirection="Horizontal">
										<asp:ListItem Value="1" Text="AND" Selected="True" />
										<asp:ListItem Value="8" Text="OR" />
									</asp:RadioButtonList>
								</td>
							</tr>
						</table>
					</asp:Panel>
					<asp:Panel ID="pnlIsSearchableExtensions" runat="server" Visible="true" CssClass="settings_category_container">
						<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
							<tr>
								<td class="left">
									<dnn:Label ID="lblSearchExtensionType" runat="server" Text="Search type:" ControlName="cbIsSearchable" HelpText="Select a search type." />
								</td>
								<td class="right">
									<asp:RadioButtonList ID="rblSearchExtensionType" runat="server" OnSelectedIndexChanged="rblSearchExtensionType_SelectedIndexChanged" RepeatDirection="Horizontal" AutoPostBack="true">
										<asp:ListItem Value="0" Text="Normal box" Selected="True" />
										<asp:ListItem Value="1" Text="Range search" />
									</asp:RadioButtonList>
								</td>
							</tr>
						</table>
						<asp:Panel ID="pnlRangeSearch" runat="server" Visible="false" CssClass="settings_category_container">
							<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
								<tr>
									<td class="left">
										<dnn:Label ID="lblCalculateFromDB" runat="server" Text="Range values:" ControlName="rblCalculateFromDB" HelpText="The automatic values are based on the values that are added in this custom field. The manual values can be set by you. " />
									</td>
									<td class="right">
										<asp:RadioButtonList ID="rblCalculateFromDB" runat="server" RepeatDirection="Horizontal" AutoPostBack="True" OnSelectedIndexChanged="rblCalculateFromDB_SelectedIndexChanged">
											<asp:ListItem Selected="True" Value="0">Automatic</asp:ListItem>
											<asp:ListItem Value="1">Manual</asp:ListItem>
										</asp:RadioButtonList>
									</td>
								</tr>
							</table>
							<asp:Panel ID="pnlRangeSearchFromToAutomatic" runat="server" Visible="true" CssClass="settings_category_container">
							</asp:Panel>
							<asp:Panel ID="pnlRangeSearchFromToManual" runat="server" Visible="false" CssClass="settings_category_container">
								<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
									<tr>
										<td class="left">
											<dnn:Label ID="lblFromToValues" runat="server" Text="Min and max value:" HelpText="Add the minimum and maximum value for this range search." />
										</td>
										<td class="right">
											<asp:TextBox ID="tbxFromValue" runat="server" Width="350px" />
											<asp:TextBox ID="tbxToValue" runat="server" Width="350px" />
										</td>
									</tr>
								</table>
							</asp:Panel>
							<div class="centerInfos">
								<asp:Label ID="lblRangeSearchFromToManualInfo" runat="server" EnableViewState="false" />
								<br />
							</div>
						</asp:Panel>
					</asp:Panel>
				</asp:Panel>
				<div class="centerInfos" style="padding-top: 20px; padding-bottom: 20px;">
					<asp:Label ID="lblSaveInfo" runat="server" EnableViewState="False" />
					<asp:Button ID="btnSaveField" runat="server" Text="Create Field" OnClick="btnSaveField_Click" ValidationGroup="vgSaveField" ResourceKey="btnSaveField" />
					<asp:Button ID="btnUpdateField" runat="server" Text="Update Field" ValidationGroup="vgSaveField" Visible="false" OnClick="btnUpdateField_Click" ResourceKey="btnUpdateField" />
					<asp:Button ID="btnCancel" runat="server" Text="Close" Visible="false" OnClick="btnCancel_Click" ResourceKey="btnCancel" />
					<asp:Button ID="btnClose" runat="server" Text="Cancel" OnClick="btnCancel_Click" ResourceKey="btnClose" />
					<!-- bifsi exit gumb -->
				</div>
			</asp:Panel>
		</asp:Panel>
	</div>
</div>
