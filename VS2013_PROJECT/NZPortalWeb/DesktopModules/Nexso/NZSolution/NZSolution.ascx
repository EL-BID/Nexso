<%@ Control Language="C#" AutoEventWireup="true" CodeFile="NZSolution.ascx.cs" Inherits="NZSolution" %>

<%@ Register Src="../NXOtherControls/CountryStateCityV2.ascx" TagName="NXMapModule"
    TagPrefix="uc1" %>
<%@ Register Src="../NXOtherControls/FileUploaderWizard.ascx" TagName="FileUploaderWizard"
    TagPrefix="uc4" %>
<link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css" rel="stylesheet">




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
                                    <input id="btnEnableBannerUploader" class="btn" type="button" value="<%=Localization.GetString("btnEnableBannerUploader", LocalResourceFile)%>" />
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
                                    <asp:Label ID="lblTitle" runat="server"></asp:Label></h1>

                                <asp:Label runat="server" ID="hfTitle" />
                                <!-- <p class="meta"></p> -->
                            </div>
                        </div>

                        <div class="curator-container-responsive" runat="server" id="curatorResponsive">
                            <img src="<%=ControlPath%>/images/curatorResponsive.png" />
                        </div>

                    </div>
                    <div class="curator-container" style="position: relative; margin: -10px -1px 0 -1px; z-index: 1000;" runat="server" id="curatorContainer">
                        <img src="<%=ControlPath%>/images/Curator%202.png" />
                        <div style="position: absolute; z-index: 2000; top: 0; margin-top: 15px; margin-left: 10%; color: #fff; font-size: 25px;">
                            <span>
                                <asp:Label runat="server" ID="lblCurator"></asp:Label><strong><asp:Label runat="server" ID="lblNameCurator"></asp:Label></strong></span>
                        </div>
                    </div>


                    <!--/ cover -->

                    <!-- actions -->
                    <div id="dvActionBar" runat="server" class="actions">
                        <div class="actions-global">
                            <a title="<%=Localization.GetString("FeedBackToolTip", LocalResourceFile)%>" class="link-action feedback" href="#comments-container"><%=Localization.GetString("FeedBack", LocalResourceFile)%></a>
                            <a title="<%=Localization.GetString("ShareToolTip", LocalResourceFile)%>" class="link-action share" href="#share-container"><%=Localization.GetString("Share", LocalResourceFile)%></a>
                        </div>
                        <div class="actions-admin">
                            <asp:DropDownList runat="server" ID="ddTranslate" onchange="translateAll(this);" class="bttn bttn-m bttn-default" Width="125" Height="32" DataValueField="Key" DataTextField="Label">
                            </asp:DropDownList>
                            <%--<input id="btnTranslate" class="bttn bttn-m bttn-default" type="button" value="Translate" onclick="javascript: translateAll();" />--%>
                            <asp:Button CssClass="bttn bttn-m bttn-default" ID="btnRate" resourcekey="RateSolution" runat="server" Visible="False" OnClick="btnRate_Click" />
                            <asp:Button CssClass="bttn bttn-m bttn-default" ID="btnReportSpam" resourcekey="ReportSpam" runat="server" OnClick="btnReportSpam_Click" />
                            <%--<asp:Button CssClass="bttn bttn-m bttn-default" ID="btnUnpublish2" Visible="False" resourcekey="Unpublish" runat="server" OnClick="btnUnpublish_Click" />--%>
                            <asp:Button CssClass="bttn bttn-m bttn-default" ID="btnUnpublish" Visible="False" resourcekey="Unpublish" runat="server" OnClientClick="if ( ! Confirmation('Unpublish')) return false;" />
                            <asp:Button CssClass="bttn bttn-m bttn-alert" ID="btnDeleteSolution" Visible="False" resourcekey="DeleteSolution" runat="server" OnClientClick="if ( ! Confirmation('Delete')) return false;" />
                            <%--<asp:Button CssClass="bttn bttn-m bttn-alert" ID="btnDeleteSolution2" Visible="false" resourcekey="DeleteSolution" runat="server" OnClick="DeleteSolution_Click" OnClientClick="if ( ! DeleteConfirmation()) return false;" />--%>
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

                <div class="lead-block">
                    <asp:Label ID="lblTagLine" runat="server"></asp:Label>
                </div>

                <div class="content-block">

                    <h2>
                        <asp:Label ID="lblChallengeTitle" runat="server" resourcekey="Challenge"></asp:Label></h2>
                    <p>
                        <asp:Label ID="lblChallenge" runat="server"></asp:Label>
                    </p>
                </div>

                <div class="content-block">

                    <h2>
                        <asp:Label ID="LblApproachTitle" runat="server" resourcekey="Approach"></asp:Label></h2>
                    <p>
                        <asp:Label ID="lblApproach" runat="server"></asp:Label>
                    </p>
                </div>

                <div class="content-block">

                    <h2>
                        <asp:Label ID="lblResultsTitle" runat="server" resourcekey="Results"></asp:Label></h2>
                    <p>
                        <asp:Label ID="lblResults" runat="server"></asp:Label>
                    </p>
                </div>

                <div class="content-block">

                    <h2>
                        <asp:Label ID="lblImplementationDetailsTitle" runat="server" resourcekey="ImplementationDetails"></asp:Label></h2>
                    <p>
                        <asp:Label ID="lblImplementationDetails" runat="server"></asp:Label>
                    </p>
                </div>

                <div class="content-block">

                    <h2>
                        <asp:Label ID="lblCostDetailsTitle" runat="server" resourcekey="CostDetails"></asp:Label></h2>
                    <p>
                        <asp:Label ID="lblCostDetails" runat="server"></asp:Label>
                    </p>
                </div>

                <div class="content-block">

                    <h2>
                        <asp:Label ID="lblDurationDetailsTitle" runat="server" resourcekey="DurationDetails"></asp:Label></h2>
                    <p>
                        <asp:Label ID="lbldurationDetails" runat="server"></asp:Label>
                    </p>
                </div>

                <div class="content-block" runat="server" id="pnlLongDescription" visible="false">

                    <h2>
                        <asp:Label ID="lblDescriptionTitle" runat="server" resourcekey="Description"></asp:Label></h2>
                    <p>
                        <asp:Label ID="lblDescription" runat="server"></asp:Label>
                    </p>
                </div>

                <div id="videoPanel" runat="server" visible="false" class="additionalInformationPanel content-block">
                   <h2>   <asp:Label ID="Label6" runat="server" resourcekey="SolutionVideo"></asp:Label></h2>
                     <asp:Literal runat="server" ID="videoObject"></asp:Literal>
                    <br />
                    <br />
                </div>

                <div id="dvOtherInformationPanel" runat="server" class="additionalInformationPanel content-block">
                    <asp:Label ID="lblCustomInformation" runat="server" resourcekey="CustomInformation"></asp:Label>
                    <br />
                    <br />
                    
                    <asp:Literal runat="server" ID="lOtherInformation"></asp:Literal>
                </div>
            </div>

            <aside class="single-aside">

                <!-- overview -->
                <section class="aside-block overview">

                    <h1 class="aside-block-title">
                        <asp:Label ID="Label1" runat="server" resourcekey="Overview"></asp:Label></h1>
                    <dl class="details-list">
                        <div runat="server" id="dState" visible="false">
                            <dd class="fa fa-info-circle fa-lg state"></dd>
                            <dd>
                                <asp:Label ID="lblSolutionState" runat="server" Visible="False"></asp:Label></dd>
                        </div>
                        <dt>Themes</dt>

                        <dd class="themes">
                            <asp:Label ID="lblTheme" runat="server"></asp:Label></dd>
                        <dt>Target</dt>

                        <dd class="target">
                            <asp:Label ID="lblBeneficiary" runat="server"></asp:Label></dd>
                        <dt>Delivery format</dt>

                        <dd class="link">
                            <asp:Label ID="lblDeliveryFormat" runat="server"></asp:Label></dd>
                        <dt>Cost</dt>

                        <dd class="cost">
                            <asp:Label ID="lblCost" runat="server"> </asp:Label>&nbsp;<asp:Label ID="lblCostType" runat="server"></asp:Label></dd>
                        <dt>Duration</dt>

                        <dd class="calendar"> 
                            <asp:Label ID="lblDuration" runat="server"></asp:Label></dd>   
                        
                        <dd class="calendar">   
                            <asp:Label ID="lblPublishDate" runat="server" resourcekey="PublishDate"></asp:Label>
                            <asp:Label ID="txtPublishDate" runat="server"></asp:Label></dd>
                    </dl>
                </section>
                <!--/ overview -->

                <!-- geo -->
                <section class="aside-block geo">

                    <h1 class="aside-block-title">
                        <asp:Label ID="Label2" runat="server" resourcekey="Locations"></asp:Label></h1>
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
                        <asp:Label ID="Label4" runat="server" resourcekey="ProvidedBy"></asp:Label></h1>
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
                        <asp:Label ID="Label5" runat="server" resourcekey="PublishedBy"></asp:Label></h1>
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
                                    <asp:Label ID="lblSendMessage" runat="server" resourcekey="SendMessage"></asp:Label></a>


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
                                    <asp:Label ID="lblSendMessageTo" runat="server" resourcekey="SendMessageTo"></asp:Label><span class="alt" id="message-recipient">[FirstName LastName]</span></h1>
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
                                    <asp:Label ID="lblSendMessage2" runat="server" resourcekey="SendMessage"></asp:Label></button>
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
<div style="display: none;">
    <asp:Button ID="btnEdit" CausesValidation="false" runat="server" Text="Button" OnClick="btnUnpublish_Click" />
    <asp:Button ID="btnDelete" CausesValidation="false" runat="server" Text="Button" OnClick="DeleteSolution_Click" />
</div>
<asp:HiddenField ID="hfSolutionId" runat="server" />
<asp:HiddenField ID="hfLnguage" runat="server" />
<asp:HiddenField ID="hfTitle2" runat="server" />
<asp:HiddenField ID="hfTagLine2" runat="server" />
<asp:HiddenField ID="hfInstitutionName2" runat="server" />
<script src="<%=ControlPath%>js/jquery.alerts.js"></script>
<script src="<%=ControlPath%>js/NXSolutionV2.js"></script>
<link href="<%=ControlPath%>css/jquery.alerts.css" rel="stylesheet" />
<input id="hfOwnerSolutionId" type="hidden" value="<%=solutionComponent.Solution.CreatedUserId.GetValueOrDefault(-1).ToString()%>" />



