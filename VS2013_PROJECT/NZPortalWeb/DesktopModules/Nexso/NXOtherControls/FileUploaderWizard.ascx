<%@ Control Language="C#" AutoEventWireup="true" CodeFile="FileUploaderWizard.ascx.cs"
    Inherits="FileUploaderWizard" %>
<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<style type="text/css">
    .RadUpload input.ruFakeInput, .hidden {
        display: none;
    }
</style>

<div id="dialog-modal-file">
    
</div>

<asp:UpdatePanel ID="UpdatePanel1" runat="server">
    <ContentTemplate>
        <asp:Wizard ID="WizardFile" runat="server" DisplaySideBar="False">
            <StartNavigationTemplate>
                <asp:Button ID="StartNextButton" runat="server" CommandName="MoveNext" Visible="false" />
            </StartNavigationTemplate>
            <FinishNavigationTemplate>
                <asp:Button runat="server" Visible="false" />
                <asp:Button runat="server" Visible="false" />
            </FinishNavigationTemplate>
            <WizardSteps>
                <asp:WizardStep ID="WizardStep1" runat="server" Title="Step 1">
                    <div>
                        <div class="documents">
                            <asp:Repeater ID="rCategory" runat="server" OnItemDataBound="rCategory_ItemDataBound">
                                <HeaderTemplate>
                                    <ul>
                                </HeaderTemplate>
                                <FooterTemplate>
                                    </ul>
                                </FooterTemplate>
                                <ItemTemplate>
                                    <div class="document-title title">
                                        <asp:Label runat="server" ID="lblCategory" Text='<%#NexsoProBLL.ListComponent.GetLabelFromListKey("FileCategory",System.Threading.Thread.CurrentThread.CurrentCulture.Name,Eval("List.Key").ToString() )
                                        %> '></asp:Label>
                                    </div>
                                    <asp:Repeater ID="rDocument" runat="server" OnItemDataBound="ItemDataBound">
                                        <HeaderTemplate>
                                            <ul>
                                        </HeaderTemplate>
                                        <FooterTemplate>
                                            </ul>
                                        </FooterTemplate>
                                        <ItemTemplate>
                                            <li>
                                                <a title="<%#Eval("Description")%>" href="javascript:openPopUpPdfViewer('<%#Eval("DocumentId")%>')">
                                                    <asp:Image runat="server" visible='<%#GetThumbImage((Guid)Eval("DocumentId"),(String)Eval("Category"))==string.Empty ? false:true%>' ID="iImage" ImageUrl='<%# GetThumbImage((Guid)Eval("DocumentId"),(String)Eval("Category"))%>' Width="300px"  />
                                                 </a>
                                                    <br />
                                                <asp:LinkButton OnClick="ibtnEdit_Click" ID="ibtnEdit" CommandArgument='<%#Eval("DocumentId")%>' runat="server"><i class="icon-pencil"></i></asp:LinkButton>

                                                <a title="<%#Eval("Description")%>" href="javascript:onClientUploaderHandler('<%#Eval("DocumentId")%>')">
                                                    <%#TitleDocument(Eval("Title").ToString(),Eval("Name").ToString(), Eval("FileType").ToString()).ToString()%>

                                                </a>
                                               
                                           
                                            </li>
                                        </ItemTemplate>
                                    </asp:Repeater>

                                    <asp:Repeater ID="rFile" runat="server" OnItemDataBound="ItemDataBound">
                                        <HeaderTemplate>
                                            <ul>
                                        </HeaderTemplate>
                                        <FooterTemplate>
                                            </ul>
                                        </FooterTemplate>
                                        <ItemTemplate>
                                            <li>
                                                <asp:LinkButton OnClick="ibtnEdit_Click" ID="ibtnEditFile" CommandArgument='<%# Eval("ChallengeObjectId")%>' runat="server"><i class="icon-pencil"></i></asp:LinkButton>

                                                <a title="<%#Eval("ObjectName")%>" href="<%#"/"+ Eval("ObjectLocation")%>" target="_blank">
                                                    <%#Eval("ObjectName").ToString() + Eval("ObjectExtension").ToString()%>
                                                </a>
                                                <br/>
                                                <asp:Image runat="server" ID="iImage" ImageUrl='<%# Eval("ObjectLocation")!=string.Empty ? "~/" + Eval("ObjectLocation"):string.Empty%>' Width="100px" Height="100px" />
                                                
                                            </li>
                                            <hr />
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </ItemTemplate>
                            </asp:Repeater>
                            <p>
                                <asp:Label Visible="False" ID="lblEmptyMessage" runat="server" resourcekey="EmptyItem"></asp:Label>
                            </p>
                        </div>
                        <div>
                            <telerik:radasyncupload visible="False" runat="server" id="aUploadFile" multiplefileselection="Disabled"
                                onfileuploaded="RadAsyncUpload1_FileUploaded" postbacktriggers="RadButton1" maxfileinputscount="1" 
                                onclientfileselected="fileSelected" maxfilesize="3145728" allowedfileextensions=".jpg,.png,.pdf,.doc,.docx,.ppt,.pptx,.xls,.xlsx" />
                            <telerik:radprogressarea visible="False" runat="server" id="rdProgressAreaUploadFile" />
                        </div>
                    </div>
                    <div style="display: none;">
                        <asp:Button runat="server" ID="RadButton1" Text="" ValidationGroup="aUploadFiledocument"/>
                    </div>
                    <div class="rfv">
                        <span id="rfvWrongExtension<%=ClientID%>" style="display: none;"><%=Localization.GetString("rfvWrongExtension",LocalResourceFile)%></span>
                        <span id="rfvWrongSize<%=ClientID%>" style="display: none;"><%=Localization.GetString("rfvWrongSize",LocalResourceFile)%></span>

                    </div>
                    </div>
                </asp:WizardStep>
                <asp:WizardStep ID="WizardStep2" runat="server" Title="Step 2">
                    <div>
                        <div>
                            <asp:Label runat="server" ID="lblCategory" resourcekey="Category"></asp:Label>
                        </div>
                        <div>
                            <asp:DropDownList ID="ddCategory" runat="server" DataTextField="Label" DataValueField="Key">
                            </asp:DropDownList>

                        </div>
                        <div class="rfv">
                            <asp:RequiredFieldValidator ID="rfvddCategoryDocument" runat="server" ControlToValidate="ddCategory"
                                resourcekey="rfvddCategoryDocument" InitialValue="0" ValidationGroup="document"></asp:RequiredFieldValidator>
                        </div>
                        <div>
                            <asp:Label runat="server" ID="lblTitle"></asp:Label>
                        </div>
                        <div style="display: -webkit-box;">
                            <asp:TextBox runat="server" ID="txtTitle" />
                        </div>
                        <div class="rfv">
                            <asp:RequiredFieldValidator ID="rfvtxtTitle" runat="server" ControlToValidate="txtTitle"
                                 ValidationGroup="document"></asp:RequiredFieldValidator>
                            <asp:RegularExpressionValidator ID="rgvtxtTitle" runat="server" SetFocusOnError="True"  ValidationGroup="document"
                                        ControlToValidate="txtTitle" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*">
                                    </asp:RegularExpressionValidator>
                        </div>
                        <div>
                            <asp:Label runat="server" ID="lblFileName" resourcekey="FileName"></asp:Label>
                        </div>
                        <div style="display: -webkit-box;">
                            <asp:TextBox runat="server" ID="txtFileName"></asp:TextBox><asp:Label ID="lblExtension"
                                runat="server"></asp:Label>
                        </div>
                        <div class="rfv">
                            <asp:RequiredFieldValidator ID="rfvtxtFileName" runat="server" ControlToValidate="txtFileName"
                                resourcekey="rfvtxtFileName" ValidationGroup="document"></asp:RequiredFieldValidator>
                              <asp:RegularExpressionValidator ID="rgvtxtFileName" runat="server" SetFocusOnError="True"  ValidationGroup="document"
                                        ControlToValidate="txtFileName" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*">
                                    </asp:RegularExpressionValidator>
                        </div>
                        <div>
                            <asp:Label runat="server" ID="lblDescription" resourcekey="Description"></asp:Label>
                        </div>
                        <div>
                            <asp:TextBox runat="server" ID="txtDescription" TextMode="MultiLine"></asp:TextBox>
                        </div>
                        <div class="rfv">
                              <asp:RegularExpressionValidator ID="rgvtxtDescription" runat="server" SetFocusOnError="True"  ValidationGroup="document"
                                        ControlToValidate="txtDescription" ValidationExpression="^(?!(.|\n)*<[^>]+>)(.|\n)*">
                                    </asp:RegularExpressionValidator>
                        </div>
                        <div>
                            <asp:Label runat="server" ID="lblScope" resourcekey="Scope"></asp:Label>
                        </div>
                        <div>
                            <asp:RadioButtonList ID="rdbScope" DataTextField="Label" DataValueField="Value" runat="server"
                                RepeatDirection="Horizontal" TextAlign="Right" Width="90%">
                            </asp:RadioButtonList>
                        </div>
                        <div runat="server" id="CreateFile" visible="false">
                            <asp:Button ID="btnBackCreate" runat="server" resourcekey="btnBack" OnClick="btnBack_Click" />
                            <asp:Button ID="btnSaveCreate" runat="server" resourcekey="btnSave" CausesValidation="true" ValidationGroup="document" OnClick="btnSave_Click" />
                        </div>
                        <div runat="server" id="UpdateFile" visible="false">
                            <asp:Button ID="btnBackUpdate" runat="server" resourcekey="btnBack" OnClick="btnBack_Click" />
                            <asp:Button ID="btnDeleteUpdate" runat="server" resourcekey="btnDelete" OnClick="btnDeleteUpdate_Click" />
                            <asp:Button ID="btnSaveUpdate" runat="server" resourcekey="btnSave" OnClick="btnUpdate_Click" CausesValidation="true" ValidationGroup="document" />
                        </div>
                    </div>
                </asp:WizardStep>
            </WizardSteps>
        </asp:Wizard>
    </ContentTemplate>
</asp:UpdatePanel>

<script>
   
    $(document).ready(function () {
        $("#dialog-modal-file").hide();
    });

    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandlerFile);
    function EndRequestHandlerFile(sender, args) {
        $("#dialog-modal-file").hide();

    }

</script>