<%@ Control Language="C#" AutoEventWireup="false" Inherits="DotNetNuke.UI.Skins.Controls.UserNexso" CodeFile="UserNexso.ascx.cs" %>
<li class="user">
                  <a href="#" class="toggle"><span class="text"><asp:Literal ID="userFirstName" runat="server"></asp:Literal></span></a>
                  <div class="drop">
                    <span class="name"><asp:HyperLink ID="enhancedRegisterLink" runat="server"/></span>
                    <span class="email"><asp:Literal ID="email" runat="server"></asp:Literal></span>
                    <ul>
                      <li>
                        <asp:HyperLink ID="Messages"  runat="server"/>
                      </li>
                      <li>
                        <asp:HyperLink ID="Settings" runat="server"/>
                      </li>
                      <li>
                        <asp:HyperLink ID="Logout" runat="server"/>
                      </li>
                    </ul>                      
                  </div>
                </li>




    <ul class="buttonGroup" style="display: none;">
        <asp:HyperLink ID="registerLink" runat="server" CssClass="SkinObject" />
        <li class="userMessages alpha" runat="server" ID="messageGroup"><asp:HyperLink ID="messageLink" runat="server"/></li>
        <li class="userNotifications omega" runat="server" ID="notificationGroup"><asp:HyperLink ID="notificationLink" runat="server"/></li>
    	<li class="userDisplayName"></li>
        <li class="userProfileImg" runat="server" ID="avatarGroup"><asp:HyperLink ID="avatar" runat="server"/></li>                                       
    </ul>
