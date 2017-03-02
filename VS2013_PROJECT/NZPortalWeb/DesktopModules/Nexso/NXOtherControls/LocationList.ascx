<%@ Control Language="C#" AutoEventWireup="true" CodeFile="LocationList.ascx.cs"
    Inherits="controls_LocationList" %>
<%@ Import Namespace="MIFWebServices" %>
<%@ Register Src="CountryStateCity.ascx" TagName="CountryStateCity" TagPrefix="uc1" %>
<asp:UpdatePanel ID="UpdatePanel1" runat="server">
    <ContentTemplate>
        <div id="selectPanel" runat="server" visible="true" class="table" style="width: 100%;">
            
            <div   style="width:300px; display:inline-block;">
                <uc1:CountryStateCity ID="CountryStateCity1" runat="server" EnableValidation="False" />
            </div>
            <div style="display:inline-block;">
                <asp:Button ID="btnAddToList" runat="server" ValidationGroup="LocationControl" Text=""
                    OnClick="btnAddToList_Click" />
            </div>
       </div>
        <asp:GridView CssClass="table-striped table-styled" AutoGenerateColumns="false" BorderWidth="0"  ID="locationRepeater" runat="server" OnItemCommand="locationRepeater_ItemCommand"
            OnItemDataBound="locationRepeater_ItemDataBound" OnDataBound="locationRepeater_RowDataBound"
            OnRowCommand="locationRepeater_RowCommand" OnRowDataBound="locationRepeater_RowDataBound1"
            OnRowDeleting="locationRepeater_RowDeleting">
            
            <Columns>
                <asp:TemplateField>
                    <HeaderTemplate>
                    </HeaderTemplate>
                    <ItemTemplate>
                        
                        <asp:Image ID="Image1" runat="server" ImageUrl='<%#Request.Url.AbsoluteUri.Replace(Request.Url.PathAndQuery, "") + ControlPath + "images/location.png"%>'
                            Width="16px" />
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
            
            <Columns>
                <asp:TemplateField>
                    <HeaderTemplate>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <%#LocationService.GetCountryName(Eval("Country").ToString())%>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
            <Columns>
                <asp:TemplateField>
                    <HeaderTemplate>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <asp:LinkButton CausesValidation="False" ID="btnDelete" runat="server" CommandName="DELETE"
                             >&#10005;</asp:LinkButton>
                        <%-- <asp:LinkButton CausesValidation="False" ID="btnDelete" runat="server" CommandName="DELETE" resourcekey="Delete"></asp:LinkButton>--%>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </ContentTemplate>
</asp:UpdatePanel>
