<%@ Control Language="C#" AutoEventWireup="true" CodeFile="NZManageUsers.ascx.cs" Inherits="NZManageUsers" %>

<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>


<link href="<%=ControlPath%>css/module.css" rel="stylesheet" />
<div>
    <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
        <AjaxSettings>
            <telerik:AjaxSetting AjaxControlID="panel1">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="grdManageUsers" LoadingPanelID="RadAjaxLoadingPanel1" />
                </UpdatedControls>
            </telerik:AjaxSetting>
        </AjaxSettings>
    </telerik:RadAjaxManager>

    <asp:Panel runat="server" ID="panel1">
        <div id="dvReport">
            <telerik:RadGrid AutoGenerateColumns="true" runat="server" ID="grdManageUsers" AllowFiltering="true" FilterControlWidth="80" AllowFilteringByColumn="True" OnNeedDataSource="RadGrid1_NeedDataSource"
                AllowPaging="True" AllowAutomaticUpdates="True" AllowAutomaticInserts="True" OnUpdateCommand="RadGrid1_UpdateCommand"
                AllowSorting="True" PageSize="60" OnItemDataBound="RadGrid1_ItemDataBound">
                <GroupingSettings CaseSensitive="false" />
                <PagerStyle Mode="NextPrevAndNumeric" />

                <MasterTableView AutoGenerateColumns="False" DataKeyNames="UserId" CommandItemDisplay="Top" AllowFilteringByColumn="True">
                    <Columns>

                        <telerik:GridEditCommandColumn ButtonType="ImageButton" UniqueName="EditCommandColumn">
                        </telerik:GridEditCommandColumn>
                        <telerik:GridBoundColumn DataField="UserId" HeaderText="UserId" SortExpression="UserId"
                            UniqueName="UserId" Display="false">
                        </telerik:GridBoundColumn>
                        <telerik:GridBoundColumn DataField="FirstName" HeaderText="FirstName" SortExpression="FirstName"
                            UniqueName="FirstName">
                        </telerik:GridBoundColumn>
                        <telerik:GridBoundColumn DataField="LastName" HeaderText="LastName" SortExpression="LastName"
                            UniqueName="LastName">
                        </telerik:GridBoundColumn>
                        <telerik:GridBoundColumn DataField="Telephone" HeaderText="Telephone" SortExpression="Telephone"
                            UniqueName="Telephone">
                        </telerik:GridBoundColumn>
                        <telerik:GridBoundColumn DataField="email" HeaderText="Email" SortExpression="email"
                            UniqueName="email">
                        </telerik:GridBoundColumn>
                        <telerik:GridTemplateColumn DataField="Country" HeaderText="Location" UniqueName="Country" SortExpression="Country">
                            <FilterTemplate>
                                <telerik:RadComboBox ID="rdCountry" Skin="Metro" runat="server" DataTextField="country" CssClass="radInput" EnableLoadOnDemand="true" MarkFirstMatch="true" SelectedValue='<%# ((GridItem)Container).OwnerTableView.GetColumn("Country").CurrentFilterValue %>'
                                    DataValueField="code" SortCaseSensitive="false" AllowCustomText="true" DataSource='<%# BindCountry() %>' OnClientSelectedIndexChanged="CountryIndexChanged">
                                </telerik:RadComboBox>

                                <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
                                    <script type="text/javascript">
                                        function CountryIndexChanged(sender, args) {
                                            var tableView = $find("<%# ((GridItem)Container).OwnerTableView.ClientID %>");
                                            if (args.get_item().get_value() != "%NULL%") {
                                                if (args.get_item().get_value() != "") {
                                                    tableView.filter("Country", args.get_item().get_value(), "EqualTo");
                                                } else {
                                                    tableView.filter("Country", args.get_item().get_value(), "IsEmpty");
                                                }
                                            } else {
                                                tableView.filter("Country", args.get_item().get_value(), "NoFilter");
                                            }
                                        }
                                    </script>
                                </telerik:RadScriptBlock>

                            </FilterTemplate>
                            <HeaderStyle VerticalAlign="Middle" />
                            <ItemStyle VerticalAlign="Middle" Width="200px" />
                            <ItemTemplate>
                                <asp:Label ID="lblLocation" runat="server" Text='<%#GetNexsoLocation((string)DataBinder.Eval(Container.DataItem,"Country"),(string)DataBinder.Eval(Container.DataItem,"Region"), (string)DataBinder.Eval(Container.DataItem, "City"))%>' />
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                    </Columns>

                    <EditFormSettings EditFormType="Template">

                        <EditColumn UniqueName="EditColumn"></EditColumn>
                        <FormTemplate>


                            <section id="FormEdit">
                                <div class="forms">
                                    <!--Personal info  -->
                                    <div class="subForm">
                                        <header>
                                            <asp:Label runat="server" ID="lblPersonalInformation" class="formTitle" resourcekey="PersonalInfo"></asp:Label>
                                        </header>
                                        <div class="inputGroup">
                                            <asp:Label runat="server" ID="lblEmail" resourcekey="Email"></asp:Label>
                                            <telerik:RadTextBox ID="txtEmail" runat="server"></telerik:RadTextBox>
                                            <div class="rfv">
                                                <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ValidationGroup="profile"
                                                    ControlToValidate="txtEmail" resourcekey="rfvtxtEmail"></asp:RequiredFieldValidator>
                                                <asp:RegularExpressionValidator ID="rgvEmail" ControlToValidate="txtEmail" ValidationGroup="profile"
                                                    runat="server" ErrorMessage='<%#InvalidEmail() %>' ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"></asp:RegularExpressionValidator>
                                                <asp:Label runat="server" ID="lblMessageExistEmail" Style="color: red; text-align: left" resourceKey="MessageExistEmail" Visible='<%#MessageExistEmail() %>'></asp:Label>
                                            </div>
                                        </div>
                                        <div class="inputGroup">
                                            <asp:TextBox ID="txtUserID" Text='<%# Bind( "UserId") %>' runat="server" Visible="false"></asp:TextBox>
                                            <asp:Label runat="server" ID="lblFirstName" resourcekey="FirstName"></asp:Label>
                                            <telerik:RadTextBox ID="txtFirstName" Text='<%# Bind( "FirstName") %>' runat="server"></telerik:RadTextBox>
                                            <div class="rfv">
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ValidationGroup="profile"
                                                    ControlToValidate="txtFirstName" resourcekey="rfvtxtFirstName"></asp:RequiredFieldValidator>
                                            </div>
                                            <div class="inputGroup">
                                                <asp:Label runat="server" ID="lblLastName" resourcekey="LastName"></asp:Label>
                                                <telerik:RadTextBox ID="txtLastName" Text='<%# Bind( "LastName") %>' runat="server"></telerik:RadTextBox>
                                                <div class="rfv">
                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ValidationGroup="profile"
                                                        ControlToValidate="txtLastName" resourcekey="rfvtxtLastName"></asp:RequiredFieldValidator>
                                                </div>
                                            </div>
                                            <div class="inputGroup">
                                                <asp:Label ID="lblPassword" runat="server" resourcekey="Password"></asp:Label>
                                                <telerik:RadTextBox TextMode="Password" ID="txtPassword" runat="server"></telerik:RadTextBox>
                                                <div class="rfv">
                                                    <asp:RequiredFieldValidator ID="rvPassword" runat="server" ValidationGroup="profile"
                                                        ControlToValidate="txtPassword" resourcekey="rfvtxtPassword"></asp:RequiredFieldValidator>
                                                    <asp:RegularExpressionValidator ID="rgvPassword" ControlToValidate="txtPassword"
                                                        ValidationGroup="profile" runat="server" ErrorMessage='<%#InvalidPassword() %>' ValidationExpression="^[a-zA-Z0-9\s]{7,20}$"></asp:RegularExpressionValidator>
                                                </div>
                                            </div>
                                            <div class="inputGroup">
                                                <asp:Label runat="server" ID="lblTelephone" resourcekey="Telephone"></asp:Label>
                                                <telerik:RadTextBox ID="txtTelephone" Text='<%# Bind( "Telephone") %>' runat="server"></telerik:RadTextBox>
                                                <div class="rfv">
                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server" ValidationGroup="profile"
                                                        ControlToValidate="txtTelephone" resourcekey="rfvtxtPhone"></asp:RequiredFieldValidator>
                                                </div>
                                            </div>
                                            <div class="inputGroup">
                                                <asp:Label runat="server" ID="lblAddress" resourcekey="Address"></asp:Label>
                                                <telerik:RadTextBox ID="txtAddress" Text='<%# Bind( "Address") %>' runat="server"></telerik:RadTextBox>
                                                <div class="rfv">
                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ValidationGroup="profile"
                                                        ControlToValidate="txtAddress" resourcekey="rfvtxtAddress"></asp:RequiredFieldValidator>
                                                </div>
                                            </div>
                                            <div class="inputGroup">
                                                <asp:Label runat="server" ID="lblLanguage" resourcekey="Language"></asp:Label>
                                                <telerik:RadComboBox ID="ddLanguage" DataTextField="Label" DataValueField="Value" runat="server"></telerik:RadComboBox>
                                                <div class="rfv">
                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ControlToValidate="ddLanguage"
                                                        resourcekey="rfvddLanguage" InitialValue="0" ValidationGroup="profile"></asp:RequiredFieldValidator>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- Aditional info -->
                                    <div class="subForm">
                                        <header>
                                            <asp:Label runat="server" ID="lblAdditionalInfo" resourcekey="AdditionalInfo"></asp:Label>
                                        </header>
                                        <div class="inputgroup">
                                            <asp:Label runat="server" ID="lblCustomerType" resourcekey="CustomerType"></asp:Label>
                                            <telerik:RadComboBox ID="ddCustomerType" DataTextField="Label" DataValueField="Value" runat="server"></telerik:RadComboBox>
                                            <div class="rfv">
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator8" runat="server" ControlToValidate="ddCustomerType"
                                                    resourcekey="rfvddWhoareYou" InitialValue="0" ValidationGroup="profile"></asp:RequiredFieldValidator>
                                            </div>
                                        </div>
                                        <div class="inputgroup">
                                            <asp:Label runat="server" ID="lblNexsoEnrolment" resourcekey="NexsoEnrolment"></asp:Label>
                                            <telerik:RadComboBox ID="ddNexsoEnrolment" DataTextField="Label" DataValueField="Value" runat="server"></telerik:RadComboBox>
                                            <div class="rfv">
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator9" runat="server" ControlToValidate="ddNexsoEnrolment"
                                                    resourcekey="rfvddSource" InitialValue="0" ValidationGroup="profile"></asp:RequiredFieldValidator>
                                            </div>
                                        </div>
                                        <div class="inputgroup">
                                            <asp:Label ID="lblInterest" runat="server" resourcekey="Interest"></asp:Label>
                                            <telerik:RadComboBox ID="ddUserTheme" runat="server" CheckBoxes="true" DataTextField="Label"
                                                DataValueField="Key" AllowCustomText="true" EnableCheckAllItemsCheckBox="true">
                                            </telerik:RadComboBox>
                                            <div class="rfv"></div>
                                        </div>
                                        <div class="inputgroup">
                                            <asp:Label ID="lblBeneficiaries" runat="server" resourcekey="Beneficiaries"></asp:Label>
                                            <telerik:RadComboBox ID="ddUserBeneficiaries" runat="server" CheckBoxes="true" DataTextField="Label"
                                                DataValueField="Key" AllowCustomText="true" EnableCheckAllItemsCheckBox="true">
                                            </telerik:RadComboBox>
                                            <div class="rfv"></div>
                                        </div>
                                        <div class="inputgroup">
                                            <asp:Label ID="lblSector" runat="server" resourcekey="Sector"></asp:Label>
                                            <telerik:RadComboBox ID="ddUserSector" runat="server" CheckBoxes="true" DataTextField="Label" RegisterWithScriptManager="False"
                                                DataValueField="Key" AllowCustomText="true" EnableCheckAllItemsCheckBox="true">
                                            </telerik:RadComboBox>
                                            <div class="rfv"></div>
                                        </div>
                                    </div>
                                    <!-- Social networks -->
                                    <div class="subForm">
                                        <header>
                                            <asp:Label runat="server" ID="lblSocialNetworks" resourcekey="SocialNetworks"></asp:Label>
                                        </header>
                                        <div class="inputGroup">
                                            <asp:Label runat="server" ID="lblSkypeName" resourcekey="SkypeName"></asp:Label>
                                            <telerik:RadTextBox ID="txtSkypeName" Text='<%# Bind( "SkypeName") %>' runat="server"></telerik:RadTextBox>
                                            <div class="rfv"></div>
                                        </div>
                                        <div class="inputGroup">
                                            <asp:Label runat="server" ID="lblGoogle" resourcekey="Google"></asp:Label>
                                            <telerik:RadTextBox ID="txtGoogle" Text='<%# Bind( "Google") %>' runat="server"></telerik:RadTextBox>
                                            <div class="rfv"></div>
                                        </div>
                                        <div class="inputGroup">
                                            <asp:Label runat="server" ID="lblLikedIn" resourcekey="LinkedIn"></asp:Label>
                                            <telerik:RadTextBox ID="txtLinkedIn" Text='<%# Bind( "LinkedIn") %>' runat="server"></telerik:RadTextBox>
                                            <div class="rfv"></div>
                                        </div>
                                        <div class="inputGroup">
                                            <asp:Label runat="server" ID="lblFacebook" resourcekey="Facebook"></asp:Label>
                                            <telerik:RadTextBox ID="txtFacebook" Text='<%# Bind( "Facebook") %>' runat="server"></telerik:RadTextBox>
                                            <div class="rfv"></div>
                                        </div>
                                        <div class="inputGroup">
                                            <asp:Label runat="server" ID="lblTwitter" resourcekey="Twitter"></asp:Label>
                                            <telerik:RadTextBox ID="txtTwitter" Text='<%# Bind( "Twitter") %>' runat="server"></telerik:RadTextBox>
                                            <div class="rfv"></div>
                                        </div>
                                        <div class="inputGroup">
                                            <asp:Label runat="server" ID="lblOtherSocialNetwork" resourcekey="OtherSocialNetwork"></asp:Label>
                                            <telerik:RadTextBox ID="txtOtherSocialNetwork" Text='<%# Bind( "OtherSocialNetwork") %>' runat="server"></telerik:RadTextBox>
                                            <div class="rfv"></div>
                                        </div>
                                    </div>
                                </div>
                                <div class="confirm">
                                    <div class="newsletter">
                                        <asp:CheckBox ID="chkNotifications" resourcekey="AllowNexsoNotifications" runat="server" />
                                    </div>
                                    <div class="submit">
                                        <asp:Button ID="btnUpdate" CommandName="Update" runat="server" resourcekey="btnUpdate" ValidationGroup="profile" class="bttn bttn-m bttn-secondary" />
                                        <asp:Button ID="btnCancel" CommandName="Cancel" runat="server" resourcekey="btnCancel" class="bttn bttn-m bttn-alert" />
                                    </div>
                                </div>
                            </section>

                        </FormTemplate>
                    </EditFormSettings>
                </MasterTableView>
            </telerik:RadGrid>
        </div>
    </asp:Panel>
    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Default"></telerik:RadAjaxLoadingPanel>
</div>
<div class="controls">
    <div id="dvBtn">
        <asp:Button ID="btnUpdateBatch" runat="server" resourcekey="UpdateBatch" Visible="false" OnClick="btnUpdateBatch_Click" />
    </div>
</div>



