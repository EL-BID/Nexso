<%@ Control Language="C#" AutoEventWireup="true" CodeFile="NZJudgesChallenge.ascx.cs" Inherits="NZJudgesChallenge" %>
<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>

<style>
   
</style>
<div>
    <telerik:radajaxmanager id="RadAjaxManager1" runat="server">
        <AjaxSettings>
            <telerik:AjaxSetting AjaxControlID="panel1">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="grdManageJudge" LoadingPanelID="RadAjaxLoadingPanel1" />
                </UpdatedControls>
            </telerik:AjaxSetting>
        </AjaxSettings>
    </telerik:radajaxmanager>

    <asp:Panel runat="server" ID="panel1">
        <div id="dvManageJudge">
            <asp:HyperLink runat="server" ID="hlPdf" resourcekey="hlPdf" Target="_blank"></asp:HyperLink>
            <telerik:radgrid autogeneratecolumns="true" runat="server" id="grdManageJudge" skin="Silk" allowfiltering="true" filtercontrolwidth="80" allowfilteringbycolumn="True" onneeddatasource="RadGrid1_NeedDataSource"
                allowpaging="True" allowautomaticupdates="True" allowautomaticinserts="True" ondeletecommand="RadGrid1_DeleteCommand" onupdatecommand="RadGrid1_UpdateCommand"
                allowsorting="True" pagesize="60" onitemdatabound="RadGrid1_ItemDataBound">
            <GroupingSettings CaseSensitive="false" />
             <PagerStyle Mode="NextPrevAndNumeric" />

             <MasterTableView  AutoGenerateColumns="False"   DataKeyNames="ChallengeJudgeId" CommandItemDisplay="Top" AllowFilteringByColumn="True" >
                 <Columns>

                    <telerik:GridEditCommandColumn ButtonType="ImageButton" UniqueName="EditCommandColumn">
                    </telerik:GridEditCommandColumn>
                      <telerik:GridBoundColumn DataField="ChallengeJudgeId" SortExpression="ChallengeJudgeId" 
                        UniqueName="ChallengeJudgeId" Display="false" >
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="UserId" HeaderText="UserId" SortExpression="UserId" 
                        UniqueName="UserId" Display="false" >
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="FirstName" HeaderText="FirstName" SortExpression="FirstName"
                        UniqueName="FirstName">
                    </telerik:GridBoundColumn>                     
                    <telerik:GridBoundColumn DataField="Email" HeaderText="Email" SortExpression="Email"
                        UniqueName="Email">
                    </telerik:GridBoundColumn>
                     <telerik:GridBoundColumn DataField="PermisionLevel" HeaderText="Permision" SortExpression="PermisionLevel"
                        UniqueName="PermisionLevel">
                    </telerik:GridBoundColumn>
                    <telerik:GridTemplateColumn HeaderText="From Date" FilterListOptions="VaryByDataType" DataType="System.DateTime"
                        SortExpression="FromDate" UniqueName="FromDate" DataField="From Date">
                        <ItemTemplate>
                            <%#DataBinder.Eval(Container.DataItem, "FromDate")%>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>
                    <telerik:GridTemplateColumn HeaderText="To Date" FilterListOptions="VaryByDataType" DataType="System.DateTime"
                        SortExpression="ToDate" UniqueName="ToDate" DataField="ToDate">
                        <ItemTemplate>
                            <%#DataBinder.Eval(Container.DataItem, "ToDate")%>
                        </ItemTemplate>
                    </telerik:GridTemplateColumn>

                     <telerik:GridTemplateColumn HeaderText="Assigned solutions" SortExpression="AssignedSolutions" UniqueName="AssignedSolutions" DataField="AssignedSolutions" Visible="false">
                        <ItemTemplate>
                            <%#DataBinder.Eval(Container.DataItem, "AssignedSolutions")%>
                           
                        </ItemTemplate>
                      </telerik:GridTemplateColumn>


                    <telerik:GridButtonColumn ConfirmText="Delete this item?" ButtonType="ImageButton"
                        CommandName="Delete" Text="Delete" UniqueName="DeleteColumn">
                        <HeaderStyle Width="33px"></HeaderStyle>
                    </telerik:GridButtonColumn>
                   
                 </Columns>
                 
                 <EditFormSettings EditFormType="Template">

                      <EditColumn UniqueName="EditColumn"></EditColumn>
                      <FormTemplate>
                          <div>
                             <table style="width:100%;padding-top: 20px;">
                                <tr>
                                  <td style="width:35%;">
                                    <div class="dvContent">
                                        <asp:TextBox ID="txtChallengeJudgeId" Text='<%# Bind("ChallengeJudgeId") %>' runat="server" Visible="false"></asp:TextBox>
                                        <div>  
                                            <asp:Label runat="server" ID="lblEmail" resourcekey="lblEmail"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadComboBox ID="rdEmail" width="100%" runat="server" skin="Silk" DataTextField="email" EnableLoadOnDemand="true" MarkFirstMatch="true" DataValueField="UserId" SortCaseSensitive="false" AllowCustomText="true">
                                            </telerik:RadComboBox>
                                            <asp:TextBox runat="server" ID="txtEmail" Visible="false"></asp:TextBox>
                                        </div>
                                        <div class="rfv">
                                            <asp:RequiredFieldValidator ID="rfvrdEmail" runat="server" ValidationGroup="addJudge" ControlToValidate="rdEmail" resourcekey="rfvrdEmail"></asp:RequiredFieldValidator>
                                        </div>
                                        <div>
                                            <asp:Label runat="server" ID="lblPermision" resourcekey="lblPermision"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadComboBox ID="rdPermisionLevel" width="100%" runat="server" skin="Silk" DataTextField="Label" EnableLoadOnDemand="true" MarkFirstMatch="true" DataValueField="Key" SortCaseSensitive="false" AllowCustomText="true">
                                            </telerik:RadComboBox>
                                        </div>
                                        <div class="rfv">
                                            <asp:RequiredFieldValidator ID="rfvrdPermisionLevel" runat="server" ValidationGroup="addJudge" ControlToValidate="rdPermisionLevel" resourcekey="rfvrdPermisionLevel"></asp:RequiredFieldValidator>
                                        </div>
                                        <div>
                                            <asp:Label runat="server" ID="lblFromDate" resourcekey="lblFromDate"></asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadDatePicker width="100%" runat="server" skin="Silk" id="dtFromDate">
                                            </telerik:RadDatePicker>
                                        </div>
                                        <div class="rfv">
                                            <asp:RequiredFieldValidator ID="rfvdtFromDate" runat="server" ValidationGroup="addJudge" ControlToValidate="dtFromDate" resourcekey="rfvdtFromDate"></asp:RequiredFieldValidator>
                                        </div>
                                        <div>
                                            <asp:Label runat="server" ID="lblToDate" resourcekey="lblToDate"> </asp:Label>
                                        </div>
                                        <div>
                                            <telerik:RadDatePicker width="100%" runat="server" skin="Silk" id="dtToDate">
                                            </telerik:RadDatePicker>
                                        </div>
                                        <div class="rfv">
                                            <asp:RequiredFieldValidator ID="rfvdtToDate" runat="server" ValidationGroup="addJudge" ControlToValidate="dtToDate" resourcekey="rfvdtToDate"></asp:RequiredFieldValidator>
                                         </div>
                                     </div>
                                  </td>
                                  <td style="width:65%;" valign="top">

                                      <div class="titleSolutions">
                                       <h3><asp:Label runat="server" ID="lblHeaderName" resourcekey="lblHeaderSolutions"></asp:Label></h3>
                                      </div>
                                      <div class="dvSolutions" id="dvSolutions">
                                           <asp:CheckBoxList ID="cblSolutions" CssClass="ckbSolutions" runat="server" DataValueField="Id" DataTextField="Text"></asp:CheckBoxList>
                                      </div>
                                     
                                  </td>
                                </tr>
                            </table>
                             <div class="divbtn" style="padding-bottom: 35px!important;">
                                <asp:Button ID="btnCancel" runat="server" resourcekey="btnCancel" CssClass="bttn bttn-m bttn-alert" CommandName="Cancel" ValidationGroup="addJudgeCancel" />
                                <asp:Button runat="server" CssClass="bttn bttn-m bttn-secondary btnS" resourcekey="btnAdd" CommandName="Update" ID="btnAddJudge" ValidationGroup="addJudge" autopostback="true" />
                             </div>
                              </div>
                      </FormTemplate>
                    </EditFormSettings>
              </MasterTableView>
        </telerik:radgrid>
            <asp:HiddenField runat="server" ID="hfSolutionsSel" />
        </div>
    </asp:Panel>
    <telerik:radajaxloadingpanel id="RadAjaxLoadingPanel1" runat="server" skin="Default"></telerik:radajaxloadingpanel>
    <div id="dvBtn">
        <asp:Button ID="btnExport" OnClick="btnExport_Click" runat="server" Text="Export" AutoPostBack="true" class="bttn bttn-m bttn-default" />
    </div>
</div>

<link href="<%=ControlPath%>css/module.css" rel="stylesheet" />
