<%@ control language="C#" autoeventwireup="true" inherits="EasyDNNSolutions.Modules.EasyDNNNews.CurrencyManager, App_Web_currencymanager.ascx.d988a5ac" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<style type="text/css">
	.centerInfos {
		width: 100%;
		margin-left: auto;
		margin-right: auto;
		text-align: center;
		color: Red;
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
		<h1>Currency manager</h1>
	</div>
	<div class="main_content dashboard customfields">
		<ul class="links">
			<li>
				<asp:HyperLink runat="server" ID="lblCustomFieldsAdd" class="icon customfiledsadd" resourcekey="lblCustomFieldsAdd" Text="Add Custom Fields" /></li>
			<li>
				<asp:HyperLink runat="server" ID="lblCustomFieldsEdit" class="icon customfileds" resourcekey="lblCustomFieldsEdit" Text="Edit Custom Fields" />
			</li>
			<li>
				<asp:HyperLink runat="server" ID="lblCustomFieldsTemplates" class="icon customfields_group" resourcekey="lblCustomFieldsTemplates" Text="Manage Custom Fields Groups" /></li>
			<li class="activelink">
				<asp:HyperLink runat="server" ID="lblCurrencyManager" class="icon customfields_currency" resourcekey="lblCurrencyManager" Text="Currency Setup" /></li>
			<li>
				<asp:HyperLink runat="server" ID="lblImportExport" class="icon customfields_export" resourcekey="lblImportExport" Text="Import/Export" /></li>
		</ul>
	</div>
	<div class="main_content">
		<asp:Panel ID="pnlFieldsList" class="module_settings" runat="server">
			<asp:Panel ID="pnlFieldsListcss" runat="server" Visible="true" CssClass="settings_category_container">
				<div class="category_toggle">
					<p class="section_number">
						1
					</p>
					<h2>
						<%=titleDefaultCurrencyOnPortal%>
					</h2>
				</div>
				<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
					<tr>
						<td class="left">
							<dnn:Label ID="lblMoneyType" runat="server" Text="Base currency:" ControlName="ddlBaseCurrency" HelpText="Base currency is the main currency across the portal. All other currencies are calculated from the base currency, according to the portal's exchange rate." ResourceKey="lblMoneyType" HelpKey="lblMoneyType.HelpText" />
						</td>
						<td class="right">
							<asp:DropDownList ID="ddlBaseCurrency" runat="server" AutoPostBack="false" Enabled="false" EnableViewState="true" />
						</td>
					</tr>
					<tr>
						<td></td>
						<td>
							<asp:Button ID="btnAddCurrencyToPortal" runat="server" Text="Add" Enabled="false" OnClick="btnAddCurrencyToPortal_Click" ResourceKey="btnAddCurrencyToPortal" />
							<asp:LinkButton ID="lblResetCurency" runat="server" ForeColor="#CC0000" OnClientClick="return confirm('Are you sure you want to delete base curreny and ALL Values?');" OnClick="lblResetCurency_Click" Text="Reset base currency and delete Exchange rate list" ResourceKey="lblResetCurency" />
						</td>
					</tr>
				</table>
				<div class="centerInfos">
					<asp:Label ID="lblBaseCurrency" runat="server" Text="" EnableViewState="false" />
				</div>
			</asp:Panel>
		</asp:Panel>
		<asp:Panel ID="pnlAllSettings" class="module_settings" runat="server">
			<asp:Panel ID="pnlMainSelect" runat="server" Visible="true" CssClass="settings_category_container">
				<div class="category_toggle">
					<p class="section_number">
						2
					</p>
					<h2>
						<%=titlePortalExchangeRateList%>
					</h2>
				</div>
				<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
					<tr>
						<td class="left">
							<dnn:Label ID="lblAddCurrencyToList" runat="server" Text="Currency:" ControlName="ddlAddCurrencyToList" HelpText="Select the currency you wish to add to your exchange rate list. The selected currency's value will be calculated according to the portal's Exchange rate." ResourceKey="lblAddCurrencyToList" HelpKey="lblAddCurrencyToList.HelpText" />
						</td>
						<td class="right">
							<asp:DropDownList ID="ddlAddCurrencyToList" runat="server" Width="200px" AutoPostBack="true" Enabled="true" EnableViewState="true" OnSelectedIndexChanged="ddlAddCurrencyToList_SelectedIndexChanged" />
						</td>
					</tr>
					<tr>
						<td class="left">
							<dnn:Label ID="lblExchangeRate" runat="server" Text="Exchange rate:" ControlName="tbxExchangeRate" HelpText="Enter selected currency's exchange rate against the base currency. For example, if USD is your base currency, and EUR is the currency you enter the exchange rate for, the current exchange rate will be approximately 1.36." ResourceKey="lblExchangeRate" HelpKey="lblExchangeRate.HelpText" />
						</td>
						<td class="right">
							<asp:TextBox ID="tbxExchangeRate" runat="server" Width="150px" EnableViewState="true" />
						</td>
					</tr>
					<tr>
						<td class="left">
							<dnn:Label ID="lblUnit" runat="server" Text="Units:" ControlName="tbxUnit" HelpText="Enter the number of units of the currency you are using to calculate the exchange rate of the base currency for." ResourceKey="lblUnit" HelpKey="lblUnit.HelpText" />
						</td>
						<td class="right">
							<asp:TextBox ID="tbxUnit" runat="server" Width="150px" EnableViewState="true" Text="1" />
						</td>
					</tr>
					<tr>
						<td class="left">
							<dnn:Label ID="lblMainDisplayFormat" runat="server" Text="Currency and display format:" ControlName="ddlMainDisplayFormat" HelpText="Select currency and display format." ResourceKey="lblMainDisplayFormat" HelpKey="lblMainDisplayFormat.HelpText" />
						</td>
						<td class="right">
							<asp:DropDownList ID="ddlMainDisplayFormat" runat="server" Width="200px" AutoPostBack="false" Enabled="true" EnableViewState="true" />
						</td>
					</tr>
					<tr>
						<td class="left"></td>
						<td class="right">
							<asp:Button ID="btnAddToExchangeRateList" runat="server" Text="Add to list" OnClick="btnAddToExchangeRateList_Click" ResourceKey="btnAddToExchangeRateList" />
						</td>
					</tr>
				</table>
				<div class="centerInfos">
					<asp:Label ID="lblAddCurrencyToListInfo" runat="server" Text="" EnableViewState="false" />
				</div>
				<asp:ObjectDataSource ID="odsExchangeRateList" runat="server" SelectMethod="GetExchangeRateList" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.DataAccess" UpdateMethod="UpdateExchangeRateListItem" DeleteMethod="RemoveExchangeRateListItem">
					<DeleteParameters>
						<asp:Parameter Name="ACodeBase" Type="String" />
						<asp:Parameter Name="PortalID" Type="Int32" />
						<asp:Parameter Name="ACode" Type="String" />
						<asp:Parameter Name="DisplayFormat" Type="String" />
					</DeleteParameters>
					<SelectParameters>
						<asp:Parameter Name="PortalID" Type="Int32" />
					</SelectParameters>
					<UpdateParameters>
						<asp:Parameter Name="ACodeBase" Type="String" />
						<asp:Parameter Name="PortalID" Type="Int32" />
						<asp:Parameter Name="ACode" Type="String" />
						<asp:Parameter Name="Unit" Type="Int32" />
						<asp:Parameter Name="ExchangeRate" Type="Decimal" />
						<asp:Parameter Name="DisplayFormat" Type="String" />
					</UpdateParameters>
				</asp:ObjectDataSource>
				<asp:GridView ID="gvExchangeRateList" runat="server" DataSourceID="odsExchangeRateList" EnableModelValidation="True" AllowPaging="True" AllowSorting="True" AutoGenerateColumns="False" DataKeyNames="ACodeBase,PortalID,ACode,DisplayFormat" GridLines="None"
					HorizontalAlign="Center" OnRowCommand="gvExchangeRateList_RowCommand" PageSize="15" OnRowDeleted="gvExchangeRateList_RowDeleted" OnRowDataBound="gvExchangeRateList_RowDataBound">
					<Columns>
						<asp:CommandField DeleteText="Remove" ShowDeleteButton="True" ShowEditButton="True">
							<ItemStyle HorizontalAlign="Left" Width="50px" />
						</asp:CommandField>
						<asp:BoundField DataField="ACodeBase" HeaderText="ACodeBase" Visible="False" />
						<asp:BoundField DataField="PortalID" HeaderText="PortalID" Visible="False" />
						<asp:TemplateField HeaderText="ACode">
							<ItemTemplate>
								<asp:Label ID="lblAcode" runat="server" Text='<%# Bind("ACode") %>' />
							</ItemTemplate>
							<EditItemTemplate>
								<asp:Label ID="lblAcode" runat="server" Text='<%# Eval("ACode") %>' />
							</EditItemTemplate>
							<HeaderStyle HorizontalAlign="Center" />
							<ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" Width="50px" />
						</asp:TemplateField>
						<asp:BoundField DataField="Unit" HeaderText="Unit">
							<HeaderStyle HorizontalAlign="Center" />
							<ItemStyle HorizontalAlign="Left" Width="50px" />
						</asp:BoundField>
						<asp:BoundField DataField="ExchangeRate" HeaderText="ExchangeRate">
							<ItemStyle HorizontalAlign="Left" VerticalAlign="Top" Width="150px" />
						</asp:BoundField>
						<asp:BoundField DataField="DateTime" HeaderText="DateTime" ReadOnly="True">
							<HeaderStyle HorizontalAlign="Center" />
							<ItemStyle HorizontalAlign="Left" Width="150px" />
						</asp:BoundField>
						<asp:TemplateField HeaderText="Currency Display Format">
							<ItemTemplate>
								<asp:DropDownList ID="ddlGVMainCurrencySimbol" runat="server" Enabled="false" Width="170px" AppendDataBoundItems="true" />
							</ItemTemplate>
							<EditItemTemplate>
								<asp:DropDownList ID="ddlGVMainCurrencySimbol" runat="server" Enabled="false" Width="170px" AppendDataBoundItems="true" />
							</EditItemTemplate>
							<ItemStyle HorizontalAlign="Left" />
						</asp:TemplateField>
					</Columns>
				</asp:GridView>
			</asp:Panel>
			<asp:Panel ID="pnlAsignLocaleToCurrency" class="settings_category_container" runat="server" Visible="true">
				<div class="category_toggle">
					<p class="section_number">
						3
					</p>
					<h2>
						<%=titleAssignCurrencyExchangeListItems%>
					</h2>
				</div>
				<table class="settings_table customfileds" cellpadding="0" cellspacing="0">
					<tr>
						<td class="left">
							<dnn:Label ID="lblEnabledLocales" runat="server" Text="Available languages:" ControlName="ddlEnabledLocales" HelpText="Select one of the added languages on the portal you wish to ascribe a currency for." ResourceKey="lblEnabledLocales" HelpKey="lblEnabledLocales.HelpText" />
						</td>
						<td class="right">
							<asp:DropDownList ID="ddlEnabledLocales" runat="server" Width="200px" Enabled="true" EnableViewState="true" />
						</td>
					</tr>
					<tr>
						<td class="left">
							<dnn:Label ID="lblCurrencyExchange" runat="server" Text="Currency and display format:" ControlName="ddlCurrencyExchangeList" HelpText="Select currency you wish to ascribe to the selected language. Then select the format of currency display. Click on Assign language to currency." ResourceKey="lblCurrencyExchange" HelpKey="lblCurrencyExchange.HelpText" />
						</td>
						<td class="right">
							<asp:DropDownList ID="ddlCurrencyExchangeList" runat="server" Width="200px" AutoPostBack="True" Enabled="true" EnableViewState="true" OnSelectedIndexChanged="ddlCurrencyExchangeList_SelectedIndexChanged" />
							<asp:DropDownList ID="ddlCurrencySimbol" runat="server" Width="200px" AutoPostBack="false" Enabled="true" EnableViewState="true" />
						</td>
					</tr>
					<tr>
						<td class="left"></td>
						<td class="right">
							<asp:Button ID="btnAsignLocaleTo" runat="server" Text="Asign language to currency" OnClick="btnAsignLocaleTo_Click" ResourceKey="btnAsignLocaleTo" />
						</td>
					</tr>
				</table>
				<div class="centerInfos">
					<asp:Label ID="lblAsignLocaleToCurrencyInfo" runat="server" Text="" EnableViewState="false" />
				</div>
				<asp:ObjectDataSource ID="odsAsignLocaleToCurrency" runat="server" DeleteMethod="RemoveLocaleToCurrencyList" SelectMethod="GetLocaleToCurrencyList" TypeName="EasyDNNSolutions.Modules.EasyDNNNews.DataAccess">
					<DeleteParameters>
						<asp:Parameter Name="ACode" Type="String" />
						<asp:Parameter Name="PortalID" Type="Int32" />
						<asp:Parameter Name="LocaleKey" Type="String" />
					</DeleteParameters>
					<SelectParameters>
						<asp:Parameter Name="PortalID" Type="Int32" />
					</SelectParameters>
				</asp:ObjectDataSource>
				<asp:GridView ID="gvAsignLocaleToCurrency" runat="server" AllowPaging="True" AllowSorting="True" AutoGenerateColumns="False" DataSourceID="odsAsignLocaleToCurrency" EnableModelValidation="True" DataKeyNames="ACode,PortalID,LocaleKey" OnRowDeleted="gvAsignLocaleToCurrency_RowDeleted"
					GridLines="None" HorizontalAlign="Center">
					<Columns>
						<asp:CommandField ShowDeleteButton="True" />
						<asp:BoundField DataField="ACodeBase" HeaderText="Base currency code" />
						<asp:BoundField DataField="Acode" HeaderText="Currency code" />
						<asp:BoundField DataField="PortalID" HeaderText="PortalID" />
						<asp:BoundField DataField="LocaleKey" HeaderText="Locale Key" />
						<asp:BoundField DataField="DisplayFormat" HeaderText="Display Format" />
					</Columns>
				</asp:GridView>
			</asp:Panel>
		</asp:Panel>
	</div>
</div>
