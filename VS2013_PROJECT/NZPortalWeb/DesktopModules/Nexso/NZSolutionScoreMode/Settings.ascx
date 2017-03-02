<%@ Control Language="C#" AutoEventWireup="true" CodeFile="Settings.ascx.cs" Inherits="NZSolutionScoreMode_Settings" %>

<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblChallengeReference" resourcekey="lblChallengeReference" />
    </div>
    <div>
        <asp:TextBox  runat="server" ID="txtChallengeReference" />
    </div>
     <div>
        <asp:Label runat="server" ID="lblMessage" resourcekey="lblMessage" />
    </div>
</div>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblChallengeReferences" resourcekey="lblChallengeReferences" />
    </div>
    <div>
        <asp:TextBox runat="server" ID="txtChallengeReferences" />
    </div>
</div>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblChallengeComments" resourcekey="lblChallengeComments" />
    </div>
    <div>
        <asp:TextBox runat="server" ID="txtChallengeComments" />
    </div>
</div>