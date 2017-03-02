<%@ Control Language="C#" AutoEventWireup="true" CodeFile="NZUserProfile.ascx.cs"
    Inherits="NZUserProfile" %>
<%@ Register Src="../NXOtherControls/CountryStateCityV2.ascx" TagName="CountryStateCity"
    TagPrefix="uc1" %>

<script src="<%=ControlPath%>js/NZUserProfile.js"></script>
<div runat="server" visible="False" id="pnlImportantMessage" class="dnnFormMessage dnnFormValidationSummary">
    <asp:Label ID="lblImportantMessage" runat="server"></asp:Label>
</div>
<div class="user sidebar-layout">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div runat="server" id="ViewPanel" visible="False">
                <article>
                    <div class="row">
                        <div class="banner-wrapper">
                            <uc1:CountryStateCity ViewInEditMode="False" MultiSelect="False" ID="CountryStateCityViewMode" runat="server" ValidationGroup="profile" />
                        </div>
                    </div>
                    <div class="row">
                        <div class="content-wrapper">
                            <h1 class="title">
                                <asp:Label ID="lblFirstName" runat="server"></asp:Label>
                                <asp:Label ID="lblLastName" runat="server"></asp:Label>
                            </h1>
                            <div class="buttons clearfix">
                                <div class="actions">
                                    <asp:Button ID="btnEditViewMode" Visible="false" runat="server" ValidationGroup="profile" OnClick="btnEditProfile_Click1" resourcekey="EditProfile" />
                                    <asp:HyperLink ID="passwordLink" Visible="false" runat="server" resourcekey="ChangePassword" />
                                </div>
                            </div>

                            <h3 class="label">
                                <asp:Label ID="lblPersonalInformation2" runat="server" resourcekey="PersonalInformation"></asp:Label>
                            </h3>
                            <dl>
                                <dt>
                                    <asp:Label ID="lblAddress2" runat="server" resourcekey="Address"></asp:Label></dt>
                                <dd>
                                    <asp:Label ID="lblAddress" runat="server" Text="Label"></asp:Label></dd>
                                <dt>
                                    <asp:Label ID="lblCity2" runat="server" resourcekey="City"></asp:Label></dt>
                                <dd>
                                    <asp:Label ID="lblCity" runat="server" Text="Label"></asp:Label></dd>
                                <dt>
                                    <asp:Label ID="lblState2" runat="server" resourcekey="State"></asp:Label></dt>
                                <dd>
                                    <asp:Label ID="lblState" runat="server" Text="Label"></asp:Label></dd>
                                <dt>
                                    <asp:Label ID="lblCountry2" runat="server" resourcekey="Country"></asp:Label></dt>
                                <dd>
                                    <asp:Label ID="lblCountry" runat="server" Text="Label"></asp:Label></dd>
                                <dt>
                                    <asp:Label ID="lblPhone2" runat="server" resourcekey="Phone2"></asp:Label></dt>
                                <dd>
                                    <asp:Label ID="lblPhoneTxt" runat="server"></asp:Label></dd>
                            </dl>
                            <div runat="server" id="ViewSocialInformation" visible="false">
                                <h3 class="label">
                                    <asp:Label ID="lblSocialInformation" runat="server" resourcekey="SocialInformation"></asp:Label>
                                </h3>
                                <ul>
                                    <li runat="server" id="ViewEmail" visible="false">
                                        <asp:HyperLink ID="hlEmail" runat="server">
                                            <asp:Label ID="lblEmailTxt" runat="server"></asp:Label>
                                        </asp:HyperLink>
                                    </li>
                                    <li>
                                        <asp:Label ID="lblSkype" runat="server"></asp:Label>
                                    </li>
                                    <li>
                                        <asp:HyperLink ID="hlTwitter" runat="server">
                                            <span class="ss-twitter"></span>
                                            <asp:Label ID="lblTwitter" runat="server"></asp:Label>
                                        </asp:HyperLink>
                                    </li>
                                    <li>
                                        <asp:HyperLink ID="hlFacebook" runat="server">
                                            <asp:Label ID="lblFacebook" runat="server"></asp:Label>
                                        </asp:HyperLink>
                                    </li>
                                    <li>
                                        <asp:HyperLink ID="hlGoogle" runat="server">
                                            <asp:Label ID="lblGoogle" runat="server"></asp:Label>
                                        </asp:HyperLink>
                                    </li>
                                    <li>
                                        <asp:HyperLink ID="hlLinkedin" runat="server">
                                            <asp:Label ID="lblLinkedin" runat="server"></asp:Label>
                                        </asp:HyperLink>
                                    </li>
                                </ul>
                            </div>
                        </div>
                        <aside>
                        </aside>
                    </div>
                </article>
            </div>
            <div runat="server" id="EditPanel" visible="False">
                <div class="row">
                    <header class="intro">
                        <h1>
                            <asp:Label ID="lblAccountSettingsCaption" runat="server" resourcekey="AccountSettings"></asp:Label>
                        </h1>
                        <p class="introduction">
                            <asp:Label ID="lblAccountSettingsMsgCaption" runat="server" resourcekey="AccountSettingsMsg"></asp:Label>
                        </p>
                    </header>
                </div>
                <div class="row">
                    <div class="edit-form">
                        <fieldset>
                            <legend>
                                <asp:Label ID="lblPersonalInformation" runat="server" resourcekey="PersonalInfo"></asp:Label>
                            </legend>
                            <div class="field">
                                <label>
                                    <asp:Label ID="lblEmailCaption" runat="server" resourcekey="Email" AssociatedControlID="txtEmail"></asp:Label>
                                </label>
                                <div>
                                    <asp:TextBox ID="txtEmail" runat="server" Enabled="false" AutoPostBack="True" OnTextChanged="txtEmail_TextChanged"></asp:TextBox>
                                </div>
                                <div class="rfv">
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ValidationGroup="profile"
                                        ControlToValidate="txtEmail" resourcekey="rfvtxtEmail"></asp:RequiredFieldValidator>
                                    <asp:RegularExpressionValidator ID="rgvEmail" ControlToValidate="txtEmail" ValidationGroup="profile"
                                        runat="server" ErrorMessage="" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"></asp:RegularExpressionValidator>
                                    <asp:CustomValidator ID="cvExistingMail" runat="server" ErrorMessage="" resourcekey="ExistingMail"></asp:CustomValidator>
                                </div>
                            </div>
                            <div class="field">
                                <label>
                                    <asp:Label ID="lblFirstNameCaption" runat="server" resourcekey="FirstName" AssociatedControlID="txtFirstName"></asp:Label>
                                </label>
                                <div>
                                    <asp:TextBox ID="txtFirstName" runat="server" Enabled="true" onfocus="Focus(this.id,'this is a test')"
                                        onblur="Blur(this.id,'this is a test')"></asp:TextBox>
                                </div>
                                <div class="rfv">
                                    <asp:RequiredFieldValidator ID="rfvtxtFirstName" runat="server" ValidationGroup="profile"
                                        ControlToValidate="txtFirstName" resourcekey="rfvtxtFirstName"></asp:RequiredFieldValidator>
                                    <asp:RegularExpressionValidator ID="rgvtxtFirstName" runat="server" SetFocusOnError="True" ValidationGroup="profile"
                                        ControlToValidate="txtFirstName" ValidationExpression="^[a-zA-Z'.\s]{1,100}$">
                                    </asp:RegularExpressionValidator>
                                </div>
                            </div>
                            <div class="field">
                                <label>
                                    <asp:Label ID="lblLastNameCaption" runat="server" AssociatedControlID="txtLastName"
                                        resourcekey="LastName"></asp:Label>
                                </label>
                                <div>
                                    <asp:TextBox ID="txtLastName" runat="server" Enabled="true"></asp:TextBox>
                                </div>
                                <div class="rfv">
                                    <asp:RequiredFieldValidator ID="rfvtxtLastName" runat="server" ValidationGroup="profile"
                                        ControlToValidate="txtLastName" resourcekey="rfvtxtLastName"></asp:RequiredFieldValidator>
                                    <asp:RegularExpressionValidator ID="rgvtxtLastName" runat="server" SetFocusOnError="True" ValidationGroup="profile"
                                        ControlToValidate="txtLastName" ValidationExpression="^[a-zA-Z'.\s]{1,100}$">
                                    </asp:RegularExpressionValidator>
                                </div>
                            </div>
                            <div id="divPassword" runat="server">
                                <div class="field">
                                    <label>
                                        <asp:Label ID="lblPassword" runat="server" resourcekey="Password" AssociatedControlID="txtFirstName"></asp:Label>
                                    </label>
                                    <div>
                                        <asp:TextBox TextMode="Password" ID="txtPassword" runat="server" Enabled="true"></asp:TextBox>
                                    </div>
                                    <div class="rfv">
                                        <asp:RequiredFieldValidator ID="rvPassword" runat="server" ValidationGroup="profile"
                                            ControlToValidate="txtPassword" resourcekey="rfvtxtPassword"></asp:RequiredFieldValidator>
                                        <asp:RegularExpressionValidator ID="rgvPassword" ControlToValidate="txtPassword"
                                            ValidationGroup="profile" runat="server" ErrorMessage="" ValidationExpression="^[a-zA-Z0-9\s]{7,20}$"></asp:RegularExpressionValidator>
                                    </div>
                                </div>
                            </div>
                            <div id="divPasswordConfirm" runat="server">
                                <div class="field">
                                    <label>
                                        <asp:Label ID="lblPasswordConfirmatiom" runat="server" AssociatedControlID="txtLastName"
                                            resourcekey="PasswordConfirmation"></asp:Label>
                                    </label>
                                    <div>
                                        <asp:TextBox TextMode="Password" ID="txtPasswordConfirmation" runat="server" Enabled="true"></asp:TextBox>
                                    </div>
                                    <div class="rfv">
                                        <asp:RequiredFieldValidator ID="rvPasswordConfirmation" runat="server" ValidationGroup="profile"
                                            ControlToValidate="txtPasswordConfirmation" resourcekey="rfvtxtPasswordConfirmation"></asp:RequiredFieldValidator>
                                        <asp:CompareValidator ID="cvPasswordConfirmation" runat="server" ControlToCompare="txtPassword"
                                            ControlToValidate="txtPasswordConfirmation" ErrorMessage="Password Doesnt Match"
                                            ValidationGroup="profile"></asp:CompareValidator>
                                    </div>
                                </div>
                            </div>
                        </fieldset>
                        <fieldset>
                            <legend>
                                <asp:Label ID="lblLocalizationInfo2" runat="server" resourcekey="LocalizationInfo"></asp:Label>
                            </legend>
                            <div class="field">
                                <label>
                                    <asp:Label ID="lblLocalizationInfo" runat="server" resourcekey="PhysicalAddress"></asp:Label>
                                </label>
                                <div>
                                    <uc1:CountryStateCity ID="CountryStateCityEditMode" MultiSelect="False" AddressRequired="True"
                                        runat="server" ValidationGroup="profile" ViewInEditMode="True" />
                                </div>
                            </div>
                            <div class="field">
                                <label>
                                    <asp:Label ID="lblPhoneCaption" runat="server" resourcekey="Phone" AssociatedControlID="txtPhone"></asp:Label>
                                </label>
                                <div>
                                    <asp:TextBox ID="txtPhone" runat="server" Enabled="true"></asp:TextBox>
                                </div>
                                <div class="rfv">
                                    <asp:RequiredFieldValidator ID="rfvtxtPhone" runat="server" ValidationGroup="profile" ControlToValidate="txtPhone" resourcekey="rfvtxtPhone"></asp:RequiredFieldValidator>
                                     <asp:RegularExpressionValidator ID="rgvtxtPhone" runat="server" SetFocusOnError="True" ValidationGroup="profile"
                                            ControlToValidate="txtPhone" ValidationExpression="([0-9\s]|-)*" >
                                        </asp:RegularExpressionValidator>
                                </div>
                            </div>
                        </fieldset>
                        <div id="divCrm" runat="server" visible="true">
                            <fieldset>
                                <legend>
                                    <asp:Label ID="lblCrmLabel" runat="server" resourcekey="CrmLabel"></asp:Label>
                                </legend>
                                <div class="field">
                                    <label>
                                        <asp:Label ID="lblWhoAreYou" runat="server" resourcekey="WhoAreYou"></asp:Label>
                                    </label>
                                    <div>
                                        <asp:DropDownList ID="ddlWhoareYou" DataTextField="Label" DataValueField="Value" runat="server"></asp:DropDownList>
                                    </div>
                                    <div class="rfv">
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator10" runat="server" ControlToValidate="ddlWhoareYou" resourcekey="rfvddWhoareYou" InitialValue="0" ValidationGroup="profile"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="field">
                                    <label>
                                        <asp:Label ID="lblSourceText" runat="server" resourcekey="SourceText"></asp:Label>
                                    </label>
                                    <div>
                                        <asp:DropDownList ID="ddlSource" DataTextField="Label" DataValueField="Value" runat="server"></asp:DropDownList>
                                    </div>
                                    <div class="rfv">
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="ddlSource" resourcekey="rfvddSource" InitialValue="0" ValidationGroup="profile"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="field checkbox">
                                    <label>
                                        <asp:Label ID="lblInterest" runat="server" resourcekey="Interest"></asp:Label>
                                    </label>
                                    <div>
                                        <asp:CheckBoxList ID="chkTheme" DataTextField="Label" DataValueField="Key" RepeatColumns="3"
                                            runat="server">
                                        </asp:CheckBoxList>
                                    </div>
                                </div>
                                <div class="field checkbox">
                                    <label>
                                        <asp:Label ID="lblBeneficiaries" runat="server" resourcekey="Beneficiaries"></asp:Label>
                                    </label>
                                    <div>
                                        <asp:CheckBoxList ID="chkBeneficiaries" DataTextField="Label" DataValueField="Key"
                                            RepeatColumns="3" runat="server">
                                        </asp:CheckBoxList>
                                    </div>
                                </div>
                                <div class="field checkbox">
                                    <label>
                                        <asp:Label ID="lblSector" runat="server" resourcekey="Sector"></asp:Label>
                                    </label>
                                    <div>
                                        <asp:CheckBoxList ID="chkSector" DataTextField="Label" DataValueField="Key" RepeatColumns="3"
                                            runat="server">
                                        </asp:CheckBoxList>
                                    </div>
                                </div>
                                <div class="field">
                                    <label>
                                        <asp:Label ID="lblLanguage" runat="server" resourcekey="Language"></asp:Label>
                                    </label>
                                    <div>
                                        <asp:DropDownList ID="ddlLanguage" DataTextField="Label" DataValueField="Value" runat="server"></asp:DropDownList>
                                    </div>
                                    <div class="rfv">
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="ddlLanguage" resourcekey="rfvddLanguage" InitialValue="0" ValidationGroup="profile"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                            </fieldset>
                        </div>
                        <div id="dvSocialMediaPane" runat="server" visible="False">
                            <fieldset>
                                <legend>
                                    <asp:Label ID="lblSocialMedia" runat="server" resourcekey="SocialInfo"></asp:Label></legend>
                                <div class="field">
                                    <label>
                                        <asp:Label ID="lblLinkedInSocialMedia" runat="server" resourcekey="LinkedIn"></asp:Label></label>
                                    <asp:TextBox ID="txtLinkedIn" runat="server" Enabled="true"></asp:TextBox>
                                    <div class="rfv">
                                        <asp:RegularExpressionValidator ID="rgvtxtLinkedIn" runat="server" SetFocusOnError="True" ValidationGroup="profile"
                                            ControlToValidate="txtLinkedIn" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*">
                                        </asp:RegularExpressionValidator>
                                    </div>
                                </div>
                                <div class="field">
                                    <label>
                                        <asp:Label ID="lblSkypeSocialMedia" runat="server" resourcekey="Skype"></asp:Label></label>
                                    <asp:TextBox ID="txtSkype" runat="server" Enabled="true"></asp:TextBox>
                                     <div class="rfv">
                                        <asp:RegularExpressionValidator ID="rgvtxtSkype" runat="server" SetFocusOnError="True" ValidationGroup="profile"
                                            ControlToValidate="txtSkype" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*">
                                        </asp:RegularExpressionValidator>
                                    </div>
                                </div>
                                <div class="field">
                                    <label>
                                        <asp:Label ID="lblTwitterSocialMedia" runat="server" resourcekey="Twitter"></asp:Label></label>
                                    <asp:TextBox ID="txtTwitter" runat="server" Enabled="true"></asp:TextBox>
                                     <div class="rfv">
                                        <asp:RegularExpressionValidator ID="rgvtxtTwitter" runat="server" SetFocusOnError="True" ValidationGroup="profile"
                                            ControlToValidate="txtTwitter" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*">
                                        </asp:RegularExpressionValidator>
                                    </div>
                                </div>
                                <div class="field">
                                    <label>
                                        <asp:Label ID="lblFacebookSocialMedia" runat="server" resourcekey="Facebook"></asp:Label></label>
                                    <asp:TextBox ID="txtFacebook" runat="server" Enabled="true"></asp:TextBox>
                                     <div class="rfv">
                                        <asp:RegularExpressionValidator ID="rgvtxtFacebook" runat="server" SetFocusOnError="True" ValidationGroup="profile"
                                            ControlToValidate="txtFacebook" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*">
                                        </asp:RegularExpressionValidator>
                                    </div>
                                </div>
                                <div class="field">
                                    <label>
                                        <asp:Label ID="lblGoogleSocialMedia" runat="server" resourcekey="Google"></asp:Label></label>
                                    <asp:TextBox ID="txtGoogle" runat="server" Enabled="true"></asp:TextBox>
                                     <div class="rfv">
                                        <asp:RegularExpressionValidator ID="rgvtxtGoogle" runat="server" SetFocusOnError="True" ValidationGroup="profile"
                                            ControlToValidate="txtGoogle" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*">
                                        </asp:RegularExpressionValidator>
                                    </div>
                                </div>
                            </fieldset>
                        </div>
                        <div>
                            <asp:CheckBox ID="chkNotifications" resourcekey="Authorization" runat="server" />
                        </div>
                        <div class="rfv">
                            <asp:CustomValidator ID="lblMessage" runat="server"></asp:CustomValidator>
                        </div>
                        <div id="dvTerms" runat="server" visible="True">
                            <div>
                                <asp:CheckBox ID="chkTerms" runat="server" AutoPostBack="True" OnCheckedChanged="chkTerms_CheckedChanged" />
                                <asp:Label ID="lblAcceptTerms" runat="server" resourcekey="AcceptTerms" Text=""></asp:Label>
                            </div>
                        </div>

                        
                        <div class="buttons">
                            <asp:Button ID="btnEditProfile" runat="server" ValidationGroup="profile" OnClick="btnEditProfile_Click1" class="btn form-save"></asp:Button>
                            <asp:Button ID="btnCancel" runat="server" CausesValidation="False" OnClick="btnCancelProfile_Click1" class="btn form-cancel"></asp:Button>
                        </div>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>

