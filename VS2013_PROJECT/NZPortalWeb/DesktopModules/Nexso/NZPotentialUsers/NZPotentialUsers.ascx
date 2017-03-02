<%@ Control Language="C#" AutoEventWireup="true" CodeFile="NZPotentialUsers.ascx.cs" Inherits="NZPotentialUsers" %>


<%@ Register Src="../NXOtherControls/CountryStateCityV2.ascx" TagName="CountryStateCity"
    TagPrefix="uc1" %>
<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<link href="<%=ControlPath%>css/module.css" rel="stylesheet" />



<div>
    <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
        <AjaxSettings>
            <telerik:AjaxSetting AjaxControlID="panel1">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="grdPreUsers" LoadingPanelID="RadAjaxLoadingPanel1" />
                </UpdatedControls>
            </telerik:AjaxSetting>
        </AjaxSettings>
    </telerik:RadAjaxManager>

    <asp:Panel runat="server" ID="panel1">
        <div id="dvReport">
            <telerik:RadGrid AutoGenerateColumns="true" runat="server" ID="grdPreUsers" AllowFilteringByColumn="True" OnNeedDataSource="RadGrid1_NeedDataSource"
                AllowPaging="True" AllowAutomaticUpdates="True" AllowAutomaticInserts="True" OnUpdateCommand="RadGrid1_UpdateCommand" Style="width: 100%!important"
                AllowAutomaticDeletes="true" AllowSorting="true" OnItemCreated="RadGrid1_ItemCreatedAndEdit"
                OnItemInserted="RadGrid1_ItemInserted" OnPreRender="RadGrid1_PreRender" OnDeleteCommand="RadGrid1_DeleteCommand" PageSize="60">
                <PagerStyle Mode="NextPrevAndNumeric" />
                <GroupingSettings CaseSensitive="false" />

                <MasterTableView AutoGenerateColumns="False" DataKeyNames="PotentialUserId" CommandItemDisplay="Top">

                    <Columns>
                        <telerik:GridEditCommandColumn ButtonType="ImageButton" UniqueName="EditCommandColumn">
                        </telerik:GridEditCommandColumn>
                        <%--[PotentialUserId]--%>
                        <telerik:GridBoundColumn DataField="PotentialUserId" HeaderText="PotentialUserId"
                            SortExpression="PotentialUserId" Visible="false" AllowFiltering="false"
                            UniqueName="PotentialUserId2">
                        </telerik:GridBoundColumn>

                        <telerik:GridBoundColumn DataField="PotentialUserId" HeaderText="PotentialUserId" SortExpression="PotentialUserId"
                            UniqueName="PotentialUserId" Display="false" MaxLength="5">
                        </telerik:GridBoundColumn>
                        <telerik:GridBoundColumn DataField="Email" HeaderText="Email" SortExpression="Email"
                            UniqueName="Email">
                             <ItemStyle VerticalAlign="Middle" Width="20px" />
                        </telerik:GridBoundColumn>
                        <telerik:GridBoundColumn DataField="FirstName" HeaderText="FirstName" SortExpression="FirstName"
                            UniqueName="FirstName">
                        </telerik:GridBoundColumn>
                        <telerik:GridBoundColumn DataField="LastName" HeaderText="LastName" SortExpression="LastName"
                            UniqueName="LastName">
                        </telerik:GridBoundColumn>

                        <%--[MiddleName]--%>
                        <telerik:GridBoundColumn DataField="MiddleName" HeaderText="MiddleName"
                            SortExpression="MiddleName" Visible="false" AllowFiltering="false"
                            UniqueName="MiddleName">
                        </telerik:GridBoundColumn>

                        <telerik:GridBoundColumn DataField="Phone" HeaderText="Phone" SortExpression="Phone"
                            UniqueName="Phone">
                        </telerik:GridBoundColumn>
                        <telerik:GridBoundColumn DataField="Address" HeaderText="Address" SortExpression="Address"
                            UniqueName="Address">
                        </telerik:GridBoundColumn>
                        <telerik:GridBoundColumn DataField="Country" HeaderText="Country" SortExpression="Country"
                            UniqueName="Country">
                        </telerik:GridBoundColumn>

                        <%--[Region]--%>
                        <telerik:GridBoundColumn DataField="Region" HeaderText="Region"
                            SortExpression="Region" Visible="false" AllowFiltering="false"
                            UniqueName="Region">
                        </telerik:GridBoundColumn>

                        <%--[City]--%>
                        <telerik:GridBoundColumn DataField="City" HeaderText="City"
                            SortExpression="City" Visible="false" AllowFiltering="false"
                            UniqueName="City">
                        </telerik:GridBoundColumn>

                        <%--[Language]--%>
                        <telerik:GridBoundColumn DataField="Language" HeaderText="Language"
                            SortExpression="Language" Visible="false" AllowFiltering="false"
                            UniqueName="Language">
                        </telerik:GridBoundColumn>


                        <telerik:GridBoundColumn DataField="OrganizationName" HeaderText="OrganizationName" SortExpression="OrganizationName"
                            UniqueName="OrganizationName">
                        </telerik:GridBoundColumn>
                        <telerik:GridBoundColumn DataField="OrganizationType" HeaderText="OrganizationType" SortExpression="OrganizationType"
                            UniqueName="OrganizationType">
                        </telerik:GridBoundColumn>

                        <%--[Qualification]--%>
                        <telerik:GridBoundColumn DataField="Qualification" HeaderText="Qualification"
                            SortExpression="Qualification" Visible="false" AllowFiltering="false"
                            UniqueName="Qualification">
                        </telerik:GridBoundColumn>

                        <telerik:GridBoundColumn DataField="Source" HeaderText="Source" SortExpression="Source"
                            UniqueName="Source">
                        </telerik:GridBoundColumn>

                        <%--[Latitude]--%>
                        <telerik:GridBoundColumn DataField="Latitude" HeaderText="Latitude"
                            SortExpression="Latitude" Visible="false" AllowFiltering="false"
                            UniqueName="Latitude">
                        </telerik:GridBoundColumn>

                        <%--[Longitude]--%>
                        <telerik:GridBoundColumn DataField="Longitude" HeaderText="Longitude"
                            SortExpression="Longitude" Visible="false" AllowFiltering="false"
                            UniqueName="Longitude">
                        </telerik:GridBoundColumn>

                        <%--[Batch]--%>
                        <telerik:GridBoundColumn DataField="Batch" HeaderText="Batch"
                            SortExpression="Batch" Visible="false" AllowFiltering="false"
                            UniqueName="Batch">
                        </telerik:GridBoundColumn>

                        <%--[Created]--%>
                        <telerik:GridBoundColumn DataField="Created" HeaderText="Created"
                            SortExpression="Created" Visible="false" AllowFiltering="false"
                            UniqueName="Created">
                        </telerik:GridBoundColumn>

                        <%--[Updated]--%>
                        <telerik:GridBoundColumn DataField="Updated" HeaderText="Updated"
                            SortExpression="Updated" Visible="false" AllowFiltering="false"
                            UniqueName="Updated">
                        </telerik:GridBoundColumn>

                        <%--[Deleted]--%>
                        <telerik:GridBoundColumn DataField="Deleted" HeaderText="Deleted"
                            SortExpression="Deleted" Visible="false" AllowFiltering="false"
                            UniqueName="Deleted">
                        </telerik:GridBoundColumn>

                        <%--[GoogleLocation]--%>
                        <telerik:GridBoundColumn DataField="GoogleLocation" HeaderText="GoogleLocation"
                            SortExpression="GoogleLocation" Visible="false" AllowFiltering="false"
                            UniqueName="GoogleLocation">
                        </telerik:GridBoundColumn>

                        <%--[CustomField1]--%>
                        <telerik:GridBoundColumn DataField="CustomField1" HeaderText="CustomField1"
                            SortExpression="CustomField1" Visible="false" AllowFiltering="false"
                            UniqueName="CustomField1">
                        </telerik:GridBoundColumn>

                        <%--[CustomField2]--%>
                        <telerik:GridBoundColumn DataField="CustomField2" HeaderText="CustomField2"
                            SortExpression="CustomField2" Visible="false" AllowFiltering="false"
                            UniqueName="CustomField2">
                        </telerik:GridBoundColumn>

                        <telerik:GridBoundColumn DataField="Title" HeaderText="Title" SortExpression="Title"
                            UniqueName="Title">
                        </telerik:GridBoundColumn>

                        <%--[ZipCode]--%>
                        <telerik:GridBoundColumn DataField="ZipCode" HeaderText="ZipCode"
                            SortExpression="ZipCode" Visible="false" AllowFiltering="false"
                            UniqueName="ZipCode">
                        </telerik:GridBoundColumn>
                        <%--[WebSite]--%>
                        <telerik:GridBoundColumn DataField="WebSite" HeaderText="WebSite" SortExpression="WebSite"
                            UniqueName="WebSite" Visible="false" AllowFiltering="false">
                        </telerik:GridBoundColumn>
                        <telerik:GridBoundColumn DataField="Sector" HeaderText="Sector" SortExpression="Sector"
                            UniqueName="Sector">
                        </telerik:GridBoundColumn>

                        <%--[LinkedIn]--%>
                        <telerik:GridBoundColumn DataField="LinkedIn" HeaderText="LinkedIn"
                            SortExpression="LinkedIn" Visible="false" AllowFiltering="false"
                            UniqueName="LinkedIn">
                        </telerik:GridBoundColumn>

                        <%--[GooglePlus]--%>
                        <telerik:GridBoundColumn DataField="GooglePlus" HeaderText="GooglePlus"
                            SortExpression="GooglePlus" Visible="false" AllowFiltering="false"
                            UniqueName="GooglePlus">
                        </telerik:GridBoundColumn>

                        <%--[Twitter]--%>
                        <telerik:GridBoundColumn DataField="Twitter" HeaderText="Twitter"
                            SortExpression="Twitter" Visible="false" AllowFiltering="false"
                            UniqueName="Twitter">
                        </telerik:GridBoundColumn>

                        <%--[Facebook]--%>
                        <telerik:GridBoundColumn DataField="Facebook" HeaderText="Facebook"
                            SortExpression="Facebook" Visible="false" AllowFiltering="false"
                            UniqueName="Facebook">
                        </telerik:GridBoundColumn>

                        <%--[Skype]--%>
                        <telerik:GridBoundColumn DataField="Skype" HeaderText="Skype"
                            SortExpression="Skype" Visible="false" AllowFiltering="false"
                            UniqueName="Skype">
                        </telerik:GridBoundColumn>

                        <telerik:GridButtonColumn Text="Delete" CommandName="Delete" ButtonType="ImageButton" UniqueName="DeleteCommandColumn" />
                    </Columns>
                    <EditFormSettings EditFormType="Template">

                        <EditColumn UniqueName="EditColumn"></EditColumn>
                        <FormTemplate>
                            <table style="width: 500px; height: 600px">

                                <tr>
                                    <td>
                                        <asp:TextBox ID="txtPotentialUserId" Text='<%# Bind( "PotentialUserId") %>' runat="server" Visible="false"></asp:TextBox>
                                        <div>
                                            <asp:Label runat="server" ID="lblMessage" Style="color: red;" resourceKey="Message" Visible='<%#MessageExistEmail() %>'></asp:Label>
                                        </div>
                                        <div>
                                            <asp:Label runat="server" ID="lblFirstName" resourcekey="FirstName"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadTextBox ID="txtFirstName" Text='<%# Bind( "FirstName") %>' runat="server"></telerik:RadTextBox>
                                        </div>

                                    </td>
                                    <td>
                                        <div>
                                            <asp:Label runat="server" ID="lblLastName" resourcekey="LastName"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadTextBox ID="txtLastName" Text='<%# Bind( "LastName") %>' runat="server"></telerik:RadTextBox>
                                        </div>
                                    </td>

                                </tr>
                                <tr>
                                    <td>
                                        <div>
                                            <asp:Label runat="server" ID="lblMiddleName" resourcekey="MiddleName"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadTextBox ID="txtMiddleName" Text='<%# Bind( "MiddleName") %>' runat="server"></telerik:RadTextBox>
                                        </div>

                                    </td>
                                    <td>
                                        <div>
                                            <asp:Label runat="server" ID="lblEmail" resourcekey="Email"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadTextBox ID="txtEmail" Text='<%# Bind( "Email") %>' runat="server"></telerik:RadTextBox>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div>
                                            <asp:Label runat="server" ID="lblOrganizationName" resourcekey="OrganizationName"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadTextBox ID="txtOrganizationName" Text='<%# Bind( "OrganizationName") %>' runat="server"></telerik:RadTextBox>
                                        </div>
                                    </td>
                                    <td>
                                        <div>
                                            <asp:Label runat="server" ID="lblOrganizationType" resourcekey="OrganizationType"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadComboBox ID="ddOrganizationType" DataTextField="Label" DataValueField="Key" runat="server"
                                                AutoPostBack="true" OnSelectedIndexChanged="RadComboBox_SelectedIndexChanged">
                                            </telerik:RadComboBox>
                                        </div>
                                        <div>
                                            <telerik:RadTextBox CssClass="NoDisplay" ID="txtNewOrganizationType" runat="server" EmptyMessage='<%# Localization.GetString("NewOrganizationType", this.LocalResourceFile).ToString()%>'></telerik:RadTextBox>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div>
                                            <asp:Label runat="server" ID="lblCountry" resourcekey="Country"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadComboBox ID="ddCountry" DataTextField="country" DataValueField="code" runat="server"></telerik:RadComboBox>
                                        </div>
                                    </td>
                                    <td>
                                        <div>
                                            <asp:Label runat="server" ID="lblAddress" resourcekey="Address"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadTextBox ID="txtAddress" Text='<%# Bind( "Address") %>' runat="server"></telerik:RadTextBox>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div>
                                            <asp:Label runat="server" ID="lblPhone" resourcekey="Phone"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadTextBox ID="txtPhone" Text='<%# Bind( "Phone") %>' runat="server"></telerik:RadTextBox>
                                        </div>
                                    </td>
                                    <td>
                                        <div>
                                            <asp:Label runat="server" ID="lblLanguage" resourcekey="Language"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadComboBox ID="ddLanguage" DataTextField="Label" DataValueField="Key" runat="server"></telerik:RadComboBox>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div>
                                            <asp:Label runat="server" ID="lblQualification" resourcekey="Qualification"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadTextBox ID="txtQualification" Text='<%# Bind( "Qualification") %>' runat="server"></telerik:RadTextBox>
                                        </div>
                                    </td>
                                    <td>
                                        <div>
                                            <asp:Label runat="server" ID="lblSource" resourcekey="Source"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadTextBox ID="txtSource" Text='<%# Bind( "Source") %>' runat="server"></telerik:RadTextBox>
                                        </div>
                                    </td>
                                </tr>
                                <tr>

                                    <td>
                                        <div>
                                            <asp:Label runat="server" ID="lblSector" resourcekey="Sector"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadTextBox ID="txtSector" Text='<%# Bind( "Sector") %>' runat="server"></telerik:RadTextBox>
                                        </div>
                                    </td>
                                    <td>
                                        <div>
                                            <asp:Label runat="server" ID="lblBatch" resourcekey="Batch"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadTextBox ID="txtBatch" Text='<%# Bind( "Batch") %>' runat="server"></telerik:RadTextBox>
                                        </div>
                                    </td>
                                </tr>
                                <tr>

                                    <td>
                                        <div>
                                            <asp:Label runat="server" ID="lblTitle" resourcekey="Title"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadTextBox ID="txtTitle" Text='<%# Bind( "Title") %>' runat="server"></telerik:RadTextBox>
                                        </div>
                                    </td>
                                    <td>
                                        <div>
                                            <asp:Label runat="server" ID="lblZipCode" resourcekey="ZipCode"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadTextBox ID="txtZipCode" Text='<%# Bind( "ZipCode") %>' runat="server"></telerik:RadTextBox>
                                        </div>

                                    </td>
                                </tr>
                                <tr>

                                    <td>
                                        <div>
                                            <asp:Label runat="server" ID="lblWebSite" resourcekey="WebSite"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadTextBox ID="txtWebSite" Text='<%# Bind( "WebSite") %>' runat="server"></telerik:RadTextBox>
                                        </div>

                                    </td>
                                    <td>
                                        <div>
                                            <asp:Label runat="server" ID="lblGooglePlus" resourcekey="GooglePlus"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadTextBox ID="txtGooglePlus" Text='<%# Bind( "GooglePlus") %>' runat="server"></telerik:RadTextBox>
                                        </div>

                                    </td>

                                </tr>
                                <tr>
                                    <td>
                                        <div>
                                            <asp:Label runat="server" ID="lblLikedIn" resourcekey="LinkedIn"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadTextBox ID="txtLinkedIn" Text='<%# Bind( "LinkedIn") %>' runat="server"></telerik:RadTextBox>
                                        </div>

                                    </td>
                                    <td>
                                        <div>
                                            <asp:Label runat="server" ID="lblFacebook" resourcekey="Facebook"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadTextBox ID="txtFacebook" Text='<%# Bind( "Facebook") %>' runat="server"></telerik:RadTextBox>
                                        </div>

                                    </td>
                                </tr>
                                <tr>

                                    <td>
                                        <div>
                                            <asp:Label runat="server" ID="lblTwitter" resourcekey="Twitter"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadTextBox ID="txtTwitter" Text='<%# Bind( "Twitter") %>' runat="server"></telerik:RadTextBox>
                                        </div>

                                    </td>
                                    <td>
                                        <div>
                                            <asp:Label runat="server" ID="lblSkype" resourcekey="Skype"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadTextBox ID="txtSkype" Text='<%# Bind( "Skype") %>' runat="server"></telerik:RadTextBox>
                                        </div>

                                    </td>
                                </tr>

                                <tr>
                                    <td colspan="2">
                                        <asp:Button ID="btnUpdate" CommandName="Update" runat="server" resourcekey="btnUpdate" />

                                        <asp:Button ID="btnCancel" CommandName="Cancel" runat="server" resourcekey="btnCancel" />
                                    </td>
                                </tr>

                            </table>
                        </FormTemplate>
                    </EditFormSettings>
                    <%--  <EditFormSettings>
                    <EditColumn ButtonType="ImageButton" />
                </EditFormSettings>--%>
                </MasterTableView>
            </telerik:RadGrid>
        </div>
    </asp:Panel>

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Default"></telerik:RadAjaxLoadingPanel>
    <div id="dvBtn">
        <asp:Button ID="btnExport" OnClick="btnExport_Click" runat="server" Text="Export" AutoPostBack="true" class="bttn bttn-m bttn-default" />
        <div>
            <br />
            <asp:CheckBox ID="chkUpdate" runat="server" resourcekey="RewriteUser" />
            <telerik:RadAsyncUpload runat="server" ID="aUploadFile" MultipleFileSelection="Automatic"
                OnClientFileSelected="fileSelected" OnFileUploaded="aUploadFile_FileUploaded"
                MaxFileInputsCount="1" OnClientFileUploaded="onClientFileUploaded" />

            <asp:Label ID="lblResult" runat="server" Text=""></asp:Label>
        </div>

    </div>
</div>





<div style="display: none;">
    <asp:Button runat="server" ID="RadButton2" Text="" />
</div>
<div style="display: none;">
    <asp:Button runat="server" ID="RadButton1" Text="" />
</div>

<script src="<%=ControlPath%>js/NZPotentialUsers.js"></script>


<script type="text/javascript">
    function onClientFileUploadedUpdate(sender, args) {
        document.getElementById("<%=RadButton2.ClientID%>").click();
    }
    function onClientFileUploaded(sender, args) {
        document.getElementById("<%=RadButton1.ClientID%>").click();
    }
    function fileSelected(upload, args) {
        $telerik.$(".ruInputs li:first", upload.get_element()).addClass('hidden');
        upload.addFileInput();
        $telerik.$(".ruFakeInput", upload.get_element()).val(args.get_fileName());
        upload.set_enabled(true);
    }

</script>
