<%@ Control Language="C#" AutoEventWireup="true" CodeFile="NZElegibility.ascx.cs" Inherits="NZElegibility" %>
<style>
  
</style> 
<div>
    <h1>
        <asp:Label runat="server" ID="lblTitle" />
    </h1>
</div>
<div>

    <p>
        <asp:Label runat="server" ID="lblDescription" />
    </p>
</div>
<div>
    <asp:Label runat="server" ID="lHtml"></asp:Label>
</div>


<div id="divMessage" style="display: none">
    <label style="color: red">* <%=Localization.GetString("Message",LocalResourceFile)%></label>
</div>


<div>
    <asp:Button runat="server" ID="btnContinue" OnClientClick="if(!Continue()) return false" OnClick="btnContinue_Click"/>
</div>


<asp:HiddenField runat="server" ID="ResponseHTML" />

