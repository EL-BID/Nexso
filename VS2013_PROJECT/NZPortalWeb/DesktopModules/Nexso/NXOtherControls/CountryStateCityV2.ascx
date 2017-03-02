<%@ Control Language="C#" AutoEventWireup="true" CodeFile="CountryStateCityV2.ascx.cs"
    Inherits="CountryStateCityV2" %>
<%@ Register TagPrefix="dnn" Namespace="DotNetNuke.Web.Client.ClientResourceManagement" Assembly="DotNetNuke.Web.Client" %>


<dnn:DnnJsInclude ID="GoogleMapsAPÍ" runat="server" FilePath="https://maps.googleapis.com/maps/api/js?v=3.exp&key=AIzaSyB1gqjm4RqlcFCBJvPSlblg1uZNSkrFsgg&sensor=false&libraries=places"></dnn:DnnJsInclude>
<dnn:DnnJsInclude ID="MarkerCluster" runat="server" FilePath="https://google-maps-utility-library-v3.googlecode.com/svn/trunk/markerclusterer/src/markerclusterer.js"></dnn:DnnJsInclude>


<style>
    #map-canvas {
        height: 100%;
        margin: 0px;
        padding: 0px;
    }

    div.gmap img {
        max-width: none;
    }

    button.save-marker, button.remove-marker {
        border: none;
        background: rgba(0, 0, 0, 0);
        color: #00F;
        padding: 0px;
        text-decoration: underline;
        margin-right: 10px;
        cursor: pointer;
        font-size: 10px;
    }
</style>

<div>

    <input id="address" class="controls " type="text" runat="server" style="display: none;" />

    <input id="pac_input" class="controls" type="text" runat="server" style="display: none;" />

    <input id="btnGeocode<%=ClientID%>" class="tertiary-button" type="button" value="<%=GetLabelGeocodeButton()%>" style="display: none;" onclick="geocodeAddress('<%=ClientID%>    ','<%=address.ClientID%>    ','<%=pac_input.ClientID%>    ','<%=hdVal1.ClientID%>    ')" />

    <div id="map_canvas<%=ClientID%>" class="gmap" style="width: auto; min-height: 270px; height: auto;">
    </div>
    <div class="rfv">
        <asp:RequiredFieldValidator ID="rfvAddress" runat="server" resourcekey="rfvAddress" Visible="false" ControlToValidate="address"></asp:RequiredFieldValidator>
        <asp:RegularExpressionValidator ID="rgvtxtaddress" runat="server" SetFocusOnError="True"
            ControlToValidate="address" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*">
        </asp:RegularExpressionValidator>
    </div>
    <div class="rfv">
        <asp:CustomValidator ID="lblMessage" runat="server"></asp:CustomValidator>
    </div>
</div>
<div style="display: none;" class="locations" id="locationsPanel<%=ClientID%>">
    <p class="title field"><%=GetLocationPanelTitle()%></p>
    <ul id="locationsList<%=ClientID%>">
    </ul>
</div>
<div style="display: none;" id="emptyMessage<%=ClientID%>">
    <p><%=GetEmptyMessage()%></p>
</div>
<asp:HiddenField ID="hdVal1" runat="server" />



