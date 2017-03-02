<%@ Control Language="C#" AutoEventWireup="true" CodeFile="NXSolutionScoreMode.ascx.cs"
Inherits="NXSolutionScoreMode" %>
<%@ Register Src="../NXOtherControls/CountryStateCityV2.ascx" TagName="NXMapModule"
TagPrefix="uc1" %>
<%@ Register Src="../NXOtherControls/FileUploaderWizard.ascx" TagName="FileUploaderWizard"
TagPrefix="uc4" %>

<style>
.hideMessage {
    display: none;
}


.TitleScore {
    text-align: center;
}

.grid {
    position: relative;
    margin-right: auto;
    margin-left: auto;
    text-align: center;
    border: 2px solid #DAD9D9;
    box-shadow: 0px 2px 21px #BABABA;
}

.divJudge {
    width: 80%;
    position: relative;
    margin-right: auto;
    margin-left: auto;
}

.titleGrid {
    padding: 8px;
    background-color: #DAD9D9;
    color: #666;
    font-weight: bold;
    font-size: 14px;
}
</style>

<script>
    // Modals
    (function ($) {

        var settings = {
            api: {
                sendMessage: 'https://www.nexso.org/DesktopModules/NexsoServices/API/Nexso/SendMessage'
            }
        };




        // Modal trigger code.
        $(function () {

            $('[data-modal-id]').click(function (e) {
                e.preventDefault();
                var id = $(this).attr('data-modal-id');

                $('#' + id).addClass('revealed');

                var userId =<%=UserInfo.UserID%>;
                if(userId >-1){
                    var id = $(this).attr('data-modal-id');

                    $('.messageAuthentication').addClass('hideMessage');
                    $('.modal-body').removeClass('hideMessage');
                    $('.modal-footer').removeClass('hideMessage');
                }
                else{
                    $('.modal-body').addClass('hideMessage');
                    $('.modal-footer').addClass('hideMessage');
                    $('.messageAuthentication').removeClass('hideMessage');
                }

            });







            $('[data-modal-dismiss]').click(function (e) {
                e.preventDefault();
                $(this).closest('.modal').removeClass('revealed');
            });

        });

        // #conector-modal code
        $(function () {
            var $modal = $('#conector-modal');
            var $status = $modal.find('#status-message');

            var recipientId = $('input#hfOwnerSolutionId').val() || null;
            // Move modal.
            $modal.appendTo('body');

            // Update recipient name before opening modal.
            $('.author-user [data-modal-id]').click(function (e) {
                e.preventDefault();
                var userName = $('.author-user h1.card-title span').text();
                $modal.find('#message-recipient').text(userName);

                // Hide status message.
                $status.removeClass('revealed status-message-success status-message-alert');
            });

            $modal.find('[data-modal-confirm]').click(function (e) {
                e.preventDefault();
                var message = $.trim($modal.find('#message-body').val());
                if (message == '') {
                    $status.addClass('revealed status-message-alert')
                      .html($('<p>').text('The message is empty.'));



                    return;
                }

                $status.addClass('revealed')
                  .removeClass('status-message-success status-message-alert')
                    .html($('<p>').text('Loading...'));

                $.get(settings.api.sendMessage, {
                    'userIdTo': recipientId,
                    'Message': message,
                })
                .done(function (data) {
                    $modal.find('#message-body').val('');

                    $status.addClass('status-message-success')
                      .html($('<p>').text('Message sent.'));
                })
                .fail(function (data) {
                    console.log('fail', data);

                    $status.addClass('status-message-alert')
                      .html($('<p>').text('An error occurred while trying to send the message. Please try again.'));

                });



            });
        });

    })($);
</script>
<asp:Label runat="server" ID="lblCount"></asp:Label>
<article class="single single-solution">

    <!-- single-header -->
    <header class="single-header">

        <div class="row">
            <div class="col">

                <div class="carded">

                    <!-- cover -->
                    <div class="cover">



                        <div id="banner-wrapper" class="cover-image-container picturecontainer">
                            <asp:Image ID="imgBanner" CssClass="headerimage" Style="z-index: 1000" runat="server" />

                            <!-- drop-image -->
                            <div id="dropbox" style="display: none; z-index: 1000">
                                <%=Localization.GetString("dropboxMessage", LocalResourceFile)%>
                            </div>

                            <div class="uploaderBar clearfix" style="z-index: 1000" id="bannerController" runat="server" visible="false">
                                <div class="controllerTopBar">
                                    <input id="btnEnableBannerUploader" visible="false" class="btn" type="button" value="<%=Localization.GetString("btnEnableBannerUploader", LocalResourceFile)%>" />
                                </div>

                                <div class="controllerBotomBar" style="display: none;">
                                    <input id="btnCancelBanner" class="btn" type="button" value="<%=Localization.GetString("btnCancelBanner", LocalResourceFile)%>" />
                                    <input id="btnSaveBanner" class="btn" type="button" value="<%=Localization.GetString("btnSaveBanner", LocalResourceFile)%>" />
                                    <form class="uploaderButton" enctype="multipart/form-data" method="post" name="fileinfo" id="fileinfo">
                                        <div class="uploadControl">
                                            <i class="icon-plus"></i>
                                            <input id="btnUploadBanner" type="file" value="<%=Localization.GetString("btnUploadBanner", LocalResourceFile)%>" />
                                        </div>
                                    </form>
                                </div>
                            </div>
                            <!--/ drop-image -->

                        </div>

                        <div class="sub-container single-headline" style="z-index: 1000">
                            <!-- <div class="avatar-container"></div> -->
                            <div class="headline">
                                <h1 class="main-title">
                                    <asp:Label ID="lblTitle2" runat="server"></asp:Label></h1>
                                <asp:Label runat="server" ID="hfTitle" />
                                <!-- <p class="meta"></p> -->
                            </div>
                        </div>

                    </div>
                    <!--/ cover -->

                    <!-- actions -->
                    <div id="dvActionBar" runat="server" class="actions">
                        <div class="actions-admin">
                            <input id="btnTranslate" class="bttn bttn-m bttn-default" type="button" value="Translate" onclick="javascript: translateAll();" />
                            <asp:Button CssClass="bttn bttn-m bttn-default" ID="btnReportSpam" resourcekey="ReportSpam" runat="server" OnClick="btnReportSpam_Click" />
                            <asp:Button CssClass="bttn bttn-m bttn-default" ID="btnUnpublish" Visible="False" resourcekey="Unpublish" runat="server" OnClick="btnUnpublish_Click" />
                        </div>
                    </div>
                    <!--/ actions -->

                </div>

            </div>
        </div>

    </header>
    <!--/ single-header -->


    <!-- single-body -->
    <div class="single-body">
        <div class="row">
            <div class="single-content">
                <asp:Label runat="server" ID="hfTagLine" />
                <asp:Label runat="server" ID="MessageTransalte"></asp:Label>

                <%-- hidden by DEMAND_SOLUTIONS2015 challenge --%>
                <asp:Panel runat="server" ID="pnlTitle" Visible="false">
                    <div class="content-block">
                        <h2 class="title">
                            <asp:Label ID="lblTitle" runat="server"></asp:Label></h2>
                        <div class="radiobuttonlist">
                            <div>
                                <asp:Label ID="lblTitleHelp" runat="server" resourcekey="TitleHelp"></asp:Label>
                                <asp:RadioButtonList CssClass="radiobuttonlist" DataTextField="Label" DataValueField="Key"
RepeatDirection="Horizontal" TextAlign="Right" ID="rdbTitle" runat="server">
</asp:RadioButtonList>
<asp:RequiredFieldValidator ID="RequiredFieldValidator1" ControlToValidate="rdbTitle" ValidationGroup="score"
resourcekey="rfvName" runat="server" />
</div>
</div>
</div>
</asp:Panel>

<div class="content-block">
    <h2 class="sub-title">
        <asp:Label ID="lblTagLine" runat="server"></asp:Label></h2>
    <%-- hidden by GOBERNARTE2015 challenge --%>
    <asp:Panel ID="pnlInstitutionNameScoreCard" runat="server" Visible="false">
        <div class="radiobuttonlist">
            <asp:Label ID="lblInstitutionNameScoreCard" runat="server" resourcekey="InstitutionNameScoreCard"></asp:Label>
            <asp:RadioButtonList CssClass="radiobuttonlist" DataTextField="Label" DataValueField="Key"
RepeatDirection="Horizontal" TextAlign="Right" ID="rdbTagLine" runat="server">
</asp:RadioButtonList>
<asp:RequiredFieldValidator ID="RequiredFieldValidator2" ControlToValidate="rdbTagLine" ValidationGroup="score"
resourcekey="rfvTagLine" runat="server" />
</div>
</asp:Panel>

</div>
<div class="content-block">
    <h2>
        <asp:Label ID="lblChallengeTitle" runat="server" resourcekey="Challenge"></asp:Label></h2>
    <p>
        <asp:Label ID="lblChallenge" runat="server"></asp:Label>
    </p>
    <%-- hidden by GOBERNARTE2015 challenge --%>
    <asp:Panel ID="pnlChallengeScoreCard" runat="server" Visible="false">
        <div class="radiobuttonlist">
            <asp:Label ID="lblChallengeScoreCard" runat="server" resourcekey="ChallengeScoreCard"></asp:Label>
            <asp:CheckBoxList ID="chkChallenge" CssClass="radiobuttonlist" RepeatDirection="Horizontal"
DataTextField="Label" DataValueField="Key" runat="server">
</asp:CheckBoxList>
</div>
</asp:Panel>

<br />
<div>

<asp:Label ID="Label14" runat="server" resourcekey="ThemesTitle" Font-Bold="true" ForeColor="#3f3f3f"></asp:Label>
</div>

<section class="aside-block overview">
    <dl class="details-list">
        <dt>Themes</dt>
        <dd class="themes">
            <p>
                <asp:Label ID="lblTheme" runat="server"></asp:Label>
            </p>
        </dd>
    </dl>
</section>
<%--  <div class="radiobuttonlist">
    <asp:Label ID="lblThemeScoreCard" runat="server" resourcekey="ThemeScoreCard"></asp:Label>
    <asp:RadioButtonList CssClass="radiobuttonlist" DataTextField="Label" DataValueField="Key"
RepeatDirection="Horizontal" TextAlign="Right" ID="rdbTheme" runat="server">
</asp:RadioButtonList>
<asp:RequiredFieldValidator ID="RequiredFieldValidator7" ControlToValidate="rdbTheme" ValidationGroup="score"
resourcekey="rfvThemes" runat="server" />
</div>--%>
</div>

<div class="content-block">
    <h2>
        <asp:Label ID="LblApproachTitle" runat="server" resourcekey="Approach"></asp:Label></h2>
    <p>
        <asp:Label ID="lblApproach" runat="server"></asp:Label>
    </p>
    <%-- hidden by GOBERNARTE2015 challenge --%>
    <asp:Panel ID="pnlApproachScoreCard" runat="server" Visible="false">
        <div class="radiobuttonlist">
            <asp:Label ID="lblApproachScoreCard" runat="server" resourcekey="ApproachScoreCard"></asp:Label>
            <asp:CheckBoxList ID="chkAproach" CssClass="radiobuttonlist" RepeatDirection="Horizontal"
DataTextField="Label" DataValueField="Key" runat="server">
</asp:CheckBoxList>
</div>
</asp:Panel>
<br />
<div>

<asp:Label ID="Label13" runat="server" resourcekey="TargetTitle" Font-Bold="true" ForeColor="#3f3f3f"></asp:Label>
</div>

<section class="aside-block overview">
    <dl class="details-list">
        <dt>Target</dt>
        <dd class="target">
            <p>
                <asp:Label ID="lblBeneficiary" runat="server"></asp:Label>
            </p>
        </dd>
    </dl>
</section>

<%--<div class="radiobuttonlist">
    <asp:Label ID="lblBeneficiaryScoreCard" runat="server" resourcekey="BeneficiaryScoreCard"></asp:Label>
    <asp:RadioButtonList CssClass="radiobuttonlist" DataTextField="Label" DataValueField="Key"
RepeatDirection="Horizontal" TextAlign="Right" ID="rdbBeneficiary" runat="server">
</asp:RadioButtonList>
<asp:RequiredFieldValidator ID="RequiredFieldValidator8" ControlToValidate="rdbBeneficiary" ValidationGroup="score"
resourcekey="rfvBeneficiaries" runat="server" />
</div>--%>
</div>
<div class="content-block">

    <h2>
        <asp:Label ID="lblResultsTitle" runat="server" resourcekey="Results"></asp:Label></h2>
    <p>
        <asp:Label ID="lblResults" runat="server"></asp:Label>
    </p>
    <%-- hidden by GOBERNARTE2015 challenge --%>
    <asp:Panel ID="pnlResultsScoreCard" runat="server" Visible="false">
        <div class="radiobuttonlist">
            <asp:Label ID="lblResultsScoreCard" runat="server" resourcekey="ResultsScoreCard"></asp:Label>
            <asp:CheckBoxList ID="chkResults" CssClass="radiobuttonlist" RepeatDirection="Horizontal"
DataTextField="Label" DataValueField="Key" runat="server">
</asp:CheckBoxList>
</div>
</asp:Panel>
<br />
<div>

<asp:Label ID="Label5" runat="server" resourcekey="DeliveryFormatTitle" Font-Bold="true" ForeColor="#3f3f3f"></asp:Label>
</div>

<section class="aside-block overview">
    <dl class="details-list">
        <dt>Delivery format</dt>
        <dd class="link">
            <p>
                <asp:Label ID="lblDeliveryFormat" runat="server"></asp:Label>
            </p>
        </dd>
    </dl>
</section>

<%--<div class="radiobuttonlist">
    <asp:Label ID="lblDeliveryFormatScoreCard" runat="server" resourcekey="DeliveryFormatScoreCard"></asp:Label>
    <asp:RadioButtonList CssClass="radiobuttonlist" DataTextField="Label" DataValueField="Key"
RepeatDirection="Horizontal" TextAlign="Right" ID="rdbDeliveryFormat" runat="server">
</asp:RadioButtonList>
<asp:RequiredFieldValidator ID="RequiredFieldValidator9" ControlToValidate="rdbDeliveryFormat" ValidationGroup="score"
resourcekey="rfvDeliveryFormat" runat="server" />
</div>--%>
</div>
<div class="content-block">

    <h2>
        <asp:Label ID="lblImplementationDetailsTitle" runat="server" resourcekey="ImplementationDetails"></asp:Label></h2>
    <p>
        <asp:Label ID="lblImplementationDetails" runat="server"></asp:Label>
    </p>
    <%-- hidden by GOBERNARTE2015 challenge --%>
    <asp:Panel ID="pnlImplementationDetailsScoreCard" runat="server" Visible="false">
        <div class="radiobuttonlist">
            <asp:Label ID="lblImplementationDetailsScoreCard" runat="server" resourcekey="ImplementationDetailsScoreCard"></asp:Label>
            <asp:RadioButtonList CssClass="radiobuttonlist" DataTextField="Label" DataValueField="Key"
RepeatDirection="Horizontal" TextAlign="Right" ID="rdbImplemenationDetails" runat="server">
</asp:RadioButtonList>
<asp:RequiredFieldValidator ID="RequiredFieldValidator5" ControlToValidate="rdbImplemenationDetails" ValidationGroup="score"
resourcekey="rfvImplementationDetails" runat="server" />
</div>
</asp:Panel>
<br />
<%-- <section class="aside-block overview">
    <dl class="details-list">
        <dt>Delivery format</dt>
        <dd class="link">
            <asp:Label ID="lblAvailableResources" runat="server"></asp:Label></dd>
    </dl>
</section>

<div class="radiobuttonlist">
    <asp:Label ID="lblAvailableResourcesScoreCard" runat="server" resourcekey="AvailableResourcesScoreCard"></asp:Label>
    <asp:RadioButtonList CssClass="radiobuttonlist" DataTextField="Label" DataValueField="Key"
RepeatDirection="Horizontal" TextAlign="Right" ID="rdbAvailableResources" runat="server">
</asp:RadioButtonList>
<asp:RequiredFieldValidator ID="RequiredFieldValidator12" ControlToValidate="rdbAvailableResources" ValidationGroup="score"
resourcekey="rfvAvailableResources" runat="server" />
</div>--%>
</div>
<div class="content-block">
    <h2>
        <asp:Label ID="lblCostDetailsTitle" runat="server" resourcekey="CostDetails"></asp:Label></h2>
    <p>
        <asp:Label ID="lblCostDetails" runat="server"></asp:Label>
    </p>
    <%-- hidden by GOBERNARTE2015 challenge --%>
    <asp:Panel ID="pnlCostDetailsScoreCard" runat="server" Visible="false">
        <div class="radiobuttonlist">
            <asp:Label ID="lblCostDetailsScoreCard" runat="server" resourcekey="CostDetailsScoreCard"></asp:Label>
            <asp:RadioButtonList ID="rbdCostDetails" CssClass="radiobuttonlist" RepeatDirection="Horizontal"
DataTextField="Label" DataValueField="Key" runat="server">
</asp:RadioButtonList>
<asp:RequiredFieldValidator ID="RequiredFieldValidator3" ControlToValidate="rbdCostDetails" ValidationGroup="score"
resourcekey="rfvCostDetails" runat="server" />
</div>
</asp:Panel>
<div>

<asp:Label ID="Label12" runat="server" resourcekey="CostTitle" Font-Bold="true" ForeColor="#3f3f3f"></asp:Label>
</div>
<br />

<section class="aside-block overview">
    <dl class="details-list">
        <dt>Cost</dt>
        <dd class="cost">
            <p>
                <asp:Label ID="lblCost" runat="server"></asp:Label>
            </p>
        </dd>
    </dl>
</section>
<%-- hidden by GOBERNARTE2015 challenge --%>
<asp:Panel ID="pnlCostScoreCard" runat="server" Visible="false">
    <div class="radiobuttonlist">

        <asp:Label ID="lblCostScoreCard" runat="server" resourcekey="CostScoreCard"></asp:Label>
        <asp:RadioButtonList CssClass="radiobuttonlist" DataTextField="Label" DataValueField="Key"
RepeatDirection="Horizontal" TextAlign="Right" ID="rdbCost" runat="server">
</asp:RadioButtonList>
<asp:RequiredFieldValidator ID="RequiredFieldValidator11" ControlToValidate="rdbCost" ValidationGroup="score"
resourcekey="rfvCost" runat="server" />
</div>
</asp:Panel>
</div>
<div class="content-block">
    <h2>
        <asp:Label ID="lblDurationDetailsTitle" runat="server" resourcekey="DurationDetails"></asp:Label></h2>
    <p>
        <asp:Label ID="lbldurationDetails" runat="server"></asp:Label>
    </p>
    <%-- hidden by GOBERNARTE2015 challenge --%>
    <asp:Panel ID="pnldurationDetailsScoreCard" runat="server" Visible="false">
        <div class="radiobuttonlist">

            <asp:Label ID="lbldurationDetailsScoreCard" runat="server" resourcekey="DurationDetailsScoreCard"></asp:Label>
            <asp:RadioButtonList ID="rbdDurationDetails" CssClass="radiobuttonlist" RepeatDirection="Horizontal"
DataTextField="Label" DataValueField="Key" runat="server">
</asp:RadioButtonList>
<asp:RequiredFieldValidator ID="RequiredFieldValidator4" ControlToValidate="rbdDurationDetails" ValidationGroup="score"
resourcekey="rfvDurationDetails" runat="server" />
</div>
</asp:Panel>
<div>

<asp:Label ID="Label6" runat="server" resourcekey="DurationTitle" Font-Bold="true" ForeColor="#3f3f3f"></asp:Label>
</div>
<br />

<section class="aside-block overview">
    <dl class="details-list">
        <dt>Duration</dt>
        <dd class="calendar">
            <p>
                <asp:Label ID="lblDuration" runat="server"></asp:Label>
            </p>
        </dd>
    </dl>
</section>
<%-- hidden by GOBERNARTE2015 challenge --%>
<asp:Panel ID="pnlDurationScoreCard" runat="server" Visible="false">
    <div class="radiobuttonlist">
        <asp:Label ID="lblDurationScoreCard" runat="server" resourcekey="DurationScoreCard"></asp:Label>
        <asp:RadioButtonList CssClass="radiobuttonlist" DataTextField="Label" DataValueField="Key"
RepeatDirection="Horizontal" TextAlign="Right" ID="rdbDuration" runat="server">
</asp:RadioButtonList>
<asp:RequiredFieldValidator ID="RequiredFieldValidator10" ControlToValidate="rdbDuration" ValidationGroup="score"
resourcekey="rfvTime" runat="server" />
</div>
</asp:Panel>
</div>
<div class="content-block" runat="server" id="pnlLongDescription" visible="false">

    <h2>
        <asp:Label ID="lblDescriptionTitle" runat="server" resourcekey="Description"></asp:Label></h2>

    <p>
        <asp:Label ID="lblDescription" runat="server"></asp:Label>
    </p>
    <%-- hidden by GOBERNARTE2015 challenge --%>
    <asp:Panel ID="pnlDescriptionScoreCard" runat="server" Visible="false">
        <div class="radiobuttonlist">
            <asp:Label ID="lblDescriptionScoreCard" runat="server" resourcekey="DescriptionScoreCard"></asp:Label>
            <asp:RadioButtonList CssClass="radiobuttonlist" DataTextField="Label" DataValueField="Key"
RepeatDirection="Horizontal" TextAlign="Right" ID="rdbDescription" runat="server">
</asp:RadioButtonList>
<asp:RequiredFieldValidator ID="RequiredFieldValidator6" ControlToValidate="rdbDescription" ValidationGroup="score"
resourcekey="rfValidator" runat="server" />
</div>
</asp:Panel>

</div>
<div id="dvOtherInformationPanel" runat="server" class="additionalInformationPanel content-block">
    <asp:Label ID="lblCustomInformation" runat="server" resourcekey="CustomInformation"></asp:Label>
    <br />
    <br />
    <asp:Literal runat="server" ID="lOtherInformation"></asp:Literal>

</div>
<div id="dvOtherInformationPanelScore" runat="server"></div>

</div>


<aside class="single-aside">

    <!-- overview -->
    <section class="aside-block overview">
        <h1 class="aside-block-title">
            <asp:Label ID="Label11" runat="server" resourcekey="Overview"></asp:Label></h1>
        <dl class="details-list">
            <dt>Themes</dt>
            <dd class="themes">
                <asp:Label ID="lblTheme2" runat="server"></asp:Label></dd>
            <dt>Target</dt>
            <dd class="target">
                <asp:Label ID="lblBeneficiary2" runat="server"></asp:Label></dd>
            <dt>Delivery format</dt>
            <dd class="link">
                <asp:Label ID="lblDeliveryFormat2" runat="server"></asp:Label></dd>
            <dt>Cost</dt>
            <dd class="cost">
                <asp:Label ID="lblCost2" runat="server"></asp:Label></dd>
            <dt>Duration</dt>
            <dd class="calendar">
                <asp:Label ID="lblDuration2" runat="server"></asp:Label></dd>
        </dl>
    </section>
    <!--/ overview -->

    <!-- geo -->
    <section class="aside-block geo">
        <h1 class="aside-block-title">
            <asp:Label ID="Label50" runat="server" resourcekey="Locations"></asp:Label></h1>
        <div class="map">
            <uc1:NXMapModule ID="NXMapModule" ViewInEditMode="False" MultiSelect="True" runat="server" MinHeight="150" />
        </div>
    </section>
    <!--/ geo -->

    <!-- documents -->
    <section class="aside-block documents">
        <h1 class="aside-block-title">
            <asp:Label ID="Label3" runat="server" resourcekey="SupportingDocuments"></asp:Label></h1>
        <div>
            <uc4:FileUploaderWizard runat="server" Folder="/challenge/20141/public" DocumentDefaultMode="1" ID="fileSupportDocuments"></uc4:FileUploaderWizard>
        </div>
        <h1 class="title">
            <asp:Label ID="lblPrivateDocuments" Visible="False" runat="server" resourcekey="PrivateDocuments"></asp:Label></h1>
        <div>
            <uc4:FileUploaderWizard Visible="False" runat="server" DocumentDefaultMode="2" ID="filePrivateDocuments"></uc4:FileUploaderWizard>
        </div>
    </section>
    <!--/ documents -->

    <!-- author: org -->
    <section class="aside-block author-org">
        <h1 class="aside-block-title">
            <asp:Label ID="Label53" runat="server" resourcekey="ProvidedBy"></asp:Label></h1>
        <article class="card temp">
            <asp:HyperLink ID="hlInstitutionName" runat="server">
                <div class="card-media card-media-thumb">
                    <asp:Image ID="imgOrganizationLogo" runat="server" />
                </div>
                <div class="card-prose">
                    <asp:Label runat="server" ID="hfInstitutionName" />
                    <h1 class="card-title">
                        <asp:Label ID="lblInstitutionName" runat="server"></asp:Label></h1>
                    <!--<p class="card-meta"><asp:Label ID="lblCountry" runat="server"></asp:Label></p>-->
                    <div class="card-body">
                        <asp:Label runat="server" ID="MessageTransalte2"></asp:Label>
                        <p>
                            <asp:Label ID="lblOrganizationDescription" runat="server"></asp:Label>
                        </p>
                    </div>
                </div>
            </asp:HyperLink>
        </article>
    </section>
    <!--/ author: org -->

    <!-- author: user -->
    <section class="aside-block author-user">
        <h1 class="aside-block-title">
            <asp:Label ID="Label2" runat="server" resourcekey="PublishedBy"></asp:Label></h1>
        <article class="card">
            <div class="card-media card-media-avatar">
                <img alt="User avatar image" width="512" height="512" src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI1MTIiIGhlaWdodD0iNTEyIiB2aWV3Qm94PSIwIDAgNTEyIDUxMiI+PHBhdGggZmlsbD0iI0VCRUJFQiIgZD0iTTAgMGg1MTJ2NTEyaC01MTJ2LTUxMnoiLz48cGF0aCBmaWxsPSIjZmZmIiBkPSJNMzAzLjUgMzM3LjdjLTkuNS0xLjUtOS43LTI3LjYtOS43LTI3LjZzMjcuOC0yNy42IDMzLjktNjQuNmMxNi4zIDAgMjYuNC0zOS40IDEwLjEtNTMuMy43LTE0LjYgMjEtMTE0LjYtODEuOC0xMTQuNnMtODIuNSAxMDAtODEuOCAxMTQuNmMtMTYuMyAxMy45LTYuMiA1My4zIDEwLjEgNTMuMyA2LjEgMzcuMSAzMy45IDY0LjYgMzMuOSA2NC42cy0uMiAyNi4xLTkuNyAyNy42Yy0zMC41IDQuOS0xNDQuNSA1NS4yLTE0NC41IDExMC4zaDM4NGMwLTU1LjEtMTE0LTEwNS40LTE0NC41LTExMC4zeiIvPjwvc3ZnPg==" />
            </div>
            <div class="card-prose">
                <h1 class="card-title">
                    <asp:HyperLink ID="hlPublishedBy" runat="server">
                        <asp:Label ID="lblPublishedBy" runat="server"></asp:Label>
                    </asp:HyperLink></h1>
                <div class="card-actions">

                    <a class="bttn-action bttn-conector bttn-l" href="#conector-modal" data-modal-id="conector-modal">
                        <asp:Label ID="Label4" runat="server" resourcekey="SendMessage"></asp:Label></a>

                </div>
            </div>
        </article>
        <!-- conector modal (will appear appended to body) -->
        <section class="modal" id="conector-modal">
            <div class="modal-inner">
                <header class="modal-header">
                    <a class="close" data-modal-dismiss href="#" title='<%=Localization.GetString("btnClose", LocalResourceFile)%>'><span>
                        <asp:Label ID="Label10" runat="server" resourcekey="btnClose"></asp:Label></span></a>
                    <h1 class="modal-title">
                        <asp:Label ID="Label7" runat="server" resourcekey="SendMessageTo"></asp:Label><span class="alt" id="message-recipient">[FirstName LastName]</span></h1>
                </header>
                <div class="messageAuthentication">
                    <div class="row full text-center">
                        <div class="medium-8 medium-offset-2 small-12 columns">
                            <asp:Label runat="server" ID="lblMessage" resourcekey="MessageAuthentication"></asp:Label>
                        </div>
                    </div>
                </div>

                <div class="modal-body">
                    <textarea name="message-body" id="message-body" rows="8" cols="40" placeholder="<%=Localization.GetString("WriteAMessage", LocalResourceFile)%>"></textarea>
                    <div class="status-message" id="status-message">
                        <!-- Status message -->
                    </div>
                </div>
                <footer class="modal-footer">
                    <button class="bttn bttn-default bttn-m" data-modal-dismiss title="Cancel">
                        <asp:Label ID="Label8" runat="server" resourcekey="btnCancelSendMessage"></asp:Label></button>
                    <button class="bttn bttn-secondary bttn-m" title="Send" data-modal-confirm>
                        <asp:Label ID="Label9" runat="server" resourcekey="SendMessage"></asp:Label></button>
                </footer>
            </div>
        </section>
        <!-- conector modal (will appear appended to body) -->

    </section>
    <!-- author: user -->

</aside>
</div>
</div>
<!--/ single-body -->
</article>
<div>
<asp:ValidationSummary ID="ValidationSummary1" ValidationGroup="score" runat="server"
ShowMessageBox="false" DisplayMode="BulletList" ShowSummary="true" />
</div>
<hr />
<%--<div class="radiobuttonlist">
    <asp:Label ID="lblCustomScoreCard" runat="server" resourcekey="CustomDataScoreCard"></asp:Label>
    <asp:RadioButtonList CssClass="radiobuttonlist" DataTextField="Label" DataValueField="Key"
RepeatDirection="Horizontal" TextAlign="Right" ID="rdCustomScoreCard" runat="server">
</asp:RadioButtonList>
<asp:RequiredFieldValidator ID="RequiredFieldValidator13" ControlToValidate="rdCustomScoreCard" ValidationGroup="score"
resourcekey="rfvCustomScoreCard" runat="server" />
</div>--%>
<br />
<div>
<asp:Button ID="btnScore" runat="server" resourcekey="btnScore" ValidationGroup="score" CssClass="btn step-finish"
OnClick="btnScore_Click" />
</div>
<br />
<hr />
<div class="divJudge">
    <div class="TitleScore">
        <h2>
            <asp:Label ID="Label1" runat="server" resourcekey="Scoring"></asp:Label>
        </h2>
    </div>
    <div>
        <asp:Label runat="server" ID="lblScoreGlobal"></asp:Label>
    </div>
    <div>
        <asp:Label runat="server" ID="lblAdditionalScoreGlobal"></asp:Label>
    </div>
    <div>
        <asp:Label runat="server" ID="lblTotalScoreGlobal"></asp:Label>
    </div>
    <br />
    <div>
        <b>
            <asp:Label runat="server" resourcekey="ListJudges" ID="lblListJudges"></asp:Label></b>
    </div>
    <br />
    <div class="divGrid">
        <asp:GridView CssClass="grid" Width="100%" ID="gvListJudges" runat="server" AutoGenerateColumns="False" HeaderStyle-CssClass="titleGrid" RowStyle-Height="40px"
HeaderStyle-Height="35px"
GridLines="None">
<Columns>
    <asp:BoundField DataField="FirstName" />
    <asp:BoundField DataField="LastName" />
    <asp:BoundField DataField="ScoreValue" />
    <asp:BoundField DataField="CustomScore" Visible="false" />
    <asp:BoundField DataField="TotalScore" Visible="false" />
</Columns>
</asp:GridView>
</div>
<br />
<br />

</div>

<div runat="server" id="Comments" visible="false">
    <div class="discussion">
        <script id="solution-stats-tpl" type="text/x-handlebars-template">
            <div class="solution-stats">
                <div class="stat view">
                    <img data-img="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAACA0lEQVRIx+1UPUhCURQWh3CIhoiGiIaIiGiIaAjHhqYIiYaQ5oaGZn2+FBUJh4imEImGhoag50/2Q4SIg9R96hCN0dAQERERESJS33nda9dnas114cPrOeee757v3PMslv/1t5cnxsbcGgsCaeAOKHPcA1kgjBj7rxMrMTaNw8y1f/H+EyD2StGYM3RUsDZNrMZZD4JTwDvHM7ANwnk1rg8FDotdwcNiN/aDsM3CFwEepfgsKhpoJIedl06Br7iR6k3mOzhxP2waUAIqVB3ip8jnOyjYQLYsET0p3CdLMklJebk53LD/qyq9lxNrII1SD3hcBSQzUlw3bCfcV1KED0GjMLxw9l1fMt9WQ66xLdgz0v91SZKbtdNiVfdAqmCFf5P73kAyYcGmyA05/0G+rkmwX5NPIjASiAavxPWBb84cuTWjkkuSx8kJytg7viPgZaeRfI+kkV+QmQCKjAu5Eb8obhXmJKTdnEmiqCSJGTUSeWI6yf0g5K4mWT02tIuI5oHEiydpNTVZfvd1Tabq6Vm79g1fxpvQbfUDprGQSITfc09ct7d6prhAH87tSOdSKwm9vdkUO6R5MIYHCZZANopXIgZtGHEL7s+elKo91Jg/kMo3n2Z+404c2BDNErI02FNFSVQ00jKxeeGFdNLtKQFwK33s6MN3RtOuNvo0/K+/sz4AdGRFLg986WoAAAAASUVORK5CYII=">
                    <div class="value">0</div>
                </div>
                <div class="stat comment">
                    <img data-img="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAABjklEQVRIx7WVP0/CQBjGG2KMYSLEOBLj6ODgJ3B0NA5Ojk4MzkgFwUCYGf0ILvaPCt/Ba00Mg3F0cCIMDsR0MPA8bZGmKbVX2kue5Nre+7t7n97dqygJW9O0Sqpu7VLsJ41b2a4NsX2liSr0DI2hWUhj/1uVY2XAZQT1oR+Cag8vruL6/tg+Y2PhdV0cYeDXIlhWjCUjGq6JEwxwIqyQlUNWeOWHTHOZvphF9/+3i+PJItOF3zzaG3gxSmtLjF0jsmnNWQa2RIpsBR0t3hZ5izyb3GdNWWfXJNlVnOA3L4vI5gTT5OlLWzTlBHaOFtmcoJujRV1F1UWFpy97i4RD9uKaaGdtD5l/V0XLO83DDK0Ztp5wioOtYVjF5aFLbxEZZEXeqJ2BXUBqvZQ75huxl53BayG2JuDH7Eva8Qm1UWx2ElU0rOLUW5UIp/8G3fnqYdwFFnMgVYdR0EsIfg+lPgGs1jTtTSlYsN3CN0COAfvw7yamfY935w1zxQ+TaSgMxbpu7amGqGB7ba0NDLQ5SkDWY0+aEfMAAAAASUVORK5CYII=">
                    <div class="value">0</div>
                </div>
                <div class="stat rate">
                    <img data-img="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAABiUlEQVRIx7VVO07DQBC1EEIIpaTkDDkD4giUKBWiokQUEALEIlQ5AEqZMg228yGKOAGsTUuRKkJWyhwgRXhv5Y2cCGOP41gaZbM778347czYsgTPYy8o0SQY0VN11RVtK+T1frB/66iQxvU2sr+8ef1c0LgulNzuB3vIfAJbRDbhXpHZn5PYvAHX3CuE/GkQ7IJwbMhjQcY8KyL7s5g0K8YzSaalmqfKAJ1WHXUNa4HkHTYzssQlin5n9KGvxgBLDnItie9c9QynaZxgU4vecEpu677rH+DPKEmGDWxEbv0WaH82kZckhWytyT1yrtwBupPV0ilAng65/rxoG2WHy2rnlYVYO610G29fO3B8kUpEDLGZSrYx0KNhLpBlTkzmnkB5laXyEJO9ex1VySFRJXMAgJo5qqcpCTBMkGL435kkQBg1jMnuA3PmeCkh1txbm0thJvKHrn8YA31zgCXeFc7oYwIRm37BrjqB8w8u7aLeS5/39KGvxgCbGgDj9qjm+eKPOjHEru//ApOcGQwaJTT4AAAAAElFTkSuQmCC">
                    <div class="value">0</div>
                </div>
            </div>
        </script>
        <!-- START Handlebars Templates -->
        <script id="comments-tpl" type="text/x-handlebars-template">
            {{#if user_logged}}
        <div class="box">
            <textarea name="comment-body" id="comment-body" rows="8" cols="40" placeholder="Write a comment..."></textarea>
            <button type="button" id="comment-submit" class="bttn bttn-l bttn-secondary">Submit </button>
        </div>
            <div id="comment-list">{{>comment-list}}</div>
{{else}}
<div class="empty-box">
    <p>You must be logged in to comment or view comments.</p>
    <p><a href="/en-us/Login" title="Login">Login</a> or <a href="/en-us/Registration" title="Register">Register</a></p>
</div>
{{/if}}
</script>
<script id="comment-tpl" type="text/x-handlebars-template">
    <article class="comment">
        <div class="comment-prose">
            <h1 class="comment-title"><a href="#" title="View user">{{FirstName}} {{LastName}}</a></h1>
            <p class="comment-meta">{{moment CreatedDate}}</p>
            <div class="comment-body">
                <p>{{nl2br Comment}}</p>
            </div>
            <div class="comment-admin-actions"><a href="#" data-comment-id="{{CommentId}}" title="Delete this comment">Delete</a> </div>
        </div>
    </article>
</script>
<script id="comment-list-tpl" type="text/x-handlebars-template">
    {{#if loading}}
<h2>Feedback</h2>
    <p>Loading comments...</p>
    {{else}}
    <h2>Feedback <span class="badge">{{comments.length}}</span></h2>
        {{#if comments.length}}
    <ol class="comments-list">
        {{#each comments}}
        <li class="comment-wrapper">{{> comment}} </li>
    {{/each}}
</ol>
        {{else}}
        <p>There are no comments.</p>
        {{/if}} {{/if}}
        </script>
        <!-- END Handlebars Templates -->
        <div class="row">
            <div class="discussion-content">
                <section class="comments" id="comments-container">
                    <!-- comments-list-tpl -->
                </section>
            </div>
        </div>
    </div>
</div>
<script>
    /*! RateIt | v1.0.22 / 05/27/2014 | https://rateit.codeplex.com/license
      http://rateit.codeplex.com | Twitter: @gjunge
  */
    (function(n){function t(n){var u=n.originalEvent.changedTouches,t=u[0],i="",r;switch(n.type){case"touchmove":i="mousemove";break;case"touchend":i="mouseup";break;default:return}r=document.createEvent("MouseEvent");r.initMouseEvent(i,!0,!0,window,1,t.screenX,t.screenY,t.clientX,t.clientY,!1,!1,!1,!1,0,null);t.target.dispatchEvent(r);n.preventDefault()}n.rateit={aria:{resetLabel:"reset rating",ratingLabel:"rating"}};n.fn.rateit=function(i,r){var e=1,u={},o="init",s=function(n){return n.charAt(0).toUpperCase()+n.substr(1)},f;if(this.length===0)return this;if(f=n.type(i),f=="object"||i===undefined||i===null)u=n.extend({},n.fn.rateit.defaults,i);else{if(f=="string"&&i!=="reset"&&r===undefined)return this.data("rateit"+s(i));f=="string"&&(o="setvalue")}return this.each(function(){var c=n(this),f=function(n,t){if(t!=null){var i="aria-value"+(n=="value"?"now":n),r=c.find(".rateit-range");r.attr(i)!=undefined&&r.attr(i,t)}return arguments[0]="rateit"+s(n),c.data.apply(c,arguments)},p,w,v,h,b,g,nt,l,y,k,a;if(i=="reset"){p=f("init");for(w in p)c.data(w,p[w]);f("backingfld")&&(h=n(f("backingfld")),h.val(f("value")),h.trigger("change"),h[0].min&&(h[0].min=f("min")),h[0].max&&(h[0].max=f("max")),h[0].step&&(h[0].step=f("step")));c.trigger("reset")}if(c.hasClass("rateit")||c.addClass("rateit"),v=c.css("direction")!="rtl",o=="setvalue"){if(!f("init"))throw"Can't set value before init";i!="readonly"||r!=!0||f("readonly")||(c.find(".rateit-range").unbind(),f("wired",!1));i=="value"&&(r=r==null?f("min"):Math.max(f("min"),Math.min(f("max"),r)));f("backingfld")&&(h=n(f("backingfld")),i=="value"&&h.val(r),i=="min"&&h[0].min&&(h[0].min=r),i=="max"&&h[0].max&&(h[0].max=r),i=="step"&&h[0].step&&(h[0].step=r));f(i,r)}f("init")||(f("min",isNaN(f("min"))?u.min:f("min")),f("max",isNaN(f("max"))?u.max:f("max")),f("step",f("step")||u.step),f("readonly",f("readonly")!==undefined?f("readonly"):u.readonly),f("resetable",f("resetable")!==undefined?f("resetable"):u.resetable),f("backingfld",f("backingfld")||u.backingfld),f("starwidth",f("starwidth")||u.starwidth),f("starheight",f("starheight")||u.starheight),f("value",Math.max(f("min"),Math.min(f("max"),isNaN(f("value"))?isNaN(u.value)?u.min:u.value:f("value")))),f("ispreset",f("ispreset")!==undefined?f("ispreset"):u.ispreset),f("backingfld")&&(h=n(f("backingfld")).hide(),(h.attr("disabled")||h.attr("readonly"))&&f("readonly",!0),h[0].nodeName=="INPUT"&&(h[0].type=="range"||h[0].type=="text")&&(f("min",parseInt(h.attr("min"))||f("min")),f("max",parseInt(h.attr("max"))||f("max")),f("step",parseInt(h.attr("step"))||f("step"))),h[0].nodeName=="SELECT"&&h[0].options.length>1?(f("min",isNaN(f("min"))?Number(h[0].options[0].value):f("min")),f("max",Number(h[0].options[h[0].length-1].value)),f("step",Number(h[0].options[1].value)-Number(h[0].options[0].value)),b=h.find("option[selected]"),b.length==1&&f("value",b.val())):f("value",h.val())),g=c[0].nodeName=="DIV"?"div":"span",e++,nt='<button id="rateit-reset-{{index}}" type="button" data-role="none" class="rateit-reset" aria-label="'+n.rateit.aria.resetLabel+'" aria-controls="rateit-range-{{index}}"><\/button><{{element}} id="rateit-range-{{index}}" class="rateit-range" tabindex="0" role="slider" aria-label="'+n.rateit.aria.ratingLabel+'" aria-owns="rateit-reset-{{index}}" aria-valuemin="'+f("min")+'" aria-valuemax="'+f("max")+'" aria-valuenow="'+f("value")+'"><{{element}} class="rateit-selected" style="height:'+f("starheight")+'px"><\/{{element}}><{{element}} class="rateit-hover" style="height:'+f("starheight")+'px"><\/{{element}}><\/{{element}}>',c.append(nt.replace(/{{index}}/gi,e).replace(/{{element}}/gi,g)),v||(c.find(".rateit-reset").css("float","right"),c.find(".rateit-selected").addClass("rateit-selected-rtl"),c.find(".rateit-hover").addClass("rateit-hover-rtl")),f("init",JSON.parse(JSON.stringify(c.data()))));c.find(".rateit-selected, .rateit-hover").height(f("starheight"));l=c.find(".rateit-range");l.width(f("starwidth")*(f("max")-f("min"))).height(f("starheight"));y="rateit-preset"+(v?"":"-rtl");f("ispreset")?c.find(".rateit-selected").addClass(y):c.find(".rateit-selected").removeClass(y);f("value")!=null&&(k=(f("value")-f("min"))*f("starwidth"),c.find(".rateit-selected").width(k));a=c.find(".rateit-reset");a.data("wired")!==!0&&a.bind("click",function(t){t.preventDefault();a.blur();var i=n.Event("beforereset");if(c.trigger(i),i.isDefaultPrevented())return!1;c.rateit("value",null);c.trigger("reset")}).data("wired",!0);var tt=function(t,i){var u=i.changedTouches?i.changedTouches[0].pageX:i.pageX,r=u-n(t).offset().left;return v||(r=l.width()-r),r>l.width()&&(r=l.width()),r<0&&(r=0),k=Math.ceil(r/f("starwidth")*(1/f("step")))},it=function(n){var t=n*f("starwidth")*f("step"),r=l.find(".rateit-hover"),i;r.data("width")!=t&&(l.find(".rateit-selected").hide(),r.width(t).show().data("width",t),i=[n*f("step")+f("min")],c.trigger("hover",i).trigger("over",i))},d=function(t){var i=n.Event("beforerated");return(c.trigger(i,[t]),i.isDefaultPrevented())?!1:(f("value",t),f("backingfld")&&n(f("backingfld")).val(t).trigger("change"),f("ispreset")&&(l.find(".rateit-selected").removeClass(y),f("ispreset",!1)),l.find(".rateit-hover").hide(),l.find(".rateit-selected").width(t*f("starwidth")-f("min")*f("starwidth")).show(),c.trigger("hover",[null]).trigger("over",[null]).trigger("rated",[t]),!0)};f("readonly")?a.hide():(f("resetable")||a.hide(),f("wired")||(l.bind("touchmove touchend",t),l.mousemove(function(n){var t=tt(this,n);it(t)}),l.mouseleave(function(){l.find(".rateit-hover").hide().width(0).data("width","");c.trigger("hover",[null]).trigger("over",[null]);l.find(".rateit-selected").show()}),l.mouseup(function(n){var t=tt(this,n),i=t*f("step")+f("min");d(i);l.blur()}),l.keyup(function(n){(n.which==38||n.which==(v?39:37))&&d(Math.min(f("value")+f("step"),f("max")));(n.which==40||n.which==(v?37:39))&&d(Math.max(f("value")-f("step"),f("min")))}),f("wired",!0)),f("resetable")&&a.show());l.attr("aria-readonly",f("readonly"))})};n.fn.rateit.defaults={min:0,max:5,step:.5,starwidth:16,starheight:16,readonly:!1,resetable:!0,ispreset:!1};n(function(){n("div.rateit, span.rateit").rateit()})})(jQuery);
        /*
        //# sourceMappingURL=jquery.rateit.min.js.map
        */
        </script>


        <script>
            (function(){

                var solId = location.pathname.match('/sl/([0-9a-f-]+)$');
                if (solId === null) return;

                var settings = {
                    api : {
                        getComments:  '/DesktopModules/NexsoServices/API/Nexso/GetComments',
                        deleteComment:  '/DesktopModules/NexsoServices/API/Nexso/DeleteComment',
                        addComment:  '/DesktopModules/NexsoServices/API/Nexso/CommentSolution',

                    },
                    base_path : window.location.protocol+'//'+window.location.hostname,
                    language : $('input[name="CurrentLanguage"]').val() ? $('input[name="CurrentLanguage"]').val() : 'en-US',
                    uid : $('input[name="CurrentUserId"]').val(),
    
                    solutionId: solId[1]
                };

                // Document ready.
                $(function() {

                    if (!$("#comments-container").length) return;

                    Handlebars.registerPartial("comment", $("#comment-tpl").html());
                    Handlebars.registerPartial("comment-list", $("#comment-list-tpl").html());
    
                    // Handlebars helper for translations.
                    Handlebars.registerHelper('moment', function(date) {
                        if (typeof window.moment == 'undefined') return "";
                        return moment(date).format('MMMM Do YYYY, h:mm:ss a');
                    });
    
                    // Handlebars helper to break lines.
                    Handlebars.registerHelper('nl2br', function(text) {
                        var nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br/ >' + '$2');
                        return new Handlebars.SafeString(nl2br);
                    });
    
                    // Initialize comment controller.
                    CommentsCtrl.init();
    
                    // Render as empty.
                    CommentsCtrl.render();

                    // Get the rating value before fetching the comments
                    // since this is a one time thing.
                    CommentsCtrl.getUserRating(function(err) {
                        // Load comments form API and render them.
                        CommentsCtrl.getComments();
                    });

    
                });
  
                var CommentsCtrl = {
                    scope: {
                        loading: true,
                        comments: [],
                        user_logged: false,
                        solutionRate: 0,
                    },
                    tpl: null,
    
                    init: function() {
                        var source = $('#comments-tpl').html();
                        CommentsCtrl.scope.user_logged = settings.uid != -1;
                        CommentsCtrl.tpl = Handlebars.compile(source);
                    },
    
                    render: function() {
                        $('#comments-container').html(CommentsCtrl.tpl(CommentsCtrl.scope));

                        // Rate it plugin.
                        var $solutionRating = $("#solution-rating")
                        $solutionRating.rateit({step:1, resetable: false});
                        $solutionRating.on('rated', function (event, value) {
                            CommentsCtrl.addRating(value);
                        });

                        $solutionRating.rateit('value', CommentsCtrl.scope.solutionRate);

                        if (!CommentsCtrl.scope.user_logged) {
                            $solutionRating.rateit('readonly', true);
                        }

                        // Listener for the form.
                        $('#comment-submit').click(function() {
                            var _self = $(this);
                            if (_self.data('querying') !== true) {
                                _self.data('querying', true);
                                var comment_body = $('#comment-body').val();
                                if ($.trim(comment_body) === '') {
                                    console.log('please input something');
                                    return;
                                }
          
                                CommentsCtrl.addComment(comment_body, function() {
                                    // Clear field.
                                    $('#comment-body').val('');
                                    _self.data('querying', false);
                                });
                            }
                        });

                        // Attach listeners to delete buttons.
                        $('#comments-container #comment-list a[data-comment-id]').click(function(e) {
                            e.preventDefault();
                            var _self = $(this);
                            if (_self.data('querying') !== true) {
                                _self.data('querying', true);
                                // As of jQuery 1.4.3 HTML 5 data- attributes will be automatically
                                // pulled in to jQuery's data object.
                                var uuid = $(this).data('commentId');
                                CommentsCtrl.deleteComment(uuid, function() {
                                    _self.data('querying', false);
                                });
                            }
                        });
                    },
    
                    getUserRating: function(cb) {
                        $.get(settings.api.getRateSolution, {
                            'solutionId': settings.solutionId,
                            'userId': settings.uid,
                        }, function(data) {
                            if (data != -1 && !isNaN(data)) {
                                CommentsCtrl.scope.solutionRate = data;
                            }
                            if (typeof cb === 'function') cb();
                        }, 'json')
      
                        .fail(function() {
                            if (typeof cb === 'function') cb(true);
                        });
                    },
    
                    addRating: function(value, cb) {
                        $.ajax({
                            url: settings.api.rateSolution + '?solutionId=' + settings.solutionId + '&value=' + value,
                            type: 'PUT',

                        }).done(function(data) {
                            console.log(data);
                            if (typeof cb === 'function') cb();
                        })
      
                        .fail(function() {
                            if (typeof cb === 'function') cb(true);
                        });
                    },
    
                    getComments: function(cb) {
                        $.get(settings.api.getComments, {
                            'solutionId': settings.solutionId,
                            'scope': 'JUDGE',
                        }, function(data) {
                            //data = JSON.parse(data);
        
                            CommentsCtrl.scope.loading = false;
                            CommentsCtrl.scope.comments = data;
                            // Render again.
                            CommentsCtrl.render();
        
                            if (typeof cb === 'function') cb();
                        }, 'json')
      
                        .fail(function() {
                            if (typeof cb === 'function') cb(true);
                        });
                    },
    
                    deleteComment: function(uuid, cb) {
                        $.get(settings.api.deleteComment, {
                            'solutionCommentId': uuid
                        }, function() {
                            // Clean array instead of querying again.
                            CommentsCtrl.scope.comments = $.grep(CommentsCtrl.scope.comments, function(obj) {
                                return obj.CommentId == uuid;
                            }, true);
                            // Render again.
                            CommentsCtrl.render();
        
                            if (typeof cb === 'function') cb();
                        }, 'json')
      
                        .fail(function() {
                            if (typeof cb === 'function') cb(true);
                        });
                    },
    
                    addComment: function(comment, cb) {
                        $.get(settings.api.addComment, {
                            'txtComment': comment,
                            'scope': 'JUDGE',
                            'solutionId': settings.solutionId,
                            'Language': settings.language
                        }, function() {
                            // Load comments and render.
                            CommentsCtrl.getComments(cb);
                        }, 'json')
      
                        .fail(function() {
                            if (typeof cb === 'function') cb(true);
                        });
                    },
                };



                //////////////////////////////////////////////////////////////////////////
                ///////////////     TEMPORTY STATS CODE    ///////////////////////////////
                //////////////////////////////////////////////////////////////////////////

                $(function() {
                    var markup = $('#solution-stats-tpl').html();
                    // Inject it in the correct place.
                    $('#dnn_ctr6950_NXSolutionV2_dvActionBar').append(markup);

                    // Data URI in src don't work with nexso.
                    // It modified the src appending a prefix url.
                    // Use data-img and replace it later
                    $('.solution-stats .stat img').each(function(){
                        $(this).attr('src', $(this).attr('data-img'));
                    });

                    // Queries to update the values.
                    $.get(settings.api.getRateSolution, {
                        'solutionId': settings.solutionId
                    }, function(data) {
                        if (data != -1 && !isNaN(data)) {
                            $('.solution-stats .stat.rate .value').html(data);
                        }
                    }, 'json');

                    $.get(settings.api.getViewSolution, {
                        'solutionId': settings.solutionId
                    }, function(data) {
                        if (data != -1 && !isNaN(data)) {
                            $('.solution-stats .stat.view .value').html(data);
                        }
                    }, 'json');

                    $.get(settings.api.getComments, {
                        'solutionId': settings.solutionId,
                        'scope': 'JUDGE'
                    }, function(data) {
                        $('.solution-stats .stat.comment .value').html(data.length || 0);
                    }, 'json');
                });

                //////////////////////////////////////////////////////////////////////////
                ///////////////     END TEMPORTY STATS CODE    ///////////////////////////
                //////////////////////////////////////////////////////////////////////////

  
            })();
        </script>

        <style type="text/css">
            .rateit {
            display: -moz-inline-box;
            display: inline-block;
            position: relative;
                -webkit-user-select: none;
                -khtml-user-select: none;
                -moz-user-select: none;
                -o-user-select: none;
                -ms-user-select: none;
                user-select: none;
                -webkit-touch-callout: none;
            }

        .rateit .rateit-range {
            position: relative;
            display: -moz-inline-box;
            display: inline-block;
            background: url('data:image/gif;base64,R0lGODlhEABAAPejAN7e3sJKSsVSUsdaWtBzc81sbO/FKe92KclgYOVxOOy8IuW2OOxrIr9CQufn59N8fOt6RN9pMe2MSe7u7uu9RO3OSd+vMerLRvXeXfHNL+mzG/WhXeqJRvb29u/IT/F/L++IT+lgG+2VWuWtONSEhPKLRfTZWt1gKeSvr92oKemDQc97e/GPU+3QWvHOU+nGQfSbWvLQReVnOOZ6OffUvO5+QdmdJeZ7Qu12MPfp6ea9Qu+TTNlVJffsvOyheezPefnu7u/VTPKXWPLVWPLWVe3CMPG5mu7DQfHcmrhERPKXVduUlPvt5tiMjNqpqfv15vzz7/z47+a/OezHx92qReS7Suq1K/Guf+mITPSOQPLfsON3Q9ZUK/vn2PfrtenHTPTf39FBGfKeV+liIOK2NO7DS+hiJaE3N+vOh91tRefCWuO4Q/amYuiwJfLFsOvNmfCBOeusmfDLOdOPIvbhYtaZK8XFxfHbove6nOpoK/TWQPLcV9GLGe3Ly8BgYO3Sq+SKZurJgey/SPfRtdeSku24q/G7oui6uuumh+nHbq1GRueVcumWbueJWumzIMw0DeR9Sux9SLRMTPv12PfenOS9ZtNIIvHcf+JwNMyADao/P+6CS////+fEcuqfgd66utbW1sxmZszMzP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH/C1hNUCBEYXRhWE1QPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS4wLWMwNjAgNjEuMTM0Nzc3LCAyMDEwLzAyLzEyLTE3OjMyOjAwICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdFJlZj0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlUmVmIyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ1M1IFdpbmRvd3MiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6REEwM0VCRTE5NDA2MTFFMDhDRTg4MzdGNDREQTdFQUUiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6REEwM0VCRTI5NDA2MTFFMDhDRTg4MzdGNDREQTdFQUUiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpEQTAzRUJERjk0MDYxMUUwOENFODgzN0Y0NERBN0VBRSIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpEQTAzRUJFMDk0MDYxMUUwOENFODgzN0Y0NERBN0VBRSIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PgH//v38+/r5+Pf29fTz8vHw7+7t7Ovq6ejn5uXk4+Lh4N/e3dzb2tnY19bV1NPS0dDPzs3My8rJyMfGxcTDwsHAv769vLu6ubi3trW0s7KxsK+urayrqqmop6alpKOioaCfnp2cm5qZmJeWlZSTkpGQj46NjIuKiYiHhoWEg4KBgH9+fXx7enl4d3Z1dHNycXBvbm1sa2ppaGdmZWRjYmFgX15dXFtaWVhXVlVUU1JRUE9OTUxLSklIR0ZFRENCQUA/Pj08Ozo5ODc2NTQzMjEwLy4tLCsqKSgnJiUkIyIhIB8eHRwbGhkYFxYVFBMSERAPDg0MCwoJCAcGBQQDAgEAACH5BAEAAKMALAAAAAAQAEAAAAj/AEcJHDiqwwSCCBGCApWw4YSFDhoqXMhQokAHoAAAyJhwgsaFGymCdNBho8aPIlOOAilSlEtRC0VxEsgypsuYHQi2fAlKVE6CGHvy5IgwZMuFCY2mFJWQoiiNL5kidBlxoANRdjpKPGgRTB+LCAmEAjtwSqhQKMiOCkWAwACyKEI9eICgScIpSwggCLWiAAK3AkKRQJGjL4G5DwoIEDCggN8BAgKMckwi1ADIkQMECBUZiMCzDzBrbsA5gOeBf0sHaEC6QQ6ETv5qXn15RcImZwXsjTzAT0ICBdpePjtAUsLGAhqQIJQkiQBNCTUvIehE0ZmEhyR+Ajuph1qBLS58/+9RoQIStReIEJFCllIFEyZe/Ejo5VKLF+9jyHEhhUyVRHc80UIQe2BgYAwGGFCEB2VQsIAFFoziQhB06JFBBgkqoIAjFIxgQRQCfVEBBhcaoKEGgoyQAogD6TAEgiZqoAEFKTyBEBIvDGGiAhossEAlCf1wwQVFHHGEFW0sQEVCanjgggc6LECBg3UktIYHC6TQSSA22DACHwlBiAZBb8yRSUJaSPQHWF3Q8N0oInDwHQ0SSGCEWhwoocQMZOEhAQwwqOBDQoNcIYIKf5YABwszYAIJI4YwIcIOYmxgaQkHHIADCJtAkEAEEYzCwg5sZPHBB5kywMAYEMgQARQCYV8hwQanHqBqCJHIcAKsA90gBKa2hhACBCcwgZARKghhKwMhJJAAIAn5wAEHONRQQx5mJJBGQo2AwAIINyQAgadcJLQFCAmcsIgnPPAgQxgJgYoIQXFY8khCbkhUyEABAQA7');
            height: 16px;
            outline: none;
        }

        .rateit .rateit-range * {
            display: block;
    }

        /* for IE 6 */
        * html .rateit, * html .rateit .rateit-range {
            display: inline;
        }

        /* for IE 7 */
        * + html .rateit, * + html .rateit .rateit-range {
            display: inline;
        }

        .rateit .rateit-hover, .rateit .rateit-selected {
            position: absolute;
            left: 0px;
        }

        .rateit .rateit-hover-rtl, .rateit .rateit-selected-rtl {
            left: auto;
            right: 0px;
        }

        .rateit .rateit-hover {
            background: url('data:image/gif;base64,R0lGODlhEABAAPejAN7e3sJKSsVSUsdaWtBzc81sbO/FKe92KclgYOVxOOy8IuW2OOxrIr9CQufn59N8fOt6RN9pMe2MSe7u7uu9RO3OSd+vMerLRvXeXfHNL+mzG/WhXeqJRvb29u/IT/F/L++IT+lgG+2VWuWtONSEhPKLRfTZWt1gKeSvr92oKemDQc97e/GPU+3QWvHOU+nGQfSbWvLQReVnOOZ6OffUvO5+QdmdJeZ7Qu12MPfp6ea9Qu+TTNlVJffsvOyheezPefnu7u/VTPKXWPLVWPLWVe3CMPG5mu7DQfHcmrhERPKXVduUlPvt5tiMjNqpqfv15vzz7/z47+a/OezHx92qReS7Suq1K/Guf+mITPSOQPLfsON3Q9ZUK/vn2PfrtenHTPTf39FBGfKeV+liIOK2NO7DS+hiJaE3N+vOh91tRefCWuO4Q/amYuiwJfLFsOvNmfCBOeusmfDLOdOPIvbhYtaZK8XFxfHbove6nOpoK/TWQPLcV9GLGe3Ly8BgYO3Sq+SKZurJgey/SPfRtdeSku24q/G7oui6uuumh+nHbq1GRueVcumWbueJWumzIMw0DeR9Sux9SLRMTPv12PfenOS9ZtNIIvHcf+JwNMyADao/P+6CS////+fEcuqfgd66utbW1sxmZszMzP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH/C1hNUCBEYXRhWE1QPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS4wLWMwNjAgNjEuMTM0Nzc3LCAyMDEwLzAyLzEyLTE3OjMyOjAwICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdFJlZj0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlUmVmIyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ1M1IFdpbmRvd3MiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6REEwM0VCRTE5NDA2MTFFMDhDRTg4MzdGNDREQTdFQUUiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6REEwM0VCRTI5NDA2MTFFMDhDRTg4MzdGNDREQTdFQUUiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpEQTAzRUJERjk0MDYxMUUwOENFODgzN0Y0NERBN0VBRSIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpEQTAzRUJFMDk0MDYxMUUwOENFODgzN0Y0NERBN0VBRSIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PgH//v38+/r5+Pf29fTz8vHw7+7t7Ovq6ejn5uXk4+Lh4N/e3dzb2tnY19bV1NPS0dDPzs3My8rJyMfGxcTDwsHAv769vLu6ubi3trW0s7KxsK+urayrqqmop6alpKOioaCfnp2cm5qZmJeWlZSTkpGQj46NjIuKiYiHhoWEg4KBgH9+fXx7enl4d3Z1dHNycXBvbm1sa2ppaGdmZWRjYmFgX15dXFtaWVhXVlVUU1JRUE9OTUxLSklIR0ZFRENCQUA/Pj08Ozo5ODc2NTQzMjEwLy4tLCsqKSgnJiUkIyIhIB8eHRwbGhkYFxYVFBMSERAPDg0MCwoJCAcGBQQDAgEAACH5BAEAAKMALAAAAAAQAEAAAAj/AEcJHDiqwwSCCBGCApWw4YSFDhoqXMhQokAHoAAAyJhwgsaFGymCdNBho8aPIlOOAilSlEtRC0VxEsgypsuYHQi2fAlKVE6CGHvy5IgwZMuFCY2mFJWQoiiNL5kidBlxoANRdjpKPGgRTB+LCAmEAjtwSqhQKMiOCkWAwACyKEI9eICgScIpSwggCLWiAAK3AkKRQJGjL4G5DwoIEDCggN8BAgKMckwi1ADIkQMECBUZiMCzDzBrbsA5gOeBf0sHaEC6QQ6ETv5qXn15RcImZwXsjTzAT0ICBdpePjtAUsLGAhqQIJQkiQBNCTUvIehE0ZmEhyR+Ajuph1qBLS58/+9RoQIStReIEJFCllIFEyZe/Ejo5VKLF+9jyHEhhUyVRHc80UIQe2BgYAwGGFCEB2VQsIAFFoziQhB06JFBBgkqoIAjFIxgQRQCfVEBBhcaoKEGgoyQAogD6TAEgiZqoAEFKTyBEBIvDGGiAhossEAlCf1wwQVFHHGEFW0sQEVCanjgggc6LECBg3UktIYHC6TQSSA22DACHwlBiAZBb8yRSUJaSPQHWF3Q8N0oInDwHQ0SSGCEWhwoocQMZOEhAQwwqOBDQoNcIYIKf5YABwszYAIJI4YwIcIOYmxgaQkHHIADCJtAkEAEEYzCwg5sZPHBB5kywMAYEMgQARQCYV8hwQanHqBqCJHIcAKsA90gBKa2hhACBCcwgZARKghhKwMhJJAAIAn5wAEHONRQQx5mJJBGQo2AwAIINyQAgadcJLQFCAmcsIgnPPAgQxgJgYoIQXFY8khCbkhUyEABAQA7') left -32px;
        }

        .rateit .rateit-hover-rtl {
            background-position: right -32px;
        }

        .rateit .rateit-selected {
            background: url('data:image/gif;base64,R0lGODlhEABAAPejAN7e3sJKSsVSUsdaWtBzc81sbO/FKe92KclgYOVxOOy8IuW2OOxrIr9CQufn59N8fOt6RN9pMe2MSe7u7uu9RO3OSd+vMerLRvXeXfHNL+mzG/WhXeqJRvb29u/IT/F/L++IT+lgG+2VWuWtONSEhPKLRfTZWt1gKeSvr92oKemDQc97e/GPU+3QWvHOU+nGQfSbWvLQReVnOOZ6OffUvO5+QdmdJeZ7Qu12MPfp6ea9Qu+TTNlVJffsvOyheezPefnu7u/VTPKXWPLVWPLWVe3CMPG5mu7DQfHcmrhERPKXVduUlPvt5tiMjNqpqfv15vzz7/z47+a/OezHx92qReS7Suq1K/Guf+mITPSOQPLfsON3Q9ZUK/vn2PfrtenHTPTf39FBGfKeV+liIOK2NO7DS+hiJaE3N+vOh91tRefCWuO4Q/amYuiwJfLFsOvNmfCBOeusmfDLOdOPIvbhYtaZK8XFxfHbove6nOpoK/TWQPLcV9GLGe3Ly8BgYO3Sq+SKZurJgey/SPfRtdeSku24q/G7oui6uuumh+nHbq1GRueVcumWbueJWumzIMw0DeR9Sux9SLRMTPv12PfenOS9ZtNIIvHcf+JwNMyADao/P+6CS////+fEcuqfgd66utbW1sxmZszMzP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH/C1hNUCBEYXRhWE1QPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS4wLWMwNjAgNjEuMTM0Nzc3LCAyMDEwLzAyLzEyLTE3OjMyOjAwICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdFJlZj0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlUmVmIyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ1M1IFdpbmRvd3MiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6REEwM0VCRTE5NDA2MTFFMDhDRTg4MzdGNDREQTdFQUUiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6REEwM0VCRTI5NDA2MTFFMDhDRTg4MzdGNDREQTdFQUUiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpEQTAzRUJERjk0MDYxMUUwOENFODgzN0Y0NERBN0VBRSIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpEQTAzRUJFMDk0MDYxMUUwOENFODgzN0Y0NERBN0VBRSIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PgH//v38+/r5+Pf29fTz8vHw7+7t7Ovq6ejn5uXk4+Lh4N/e3dzb2tnY19bV1NPS0dDPzs3My8rJyMfGxcTDwsHAv769vLu6ubi3trW0s7KxsK+urayrqqmop6alpKOioaCfnp2cm5qZmJeWlZSTkpGQj46NjIuKiYiHhoWEg4KBgH9+fXx7enl4d3Z1dHNycXBvbm1sa2ppaGdmZWRjYmFgX15dXFtaWVhXVlVUU1JRUE9OTUxLSklIR0ZFRENCQUA/Pj08Ozo5ODc2NTQzMjEwLy4tLCsqKSgnJiUkIyIhIB8eHRwbGhkYFxYVFBMSERAPDg0MCwoJCAcGBQQDAgEAACH5BAEAAKMALAAAAAAQAEAAAAj/AEcJHDiqwwSCCBGCApWw4YSFDhoqXMhQokAHoAAAyJhwgsaFGymCdNBho8aPIlOOAilSlEtRC0VxEsgypsuYHQi2fAlKVE6CGHvy5IgwZMuFCY2mFJWQoiiNL5kidBlxoANRdjpKPGgRTB+LCAmEAjtwSqhQKMiOCkWAwACyKEI9eICgScIpSwggCLWiAAK3AkKRQJGjL4G5DwoIEDCggN8BAgKMckwi1ADIkQMECBUZiMCzDzBrbsA5gOeBf0sHaEC6QQ6ETv5qXn15RcImZwXsjTzAT0ICBdpePjtAUsLGAhqQIJQkiQBNCTUvIehE0ZmEhyR+Ajuph1qBLS58/+9RoQIStReIEJFCllIFEyZe/Ejo5VKLF+9jyHEhhUyVRHc80UIQe2BgYAwGGFCEB2VQsIAFFoziQhB06JFBBgkqoIAjFIxgQRQCfVEBBhcaoKEGgoyQAogD6TAEgiZqoAEFKTyBEBIvDGGiAhossEAlCf1wwQVFHHGEFW0sQEVCanjgggc6LECBg3UktIYHC6TQSSA22DACHwlBiAZBb8yRSUJaSPQHWF3Q8N0oInDwHQ0SSGCEWhwoocQMZOEhAQwwqOBDQoNcIYIKf5YABwszYAIJI4YwIcIOYmxgaQkHHIADCJtAkEAEEYzCwg5sZPHBB5kywMAYEMgQARQCYV8hwQanHqBqCJHIcAKsA90gBKa2hhACBCcwgZARKghhKwMhJJAAIAn5wAEHONRQQx5mJJBGQo2AwAIINyQAgadcJLQFCAmcsIgnPPAgQxgJgYoIQXFY8khCbkhUyEABAQA7') left -16px;
        }

        .rateit .rateit-selected-rtl {
            background-position: right -16px;
        }

        .rateit .rateit-preset {
            background: url('data:image/gif;base64,R0lGODlhEABAAPejAN7e3sJKSsVSUsdaWtBzc81sbO/FKe92KclgYOVxOOy8IuW2OOxrIr9CQufn59N8fOt6RN9pMe2MSe7u7uu9RO3OSd+vMerLRvXeXfHNL+mzG/WhXeqJRvb29u/IT/F/L++IT+lgG+2VWuWtONSEhPKLRfTZWt1gKeSvr92oKemDQc97e/GPU+3QWvHOU+nGQfSbWvLQReVnOOZ6OffUvO5+QdmdJeZ7Qu12MPfp6ea9Qu+TTNlVJffsvOyheezPefnu7u/VTPKXWPLVWPLWVe3CMPG5mu7DQfHcmrhERPKXVduUlPvt5tiMjNqpqfv15vzz7/z47+a/OezHx92qReS7Suq1K/Guf+mITPSOQPLfsON3Q9ZUK/vn2PfrtenHTPTf39FBGfKeV+liIOK2NO7DS+hiJaE3N+vOh91tRefCWuO4Q/amYuiwJfLFsOvNmfCBOeusmfDLOdOPIvbhYtaZK8XFxfHbove6nOpoK/TWQPLcV9GLGe3Ly8BgYO3Sq+SKZurJgey/SPfRtdeSku24q/G7oui6uuumh+nHbq1GRueVcumWbueJWumzIMw0DeR9Sux9SLRMTPv12PfenOS9ZtNIIvHcf+JwNMyADao/P+6CS////+fEcuqfgd66utbW1sxmZszMzP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH/C1hNUCBEYXRhWE1QPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS4wLWMwNjAgNjEuMTM0Nzc3LCAyMDEwLzAyLzEyLTE3OjMyOjAwICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdFJlZj0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlUmVmIyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ1M1IFdpbmRvd3MiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6REEwM0VCRTE5NDA2MTFFMDhDRTg4MzdGNDREQTdFQUUiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6REEwM0VCRTI5NDA2MTFFMDhDRTg4MzdGNDREQTdFQUUiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpEQTAzRUJERjk0MDYxMUUwOENFODgzN0Y0NERBN0VBRSIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpEQTAzRUJFMDk0MDYxMUUwOENFODgzN0Y0NERBN0VBRSIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PgH//v38+/r5+Pf29fTz8vHw7+7t7Ovq6ejn5uXk4+Lh4N/e3dzb2tnY19bV1NPS0dDPzs3My8rJyMfGxcTDwsHAv769vLu6ubi3trW0s7KxsK+urayrqqmop6alpKOioaCfnp2cm5qZmJeWlZSTkpGQj46NjIuKiYiHhoWEg4KBgH9+fXx7enl4d3Z1dHNycXBvbm1sa2ppaGdmZWRjYmFgX15dXFtaWVhXVlVUU1JRUE9OTUxLSklIR0ZFRENCQUA/Pj08Ozo5ODc2NTQzMjEwLy4tLCsqKSgnJiUkIyIhIB8eHRwbGhkYFxYVFBMSERAPDg0MCwoJCAcGBQQDAgEAACH5BAEAAKMALAAAAAAQAEAAAAj/AEcJHDiqwwSCCBGCApWw4YSFDhoqXMhQokAHoAAAyJhwgsaFGymCdNBho8aPIlOOAilSlEtRC0VxEsgypsuYHQi2fAlKVE6CGHvy5IgwZMuFCY2mFJWQoiiNL5kidBlxoANRdjpKPGgRTB+LCAmEAjtwSqhQKMiOCkWAwACyKEI9eICgScIpSwggCLWiAAK3AkKRQJGjL4G5DwoIEDCggN8BAgKMckwi1ADIkQMECBUZiMCzDzBrbsA5gOeBf0sHaEC6QQ6ETv5qXn15RcImZwXsjTzAT0ICBdpePjtAUsLGAhqQIJQkiQBNCTUvIehE0ZmEhyR+Ajuph1qBLS58/+9RoQIStReIEJFCllIFEyZe/Ejo5VKLF+9jyHEhhUyVRHc80UIQe2BgYAwGGFCEB2VQsIAFFoziQhB06JFBBgkqoIAjFIxgQRQCfVEBBhcaoKEGgoyQAogD6TAEgiZqoAEFKTyBEBIvDGGiAhossEAlCf1wwQVFHHGEFW0sQEVCanjgggc6LECBg3UktIYHC6TQSSA22DACHwlBiAZBb8yRSUJaSPQHWF3Q8N0oInDwHQ0SSGCEWhwoocQMZOEhAQwwqOBDQoNcIYIKf5YABwszYAIJI4YwIcIOYmxgaQkHHIADCJtAkEAEEYzCwg5sZPHBB5kywMAYEMgQARQCYV8hwQanHqBqCJHIcAKsA90gBKa2hhACBCcwgZARKghhKwMhJJAAIAn5wAEHONRQQx5mJJBGQo2AwAIINyQAgadcJLQFCAmcsIgnPPAgQxgJgYoIQXFY8khCbkhUyEABAQA7') left -48px;
        }

        .rateit .rateit-preset-rtl {
            background: url('data:image/gif;base64,R0lGODlhEABAAPejAN7e3sJKSsVSUsdaWtBzc81sbO/FKe92KclgYOVxOOy8IuW2OOxrIr9CQufn59N8fOt6RN9pMe2MSe7u7uu9RO3OSd+vMerLRvXeXfHNL+mzG/WhXeqJRvb29u/IT/F/L++IT+lgG+2VWuWtONSEhPKLRfTZWt1gKeSvr92oKemDQc97e/GPU+3QWvHOU+nGQfSbWvLQReVnOOZ6OffUvO5+QdmdJeZ7Qu12MPfp6ea9Qu+TTNlVJffsvOyheezPefnu7u/VTPKXWPLVWPLWVe3CMPG5mu7DQfHcmrhERPKXVduUlPvt5tiMjNqpqfv15vzz7/z47+a/OezHx92qReS7Suq1K/Guf+mITPSOQPLfsON3Q9ZUK/vn2PfrtenHTPTf39FBGfKeV+liIOK2NO7DS+hiJaE3N+vOh91tRefCWuO4Q/amYuiwJfLFsOvNmfCBOeusmfDLOdOPIvbhYtaZK8XFxfHbove6nOpoK/TWQPLcV9GLGe3Ly8BgYO3Sq+SKZurJgey/SPfRtdeSku24q/G7oui6uuumh+nHbq1GRueVcumWbueJWumzIMw0DeR9Sux9SLRMTPv12PfenOS9ZtNIIvHcf+JwNMyADao/P+6CS////+fEcuqfgd66utbW1sxmZszMzP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH/C1hNUCBEYXRhWE1QPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS4wLWMwNjAgNjEuMTM0Nzc3LCAyMDEwLzAyLzEyLTE3OjMyOjAwICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdFJlZj0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlUmVmIyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ1M1IFdpbmRvd3MiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6REEwM0VCRTE5NDA2MTFFMDhDRTg4MzdGNDREQTdFQUUiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6REEwM0VCRTI5NDA2MTFFMDhDRTg4MzdGNDREQTdFQUUiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpEQTAzRUJERjk0MDYxMUUwOENFODgzN0Y0NERBN0VBRSIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpEQTAzRUJFMDk0MDYxMUUwOENFODgzN0Y0NERBN0VBRSIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PgH//v38+/r5+Pf29fTz8vHw7+7t7Ovq6ejn5uXk4+Lh4N/e3dzb2tnY19bV1NPS0dDPzs3My8rJyMfGxcTDwsHAv769vLu6ubi3trW0s7KxsK+urayrqqmop6alpKOioaCfnp2cm5qZmJeWlZSTkpGQj46NjIuKiYiHhoWEg4KBgH9+fXx7enl4d3Z1dHNycXBvbm1sa2ppaGdmZWRjYmFgX15dXFtaWVhXVlVUU1JRUE9OTUxLSklIR0ZFRENCQUA/Pj08Ozo5ODc2NTQzMjEwLy4tLCsqKSgnJiUkIyIhIB8eHRwbGhkYFxYVFBMSERAPDg0MCwoJCAcGBQQDAgEAACH5BAEAAKMALAAAAAAQAEAAAAj/AEcJHDiqwwSCCBGCApWw4YSFDhoqXMhQokAHoAAAyJhwgsaFGymCdNBho8aPIlOOAilSlEtRC0VxEsgypsuYHQi2fAlKVE6CGHvy5IgwZMuFCY2mFJWQoiiNL5kidBlxoANRdjpKPGgRTB+LCAmEAjtwSqhQKMiOCkWAwACyKEI9eICgScIpSwggCLWiAAK3AkKRQJGjL4G5DwoIEDCggN8BAgKMckwi1ADIkQMECBUZiMCzDzBrbsA5gOeBf0sHaEC6QQ6ETv5qXn15RcImZwXsjTzAT0ICBdpePjtAUsLGAhqQIJQkiQBNCTUvIehE0ZmEhyR+Ajuph1qBLS58/+9RoQIStReIEJFCllIFEyZe/Ejo5VKLF+9jyHEhhUyVRHc80UIQe2BgYAwGGFCEB2VQsIAFFoziQhB06JFBBgkqoIAjFIxgQRQCfVEBBhcaoKEGgoyQAogD6TAEgiZqoAEFKTyBEBIvDGGiAhossEAlCf1wwQVFHHGEFW0sQEVCanjgggc6LECBg3UktIYHC6TQSSA22DACHwlBiAZBb8yRSUJaSPQHWF3Q8N0oInDwHQ0SSGCEWhwoocQMZOEhAQwwqOBDQoNcIYIKf5YABwszYAIJI4YwIcIOYmxgaQkHHIADCJtAkEAEEYzCwg5sZPHBB5kywMAYEMgQARQCYV8hwQanHqBqCJHIcAKsA90gBKa2hhACBCcwgZARKghhKwMhJJAAIAn5wAEHONRQQx5mJJBGQo2AwAIINyQAgadcJLQFCAmcsIgnPPAgQxgJgYoIQXFY8khCbkhUyEABAQA7') left -48px;
        }

        .rateit button.rateit-reset {
            background: url('data:image/gif;base64,R0lGODlhEAAgAOYAALlRM729vZmZmd/f35SUlNullfJ2YtbW1uZVS913cvX19c5hU+fEubW1tfOmou6DfNRwZO/v78XFxa2trfbPz/qZhuliWtZtY71bP/CLdu6LgPSfnczMzPXm4cNkS+qwrO7Iw+ZVT9dcUPCEb6WlpcNPM+J+fPGclfCQfv///+fn5/jCveNtYvvr6/3c2NtVSvm4rvqqnOxeU+R3cMZqU+5lUe2SjeuyruqCfL5TOfqikN5qae/KxuBkW+Cqn/i1p9BOPfNyXPnTzON3ePuom71jSuZZUel6b81nV+5pXffn5cBMMvzHufN4YuZXS/aDa/eSffWupPGNefWinviLdd54c+h5dOdcWPqcittoZPC0tfSNgPKsqdZfU/nLw8xRO/zUzeN+fP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEHAGIALAAAAAAQACAAAAf/gGKCg4SFhQoDAQ0NAQcKhmIqARwDKioHDRMDhSoNBxEDHBwHiSSbggqNERwSra2YJI9iBxIqrAG4uQcCHIKNtIvBjBIBJIINoQEpy8wTDRwCx7TKzMvOHAS+rZkT3d7E0bMkmNzeEwcEEqjOmObnEwIRgwMk5xKLEgckBAeF9AKTOAQgIKCfoVUkBBCUIA+Sw4cQC7XQYmLHjio3WkCiMMTGCiFefrC4wKMQhR1cXMDQgYUIkyMLQAxqMcSBiwoopECBQkUkEiWCtOAAgwVKhidInzSJAsSHoDBRYmSQQbWqgS1WaAjaAQPKiGrLnCQ5kUNQlhhIwaZwYoGsoAQaTaAEcUK3rpMHVTwI+vDCQY0adp0YmVKigKAWEFhEoWp3ShcMHQbxWNDDwQMLVx5sEAGAQSEQSL5YsWFjxhIMng0p8UEDQw4PBSJHdBgIADs=') 0 0;
            width: 16px;
            height: 16px;
            display: -moz-inline-box;
            display: inline-block;
            float: left;
            outline: none;
            border: none;
            padding: 0;
        }

        .rateit button.rateit-reset:hover, .rateit button.rateit-reset:focus {
            background-position: 0 -16px;
        }
        </style>

        <style type="text/css">
            .solution-stats {
            overflow: auto;
            }

        .solution-stats .stat {
            float: left;
            text-align: center;
            color: #79AFCB;
            font-size: 12px;
            padding: 0 15px;
            border-right: 1px solid #eee;
        }

        .solution-stats .stat:last-child {
            border: none;
        }

        .solution-stats .img {
            width: 16px;
        }
        </style>
        <script src="<%=ControlPath%>js/jquery.alerts.js"></script>
        <link href="<%=ControlPath%>css/jquery.alerts.css" rel="stylesheet" />
        <input id="hfOwnerSolutionId" type="hidden" value="<%=solutionComponent.Solution.CreatedUserId.GetValueOrDefault(-1).ToString()%>" />

        <script type="text/javascript">

            function PopUpReportSpam(){
    
                var messageConfirmation ='<%=Localization.GetString("PopUpReportSpam", this.LocalResourceFile)%>';
                var title= "";
                jAlert(messageConfirmation, title);
            }

        function ErrorScore(){
    
            var messageConfirmation ='<%=Localization.GetString("PopUpError", this.LocalResourceFile)%>';
            var title= "";
            jAlert(messageConfirmation, title);
        }
        function Finish(){
    
            var messageConfirmation ='<%=Localization.GetString("PopUpConfirmation", this.LocalResourceFile)%>';
            var title= "";
            jAlert(messageConfirmation, title);

        }

        $(document).ready(function () {
            activateTransalte();
        }
            );

        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);
        function EndRequestHandler(sender, args) {

            activateTransalte();
        }

        function activateTransalte() {
            if ('<%=System.Threading.Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName.ToUpper()%>' != '<%=SolutionLanguage%>') {
                if ('<%=System.Threading.Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName.ToUpper()%>' == 'EN') {
                    $('#btnTranslate').val('Translate');
                }
                else if ('<%=System.Threading.Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName.ToUpper()%>' == 'ES') {
                    $('#btnTranslate').val('Traducir');
                }
                else if ('<%=System.Threading.Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName.ToUpper()%>' == 'PT') {
                    $('#btnTranslate').val('Traduzir');
                }
                $('#btnTranslate').show();
            } else {
                $('#btnTranslate').hide();
            }
        }

        function translateAll() {

            var count = $('#<%=lblCount.ClientID%>').html();
            TranslateControl($('#<%=lblChallenge.ClientID%>'), null, false, count);
            TranslateControl($('#<%=lblApproach.ClientID%>'), null, false, count);
            TranslateControl($('#<%=lblResults.ClientID%>'), null, false, count);
            TranslateControl($('#<%=lblDescription.ClientID%>'), null, false, count);
            TranslateControl($('#<%=lblCostDetails.ClientID%>'), null, false, count);
            TranslateControl($('#<%=lbldurationDetails.ClientID%>'), null, false, count);
            TranslateControl($('#<%=lblImplementationDetails.ClientID%>'), null, false, count);
            TranslateControl($('#<%=lblOrganizationDescription.ClientID%>'), null, false, count);
            TranslateControl($('#<%=lblTitle.ClientID%>'), $('#<%=hfTitle.ClientID%>'), true, count);
            TranslateControl($('#<%=lblTitle2.ClientID%>'), $('#<%=hfTitle.ClientID%>'), true, count);
            TranslateControl($('#<%=lblTagLine.ClientID%>'), $('#<%=hfTagLine.ClientID%>'), true, count);
            TranslateControl($('#<%=lblInstitutionName.ClientID%>'), $('#<%=hfInstitutionName.ClientID%>'), true, count);

            $('#<%=lblCount.ClientID%>').html(parseInt(count) + 1);

        }






        function TranslateControl(control, control2, sw, count) {

            var text;
            if (sw) {
                text = control2.html()
            }
            else {
                text = control.html();
            }

            var apiKey = "AIzaSyB1gqjm4RqlcFCBJvPSlblg1uZNSkrFsgg";

            var langTarget = '<%=System.Threading.Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName.ToUpper()%>';
            var langSource = '<%=SolutionLanguage%>';
            var apiurl = "https://www.googleapis.com/language/translate/v2?key=" + apiKey + "&source=" + langSource + "&target=" + langTarget + "&q=";
            var failed = 0;

            // Now we call the data
            $.ajax({
                url: apiurl + encodeURIComponent(text),
                dataType: 'jsonp',
                type: "GET",
                beforeSend: function () {
                    if (failed == 1) {
                        control.html('<span class="translated">Translating Again ...</span>'); // Updates the status of translation.
                    }
                    else {
                        control.html('<span class="translated">Translating...</span>'); // Updates the status of translation.
                    }
                },
                success: function (data) {
                    var MessageTransalte = $('#<%=MessageTransalte.ClientID%>');
                    MessageTransalte.html('</span><span class="translatedGoogle"> Translated by google</span>');
                    var MessageTransalte2 = $('#<%=MessageTransalte2.ClientID%>');
                    MessageTransalte2.html('</span><span class="translatedGoogle"> Translated by google</span>');
                    if (sw) {
                        control.html(text + '<span class="translated"> (' + data.data.translations[0].translatedText + ') </span>'); // Inserts translated text.
                    }
                    else {
                        if (count == 0) {
                            control.html('<span class="translated">' + data.data.translations[0].translatedText + '</span><span class="translatedGoogle"> Translated by google</span>');  // Inserts translated text.

                        } else {

                            control.html(text);
                        }

                    }
                },
                error: function (data) {
                    failed = 1;
                    control.html('<span class="translated">Translation Failed!</span>');
                }
            });

            return false;

        }

        </script>
