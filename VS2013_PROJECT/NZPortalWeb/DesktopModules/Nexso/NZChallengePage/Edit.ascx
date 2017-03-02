<%@ Control Language="C#" AutoEventWireup="true" CodeFile="Edit.ascx.cs" Inherits="DesktopModules_Nexso_NXZSolutionWizard_Edit" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>

<div class="dnnFormItem">
    <dnn:label id="lblHtmlTemplate" runat="server" resourcekey="HtmlTemplate"/>
    <asp:TextBox ID="txtHtmlTemplate" runat="server" TextMode="MultiLine" Rows="12" />
</div>
<div class="dnnActions dnnClear">
    <asp:Button runat="server" ID="btnSaveTemplate" OnClick="btnSaveTemplateTemplate_Click" resourcekey="btnSaveTemplate" CssClass="dnnPrimaryAction" />
    <asp:Button runat="server" ID="btnClose" OnClientClick="dnnModal.closePopUp(true)" class="dnnSecondaryAction" resourcekey="btnClose" />
</div>


