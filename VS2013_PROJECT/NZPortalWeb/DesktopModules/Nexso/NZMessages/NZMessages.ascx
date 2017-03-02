<%@ Control Language="C#" AutoEventWireup="true" CodeFile="NZMessages.ascx.cs" Inherits="NZMessages" %>
<div id="noMessageContainer" runat="server" class="noMessage">
    <asp:Label ID="lblnoMessage" runat="server" resourcekey="lblnoMessage"></asp:Label>
</div>
<asp:UpdatePanel ID="UpdatePanel1" runat="server">
    <ContentTemplate>
        <div id="accordion" class="messageBlock">
            <asp:Repeater runat="server" ID="rpConversations" OnItemDataBound="rpConversations_ItemDataBound">
                <ItemTemplate>
                    <div class="userContainer" >
                        <asp:HiddenField ID="hfId" runat="server" Value='<%#Eval("UserId")%>' />
                        <asp:Image CssClass="userPicture" runat="server" ID="imUser" ImageUrl='<%#imageUrl(Convert.ToInt32(Eval("UserId"))) %>' Width="50px" Height="50px" />
                        <asp:Label CssClass="userName" runat="server" ID="lblUser" Text='<%#Eval("FirstName") + " " + Eval("LastName") %>'></asp:Label>

                    </div>
                    <div id="idMessages" class="messageContainer">

                        <asp:Repeater runat="server" ID="rpMessages">
                            <ItemTemplate>
                                <div class="messageBox">
                                    <asp:Label  CssClass="messageFrom" ID="lblFrom" runat="server" Text='<%#"- " +Eval("FirstName")+":"%>' />
                                    <asp:Label CssClass="message" ID="lblMessage" runat="server" Text='<%#Eval("Message1")%>' />
                                    <asp:Label CssClass="messageDate" runat="server" ID="lblDate" Text='<%#Eval("DateCreated")%>'></asp:Label>
                                </div>

                            </ItemTemplate>
                        </asp:Repeater>

                        <asp:TextBox CssClass="messageInput" ID="txtMessage" Width="200px" runat="server"></asp:TextBox>
                        <asp:Button CssClass="messageButton" runat="server" ID="btnSendMessage" OnClick="btnSendMessage_Click" CommandArgument='<%#Eval("UserId")%>' resourcekey="BtnSendMessage" />
                    </div>

                </ItemTemplate>
            </asp:Repeater>
        </div>

    </ContentTemplate>
</asp:UpdatePanel>
<asp:HiddenField ID="hFSelector" runat="server" />
<script type="text/javascript">Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);</script>
