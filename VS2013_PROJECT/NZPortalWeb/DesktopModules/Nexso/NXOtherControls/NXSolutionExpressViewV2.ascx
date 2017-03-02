<%@ Control Language="C#" AutoEventWireup="true" CodeFile="NXSolutionExpressViewV2.ascx.cs"
    Inherits="NXSolutionExpressViewV2" %>
<%@ Register Src="LocationList.ascx" TagName="LocationList" TagPrefix="uc1" %>
<div id="mainPanel" class="results_details" runat="server">
    <div class="logo">
        <asp:Image ID="imgOrganizationLogo" runat="server" />
        <asp:Button ID="btnView" runat="server" resourcekey="View" OnClick="btnView_Click1" />
    </div>
    <div class="title_wrapper">
        <h1>
            <asp:HyperLink ID="lnkSolutionName" runat="server"></asp:HyperLink>
        </h1>
        <h3>
            <asp:HyperLink ID="lnkInstitutionName" runat="server"></asp:HyperLink>
        </h3>
    </div>
    <div>
        <asp:Label ID="lblSolutionshortDescription" runat="server"></asp:Label>
    </div>
  
    <div class="metadata theme clearfix">
        <div class="iconwrapper">
            <i class="icon-tags"></i>
        </div>
        <div class="details">
            <h3 class="title"><asp:Label ID="lblDetailsTitle" runat="server" resourcekey="lblDetailsTitle"></asp:Label></h3>
            <asp:Label ID="lblTheme" runat="server"></asp:Label>
        </div>
    </div>
    <div class="metadata beneficiary clearfix">
        <div class="iconwrapper">
            <i class="icon-user"></i>
        </div>
        <div class="details">
            <h3 class="title"><asp:Label ID="lblBeneficiariesTitle" runat="server" resourcekey="lblBeneficiariesTitle"></asp:Label></h3>
            <asp:Label ID="lblBeneficiaries" runat="server"></asp:Label>
        </div>
    </div>
    <div class="metadata format clearfix">
        <div class="iconwrapper">
            <i class="icon-archive"></i>
        </div>
        <div class="details">
            <h3 class="title"><asp:Label ID="lblFormatTitle" runat="server" resourcekey="lblFormatTitle"></asp:Label></h3>
            <asp:Label ID="lblFormat" runat="server"></asp:Label>
        </div>
    </div>
    <div class="metadata duration clearfix">
        <div class="iconwrapper">
            <i class="geomicon ss-clock"></i>
        </div>
        <div class="details">
            <h3 class="title"><asp:Label ID="lblDurationTitle" runat="server" resourcekey="lblDurationTitle"></asp:Label></h3>
            <asp:Label ID="lblduration" runat="server"></asp:Label>
        </div>
    </div>
    <div class="metadata cost clearfix">
        <div class="iconwrapper">
            <i class="icon-money"></i>
        </div>
        <div class="details">
            <h3 class="title"><asp:Label ID="lblCostTitle" runat="server" resourcekey="lblCostTitle"></asp:Label></h3>
            <asp:Label ID="lblCost" runat="server"></asp:Label>
        </div>
    </div>
    <div class="metadata location clearfix">
        <div class="iconwrapper">
            <i class="icon-map-marker"></i>
        </div>
        <div class="details">
            <h3 class="title"><asp:Label ID="lblImplementationTitle" runat="server" resourcekey="lblImplementationTitle"></asp:Label></h3>
            <uc1:LocationList ID="LocationList1" runat="server" />
        </div>
    </div>
</div>

<div id="EmptyPanel" runat="server">
    <asp:Label ID="lblEmptyMessage" runat="server" resourcekey="EmptyMessage"></asp:Label>
</div>