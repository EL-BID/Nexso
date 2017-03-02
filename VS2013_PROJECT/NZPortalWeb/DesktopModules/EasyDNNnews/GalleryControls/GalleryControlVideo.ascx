<%@ control language="C#" autoeventwireup="true" inherits="EasyDNNSolutions.Modules.EasyDNNNews.GalleryControlVideo, App_Web_gallerycontrolvideo.ascx.1b1ab6" enableviewstate="false" %>
<br />
<div id="VideoGalleryID" class="article_gallery" runat="server">
	<asp:Panel ID="pnlVideoGallery" runat="server">
		<div id='<%=settings.GalleryTheme.Substring(0, settings.GalleryTheme.LastIndexOf("."))%>' class="easydnngallery">
			<div class="EDGbackground">
				<div class="EDGcontentbgrd">
					<div class="EDGcornerbotleft">
						<div class="EDGcornerbotright">
							<div class="EDGcornertopleft">
								<div class="EDGcornertopright">
									<div class="EDGcontent" style="text-align: center;">
										<asp:Label ID="lblMessage" runat="server" Text="" Visible="False"></asp:Label>
										<asp:DataList ID="dlVideos" runat="server" Font-Bold="False" Font-Italic="False" Font-Overline="False" Font-Strikeout="False" Font-Underline="False" HorizontalAlign="Center" CssClass="video_gallery">
											<EditItemStyle HorizontalAlign="Center" />
											<ItemTemplate>
												<asp:PlaceHolder ID="phVGEmbed" runat="server" Visible='<%# ToDisplay("Embeded Video",DataBinder.Eval(Container.DataItem, "MediaType"))%>'>
													<div id="embedvideo" style="z-index: 0">
														<asp:Label ID="lblVGEVMediaTitle" runat="server" Text='<%#Eval("Title") %>' Visible="<%#settings.ShowTitle%>"></asp:Label>
														<div class="VideoBodyEmbed">
															<%#Eval("FileName") %></div>
														<asp:Label ID="lblVGEVMediaDescription" runat="server" Text='<%#Server.HtmlDecode(DataBinder.Eval(Container.DataItem, "Description").ToString())%>' Visible="<%#settings.ShowDescription%>"></asp:Label>
													</div>
												</asp:PlaceHolder>
												<asp:PlaceHolder ID="phSWfFlash" runat="server" Visible='<%# ToDisplayVideo("Video",DataBinder.Eval(Container.DataItem, "MediaType"),DataBinder.Eval(Container.DataItem, "Info"))%>'>
													<asp:Label ID="lblVGEVMediaTitle3" runat="server" Text='<%#Eval("Title") %>' Visible="<%#settings.ShowTitle%>"></asp:Label>
													<div class="VideoBodyPlayer">
														<div id="EDNpid<%#Eval("PictureID") %>">
															You need to upgrade your flash player.
														</div>
													</div>
													<asp:Label ID="lblVGEVMediaDescription3" runat="server" Text='<%#Server.HtmlDecode(DataBinder.Eval(Container.DataItem, "Description").ToString())%>' Visible="<%#settings.ShowDescription%>"></asp:Label>
													<script type="text/javascript">
														eds1_8(document).ready(function () {
															var flashvars = {};
															var params = {};
															params.wmode = 'transparent';
															var attributes = {};
															swfobject.embedSWF('<%#DataBinder.Eval(Container.DataItem, "FileName")%>', '#EDNpid<%#Eval("PictureID") %>', '<%# GetVideoWidth(DataBinder.Eval(Container.DataItem, "MediaType"),DataBinder.Eval(Container.DataItem, "FileName"))%>', '<%# GetVideoHeight(DataBinder.Eval(Container.DataItem, "MediaType"),DataBinder.Eval(Container.DataItem, "FileName"))%>', "9.0.0", "<%=ModulePath%>js/expressInstall.swf", flashvars, params, attributes);
														}); 
													</script>
												</asp:PlaceHolder>
												<asp:PlaceHolder ID="phEVVideo" runat="server" Visible='<%# ToDisplayVideoMpeg("Video",DataBinder.Eval(Container.DataItem, "MediaType"),DataBinder.Eval(Container.DataItem, "Info"))%>'>
													<asp:Label ID="lblVGEVMediaTitle2" runat="server" Text='<%#Eval("Title") %>' Visible="<%#settings.ShowTitle%>"></asp:Label>
													<div class="VideoBodyPlayer">
															<div style='display: block; width: <%#GetVideoWidth(DataBinder.Eval(Container.DataItem, "MediaType"),DataBinder.Eval(Container.DataItem, "FileName"))%>px; height: <%# GetVideoHeight(DataBinder.Eval(Container.DataItem, "MediaType"),DataBinder.Eval(Container.DataItem, "FileName"))%>px' data-embed="false" class="flowplayer" fullscreen="true" data-tooltip="false" data-flashfit="true" data-native_fullscreen="true" data-adaptiveratio="true" controls="controls">
																<video poster="<%#DataBinder.Eval(Container.DataItem, "ThumbUrl")%>">
																	<source type="video/mp4" src="<%#GetFlowFileName(DataBinder.Eval(Container.DataItem, "FileName"))%>">
																</video>
															</div>
														</div>
													<asp:Label ID="lblVGEVMediaDescription2" runat="server" Text='<%#Server.HtmlDecode(DataBinder.Eval(Container.DataItem, "Description").ToString())%>' Visible="<%#settings.ShowDescription%>"></asp:Label>
												</asp:PlaceHolder>
											</ItemTemplate>
										</asp:DataList>
										<asp:GridView ID="gvVGalPagination" runat="server" AllowPaging="True" AutoGenerateColumns="False" DataKeyNames="NumOf" HorizontalAlign="Center" PageSize="1" ShowFooter="True" ShowHeader="False" Width="28px" BorderWidth="0px" BorderStyle="None" GridLines="None"
											EnableModelValidation="True" CssClass="gallery_pagination" onpageindexchanging="gvVGalPagination_PageIndexChanging">
											<Columns>
												<asp:BoundField DataField="FileName" Visible="False" />
											</Columns>
											<PagerStyle HorizontalAlign="Center" CssClass="EDGpager" BorderWidth="0px" />
										</asp:GridView>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
				<div style="clear: both">
					&nbsp;</div>
			</div>
		</div>
	</asp:Panel>
</div>
