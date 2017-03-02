<%@ Control Language="C#" AutoEventWireup="true" CodeFile="Settings.ascx.cs" Inherits="NZChallenge_Settings" %>
<script runat="server">

   
</script>

<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblChallengeReference" resourcekey="lblChallengeReference" />
    </div>
    <div>
        <asp:TextBox  runat="server" ID="txtChallengeReference" />
    </div>
     <div>
        <asp:TextBox  runat="server" ID="txtSolutionType" />
    </div>
</div>
<div class="dnnFormItem">
    <div class="dnnLabel">
        <asp:Label runat="server" ID="lblPage" resourcekey="lblPage" />
    </div>
    <div>
        <asp:TextBox runat="server" ID="txtPage" />
    </div>
</div>


