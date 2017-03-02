<%@ Control Language="C#" AutoEventWireup="true" CodeFile="Settings.ascx.cs" Inherits="NZElegibility_Settings" %>
<%@ Register TagPrefix="dnn" TagName="TextEditor" Src="~/controls/TextEditor.ascx" %>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblRedirectPage" resourcekey="lblRedirectPage" />
    </div>
    <div>
        <asp:TextBox runat="server" ID="txtRedirectPage" />
    </div>
</div>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblButtonText" resourcekey="lblButtonText" />
    </div>
    <div>
        <asp:TextBox runat="server" ID="txtButtonText" />        
    </div>
</div>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblChallengeReference" resourcekey="lblChallengeReference" />
    </div>
    <div>
        <asp:TextBox runat="server" ID="txtChallengeReference" />
    </div>
</div>
<div class="dnnFormItem">
    <dnn:TextEditor ID="RadEditorTemplate" Mode="BASIC" HtmlEncode="False" Enable="true" runat="server" Width="100%" Height="300px">
        <richtext></richtext>
    </dnn:TextEditor>
</div> 