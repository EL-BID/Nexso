<%@ Control Language="C#" AutoEventWireup="true" CodeFile="Settings.ascx.cs" Inherits="NZHTMLGIT_Settings" %>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblAcessToken" resourcekey="lblAcessToken" />
    </div>
    <div>
        <asp:TextBox TextMode="Password" runat="server" ID="txtAccessToken" />
    </div>
</div>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblRepo" resourcekey="lblRepo" />
    </div>
    <div>
        <asp:TextBox runat="server" ID="txtRepo" />
    </div>
</div>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblContent" resourcekey="lblContent" />
    </div>
    <div>
        <asp:TextBox runat="server" ID="txtContent" />
    </div>
</div>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblBranch" resourcekey="lblBranch" />
    </div>
    <div>
        <asp:TextBox runat="server" ID="txtBranch" />
    </div>
</div>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblCache" resourcekey="lblCache" />
    </div>
    <div>
        <asp:CheckBox ID="chkCache" Checked="False" runat="server" />
    </div>
</div>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblLocalization" resourcekey="lblLocalization" />
    </div>
    <div>
        <asp:CheckBox ID="chkLocalization" Checked="True" runat="server" />
    </div>
</div>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblProxy" resourcekey="lblProxy" />
    </div>
    <div>
       <asp:TextBox runat="server" ID="txtProxy" />
    </div>
</div>