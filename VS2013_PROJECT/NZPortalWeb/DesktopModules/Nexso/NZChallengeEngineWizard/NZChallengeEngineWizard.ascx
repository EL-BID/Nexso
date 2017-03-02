<%@ Control Language="C#" AutoEventWireup="true" CodeFile="NZChallengeEngineWizard.ascx.cs"
    Inherits="NZChallengeEngineWizard" %>
<%--<%@ Register Assembly="CuteEditor" Namespace="CuteEditor" TagPrefix="CE" %>--%>
<%--<%@ Register Assembly="RichTextEditor" Namespace="RTE" TagPrefix="RTE" %>--%>
<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<%@ Register Src="../NXOtherControls/FileUploaderWizard.ascx" TagName="FileUploaderWizard"
    TagPrefix="uc4" %>

<script src="<%=ControlPath%>js/jquery.maxlength.js"></script>
<script src="<%=ControlPath%>js/jquery.alerts.js"></script>
<link href="<%=ControlPath%>css/jquery.alerts.css" rel="stylesheet" />
<link href="<%=ControlPath%>css/Module.css" rel="stylesheet" />
<script src="https://cdnjs.cloudflare.com/ajax/libs/prefixfree/1.0.7/prefixfree.min.js"></script>
<link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css" rel="stylesheet">

<div class="mailer-form">
    <div class="content-wrapper">
        <h1>
            <asp:Label runat="server" ID="lblMessage" resourcekey="lblMessage" Visible="false"></asp:Label></h1>
    </div>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">

        <ContentTemplate>
            
            <asp:Wizard Width="100%" ID="wizardChallengeEngine" runat="server" ActiveStepIndex="0" OnFinishButtonClick="wizardChallengeEngine_FinishButtonClick" CssClass="wizardChallenge"
                DisplaySideBar="false" OnNextButtonClick="wizardChallengeEngine_NextButtonClick" OnPreRender="WizardChallengeEngine_PreRender">
                <HeaderTemplate>
                    <div class="banner">
                        <div class="row">
                            <div class="step-navigation">
                                <h1>
                                    <asp:Label ID="Label59" runat="server" resourcekey="WizardTitle"></asp:Label>
                                </h1>
                                <ul id="header" class="clearfix">
                                    <asp:Repeater ID="SideBarList" runat="server" OnDataBinding="SideBarList_DataBinding"
                                        OnItemDataBound="SideBarList_ItemDataBound">
                                        <ItemTemplate>
                                            <li>
                                                <asp:LinkButton CssClass="<%# GetClassForWizardStep(Container.DataItem) %>" ID="LinkButton1"
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
                            <div id="wizard-form-Step0" class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="BlockTimeLine" runat="server" resourcekey="BlockTimeLine"></asp:Label>
                                    </legend>
                                    <p class="introduction">
                                        <asp:Label ID="BlockTimeLineDesc" runat="server" resourcekey="BlockTimeLineDesc"></asp:Label>
                                    </p>
                                    <div class="field">

                                        <label>
                                            <asp:Label ID="lblChallengeReference" runat="server" resourcekey="lblChallengeReference"></asp:Label>
                                        </label>
                                        <div class="RadCombo">
                                            <telerik:radcombobox id="rdChallengeReference" runat="server" datatextfield="ChallengeReference" width="100%" onselectedindexchanged="RadComboBox_SelectedIndexChanged"
                                                cssclass="radInput" datavaluefield="ChallengeReference" allowcustomtext="true" autopostback="true">
                                             </telerik:radcombobox>
                                        </div>
                                        <div class="rfv">
                                            <asp:RequiredFieldValidator class="rfv" ID="rfvrdChallengeReference" runat="server"
                                                ControlToValidate="rdChallengeReference" resourcekey="rfvrdChallengeReference"></asp:RequiredFieldValidator>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="ChallengeReferenceDesc" runat="server" resourcekey="ChallengeReferenceDesc"></asp:Label>
                                        </div>

                                    </div>
                                    <div runat="server" id="dvNewChallenge" visible="false">
                                        <div class="field">

                                            <label>
                                                <asp:Label ID="lblChallengeReference2" runat="server" resourcekey="lblChallengeReference"></asp:Label>
                                            </label>
                                            <div>
                                                <asp:TextBox runat="server" ID="txtChallengeReference" OnTextChanged="txtChallengeReference_TextChanged" AutoPostBack="true"></asp:TextBox>
                                            </div>
                                            <div class="rfv">
                                                <asp:RequiredFieldValidator class="rfv" ID="rfvtxtChallengeReference" runat="server"
                                                    ControlToValidate="txtChallengeReference" resourcekey="rfvtxtChallengeReference"></asp:RequiredFieldValidator>
                                                <asp:CustomValidator ID="cvrfvtxtChallengeReference" runat="server" ControlToValidate="txtChallengeReference" ClientValidationFunction="validateChallengeReference"
                                                    resourcekey="cvrfvtxtChallengeReference"></asp:CustomValidator>
                                                <asp:RegularExpressionValidator runat="server" ID="revtxtChallengeReference" ControlToValidate="txtChallengeReference"
                                                    resourcekey="revtxtChallengeReference" ValidationExpression="^[A-Z0-9a-z]*$"></asp:RegularExpressionValidator>
                                            </div>
                                            <div class="support-text">
                                                <asp:Label ID="ChallengeReference2Desc" runat="server" resourcekey="ChallengeReference2Desc"></asp:Label>
                                            </div>

                                        </div>
                                    </div>
                                    <div runat="server" id="dvChallenge" visible="false">
                                        <div class="field">
                                            <label>
                                                <asp:Label ID="lblChallengeTitle" runat="server" resourcekey="lblChallengeTitle"></asp:Label>
                                            </label>
                                            <div>
                                                <asp:TextBox runat="server" ID="txtChallengeTitle"></asp:TextBox>
                                            </div>

                                        </div>
                                        <div class="field">
                                            <label>
                                                <asp:Label ID="lblLanguage" runat="server" resourcekey="lblLanguage"></asp:Label>
                                            </label>
                                            <div class="RadCombo">
                                                <telerik:radcombobox id="rdLanguage" runat="server" datatextfield="Label" width="100%" onselectedindexchanged="rdLanguage_SelectedIndexChanged"
                                                    cssclass="radInput" datavaluefield="Key" allowcustomtext="true" enablecheckallitemscheckbox="true" autopostback="true">
                                             </telerik:radcombobox>
                                            </div>
                                            <div class="rfv">
                                                <asp:RequiredFieldValidator class="rfv" ID="rfvLanguage" runat="server"
                                                    ControlToValidate="rdLanguage" resourcekey="rfvrdLanguage"></asp:RequiredFieldValidator>
                                            </div>
                                            <div class="support-text">
                                                <asp:Label ID="LanguageDesc" runat="server"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="field box">
                                            <label>
                                                <asp:Label runat="server" ID="lblPreLaunch" resourcekey="lblPreLaunch"></asp:Label>
                                            </label>
                                            <div>
                                                <telerik:raddatetimepicker runat="server" id="rdPreLaunch">
                                                        <TimeView CellSpacing="-1">
                                                        </TimeView>
                                                        <TimePopupButton CssClass="" HoverImageUrl="" ImageUrl="" />
                                                        <Calendar EnableWeekends="True" UseColumnHeadersAsSelectors="False" UseRowHeadersAsSelectors="False">
                                                        </Calendar>
                                                        <DateInput DateFormat="M/d/yyyy" DisplayDateFormat="M/d/yyyy" LabelWidth="64px" Width="">
                                                            <EmptyMessageStyle Resize="None" />
                                                            <ReadOnlyStyle Resize="None" />
                                                            <FocusedStyle Resize="None" />
                                                            <DisabledStyle Resize="None" />
                                                            <InvalidStyle Resize="None" />
                                                            <HoveredStyle Resize="None" />
                                                            <EnabledStyle Resize="None" />
                                                        </DateInput>
                                                        <DatePopupButton CssClass="" HoverImageUrl="" ImageUrl="" />
                                                    </telerik:raddatetimepicker>
                                            </div>
                                            <div class="support-text">
                                                <asp:Label ID="PreLaunchDesc" runat="server" resourcekey="PreLaunchDesc"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="field box">
                                            <label>
                                                <asp:Label runat="server" ID="lblLaunch" resourcekey="lblLaunch"></asp:Label>
                                            </label>
                                            <div>
                                                <telerik:raddatetimepicker runat="server" id="rdLaunch">
                                                        <TimeView CellSpacing="-1">
                                                        </TimeView>
                                                        <TimePopupButton CssClass="" HoverImageUrl="" ImageUrl="" />
                                                        <Calendar EnableWeekends="True" UseColumnHeadersAsSelectors="False" UseRowHeadersAsSelectors="False">
                                                        </Calendar>
                                                        <DateInput DateFormat="M/d/yyyy" DisplayDateFormat="M/d/yyyy" LabelWidth="64px" Width="">
                                                            <EmptyMessageStyle Resize="None" />
                                                            <ReadOnlyStyle Resize="None" />
                                                            <FocusedStyle Resize="None" />
                                                            <DisabledStyle Resize="None" />
                                                            <InvalidStyle Resize="None" />
                                                            <HoveredStyle Resize="None" />
                                                            <EnabledStyle Resize="None" />
                                                        </DateInput>
                                                        <DatePopupButton CssClass="" HoverImageUrl="" ImageUrl="" />
                                                    </telerik:raddatetimepicker>
                                            </div>
                                            <div class="support-text">
                                                <asp:Label ID="LaunchDesc" runat="server" resourcekey="LaunchDesc"></asp:Label>
                                            </div>
                                            <div class="rfv">
                                                <asp:RequiredFieldValidator class="rfv" ID="rfvrdLaunch" runat="server"
                                                    ControlToValidate="rdLaunch" resourcekey="rfvrdLaunch"></asp:RequiredFieldValidator>
                                            </div>
                                        </div>
                                        <div class="field box">
                                            <label>
                                                <asp:Label runat="server" ID="lblAvailableFrom" resourcekey="lblAvailableFrom"></asp:Label>
                                            </label>
                                            <div>
                                                <telerik:raddatetimepicker runat="server" id="rdAvailableFrom">
                                                        <TimeView CellSpacing="-1">
                                                        </TimeView>
                                                        <TimePopupButton CssClass="" HoverImageUrl="" ImageUrl="" />
                                                        <Calendar EnableWeekends="True" UseColumnHeadersAsSelectors="False" UseRowHeadersAsSelectors="False">
                                                        </Calendar>
                                                        <DateInput DateFormat="M/d/yyyy" DisplayDateFormat="M/d/yyyy" LabelWidth="64px" Width="">
                                                            <EmptyMessageStyle Resize="None" />
                                                            <ReadOnlyStyle Resize="None" />
                                                            <FocusedStyle Resize="None" />
                                                            <DisabledStyle Resize="None" />
                                                            <InvalidStyle Resize="None" />
                                                            <HoveredStyle Resize="None" />
                                                            <EnabledStyle Resize="None" />
                                                        </DateInput>
                                                        <DatePopupButton CssClass="" HoverImageUrl="" ImageUrl="" />
                                                    </telerik:raddatetimepicker>
                                            </div>
                                            <div class="support-text">
                                                <asp:Label ID="Label5" runat="server" resourcekey="SendOnDesc"></asp:Label>
                                            </div>
                                            <div class="rfv">
                                                <asp:RequiredFieldValidator class="rfv" ID="rfvrdAvailableFrom" runat="server"
                                                    ControlToValidate="rdAvailableFrom" resourcekey="rfvrdAvailableFrom"></asp:RequiredFieldValidator>
                                            </div>
                                        </div>
                                        <div class="field box">
                                            <label>
                                                <asp:Label runat="server" ID="lblAvailableTo" resourcekey="lblAvailableTo"></asp:Label>
                                            </label>
                                            <div>
                                                <telerik:raddatetimepicker runat="server" id="rdAvailableTo">
                                                        <TimeView CellSpacing="-1">
                                                        </TimeView>
                                                        <TimePopupButton CssClass="" HoverImageUrl="" ImageUrl="" />
                                                        <Calendar EnableWeekends="True" UseColumnHeadersAsSelectors="False" UseRowHeadersAsSelectors="False">
                                                        </Calendar>
                                                        <DateInput DateFormat="M/d/yyyy" DisplayDateFormat="M/d/yyyy" LabelWidth="64px" Width="">
                                                            <EmptyMessageStyle Resize="None" />
                                                            <ReadOnlyStyle Resize="None" />
                                                            <FocusedStyle Resize="None" />
                                                            <DisabledStyle Resize="None" />
                                                            <InvalidStyle Resize="None" />
                                                            <HoveredStyle Resize="None" />
                                                            <EnabledStyle Resize="None" />
                                                        </DateInput>
                                                        <DatePopupButton CssClass="" HoverImageUrl="" ImageUrl="" />
                                                    </telerik:raddatetimepicker>
                                            </div>
                                            <div class="support-text">
                                                <asp:Label ID="AvailableToDesc" runat="server" resourcekey="AvailableToDesc"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="field box2">
                                            <label>
                                                <asp:Label runat="server" ID="lblEval1From" resourcekey="lblEval1From"></asp:Label>
                                            </label>
                                            <div>
                                                <telerik:raddatetimepicker runat="server" id="rdEval1From">
                                                        <TimeView CellSpacing="-1">
                                                        </TimeView>
                                                        <TimePopupButton CssClass="" HoverImageUrl="" ImageUrl="" />
                                                        <Calendar EnableWeekends="True" UseColumnHeadersAsSelectors="False" UseRowHeadersAsSelectors="False">
                                                        </Calendar>
                                                        <DateInput DateFormat="M/d/yyyy" DisplayDateFormat="M/d/yyyy" LabelWidth="64px" Width="">
                                                            <EmptyMessageStyle Resize="None" />
                                                            <ReadOnlyStyle Resize="None" />
                                                            <FocusedStyle Resize="None" />
                                                            <DisabledStyle Resize="None" />
                                                            <InvalidStyle Resize="None" />
                                                            <HoveredStyle Resize="None" />
                                                            <EnabledStyle Resize="None" />
                                                        </DateInput>
                                                        <DatePopupButton CssClass="" HoverImageUrl="" ImageUrl="" />
                                                    </telerik:raddatetimepicker>
                                            </div>
                                            <div class="support-text">
                                                <asp:Label ID="Eval1FromDesc" runat="server" resourcekey="Eval1FromDesc"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="field box">
                                            <label>
                                                <asp:Label runat="server" ID="lblEval1To" resourcekey="lblEval1To"></asp:Label>
                                            </label>
                                            <div>
                                                <telerik:raddatetimepicker runat="server" id="rdEval1To">
                                                        <TimeView CellSpacing="-1">
                                                        </TimeView>
                                                        <TimePopupButton CssClass="" HoverImageUrl="" ImageUrl="" />
                                                        <Calendar EnableWeekends="True" UseColumnHeadersAsSelectors="False" UseRowHeadersAsSelectors="False">
                                                        </Calendar>
                                                        <DateInput DateFormat="M/d/yyyy" DisplayDateFormat="M/d/yyyy" LabelWidth="64px" Width="">
                                                            <EmptyMessageStyle Resize="None" />
                                                            <ReadOnlyStyle Resize="None" />
                                                            <FocusedStyle Resize="None" />
                                                            <DisabledStyle Resize="None" />
                                                            <InvalidStyle Resize="None" />
                                                            <HoveredStyle Resize="None" />
                                                            <EnabledStyle Resize="None" />
                                                        </DateInput>
                                                        <DatePopupButton CssClass="" HoverImageUrl="" ImageUrl="" />
                                                    </telerik:raddatetimepicker>
                                            </div>
                                            <div class="support-text">
                                                <asp:Label ID="Eval1ToDesc" runat="server" resourcekey="Eval1ToDesc"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="field box">
                                            <label>
                                                <asp:Label runat="server" ID="lblClosed" resourcekey="lblClosed"></asp:Label>
                                            </label>
                                            <div>
                                                <telerik:raddatetimepicker runat="server" id="rdClosed">
                                                        <TimeView CellSpacing="-1">
                                                        </TimeView>
                                                        <TimePopupButton CssClass="" HoverImageUrl="" ImageUrl="" />
                                                        <Calendar EnableWeekends="True" UseColumnHeadersAsSelectors="False" UseRowHeadersAsSelectors="False">
                                                        </Calendar>
                                                        <DateInput DateFormat="M/d/yyyy" DisplayDateFormat="M/d/yyyy" LabelWidth="64px" Width="">
                                                            <EmptyMessageStyle Resize="None" />
                                                            <ReadOnlyStyle Resize="None" />
                                                            <FocusedStyle Resize="None" />
                                                            <DisabledStyle Resize="None" />
                                                            <InvalidStyle Resize="None" />
                                                            <HoveredStyle Resize="None" />
                                                            <EnabledStyle Resize="None" />
                                                        </DateInput>
                                                        <DatePopupButton CssClass="" HoverImageUrl="" ImageUrl="" />
                                                    </telerik:raddatetimepicker>
                                            </div>
                                            <div class="support-text">
                                                <asp:Label ID="ClosedDesc" runat="server" resourcekey="ClosedDesc"></asp:Label>
                                            </div>
                                            <div class="rfv">
                                                <asp:RequiredFieldValidator class="rfv" ID="rfvrdClosed" runat="server"
                                                    ControlToValidate="rdClosed" resourcekey="rfvrdClosed"></asp:RequiredFieldValidator>
                                            </div>
                                        </div>
                                        <div class="field box3">
                                            <label>
                                                <asp:Label ID="lblFile" runat="server" resourcekey="lblFile"></asp:Label>
                                            </label>
                                            <div>
                                                <asp:Label runat="server" ID="lblFileDescription" resourcekey="lblFileDescription"></asp:Label>
                                            </div>
                                            <div>
                                                <uc4:fileuploaderwizard runat="server" IsChallengeFiles="true" documentdefaultmode="1" id="challengeFile"></uc4:fileuploaderwizard>
                                            </div>
                                            <div class="rfv">
                                            </div>
                                            <div class="support-text">
                                                <asp:Label ID="FileDesc" runat="server" resourcekey="FileDesc"></asp:Label>
                                            </div>
                                        </div>
                                        <div>
                                            <hr />
                                            <asp:HyperLink runat="server" ID="hlAdminJudge" resourcekey="hlAdminJudge" Target="_blank"></asp:HyperLink>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep1" runat="server">
                        <div class="row">
                            <div id="wizard-form-Step2" class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="BlockHome" runat="server" resourcekey="BlockHome"></asp:Label>
                                    </legend>
                                    <p class="introduction">
                                        <asp:Label ID="BlockHomeDesc" runat="server" resourcekey="BlockHomeDesc"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblTitle" runat="server" resourcekey="lblTitle"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox ID="txtTitle" runat="server"></asp:TextBox>
                                        </div>
                                        <%--<div class="rfv">
                                            <asp:RequiredFieldValidator class="rfv" ID="rfvTitle" runat="server"
                                                ControlToValidate="txtTitle" resourcekey="rfvtxtTitle"></asp:RequiredFieldValidator>
                                        </div>--%>
                                        <div class="support-text">
                                            <asp:Label ID="TitleDesc" runat="server" resourcekey="TitleDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblTagLineHome" runat="server" resourcekey="lblTagLineHome"></asp:Label>
                                        </label>

                                        <div>
                                            <asp:TextBox ID="txtTagLineHome" runat="server" TextMode="MultiLine" CssClass="maxlength"></asp:TextBox>
                                        </div>
                                        <%-- <div class="rfv">
                                            <asp:RequiredFieldValidator class="rfv" ID="rfvtxtTagLineHome" runat="server"
                                                ControlToValidate="txtTagLineHome" resourcekey="rfvtxtTagLineHome"></asp:RequiredFieldValidator>
                                        </div>--%>
                                        <div class="support-text">
                                            <asp:Label ID="TagLineHomeDesc" runat="server" resourcekey="TagLineHomeDesc"></asp:Label>
                                        </div>
                                    </div>

                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblDescription" runat="server" resourcekey="lblDescription"></asp:Label>
                                        </label>
                                        <div>
                                            <telerik:radeditor runat="server" id="txtDescriptionHome" skin="Silk"
                                                width="100%" contentfilters="none"
                                                height="600px">

                                                <ImageManager ViewPaths="~/Portals/0/images"
                                                            UploadPaths="~/Portals/0/images"
                                                            DeletePaths="~/Portals/0/images"
                                                            EnableAsyncUpload="true"></ImageManager></telerik:radeditor>
                                          
                                        </div>
                                       
                                        <div class="support-text">
                                            <asp:Label ID="DescriptionDesc" runat="server" resourcekey="DescriptionDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblTypeChallenge" runat="server" resourcekey="lblTypeChallenge"></asp:Label>
                                        </label>
                                        <div class="RadCombo">
                                            <telerik:radcombobox id="rdSolutionFlavor" runat="server" datatextfield="Label" datavaluefield="Key" width="100%"
                                                cssclass="radInput" allowcustomtext="true">
                                             </telerik:radcombobox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="TypeChallengeDesc" runat="server" resourcekey="TypeChallengeDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div id="eligibilitymodal" class="ui-widget-overlay ui-front invisible" style="background: rgba(0, 0, 0, 0.19);" runat="server">
                                        <div class="row popup">
                                            <div class="wizard-form">
                                                <fieldset>
                                                    <legend>
                                                        <asp:Label ID="lblEligibility" runat="server" resourcekey="lblEligibility"></asp:Label>
                                                    </legend>
                                                    <div class="field">
                                                        <label>
                                                            <asp:Label ID="lblTypeControl" runat="server" resourcekey="lblTypeControl"></asp:Label>
                                                        </label>
                                                        <div class="RadCombo">
                                                            <telerik:radcombobox id="ddTypeControl" runat="server" datatextfield="Label" datavaluefield="Key" width="100%"
                                                                cssclass="radInput" allowcustomtext="true"></telerik:radcombobox>
                                                        </div>
                                                        <div class="rfv">
                                                            <asp:RequiredFieldValidator class="rfv" ID="rfvddTypeControl" runat="server" ValidationGroup="ELIGIBILITYGroup"
                                                                ControlToValidate="ddTypeControl" resourcekey="rfvddTypeControl"></asp:RequiredFieldValidator>
                                                        </div>
                                                        <label>
                                                            <asp:Label ID="lblTextControl" runat="server" resourcekey="lblTextControl"></asp:Label>
                                                        </label>
                                                        <div>
                                                            <asp:TextBox ID="txtEligibility" TextMode="MultiLine" runat="server" CssClass="maxlength"></asp:TextBox>
                                                        </div>
                                                        <div class="rfv">
                                                            <asp:RequiredFieldValidator class="rfv" ID="rfvtxtEligibility" runat="server" ValidationGroup="ELIGIBILITYGroup"
                                                                ControlToValidate="txtEligibility" resourcekey="rfvtxtEligibility"></asp:RequiredFieldValidator>
                                                        </div>
                                                        <div class="support-text">
                                                            <asp:Label ID="EligibilityDesc" runat="server" resourcekey="EligibilityDesc"></asp:Label>
                                                        </div>
                                                        <div>
                                                            <asp:Button runat="server" CssClass="bttn bttn-l bttn-alert btnC" resourcekey="close" OnClientClick="ClosePopUp(1); return false;" ID="btnCloseEligibility" autopostback="true" />
                                                            <asp:Button runat="server" CssClass="bttn bttn-l bttn-secondary btnS" resourcekey="btnSaveELIGIBILITY" OnClick="btnAddELIGIBILITY2_Click" ID="btnAddELIGIBILITY2" ValidationGroup="ELIGIBILITYGroup" autopostback="true" />
                                                        </div>
                                                    </div>
                                                </fieldset>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <asp:HiddenField runat="server" ID="idEditItemEligibility" />
                                        <h2 style="text-align: center;">
                                            <asp:Label runat="server" ID="lblTitleELIGIBILITY" resourcekey="lblTitleELIGIBILITY"></asp:Label></h2>
                                        <asp:Repeater ID="rpEligibility" runat="server">
                                            <HeaderTemplate>
                                                <table class="table">
                                                    <th>
                                                        <td colspan="3" style="width: 10%"></td>
                                                        <td style="width: 45%">
                                                            <h3>
                                                                <asp:Label runat="server" ID="lblHedearElegibilityControl" resourcekey="lblHedearElegibilityControl"></asp:Label></h3>
                                                        </td>
                                                        <td style="width: 45%">
                                                            <h3>
                                                                <asp:Label runat="server" ID="lblHeaderPreview" resourcekey="lblHeaderPreview"></asp:Label></h3>
                                                        </td>
                                                    </th>
                                                </table>
                                                <ul>
                                            </HeaderTemplate>
                                            <FooterTemplate>
                                                </ul>
                                            </FooterTemplate>
                                            <ItemTemplate>
                                                <li>
                                                    <hr />
                                                    <table class="table">

                                                        <tr>
                                                            <td rowspan="2">
                                                                <asp:LinkButton OnClick="ibtnPositionELIGIBILITY_Click" ID="ibtnPositionUpELIGI" CommandArgument='<%#Eval("id")%>' CommandName="UP" runat="server" ValidationGroup="ELIGIBILITYGroup2" ToolTip='<%#Localization.GetString("ToolTipUp", this.LocalResourceFile)%>' Visible='<%#GetPositionVisible(Eval("position").ToString(),"ELIGIBILITY","UP")%>'><%--<i class="icon-arrow-up"></i>--%><i class="fa fa-chevron-up"></i></asp:LinkButton>
                                                                <br />

                                                                <asp:LinkButton OnClick="ibtnPositionELIGIBILITY_Click" ID="ibtnPositionELIGI" CommandArgument='<%#Eval("id")%>' CommandName="DOWN" runat="server" ValidationGroup="ELIGIBILITYGroup2" ToolTip='<%#Localization.GetString("ToolTipDown", this.LocalResourceFile)%>' Visible='<%#GetPositionVisible(Eval("position").ToString(),"ELIGIBILITY","DOWN")%>'><%--<i class="fa fa-arrow-down"></i>--%> <i class="fa fa-chevron-down"></i></asp:LinkButton>

                                                            </td>

                                                            <td rowspan="2">
                                                                <asp:LinkButton OnClick="ibtnEditELIGIBILITY_Click" ID="ibtnEditELIGI" ValidationGroup="ELIGIBILITYGroup2" CommandArgument='<%#Eval("id")%>' runat="server" ToolTip='<%#Localization.GetString("ToolTipEdit", this.LocalResourceFile)%>'><i class="icon-pencil"></i></asp:LinkButton>
                                                            </td>
                                                            <td rowspan="2">

                                                                <asp:LinkButton ID="ibtnDeleteELIGI" ValidationGroup="ELIGIBILITYGroup2" OnClientClick="return Confirmation(this,1);" idElegibility='<%#Eval("id")%>' CommandArgument='<%#Eval("id")%>' runat="server" ToolTip='<%#Localization.GetString("ToolTipDelete", this.LocalResourceFile)%>'><i class="fa fa-trash-o fa-lg"></i></asp:LinkButton>
                                                            </td>
                                                            <td style="width: 45%">
                                                                <asp:Label runat="server" ID="lblName" Text='<%#Eval("value1")%>'></asp:Label>

                                                            </td>
                                                            <td rowspan="2" style="width: 45%">
                                                                <asp:Label runat="server" ID="Label3" Text='<%#Eval("value3")%>'></asp:Label>

                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="width: 45%">
                                                                <asp:Label runat="server" ID="lblDescription" Text='<%#Eval("value2")%>'></asp:Label>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </li>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                        <div style="display: none;">
                                            <asp:Button runat="server" ID="lbDeleteEligiAux" ValidationGroup="ELIGIBILITYGroup2" OnClick="ibtnDeleteELIGIBILITY_Click" />
                                        </div>
                                        <div style="padding-bottom: 100px!important;">
                                            <asp:Button runat="server" CssClass="bttn bttn-l bttn-secondary btnS" resourcekey="btnAddEligibility" ID="btnAddEligibility" OnClientClick="OpenPopUp(1);return false;" />
                                        </div>
                                    </div>


                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep2" runat="server">
                        <div class="row">
                            <div class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="BlockCriteria" runat="server" resourcekey="BlockCriteria"></asp:Label></legend>
                                    <p class="introduction">
                                        <asp:Label ID="BlockCriteriaDesc" runat="server" resourcekey="BlockCriteriaDesc"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblTitleCriteria" runat="server" resourcekey="lblTitle"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox ID="txtTitleCriteria" runat="server"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <%-- <asp:RequiredFieldValidator class="rfv" ID="rfvTitleCriteria" runat="server"
                                                ControlToValidate="txtTitleCriteria" resourcekey="rfvtxtTitle"></asp:RequiredFieldValidator>--%>
                                            <asp:RegularExpressionValidator runat="server" ID="revTitleCriteria" ControlToValidate="txtTitleCriteria"
                                                ValidationExpression="^[\s\S]{0,50}$" resourcekey="revLimit">
                                            </asp:RegularExpressionValidator>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="TitleCriteriaDesc" runat="server" resourcekey="TitleCriteriaDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblCriteriaTagLine" runat="server" resourcekey="lblCriteriaTagLine"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox TextMode="MultiLine" ID="txtCriteriaTagLine" runat="server" CssClass="maxlength"></asp:TextBox>
                                        </div>

                                        <div class="support-text">
                                            <asp:Label ID="criteriaTagLineDesc" runat="server" resourcekey="criteriaTagLineDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblCriteriaContent" runat="server" resourcekey="lblCriteriaContent"></asp:Label>
                                        </label>
                                        <div>

                                            <telerik:radeditor runat="server" id="teCriteriaContent" skin="Silk" width="100%"
                                                height="600px" contentfilters="none">
                                                        <ImageManager ViewPaths="~/Portals/0/images"
                                                            UploadPaths="~/Portals/0/images"
                                                            DeletePaths="~/Portals/0/images"
                                                            EnableAsyncUpload="true"></ImageManager>
                                                    </telerik:radeditor>
                                         
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="criteriaContentDesc" runat="server" resourcekey="criteriaContentDesc"></asp:Label>
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
                                        <asp:Label ID="BlockJudges" runat="server" resourcekey="BlockJudges"></asp:Label></legend>
                                    <p class="introduction">
                                        <asp:Label ID="BlockJudgesDesc" runat="server" resourcekey="BlockJudgesDesc"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblTitleJudges" runat="server" resourcekey="lblTitle"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox ID="txtTitleJudges" runat="server"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <%--    <asp:RequiredFieldValidator class="rfv" ID="rfvtxtTitleJudges" runat="server"
                                                ControlToValidate="txtTitleJudges" resourcekey="rfvtxtTitle"></asp:RequiredFieldValidator>--%>
                                            <asp:RegularExpressionValidator runat="server" ID="revtxtTitle" ControlToValidate="txtTitleJudges"
                                                ValidationExpression="^[\s\S]{0,50}$" resourcekey="revLimit">
                                            </asp:RegularExpressionValidator>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="TitleJudgesDesc" runat="server" resourcekey="TitleJudgesDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblJudgesTagLine" runat="server" resourcekey="lblJudgesTagLine"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox ID="txtJudgesTagLine" runat="server" TextMode="MultiLine" CssClass="maxlength"></asp:TextBox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="JudgesTagLineDesc" runat="server" resourcekey="JudgesTagLineDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div id="judgemodal" class="ui-widget-overlay ui-front invisible" style="background: rgba(0, 0, 0, 0.19);" runat="server">
                                        <div class="row popup">
                                            <div class="contentpopup">
                                                <legend>
                                                    <asp:Label ID="Label1" runat="server" resourcekey="lblJudgeTitle"></asp:Label>
                                                </legend>
                                                <div>
                                                    <asp:Label ID="lblPhoto" runat="server" resourcekey="lblPhoto" CssClass="labelpopup"></asp:Label>
                                                </div>
                                                <div>
                                                    <telerik:radasyncupload runat="server" id="RadAsyncUploadPhoto" allowedfileextensions="jpg,jpeg,png,gif" targetfolder="~/portals/0/tmpPhoto/" multiplefileselection="Disabled"
                                                        maxfilesize="524288" skin="Silk" autopostback="true" onfileuploaded="RadAsyncUploadPhoto_FileUploaded" onclientvalidationfailed="validationFailed" uploadedfilesrendering="BelowFileInput">
                                                </telerik:radasyncupload>
                                                    <asp:Image runat="server" ID="imgPhoto" />

                                                    <asp:Label ID="lblPhotoEdit" Font-Size="Small" runat="server" Visible="false"></asp:Label>

                                                </div>

                                                <div>
                                                    <asp:Label ID="lblNameJudge" runat="server" resourcekey="lblNameJudge" CssClass="labelpopup"></asp:Label>
                                                </div>
                                                <div>
                                                    <asp:TextBox ID="txtNameJudge" runat="server"></asp:TextBox>
                                                </div>
                                                <div class="rfv">
                                                    <asp:RequiredFieldValidator class="rfv" ID="rfvtxtNameJudge" runat="server" ValidationGroup="JUDGEGroup"
                                                        ControlToValidate="txtNameJudge" resourcekey="rfvtxtNameJudge"></asp:RequiredFieldValidator>
                                                </div>

                                                <div>
                                                    <asp:Label ID="lblTagLineJudge" runat="server" resourcekey="lblTagLineJudge" CssClass="labelpopup"></asp:Label>
                                                </div>
                                                <div>
                                                    <asp:TextBox ID="txtTagLineJudge" runat="server"></asp:TextBox>
                                                </div>


                                                <div>
                                                    <asp:Label ID="lblDescriptionJudge" runat="server" resourcekey="lblDescriptionJudge" CssClass="labelpopup"></asp:Label>
                                                </div>
                                                <div>
                                                    <telerik:radeditor runat="server" id="txtDescriptionJudge" width="100%"
                                                        height="300px" contentfilters="none">
                                                        <ImageManager ViewPaths="~/Portals/0/images"
                                                            UploadPaths="~/Portals/0/images"
                                                            DeletePaths="~/Portals/0/images"
                                                            EnableAsyncUpload="true"></ImageManager>
                                                   </telerik:radeditor>
                                                  
                                                </div>
                                                <div class="rfv">
                                                    <asp:RequiredFieldValidator class="rfv" ID="rfvtxtDescriptionJudge" runat="server" ValidationGroup="JUDGEGroup"
                                                        ControlToValidate="txtDescriptionJudge" resourcekey="rfvtxtDescriptionJudge"></asp:RequiredFieldValidator>
                                                </div>
                                                <div>
                                                    <asp:Label ID="lblTagJudge" runat="server" resourcekey="lblTagJudge" CssClass="labelpopup"></asp:Label>
                                                </div>
                                                <div>
                                                    <asp:TextBox ID="txtTagJudge" runat="server"></asp:TextBox>
                                                </div>
                                                <div>
                                                    <asp:Button runat="server" CssClass="bttn bttn-l bttn-alert btnC" resourcekey="close" OnClientClick="ClosePopUp(2); return false;" ID="btnCloseJudge" autopostback="true" />
                                                    <asp:Button runat="server" CssClass="bttn bttn-l bttn-secondary btnS" resourcekey="btnSaveJudge" OnClick="btnAddJUDGE_Click" ID="btnAddJUDGE" ValidationGroup="JUDGEGroup" autopostback="true" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div>
                                        <div>
                                            <asp:HiddenField runat="server" ID="idEditItemJudge" />
                                            <h2 style="text-align: center;">
                                                <asp:Label runat="server" ID="lblTitleJudge" resourcekey="lblTitleJudge"></asp:Label></h2>
                                            <asp:Repeater ID="rpJudges" runat="server">
                                                <HeaderTemplate>
                                                    <ul>
                                                </HeaderTemplate>
                                                <FooterTemplate>
                                                    </ul>
                                                </FooterTemplate>
                                                <ItemTemplate>
                                                    <li>
                                                        <hr />
                                                        <table class="table">

                                                            <tr>
                                                                <td rowspan="4">
                                                                    <asp:LinkButton OnClick="ibtnPositionJUDGE_Click" ID="ibtnPositionUpJUDGE" CommandArgument='<%#Eval("id")%>' ToolTip='<%#Localization.GetString("ToolTipUp", this.LocalResourceFile)%>' CommandName="UP" runat="server" ValidationGroup="JUDGEGroup2" Visible='<%#GetPositionVisible(Eval("position").ToString(),"JUDGE","UP")%>'><%--<i class="icon-arrow-up"></i>--%><i class="fa fa-chevron-up"></i></asp:LinkButton>
                                                                    <br />

                                                                    <asp:LinkButton OnClick="ibtnPositionJUDGE_Click" ID="ibtnPositionJUDGE" CommandArgument='<%#Eval("id")%>' ToolTip='<%#Localization.GetString("ToolTipDown", this.LocalResourceFile)%>' CommandName="DOWN" runat="server" ValidationGroup="JUDGEGroup2" Visible='<%#GetPositionVisible(Eval("position").ToString(),"JUDGE","DOWN")%>'><%--<i class="fa fa-arrow-down"></i>--%><i class="fa fa-chevron-down"></i></asp:LinkButton>

                                                                </td>

                                                                <td rowspan="4">
                                                                    <asp:LinkButton OnClick="ibtnEditJUDGE_Click" ID="ibtnEditJUDGE" ValidationGroup="JUDGEGroup2" ToolTip='<%#Localization.GetString("ToolTipEdit", this.LocalResourceFile)%>' CommandArgument='<%#Eval("id")%>' runat="server"><i class="icon-pencil"></i></asp:LinkButton>
                                                                </td>
                                                                <td rowspan="4">
                                                                    <asp:LinkButton OnClientClick="Confirmation(this,2)" ID="ibtnDeleteJUDGE" idJudge='<%#Eval("id")%>' ValidationGroup="JUDGEGroup2" ToolTip='<%#Localization.GetString("ToolTipDelete", this.LocalResourceFile)%>' CommandArgument='<%#Eval("id")%>' runat="server"><i class="fa fa-trash-o fa-lg"></i></asp:LinkButton>
                                                                </td>
                                                                <td rowspan="4" style="width: 150px!important;">
                                                                    <asp:Image CssClass="round" runat="server" ID="iPhoto" ImageUrl='<%#  Eval("value3")!=string.Empty ? "~/" + Eval("value3"):string.Empty%>' Width="112px" Height="112px" />
                                                                </td>
                                                                <td>
                                                                    <asp:Label runat="server" ID="lblName" Text='<%#Eval("value1")%>'></asp:Label>

                                                                </td>
                                                            </tr>
                                                            <td>
                                                                <asp:Label runat="server" ID="lblTagLine" Text='<%#Eval("value4")%>'></asp:Label>

                                                            </td>
                                                            <tr>

                                                                <td>
                                                                    <asp:Label runat="server" ID="lblDescription" Text='<%#Eval("value2")%>'></asp:Label>

                                                                </td>
                                                            </tr>
                                                            <tr>

                                                                <td>
                                                                    <asp:Label runat="server" ID="lblTag" Text='<%#Eval("value5")%>'></asp:Label>

                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </li>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                            <div style="display: none;">
                                                <asp:Button ID="lbDeleteJudAux" runat="server" ValidationGroup="JUDGEGroup2" OnClick="ibtnDeleteJUDGE_Click"></asp:Button>
                                            </div>

                                            <div style="padding-bottom: 100px!important;">
                                                <asp:Button runat="server" CssClass="bttn bttn-l bttn-secondary btnS" resourcekey="btnAddJudge" ID="btnAddJudge2" OnClientClick="OpenPopUp(2);return false;" />
                                            </div>
                                        </div>
                                    </div>

                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep4" runat="server">
                        <div class="row">
                            <div class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="BlockPartners" runat="server" resourcekey="BlockPartners"></asp:Label></legend>
                                    <p class="introduction">
                                        <asp:Label ID="BlockPartnersDesc" runat="server" resourcekey="BlockPartnersDesc"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblTitlePartnersPage" runat="server" resourcekey="lblTitle"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox ID="txtTitlePartners" runat="server"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <%-- <asp:RequiredFieldValidator class="rfv" ID="rfvtxtTitlePartners" runat="server"
                                                ControlToValidate="txtTitlePartners" resourcekey="rfvtxtTitle"></asp:RequiredFieldValidator>--%>
                                            <asp:RegularExpressionValidator runat="server" ID="revtxtTitlePartners" ControlToValidate="txtTitlePartners"
                                                ValidationExpression="^[\s\S]{0,50}$" resourcekey="revLimit">
                                            </asp:RegularExpressionValidator>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="TitlePartnersDesc" runat="server" resourcekey="TitlePartnersDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblPartnersTagLine" runat="server" resourcekey="lblPartnersTagLine"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox ID="txtPartnersTagLine" runat="server" TextMode="MultiLine" CssClass="maxlength"></asp:TextBox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="PartnerTagLineDesc" runat="server" resourcekey="PartnerTagLineDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div id="partnermodal" class="ui-widget-overlay ui-front invisible" style="background: rgba(0, 0, 0, 0.19);" runat="server">
                                        <div class="row popup">
                                            <div class="contentpopup">
                                                <legend>
                                                    <asp:Label ID="Label12" runat="server" resourcekey="lblPartnersTitle"></asp:Label>
                                                </legend>
                                                <div>
                                                    <asp:Label ID="lblImagePartner" runat="server" resourcekey="lblImagePartner" CssClass="labelpopup"></asp:Label>
                                                </div>
                                                <div>
                                                    <telerik:radasyncupload runat="server" id="RadAsyncUploadImage" allowedfileextensions="jpg,jpeg,png,gif" targetfolder="~/portals/0/tmpPhoto/" multiplefileselection="Disabled"
                                                        maxfilesize="524288" skin="Silk" autopostback="true" onfileuploaded="RadAsyncUploadImage_FileUploaded" onclientvalidationfailed="validationFailed" uploadedfilesrendering="BelowFileInput">
                                                            </telerik:radasyncupload>
                                                    <asp:Image runat="server" ID="Image1" />

                                                    <asp:Label ID="lblImageEdit" Font-Size="Small" runat="server" Visible="false"></asp:Label>

                                                </div>
                                                <div>
                                                    <asp:Label ID="lblNamePartner" runat="server" resourcekey="lblNamePartner" CssClass="labelpopup">></asp:Label>
                                                </div>
                                                <div>
                                                    <asp:TextBox ID="txtNamePartner" runat="server"></asp:TextBox>
                                                </div>
                                                <div class="rfv">
                                                    <asp:RequiredFieldValidator class="rfv" ID="rfvtxtNamePartner" runat="server" ValidationGroup="PartnerGroup"
                                                        ControlToValidate="txtNamePartner" resourcekey="rfvtxtNamePartner"></asp:RequiredFieldValidator>
                                                </div>

                                                <div>
                                                    <asp:Label ID="lblTagLinePartner" runat="server" resourcekey="lblTagLinePartner" CssClass="labelpopup">></asp:Label>
                                                </div>
                                                <div>
                                                    <asp:TextBox ID="txtTagLinePartner" runat="server"></asp:TextBox>
                                                </div>
                                                <div>
                                                    <asp:Label ID="lblDescriptionPartner" runat="server" resourcekey="lblDescriptionPartner" CssClass="labelpopup">></asp:Label>
                                                </div>
                                                <div>
                                                    <telerik:radeditor runat="server" id="txtDescriptionPartner" width="100%"
                                                        height="300px" contentfilters="none">
                                                        <ImageManager ViewPaths="~/Portals/0/images"
                                                            UploadPaths="~/Portals/0/images"
                                                            DeletePaths="~/Portals/0/images"
                                                            EnableAsyncUpload="true"></ImageManager>
                                                    </telerik:radeditor>
                                                
                                                </div>
                                                <div class="rfv">
                                                    <asp:RequiredFieldValidator class="rfv" ID="rvftxtDescriptionPartner" runat="server" ValidationGroup="PartnerGroup"
                                                        ControlToValidate="txtDescriptionPartner" resourcekey="rfvtxtDescriptionPartner"></asp:RequiredFieldValidator>
                                                </div>
                                                <div>
                                                    <asp:Label ID="lblTagPartner" runat="server" resourcekey="lblTagPartner" CssClass="labelpopup"></asp:Label>
                                                </div>
                                                <div>
                                                    <asp:TextBox ID="txtTagPartner" runat="server"></asp:TextBox>
                                                </div>
                                                <div>
                                                    <asp:Button runat="server" CssClass="bttn bttn-l bttn-alert btnC" resourcekey="close" OnClientClick="ClosePopUp(4); return false;" ID="btnClosePartner" autopostback="true" />
                                                    <asp:Button runat="server" CssClass="bttn bttn-l bttn-secondary btnS" resourcekey="btnSavePartner" OnClick="btnAddPARTNER_Click" ID="btnAddPartner" ValidationGroup="PartnerGroup" autopostback="true" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div>
                                        <div>
                                            <asp:HiddenField runat="server" ID="hfPartners" />
                                            <h2 style="text-align: center;">
                                                <asp:Label runat="server" ID="lblTitlePartners" resourcekey="lblTitlePartners"></asp:Label></h2>
                                            <asp:Repeater ID="rpPartners" runat="server">
                                                <HeaderTemplate>
                                                    <ul>
                                                </HeaderTemplate>
                                                <FooterTemplate>
                                                    </ul>
                                                </FooterTemplate>
                                                <ItemTemplate>
                                                    <li>
                                                        <hr />
                                                        <table class="table">

                                                            <tr>
                                                                <td rowspan="4">
                                                                    <asp:LinkButton OnClick="ibtnDeletePARTNER_Click" ID="ibtnPositionUpPARTNERS" CommandArgument='<%#Eval("id")%>' CommandName="UP" runat="server" ToolTip='<%#Localization.GetString("ToolTipUp", this.LocalResourceFile)%>' ValidationGroup="PartnerGroup2" Visible='<%#GetPositionVisible(Eval("position").ToString(),"PARTNER","UP")%>'><%--<i class="icon-arrow-up"></i>--%><i class="fa fa-chevron-up"></i></asp:LinkButton>
                                                                    <br />

                                                                    <asp:LinkButton OnClick="ibtnDeletePARTNER_Click" ID="ibtnPositionPARTNERS" CommandArgument='<%#Eval("id")%>' CommandName="DOWN" runat="server" ToolTip='<%#Localization.GetString("ToolTipDown", this.LocalResourceFile)%>' ValidationGroup="PartnerGroup2" Visible='<%#GetPositionVisible(Eval("position").ToString(),"PARTNER","DOWN")%>'><%--<i class="fa fa-arrow-down"></i>--%><i class="fa fa-chevron-down"></i></asp:LinkButton>

                                                                </td>

                                                                <td rowspan="4">
                                                                    <asp:LinkButton OnClick="ibtnEditPARTNER_Click" ID="ibtnEditPARTNERS" ValidationGroup="PARTNERSGroup2" CommandArgument='<%#Eval("id")%>' ToolTip='<%#Localization.GetString("ToolTipEdit", this.LocalResourceFile)%>' runat="server"><i class="icon-pencil"></i></asp:LinkButton>
                                                                </td>
                                                                <td rowspan="4">

                                                                    <asp:LinkButton ID="ibtnDeletePARTNERS" OnClientClick="return Confirmation(this, 3);" idPartner='<%#Eval("id")%>' ValidationGroup="PARTNERSGroup2" CommandArgument='<%#Eval("id")%>' ToolTip='<%#Localization.GetString("ToolTipDelete", this.LocalResourceFile)%>' runat="server"><i class="fa fa-trash-o fa-lg"></i></asp:LinkButton>
                                                                </td>
                                                                <td rowspan="4" style="width: 150px!important;">
                                                                    <asp:Image CssClass="round" runat="server" ID="iImage" ImageUrl='<%#  Eval("value3")!=string.Empty ? "~/" + Eval("value3"):string.Empty%>' Width="112px" Height="112px" />
                                                                </td>
                                                                <td>
                                                                    <asp:Label runat="server" ID="lblName" Text='<%#Eval("value1")%>'></asp:Label>

                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <asp:Label runat="server" ID="lblTagLine" Text='<%#Eval("value4")%>'></asp:Label>

                                                                </td>
                                                            </tr>
                                                            <tr>

                                                                <td>
                                                                    <asp:Label runat="server" ID="lblDescription" Text='<%#Eval("value2")%>'></asp:Label>

                                                                </td>
                                                            </tr>
                                                            <tr>

                                                                <td>
                                                                    <asp:Label runat="server" ID="lblTag" Text='<%#Eval("value5")%>'></asp:Label>

                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </li>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                            <div style="display: none;">
                                                <asp:Button ID="lbDeletePartAux" runat="server" ValidationGroup="PARTNERSGroup2" OnClick="ibtnDeletePARTNER_Click" CommandArgument='<%#Eval("id")%>'></asp:Button>
                                            </div>
                                            <div style="padding-bottom: 100px!important;">
                                                <asp:Button runat="server" CssClass="bttn bttn-l bttn-secondary btnS" resourcekey="btnAddPartner" ID="btnAddPartner2" OnClientClick="OpenPopUp(4);return false;" />
                                            </div>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep5" runat="server">
                        <div class="row">
                            <div id="wizard-form-Step4" class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="BlockFAQ" runat="server" resourcekey="BlockFAQ"></asp:Label></legend>
                                    <p class="introduction">
                                        <asp:Label ID="BlockFAQDesc" runat="server" resourcekey="BlockFAQDesc"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblTitleFAQ2" runat="server" resourcekey="lblTitle"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox ID="txtTitleFAQ" runat="server"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <%--<asp:RequiredFieldValidator class="rfv" ID="rvftxtTitleFAQ" runat="server"
                                                ControlToValidate="txtTitleFAQ" resourcekey="rfvtxtTitle"></asp:RequiredFieldValidator>--%>
                                            <asp:RegularExpressionValidator runat="server" ID="revtxtTitleFAQ" ControlToValidate="txtTitleFAQ"
                                                ValidationExpression="^[\s\S]{0,50}$" resourcekey="revLimit">
                                            </asp:RegularExpressionValidator>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="TitleFAQDesc" runat="server" resourcekey="TitleFAQDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblFAQTagLine" runat="server" resourcekey="lblFAQTagLine"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox ID="txtFAQTagLine" runat="server" TextMode="MultiLine" CssClass="maxlength"></asp:TextBox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="FAQTagLineDesc" runat="server" resourcekey="FAQTagLineDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div id="faqmodal" class="ui-widget-overlay ui-front invisible" style="background: rgba(0, 0, 0, 0.19);" runat="server">
                                        <div class="row popup">
                                            <div class="contentpopup">
                                                <legend>
                                                    <asp:Label ID="lblFaqTitle" runat="server" resourcekey="lblFaqTitle"></asp:Label>
                                                </legend>
                                                <div>
                                                    <asp:Label ID="lblQuestion" runat="server" resourcekey="lblQuestion" CssClass="labelpopup"></asp:Label>
                                                </div>
                                                <div>
                                                    <asp:TextBox TextMode="MultiLine" ID="txtFAQuestion" runat="server" CssClass="maxlength"></asp:TextBox>
                                                </div>
                                                <div class="rfv">
                                                    <asp:RequiredFieldValidator class="rfv" ID="rfvtxtFAQuestion" runat="server" ValidationGroup="FAQGroup"
                                                        ControlToValidate="txtFAQuestion" resourcekey="rfvtxtFAQuestion"></asp:RequiredFieldValidator>
                                                </div>
                                                <div>
                                                    <asp:Label ID="lblAnswer" runat="server" resourcekey="lblAnswer" CssClass="labelpopup"></asp:Label>
                                                </div>
                                                <div>
                                                    <telerik:radeditor runat="server" id="txtFAQAnswer" width="100%"
                                                        height="300px" contentfilters="none">
                                                       <ImageManager ViewPaths="~/Portals/0/images"
                                                            UploadPaths="~/Portals/0/images"
                                                            DeletePaths="~/Portals/0/images"
                                                            EnableAsyncUpload="true"></ImageManager>
                                                    </telerik:radeditor>
                                                 
                                                </div>
                                                <div class="rfv">
                                                    <asp:RequiredFieldValidator class="rfv" ID="rfvtxtFAQAnswer" runat="server" ValidationGroup="FAQGroup"
                                                        ControlToValidate="txtFAQAnswer" resourcekey="rfvtxtFAQAnswer"></asp:RequiredFieldValidator>
                                                </div>
                                                <div>
                                                    <asp:Label ID="lblTagFAQ" runat="server" resourcekey="lblTagFAQ" CssClass="labelpopup"></asp:Label>
                                                </div>
                                                <div>
                                                    <asp:TextBox ID="txtTagFAQ" runat="server"></asp:TextBox>
                                                </div>
                                                <div>
                                                    <asp:Button runat="server" CssClass="bttn bttn-l bttn-alert btnC" resourcekey="close" OnClientClick="ClosePopUp(3); return false;" ID="btnCloseFaq" autopostback="true" />
                                                    <asp:Button runat="server" CssClass="bttn bttn-l bttn-secondary btnS" resourcekey="btnSaveFAQ" OnClick="btnAddFAQ_Click" ID="btnAddFAQ" ValidationGroup="FAQGroup" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div>
                                        <div>
                                            <asp:HiddenField runat="server" ID="idEditItemFAQ" />
                                            <h2 style="text-align: center;">
                                                <asp:Label runat="server" ID="lblTitleFAQ" resourcekey="lblTitleFAQ"></asp:Label></h2>
                                            <asp:Repeater ID="rpFAQ" runat="server">
                                                <HeaderTemplate>
                                                    <ul>
                                                </HeaderTemplate>
                                                <FooterTemplate>
                                                    </ul>
                                                </FooterTemplate>
                                                <ItemTemplate>
                                                    <li>
                                                        <hr />
                                                        <table class="table">
                                                            <tr>
                                                                <td rowspan="3">
                                                                    <asp:LinkButton OnClick="ibtnPositionFAQ_Click" ID="ibtnPositionUpFAQ" CommandArgument='<%#Eval("id")%>' CommandName="UP" runat="server" ValidationGroup="FAQGroup2" ToolTip='<%#Localization.GetString("ToolTipUp", this.LocalResourceFile)%>' Visible='<%#GetPositionVisible(Eval("position").ToString(),"FAQ","UP")%>'><%--<i class="icon-arrow-up"></i>--%><i class="fa fa-chevron-up"></i></asp:LinkButton>
                                                                    <br />

                                                                    <asp:LinkButton OnClick="ibtnPositionFAQ_Click" ID="ibtnPositionFAQ" CommandArgument='<%#Eval("id")%>' CommandName="DOWN" runat="server" ValidationGroup="FAQGroup2" ToolTip='<%#Localization.GetString("ToolTipDown", this.LocalResourceFile)%>' Visible='<%#GetPositionVisible(Eval("position").ToString(),"FAQ","DOWN")%>'><%--<i class="fa fa-arrow-down"></i>--%><i class="fa fa-chevron-down"></i></asp:LinkButton>

                                                                </td>
                                                                <td rowspan="3">
                                                                    <asp:LinkButton OnClick="ibtnEditFAQ_Click" ValidationGroup="FAQGroup2" ID="ibtnEditFAQ" CommandArgument='<%#Eval("id")%>' ToolTip='<%#Localization.GetString("ToolTipEdit", this.LocalResourceFile)%>' runat="server"><i class="icon-pencil"></i></asp:LinkButton>
                                                                </td>
                                                                <td rowspan="3">
                                                                    <asp:LinkButton OnClientClick="return Confirmation(this, 4);" idFaq='<%#Eval("ID")%>' ValidationGroup="FAQGroup2" ID="ibtnDeleteFAQ" CommandArgument='<%#Eval("ID")%>' ToolTip='<%#Localization.GetString("ToolTipDelete", this.LocalResourceFile)%>' runat="server"><i class="fa fa-trash-o fa-lg"></i></asp:LinkButton>
                                                                </td>
                                                                <td>
                                                                    <strong>
                                                                        <asp:Label runat="server" ID="lblHeaderQuestion" Text="Question"></asp:Label></strong>
                                                                </td>
                                                                <td>
                                                                    <asp:Label runat="server" ID="lblQuestion" Text='<%#Eval("value1")%>'></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <strong>
                                                                        <asp:Label runat="server" ID="lblHeaderAnswer" Text="Answer"></asp:Label></strong>
                                                                </td>
                                                                <td>
                                                                    <asp:Label runat="server" ID="lblAnswer" Text='<%#Eval("value2")%>'></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <strong>
                                                                        <asp:Label runat="server" ID="lblHeaderTag" Text='<%#Eval("value3")!=string.Empty?"Tag":string.Empty%>'></asp:Label></strong>
                                                                </td>
                                                                <td>
                                                                    <asp:Label runat="server" ID="lblTag" Text='<%#Eval("value3")%>'></asp:Label>

                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </li>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                            <div style="display: none;">
                                                <asp:Button ID="lbDeleteFAQaux" runat="server" ValidationGroup="FAQGroup2" OnClick="ibtnDeleteFAQ_Click" CommandArgument='<%#Eval("id")%>'></asp:Button>
                                            </div>
                                            <div style="padding-bottom: 100px!important;">
                                                <asp:Button runat="server" CssClass="bttn bttn-l bttn-secondary btnS" resourcekey="btnAddFaq" ID="btnAddFaq2" OnClientClick="OpenPopUp(3);return false;" />
                                            </div>

                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep6" runat="server">
                        <div class="row">
                            <div id="wizard-form-Step5" class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="BlockTerms" runat="server" resourcekey="BlockTerms"></asp:Label></legend>
                                    <p class="introduction">
                                        <asp:Label ID="BlockTermsDesc" runat="server" resourcekey="BlockTermsDesc"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblTitleTerms" runat="server" resourcekey="lblTitle"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox ID="txtTitleTerms" runat="server"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <%--<asp:RequiredFieldValidator class="rfv" ID="rfvtxtTitleTerms" runat="server"
                                                ControlToValidate="txtTitleTerms" resourcekey="rfvtxtTitle"></asp:RequiredFieldValidator>--%>
                                            <asp:RegularExpressionValidator runat="server" ID="revtxtTitleTerms" ControlToValidate="txtTitleTerms"
                                                ValidationExpression="^[\s\S]{0,50}$" resourcekey="revLimit">
                                            </asp:RegularExpressionValidator>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="TitleTermsDesc" runat="server" resourcekey="TitleTermsDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblTermsTagLine" runat="server" resourcekey="lblTermsTagLine"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox TextMode="MultiLine" ID="txtTermsTagLine" runat="server" CssClass="maxlength"></asp:TextBox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="termsTagLineDesc" runat="server" resourcekey="termsTagLineDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblTermsContent" runat="server" resourcekey="lblTermsContent"></asp:Label>
                                        </label>
                                        <div>
                                            <telerik:radeditor runat="server" id="teTermsContent" skin="Silk" width="100%"
                                                height="600px" contentfilters="none">
                                                       <ImageManager ViewPaths="~/Portals/0/images"
                                                            UploadPaths="~/Portals/0/images"
                                                            DeletePaths="~/Portals/0/images"
                                                            EnableAsyncUpload="true"></ImageManager>
                                                    </telerik:radeditor>
                                           
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="termsContentDesc" runat="server" resourcekey="termsContentDesc"></asp:Label>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep7" runat="server">
                        <div class="row">
                            <div class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="BlockParticipate" runat="server" resourcekey="BlockParticipate"></asp:Label></legend>
                                    <p class="introduction">
                                        <asp:Label ID="BlockParticipateDesc" runat="server" resourcekey="BlockParticipateDesc"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblTitleParticipate" runat="server" resourcekey="lblTitle"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox ID="txtTitleParticipate" runat="server"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <%--<asp:RequiredFieldValidator class="rfv" ID="rfvtxtTitleParticipate" runat="server"
                                                ControlToValidate="txtTitleParticipate" resourcekey="rfvtxtTitle"></asp:RequiredFieldValidator>--%>
                                            <asp:RegularExpressionValidator runat="server" ID="revtxtTitleParticipate" ControlToValidate="txtTitleParticipate"
                                                ValidationExpression="^[\s\S]{0,50}$" resourcekey="revLimit">
                                            </asp:RegularExpressionValidator>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="TitleParticipateDesc" runat="server" resourcekey="TitleParticipateDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblParticipateTagLine" runat="server" resourcekey="lblParticipateTagLine"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox TextMode="MultiLine" ID="txtParticipateTagLine" runat="server" CssClass="maxlength"></asp:TextBox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="participateTagLineDesc" runat="server" resourcekey="participateTagLineDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblParticipateContent" runat="server" resourcekey="lblParticipateContent"></asp:Label>
                                        </label>
                                        <div>
                                            <telerik:radeditor runat="server" id="teParticipateContent" skin="Silk" width="100%"
                                                height="600px" contentfilters="none">
                                                       <ImageManager ViewPaths="~/Portals/0/images"
                                                            UploadPaths="~/Portals/0/images"
                                                            DeletePaths="~/Portals/0/images"
                                                            EnableAsyncUpload="true"></ImageManager>
                                                  </telerik:radeditor>
                                           
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="participateContentDesc" runat="server" resourcekey="participateContentDesc"></asp:Label>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep8" runat="server">
                        <div class="row">
                            <div class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="BlockAwards" runat="server" resourcekey="BlockAwards"></asp:Label></legend>
                                    <p class="introduction">
                                        <asp:Label ID="BlockAwardsDesc" runat="server" resourcekey="BlockAwardsDesc"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblTitleAwards" runat="server" resourcekey="lblTitle"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox ID="txtTitleAwards" runat="server"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <%-- <asp:RequiredFieldValidator class="rfv" ID="rfvtxtTitleAwards" runat="server"
                                                ControlToValidate="txtTitleAwards" resourcekey="rfvtxtTitle"></asp:RequiredFieldValidator>--%>
                                            <asp:RegularExpressionValidator runat="server" ID="revtxtTitleAwards" ControlToValidate="txtTitleAwards"
                                                ValidationExpression="^[\s\S]{0,50}$" resourcekey="revLimit">
                                            </asp:RegularExpressionValidator>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="TitleAwardsDesc" runat="server" resourcekey="TitleAwardsDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblAwardsTagLine" runat="server" resourcekey="lblAwardsTagLine"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox TextMode="MultiLine" ID="txtAwardsTagLine" runat="server" CssClass="maxlength"></asp:TextBox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="AwardsTagLineDesc" runat="server" resourcekey="AwardsTagLineDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblAwardsContent" runat="server" resourcekey="lblAwardsContent"></asp:Label>
                                        </label>
                                        <div>
                                            <telerik:radeditor runat="server" id="teAwardsContent" skin="Silk" width="100%"
                                                height="600px" contentfilters="none">
                                                <ImageManager ViewPaths="~/Portals/0/images"
                                                            UploadPaths="~/Portals/0/images"
                                                            DeletePaths="~/Portals/0/images"
                                                            EnableAsyncUpload="true"></ImageManager>
                                                   </telerik:radeditor>
                                          
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="AwardsContentDesc" runat="server" resourcekey="AwardsContentDesc"></asp:Label>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep9" runat="server">
                        <div class="row">
                            <div class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="Label2" runat="server" resourcekey="BlockScore"></asp:Label></legend>
                                    <p class="introduction">
                                        <asp:Label ID="Label4" runat="server" resourcekey="BlockScoreDesc"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblTitleScore" runat="server" resourcekey="lblTitle"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox ID="txtTitleScoring" runat="server"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <asp:RegularExpressionValidator runat="server" ID="revtxtTitleScore" ControlToValidate="txtTitleScoring"
                                                ValidationExpression="^[\s\S]{0,50}$" resourcekey="revLimit">
                                            </asp:RegularExpressionValidator>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="TitleScoreDesc" runat="server" resourcekey="TitleScoreDesc"></asp:Label>
                                        </div>
                                    </div>

                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep10" runat="server">
                        <div class="row">
                            <div class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label ID="BlockFinish" runat="server" resourcekey="BlockFinish"></asp:Label></legend>
                                    <p class="introduction">
                                        <asp:Label ID="BlockFinishDesc" runat="server" resourcekey="BlockFinishDesc"></asp:Label>
                                    </p>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblDictionary" runat="server" resourcekey="lblDictionary"></asp:Label>
                                        </label>
                                        <div>
                                            <div class="rfv">

                                                <asp:CustomValidator class="rfv" ID="cvtxtKey" runat="server" ValidationGroup="dictionary"
                                                    resourcekey="cvtxtKey"></asp:CustomValidator>
                                            </div>
                                            <telerik:radgrid runat="server" id="grdDictionary" allowfiltering="true" filtercontrolwidth="80" allowfilteringbycolumn="True" skin="Silk" onneeddatasource="RadGrid1_NeedDataSource"
                                                allowautomaticdeletes="True" allowautomaticupdates="True" allowpaging="True" allowsorting="True" pagesize="20" ondeletecommand="RadGrid1_DeleteCommand" onupdatecommand="RadGrid1_UpdateCommand" autogeneratecolumns="false" onsortcommand="grdRecentSolution_SortCommand">
                                            <GroupingSettings CaseSensitive="false" />
                                            <PagerStyle Mode="NextPrevAndNumeric" />
                                           
                                            <MasterTableView CommandItemDisplay="top" DataKeyNames="id">
                                                <Columns>

                                                    <telerik:GridEditCommandColumn ButtonType="ImageButton" UniqueName="EditCommandColumn">
                                                          <HeaderStyle Width="33px"></HeaderStyle>
                                                    </telerik:GridEditCommandColumn>
                                                    <telerik:GridBoundColumn DataField="id"  SortExpression="id" UniqueName="id" Display="false" >
                                                        
                                                   </telerik:GridBoundColumn>
                                                    <telerik:GridBoundColumn DataField="value1" HeaderText="Key" ColumnEditorID="GridTextBoxEditor">
                                                        <HeaderStyle Width="342px" />
                                                    </telerik:GridBoundColumn>
                                                    <telerik:GridBoundColumn DataField="value2" HeaderText="Value" ColumnEditorID="GridTextBoxEditor">
                                                        <HeaderStyle Width="669px" />
                                                    </telerik:GridBoundColumn>
                                                    <telerik:GridButtonColumn ConfirmText="Delete this item?" ButtonType="ImageButton"
                                                        CommandName="Delete" Text="Delete" UniqueName="DeleteColumn">
                                                        <HeaderStyle Width="33px"></HeaderStyle>
                                                      
                                                    </telerik:GridButtonColumn>
                                                </Columns>
                                                
                                                <EditFormSettings EditFormType="Template">
                                                  <EditColumn UniqueName="EditColumn"></EditColumn>
                                                <FormTemplate>
                                                          <table style="width: 80%; margin: 0 auto;" >
                                                      <tr>
                                                          <td>
                                                                 <asp:TextBox ID="txtID" Text='<%# Bind( "Id") %>' runat="server" Visible="false"></asp:TextBox>
                                         
                                                                 <div>
                                                                    <asp:Label runat="server" ID="lblKey" resourcekey="lblKey"></asp:Label>
                                                                 </div>
                                                                 <div>
                                                                    <asp:TextBox ID="txtKey" Text='<%# Bind( "value1") %>' runat="server"></asp:TextBox>
                                                                 </div>
                                                                  <div class="rfv">
                                                                    <asp:RequiredFieldValidator class="rfv" ID="rfvtxtKey" runat="server" ValidationGroup="dictionary"
                                                                        ControlToValidate="txtKey" resourcekey="rfvtxtKey"></asp:RequiredFieldValidator>
                                                                      <asp:CustomValidator class="rfv" ID="cvtxtKey" runat="server" ValidationGroup="dictionary"
                                                                        ControlToValidate="txtKey" resourcekey="cvtxtKey"></asp:CustomValidator>
                                                                 </div>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                          <td>
                                                                 <div>
                                                                    <asp:Label runat="server" ID="lblValue" resourcekey="lblValue"></asp:Label>
                                                                 </div>
                                                                 <div>
                                                                    <asp:TextBox ID="txtValue" Text='<%# Bind( "value2") %>' runat="server" ></asp:TextBox>
                                                                 </div>
                                                                  <div class="rfv">
                                                                    <asp:RequiredFieldValidator class="rfv" ID="rfvtxtValue" runat="server" ValidationGroup="dictionary"
                                                                        ControlToValidate="txtValue" resourcekey="rfvtxtValue"></asp:RequiredFieldValidator>
                                                                 </div>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                           <td>
                                                             <div class="divbtn" style="padding-bottom: 35px!important;">
                                                                 <asp:Button ID="btnCancelDictionary" runat="server" resourcekey="btnCancelDictionary" CssClass="bttn bttn-m bttn-alert"  CommandName="Cancel"  ValidationGroup="dictionarycancel"/>
                                                                   <asp:Button runat="server" CssClass="bttn bttn-m bttn-secondary btnS" resourcekey="btnAddDictionary" CommandName="Update" ID="btnAddDictionary" ValidationGroup="dictionary" autopostback="true" />
                                                              </div>                                                                
                                                          </td>
                                                        </tr>
                                                     </table>
                                                </FormTemplate>
                                                  </EditFormSettings>
                                              </MasterTableView>
                                          </telerik:radgrid>

                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="Label9" runat="server" resourcekey="lblPage"></asp:Label>
                                        </label>
                                        <asp:Repeater ID="rpPages" runat="server">
                                            <HeaderTemplate>
                                                <table class="table">
                                                    <th>
                                                        <td style="width: 10%; text-align: center;">
                                                            <asp:Label runat="server" ID="lblckSelectAll" resourcekey="ckSelectAll"></asp:Label><br />
                                                            <asp:CheckBox runat="server" ID="SelectAll" OnClick="SelectAll(this);" />
                                                        </td>
                                                        <td style="width: 30%; text-align: center;">
                                                            <h3>
                                                                <asp:Label runat="server" ID="lblHeaderName" resourcekey="lblHeaderName"></asp:Label></h3>
                                                        </td>
                                                        <td style="width: 60%; text-align: center;">
                                                            <h3>
                                                                <asp:Label runat="server" ID="lblHeaderUrl" resourcekey="lblHeaderUrl"></asp:Label></h3>
                                                        </td>
                                                    </th>
                                                </table>
                                                <ul>
                                            </HeaderTemplate>
                                            <FooterTemplate>
                                                </ul>
                                            </FooterTemplate>
                                            <ItemTemplate>
                                                <li>
                                                    <hr />
                                                    <table class="table" style="width: 100%;">

                                                        <tr>
                                                            <td style="width: 10%; text-align: center;">
                                                                <asp:CheckBox runat="server" OnClick='<%# String.Format("javascript:return CheckItem(this,\"{0}\")", Eval("id").ToString())%>' />
                                                            </td>
                                                            <td style="width: 30%">
                                                                <asp:Label runat="server" ID="lblName" Text='<%#Eval("value1")%>'></asp:Label>

                                                            </td>
                                                            <td style="width: 60%">
                                                                <asp:Label runat="server" ID="lblUrlEn" Text='<%#Eval("value2")%>'></asp:Label><br />
                                                                <asp:Label runat="server" ID="lblUrlEs" Text='<%#Eval("value3")%>'></asp:Label><br />
                                                                <asp:Label runat="server" ID="lblUrlPt" Text='<%#Eval("value4")%>'></asp:Label>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </li>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                        <div style="display: none;">

                                            <asp:Button ID="Button1" runat="server" OnClick="btnDeletePages_Click"></asp:Button>
                                            <asp:Button ID="Button2" runat="server" OnClick="btnGeneratePages_Click"></asp:Button>
                                        </div>
                                        <div class="divbtn">
                                            <asp:Button ID="btnDeletePages" runat="server" resourcekey="btnDeletePages" CssClass="bttn bttn-l bttn-alert" OnClientClick="return ConfirmationFinish(1);" />
                                            <asp:Button ID="btnGeneratePages" runat="server" resourcekey="btnGeneratePages" CssClass="bttn bttn-l bttn-secondary" OnClientClick="return ConfirmationFinish(2);" />
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                </WizardSteps>
            </asp:Wizard>
            <asp:HiddenField runat="server" ID="hfPhoto" />
            <asp:HiddenField runat="server" ID="hfImage" />
            <asp:HiddenField runat="server" ID="hfchkPage" />

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

<asp:HiddenField runat="server" ID="hfValidateChallenge" />


<script>



    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);
    function EndRequestHandler(sender, args) {
        setMaxLenght();

    }


    $(document).ready(function () {

        setMaxLenght();

    });
    function SelectAll(control) {

        var repeater = control.parentNode.parentNode.parentNode.parentNode.parentNode;
        var inputList = repeater.getElementsByTagName("input");


        for (var i = 0; i < inputList.length; i++) {
            if (inputList[i].type == "checkbox" && control != inputList[i]) {
                if (control.checked) {
                    inputList[i].click();
                    inputList[i].checked = true;
                } else {
                    inputList[i].click();
                    inputList[i].checked = false;
                }

            }
        }


    }

    function CheckItem(control, reference) {

        var text = $('#<%=hfchkPage.ClientID%>').val();
        if (control.checked) {
            if (text != '')
                $('#<%=hfchkPage.ClientID%>').val(text + ";" + reference);
            else
                $('#<%=hfchkPage.ClientID%>').val(reference);
        }
        else {
            if (text != '') {
                var txtNew = text.replace(";" + reference, "");
                txtNew = txtNew.replace(reference, "");
                $('#<%=hfchkPage.ClientID%>').val(txtNew);


            }
        }
    }
    function setMaxLenght() {

        $('#<%=txtTagLineHome.ClientID%>').maxlength($.extend({ max: 500, counterType: 'word' }, languages['<%=System.Threading.Thread.CurrentThread.CurrentCulture.ToString() %>']));
        $('#<%=txtCriteriaTagLine.ClientID%>').maxlength($.extend({ max: 500, counterType: 'word' }, languages['<%=System.Threading.Thread.CurrentThread.CurrentCulture.ToString() %>']));
        $('#<%=txtJudgesTagLine.ClientID%>').maxlength($.extend({ max: 500, counterType: 'word' }, languages['<%=System.Threading.Thread.CurrentThread.CurrentCulture.ToString() %>']));
        $('#<%=txtPartnersTagLine.ClientID%>').maxlength($.extend({ max: 500, counterType: 'word' }, languages['<%=System.Threading.Thread.CurrentThread.CurrentCulture.ToString() %>']));
        $('#<%=txtFAQTagLine.ClientID%>').maxlength($.extend({ max: 500, counterType: 'word' }, languages['<%=System.Threading.Thread.CurrentThread.CurrentCulture.ToString() %>']));
        $('#<%=txtTermsTagLine.ClientID%>').maxlength($.extend({ max: 500, counterType: 'word' }, languages['<%=System.Threading.Thread.CurrentThread.CurrentCulture.ToString() %>']));
        $('#<%=txtParticipateTagLine.ClientID%>').maxlength($.extend({ max: 500, counterType: 'word' }, languages['<%=System.Threading.Thread.CurrentThread.CurrentCulture.ToString() %>']));
        $('#<%=txtAwardsTagLine.ClientID%>').maxlength($.extend({ max: 500, counterType: 'word' }, languages['<%=System.Threading.Thread.CurrentThread.CurrentCulture.ToString() %>']));
    }

    function ConfirmationFinish(btn) {
        var messageConfirmation = "";
        var title = "";
        if (btn == 1) {
            messageConfirmation = '<%=Localization.GetString("DeletePageConfirmation", this.LocalResourceFile)%>';
            title = '<%=Localization.GetString("DeletePageTitle", this.LocalResourceFile)%>';
        }
        if (btn == 2) {
            messageConfirmation = '<%=Localization.GetString("GeneratePageConfirmation", this.LocalResourceFile)%>';
            title = '<%=Localization.GetString("GeneratePageTitle", this.LocalResourceFile)%>';
        }
        $.alerts.okButton = '<%=Localization.GetString("btnOk", this.LocalResourceFile)%>';
        $.alerts.cancelButton = '<%=Localization.GetString("btnCancel", this.LocalResourceFile)%>';
        jConfirm(messageConfirmation, title, function (r) {

            if (r) {
                if (btn == 1) {
                    document.getElementById('<%=Button1.ClientID%>').click();
                }
                if (btn == 2) {
                    document.getElementById('<%=Button2.ClientID%>').click();
                }
            }
        });
        return false;
    }

    function Confirmation(control, btn) {

        var messageConfirmation = "";
        var title = "";
        messageConfirmation = '<%=Localization.GetString("MessageConfirmation", this.LocalResourceFile)%>';
        title = '<%=Localization.GetString("DeleteTitle", this.LocalResourceFile)%>';

        $.alerts.okButton = '<%=Localization.GetString("btnOk", this.LocalResourceFile)%>';
        $.alerts.cancelButton = '<%=Localization.GetString("btnCancel", this.LocalResourceFile)%>';


        jConfirm(messageConfirmation, title, function (r) {

            if (r) {
                if (btn == 1) {
                    var att = $(control).attr('idElegibility');
                    $('#<%=idEditItemEligibility.ClientID%>').val(att);
                    document.getElementById('<%=lbDeleteEligiAux.ClientID%>').click();
                }
                if (btn == 2) {
                    var att = $(control).attr('idJudge');
                    $('#<%=idEditItemJudge.ClientID%>').val(att);
                    document.getElementById('<%=lbDeleteJudAux.ClientID%>').click();
                }
                if (btn == 3) {
                    var att = $(control).attr('idPartner');
                    $('#<%=hfPartners.ClientID%>').val(att);
                    document.getElementById('<%=lbDeletePartAux.ClientID%>').click();

                }
                if (btn == 4) {
                    var att = $(control).attr('idFaq');
                    $('#<%=idEditItemFAQ.ClientID%>').val(att);
                    document.getElementById('<%=lbDeleteFAQaux.ClientID%>').click();
                }
            }
        });
        return false;
    }

    function OpenPopUp(sw) {


        $('body').scrollTop(200);

        $('div.RadEditor.Default.reWrapper').css({ 'height': '474px', 'width': '100%' });


        if (sw == 1) {
            $('#<%=eligibilitymodal.ClientID%>').removeClass('invisible');

        }
        if (sw == 2) {
            $('#<%=judgemodal.ClientID%>').removeClass('invisible');

        }
        if (sw == 3) {
            $('#<%=faqmodal.ClientID%>').removeClass('invisible');
        }
        if (sw == 4) {
            $('#<%=partnermodal.ClientID%>').removeClass('invisible');
        }



        $('body').scrollTop(200);

        setTimeout(function () { $('body').scrollTop(200); }, 200);
        $('body').css({ 'overflow': 'hidden' });

    }
    function ClosePopUp(sw) {
        $('body').css({ 'overflow': 'auto' });

        if (sw == 1) {
            $('#<%=eligibilitymodal.ClientID%>').addClass('invisible');
        }
        if (sw == 2) {
            $('#<%=judgemodal.ClientID%>').addClass('invisible');

        }
        if (sw == 3) {
            $('#<%=faqmodal.ClientID%>').addClass('invisible');
        }
        if (sw == 4) {
            $('#<%=partnermodal.ClientID%>').addClass('invisible');

        }
    }

    function validateChallengeReference(events, args) {

        var combo = $find("<%=rdChallengeReference.ClientID%>");
        var name = document.getElementById("<%= txtChallengeReference.ClientID %>").value;
        var sw = validateCombo(combo, name, args);

        $('#<%=hfValidateChallenge.ClientID%>').val(sw);
        return sw;
    }

    function validateCombo(combo, name, args) {

        var items = combo.get_items();
        if (combo.get_text() != name) {
            for (var i = 0 ; i < items.get_count() ; i++) {

                if (items.getItem(i).get_text() == name && combo.get_text() != name) {
                    args.IsValid = false;
                    return false;
                }
            }
        }
        args.IsValid = true;
        return true;
    }





    window.validationFailed = function (radAsyncUpload, args) {
        var $row = $(args.get_row());
        var erorMessage = getErrorMessage(radAsyncUpload, args);
        var span = createError(erorMessage);
        $row.addClass("ruError");
        $row.append(span);
        $('#<%=lblPhotoEdit.ClientID%>').attr('Visible', 'false');
    }

    function getErrorMessage(sender, args) {
        var fileExtention = args.get_fileName().substring(args.get_fileName().lastIndexOf('.') + 1, args.get_fileName().length);
        if (args.get_fileName().lastIndexOf('.') != -1) {//this checks if the extension is correct
            if (sender.get_allowedFileExtensions().indexOf(fileExtention) == -1) {
                return ("This file type is not supported.");
            }
            else {
                return ("This file exceeds the maximum allowed size of 500 KB.");
            }
        }
        else {
            return ("not correct extension.");
        }
    }

    function createError(erorMessage) {
        var input = '<span class="ruErrorMessage">' + erorMessage + ' </span>';
        return input;
    }


</script>
