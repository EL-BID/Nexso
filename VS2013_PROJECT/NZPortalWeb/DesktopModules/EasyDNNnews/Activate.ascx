<%@ control language="C#" inherits="EasyDNNSolutions.Modules.EasyDNNNews.Activate, App_Web_activate.ascx.d988a5ac" autoeventwireup="true" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<style type="text/css">
	#EDSadmin
	{
		color: #464646;
		font-family: Arial,Helvetica,sans-serif;
		font-size: 12px;
		margin: 0 auto;
		width: 600px;
	}
	
	#EDSadmin .module_settings
	{
		background: none repeat scroll 0 0 #FAFAFA;
		border-radius: 10px;
	}
	
	#EDSadmin .module_settings .settings_category_container
	{
		border: 0 none;
		margin: 0;
		padding: 0;
	}
	
	
	#EDSadmin .module_settings .settings_category_container .category_toggle
	{
		-moz-border-bottom-colors: none;
		-moz-border-left-colors: none;
		-moz-border-right-colors: none;
		-moz-border-top-colors: none;
		background-color: #E8E8E8;
		border-color: #E2E1E1;
		border-image: none;
		border-style: solid solid none;
		border-width: 1px 1px 0;
		height: 34px;
		margin: 0;
		overflow: hidden;
		padding: 0;
	}
	
	#EDSadmin .module_settings .settings_category_container .category_toggle h2
	{
		float: left;
		font-family: Verdana,sans-serif;
		font-size: 14px;
		font-weight: bold;
		line-height: normal;
		margin: 6px 0 0 7px;
		padding: 0;
		color: #486580;
	}
	
	#EDSadmin .main_content
	{
		-moz-border-bottom-colors: none;
		-moz-border-left-colors: none;
		-moz-border-right-colors: none;
		-moz-border-top-colors: none;
		background: none repeat scroll 0 0 #F4F4F4;
		border-color: #E2E1E1;
		border-image: none;
		border-right: 1px solid #E2E1E1;
		border-style: none solid solid;
		border-width: 0 1px 1px;
		margin: 0;
	}
	
	#EDSadmin .main_content input
	{
		font-size: 12px;
		padding: 2px 4px;
		margin: 2px 0 0;
		background: #f4f4f4;
		color: #464646;
		border: 1px solid #858585;
		border-radius: 3px 3px 3px 3px;
		box-shadow: 0 1px 0 0 rgba(255, 255, 255, 0.8), 0 1px 2px 0 rgba(0, 0, 0, 0.1) inset;
		min-width: 150px;
	}
	
	#EDSadmin .main_content input[type="submit"]
	{
		background-color: #358eea;
		border-color: #0d569e;
		box-shadow: 0 1px 0 0 rgba(0, 0, 0, 0.6), 0 1px 0 0 rgba(255, 255, 255, 0.4) inset;
		color: #efefef;
		text-shadow: 0 -1px 0 #185b93;
		height: 27px;
	}
	
	#EDSadmin .main_content input[type="submit"]:hover
	{
		background: -moz-linear-gradient(center top, #6cb6f3 0%, #4387d2 100%) repeat scroll 0 0 transparent;
		border-color: #0d569e;
		color: white;
	}
	
	#EDSadmin .leftwidth
	{
		width: 150px;
		vertical-align: top;
	}
	
	#EDSadmin .rightwidth
	{
		vertical-align: top;
	}
	
	td > .dnnLabel
	{
		width: 150px;
	}
	
	#EDSadmin .msgareq
	{
		color: #f00;
		font-size: 11px;
	}
	.style1
	{
		height: 41px;
	}
</style>
<div id="EDSadmin">
	<div class="module_settings">
		<div class="settings_category_container">
			<div class="category_toggle">
				<h2>
					EasyDNNnews Activation</h2>
			</div>
			<table border="0" class="main_content grid_view_table" width="100%">
				<tr>
					<td>
						&nbsp;
					</td>
				</tr>
				<tr>
					<td class="style3">
						&nbsp;
					</td>
					<td class="style4">
						<asp:Label ID="lblUpgradeMessage" runat="server" Text="You have upgraded the module with new version. Please activate it again." Visible="False"></asp:Label>
					</td>
				</tr>
				<tr>
					<td class="leftwidth" style="height: 41px">
						<dnn:Label ID="lblInvoiceID" runat="server" Text="Please enter invoice id:" HelpText="Enter you invoice id from purchasing the module."></dnn:Label>
					</td>
					<td class="rightwidth" style="height: 41px">
						<div>
							<asp:TextBox ID="tbInvoiceID" runat="server" Width="300px" MaxLength="100"></asp:TextBox>
						</div>
						<div>
							<asp:Label ID="lblInvoiceRequiredMessage" runat="server" ForeColor="Red" Text="This field is required." Visible="False"></asp:Label>
						</div>
					</td>
				</tr>
				<tr>
					<td>
						&nbsp;
					</td>
					<td>
						<asp:Label ID="lblMessage" runat="server"></asp:Label>
					</td>
				</tr>
				<tr>
					<td class="style1">
						&nbsp;
					</td>
					<td class="style1">
						<div>
							<asp:TextBox ID="tbOriginalInvoiceID" runat="server" Width="300px" MaxLength="100" Visible="False"></asp:TextBox>
						</div>
						<div>
							<asp:Label ID="lblUpgradeInvoiceRequiredMessage" runat="server" ForeColor="Red" Text="This field is required." Visible="False"></asp:Label>
						</div>
					</td>
				</tr>
				<tr>
					<td>
						&nbsp;
					</td>
					<td>
						<asp:Button ID="btnActivate" runat="server" OnClick="btnActivate_Click" Text="Activate" />
					</td>
				</tr>
				<tr>
					<td>
						&nbsp;
					</td>
					<td>
						<asp:HiddenField ID="hfIsUpgrade" runat="server" Value="False" />
					</td>
				</tr>
			</table>
		</div>
	</div>
</div>
