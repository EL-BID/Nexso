<%@ Control Language="C#" AutoEventWireup="true" CodeFile="Settings.ascx.cs" Inherits="NZSolutionWizard_Settings" %>
<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<%@ Register TagPrefix="dnn" TagName="TextEditor" Src="~/controls/TextEditor.ascx" %>
<style>
    .dnnTextEditor {
        margin-left: 10%!important;
    }
</style>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblChallengeReference" resourcekey="lblChallengeReference" />
    </div>
    <div>
        <asp:TextBox runat="server" ID="txtChallengeReference" />
    </div>
</div>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblChallengeTitle" resourcekey="lblChallengeTitle" />
    </div>
    <div>
        <asp:TextBox runat="server" ID="txtChallengeTitle" />
    </div>
</div>

<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblTagUrl" resourcekey="lblTagUrl" />
    </div>
    <div>
        <asp:TextBox runat="server" ID="txtTagUrl" />
    </div>
</div>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblOutUrl" resourcekey="lblOutUrl" />
    </div>
    <div>
        <asp:TextBox runat="server" ID="txtOutUrl" />
    </div>
</div>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblEnterUrl" resourcekey="lblEnterUrl" />
    </div>
    <div>
        <asp:TextBox runat="server" ID="txtEnterUrl" />
    </div>
</div>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblFlavor" resourcekey="lblFlavor" />
    </div>
    <div>
        <asp:DropDownList ID="ddFlavor" runat="server" DataTextField="Label" DataValueField="Key" />
    </div>
</div>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblThemeFilter" resourcekey="lblThemeFilter" />
    </div>
    <div>
        <asp:TextBox runat="server" ID="txtThemeFilter" />
    </div>
</div>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblBeneficiaryFilter" resourcekey="lblBeneficiaryFilter" />
    </div>
    <div>
        <asp:TextBox runat="server" ID="txtBeneficiaryFilter" />
    </div>
</div>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblPublishState" resourcekey="lblPublishState" />
    </div>
    <div>
        <asp:DropDownList ID="ddPublishState" runat="server" DataTextField="Label" DataValueField="Value" />
    </div>
</div>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblAvailableFrom" resourcekey="lblAvailableFrom" />

    </div>
    <div>
        <telerik:raddatepicker id="dtAvailableFrom" width="50%" runat="server">
        </telerik:raddatepicker>
    </div>

</div>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblAvailableTo" resourcekey="lblAvailableTo" />

    </div>
    <div>
        <telerik:raddatepicker id="dtAvailableTo" width="50%" runat="server"></telerik:raddatepicker>
    </div>
</div>

<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblCloseDate" resourcekey="lblCloseDate" />

    </div>
    <div>
        <telerik:raddatepicker id="dtCloseDate" width="50%" runat="server"></telerik:raddatepicker>
    </div>
</div>
<div class="dnnFormItem">
    <div>
        <dnn:TextEditor ID="RadEditor" Mode="BASIC" HtmlEncode="False" Enable="true" runat="server" Width="90%" Height="300px">
            <richtext></richtext>
        </dnn:TextEditor>
    </div>
</div>
