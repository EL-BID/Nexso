<%@ Control Language="C#" AutoEventWireup="true" CodeFile="NZTokenAccess.ascx.cs" Inherits="NZTokenAccess" %>
<link href="<%=ControlPath%>css/Module.css" rel="stylesheet" />


<div class="dnnFormItem">
	<div class="dnnLabel">
		<asp:label id="plPassword" AssociatedControlID="txtPassword" runat="server" text="Token:" CssClass="dnnFormLabel" ViewStateMode="Disabled" />
	</div>
    <asp:textbox Width="40%" id="txtPassword" textmode="Password" runat="server" />
    <asp:Button id="btnLogin"  runat="server" OnClick="btnLogin_Click" text="Login"/>
</div>