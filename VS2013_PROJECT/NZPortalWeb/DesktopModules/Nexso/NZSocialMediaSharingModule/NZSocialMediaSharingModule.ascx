<%@ Control Language="C#" AutoEventWireup="true" CodeFile="NZSocialMediaSharingModule.ascx.cs" Inherits="NZSocialMediaSharingModule" %>
<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<telerik:RadSocialShare ID="RadSocialShare1" runat="server" BorderStyle="None">
    <MainButtons>
        <telerik:RadSocialButton SocialNetType="ShareOnFacebook"></telerik:RadSocialButton>
        <telerik:RadSocialButton SocialNetType="ShareOnTwitter"></telerik:RadSocialButton>
        <telerik:RadSocialButton SocialNetType="GooglePlusOne"></telerik:RadSocialButton>
        <telerik:RadSocialButton SocialNetType="LinkedInShare"></telerik:RadSocialButton>
        <telerik:RadSocialButton SocialNetType="ShareOnPinterest"></telerik:RadSocialButton>
        <telerik:RadSocialButton SocialNetType="SendEmail"></telerik:RadSocialButton>
    </MainButtons>
</telerik:RadSocialShare>