<%@ Control Language="C#" AutoEventWireup="true" CodeFile="NZMailer.ascx.cs" Inherits="NZMailer" %>
<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<%@ Register TagPrefix="dnn" TagName="TextEditor" Src="~/controls/TextEditor.ascx" %>
<div class="mailer-form">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:Wizard runat="server" ID="wizardCampaign" Width="100%" ActiveStepIndex="0" DisplaySideBar="False"
                OnNextButtonClick="wizardCampaign_NextButtonClick" OnFinishButtonClick="wizardCampaign_FinishButtonClick">
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
                    <asp:WizardStep ID="WizardStep1" Title="Step 1" runat="server">
                        <div style="display: none">
                            <telerik:radslider runat="server" cssclass="rdControl" id="RadSlider1" />
                        </div>
                        <div class="row">
                            <div class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label runat="server" ID="lblCampaignConfiguration" resourcekey="CampaignConfiguration"></asp:Label>
                                    </legend>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblCampaign" runat="server" resourcekey="Campaign"></asp:Label>
                                        </label>
                                        <div>
                                            <div class="RadCombo">
                                                <telerik:radcombobox id="ddCampaign" runat="server" datatextfield="CampaignName"
                                                    cssclass="radInput" datavaluefield="CampaignId" allowcustomtext="true" autopostback="true"
                                                    ontextchanged="RadComboBox_TextChangedCampaign" width="100%">
                                                </telerik:radcombobox>
                                            </div>
                                            <div class="support-text">
                                                <asp:Label ID="Label60" runat="server" resourcekey="CampaignDesc"></asp:Label>
                                            </div>
                                            <div class="rfv">
                                                <asp:RequiredFieldValidator class="rfv" ID="rfvddCampaignn" runat="server" ControlToValidate="ddCampaign"
                                                    resourcekey="rfvddCampaign" InitialValue=""></asp:RequiredFieldValidator>
                                            </div>

                                        </div>
                                        <div runat="server" id="divEditCampaign" visible="false">
                                            <asp:HyperLink ID="hlReport" runat="server" resourcekey="hlReport" Visible="false" />
                                            <div class="field">
                                                <label>
                                                    <asp:Label runat="server" ID="lblCampaignName" resourcekey="CampaignName"></asp:Label>
                                                </label>
                                                <div>
                                                    <asp:TextBox ID="txtCampaignName" runat="server"></asp:TextBox>
                                                </div>
                                                <div class="support-text">
                                                    <asp:Label ID="Label1" runat="server" resourcekey="CampaignNameDesc"></asp:Label>
                                                </div>
                                                <div class="rfv">
                                                    <asp:RequiredFieldValidator ID="rfvtxtCampaignName" runat="server" ValidationGroup="campaign"
                                                        ControlToValidate="txtCampaignName" resourcekey="rfvtxtCampaignName"></asp:RequiredFieldValidator>
                                                    <asp:CustomValidator ID="cvrfvtxtCampaignName" runat="server" ControlToValidate="txtCampaignName" ClientValidationFunction="validateCampaign"
                                                        resourcekey="cvrfvtxtCampaignName" ValidationGroup="campaign"></asp:CustomValidator>
                                                </div>
                                            </div>
                                            <div class="field">
                                                <label>
                                                    <asp:Label runat="server" ID="lblCampaignTemplate" resourcekey="CampaignTemplate"></asp:Label>
                                                </label>
                                                <div class="RadCombo">
                                                    <telerik:radcombobox id="ddCampaignTemplate" runat="server" datatextfield="TemplateTitle" validationgroup="campaignTemplate"
                                                        cssclass="radInput" datavaluefield="TemplateId" allowcustomtext="true" autopostback="true"
                                                        ontextchanged="RadComboBox1_TextChanged" width="100%">
                                                    </telerik:radcombobox>
                                                    <asp:LinkButton runat="server" ID="linkButtonTemplate" collapse="true" OnClick="linkButtonTemplate_Click" ValidationGroup="campaignTemplate">
                                          
                                                    </asp:LinkButton>
                                                </div>
                                                <div class="support-text">
                                                    <asp:Label ID="Label2" runat="server" resourcekey="CampaignTemplateDesc"></asp:Label>
                                                </div>
                                                <div class="rfv">
                                                    <asp:RequiredFieldValidator class="rfv" ID="rfvddCampaignTemplate" runat="server" InitialValue="" ValidationGroup="campaign"
                                                        ControlToValidate="ddCampaignTemplate" resourcekey="rfvddCampaignTemplate"></asp:RequiredFieldValidator>
                                                </div>

                                                <div class="CampaignTemplate" runat="server" id="divEditTemplate" visible="false">
                                                    <hr />
                                                    <div class="row">
                                                        <div class="wizard-form">
                                                            <div class="field">
                                                                <label>
                                                                    <asp:Label ID="lblTemplateName" runat="server" resourcekey="TemplateName"></asp:Label>
                                                                </label>
                                                                <div>
                                                                    <asp:TextBox ID="txtTemplateName" runat="server"></asp:TextBox>
                                                                </div>
                                                                <div class="support-text">
                                                                    <asp:Label ID="Label19" runat="server" resourcekey="TemplateNameDesc"></asp:Label>
                                                                </div>
                                                                <div class="rfv">
                                                                    <asp:RequiredFieldValidator ID="rfvtxtTemplateName" runat="server" ValidationGroup="template"
                                                                        ControlToValidate="txtTemplateName" resourcekey="rfvtxtTemplateName"></asp:RequiredFieldValidator>
                                                                    <asp:CustomValidator ID="cvtxtTemplateName" runat="server" ControlToValidate="txtTemplateName" ValidationGroup="template"
                                                                        ClientValidationFunction="validateCampaignTemplate" resourcekey="cvtxtTemplateName"></asp:CustomValidator>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="wizard-form">
                                                            <div class="field">
                                                                <label>
                                                                    <asp:Label ID="lblTemplateVersion" runat="server" resourcekey="Version"></asp:Label>
                                                                </label>
                                                                <div>
                                                                    <asp:Label ID="lbTemplateVersion" runat="server"></asp:Label>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="wizard-form">
                                                            <div class="field">
                                                                <label>
                                                                    <asp:Label ID="lblTemplateLanguage" runat="server" resourcekey="Language"></asp:Label>
                                                                </label>
                                                                <div class="RadCombo">
                                                                    <telerik:radcombobox id="rdTemplateLanguage" runat="server" datatextfield="Label" width="100%"
                                                                        cssclass="radInput" datavaluefield="Key" allowcustomtext="true" enablecheckallitemscheckbox="true">
                                                                    </telerik:radcombobox>
                                                                </div>
                                                                <div class="support-text">
                                                                    <asp:Label ID="Label21" runat="server" resourcekey="TemplateLanguageDesc"></asp:Label>
                                                                </div>
                                                                <div class="rfv">
                                                                    <asp:RequiredFieldValidator ID="rfvtxtLanguage" runat="server" ValidationGroup="template"
                                                                        ControlToValidate="rdTemplateLanguage" resourcekey="rfvtxtLanguage"></asp:RequiredFieldValidator>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="wizard-form">
                                                            <div class="field">
                                                                <label>
                                                                    <asp:Label ID="Label23" runat="server" resourcekey="TemplateSubject"></asp:Label>
                                                                </label>
                                                                <div>
                                                                    <asp:TextBox ID="txtSubject" runat="server"></asp:TextBox>
                                                                </div>
                                                                <div class="support-text">
                                                                    <asp:Label ID="Label24" runat="server" resourcekey="TemplateSubjectDesc"></asp:Label>
                                                                </div>
                                                                <div class="rfv">
                                                                    <asp:RequiredFieldValidator ID="rfvtxtTemplateSubject" runat="server" ValidationGroup="template"
                                                                        ControlToValidate="txtSubject" resourcekey="rfvtxtTemplateSubject"></asp:RequiredFieldValidator>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="wizard-form">
                                                            <div class="field">
                                                                <label>
                                                                    <asp:Label ID="Label13" runat="server" resourcekey="EmailTemplate"></asp:Label>
                                                                </label>
                                                                <a onclick="javascript:ToggleHelp($(this))">
                                                                    <asp:Label ID="Label22" runat="server" resourcekey="ToggleHelp"></asp:Label>
                                                                </a>
                                                                <div>

                                                                    <telerik:radeditor runat="server" id="RadEditorTemplate" skin="Silk" Width="100%" Height="600px"
                                                                         contentfilters="none">

                                                                        <ImageManager ViewPaths="~/Portals/0/images"
                                                                                    UploadPaths="~/Portals/0/images"
                                                                                    DeletePaths="~/Portals/0/images"
                                                                                    EnableAsyncUpload="true"></ImageManager>

                                                                    </telerik:radeditor>
                                                                    <%-- <dnn:TextEditor ID="RadEditorTemplate" Mode="BASIC" HtmlEncode="False" Enable="true" runat="server" Width="100%" Height="300px">
                                                                        <richtext></richtext>
                                                                    </dnn:TextEditor>--%>
                                                                </div>
                                                                <div class="support-text">
                                                                    <asp:Label ID="Label20" runat="server" resourcekey="EmailTemplateContentDesc"></asp:Label>
                                                                </div>
                                                                <div class="rfv">
                                                                    <asp:RequiredFieldValidator ID="rfvtxtContent" runat="server" ValidationGroup="template"
                                                                        ControlToValidate="RadEditorTemplate" resourcekey="rfvtxtContent"></asp:RequiredFieldValidator>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>

                            <div class="field">
                                <div class="CampaignTemplate" runat="server" id="divEditTemplate2" visible="false">
                                    <asp:Button ID="btnSaveTemplate" runat="server" resourcekey="BtnSaveTemplate" OnClick="btnSaveTemplate_Click" ValidationGroup="template" OnClientClick="if ( ! SaveConfirmation()) return false;" />
                                    <asp:Button ID="btnCloneTemplate" runat="server" resourcekey="BtnCloneTemplate" OnClick="btnCloneTemplate_Click" ValidationGroup="template" />
                                    <asp:Button ID="btnDeleteTemplate" runat="server" resourcekey="BtnDeleteTemplate" ValidationGroup="templateDelete"
                                        OnClick="btnDeleteTemplate_Click" OnClientClick="if ( ! DeleteConfirmation(0)) return false;" />
                                    <br />
                                </div>
                            </div>
                            <div class="wizard-form">
                                <fieldset>
                                    <div class="field">
                                        <div runat="server" id="divEditCampaign2" visible="false">
                                            <div class="field">
                                                <label>
                                                    <asp:Label runat="server" ID="lblDescription" resourcekey="Description"></asp:Label>
                                                </label>
                                                <div>
                                                    <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine"></asp:TextBox>
                                                </div>
                                                <div class="support-text">
                                                    <asp:Label ID="Label3" runat="server" resourcekey="DescriptionDesc"></asp:Label>
                                                </div>
                                                <div class="rfv">
                                                    <asp:RequiredFieldValidator class="rfv" ID="rfvtxtDescription" runat="server" ValidationGroup="campaign"
                                                        ControlToValidate="txtDescription" resourcekey="rfvtxtDescription"></asp:RequiredFieldValidator>
                                                </div>
                                            </div>
                                            <div class="field">
                                                <label>
                                                    <asp:Label runat="server" ID="lblSendOn" resourcekey="SendOn"></asp:Label>
                                                </label>
                                                <div>
                                                    <telerik:raddatetimepicker runat="server" id="RadDatePicker1">
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
                                                    <asp:Label ID="Label4" runat="server" resourcekey="SendOnDesc"></asp:Label>
                                                </div>
                                                <div class="rfv">
                                                    <asp:RequiredFieldValidator class="rfv" ID="rfvRadDatePicker1" runat="server" ValidationGroup="campaign"
                                                        ControlToValidate="RadDatePicker1" resourcekey="rfvRadDatePicker1"></asp:RequiredFieldValidator>
                                                </div>
                                            </div>
                                            <div class="field">
                                                <label>
                                                    <asp:Label runat="server" ID="lblRepeat" resourcekey="Repeat"></asp:Label>
                                                </label>
                                                <div>
                                                    <asp:RadioButtonList ID="rdbRepeat" DataTextField="Label" DataValueField="Value"
                                                        runat="server" RepeatDirection="Horizontal" TextAlign="Right" CssClass="radiobuttonlisttop">
                                                    </asp:RadioButtonList>
                                                </div>
                                                <div class="support-text">
                                                    <asp:Label ID="Label5" runat="server" resourcekey="RepeatDesc"></asp:Label>
                                                </div>
                                                <div class="rfv">
                                                    <asp:RequiredFieldValidator class="rfv" ID="rfvrdbRepeat" runat="server" ValidationGroup="campaign"
                                                        ControlToValidate="rdbRepeat" resourcekey="rfvrdbRepeat"></asp:RequiredFieldValidator>
                                                </div>
                                            </div>
                                            <div class="field">
                                                <label>
                                                    <asp:Label runat="server" ID="lblStatus" resourcekey="Status"></asp:Label>
                                                </label>
                                                <div>
                                                    <asp:RadioButtonList ID="rdbStatus" DataTextField="Label" DataValueField="Label"
                                                        runat="server" RepeatDirection="Horizontal" TextAlign="Right" CssClass="radiobuttonlisttop">
                                                    </asp:RadioButtonList>
                                                </div>
                                                <div class="support-text">
                                                    <asp:Label ID="Label6" runat="server" resourcekey="StatusDesc"></asp:Label>
                                                </div>
                                                <div class="rfv">
                                                    <asp:RequiredFieldValidator class="rfv" ID="rfvrdbStatus" runat="server" ValidationGroup="campaign"
                                                        ControlToValidate="rdbStatus" resourcekey="rfvrdbStatus"></asp:RequiredFieldValidator>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                            <div runat="server" id="divActionPanel" visible="false">
                                <asp:Button ID="btnSaveCampaign" runat="server" resourcekey="BtnSaveCampaign" OnClick="btnSaveCampaign_Click" ValidationGroup="campaign" />
                                <asp:Button ID="btnDeletedCampaign" runat="server" resourcekey="BtnDeleteCampaign" ValidationGroup="campaignDelete"
                                    OnClick="btnDeletedCampaign_Click" OnClientClick="if ( ! DeleteConfirmation(1)) return false;" />
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep2" runat="server">
                        <div class="row">
                            <div class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label runat="server" ID="Label49" resourcekey="Exceptions"></asp:Label>
                                    </legend>
                                    <div class="field">
                                        <label>
                                            <asp:Label runat="server" ID="Label50" resourcekey="Exclude"></asp:Label>
                                        </label>
                                        <div class="RadCombo">
                                            <telerik:radcombobox id="ddCampaignExclude" runat="server" checkboxes="true" width="100%"
                                                datatextfield="CampaignName" cssclass="radInput" datavaluefield="CampaignId" allowcustomtext="true"
                                                enablecheckallitemscheckbox="true">
                                            </telerik:radcombobox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label51" runat="server" resourcekey="CampaignExcludeDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label runat="server" ID="Label52" resourcekey="Include"></asp:Label>
                                        </label>
                                        <div class="RadCombo">
                                            <telerik:radcombobox id="ddCampaignInclude" runat="server" checkboxes="true" width="100%"
                                                datatextfield="CampaignName" cssclass="radInput" datavaluefield="CampaignId" allowcustomtext="true"
                                                enablecheckallitemscheckbox="true">
                                            </telerik:radcombobox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label53" runat="server" resourcekey="CampaignIncludeDesc"></asp:Label>
                                        </div>
                                    </div>
                                </fieldset>

                            </div>
                        </div>

                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep3" Title="Step 2" runat="server">
                        <div class="row">
                            <div class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label runat="server" ID="Label39" resourcekey="NexsoPotentialUserSelector"></asp:Label>
                                    </legend>
                                    <div class="field">
                                        <label>
                                            <asp:Label runat="server" ID="Label40" resourcekey="SelectPotentialUserTable"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:RadioButtonList ID="rdUsePotentialUsers" DataTextField="Label" DataValueField="Value"
                                                RepeatDirection="Horizontal" TextAlign="Right" runat="server" CssClass="radiobuttonlisttop">
                                            </asp:RadioButtonList>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label41" runat="server" resourcekey="SelectPotentialUserTableDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field" style="display: none;">
                                        <label>
                                            <asp:Label runat="server" ID="Label42" resourcekey="SelectCountry"></asp:Label>
                                        </label>
                                        <div class="RadCombo">
                                            <telerik:radcombobox id="rdPotentialUserCountry" runat="server" checkboxes="true" datatextfield="country"
                                                cssclass="radInput" datavaluefield="code" allowcustomtext="true" enablecheckallitemscheckbox="true" width="100%">
                                            </telerik:radcombobox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label43" runat="server" resourcekey="CountryPotentialUserDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field" style="display: none;">
                                        <label>
                                            <asp:Label ID="Label44" runat="server" resourcekey="Language"></asp:Label>
                                        </label>
                                        <div class="RadCombo">
                                            <telerik:radcombobox id="rdPotentialUserLanguage" runat="server" checkboxes="true" datatextfield="Label"
                                                cssclass="radInput" datavaluefield="value" allowcustomtext="true" enablecheckallitemscheckbox="true" width="100%">
                                            </telerik:radcombobox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label45" runat="server" resourcekey="LanguagePotentialUserDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label runat="server" ID="Label46" resourcekey="PotentialUserSource"></asp:Label>
                                        </label>
                                        <div class="RadCombo">
                                            <telerik:radcombobox id="rdPotentialUserSource" runat="server" checkboxes="true" allowcustomtext="true" width="100%"
                                                cssclass="radInput" enablecheckallitemscheckbox="true">
                                            </telerik:radcombobox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label47" runat="server" resourcekey="PotentialUserSourceDesc"></asp:Label>
                                        </div>
                                    </div>

                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep4" Title="Step 2" runat="server">
                        <div class="row">
                            <div class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label runat="server" ID="lblNexsoUserSelector" resourcekey="NexsoUserSelector"></asp:Label>
                                    </legend>
                                    <div class="field">
                                        <label>
                                            <asp:Label runat="server" ID="Label25" resourcekey="SelectUserTable"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:RadioButtonList ID="rdUseUser" DataTextField="Label" DataValueField="Value"
                                                RepeatDirection="Horizontal" TextAlign="Right" runat="server" CssClass="radiobuttonlisttop">
                                            </asp:RadioButtonList>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label26" runat="server" resourcekey="SelectUserTableDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label runat="server" ID="lblCountry" resourcekey="SelectCountry"></asp:Label>
                                        </label>
                                        <div class="RadCombo">
                                            <telerik:radcombobox id="ddUserCountry" runat="server" checkboxes="true" datatextfield="country" width="100%"
                                                cssclass="radInput" datavaluefield="code" allowcustomtext="true" enablecheckallitemscheckbox="true">
                                            </telerik:radcombobox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label8" runat="server" resourcekey="CountryUserDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblLanguage" runat="server" resourcekey="Language"></asp:Label>
                                        </label>
                                        <div class="RadCombo">
                                            <telerik:radcombobox id="ddUserLanguage" runat="server" checkboxes="true" datatextfield="Label" width="100%"
                                                cssclass="radInput" datavaluefield="value" allowcustomtext="true" enablecheckallitemscheckbox="true">
                                            </telerik:radcombobox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label7" runat="server" resourcekey="LanguageUserDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field" style="display: none;">
                                        <label>
                                            <asp:Label runat="server" ID="lblCustomerType" resourcekey="CustomerType"></asp:Label>
                                        </label>
                                        <div class="RadCombo">
                                            <telerik:radcombobox id="ddUserCustomerType" runat="server" checkboxes="true" allowcustomtext="true" width="100%"
                                                cssclass="radInput" datatextfield="Label" datavaluefield="Value" enablecheckallitemscheckbox="true">
                                            </telerik:radcombobox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label9" runat="server" resourcekey="CustomerTypeDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblInterest" runat="server" resourcekey="Interest"></asp:Label>
                                        </label>
                                        <div class="RadCombo">
                                            <telerik:radcombobox id="ddUserTheme" runat="server" checkboxes="true" datatextfield="Label" width="100%"
                                                cssclass="radInput" datavaluefield="Key" allowcustomtext="true" enablecheckallitemscheckbox="true">
                                            </telerik:radcombobox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label10" runat="server" resourcekey="InterestUserDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblBeneficiaries" runat="server" resourcekey="Beneficiaries"></asp:Label>
                                        </label>
                                        <div class="RadCombo">
                                            <telerik:radcombobox id="ddUserBeneficiaries" runat="server" checkboxes="true" datatextfield="Label" width="100%"
                                                cssclass="radInput" datavaluefield="Key" allowcustomtext="true" enablecheckallitemscheckbox="true">
                                            </telerik:radcombobox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label11" runat="server" resourcekey="BeneficiariesUserDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label runat="server" ID="lblNotifications" resourcekey="Authorization"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:RadioButtonList ID="rbNotifications" DataTextField="Label" DataValueField="Value"
                                                RepeatDirection="Horizontal" TextAlign="Right" runat="server" CssClass="radiobuttonlisttop">
                                            </asp:RadioButtonList>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label12" runat="server" resourcekey="NotificationAuthorizationDesc"></asp:Label>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep5" Title="Step 1" runat="server">
                        <div class="row">
                            <div class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label runat="server" ID="lblOrganizationSelector" resourcekey="OrganizationSelector"></asp:Label>
                                    </legend>
                                    <div class="field">
                                        <label>
                                            <asp:Label runat="server" ID="Label27" resourcekey="SelectOrganizationTable"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:RadioButtonList ID="rdUseOrganization" DataTextField="Label" DataValueField="Value"
                                                RepeatDirection="Horizontal" TextAlign="Right" runat="server" CssClass="radiobuttonlisttop">
                                            </asp:RadioButtonList>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label28" runat="server" resourcekey="SelectOrganizationTableDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label runat="server" ID="lblCountry2" resourcekey="SelectCountry"></asp:Label>
                                        </label>
                                        <div class="RadCombo">
                                            <telerik:radcombobox id="ddOrganizationCountry" runat="server" checkboxes="true" width="100%"
                                                datatextfield="country" cssclass="radInput" datavaluefield="code" allowcustomtext="true"
                                                enablecheckallitemscheckbox="true">
                                            </telerik:radcombobox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label14" runat="server" resourcekey="CountryOrganizationDesc"></asp:Label>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep6" Title="Step 2" runat="server">
                        <div class="row">
                            <div class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label runat="server" ID="lblSolutionSelector" resourcekey="SolutionSelector"></asp:Label>
                                    </legend>
                                    <div class="field">
                                        <label>
                                            <asp:Label runat="server" ID="Label29" resourcekey="SelectSolutionTable"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:RadioButtonList ID="rdUseSolution" DataTextField="Label" DataValueField="Value"
                                                RepeatDirection="Horizontal" TextAlign="Right" runat="server" CssClass="radiobuttonlisttop">
                                            </asp:RadioButtonList>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label30" runat="server" resourcekey="SelectSolutionTableDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblLanguage2" runat="server" resourcekey="Language"></asp:Label>
                                        </label>
                                        <div class="RadCombo">
                                            <telerik:radcombobox id="ddSolutionLanguage" runat="server" datatextfield="Label" width="100%"
                                                datavaluefield="Key" cssclass="radInput" allowcustomtext="true" checkboxes="true"
                                                enablecheckallitemscheckbox="true">
                                            </telerik:radcombobox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label15" runat="server" resourcekey="LanguageSolutionDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label runat="server" ID="lblWordCounter" resourcekey="WordCounter"></asp:Label>
                                        </label>
                                        <div class="rdControl">


                                            <telerik:radslider runat="server" width="300px" height="50px" orientation="Horizontal" id="rsWordCounter" enableserversiderendering="true"
                                                isselectionrangeenabled="true" selectionstart="0" selectionend="700" minimumvalue="0"
                                                maximumvalue="700" smallchange="50" largechange="100" itemtype="Tick" trackposition="TopLeft">
                                            </telerik:radslider>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label16" runat="server" resourcekey="WordCounterDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label runat="server" ID="lblRate" resourcekey="Rate"></asp:Label>
                                        </label>
                                        <div class="rdControl">
                                            <telerik:radslider runat="server" cssclass="rdControl" width="300px" height="50px" id="RadSliderRate" trackposition="TopLeft"
                                                isselectionrangeenabled="true" selectionstart="0" selectionend="100" minimumvalue="0"
                                                maximumvalue="100" smallchange="5" largechange="10" enableserversiderendering="true" itemtype="Tick">
                                            </telerik:radslider>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label17" runat="server" resourcekey="RateDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="Label31" runat="server" resourcekey="SolutionState"></asp:Label>
                                        </label>
                                        <div class="RadCombo">
                                            <telerik:radcombobox id="rdSolutionState" runat="server" datatextfield="Label" datavaluefield="Value" width="100%"
                                                cssclass="radInput" allowcustomtext="true" checkboxes="true" enablecheckallitemscheckbox="true">
                                            </telerik:radcombobox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label32" runat="server" resourcekey="SolutionStateDesc"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label ID="Label33" runat="server" resourcekey="SolutionChallenge"></asp:Label>
                                        </label>
                                        <div class="RadCombo">
                                            <telerik:radcombobox id="rdChallenge" runat="server" cssclass="radInput" allowcustomtext="true"
                                                checkboxes="true" enablecheckallitemscheckbox="true" width="100%">
                                            </telerik:radcombobox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label34" runat="server" resourcekey="SolutionChallengeDesc"></asp:Label>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="WizardStep7" Title="Step 1" runat="server">
                        <div class="row">
                            <div class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label runat="server" ID="lblUserTest" resourcekey="lblUserTest"></asp:Label>
                                    </legend>
                                    <div class="field">
                                        <label>
                                            <asp:Label runat="server" ID="Label18" resourcekey="lblUserTestMessage"></asp:Label>
                                        </label>
                                    </div>

                                    <div class="field">
                                        <label>
                                            <asp:Label ID="lblUser" runat="server" resourcekey="lblUser"></asp:Label>
                                        </label>
                                        <div class="RadCombo">
                                            <telerik:radcombobox id="ddUser" runat="server" cssclass="radInput" allowcustomtext="true"
                                                checkboxes="true" enablecheckallitemscheckbox="true" width="100%" datatextfield="FirstName" datavaluefield="UserID">
                                            </telerik:radcombobox>
                                        </div>
                                        <div class="support-text">
                                            <asp:Label ID="Label48" runat="server" resourcekey="UserDesc"></asp:Label>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>
                    <%--<asp:WizardStep ID="WizardStep6" Title="Step 1" runat="server">
                        <div class="row">
                            <div class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label runat="server" ID="lblAdditionalRecipients" resourcekey="AdditionalRecipients"></asp:Label>
                                    </legend>
                                    <div class="field">
                                        <label>
                                            <asp:Label runat="server" ID="lblMail" resourcekey="Mail"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:TextBox ID="txtAdditionalRecipients" runat="server" CssClass="WideText" TextMode="MultiLine"></asp:TextBox>
                                            <div class="support-text">
                                                <asp:Label ID="Label18" runat="server" resourcekey="AdditionalRecipientsDesc"></asp:Label>
                                            </div>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                        </div>
                    </asp:WizardStep>--%>
                    <asp:WizardStep ID="WizardStep8" Title="Step 2" runat="server">
                        <div class="row">
                            <div class="wizard-form">
                                <fieldset>
                                    <legend>
                                        <asp:Label runat="server" ID="Label35" resourcekey="Preview"></asp:Label>
                                    </legend>
                                    <div class="field">
                                        <label>
                                            <asp:Label runat="server" ID="Label36" resourcekey="resultsPreview"></asp:Label>
                                        </label>
                                        <div>
                                            <asp:Label ID="lblResult" runat="server" Text=""></asp:Label>
                                        </div>
                                        <br />

                                    </div>
                                    <div class="field">
                                        <label>
                                            <asp:Label runat="server" ID="Label37" resourcekey="samplePreview"></asp:Label>
                                        </label>

                                        <div>
                                            <asp:GridView ID="grdPreviewList" PageSize="40" AutoGenerateColumns="False" Width="100%"
                                                runat="server">
                                                <Columns>
                                                    <asp:TemplateField HeaderText="Sample">
                                                        <ItemTemplate>
                                                            <br />
                                                            <br />
                                                            <br />
                                                            <div>
                                                                <strong>
                                                                    <asp:Label runat="server" ID="Label37" resourcekey="Subject"></asp:Label>
                                                                    (
                                                                    <%#Eval("Email") %>
                                                                    )</strong><br />
                                                                <%#Eval("MailSubject") %>
                                                            </div>
                                                            <hr />
                                                            <div>
                                                                <strong>
                                                                    <asp:Label runat="server" ID="Label38" resourcekey="Body"></asp:Label></strong><br />
                                                                <div>
                                                                    <iframe height="600px" width="100%" src="<%#NexsoHelper.GetCulturedUrlByTabName("testnxmailpreviewpage")+"?nx="+Eval("CampaignLogId").ToString()%>"></iframe>
                                                                    <%-- <%#Eval("MailContent") %>--%>
                                                                </div>
                                                            </div>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                            <asp:Button ID="btnTest" runat="server" resourcekey="BtnTestCampaign" OnClick="btnTestCampaign_Click" />
                        </div>
                    </asp:WizardStep>
                </WizardSteps>
            </asp:Wizard>
            <asp:HiddenField ID="hdSelector" runat="server" />
            <asp:HiddenField ID="HiddenFieldMessage" runat="server" />

        </ContentTemplate>
    </asp:UpdatePanel>
</div>
<link href="<%=ControlPath%>css/module.css" rel="stylesheet" />
<script src="<%=ControlPath%>js/module.js"></script>
<script src="<%=ControlPath%>js/jquery.uniform.min.js"></script>


<script type="text/javascript">

    function DeleteConfirmation(idMessage) {
        var messageConfirmation = "";
        if (idMessage == 0)
            messageConfirmation = '<%=Localization.GetString("ConfirmationTemplateDelete", this.LocalResourceFile)%>';
        else
            messageConfirmation = '<%=Localization.GetString("ConfirmationCampaignDelete", this.LocalResourceFile)%>';
        return confirm(messageConfirmation);
    }

    function SaveConfirmation() {
        var messageConfirmation = "";
        var combo = $find("<%=ddCampaignTemplate.ClientID%>");
        if (combo.get_text() != '<%=Localization.GetString("NewTemplate", this.LocalResourceFile)%>') {
            messageConfirmation = '<%=Localization.GetString("ConfirmationTemplateSave", this.LocalResourceFile)%>';
            return confirm(messageConfirmation);
        }
        return true;
    }

    SetUniform();

    $(document).ready(function () {

        SetShowHideSupportText();
    });

    function MessageAlert() {
        var message = $('#<%=HiddenFieldMessage.ClientID%>').val();

        alert(message);

    }

    function validateCampaign(events, args) {

        var combo = $find("<%=ddCampaign.ClientID%>");
        var name = document.getElementById("<%= txtCampaignName.ClientID %>").value;
        validateCombo(combo, name, args);
    }
    function validateCampaignTemplate(events, args) {

        var combo = $find("<%=ddCampaignTemplate.ClientID%>");
        var name = document.getElementById("<%= txtTemplateName.ClientID %>").value;
        validateCombo(combo, name, args);
    }

    function validateCombo(combo, name, args) {

        var items = combo.get_items();
        if (combo.get_text() != name) {
            for (var i = 0 ; i < items.get_count() ; i++) {

                if (items.getItem(i).get_text() == name && combo.get_text() != name) {
                    args.IsValid = false;
                    return;
                }
            }
        }

        args.IsValid = true;

    }
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);
    function EndRequestHandler(sender, args) {

        SetShowHideSupportText();

        SetUniform();
    }

</script>