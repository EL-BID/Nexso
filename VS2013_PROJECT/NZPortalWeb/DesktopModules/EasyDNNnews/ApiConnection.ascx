<%@ control language="C#" autoeventwireup="true" inherits="EasyDNNSolutions.Modules.EasyDNNNews.ApiConnection, App_Web_apiconnection.ascx.d988a5ac" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<style type="text/css">
	.style1
	{
		width: 100%;
	}
	.style2
	{
		width: 130px;
	}
</style>
<script type="text/ecmascript">
	function ShowWarning() {
		return confirm('<%=Localization.GetString("Warning.Text", this.LocalResourceFile)%>');
	}
</script>
<asp:Panel ID="pnlMain" runat="server">
	<div id="EDNadmin">
		<div class="module_action_title_box">
			<asp:PlaceHolder ID="phAdminNavigation" runat="server" />
			<h1>
				<%=APIconnections %></h1>
		</div>
		<div class="main_content token_editor">
			<div class="tabbed_container">
				<h1 class="section_box_title">
					<span><%=TwitterAPIConnection%></span></h1>
				<div class="content" style="margin-bottom: 20px;">
					<div class="padded_wrapper" style="clear: both">
						<div class="text_input_set">
							<table class="style1">
								<tr>
									<td class="style2">
										&nbsp;
									</td>
									<td>
										&nbsp;
									</td>
								</tr>
								<tr>
									<td class="style2" valign="top">
										<asp:Label ID="lblInstructions" resourcekey="lblInstructions" runat="server" Text="Instructions:" Font-Bold="True"></asp:Label>
									</td>
									<td>
										<asp:HyperLink ID="hlVisitDetailInstrictionsTwitter" resourcekey="hlVisitDetailInstrictionsTwitter" runat="server" Font-Bold="True" NavigateUrl="http://www.easydnnsolutions.com/Blog/TabId/248/ArtMID/790/ArticleID/15/default.aspx" Target="_blank">For more detail instructions please visit this link.</asp:HyperLink>
										<asp:Label ID="lblDetailInstructions" resourcekey="lblDetailInstructions" runat="server" Text="&lt;ol&gt;&lt;li&gt;Visit the URL below &lt;/li&gt;&lt;li&gt;Create a Twitter app&lt;/li&gt;&lt;li&gt;Click on the 'Settings' tab and under 'Application type' 'Access:' select 'Read and Write'&lt;/li&gt;&lt;li&gt;Go to 'Details' tab and copy 'Consumer key' and 'Consumer secret' values into fields below.&lt;/li&gt;&lt;/ol&gt;"></asp:Label>
									</td>
								</tr>
								<tr>
									<td class="style2">
										<asp:Label ID="lblGoToURL" resourcekey="lblGoToURL" runat="server" Text="Visit this url:" Font-Bold="True"></asp:Label>
									</td>
									<td>
										<asp:HyperLink ID="hlTwitterDevURL" resourcekey="hlTwitterDevURL" runat="server" NavigateUrl="https://dev.twitter.com/apps/new" Target="_blank" ImageUrl="~/DesktopModules/EasyDNNnews/images/twitter_connect.png">Twitter create new app</asp:HyperLink>
									</td>
								</tr>
								<tr>
									<td class="style2">
										&nbsp;
									</td>
									<td>
										&nbsp;
									</td>
								</tr>
								<tr>
									<td class="style2">
										<asp:Label ID="lblConsumerKey" resourcekey="lblConsumerKey" runat="server" Text="Consumer key:" Font-Bold="True"></asp:Label>
									</td>
									<td>
										<asp:TextBox ID="tbConsumerKey" runat="server" Width="500px" ValidationGroup="addTwitterApp" CssClass="text"></asp:TextBox>
										<asp:RequiredFieldValidator ID="rfvTwitterKey" runat="server" ControlToValidate="tbConsumerKey" ErrorMessage="Please enter consumer key." ValidationGroup="addTwitterApp"></asp:RequiredFieldValidator>
									</td>
								</tr>
								<tr>
									<td class="style2">
										<asp:Label ID="lblConsumerSecret" resourcekey="lblConsumerSecret" runat="server" Text="Consumer secret:" Font-Bold="True"></asp:Label>
									</td>
									<td>
										<asp:TextBox ID="tbConsumerSecret" runat="server" Width="500px" ValidationGroup="addTwitterApp" CssClass="text"></asp:TextBox>
										<asp:RequiredFieldValidator ID="rfvTwitterSecret" runat="server" ControlToValidate="tbConsumerSecret" ErrorMessage="Please enter consumer secret." ValidationGroup="addTwitterApp"></asp:RequiredFieldValidator>
									</td>
								</tr>
								<tr>
									<td class="style2">
										&nbsp;
									</td>
									<td>
										<asp:Label ID="lblSaveMessage" runat="server" ForeColor="Red" EnableViewState="False"></asp:Label>
									</td>
								</tr>
								<tr>
									<td class="style2">
										&nbsp;
									</td>
									<td>
										<asp:Button ID="btnSaveTwitter" resourcekey="btnSaveTwitter" runat="server" Text="Add or update Twitter app keys" OnClick="btnSaveTwitter_Click" ValidationGroup="addTwitterApp" />
										<asp:Button ID="btnDeleteExistingTwiter" resourcekey="btnDeleteExistingTwiter" runat="server" Text="Delete Existing Keys" OnClientClick="return ShowWarning();" OnClick="btnDeleteExistingTwiter_Click" />
									</td>
								</tr>
								<tr>
									<td class="style2">
										&nbsp;
									</td>
									<td>
										&nbsp;
									</td>
								</tr>
							</table>
						</div>
					</div>
				</div>
				<h1 class="section_box_title">
					<span><%=FacebookAPIConnection%></span></h1>
				<div class="content">
					<div class="padded_wrapper" style="clear: both">
						<div class="text_input_set">
							<table class="style1">
								<tr>
									<td class="style2">
										&nbsp;
									</td>
									<td>
										&nbsp;
									</td>
								</tr>
								<tr>
									<td class="style2" valign="top">
										<asp:Label ID="lblFacebookInstructions" resourcekey="lblFacebookInstructions" runat="server" Text="Instructions:" Font-Bold="True"></asp:Label>
									</td>
									<td>
										<asp:HyperLink ID="hlVisitDetailInstrictionsFacebook" resourcekey="hlVisitDetailInstrictionsFacebook" runat="server" Font-Bold="True" NavigateUrl="http://www.easydnnsolutions.com/Blog/TabId/248/ArtMID/790/ArticleID/15/default.aspx" Target="_blank">For more detail instructions please visit this link.</asp:HyperLink>
										<asp:Label ID="lblFaceBookDetailInstructions" resourcekey="lblFaceBookDetailInstructions" runat="server" Text="&lt;ol&gt; &lt;li&gt;Visit the URL below and create Facebook application&lt;/li&gt; &lt;li&gt;If on localhost you must specify Site Domain as &quot;localhost&quot; and Site URL as http://localhost:####/ where #### is port number&lt;/li&gt; &lt;li&gt;To below textboxes, add information from created Facebook application settings tab&lt;/li&gt;&lt;/ol&gt;"></asp:Label>
									</td>
								</tr>
								<tr>
									<td class="style2">
										<asp:Label ID="lblFacebookVisitLink" resourcekey="lblFacebookVisitLink" runat="server" Text="Visit this url:" Font-Bold="True"></asp:Label>
									</td>
									<td>
										<asp:HyperLink ID="hlFacebookCreateApp" resourcekey="hlFacebookCreateApp" runat="server" NavigateUrl="https://developers.facebook.com/apps" Target="_blank" ImageUrl="~/DesktopModules/EasyDNNnews/images/facebook_connect.png">Facebook create new app</asp:HyperLink>
									</td>
								</tr>
								<tr>
									<td class="style2">
										&nbsp;
									</td>
									<td>
										&nbsp;
									</td>
								</tr>
								<tr>
									<td class="style2">
										<asp:Label ID="lblAppFacebookidapiKey" resourcekey="lblAppFacebookidapiKey" runat="server" Text="App ID/API Key:" Font-Bold="True"></asp:Label>
									</td>
									<td>
										<asp:TextBox ID="tbxFacebookApiKey" runat="server" Width="500px" ValidationGroup="addFacebookApp" CssClass="text"></asp:TextBox>
										<asp:RequiredFieldValidator ID="rfvFacebookApiKey" runat="server" ControlToValidate="tbxFacebookApiKey" ErrorMessage="Please enter App ID/API Key." ValidationGroup="addFacebookApp"></asp:RequiredFieldValidator>
									</td>
								</tr>
								<tr>
									<td class="style2">
										<asp:Label ID="lblFacebookAppSecret" resourcekey="lblFacebookAppSecret" runat="server" Text="App secret:" Font-Bold="True"></asp:Label>
									</td>
									<td>
										<asp:TextBox ID="tbxFacebookAppSecret" runat="server" Width="500px" ValidationGroup="addFacebookApp" CssClass="text"></asp:TextBox>
										<asp:RequiredFieldValidator ID="rfvFacebookAppSecret" runat="server" ControlToValidate="tbxFacebookAppSecret" ErrorMessage="Please enter App secret." ValidationGroup="addFacebookApp"></asp:RequiredFieldValidator>
									</td>
								</tr>
								<tr>
									<td class="style2">
										&nbsp;
									</td>
									<td>
										<asp:Label ID="lblSaveInfo" runat="server" ForeColor="#FF3300" EnableViewState="False"></asp:Label>
										<br />
										<asp:Label ID="lblFaceBookError" runat="server" EnableViewState="False"></asp:Label>
									</td>
								</tr>
								<tr>
									<td class="style2">
										&nbsp;
									</td>
									<td>
										<asp:Button ID="btnSaveFacebook" resourcekey="btnSaveFacebook" runat="server" Text="Add or update Facebook app keys" ValidationGroup="addFacebookApp" OnClick="btnSaveFacebook_Click" />
										<asp:Button ID="btnDeleteExistingFacebook" resourcekey="btnDeleteExistingFacebook" runat="server" OnClick="btnDeleteExistingFacebook_Click" OnClientClick="return ShowWarning();" Text="Delete Existing Keys" />
									</td>
								</tr>
								<tr>
									<td class="style2">
										&nbsp;
									</td>
									<td>
										&nbsp;
									</td>
								</tr>
							</table>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</asp:Panel>
