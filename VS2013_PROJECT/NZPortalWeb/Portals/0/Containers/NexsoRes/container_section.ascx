<%@ Control language="vb" CodeBehind="~/admin/Containers/container.vb" AutoEventWireup="false" Explicit="True" Inherits="DotNetNuke.UI.Containers.Container" %>
<%@ Register TagPrefix="dnn" TagName="TITLE1" Src="~/Admin/Containers/Title.ascx" %>
<%@ Register TagPrefix="dnn" TagName="VISIBILITY" Src="~/Admin/Containers/Visibility.ascx" %>
<%@ Register TagPrefix="dnn" TagName="SOLPARTACTIONS" Src="~/Admin/Containers/SolPartActions.ascx" %>

<section>

   <div id="dnnactions"><dnn:SOLPARTACTIONS runat="server" id="dnnSOLPARTACTIONS" /></div>
   <h1 id="title"><dnn:TITLE1 runat="server" id="dnnTITLE1"/></h1>
   <div runat="server" id="ContentPane"></div>

</section>