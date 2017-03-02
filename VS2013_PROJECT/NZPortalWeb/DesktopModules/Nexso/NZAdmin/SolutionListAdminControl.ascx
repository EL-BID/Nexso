<%@ Control Language="C#" AutoEventWireup="true" CodeFile="SolutionListAdminControl.ascx.cs" Inherits="SolutionListAdminControl" %>
<%@ Import Namespace="NexsoProBLL" %>
<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>

<link href="<%=ControlPath%>css/module.css" rel="stylesheet" />

<telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" UpdateInitiatorPanelsOnly="true">
    <ClientEvents OnRequestStart="onRequestStart"></ClientEvents>
    <AjaxSettings>
        <telerik:AjaxSetting AjaxControlID="pnlReportS">
            <UpdatedControls>
                <telerik:AjaxUpdatedControl ControlID="grdRecentSolution" LoadingPanelID="RadAjaxLoadingPanel1" />
            </UpdatedControls>
        </telerik:AjaxSetting>
    </AjaxSettings>
</telerik:RadAjaxManager>
<telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Default" />


<asp:Panel runat="server" ID="pnlReportS">
    <div id="dvReport">
        <asp:CheckBox runat="server" ID="ckbScoreMode" Text="generate Url on score mode" AutoPostBack="true" OnCheckedChanged="ckbScoreMode_CheckedChanged" />

        <telerik:RadGrid runat="server" ID="grdRecentSolution" AllowFiltering="true" FilterControlWidth="80" AllowFilteringByColumn="True" OnNeedDataSource="RadGrid1_NeedDataSource" OnPreRender="grdRecentSolution_PreRender" 
              AllowPaging="True" AllowSorting="True" PageSize="60" AutoGenerateColumns="false" OnSortCommand="grdRecentSolution_SortCommand" AllowAutomaticUpdates="True">
            <GroupingSettings CaseSensitive="false" />
            <PagerStyle Mode="NextPrevAndNumeric" />
            <HeaderStyle Font-Size="10" />
            <ItemStyle VerticalAlign="Middle" Font-Size="10px" />
            <ExportSettings HideStructureColumns="true">
            </ExportSettings>
            <MasterTableView CommandItemDisplay="top" Font-Size="10px">
                <CommandItemSettings ShowAddNewRecordButton="false" />
                <Columns>
                    <telerik:GridTemplateColumn HeaderText="Row" AllowFiltering="false" UniqueName="Row">
                        <HeaderStyle Width="20px" />
                        <ItemStyle VerticalAlign="Middle" Width="20px" />
                        <ItemTemplate>
                            <%#DataBinder.Eval(Container.DataItem, "Row")%>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridTemplateColumn HeaderText="Url" AllowFiltering="false" DataField="SolutionIDScore" UniqueName="SolutionIDScore" Visible="false">
                        <ItemTemplate>
                            <%#NexsoHelper.GetCulturedUrlByTabName("solprofilescore")+ "/sl/"+Eval("SolutionId")%>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridTemplateColumn HeaderText="Url" AllowFiltering="false" DataField="SolutionID" UniqueName="SolutionID" Visible="false">
                        <ItemTemplate>
                            <%#NexsoHelper.GetCulturedUrlByTabName("solprofile")+ "/sl/"+Eval("SolutionId")%>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridTemplateColumn HeaderText="Title" AllowFiltering="false" DataField="SolutionTitle2" UniqueName="SolutionTitle2" Visible="false">
                        <ItemTemplate>
                            <%#DataBinder.Eval(Container.DataItem, "SolutionTitle")%>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridTemplateColumn HeaderText="Organization" AllowFiltering="false" DataField="OrganizationName2" UniqueName="OrganizationName2" Visible="false">
                        <ItemTemplate>
                            <%#DataBinder.Eval(Container.DataItem,"OrganizationName")%>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridTemplateColumn HeaderText="Title" UniqueName="SolutionTitleScore" SortExpression="SolutionTitle" DataField="SolutionTitle">
                        <ItemTemplate>
                            <asp:HyperLink ID="HyperLink3" runat="server" NavigateUrl='<%#UrlEscore(Eval("SolutionID").ToString(), Convert.ToInt32(Eval("SolutionState")))%>'>
                                       
                               <%#DataBinder.Eval(Container.DataItem, "SolutionTitle")%>
                            </asp:HyperLink>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridTemplateColumn HeaderText="Title" SortExpression="SolutionTitle" UniqueName="SolutionTitle" DataField="SolutionTitle">
                        <ItemTemplate>
                            <asp:HyperLink ID="HyperLink2" Target="_blank" runat="server" NavigateUrl='<%#NexsoHelper.GetCulturedUrlByTabName("solprofile")+ "/sl/"+Eval("SolutionID")%>'>
                                       
                          <%#DataBinder.Eval(Container.DataItem, "SolutionTitle")%>
                            </asp:HyperLink>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridTemplateColumn UniqueName="OrganizationName" HeaderText="Organization"
                        DataField="OrganizationName" SortExpression="OrganizationName">
                        <ItemTemplate>
                            <asp:HyperLink ID="HyperLink4" Target="_blank" runat="server" NavigateUrl='<%#NexsoHelper.GetCulturedUrlByTabName("insprofile") +"/in/"+ Eval("OrganizationID")%>'>
                        <%#DataBinder.Eval(Container.DataItem,"OrganizationName")%>
                            </asp:HyperLink>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridTemplateColumn HeaderText="EntryUser"
                        SortExpression="UserName" DataField="UserName"
                        UniqueName="UserName">
                        <ItemTemplate>
                            <%#DataBinder.Eval(Container.DataItem, "UserName") %>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridTemplateColumn HeaderText="Email"
                        SortExpression="UserEmail" UniqueName="UserEmail" DataField="UserEmail">
                        <ItemStyle Font-Size="9px"></ItemStyle>
                        <ItemTemplate>
                            <%#DataBinder.Eval(Container.DataItem, "UserEmail")%>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridTemplateColumn HeaderText="Date Created" FilterListOptions="VaryByDataType" DataType="System.DateTime"
                        SortExpression="SolutionDateCreated" UniqueName="SolutionDateCreated" DataField="SolutionDateCreated">
                        <ItemTemplate>
                            <%#DataBinder.Eval(Container.DataItem, "SolutionDateCreated")%>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridTemplateColumn HeaderText="Date Updated" FilterListOptions="VaryByDataType" DataType="System.DateTime"
                        SortExpression="SolutionDateUpdated" UniqueName="SolutionDateUpdated" DataField="SolutionDateUpdated">
                        <ItemTemplate>
                            <%#DataBinder.Eval(Container.DataItem, "SolutionDateUpdated")%>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridTemplateColumn DataField="OrganizationCountry" HeaderText="Location" UniqueName="OrganizationCountry" SortExpression="OrganizationCountry">
                        <FilterTemplate>
                            <telerik:RadComboBox ID="rdCountry" runat="server" DataTextField="country" Skin="Metro" CssClass="radInput" EnableLoadOnDemand="true" MarkFirstMatch="true" SelectedValue='<%# ((GridItem)Container).OwnerTableView.GetColumn("OrganizationCountry").CurrentFilterValue %>'
                                DataValueField="code" SortCaseSensitive="false" AllowCustomText="true" DataSource='<%# BindCountry() %>' OnClientSelectedIndexChanged="CountryIndexChanged">
                            </telerik:RadComboBox>

                            <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
                                <script type="text/javascript">
                                    function CountryIndexChanged(sender, args) {
                                        var tableView = $find("<%# ((GridItem)Container).OwnerTableView.ClientID %>");
                                        if (args.get_item().get_value() != "%NULL%") {
                                            if (args.get_item().get_value() != "") {
                                                tableView.filter("OrganizationCountry", args.get_item().get_value(), "EqualTo");
                                            } else {
                                                tableView.filter("OrganizationCountry", args.get_item().get_value(), "IsEmpty");
                                            }
                                        } else {
                                            tableView.filter("OrganizationCountry", args.get_item().get_value(), "NoFilter");
                                        }
                                    }
                                </script>
                            </telerik:RadScriptBlock>

                        </FilterTemplate>

                        <ItemTemplate>
                            <asp:Label ID="lblLocation" runat="server" Text=' <%#GetNexsoLocation((string)DataBinder.Eval(Container.DataItem,"OrganizationCountry"),(string)DataBinder.Eval(Container.DataItem,"OrganizationRegion"), (string)DataBinder.Eval(Container.DataItem, "OrganizationCity"))%>' />
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridTemplateColumn HeaderText="Challenge Reference"
                        SortExpression="Solution.ChallengeReference" UniqueName="Solution.ChallengeReference" DataField="SolutionChallengeReference">
                        <ItemTemplate>
                            <%#DataBinder.Eval(Container.DataItem, "SolutionChallengeReference")%>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridTemplateColumn DataField="SolutionState" HeaderText="Status" UniqueName="SolutionState" SortExpression="SolutionState" AllowFiltering="true"
                        DataType="System.Decimal" Aggregate="Custom">
                        <FilterTemplate>
                            <telerik:RadComboBox ID="rdStatus" runat="server" Width="100" Skin="Metro" DataTextField="status" CssClass="radInput" EnableLoadOnDemand="true" MarkFirstMatch="true" SelectedValue='<%# GetValueSolutionState(((GridItem)Container).OwnerTableView.GetColumn("SolutionState").CurrentFilterValue )%>'
                                DataValueField="code" SortCaseSensitive="false" AllowCustomText="true" DataSource='<%# BindStatus() %>' OnClientSelectedIndexChanged="StatusIndexChanged">
                            </telerik:RadComboBox>

                            <telerik:RadScriptBlock ID="RadScriptBlock2" runat="server">
                                <script type="text/javascript">
                                    function StatusIndexChanged(sender, args) {
                                        var tableView = $find("<%# ((GridItem)Container).OwnerTableView.ClientID %>");

                                        if (args.get_item().get_value() == -1) {

                                            tableView.filter("SolutionState", args.get_item().get_value(), "NoFilter");

                                        } else {

                                            var startValue = args.get_item().get_value();
                                            var endValue = 799;
                                            if (startValue == 800) {
                                                endValue = 1000;
                                            }

                                            tableView.filter("SolutionState", startValue + " " + endValue, "Between");

                                        }
                                    }
                                </script>
                            </telerik:RadScriptBlock>
                        </FilterTemplate>
                        <ItemTemplate>
                            <%#GetStatus(Convert.ToInt32(DataBinder.Eval(Container.DataItem,"SolutionState")))%>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridBoundColumn DataField="SolutionLanguage" HeaderText="Language" SortExpression="SolutionLanguage"
                        UniqueName="SolutionLanguage">
                        <ItemStyle VerticalAlign="Middle" Width="100px" />
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="SolutionScoreAcumulate" HeaderText="Score" SortExpression="SolutionScoreAcumulate"
                        UniqueName="SolutionScoreAcumulate" DataType="System.Int32">
                    </telerik:GridBoundColumn>
                    <telerik:GridTemplateColumn HeaderText="Judges Scores" AllowFiltering="true" SortExpression="SolutionScores"
                        DataField="SolutionScores" UniqueName="SolutionScores">
                        <ItemTemplate>
                            <%#DataBinder.Eval(Container.DataItem, "SolutionScores")%>
                        </ItemTemplate>
                        <ItemStyle Width="150" />
                    </telerik:GridTemplateColumn>


                </Columns>
            </MasterTableView>
        </telerik:RadGrid>
    </div>
</asp:Panel>
<div id="dvBtn">
    <asp:Button ID="btnExport" OnClick="btnExport_Click" runat="server" Text="Export" AutoPostBack="true" />

</div>
