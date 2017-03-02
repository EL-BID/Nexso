<%@ Control Language="C#" AutoEventWireup="true" CodeFile="NZSubscriptionChallenge.ascx.cs" Inherits="NZSubscriptionChallenge" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<link href="<%=ControlPath%>css/module.css" rel="stylesheet" />
<script src="<%=ControlPath%>js/NZSubscriptionChallenge.js"></script>
<telerik:radajaxmanager id="RadAjaxManager1" runat="server">
    <AjaxSettings>
        <telerik:AjaxSetting AjaxControlID="Panel">
            <UpdatedControls>
                <telerik:AjaxUpdatedControl ControlID="pnlSubscription" LoadingPanelID="RadAjaxLoadingPanel1" />
                <telerik:AjaxUpdatedControl ControlID="pnlMessage" />
            </UpdatedControls>
        </telerik:AjaxSetting>
    </AjaxSettings>
</telerik:radajaxmanager>


<div id="Panel" runat="server">

    <div runat="server" id="pnlSubscription" visible="true">
        <div>
            <div>
                <asp:Label runat="server" ID="lblEmail" resourcekey="Email"></asp:Label>
            </div>
            <div>
                <asp:TextBox runat="server" ID="txtEmail"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ValidationGroup="potentialUser"
                    ControlToValidate="txtEmail" resourcekey="rfvtxtEmail"></asp:RequiredFieldValidator>
                <asp:RegularExpressionValidator ID="rgvEmail" ControlToValidate="txtEmail" ValidationGroup="potentialUser"
                    runat="server" ErrorMessage="" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"></asp:RegularExpressionValidator>
            </div>

        </div>
        <div>
            <div>
                <asp:Label runat="server" ID="lblFirstName" resourcekey="FirstName"></asp:Label>
            </div>
            <div>
                <asp:TextBox runat="server" ID="txtFirstName"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvtxtFirstName" runat="server" ValidationGroup="potentialUser"
                    ControlToValidate="txtFirstName" resourcekey="rfvtxtFirstName"></asp:RequiredFieldValidator>
            </div>
        </div>
        <div>
            <div>
                <asp:Label runat="server" ID="lblLastName" resourcekey="LastName"></asp:Label>
            </div>
            <div>
                <asp:TextBox runat="server" ID="txtLastName"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvtxtLastName" runat="server" ValidationGroup="potentialUser"
                    ControlToValidate="txtLastName" resourcekey="rfvtxtLastName"></asp:RequiredFieldValidator>
            </div>
        </div>
        <div>
            <div>
                <asp:Label runat="server" ID="lblAddress" resourcekey="Address"></asp:Label>
            </div>
            <div>
                <asp:TextBox runat="server" ID="txtAddress"></asp:TextBox>
                <%-- <asp:RequiredFieldValidator ID="rfvtxtAddress" runat="server" ValidationGroup="potentialUser"
                    ControlToValidate="txtAddress" resourcekey="rfvtxtAddress"></asp:RequiredFieldValidator>--%>
            </div>
        </div>
        <div>
            <div>
                <asp:Label runat="server" ID="lblPhone" resourcekey="Phone"></asp:Label>
            </div>
            <div>
                <asp:TextBox runat="server" ID="txtPhone"></asp:TextBox>
                <%--<asp:RequiredFieldValidator ID="rfvtxtPhone" runat="server" ValidationGroup="potentialUser"
                    ControlToValidate="txtPhone" resourcekey="rfvtxtPhone"></asp:RequiredFieldValidator>--%>
            </div>
        </div>
        <div>
            <div>
                <asp:Label runat="server" ID="lblCountry" resourcekey="Country"></asp:Label>
            </div>
            <div>
                <div>
                    <telerik:radcombobox id="ddCountry" runat="server" datatextfield="country" onselectedindexchanged="ddCountry_SelectedIndexChanged"
                        datavaluefield="code" allowcustomtext="true" cssclass="radInput" autopostback="true">
                    </telerik:radcombobox>
                </div>
                <div>
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ValidationGroup="potentialUser"
                        ControlToValidate="ddCountry" resourcekey="rfvddCountry"></asp:RequiredFieldValidator>
                </div>


            </div>
        </div>
        <div>
            <div>
                <asp:Label runat="server" ID="lblRegion" resourcekey="Region"></asp:Label>
            </div>
            <div>
                <div>
                    <telerik:radcombobox id="ddRegion" runat="server" datatextfield="state" onselectedindexchanged="ddRegion_SelectedIndexChanged"
                        datavaluefield="code" allowcustomtext="true" cssclass="radInput" autopostback="true">
                    </telerik:radcombobox>
                </div>
            </div>
        </div>
        <div>
            <div>
                <asp:Label runat="server" ID="lblCities" resourcekey="City"></asp:Label>
            </div>
            <div>
                <div>
                    <telerik:radcombobox id="ddCities" runat="server" datatextfield="city"
                        datavaluefield="code" allowcustomtext="true" cssclass="radInput">
                    </telerik:radcombobox>
                </div>
            </div>
        </div>
        <div>
            <div>
                <asp:Label runat="server" ID="lblTitle" resourcekey="Title"></asp:Label>
            </div>
            <div>
                <asp:TextBox runat="server" ID="txtTitle"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvtxtTitle" runat="server" ValidationGroup="potentialUser"
                    ControlToValidate="txtTitle" resourcekey="rfvtxtTitle"></asp:RequiredFieldValidator>
            </div>
        </div>
        <div>
            <div>
                <asp:Label runat="server" ID="lblOrganizationName" resourcekey="OrganizationName"></asp:Label>
            </div>
            <div>
                <asp:TextBox runat="server" ID="txtOrganizationName"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvtxtOrganizationName" runat="server" ValidationGroup="potentialUser"
                    ControlToValidate="txtOrganizationName" resourcekey="rfvtxtOrganizationName"></asp:RequiredFieldValidator>
            </div>
        </div>

        <div>
            <div>
                <asp:Label runat="server" ID="lblSectorJPO" resourcekey="SectorJPO"></asp:Label>
            </div>
            <div>
                <div>
                    <telerik:radcombobox id="ddSectorJPO" runat="server" autopostback="true" allowcustomtext="true" cssclass="radInput" onselectedindexchanged="ddSectorJPO_SelectedIndexChanged">
                    </telerik:radcombobox>
                </div>
                <div>
                    <asp:RequiredFieldValidator ID="rfvddSectorJPO" runat="server" ValidationGroup="potentialUser"
                        ControlToValidate="ddSectorJPO" resourcekey="rfvddSectorJPO"></asp:RequiredFieldValidator>
                </div>

            </div>
            <div>
                <div>
                    <telerik:radcombobox id="ddSectorItems" runat="server" onselectedindexchanged="ddSectorItems_SelectedIndexChanged" autopostback="true"
                        allowcustomtext="true" cssclass="radInput">
                    </telerik:radcombobox>
                    <div>
                        <asp:RequiredFieldValidator ID="rfvddSectorItems" runat="server" ValidationGroup="potentialUser" Visible="false"
                            ControlToValidate="ddSectorItems" resourcekey="rfvddSectorItems"></asp:RequiredFieldValidator>
                    </div>
                </div>
            </div>
            <div runat="server" visible="false" id="dvOther">
                <div>
                    <asp:Label runat="server" ID="lblOther" resourcekey="Other"></asp:Label>
                </div>
                <div>
                    <asp:TextBox runat="server" ID="txtOther"></asp:TextBox>
                    <div>
                        <asp:RequiredFieldValidator ID="rfvtxtOther" runat="server" ValidationGroup="potentialUser"
                            ControlToValidate="txtOther" resourcekey="rfvtxtOther"></asp:RequiredFieldValidator>
                    </div>
                </div>
            </div>
        </div>

        <div>
            <div>
                <asp:Label runat="server" ID="lblWebSite" resourcekey="WebSite"></asp:Label>
            </div>
            <div>
                <asp:TextBox runat="server" ID="txtWebSite"></asp:TextBox>
            </div>
        </div>
        <div>
            <div>
                <asp:Label runat="server" ID="lblLinkedIn" resourcekey="LinkedIn"></asp:Label>
            </div>
            <div>
                <asp:TextBox runat="server" ID="txtLinkedIn"></asp:TextBox>
            </div>
        </div>
        <div>
            <div>
                <asp:Label runat="server" ID="lblGooglePlus" resourcekey="GooglePlus"></asp:Label>
            </div>
            <div>
                <asp:TextBox runat="server" ID="txtGooglePlus"></asp:TextBox>
            </div>
        </div>
        <div>
            <div>
                <asp:Label runat="server" ID="lblTwitter" resourcekey="Twitter"></asp:Label>
            </div>
            <div>
                <asp:TextBox runat="server" ID="txtTwitter"></asp:TextBox>
            </div>
        </div>
        <div>
            <div>
                <asp:Label runat="server" ID="lblFacebook" resourcekey="Facebook"></asp:Label>
            </div>
            <div>
                <asp:TextBox runat="server" ID="txtFacebook"></asp:TextBox>
            </div>
        </div>
        <div>
            <div>
                <asp:Label runat="server" ID="lblSkype" resourcekey="Skype"></asp:Label>
            </div>
            <div>
                <asp:TextBox runat="server" ID="txtSkype"></asp:TextBox>
            </div>
        </div>
        <div>
            <div>
                <asp:CheckBox runat="server" ID="ckbAuthorization" resourcekey="Authorization" onclick="CheckBox();"></asp:CheckBox>
            </div>
        </div>
        <div>
            <asp:Button runat="server" ID="btnSubmit" resourceKey="btnSubmit" ValidationGroup="potentialUser" OnClick="btnSubmit_Click" OnClientClick="if(!CheckBox())return false;"/>
        </div>
    </div>
    <div runat="server" id="pnlMessage" visible="false">
        <div>
            <asp:Label runat="server" ID="lblConfirmation" resourcekey="MessageConfirmation"></asp:Label>
        </div>
    </div>
</div>

<telerik:radajaxloadingpanel id="RadAjaxLoadingPanel1" runat="server" skin="Default"></telerik:radajaxloadingpanel>

