<%@ page language="C#" autoeventwireup="true" inherits="EasyDNNSolutions.Modules.EasyDNNNews.ContactAuthor, App_Web_contactauthor.aspx.d988a5ac" viewStateEncryptionMode="Always" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
	<title>Contact form</title>
	<link rel="stylesheet" type="text/css" href="css/ContactAuthor.css" />
</head>
<body>
	<h1>
		<asp:Label ID="lblContactAuthorTitle" runat="server" Text="Contact Author" /></h1>
	<form id="ContactForm" class="contact_form" runat="server">
	<div class="field">
		<asp:TextBox ID="tbAutContactYourName" runat="server" CssClass="text" Text="" onblur="if(this.value=='') this.value=this.defaultValue;" onfocus="if(this.defaultValue==this.value) this.value = '';" />
		<asp:RequiredFieldValidator ID="rfvPleaseName" runat="server" ControlToValidate="tbAutContactYourName" ErrorMessage="Please enter your name." ValidationGroup="vgContactAuthor" Display="Dynamic" />
		<asp:CompareValidator ID="cvYourName" runat="server" ControlToValidate="tbAutContactYourName" Display="Dynamic" ErrorMessage="Please enter your name." Operator="NotEqual" ValidationGroup="vgContactAuthor" ValueToCompare="TEST"></asp:CompareValidator>
	</div>
	<div class="field">
		<asp:TextBox ID="tbAutContactYourEmail" CssClass="text" Text="" runat="server" onblur="if(this.value=='') this.value=this.defaultValue;" onfocus="if(this.defaultValue==this.value) this.value = '';" />
		<asp:RequiredFieldValidator ID="rfvPleaseEmail" runat="server" ControlToValidate="tbAutContactYourEmail" Display="Dynamic" ErrorMessage="Please enter a valid email address." ValidationGroup="vgContactAuthor" />
		<asp:RegularExpressionValidator ID="revValidEmail" runat="server" ControlToValidate="tbAutContactYourEmail" Display="Dynamic" ErrorMessage="Please enter a valid email address." ValidationGroup="vgContactAuthor" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" />
		<asp:CompareValidator ID="cvYourEmail" runat="server" ControlToValidate="tbAutContactYourEmail" Display="Dynamic" ErrorMessage="Please enter your email." Operator="NotEqual" ValidationGroup="vgContactAuthor" ValueToCompare="TEST"></asp:CompareValidator>
	</div>
	<div class="field">
		<asp:TextBox ID="tbAutContactSubject" runat="server" Text="" CssClass="text" onblur="if(this.value=='') this.value=this.defaultValue;" onfocus="if(this.defaultValue==this.value) this.value = '';" />
		<asp:RequiredFieldValidator ID="rfvPleaseSubject" runat="server" ControlToValidate="tbAutContactSubject" Display="Dynamic" ErrorMessage="Please enter a subject." ValidationGroup="vgContactAuthor" />
		<asp:CompareValidator ID="cvEmailSubject" runat="server" ControlToValidate="tbAutContactSubject" Display="Dynamic" ErrorMessage="Please enter a subject." Operator="NotEqual" ValidationGroup="vgContactAuthor" ValueToCompare="TEST"></asp:CompareValidator>
	</div>
	<div class="field">
		<asp:TextBox ID="tbAutContactMessage" runat="server" CssClass="text" TextMode="MultiLine" onblur="if(this.value=='') this.value=this.defaultValue;" onfocus="if(this.defaultValue==this.value) this.value = '';" ValidationGroup="vgContactAuthor" />
		<asp:RequiredFieldValidator ID="rfvPleaseMessage" runat="server" ControlToValidate="tbAutContactMessage" Display="Dynamic" ErrorMessage="Please enter the message." ValidationGroup="vgContactAuthor" />
	</div>
	<div class="buttons">
		<asp:Button ID="btnSend" runat="server" Text="Send" OnClick="btnSend_Click" ValidationGroup="vgContactAuthor" CssClass="submit" />
	</div>
	</form>
	<asp:Panel ID="pnlMessageSent" runat="server" CssClass="state_message" Visible="False">
		<asp:Label ID="lblMessageSent" runat="server" Text="Message sent." />
	</asp:Panel>
</body>
</html>
