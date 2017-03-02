<%@ Control Language="C#" AutoEventWireup="true" CodeFile="View.ascx.cs" Inherits="NZSolutionWizard_View" EnableViewState="true" %>
<link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css" rel="stylesheet">
<%@ Register Src="../NZSolution/NZSolution.ascx" TagName="NZSolution" TagPrefix="uc1" %>
<%@ Register Src="../NZOrganization/NZOrganization.ascx" TagName="NZOrganization" TagPrefix="uc2" %>
<%@ Register Src="../NXOtherControls/CountryStateCityV2.ascx" TagName="CountryStateCity" TagPrefix="uc3" %>
<%@ Register Src="../NXOtherControls/FileUploaderWizard.ascx" TagName="FileUploaderWizard" TagPrefix="uc4" %>
<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<%@ Register TagPrefix="dnn" Namespace="DotNetNuke.Web.Client.ClientResourceManagement" Assembly="DotNetNuke.Web.Client" %>

<link href="<%=ControlPath%>css/jquery.alerts.css" rel="stylesheet" />
<link href="<%=ControlPath%>css/module.css" rel="stylesheet" />
<script src="<%=ControlPath%>js/jquery.alerts.js"></script>
<script src="<%=ControlPath%>js/module.js"></script>
<script src="<%=ControlPath%>js/jquery.uniform.min.js"></script>
<script src="<%=ControlPath%>js/jquery.maxlength.js"></script>

<div class="solution-wizard">
    <div class="content-wrapper">
        <h1>
            <asp:Label runat="server" ID="lblMessage" resourcekey="lblMessage" Visible="false"></asp:Label></h1>
    </div>

    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:LinkButton ID="btnDeleteSolution" runat="server" CssClass="deleteButton" OnClientClick="if(!DeleteConfirmation()) return false;" CausesValidation="False"><i class="fa fa-trash-o fa-3x"></i></asp:LinkButton>
            <asp:HyperLink ID="hlkOpenPopUp" CssClass="openPopUp" runat="server" CausesValidation="False" resourcekey="btnReUse"></asp:HyperLink>
            <asp:HiddenField ID="doPane" runat="server" />
            <asp:HiddenField ID="HiddenFieldCurrentWords" runat="server" />
            <asp:Wizard Width="100%" ID="Wizard1" runat="server" ActiveStepIndex="0" OnFinishButtonClick="Wizard1_FinishButtonClick"
                DisplaySideBar="false" OnNextButtonClick="Wizard1_NextButtonClick" OnPreviousButtonClick="Wizard1_PreviousButtonClick"
                OnActiveStepChanged="Wizard1_ActiveStepChanged">
                <HeaderTemplate>
                    <div class="banner">
                        <div class="row">
                            <div class="step-navigation">
                                <h1>
                                    <asp:Label ID="Label59" runat="server" resourcekey="WizardTitle"></asp:Label>
                                </h1>
                                <ul id="header" class="clearfix">
                                    <asp:Repeater ID="repSideBarList" runat="server" OnItemDataBound="SideBarList_ItemDataBound">
                                        <ItemTemplate>
                                            <li id="Li1" runat="server" class="<%# GetClassBanner()%>">

                                                <asp:LinkButton CssClass="<%# GetClassForWizardStep(Container.DataItem) %>" ID="LinkButton1" Enabled='<%# EnableLinkButton() %>'
                                                    OnClick="Jump_Click" runat="server"><%# Eval("Name")%></asp:LinkButton>
                                            </li>
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
                            <div class="Counter">
                                <div class="GlobalCounterContainer">
                                </div>
                                <div class="Logo">
                                    <asp:Image runat="server" ID="imgWizardStep0" />
                                </div>
                            </div>
                            <div id="wizard-form-Step0" class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="lblBlockTitle" runat="server"></asp:Label>
                                    </legend>
                                    <p class="introduction">
                                        <asp:Label ID="lblBlockTitleDesc" runat="server"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblSubmissionTitle" runat="server"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox TextMode="SingleLine" ID="txtSubmissionTitle" runat="server" CssClass="maxlength"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <asp:RequiredFieldValidator class="rfv" ID="RequiredFieldValidator1" runat="server"
                                                ControlToValidate="txtSubmissionTitle" resourcekey="rfvtxtSubmissionTitle"></asp:RequiredFieldValidator>

                                            <asp:RegularExpressionValidator ID="rgvtxtSubmissionTitle" runat="server" SetFocusOnError="True"
                                                ControlToValidate="txtSubmissionTitle" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*">
                                            </asp:RegularExpressionValidator>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="lblSubmissionTitleDesc" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field last">
                                        <label>
                                            <asp:Label ID="lblShortDescription" runat="server"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox TextMode="MultiLine" ID="txtShortDescription" runat="server" CssClass="maxlength"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <asp:RequiredFieldValidator class="rfv" ID="RequiredFieldValidator3" runat="server"
                                                ControlToValidate="txtShortDescription" resourcekey="rfvtxtShortDescription"></asp:RequiredFieldValidator>
                                            <asp:RegularExpressionValidator ID="rgvtxtShortDescription" runat="server" SetFocusOnError="True" 
                                                ControlToValidate="txtShortDescription" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*">
                                            </asp:RegularExpressionValidator>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="lblShortDescriptionDesc" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                    <div id="pnlVerification" runat="server" visible="False">
                                        <asp:Label ID="lblVerification" runat="server" resourcekey="Verification"></asp:Label>
                                    </div>
                                </fieldset>
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="lblBlockBasicDetails" runat="server" resourcekey="BlockBasicDetails"></asp:Label>
                                    </legend>
                                    <p class="introduction">
                                        <asp:Label ID="lblBlockBasicDetailsDesc" runat="server" resourcekey="BlockBasicDetailsDesc"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblOrganizationAttached" runat="server"></asp:Label>
                                        </label>
                                        <div>

                                            <telerik:RadComboBox runat="server" ID="RadAutoCompleteBox1" AllowCustomText="True" SortCaseSensitive="false" MarkFirstMatch="true"
                                                AutoPostBack="True" EnableVirtualScrolling="True" CausesValidation="False" OnSelectedIndexChanged="RadAutoCompleteBox1_SelectedIndexChanged" EnableScreenBoundaryDetection="false" ExpandDirection="Down"
                                                OnTextChanged="RadAutoCompleteBox1_TextChanged" Filter="Contains">
                                            </telerik:RadComboBox>
                                        </div>
                                        <div class="rfv">
                                            <asp:RequiredFieldValidator class="rfv" ID="RequiredFieldValidator2" runat="server"
                                                ControlToValidate="RadAutoCompleteBox1" resourcekey="rfvRadAutoCompleteBox1"></asp:RequiredFieldValidator>
                                            <asp:HiddenField ID="hfSelectedOrg" runat="server"></asp:HiddenField>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="lblOrganizationAttachedDesc" runat="server"></asp:Label>
                                        </div>
                                        <div runat="server" id="pnlOrganization" visible="False">

                                            <div>
                                                <uc2:NZOrganization ID="NZOrganization1" runat="server" />
                                            </div>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep1" runat="server">
                        <div class="row">
                            <div class="Counter">
                                <div class="GlobalCounterContainer">
                                </div>
                                <div class="Logo">
                                    <asp:Image runat="server" ID="imgWizardStep1" />
                                </div>
                            </div>
                            <div id="wizard-form-Step1" class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="lblBlockProblem" runat="server"></asp:Label></legend>
                                    <p class="introduction">
                                        <asp:Label ID="lblBlockProblemDesc" runat="server"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblChallenge" runat="server"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox TextMode="MultiLine" ID="txtChallenge" runat="server" CssClass="maxlength"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <asp:RequiredFieldValidator class="rfv" ID="RequiredFieldValidator4" runat="server"
                                                ControlToValidate="txtChallenge" resourcekey="rfvtxtChallenge"></asp:RequiredFieldValidator>
                                            <asp:RegularExpressionValidator ID="rgvtxtChallenge" runat="server" SetFocusOnError="True"
                                                ControlToValidate="txtChallenge" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*">
                                            </asp:RegularExpressionValidator>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="lblChallengeDesc" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field checkbox">
                                        <label>
                                            <asp:Label ID="lblTheme" runat="server"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:CheckBoxList ID="cblTheme" DataTextField="Label" DataValueField="Key" RepeatColumns="3"
                                                runat="server" onClick="CheckValidateOnClick('cblTheme', 'cvcblTheme')">
                                            </asp:CheckBoxList>
                                            <div class="rfv">
                                                <asp:CustomValidator runat="server" ID="cvcblTheme" ClientValidationFunction="ValidateChk"
                                                    resourcekey="rfvtxtTheme"></asp:CustomValidator>
                                            </div>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="lblThemeDesc" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep2" runat="server">
                        <div class="row">
                            <div class="Counter">
                                <div class="GlobalCounterContainer">
                                </div>
                                <div class="Logo">
                                    <asp:Image runat="server" ID="imgWizardStep2" />
                                </div>
                            </div>
                            <div id="wizard-form-Step2" class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="lblBlockInnovation" runat="server"></asp:Label>
                                    </legend>
                                    <p class="introduction">
                                        <asp:Label ID="lblBlockInnovationDesc" runat="server"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblApproach" runat="server"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox TextMode="MultiLine" ID="txtApproach" runat="server" CssClass="maxlength"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <asp:RequiredFieldValidator class="rfv" ID="RequiredFieldValidator5" runat="server"
                                                ControlToValidate="txtApproach" resourcekey="rfvtxtApproach"></asp:RequiredFieldValidator>
                                            <asp:RegularExpressionValidator ID="rgvtxtApproach" runat="server" SetFocusOnError="True"
                                                ControlToValidate="txtApproach" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*">
                                            </asp:RegularExpressionValidator>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="lblApproachDesc" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field checkbox">
                                        <label>
                                            <asp:Label ID="lblBeneficiaries" runat="server"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:CheckBoxList ID="cblBeneficiaries" DataTextField="Label" DataValueField="Key"
                                                RepeatColumns="3" runat="server" onClick="CheckValidateOnClick('cblBeneficiaries', 'cvcblBeneficiaries')">
                                            </asp:CheckBoxList>
                                            <div class="rfv">
                                                <asp:CustomValidator runat="server" ID="cvcblBeneficiaries" ClientValidationFunction="ValidateChk"
                                                    resourcekey="rfvtxtBeneficiaries"></asp:CustomValidator>
                                               
                                            </div>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="lblBeneficiariesDesc" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep3" runat="server">
                        <div class="row">
                            <div class="Counter">
                                <div class="GlobalCounterContainer">
                                </div>
                                <div class="Logo">
                                    <asp:Image runat="server" ID="imgWizardStep3" />
                                </div>
                            </div>
                            <div id="wizard-form-Step3" class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="lblBlockBenefits" runat="server"></asp:Label></legend>
                                    <p class="introduction">
                                        <asp:Label ID="lblBlockBenefitsDesc" runat="server"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblResults" runat="server"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox TextMode="MultiLine" ID="txtResults" runat="server" CssClass="maxlength"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <asp:RequiredFieldValidator class="rfv" ID="RequiredFieldValidator6" runat="server"
                                                ControlToValidate="txtResults" resourcekey="rfvtxtResults"></asp:RequiredFieldValidator>
                                             <asp:RegularExpressionValidator ID="rgvtxtResults" runat="server" SetFocusOnError="True"
                                                ControlToValidate="txtResults" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*">
                                            </asp:RegularExpressionValidator>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="lblResultsDesc" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field checkbox">
                                        <label>
                                            <asp:Label ID="lblDeliveryFormat" runat="server"></asp:Label></label>
                                        <div>
                                            <asp:CheckBoxList ID="cblDeliveryFormat" DataTextField="Label" DataValueField="Key"
                                                RepeatColumns="3" runat="server" onClick="CheckValidateOnClick('cblDeliveryFormat', 'cvcblDeliveryFormat')">
                                            </asp:CheckBoxList>
                                            <div class="rfv">
                                                <asp:CustomValidator runat="server" ID="cvcblDeliveryFormat" ClientValidationFunction="ValidateChk"
                                                    resourcekey="rfvtxtDeliveryFormat"></asp:CustomValidator>
                                            </div>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="lblDeliveryFormatDesc" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep4" runat="server">
                        <div class="row">
                            <div class="Counter">
                                <div class="GlobalCounterContainer">
                                </div>
                                <div class="Logo">
                                    <asp:Image runat="server" ID="imgWizardStep4" />
                                </div>
                            </div>
                            <div id="wizard-form-Step4" class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="lblBlockDetails" runat="server"></asp:Label></legend>
                                    <p class="introduction">
                                        <asp:Label ID="lblBlockDetailsDesc" runat="server"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblImplementationDetails" runat="server"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox ID="txtImplementationDetails" runat="server" TextMode="MultiLine" CssClass="maxlength"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <asp:RequiredFieldValidator class="rfv" ID="RequiredFieldValidator12" runat="server"
                                                ControlToValidate="txtImplementationDetails" resourcekey="rfvtxtImplementationDetails"></asp:RequiredFieldValidator>
                                               <asp:RegularExpressionValidator ID="rgvtxtImplementationDetails" runat="server" SetFocusOnError="True"
                                                ControlToValidate="txtImplementationDetails" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*">
                                            </asp:RegularExpressionValidator>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="lblImplementationDetailsDesc" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                    <div runat="server" id="pnlLongDescription" class="field" visible="false">
                                        <label>
                                            <asp:Label ID="lblLongDescription" runat="server" resourcekey="LongDescription"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox TextMode="MultiLine" ID="txtLongDescription" runat="server" CssClass="maxlength"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <asp:RequiredFieldValidator class="rfv" ID="RequiredFieldValidator13" runat="server"
                                                ControlToValidate="txtLongDescription" resourcekey="rfvtxtLongDescription"></asp:RequiredFieldValidator>
                                              <asp:RegularExpressionValidator ID="rgvtxtLongDescription" runat="server" SetFocusOnError="True"
                                                ControlToValidate="txtLongDescription" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*">
                                            </asp:RegularExpressionValidator>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="lblLongDescriptionDesc" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label runat="server" id="lblHtmlCostTitle" visible="false">
                                            <asp:Label ID="lblCost" runat="server" resourcekey="Cost"></asp:Label>
                                        </label>
                                        <div runat="server" id="pnlCostSelect" visible="false">
                                            <asp:DropDownList ID="ddlCost" DataTextField="Label" DataValueField="Value" runat="server">
                                            </asp:DropDownList>
                                        </div>
                                        <label>
                                            <asp:Label ID="lblCostValue" runat="server"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox ID="txtCost" runat="server"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <asp:RequiredFieldValidator class="rfv" ID="RequiredFieldValidator7" runat="server"
                                                ControlToValidate="txtCost" resourcekey="rfvtxtCost"></asp:RequiredFieldValidator>

                                        </div>
                                        <div class="rfv">
                                            <asp:RegularExpressionValidator ControlToValidate="txtCost" ID="RegularExpressionValidator1"
                                                runat="server" resourcekey="revtxtCost" ValidationExpression="^\$?[0-9]+(\,[0-9]{3})*(.[0-9]{2})?$"></asp:RegularExpressionValidator>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="lblCostDesc" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblCostDetails" runat="server"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox TextMode="MultiLine" ID="txtCostDetails" runat="server" CssClass="maxlength"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <asp:RequiredFieldValidator class="rfv" ID="RequiredFieldValidator8" runat="server"
                                                ControlToValidate="txtCostDetails" resourcekey="rfvtxtCostDetails"></asp:RequiredFieldValidator>
                                            <asp:RegularExpressionValidator ID="rgvtxtCostDetails" runat="server" SetFocusOnError="True"
                                                ControlToValidate="txtCostDetails" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*">
                                            </asp:RegularExpressionValidator>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="lblCostDetailsDesc" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblProjectDuration" runat="server"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:DropDownList ID="ddlProjectDuration" DataValueField="Value" DataTextField="Label"
                                                runat="server" OnDataBinding="ddProjectDuration_DataBinding">
                                            </asp:DropDownList>
                                        </div>
                                        <div class="rfv">
                                            <asp:RequiredFieldValidator class="rfv" ID="RequiredFieldValidator11" runat="server"
                                                ControlToValidate="ddlProjectDuration" resourcekey="rfvddProjectDuration" InitialValue="0"></asp:RequiredFieldValidator>

                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="lblProjectDurationDesc" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblDurationDetails" runat="server"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox TextMode="MultiLine" ID="txtDurationDetails" runat="server" CssClass="maxlength"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <asp:RequiredFieldValidator class="rfv" ID="RequiredFieldValidator9" runat="server"
                                                ControlToValidate="txtDurationDetails" resourcekey="rfvtxtDurationDetails"></asp:RequiredFieldValidator>
                                             <asp:RegularExpressionValidator ID="rgvtxtDurationDetails" runat="server" SetFocusOnError="True"
                                                ControlToValidate="txtDurationDetails" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*">
                                            </asp:RegularExpressionValidator>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="lblDurationDetailsDesc" runat="server"></asp:Label>
                                        </div>
                                    </div>


                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep5" runat="server">
                        <div class="row">
                            <div class="Counter">
                                <div class="GlobalCounterContainer">
                                </div>
                                <div class="Logo">
                                    <asp:Image runat="server" ID="imgWizardStep5" />
                                </div>
                            </div>
                            <div id="wizard-form-Step5" class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="lblBlockEvidences" runat="server"></asp:Label></legend>
                                    <p class="introduction">
                                        <asp:Label ID="lblBlockEvidencesDesc" runat="server"></asp:Label>
                                    </p>
                                    <div class="field rdControl">
                                        <label>
                                            <asp:Label ID="lblSupportDocuments" runat="server"></asp:Label>
                                        </label>
                                        <div>
                                            <uc4:FileUploaderWizard runat="server" Folder="/challenge/20141/public" DocumentDefaultMode="1" ID="fileSupportDocuments"></uc4:FileUploaderWizard>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="lblSupportDocumentsDesc" runat="server"></asp:Label>
                                        </div>
                                    </div>

                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblLocation" runat="server" resourcekey="Location"></asp:Label>
                                        </label>
                                        <div>
                                            <uc3:CountryStateCity AddressRequired="False" ViewInEditMode="True" MultiSelect="True" ID="CountryStateCityEditMode"
                                                runat="server" ValidationGroup="profile" />
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="lblLocationDesc" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep6" runat="server">
                        <div class="row">
                            <div class="Counter">
                                <div class="GlobalCounterContainer">
                                </div>
                                <div class="Logo">
                                    <asp:Image runat="server" ID="imgWizardStep6" />
                                </div>
                            </div>
                            <div id="wizard-form-Step6" class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="lblBlockFinish" runat="server"></asp:Label></legend>
                                    <p class="introduction">
                                        <asp:Label ID="lblBlockFinishDesc" runat="server"></asp:Label>
                                    </p>



                                </fieldset>
                                <div>
                                    <uc1:NZSolution ID="NZSolution1" runat="server" />
                                </div>
                                <div>
                                    <asp:CheckBox ID="chkPublicationApproval" Checked="true" resourcekey="chkPublicationApprovalCustom" Visible="false" runat="server" />
                                    <br />
                                </div>
                                <br />
                            </div>
                        </div>
                    </asp:WizardStep>
                </WizardSteps>
            </asp:Wizard>
            <div>
                <asp:Literal ID="pass" ViewStateMode="Disabled" runat="server"></asp:Literal>
            </div>
            <div id="doKeep" style="display: none;">
                <asp:Button ID="btnDoKeep" CausesValidation="false" runat="server" Text="Button" OnClick="btnDoKeep_Click" />
            </div>
            <div style="display: none;">
                <asp:Button ID="btnDelete" CausesValidation="false" runat="server" Text="Button" OnClick="btnDeleteSolution_OnClick" />
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
<asp:UpdateProgress ID="UpdateProgress1" runat="server" AssociatedUpdatePanelID="UpdatePanel1">
    <ProgressTemplate>
        <div class="loader">
            <img src='<%= Request.Url.AbsoluteUri.Replace(Request.Url.PathAndQuery,"")+ControlPath+"images/239.gif" %>' />
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>

<div id="dialog-modal">
    <asp:Label ID="lbHeader" runat="server"></asp:Label>
</div>



<link href="<%=ControlPath%>css/jquery.alerts.css" rel="stylesheet" />
<link href="<%=ControlPath%>css/module.css" rel="stylesheet" />
<script src="<%=ControlPath%>js/jquery.alerts.js"></script>
<script src="<%=ControlPath%>js/module.js"></script>
<script src="<%=ControlPath%>js/jquery.uniform.min.js"></script>
<script src="<%=ControlPath%>js/jquery.maxlength.js"></script>

<script type="text/javascript">

    function ValidateCheckBoxList(sender, args) {
        args.IsValid = false;
        $("#" + sender.id).parent().parent().find("table").find(":checkbox").each(function () {
            if ($(this).attr("checked")) {
                args.IsValid = true;
                return;
            }
        });
    }
        
    function onChangeVideo(id, element, sw ){
        var m = $("textarea[class*='words'");
        var n = $("input[class*='words'");
        count(m);
        count(n);

        var control= $("#"+id);
        if(sw)
            control = $("#"+element.id);
     

        if(typeof control.val() == 'undefined')
            return;
        var iframe = $("iframe[id*='video"+control.attr("id") +"'");
        if(iframe!= null)
            iframe.remove();

        if(control.val() != "")
        {
            var value=control.val();
           
            if(value.indexOf('www.youtube.com/embed/')>=0){
                if(value.indexOf('http')==-1){
                    value ="https://"+ control.val();
                }
                control.after("<iframe id='video"+ control.attr("id") +"' width=\"560\" height=\"315\" src='"+value+"' frameborder=\"0\" allowfullscreen></iframe>");
            }else{
                
                var url ="";
                var video_id = videoId(value,'v=');
                var base = "https://www.youtube.com/embed/";
                if(video_id != ""){
                    url = base + video_id;
                }
                else
                {
                    video_id = videoId(value,'youtu.be/');
                    if(video_id != ""){
                        url = base + video_id;
                    }
                    else
                    {
                        video_id = videoId(value,'vimeo.com/');
                        if(video_id != ""){

                            url = "//player.vimeo.com/video/" + video_id;
                        }
                    
                    
                    }
                }

                if(url!=""){

                    control.after("<iframe id='video"+ control.attr("id") +"' width=\"560\" height=\"315\" src='"+url+"' frameborder=\"0\" allowfullscreen></iframe>");
                }
            }
        }
        
    };


    function videoId(url, par){
        var video_id = url.split(par)[1];

        if(typeof video_id != 'undefined'){

            var ampersandPosition = video_id.indexOf('&');
            if(ampersandPosition != -1) {
                video_id = video_id.substring(0, ampersandPosition);
            }

            return video_id;

        }else
            return "";
    
    }


    function Finish(text){
        $(function() {
            $( "#dialog-modal" ).dialog({
                height: 620,
                width: 1200,
                modal: true,
                dialogClass: "ui-dialog ui-widget ui-widget-content ui-corner-all ui-front dnnFormPopup ui-draggable ui-resizable"
            });
            $("div[aria-describedby*='dialog-modal'] > div[class*='titlebar'] > button[title*='close']").remove();
            $('#<%=lbHeader.ClientID%>').html(text);
            $("#dialog-modal").show();
           
        });
                
    }
 
    function setTop() {
        if (($('#<%=doPane.ClientID%>').val() != ''))
            location.href = '#dnn_ContentPane';
    }

    SetUniform();
    setInterval(function () { keepAlive(); }, 600000);
    $(document).ready(function () {
        $("#dialog-modal").hide();  
        setMaxLenght();
        setBackGround();
        SetShowHideSupportText();
        $('.connect-wizard .btn, .solution-wizard .btn').parents('table').attr('align', 'center');
        

        var m = $("textarea[class*='words'");
        var n = $("input[class*='words'");
        count(m);
        count(n);

    }
    );

 
    function count(m) {
        for (var i = 0; i < m.length; i++) {

            var s = document.getElementById(m[i].id);
            WordCount(s, -1);

        }

    }

    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);
    function EndRequestHandler(sender, args) {

        $('.connect-wizard .btn, .solution-wizard .btn').parents('table').attr('align', 'center');
        SetShowHideSupportText();

        setBackGround();
        setTop();
        SetUniform();
        setMaxLenght();

    }


    function setBackGround() {

        $('#divWizardStep0').css({ "background": "url(\"" + '<%=Request.Url.AbsoluteUri.Replace(Request.Url.PathAndQuery,"")+ControlPath+"images/WizardHeader0." + System.Threading.Thread.CurrentThread.CurrentCulture.ToString()+".png"%>' + "\") top left no-repeat" });
    }
    function setMaxLenght() {


        adjustGlobalCounter(parseInt($('#<%=HiddenFieldCurrentWords.ClientID%>').val()));

        $('#<%=txtSubmissionTitle.ClientID%>').maxlength($.extend({ max: 8, counterType: 'word' }, languages['<%=System.Threading.Thread.CurrentThread.CurrentCulture.ToString() %>']));
        $('#<%=txtShortDescription.ClientID%>').maxlength($.extend({ max: 32, counterType: 'word' }, languages['<%=System.Threading.Thread.CurrentThread.CurrentCulture.ToString() %>']));
        $('#<%=txtChallenge.ClientID%>').maxlength($.extend({ max: 75, counterType: 'word' }, languages['<%=System.Threading.Thread.CurrentThread.CurrentCulture.ToString() %>']));
        $('#<%=txtApproach.ClientID%>').maxlength($.extend({ max: 75, counterType: 'word' }, languages['<%=System.Threading.Thread.CurrentThread.CurrentCulture.ToString() %>']));
        $('#<%=txtResults.ClientID%>').maxlength($.extend({ max: 75, counterType: 'word' }, languages['<%=System.Threading.Thread.CurrentThread.CurrentCulture.ToString() %>']));
        $('#<%=txtLongDescription.ClientID%>').maxlength($.extend({ max: 60, counterType: 'word' }, languages['<%=System.Threading.Thread.CurrentThread.CurrentCulture.ToString() %>']));
        $('#<%=txtCostDetails.ClientID%>').maxlength($.extend({ max: 50, counterType: 'word' }, languages['<%=System.Threading.Thread.CurrentThread.CurrentCulture.ToString() %>']));
        $('#<%=txtDurationDetails.ClientID%>').maxlength($.extend({ max: 50, counterType: 'word' }, languages['<%=System.Threading.Thread.CurrentThread.CurrentCulture.ToString() %>']));
        $('#<%=txtImplementationDetails.ClientID%>').maxlength($.extend({ max: <%=GetMaxLenght("txtImplementationDetails")%>, counterType: 'word' }, languages['<%=System.Threading.Thread.CurrentThread.CurrentCulture.ToString() %>']));


        //        $('#<%= NZOrganization1.BioClientID%>').maxlength($.extend({ max: 75, truncate: false, counterType: 'word' }, languages['<%=System.Threading.Thread.CurrentThread.CurrentCulture.ToString() %>']));

        countGlobal(languages['<%=System.Threading.Thread.CurrentThread.CurrentCulture.ToString() %>'].globalCounterText);

    }

    function keepAlive() {
        document.getElementById('<%=btnDoKeep.ClientID%>').click()
    }

    function CheckValidateOnClick(check, customValidator) {
        var chk = null;
        var customValidate = null;
        if (check == "cblTheme") {
            chk = '<%= cblTheme.ClientID %>'; customValidate = '<%= cvcblTheme.ClientID %>';
        }
        if (check == "cblBeneficiaries") {
            chk = '<%= cblBeneficiaries.ClientID %>'; customValidate = '<%= cvcblBeneficiaries.ClientID %>';
        }
        if (check == "cblDeliveryFormat") {
            chk = '<%= cblDeliveryFormat.ClientID %>'; customValidate = '<%= cvcblDeliveryFormat.ClientID %>';
        }


        var chkListinputs = document.getElementById(chk).getElementsByTagName("input");
        var customValidator = document.getElementById(customValidate);
        var maxChecked = 0;

        for (var i = 0; i < chkListinputs.length; i++) {
            if (chkListinputs[i].checked) {
                maxChecked++;

            }
        }

        if (maxChecked >= 1 && maxChecked <= 3) {
            customValidator.style.visibility = 'hidden';
        }
        else {
            customValidator.style.visibility = 'visible';
        }
    }

    function ValidateChk(source, args) {

        var check = null;
        if (source.id == '<%= cvcblTheme.ClientID %>') {
            check = '<%= cblTheme.ClientID %>';
        }
        if (source.id == '<%= cvcblBeneficiaries.ClientID %>') {
            check = '<%= cblBeneficiaries.ClientID %>';
        }
        if (source.id == '<%= cvcblDeliveryFormat.ClientID %>') {
            check = '<%= cblDeliveryFormat.ClientID %>';
        }


        var chkListinputs = document.getElementById(check).getElementsByTagName("input");
        var maxChecked = 0;

        for (var i = 0; i < chkListinputs.length; i++) {
            if (chkListinputs[i].checked) {

                maxChecked++;
            }
        }


        if (maxChecked >= 1 && maxChecked <= 3) {
            args.IsValid = true;
        }
        else {
            args.IsValid = false;
        }
    }
    function DeleteConfirmation() {
        var messageConfirmation = '<%=Localization.GetString("ConfirmationDelete", this.LocalResourceFile)%>';
        var title = '<%=Localization.GetString("TitlePopUp", this.LocalResourceFile)%>';
        $.alerts.okButton = '<%=Localization.GetString("btnOk", this.LocalResourceFile)%>';
        $.alerts.cancelButton = '<%=Localization.GetString("btnCancel", this.LocalResourceFile)%>';

        jConfirm(messageConfirmation, title, function (r) {
            if (r)
                document.getElementById('<%=btnDelete.ClientID%>').click();
        });

    }



    $(window).keypress(function (e) {
        var ListTextArea = $("textarea");
        var sw= false;
        for (var i = 0; i < ListTextArea.length; i++) {
            if(e.target == ListTextArea[i]){
                sw = true;
            }
        }

        if(!sw){
            if (e.keyCode == 13) {
                return false;
            }
        }
    
    });

    function addHeaderClass(headerClass) {
        $("ul[id*='header']").addClass(headerClass);
    }

    

    function WordCount(obj, limit) {

        var txt = obj.value.replace(/[-'`~!@#$%^&*()_|+=?;:'",.<>\{\}\[\]\\\/]/gi, "");
        var words = "";
        if (txt != "") {
            words = txt.match(/\S+/g).length;
        } else {
            words = 0;
        }

        var lengthText = words;
        var id = obj.id.split("_");
        var textMessage = $("span[id*='words" + id[id.length - 1] + "']").text();
        var txt = "<%= Localization.GetString("Maxlength", LocalResourceFile)%>";
        if (parseInt(limit) >= 0) {
            if (words > parseInt(limit)) {
                // Split the string on first limit words and rejoin on spaces
                var trimmed = $(obj).val().split(/\s+/, limit).join(" ");
                // Add a space at the end to make sure more typing creates new words
                $(obj).val(trimmed + " ");
                lengthText = limit;
            }
            $("span[id*='words" + id[id.length - 1] + "']").text(txt.replace("{m}", limit).replace("{r}", lengthText));

        } else {
            var textLimit = textMessage.split(/\s+/);
            var txtReplace = textMessage.replace(textLimit[0], words);
            $("span[id*='words" + id[id.length - 1] + "']").text(txtReplace);
        }
    }

    
</script>