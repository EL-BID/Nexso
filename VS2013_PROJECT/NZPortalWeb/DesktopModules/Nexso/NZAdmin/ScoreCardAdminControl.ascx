<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ScoreCardAdminControl.ascx.cs"
    Inherits="ScoreCardAdminControl" %>
<%@ Import Namespace="NexsoProBLL" %>
<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>


<h1>User List</h1>

<telerik:RadGrid runat="server" ID="grdRecentSolution" AllowFiltering="true" FilterControlWidth="80" AllowFilteringByColumn="True" OnNeedDataSource="RadGrid1_NeedDataSource"
    AllowPaging="True" AllowSorting="True" PageSize="60" AutoGenerateColumns="false" OnSortCommand="grdRecentSolution_SortCommand" AllowAutomaticUpdates="True" Skin="MetroTouch">
    <GroupingSettings CaseSensitive="false" />
    <PagerStyle Mode="NextPrevAndNumeric" />
    <MasterTableView DataKeyNames="SolutionID" CommandItemDisplay="top">
        <CommandItemSettings ShowAddNewRecordButton="false" />
        <Columns>
            <telerik:GridTemplateColumn HeaderText="Solution Title" UniqueName="Title" SortExpression="Title" DataField="Title">
                <ItemTemplate>
                    <asp:HyperLink ID="HyperLink3" runat="server" NavigateUrl='<%#NexsoHelper.GetCulturedUrlByTabName("solprofilescore")+ "/sl/"+Eval("SolutionID") %>'>
                                       
                               <%#DataBinder.Eval(Container.DataItem, "Title")%>
                    </asp:HyperLink>
                </ItemTemplate>
            </telerik:GridTemplateColumn>
            <telerik:GridBoundColumn DataField="Language" HeaderText="Language" SortExpression="Language"
                UniqueName="Language">
            </telerik:GridBoundColumn>
            <telerik:GridBoundColumn DataField="DateUpdated" HeaderText="Las Update" SortExpression="DateUpdated"
                UniqueName="DateUpdated">
            </telerik:GridBoundColumn>
            <telerik:GridTemplateColumn HeaderText="Scores" AllowFiltering="false">
                <ItemTemplate>
                    <%#GetScore(DataBinder.Eval(Container.DataItem, "Scores"))%>
                </ItemTemplate>
            </telerik:GridTemplateColumn>
        </Columns>
    </MasterTableView>
</telerik:RadGrid>
