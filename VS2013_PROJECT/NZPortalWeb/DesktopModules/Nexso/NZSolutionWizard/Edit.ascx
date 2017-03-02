<%@ Control Language="C#" AutoEventWireup="true" CodeFile="Edit.ascx.cs" Inherits="NZSolutionWizard_Edit" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<div class="dnnFormItem">
    <dnn:label id="lblCustomDataTemplate" runat="server" resourcekey="CustomDataTemplate"/>
    <asp:TextBox ID="txtCustomDataTemplate" runat="server" TextMode="MultiLine" Rows="12" />
</div>
<div class="dnnFormItem">
    <dnn:label id="lblScoring" runat="server" resourcekey="Scoring"/>
    <asp:TextBox ID="TxtScoring" runat="server" TextMode="MultiLine" Rows="12" />
</div>
<div class="dnnActions dnnClear">
    <asp:Button runat="server" ID="btnSaveChallenge" OnClick="btnSaveChallenge_Click" resourcekey="btnSave" CssClass="dnnPrimaryAction" />
    <asp:Button runat="server" ID="btnClose" OnClientClick="dnnModal.closePopUp(true)" class="dnnSecondaryAction" resourcekey="btnClose" />
</div>


