<%@ control language="C#" autoeventwireup="true" inherits="EasyDNNSolutions.Modules.EasyDNNNews.ExcelDataImport, App_Web_dataexportimport.ascx.b9f6810f" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>

<asp:Panel ID="pnlMain" runat="server">
	<div id="EDNadmin">
		<div class="module_action_title_box">
			<ul class="module_navigation_menu">
				<li>
					<asp:LinkButton ID="lbModuleNavigationAddArticle" runat="server" ToolTip="Add article" OnClick="lbModuleNavigationAddArticle_Click" meta:resourcekey="lbModuleNavigationAddArticleResource1"><img src="<%=ModulePath.Replace("Controls/","") %>images/icons/paper_and_pencil.png" alt="" /></asp:LinkButton></li>
				<li>
					<asp:LinkButton ID="lbModuleNavigationArticleEditor" runat="server" ToolTip="Article editor" OnClick="lbModuleNavigationArticleEditor_Click" meta:resourcekey="lbModuleNavigationArticleEditorResource1"><img src="<%=ModulePath.Replace("Controls/","") %>images/icons/papers_and_pencil.png" alt="" /></asp:LinkButton></li>
				<li>
					<asp:LinkButton ID="lbModuleNavigationCategoryEditor" runat="server" ToolTip="Category editor" OnClick="lbModuleNavigationCategoryEditor_Click" meta:resourcekey="lbModuleNavigationCategoryEditorResource1"><img src="<%=ModulePath.Replace("Controls/","") %>images/icons/categories.png" alt="" /></asp:LinkButton></li>
				<li>
					<asp:LinkButton ID="lbModuleNavigationApproveComments" runat="server" ToolTip="Approve comments" OnClick="lbModuleNavigationApproveComments_Click" meta:resourcekey="lbModuleNavigationApproveCommentsResource1"><img src="<%=ModulePath.Replace("Controls/","") %>images/icons/conversation.png" alt="" /></asp:LinkButton></li>
				<li>
					<asp:LinkButton ID="lbModuleNavigationDashboard" runat="server" ToolTip="Dashboard" OnClick="lbModuleNavigationDashboard_Click" meta:resourcekey="lbModuleNavigationDashboardResource1"><img src="<%=ModulePath.Replace("Controls/","") %>images/icons/lcd.png" alt="" /></asp:LinkButton></li>
				<li class="power_off">
					<asp:LinkButton ID="lbPowerOff" runat="server" ToolTip="Close" meta:resourcekey="lbPowerOffResource1"><img src="<%=ModulePath.Replace("Controls/","") %>images/icons/power_off.png" alt="" /></asp:LinkButton></li>
			</ul>
			<h1>
				<%=TopTitle%></h1>
		</div>
		<div class="main_content dashboard">
			<ul class="links">
				<li>
					<asp:LinkButton runat="server" resourcekey="lbImport" ID="lbImport" class="icon content_import" Text="Import" OnClick="lbImport_Click" /></li>
				<li>
					<asp:LinkButton runat="server" resourcekey="lbImportFromExcel" ID="lbImportFromExcel" class="icon excel_import" Text="Import from Excel" OnClick="lbImportFromExcel_Click" />
				</li>
				<li>
					<asp:LinkButton runat="server" resourcekey="lbExport" ID="lbExport" class="icon content_export" Text="Export" OnClick="lbExport_Click" />
				</li>
			</ul>
		</div>
		<div class="module_settings">
			<div class="settings_category_container">
				<div class="tabbed_container">
					<div class="module_settings">
						<div class="settings_category_container">
							<div class="edn_admin_progress_overlay_container">
								<table id="tblImportUploadHeader" runat="server" class="settings_table" cellpadding="0" cellspacing="0">
									<tr>
										<td colspan="2">
											<div class="category_toggle">
												<h2><%=ImportXMLfile%></h2>
											</div>
										</td>
									</tr>
								</table>
								<table id="tblImportFromExcelHeader" runat="server" class="settings_table" cellpadding="0" cellspacing="0" visible="false">
									<tr>
										<td colspan="2">
											<div class="category_toggle">
												<h2><%=ImportdatafromExcel%></h2>
											</div>
										</td>
									</tr>
									<tr>
										<td class="left">

										</td>
										<td class="right">
											<div>
												<a href="<%=ModulePath.Replace("Controls","")%>Excel Import Example.xls">Download Excel example file</a>
											</div>
										</td>
									</tr>
								</table>
								<table id="tblImportModeSelect" runat="server" class="settings_table" cellpadding="0" cellspacing="0">
									<tr>
										<td class="left">&nbsp;</td>
										<td class="right">&nbsp;</td>
									</tr>
									<tr>
										<td class="left">
											<dnn:Label ID="lblSelectImportMethod" runat="server" HelpText="Select to import or upload file. Existing files are located in: /portals/portalnumber/EasyDNNNewsExport/NewsExport/" Text="Please select:" ResourceKey="lblSelectImportMethod"></dnn:Label>
										</td>
										<td class="right">
											<asp:RadioButtonList ID="rblImportModeSelect" runat="server" AutoPostBack="True" OnSelectedIndexChanged="rblImportModeSelect_SelectedIndexChanged" RepeatDirection="Horizontal">
												<asp:ListItem resourcekey="liImportExistingFile" Selected="True" Value="import">Import existing file</asp:ListItem>
												<asp:ListItem resourcekey="liUpload" Value="upload">Upload</asp:ListItem>
											</asp:RadioButtonList>
										</td>
									</tr>
								</table>
								<table id="tblImportExistingFile" runat="server" class="settings_table" cellpadding="0" cellspacing="0">
									<tr>
										<td class="left">
											<dnn:Label ID="lblSelectFileToImport" runat="server" HelpText="Select file to import. Existing files are located in: /portals/portalnumber/EasyDNNNewsExport/NewsExport/" Text="Select file to import:" ResourceKey="lblSelectFileToImport"></dnn:Label>
										</td>
										<td>
											<asp:DropDownList ID="ddlImportXMLFile" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlImportXMLFile_SelectedIndexChanged"></asp:DropDownList></td>
									</tr>
									<tr>
										<td class="left">
											<dnn:Label ID="lblFileOperations" runat="server" HelpText="File actions." Text="File actions:" ResourceKey="lblFileOperations" />
										</td>
										<td class="right">
											<asp:Button ID="btnDeleteExistingXML" ResourceKey="btnDeleteExistingXML" runat="server" Text="Delete" OnClick="btnDeleteExistingXML_Click" />
											<asp:Button ID="btnDownloadExistingXML" ResourceKey="btnDownloadExistingXML" runat="server" Text="Download XML file" OnCommand="btnDownloadExistingXML_Command" />
											<asp:Button ID="btnDownloadExistingZIP" ResourceKey="btnDownloadExistingZIP" runat="server" Text="Download ZIP file" OnClick="btnDownloadExistingZIP_Click" Visible="False" />
										</td>
									</tr>
								</table>
								<table id="tblSelectAuthorAdCategory" runat="server" class="settings_table" cellpadding="0" cellspacing="0">
                                      <tr>
										<td class="left">&nbsp;</td>
										<td class="right">&nbsp;</td>
									</tr>
									<tr>
										<td class="left">
											<dnn:Label ID="lblSelectDefaultCategory" runat="server" HelpText="Select default category to import to - if article doesn't have a category it will be placed into this one." Text="Select default category to import to:" ResourceKey="lblSelectDefaultCategory"></dnn:Label>
										</td>
										<td class="right">
											<asp:DropDownList ID="ddlArticlesCategorySelect" runat="server">
											</asp:DropDownList>
										</td>
									</tr>
									<tr>
										<td class="left">
											<dnn:Label ID="lblSelectAuthor" runat="server" HelpText="Select article author - if no author is selected current user will be added as author." Text="Select article author:" ResourceKey="lblSelectAuthor" />
										</td>
										<td class="right">
											<asp:DropDownList ID="ddlRoles" runat="server" AppendDataBoundItems="True" AutoPostBack="True" OnSelectedIndexChanged="ddlRoles_SelectedIndexChanged" CssClass="ddlgeneral">
												<asp:ListItem ResourceKey="liSelectRole" Value="-1">Select role</asp:ListItem>
											</asp:DropDownList>
											<asp:DropDownList ID="ddlAuthors" runat="server" AppendDataBoundItems="True" CssClass="ddlgeneral">
												<asp:ListItem ResourceKey="liSelectAuthor" Value="-1">Select author</asp:ListItem>
											</asp:DropDownList>
										</td>
									</tr>
								</table>
								<table id="tblUplaodXMLFile" runat="server" class="settings_table" cellpadding="0" cellspacing="0" visible="false">
									<tr>
										<td class="left">
											<dnn:Label ID="lblSelectXMLFile" runat="server" HelpText="Select XML file." Text="Select XML file:" ResourceKey="lblSelectXMLFile" />
										</td>
										<td class="right">
											<asp:FileUpload ID="fuXMLFileUpload" runat="server" /></td>
									</tr>
									<tr>
										<td class="left">
											<dnn:Label ID="lblSelectZipResource" runat="server" HelpText="Select zip file with resources." Text="Select zip resources file:" ResourceKey="lblSelectZipResource" />
										</td>
										<td class="right">
											<asp:FileUpload ID="fuZipFileUpload" runat="server" /></td>
									</tr>
									<tr>
										<td class="left"></td>
										<td class="right">
											<asp:Button ID="btnXMLFileUpload" ResourceKey="btnXMLFileUpload"  runat="server" Text="Upload" OnClick="btnXMLFileUpload_Click" Style="min-height: 30px; min-width:150px" />
										</td>
									</tr>
									<tr>
										<td class="left"></td>
										<td class="right">&nbsp;</td>
									</tr>
								</table>
								<asp:UpdatePanel ID="upImport" runat="server" UpdateMode="Conditional">
									<Triggers>
										<asp:PostBackTrigger ControlID="btnExcelFileUpload" />
										<asp:PostBackTrigger ControlID="btnCancelImport" />
									</Triggers>
									<ContentTemplate>
										<asp:UpdateProgress ID="upImportOverlay" runat="server" AssociatedUpdatePanelID="upImport" DisplayAfter="300" DynamicLayout="true">
											<ProgressTemplate>
												<div class="edn_admin_progress_overlay">
													<asp:Label ID="lblExcelImportInfo" ResourceKey="lblExcelImportInfo"  runat="server" Style="width: 50%; display: block; margin-left: auto; margin-right: auto;" Text="Importing data may take a few minutes to finish. Please wait." Font-Size="Large" />
												</div>
											</ProgressTemplate>
										</asp:UpdateProgress>
										<table id="tblImportFromExistingFile" runat="server" class="settings_table" cellpadding="0" cellspacing="0">
											<tr>
												<td class="left"></td>
												<td class="right">
													<asp:Button ID="btnImportFromExistingXML" ResourceKey="btnImportFromExistingXML"  runat="server" Text="Import" OnClick="btnImportFromXML_Click" Style="min-height: 30px; min-width:150px"/></td>
											</tr>
										</table>
										<table id="tblUploadExcelFile" runat="server" class="settings_table" cellpadding="0" cellspacing="0" visible="false">
											<tr>
												<td class="left">
													<dnn:Label ID="lblSelectExcelFile" runat="server" HelpText="Selec Excel file to upload." Text="Select Excel file:" ResourceKey="lblSelectExcelFile" />
												</td>
												<td class="right">
													<asp:FileUpload ID="fuExcelFileUpload" runat="server" /></td>
											</tr>
											<tr>
												<td class="left"></td>
												<td class="right">
													<asp:Button ID="btnExcelFileUpload" ResourceKey="btnExcelFileUpload"  runat="server" Text="Upload" Style="min-height: 30px; min-width:150px" OnClick="btnExcelFileUpload_Click" />
												</td>
											</tr>
										</table>
										<table class="settings_table" runat="server" id="tblImport" visible="false">
											<tr>
												<td class="left">&nbsp;</td>
												<td class="right">&nbsp;</td>
											</tr>
											<tr>
												<td class="left"></td>
												<td class="right">
													<asp:Button ID="btnImportIntoNews" ResourceKey="btnImportIntoNews" runat="server" Text="Import" OnClick="btnImportIntoNews_Click" />
													<asp:Button ID="btnCancelImport" ResourceKey="btnCancelImport" runat="server" Text="Cancel" OnClick="btnCancelImport_Click" />
												</td>
											</tr>
											<tr id="trExcelScanMessage" runat="server" visible="false">
												<td class="left">
													<asp:Label runat="server" ResourceKey="lblColumnsToImportTitle" ID="lblColumnsToImportTitle" Text="Columns To Import:"></asp:Label>
												</td>
												<td class="right">
													<asp:Literal runat="server" ID="ltColumnsToImport" EnableViewState="False" />
												</td>
											</tr>
										</table>
										<table class="settings_table" runat="server" id="tblImportResults">
											<tr>
												<td class="left">&nbsp;</td>
												<td class="right">
													<asp:Label runat="server" ID="lblImportMainMessage" EnableViewState="False"></asp:Label></td>
											</tr>
										</table>
									</ContentTemplate>
								</asp:UpdatePanel>
							</div>
							<asp:UpdatePanel ID="upExportData" runat="server" UpdateMode="Conditional" Visible="False">
								<ContentTemplate>
									<div class="edn_admin_progress_overlay_container">
										<asp:UpdateProgress ID="upExportOverlay" runat="server" AssociatedUpdatePanelID="upExportData" DisplayAfter="300" DynamicLayout="true">
											<ProgressTemplate>
												<div class="edn_admin_progress_overlay">
													<asp:Label ID="lblExportInfo" ResourceKey="lblExportInfo" runat="server" Style="width: 50%; display: block; margin-left: auto; margin-right: auto;" Text="Exporting files may take a few minutes to finish. Please wait." Font-Size="Large" />
												</div>
											</ProgressTemplate>
										</asp:UpdateProgress>
										<table class="settings_table" cellpadding="0" cellspacing="0">
											<tr>
												<td colspan="2">
													<div class="category_toggle">
														<h2><%=ExportdatatoXMLfile%></h2>
													</div>
												</td>
											</tr>
                                                <tr>
										            <td class="left">&nbsp;</td>
										            <td class="right">&nbsp;</td>
									            </tr>
											<tr>
												<td class="left">
													<asp:Label ID="lblExportFileName" ResourceKey="lblExportFileName" runat="server" Text="Enter file name:"></asp:Label></td>
												<td class="right">
													<asp:TextBox ID="tbExportFileName" runat="server" style="width:250px"></asp:TextBox>
												</td>
											</tr>
											<tr>
												<td class="left">
													<asp:Label ID="lblCreateZipWithData" ResourceKey="lblCreateZipWithData" runat="server" Text="Create zip file with images and document:"></asp:Label>
												</td>
												<td class="right">
													<asp:CheckBox ID="cbCreateZipFile" runat="server" Checked="True" />
												</td>
											</tr>
											<tr>
												<td class="left"></td>
												<td class="right">
													<asp:Button ID="btnExportToXMLFile" ResourceKey="btnExportToXMLFile" runat="server" Text="Export to XML file" OnClick="btnExportToXMLFile_Click" style="min-height: 30px; min-width:150px"/>
												</td>
											</tr>
											<tr>
												<td class="left"></td>
												<td class="right">
													<asp:Label ID="lblExportInfoMessage" runat="server" EnableViewState="False" /></td>
											</tr>
											<tr>
												<td class="left">
													<asp:Label ID="lblExportXMLMessage" runat="server" Text="" />
												</td>
												<td class="right">
													<asp:HyperLink ID="hlExportXMLMessage" ResourceKey="hlExportXMLMessage" runat="server" Visible="false" Text="Download file."></asp:HyperLink>
												</td>
											</tr>
											<tr>
												<td class="left">
													<asp:Label ID="lblExportZipMessage" runat="server" Text="" />
												</td>
												<td class="right">
													<asp:HyperLink ID="hlDownloadZipFile" ResourceKey="hlDownloadZipFile" runat="server" Visible="false" Text="Download file."></asp:HyperLink>
												</td>
											</tr>
										</table>
									</div>
								</ContentTemplate>
							</asp:UpdatePanel>
						</div>
					</div>
				</div>
				<br />
			</div>
		</div>
	</div>
</asp:Panel>
<asp:HiddenField ID="hfUploadedFile" runat="server" />







