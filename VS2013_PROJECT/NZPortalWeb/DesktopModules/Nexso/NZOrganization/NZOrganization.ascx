<%@ Control Language="C#" AutoEventWireup="true" CodeFile="NZOrganization.ascx.cs"
    Inherits="NZOrganization" %>
<%@ Register Src="../NXOtherControls/CountryStateCityV2.ascx" TagName="CountryStateCity"
    TagPrefix="uc1" %>
<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<link href="<%=ControlPath%>css/jquery.maxlength.css" rel="stylesheet" type="text/css"
    media="screen" />
<link href="<%=ControlPath%>css/module.css" rel="stylesheet" type="text/css" />
<asp:Label runat="server" ID="lblCount"></asp:Label>
<div class="organization sidebar-layout">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div runat="server" id="ViewPanel" visible="False">
                <article class="organization-page">
                    <div class="row">
                        <div class="banner-wrapper">
                            <uc1:CountryStateCity ID="CountryStateCityViewMode" EditMode="False" runat="server" />
                        </div>
                    </div>
                    <div class="row">
                        <div class="content-wrapper">     
                            <asp:HiddenField ID="HiddenFieldCurrentWords" runat="server" />
                            <input id="btnTranslate" class="btn" type="button" value="Translate" onclick="javascript: translateAll();" />
                            <h1 class="title">
                                <asp:Label ID="lblInstitutionNameTxt" runat="server"></asp:Label>
                                <asp:Label runat="server" ID="hfInstitutionNameTxt" />
                            </h1>
                            <asp:Label runat="server" ID="MessageTransalte"></asp:Label>
                            <h3 class="label">
                                <asp:Label ID="lblChallengeTitle" runat="server" resourcekey="Biografy"></asp:Label>
                            </h3>
                            <p>
                                <asp:Label ID="lblDesciptionTxt" runat="server"></asp:Label>
                            </p>
                        </div>
                        <aside>
                            <div class="media-wrapper">
                                <asp:Image ID="imgInstitution2" runat="server" />
                            </div>
                            <h1>
                                <asp:Label ID="Label14" runat="server" resourcekey="InstitutionalInformation"></asp:Label>
                            </h1> 
                            <dl>
                                <dt>
                                    <asp:Label ID="Label15" runat="server" resourcekey="Address"></asp:Label></dt>
                                <dd>
                                    <asp:Label ID="lblAddress" runat="server" Text="Label"></asp:Label></dd>
                                <dt>
                                    <asp:Label ID="Label16" runat="server" resourcekey="City"></asp:Label></dt>
                                <dd>
                                    <asp:Label ID="lblCity" runat="server" Text="Label"></asp:Label></dd>
                                <dt>
                                    <asp:Label ID="Label17" runat="server" resourcekey="State"></asp:Label></dt>
                                <dd>
                                    <asp:Label ID="lblState" runat="server" Text="Label"></asp:Label></dd>
                                <dt>
                                    <asp:Label ID="Label18" runat="server" resourcekey="Country"></asp:Label></dt>
                                <dd>
                                    <asp:Label ID="lblCountry" runat="server" Text="Label"></asp:Label></dd>
                                <dt>
                                    <asp:Label ID="Label13" runat="server" resourcekey="Phone2"></asp:Label></dt>
                                <dd>
                                    <asp:Label ID="lblPhoneTxt" runat="server"></asp:Label></dd>
                            </dl>
                            <h1>
                                <asp:Label ID="Label19" runat="server" resourcekey="SocialInformation"></asp:Label>
                            </h1>
                            <ul>
                                <li>
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
                                    </asp:HyperLink></li>
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
                            <div class="buttons-com">
                                <asp:Button ID="btnEditProfile2" runat="server" OnClick="btnEditProfile_Click" class="edit"></asp:Button>
                            </div>
                        </aside>
                    </div>
                </article>
            </div>
            <div id="pnlOrganizationEditMode">
                <div runat="server" id="EditPanel" visible="False">
                    <fieldset>
                        <legend>
                            <asp:Label ID="lblOrganizationInfo" runat="server" resourcekey="OrganizationInfo"></asp:Label></legend>
                        <div class="field">
                            <label>
                                <asp:Label ID="lblInstitutionName" runat="server" resourcekey="OrganizationName"
                                    AssociatedControlID="txtinstitutionName"></asp:Label>

                            </label>
                            <div>
                                <asp:TextBox ID="txtInstitutionName" runat="server" CssClass="input-xlarge maxlength"></asp:TextBox>
                            </div>
                            <div class="rfv">
                                <asp:RequiredFieldValidator class="rfv" ID="rfvInstitutionName" runat="server" ControlToValidate="txtInstitutionName"
                                    resourcekey="rfvInstitutionName" ViewStateMode="Disabled"></asp:RequiredFieldValidator>
                            </div>
                            <div class="rfv">
                                <asp:RegularExpressionValidator ID="rgvtxtInstitutionName" runat="server" SetFocusOnError="True"
                                    ControlToValidate="txtInstitutionName" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*" resourcekey="InvalidFormat">
                                </asp:RegularExpressionValidator>
                                <asp:RegularExpressionValidator Display="Dynamic" class="rfv" ControlToValidate="txtInstitutionName"
                                    ID="revInstitutionName" resourcekey="revInstitutionName" ValidationExpression="^[\s\S]{0,99}$"
                                    runat="server"></asp:RegularExpressionValidator>
                            </div>
                            <div class="support-text">
                                <asp:Label ID="lblspInstitutionName" runat="server" resourcekey="OrganizationNameDesc"></asp:Label>
                            </div>
                        </div>
                        <div class="field">
                            <div>
                                <asp:Label ID="lblDesciption" runat="server" resourcekey="Biografy" AssociatedControlID="txtDescription"></asp:Label>
                            </div>
                            <div>
                                <asp:TextBox ID="txtDescription" runat="server" Enabled="true" TextMode="MultiLine"
                                    Height="150px" CssClass="maxlength hasMaxLength"></asp:TextBox>
                            </div>     
                            <div>
                                <asp:Label ID="lblCountDescription" CssClass="count" runat="server" ></asp:Label>
                            </div>
                            <div class="rfv">
                                <asp:RequiredFieldValidator class="rfv" ID="rfvDescription" runat="server" ControlToValidate="txtDescription"
                                    resourcekey="rfvDescription"></asp:RequiredFieldValidator>
                                 <asp:RegularExpressionValidator ID="rgvtxtDescription" runat="server" SetFocusOnError="True"
                                    ControlToValidate="txtDescription" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n){100,799}$" resourcekey="revDescription">
                                </asp:RegularExpressionValidator>                               
                            </div>
                            <div class="support-text">
                                <asp:Label ID="lblspDescription" runat="server" resourcekey="BiografyDesc"></asp:Label>
                            </div>
                        </div>
                        <div class="field">
                            <label>
                                <asp:Label ID="lblImageInfo" runat="server" resourcekey="ImageInfo"></asp:Label></label>
                            <div>
                                <asp:Image ID="imgInstitution" runat="server" />
                            </div>
                            <div>
                                <telerik:RadAsyncUpload runat="server" OnFileUploaded="RadAsyncUpload1_FileUploaded" Skin="Silk"
                                    ID="RadAsyncUpload1" MultipleFileSelection="Disabled" PostbackTriggers="RadButton11"
                                    MaxFileSize="1048576" MaxFileInputsCount="1" OnClientFileSelected="fileSelected" />
                            </div>
                            <div style="display: none;">
                                <asp:Button runat="server" ID="RadButton11" CausesValidation="false" Text="" />
                            </div>
                            <div class="support-text">
                                <asp:Label ID="lblspImage" runat="server" resourcekey="ImageInfoDesc"></asp:Label>
                            </div>
                        </div>
                        <div class="field">
                            <label>
                                <asp:Label ID="lblEmail" runat="server" resourcekey="Email" AssociatedControlID="lblEmail"></asp:Label>
                            </label>
                            <div>
                                <asp:TextBox ID="txtEmail" runat="server"></asp:TextBox>
                            </div>
                            <div class="rfv">
                                <asp:RequiredFieldValidator class="rfv" ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                                    resourcekey="rfvEmail"></asp:RequiredFieldValidator>
                            </div>
                            <div class="rfv">
                                <asp:RegularExpressionValidator ID="revEmail" ControlToValidate="txtEmail" runat="server"
                                    ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" resourcekey="revEmail"></asp:RegularExpressionValidator>
                            </div>
                            <div class="rfv">
                                <asp:RegularExpressionValidator Display="Dynamic" class="rfv" ControlToValidate="txtEmail"
                                    ID="revEmail2" ValidationExpression="^[\s\S]{0,99}$" runat="server" resourcekey="revEmail2"></asp:RegularExpressionValidator>
                            </div>
                            <div class="support-text">
                                <asp:Label ID="lblspEmail" runat="server" resourcekey="EmailDesc"></asp:Label>
                            </div>
                        </div>
                        <div class="field">
                            <label>
                                <asp:Label ID="Label1" runat="server" resourcekey="Location" AssociatedControlID="CountryStateCityEditMode"></asp:Label>
                            </label>
                            <div>
                                <uc1:CountryStateCity ID="CountryStateCityEditMode" ViewInEditMode="True" AddressRequired="True" runat="server" LocationRequired="true" />
                            </div>
                            <div class="support-text">
                                <asp:Label ID="Label2" runat="server" resourcekey="LocationDesc"></asp:Label>
                            </div>
                        </div>
                        <div class="field">
                            <label>
                                <asp:Label ID="lblPhone" runat="server" resourcekey="Phone" AssociatedControlID="txtPhone"></asp:Label>
                            </label>
                            <div>
                                <asp:TextBox ID="txtPhone" runat="server" Enabled="true"></asp:TextBox>
                            </div>
                            <div class="rfv">
                                <asp:RequiredFieldValidator class="rfv" ID="rfvPhone" runat="server" ControlToValidate="txtPhone"
                                    resourcekey="rfvPhone"></asp:RequiredFieldValidator>
                            </div>
                            <div class="rfv">
                                <asp:RegularExpressionValidator Display="Dynamic" class="rfv" ControlToValidate="txtPhone"
                                    ID="revPhone" ValidationExpression="^[\s\S]{0,49}$" runat="server" resourcekey="revPhone"></asp:RegularExpressionValidator>
                            </div>
                            <div class="rfv">
                                <asp:RegularExpressionValidator Display="Dynamic" class="rfv" ControlToValidate="txtPhone"
                                    ID="revPhoneFormat" ValidationExpression="^[\s\S]{0,49}$" runat="server" resourcekey="revPhoneFormat"></asp:RegularExpressionValidator>
                            </div>
                            <div class="support-text">
                                <asp:Label ID="lblspPhone" runat="server" resourcekey="PhoneDesc"></asp:Label>
                            </div>
                        </div>
                    </fieldset>
                    <fieldset id="socialPanel" runat="server">
                        <legend>
                            <asp:Label ID="lblSocialInformation" runat="server" resourcekey="SocialInformation"></asp:Label></legend>
                        <div class="field">
                            <label>
                                <asp:Label ID="Label3" runat="server" resourcekey="LinkedIn"></asp:Label></label>
                            <div>
                                <asp:TextBox ID="txtLinkedIn" runat="server" Enabled="true"></asp:TextBox>
                            </div>
                            <div class="rfv">
                                  <asp:RegularExpressionValidator ID="rgvtxtLinkedIn" runat="server" SetFocusOnError="True"
                                    ControlToValidate="txtLinkedIn" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*" resourcekey="InvalidFormat">
                                </asp:RegularExpressionValidator>
                                <asp:RegularExpressionValidator Display="Dynamic" class="rfv" ControlToValidate="txtLinkedIn"
                                    ID="revLinkedIn" ValidationExpression="^[\s\S]{0,49}$" runat="server" resourcekey="revLinkedIn"></asp:RegularExpressionValidator>
                            </div>
                            <div class="support-text">
                                <asp:Label ID="Label4" runat="server" resourcekey="LinkedInDesc"></asp:Label>
                            </div>
                        </div>
                        <div class="field">
                            <label>
                                <asp:Label ID="Label5" runat="server" resourcekey="Skype"></asp:Label></label>
                            <div>
                                <asp:TextBox ID="txtSkype" runat="server" Enabled="true"></asp:TextBox>
                            </div>
                            <div class="rfv">
                                <asp:RegularExpressionValidator ID="rgvtxtSkype" runat="server" SetFocusOnError="True"
                                    ControlToValidate="txtSkype" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*" resourcekey="InvalidFormat">
                                </asp:RegularExpressionValidator>
                                <asp:RegularExpressionValidator Display="Dynamic" class="rfv" ControlToValidate="txtSkype"
                                    ID="revSkype" ValidationExpression="^[\s\S]{0,49}$" runat="server" resourcekey="revSkype"></asp:RegularExpressionValidator>
                            </div>
                            <div class="support-text">
                                <asp:Label ID="Label6" runat="server" resourcekey="SkypeDesc"></asp:Label>
                            </div>
                        </div>
                        <div class="field">
                            <label>
                                <asp:Label ID="Label7" runat="server" resourcekey="Twitter"></asp:Label></label>
                            <div>
                                <asp:TextBox ID="txtTwitter" runat="server" Enabled="true"></asp:TextBox>
                            </div>
                            <div class="rfv">
                                <asp:RegularExpressionValidator ID="rgvtxtTwitter" runat="server" SetFocusOnError="True"
                                    ControlToValidate="txtTwitter" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*" resourcekey="InvalidFormat">
                                </asp:RegularExpressionValidator>
                                <asp:RegularExpressionValidator Display="Dynamic" class="rfv" ControlToValidate="txtTwitter"
                                    ID="revTwitter" ValidationExpression="^[\s\S]{0,49}$" runat="server" resourcekey="revTwitter"></asp:RegularExpressionValidator>
                            </div>
                            <div class="support-text">
                                <asp:Label ID="Label8" runat="server" resourcekey="TwitterDesc"></asp:Label>
                            </div>
                        </div>
                        <div class="field">
                            <label>
                                <asp:Label ID="Label9" runat="server" resourcekey="Facebook"></asp:Label></label>
                            <div>
                                <asp:TextBox ID="txtFacebook" runat="server" Enabled="true"></asp:TextBox>
                            </div>
                            <div class="rfv">
                                <asp:RegularExpressionValidator ID="rgvtxtFacebook" runat="server" SetFocusOnError="True"
                                    ControlToValidate="txtFacebook" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*" resourcekey="InvalidFormat">
                                </asp:RegularExpressionValidator>
                                <asp:RegularExpressionValidator Display="Dynamic" class="rfv" ControlToValidate="txtFacebook"
                                    ID="revFacebook" ValidationExpression="^[\s\S]{0,39}$" runat="server" resourcekey="revFacebook"></asp:RegularExpressionValidator>
                            </div>
                            <div class="support-text">
                                <asp:Label ID="Label10" runat="server" resourcekey="FacebookDesc"></asp:Label>
                            </div>
                        </div>
                        <div class="field">
                            <label>
                                <asp:Label ID="Label11" runat="server" resourcekey="Google"></asp:Label></label>
                            <div>
                                <asp:TextBox ID="txtGoogle" runat="server" Enabled="true"></asp:TextBox>
                            </div>
                            <div class="rfv">
                                 <asp:RegularExpressionValidator ID="rgvtxtGoogle" runat="server" SetFocusOnError="True"
                                    ControlToValidate="txtGoogle" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*" resourcekey="InvalidFormat">
                                </asp:RegularExpressionValidator>
                                <asp:RegularExpressionValidator Display="Dynamic" class="rfv" ControlToValidate="txtGoogle"
                                    ID="revGoogle" ValidationExpression="^[\s\S]{0,39}$" runat="server" resourcekey="revGoogle"></asp:RegularExpressionValidator>
                            </div>
                            <div class="support-text">
                                <asp:Label ID="Label12" runat="server" resourcekey="GoogleDesc"></asp:Label>
                            </div>
                        </div>

                        <div class="rfv">
                            <asp:CustomValidator ID="lblMessage" runat="server"></asp:CustomValidator>
                        </div>
                    </fieldset>

                    <asp:Button ID="btnEditProfile" runat="server" OnClick="btnEditProfile_Click" CssClass="bttn bttn-m bttn-default"></asp:Button>
                    <asp:Button ID="btnCancel" Visible="False" runat="server" CausesValidation="False"
                        OnClick="btnCancel_Click" CssClass="bttn bttn-m bttn-alert"></asp:Button>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
<!--<script type="text/javascript" src="<%=ControlPath%>js/jquery.maxlength.js"></script>-->
<script type="text/javascript" src="<%=ControlPath%>js/NZOrganization.js"></script>
<%--<script type="text/javascript">Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);</script>--%>

<script type="text/javascript">

    console.log("cuakquercosa");

    var RadButton11 = '<%= RadButton11.ClientID%>';
    var txtDescription = '<%=txtDescription.ClientID %>';
    var OrganizationLanguage = '<%= OrganizationLanguage %>';
    var languageName = '<%= System.Threading.Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName.ToUpper() %>';
    var lblInstitutionNameTxt = '<%= lblInstitutionNameTxt.ClientID %>';
    var hfInstitutionNameTxt = '<%= hfInstitutionNameTxt.ClientID %>';
    var lblDesciptionTxt = '<%= lblDesciptionTxt.ClientID %>';
    var lblCount = '<%=lblCount.ClientID %>';
    var MessageTransalte = '<%= MessageTransalte.ClientID %>';


    var OrganizationLanguage = '<%=OrganizationLanguage%>';
    function onClientFileUploaded(sender, args) {
        document.getElementById("<%=RadButton11.ClientID%>").click();
    }
    function fileSelected(upload, args) {
        $telerik.$(".ruInputs li:first", upload.get_element()).addClass('hidden');
        upload.addFileInput();

        $telerik.$(".ruFakeInput", upload.get_element()).val(args.get_fileName());
        upload.set_enabled(true);
    }

    setInterval(function () { keepAlive(); }, 600000);

    $('body').on('click', '#<%=txtDescription.ClientID %>', counter());

    $(document).ready(function () {
        $('#<%=txtDescription.ClientID %>').change(counter());
        $('#<%=txtDescription.ClientID %>').keydown(counter());
        $('#<%=txtDescription.ClientID %>').keypress(counter());
        $('#<%=txtDescription.ClientID %>').keyup(counter());
        $('#<%=txtDescription.ClientID %>').blur(counter());
        $('#<%=txtDescription.ClientID %>').focus(counter());
    });

    function counter() {

        console.log("cuakquercosa");
        var value = $('#<%=txtDescription.ClientID %>').val();

        if (value.length == 0) {
            $('#<%=txtDescription.ClientID %>').html(0);
            return;
        }

        var regex = /\s+/gi;
        var wordCount = value.trim().replace(regex, ' ').split(' ').length;
        $('#<%=lblCountDescription.ClientID %>').html(wordCount);
    }

</script>
