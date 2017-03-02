<%@ Control Language="C#" AutoEventWireup="true" CodeFile="NZRegistrationWizard.ascx.cs"
    Inherits="NZRegistrationWizard" %>
<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<%@ Import Namespace="NexsoProBLL" %>
<link href="<%=ControlPath%>css/Module.css" rel="stylesheet" type="text/css" />
<%@ Register Src="../NXOtherControls/CountryStateCityV2.ascx" TagName="CountryStateCity"
    TagPrefix="uc1" %>
<div class="connect-wizard">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:Wizard ID="Wizard1" runat="server" DisplaySideBar="False" OnPreviousButtonClick="Wizard1_PreviousButtonClick"
                OnFinishButtonClick="Wizard1_FinishButtonClick" OnNextButtonClick="Wizard1_NextButtonClick" Width="100%">
                <HeaderTemplate>
                    <div class="banner">
                        <div class="row">
                            <div class="step-navigation">
                                <h1>
                                    <asp:Label ID="lblWizardTitle" runat="server" resourcekey="WizardTitle"></asp:Label>
                                </h1>
                                <ul id="header" class="clearfix">
                                    <asp:Repeater ID="SideBarList" runat="server">
                                        <ItemTemplate>
                                            <li><a class="<%# GetClassForWizardStep(Container.DataItem) %>" title="<%#Eval("Name")%>">
                                                <%--  <span class="step-title">
                      <%# Eval("Name")%></span>--%></a> </li>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </ul>
                            </div>
                        </div>
                    </div>
                </HeaderTemplate>
                <WizardSteps>
                    <asp:WizardStep ID="WizardStep0" runat="server">
                        <div class="row">
                            <div id="wizard-form-Step0" class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="lblIntroductionTitle" runat="server"></asp:Label>
                                    </legend>
                                    <p class="introduction">
                                        <asp:Label ID="lblStep0Title" runat="server"></asp:Label>
                                    </p>
                                    <asp:Label ID="lblStep0Description" runat="server" resourcekey="Step0Description"></asp:Label>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep1" runat="server">
                        <div class="row">
                            <div id="wizard-form-Step1" class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="lblStep1Title" runat="server" resourcekey="Step1Title"></asp:Label>
                                    </legend>
                                    <p class="introduction">
                                        <asp:Label ID="lblStep1Description" runat="server" resourcekey="Step1Description"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <div>
                                            <telerik:RadAjaxPanel ID="RadAjaxPanel1" runat="server">
                                                <div>
                                                    <telerik:RadListView ID="RadListView1" runat="server" AllowMultiItemSelection="true"
                                                        ItemPlaceholderID="AutoStoreDetailsPlaceHolder" OnItemCommand="abc_ItemCommand">
                                                        <LayoutTemplate>
                                                            <asp:PlaceHolder runat="server" ID="AutoStoreDetailsPlaceHolder"></asp:PlaceHolder>
                                                        </LayoutTemplate>
                                                        <ItemTemplate>
                                                            <asp:Button ID="SelectButton1" Text='<%#Eval("Label")%> ' CommandName="Select" runat="server"
                                                                CssClass="buttonWrapper"></asp:Button>
                                                        </ItemTemplate>
                                                        <SelectedItemTemplate>
                                                            <asp:Button ID="DeselectButton1" Text='<%#Eval ("Label")  %>' CommandName="Deselect"
                                                                runat="server" CssClass="selectButtonWrapper buttonWrapper" />
                                                        </SelectedItemTemplate>
                                                    </telerik:RadListView>
                                                </div>
                                            </telerik:RadAjaxPanel>
                                            <div class="rfv">
                                                <asp:CustomValidator ID="rfvTheme" runat="server" resourcekey="rfvTheme"></asp:CustomValidator>
                                            </div>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep2" runat="server">
                        <div class="row">
                            <div id="wizard-form-Step2" class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="lblStep2Title" runat="server" resourcekey="Step2Title"></asp:Label>
                                    </legend>
                                    <p class="introduction">
                                        <asp:Label ID="lblStep2Description" runat="server" resourcekey="Step2Description"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <div>
                                            <telerik:RadAjaxPanel ID="RadAjaxPanel2" runat="server">
                                                <div>
                                                    <telerik:RadListView ID="RadListView2" runat="server" AllowMultiItemSelection="true"
                                                        ItemPlaceholderID="AutoStoreDetailsPlaceHolder" OnItemCommand="abc_ItemCommand">
                                                        <LayoutTemplate>
                                                            <asp:PlaceHolder runat="server" ID="AutoStoreDetailsPlaceHolder"></asp:PlaceHolder>
                                                        </LayoutTemplate>
                                                        <ItemTemplate>
                                                            <asp:Button ID="SelectButton2" Text='<%#Eval("Label")%> ' CommandName="Select" runat="server"
                                                                CssClass="buttonWrapper" />
                                                        </ItemTemplate>
                                                        <SelectedItemTemplate>
                                                            <asp:Button ID="deselectButton2" Text='<%#Eval ("Label")  %>' CommandName="Deselect"
                                                                runat="server" CssClass="selectButtonWrapper buttonWrapper" />
                                                        </SelectedItemTemplate>
                                                    </telerik:RadListView>
                                                </div>
                                            </telerik:RadAjaxPanel>
                                        </div>
                                        <div class="rfv">
                                            <asp:CustomValidator ID="rfvBeneficiaries" runat="server" resourcekey="rfvBeneficiaries"></asp:CustomValidator>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep3" runat="server">
                        <div class="row">
                            <div id="wizard-form-Step3" class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="lblStep3Title" runat="server" resourcekey="Step3Title"></asp:Label>
                                    </legend>
                                    <p class="introduction">
                                        <asp:Label ID="lblStep3Description" runat="server" resourcekey="Step3Description"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <div>
                                            <telerik:RadAjaxPanel ID="RadAjaxPanel3" runat="server">
                                                <div>
                                                    <telerik:RadListView ID="RadListView3" runat="server" AllowMultiItemSelection="true"
                                                        ItemPlaceholderID="AutoStoreDetailsPlaceHolder" OnItemCommand="abc_ItemCommand"
                                                        Width="30%">
                                                        <LayoutTemplate>
                                                            <asp:PlaceHolder runat="server" ID="AutoStoreDetailsPlaceHolder"></asp:PlaceHolder>
                                                        </LayoutTemplate>
                                                        <ItemTemplate>
                                                            <asp:Button ID="SelectButton3" Text='<%#Eval("Label")%> ' DataValueField="Key" CommandName="Select"
                                                                runat="server" CssClass="buttonWrapper" />
                                                        </ItemTemplate>
                                                        <SelectedItemTemplate>
                                                            <asp:Button ID="DeselectButton3" Text='<%#Eval ("Label")  %>' DataValueField="Key"
                                                                CommandName="Deselect" runat="server" CssClass="selectButtonWrapper buttonWrapper" />
                                                        </SelectedItemTemplate>
                                                    </telerik:RadListView>
                                                </div>
                                            </telerik:RadAjaxPanel>
                                        </div>
                                        <div class="rfv">
                                            <asp:CustomValidator ID="rfvSector" runat="server" resourcekey="rfvSector"></asp:CustomValidator>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep4" runat="server">
                        <div class="row">
                            <div id="wizard-form-Step4" class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="lblStep4Title" runat="server" resourcekey="Step4Title"></asp:Label>
                                    </legend>
                                    <p class="introduction">
                                        <asp:Label ID="lblStep4Description" runat="server" resourcekey="Step4Description"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <div>
                                            <telerik:RadAjaxPanel ID="RadAjaxPanel4" runat="server">
                                                <div>
                                                    <telerik:RadListView ID="RadListView4" runat="server" AllowMultiItemSelection="true"
                                                        ItemPlaceholderID="AutoStoreDetailsPlaceHolder" OnItemCommand="abc_ItemCommand">
                                                        <LayoutTemplate>
                                                            <asp:PlaceHolder runat="server" ID="AutoStoreDetailsPlaceHolder"></asp:PlaceHolder>
                                                        </LayoutTemplate>
                                                        <ItemTemplate>
                                                            <asp:Button ID="SelectButton4" Text='<%#Eval("Label")%> ' CommandName="Select" runat="server"
                                                                CssClass="buttonWrapper"></asp:Button>
                                                        </ItemTemplate>
                                                        <SelectedItemTemplate>
                                                            <asp:Button ID="DeselectButton4" Text='<%#Eval ("Label")  %>' CommandName="Deselect"
                                                                runat="server" CssClass="selectButtonWrapper buttonWrapper" />
                                                        </SelectedItemTemplate>
                                                    </telerik:RadListView>
                                                </div>
                                            </telerik:RadAjaxPanel>
                                        </div>
                                        <div class="rfv">
                                            <asp:CustomValidator ID="rfvWhoAreYou" runat="server" resourcekey="rfvWhoAreYou"></asp:CustomValidator>
                                        </div>
                                        <fieldset>
                                    </div>
                            </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep5" runat="server">
                        <div class="row">
                            <div id="wizard-form-Step5" class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="lblStep5Title" runat="server" resourcekey="Step5Title"></asp:Label>
                                    </legend>
                                    <p class="introduction">
                                        <asp:Label ID="lblStep5Description" runat="server" resourcekey="Step5Description"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <div>
                                            <uc1:CountryStateCity ID="CountryStateCityEditMode" MultiSelect="False" runat="server"
                                                ValidationGroup="profile" ViewInEditMode="True" AddressRequired="True" />
                                        </div>

                                        <div class="rfv">
                                            <asp:CustomValidator ID="rfvAddress" runat="server" resourcekey="rfvAddress"></asp:CustomValidator>
                                        </div>
                                    </div>

                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep6" runat="server">
                        <div class="row">
                            <div id="wizard-form-Step" class="wizard-form">
                                <fieldset runat="server" id="fsCreateUser" visible="False">
                                    <legend>
                                        <asp:Label ID="lblStep6Title" runat="server" resourcekey="Step6Title"></asp:Label>
                                    </legend>
                                    <p class="introduction">
                                        <asp:Label ID="lblStep6Description" runat="server" resourcekey="Step6Description"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblEmailTitle" runat="server" resourcekey="EmailTitle"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox ID="txtEmail" runat="server" Enabled="true"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <asp:RequiredFieldValidator ID="rvEmail" runat="server" ControlToValidate="txtEmail"
                                                resourcekey="rfvtxtEmail"></asp:RequiredFieldValidator>
                                            <asp:RegularExpressionValidator ID="rgvEmail" ControlToValidate="txtEmail" runat="server"
                                                ErrorMessage="" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"></asp:RegularExpressionValidator>
                                            <asp:CustomValidator ID="rfvExistingMail" runat="server" ErrorMessage="" resourcekey="ExistingMail"></asp:CustomValidator>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblFirstNameTitle" runat="server" resourcekey="FirstNameTitle"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox ID="txtFirstName" runat="server" Enabled="true" onfocus="Focus(this.id,'this is a test')"
                                                onblur="Blur(this.id,'this is a test')"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <asp:RequiredFieldValidator ID="rvFirstName" runat="server" ControlToValidate="txtFirstName"
                                                resourcekey="rfvtxtFirstName"></asp:RequiredFieldValidator>
                                            <asp:RegularExpressionValidator ID="rgvtxtFirstName" runat="server" SetFocusOnError="True" 
                                                ControlToValidate="txtFirstName" ValidationExpression="^[a-zA-Z'.\s]{1,100}$">
                                            </asp:RegularExpressionValidator>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblLastNameTitle" runat="server" resourcekey="LastNameTitle"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox ID="txtLastName" runat="server" Enabled="true"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <asp:RequiredFieldValidator ID="rvLastName" runat="server" ControlToValidate="txtLastName"
                                                resourcekey="rfvtxtLastName"></asp:RequiredFieldValidator>
                                            <asp:RegularExpressionValidator ID="rgvtxtLastName" runat="server" SetFocusOnError="True"
                                                ControlToValidate="txtLastName" ValidationExpression="^[a-zA-Z'.\s]{1,100}$">
                                            </asp:RegularExpressionValidator>
                                        </div>
                                    </div>
                                    <div class="field" id="pnlPassword" runat="server" visible="true">
                                        <label>
                                            <asp:Label ID="lblPasswordTitle" runat="server" resourcekey="PasswordTitle"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox TextMode="Password" ID="txtPassword" runat="server" Enabled="true"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <asp:RequiredFieldValidator ID="rvPassword" runat="server" ControlToValidate="txtPassword"
                                                resourcekey="rfvtxtPassword"></asp:RequiredFieldValidator>
                                            <asp:RegularExpressionValidator ID="rgvPassword" ControlToValidate="txtPassword"
                                                runat="server" ErrorMessage="" ValidationExpression="^[\s\S]{7,20}$"></asp:RegularExpressionValidator>
                                        </div>
                                    </div> 
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblTermsAndConditions" runat="server" resourcekey="TermsAndConditions"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:CheckBox ID="chkTerms" runat="server" AutoPostBack="False" OnClick="UpdateValidator(this.checked);" />
                                            <asp:Label ID="lblAcceptTerms" runat="server" resourcekey="AcceptTerms"></asp:Label>
                                        </div>
                                        <div class="rfv">
                                            <asp:CustomValidator ID="rfvTermsValidator" ClientValidationFunction="ValidateTerms" Display="Dynamic"
                                                runat="server" resourcekey="rfvTermAndContiditions"></asp:CustomValidator>
                                        </div>
                                    </div>
                                </fieldset>
                                <fieldset runat="server" id="fsExistingUser" visible="False">
                                    <legend>
                                        <asp:Label ID="lblStep6TitleAlt" runat="server" resourcekey="Step6TitleAlt"></asp:Label>
                                    </legend>
                                    <p class="introduction">
                                        <asp:Label ID="lblStep6DescriptionAlt" runat="server" resourcekey="Step6DescriptionAlt"></asp:Label>
                                    </p>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                </WizardSteps>
            </asp:Wizard>


        </ContentTemplate>
    </asp:UpdatePanel>
</div>
<script type="text/javascript">Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler); </script>
