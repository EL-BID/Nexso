<%@ Control Language="C#" AutoEventWireup="true" CodeFile="CountryStateCity.ascx.cs"
    Inherits="controls_CountryStateCity" %>
<asp:UpdatePanel ID="UpdatePanel1" runat="server">
    <ContentTemplate>
        <asp:HiddenField ID="hfCountry" runat="server" />
        <asp:HiddenField ID="hfRegion" runat="server" />
        <asp:HiddenField ID="hfCity" runat="server" />
        <div runat="server" id="pnlEdit" visible="False">
            <div class="table">
                <div class="cell">
                    <asp:Label ID="lblCountryCaption" runat="server"
                        resourcekey="CountryC" AssociatedControlID="ddCountry"></asp:Label>
                    <asp:DropDownList ID="ddCountry"  runat="server" DataTextField="country"
                        DataValueField="code" AutoPostBack="True" OnSelectedIndexChanged="ddCountry_SelectedIndexChanged">
                    </asp:DropDownList>
                     <asp:RequiredFieldValidator class="rfv" ID="rfvddCountry" runat="server"
                                            ControlToValidate="ddCountry" Enabled="True"   resourcekey="rfvddCountry" InitialValue="0"></asp:RequiredFieldValidator>
                </div>
            </div>
            <div class="table">
                <div class="cell">
                    <asp:Label ID="lblStateRegionCaption"  runat="server"
                        resourcekey="StateRegionC" AssociatedControlID="ddRegion"></asp:Label>
                    <asp:DropDownList ID="ddRegion"  runat="server" DataTextField="state"
                        DataValueField="code" AutoPostBack="True" OnSelectedIndexChanged="ddRegion_SelectedIndexChanged">
                    </asp:DropDownList>
                </div>
            </div>
            <div class="table">
                <div class="cell">
                    <asp:Label ID="lblCityCaption"  runat="server" resourcekey="CityC"
                        AssociatedControlID="ddCities"></asp:Label>
                    <asp:DropDownList ID="ddCities" CssClass="input-xlarge" runat="server" DataTextField="city"
                        DataValueField="code" OnSelectedIndexChanged="ddCities_SelectedIndexChanged"
                        AutoPostBack="True">
                    </asp:DropDownList>
                   
                </div>
            </div>
            
             <div class="table">
                <div class="cell">
                 <div id="dvCity" runat="server" visible="False">
                        <br />
                        <asp:Label ID="lblTextCity"  runat="server" resourcekey="AddOtherCity"
                            AssociatedControlID="txtCityDd"></asp:Label>
                        <asp:TextBox ID="txtCityDd" runat="server" BorderColor="#000000" 
                            Enabled="true" BorderStyle="Solid" BorderWidth="1px"></asp:TextBox>
                    </div>
                    </div>
                </div>
        </div>
        <div runat="server" id="pnlShow" visible="True">
            <div class="table">
                <div class="cell">
                    <asp:Label ID="Label3" runat="server" resourcekey="CityC"
                        AssociatedControlID="lblRegion"></asp:Label>
                    <asp:TextBox ID="lblCity" runat="server"  Enabled="false"
                        Visible="False"></asp:TextBox>
                    <asp:Label ID="lblCity2" CssClass="tblue" runat="server" Visible="False"></asp:Label>
                </div>
            </div>
            <div class="table">
                <div class="cell">
                    <asp:Label ID="Label2"  runat="server" resourcekey="StateRegionC"
                        AssociatedControlID="lblRegion"></asp:Label>
                    <asp:TextBox ID="lblRegion" runat="server"  Enabled="false"
                        Visible="False"></asp:TextBox>
                    <asp:Label ID="lblRegion2" CssClass="tblue" runat="server" Visible="False"></asp:Label>
                </div>
            </div>
            <div class="table">
                <div class="cell">
                    <asp:Label ID="Label1"  runat="server" resourcekey="CountryC"
                        AssociatedControlID="lblCountry"></asp:Label>
                    <asp:TextBox ID="lblCountry" runat="server"  Enabled="false"
                        Visible="False"></asp:TextBox>
                    <asp:Label ID="lblCountry2" CssClass="tblue" runat="server" Visible="False"></asp:Label>
                </div>
            </div>
        </div>
    </ContentTemplate>
</asp:UpdatePanel>
