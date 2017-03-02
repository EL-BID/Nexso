<%@ Control Language="C#" AutoEventWireup="true" CodeFile="NZReportMailer.ascx.cs" Inherits="NZReportMailer" %>
<link href="<%=ControlPath%>css/module.css" rel="stylesheet" />
<asp:Label ID="lblMessage" runat="server" Visible="false" resourcekey="lblMessage"></asp:Label>
<asp:Repeater runat="server" ID="rpReport">
    <ItemTemplate>
        <div id="dvContent">
            <table class="table1">
                <tr class="title">
                    <td>
                        <asp:Label ID="lblCreated" runat="server" resourcekey="lblCreated"></asp:Label></td>
                    <td>
                        <asp:Label ID="lblSentMails" runat="server" resourcekey="lblSentMails"></asp:Label></td>
                    <td>
                        <asp:Label ID="lblErrors" runat="server" resourcekey="lblErrors"></asp:Label></td>
                    <td>
                        <asp:Label ID="lblBouncedMail" runat="server" resourcekey="lblBouncedMail"></asp:Label></td>
                    <td>
                        <asp:Label ID="lblViewMails" runat="server" resourcekey="lblViewMails"></asp:Label></td>
                    <td>
                        <asp:Label ID="lblPendingViews" runat="server" resourcekey="lblPendingViews"></asp:Label></td>
                    <td>
                        <asp:Label ID="lblEffectiveness" runat="server" resourcekey="lblEffectiveness"></asp:Label></td>
                </tr>
                <tr class="data text">
                    <td>
                        <asp:Label ID="lblCreatedData" runat="server" Text='<%#Eval("Created")%>'></asp:Label></td>
                    <td>
                        <asp:Label ID="lblSentMailsData" runat="server" Text='<%#Eval("SentMails")%>'></asp:Label></td>
                    <td>
                        <asp:Label ID="lblErrorsData" runat="server" Text='<%#Eval("Errors")%>'></asp:Label></td>
                    <td>
                        <asp:Label ID="lblBouncedMailData" runat="server" Text='<%#Eval("BouncedMail")%>'></asp:Label></td>
                    <td>
                        <asp:Label ID="lblViewMailsData" runat="server" Text='<%#Eval("ViewMails")%>'></asp:Label></td>
                    <td>
                        <asp:Label ID="lblPendingViewsData" runat="server" Text='<%#Eval("PendingViews")%>'></asp:Label></td>
                    <td>
                        <asp:Label ID="lblEffectivenessData" runat="server" Text='<%#Eval("Effectiveness")%>'></asp:Label></td>
                </tr>
            </table>
            <table class="table2">
                <tr class="data font">
                    <td>
                        <asp:Label ID="lblViewGeographic" runat="server" resourcekey="lblGeographicView"></asp:Label></td>
                </tr>
                <tr class='<%# Eval("ViewGeographic") != null ? "hide": "" %>'>
                    <td class="data">
                        <asp:Label ID="lblViewGeographicMessage" runat="server" resourcekey="lblViewGeographicMessage" Visible='<%#Eval("ViewGeographic") == null%>'></asp:Label>
                    </td>
                </tr>
                <asp:Repeater runat="server" ID="ViewGeographic" DataSource='<%# Eval("ViewGeographic") %>' Visible='<%#Eval("ViewGeographic") != null%>'>
                    <ItemTemplate>
                        <tr>
                            <td class="dataCountry">
                                <asp:Label ID="lblCountryData" runat="server" Text='<%#Eval("Country") +" : " + Eval("ViewsPercentage") + "% - Total " + Eval("TotalViews")  %>'></asp:Label>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>

                <tr>
                    <td>
                        <div class="footer">
                            <img src="<%= "/DesktopModules/Nexso/NZReportMailer/images/bg_shadow.png"%>"/>
                        </div>
                    </td>
                </tr>
            </table>
        </div>
    </ItemTemplate>
</asp:Repeater>