<%@ Control Language="C#" AutoEventWireup="true" CodeFile="NZChangePassword.ascx.cs" Inherits="NZChangePassword" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<%@ Register TagPrefix="dnn" Assembly="DotNetNuke" Namespace="DotNetNuke.UI.WebControls" %>

<div id="pChangePassword" runat="server">
    <br />
    <div class="dnnForm dnnPasswordReset dnnClear">
        <div class="dnnFormMessage dnnFormInfo" runat="server" visible="False" id="resetMessages">
            <asp:Label ID="lblHelp" runat="Server" />
        </div>
        <div id="divPassword" runat="server" class="dnnPasswordResetContent">
            <div class="dnnFormItem">
                <dnn:Label ID="lblOldPassword" runat="server" ControlName="txtOldPassword" ResourceKey="OldPassword" CssClass="dnnFormRequired" />
                <asp:TextBox ID="txtOldPassword" runat="server" TextMode="Password" />
                <asp:RequiredFieldValidator ID="valOldPassword" CssClass="dnnFormMessage dnnFormError dnnRequired" runat="server" resourcekey="OldPassword.Required" Display="Dynamic" ControlToValidate="txtOldPassword" />
            </div>
            <div class="dnnFormItem">
                <dnn:Label ID="lblPassword" runat="server" ControlName="txtPassword" ResourceKey="Password" CssClass="dnnFormRequired" />
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" />
                <asp:RequiredFieldValidator ID="valPassword" CssClass="dnnFormMessage dnnFormError dnnRequired" runat="server" resourcekey="Password.Required" Display="Dynamic" ControlToValidate="txtPassword" />
                <div class="rfv">
                    <asp:RegularExpressionValidator ID="rgvPassword" ControlToValidate="txtPassword"
                        runat="server" ErrorMessage="" ValidationExpression="^[a-zA-Z0-9\s]{7,20}$"></asp:RegularExpressionValidator>
                </div>
            </div>

            <div class="dnnFormItem">
                <dnn:Label ID="lblConfirmPassword" runat="server" ControlName="txtConfirmPassword" ResourceKey="Confirm" CssClass="dnnFormRequired" />
                <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" />
                <asp:RequiredFieldValidator ID="valConfirmPassword" CssClass="dnnFormMessage dnnFormError dnnRequired" runat="server" resourcekey="Confirm.Required" Display="Dynamic" ControlToValidate="txtConfirmPassword" />
                
            </div>
            <ul class="dnnActions dnnClear">
                <li>
                    <asp:LinkButton ID="cmdChangePassword" CssClass="dnnPrimaryAction" runat="server" resourcekey="cmdChangePassword" /></li>
                <li id="liLogin" runat="server">
                    <asp:HyperLink ID="hlCancel" CssClass="dnnSecondaryAction" runat="server" resourcekey="cmdCancel" /></li>
            </ul>
        </div>
    </div>
</div>
<div id="pMessage" runat="server" visible="false">

    <br />
    <br />
    <div>
        <asp:Label ID="lblMessageSuccessfully" runat="server" resourcekey="MessageSuccessfully"></asp:Label>
    </div>
    <br />
    <asp:Button ID="btnClose" runat="server" OnClick="btnClose_Click" CssClass="dnnSecondaryAction" resourcekey="btnClose" />

</div>
