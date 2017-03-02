<%@ Control Language="C#" AutoEventWireup="true" CodeFile="NXSolutionExpressView.ascx.cs"
    Inherits="NXSolutionExpressView" %>
<%@ Register Src="LocationList.ascx" TagName="LocationList" TagPrefix="uc1" %>
<div id="mainPanel" runat="server">
    <div class="cell">
        <asp:Image ID="imgOrganizationLogo" runat="server" /></div>
    <div class="cell">
        <h1>
            <asp:HyperLink ID="lnkSolutionName" runat="server"></asp:HyperLink>
        </h1>
    </div>
    <div class="cell">
        <p>
            <asp:HyperLink ID="lnkInstitutionName" runat="server"></asp:HyperLink>
        </p>
    </div>
    <div>
        <asp:Label ID="lblSolutionshortDescription" runat="server"></asp:Label>
    </div>
    <div class="table">
        <div class="row">
            <div class="cell">
                <asp:Image ID="imgThemeIcon" runat="server" Width="16px" />
            </div>
            <div class="cell">
                <asp:Label ID="lblTheme" runat="server"></asp:Label>
            </div>
        </div>
        <div class="row">
            <div class="cell">
                <asp:Image ID="imgBeneficiariesIcon" runat="server" Width="16px" />
            </div>
            <div class="cell">
                <asp:Label ID="lblBeneficiaries" runat="server"></asp:Label>
            </div>
        </div>
    </div>
    <div class="table">
        <div class="row">
            <div class="cell">
                <h1>
                    <asp:Label ID="lblFormat" runat="server"></asp:Label></h1>
                <p>
                    <asp:Label ID="lblFormatTitle" runat="server" resourcekey="Format"></asp:Label></p>
            </div>
        </div>
        <div class="row">
            <div class="cell">
                <h1>
                    <asp:Label ID="lblduration" runat="server"></asp:Label></h1>
                <p>
                    <asp:Label ID="lblDurationTitle" runat="server" resourcekey="ToComplete"></asp:Label></p>
            </div>
        </div>
        <div class="row">
            <div class="cell">
                <h1>
                    <asp:Label ID="lblCost" runat="server"></asp:Label></h1>
                <p>
                    <asp:Label ID="lblCostConcept" runat="server"></asp:Label></p>
            </div>
        </div>
    </div>
    <hr />
    <h1>
        <asp:Label ID="lblImplementationTitle" runat="server" resourcekey="ImplementationLocation"></asp:Label></h1>
    <div class="table">
        <div class="row">
            <div class="cell">
                <uc1:LocationList ID="LocationList1" runat="server" />
            </div>
        </div>
    </div>
    <div>
        <asp:Button ID="btnView" runat="server" resourcekey="View" OnClick="btnView_Click1" />
    </div>
</div>
<div id="EmptyPanel" runat="server">
    <asp:Label ID="lblEmptyMessage" resourcekey="EmptyMessage"></asp:Label>
</div>
