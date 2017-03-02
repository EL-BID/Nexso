<%@ control language="C#" autoeventwireup="true" inherits="EasyDNNSolutions.Modules.EasyDNNNews.GalleryControl, App_Web_gallerycontrol.ascx.1b1ab6" enableviewstate="false" %>
<div id="LightBoxGallery" class="article_gallery" runat="server">
	<style type="text/css">
		#<%=LightBoxGallery.ClientID%> table.EDGlightbox.EDGresponsive
		{
			width: 100%;
			max-width: <%=maxwidth.ToString()%>px;
		}
		#<%=LightBoxGallery.ClientID%> .EDGlightbox.EDGresponsive td
		{
			display: inline-block;
			width: <%=percentWidth.ToString()%>%;
		}
		#<%=LightBoxGallery.ClientID%> .EDGresponsive a, #LightBoxGallery .EDGresponsive .titleempty
		{
			width: 100%;
		}
		#<%=LightBoxGallery.ClientID%> .EDGresponsive .EDGmain .EDGimage a .title, #LightBoxGallery .EDGresponsive .EDGmain .EDGimage a .title span
		{
			width: 100%;
			max-width: 100%;
			padding: 2px 0;
		}
		#<%=LightBoxGallery.ClientID%> .EDGresponsive .EDGmain .EDGimage a .Description
		{
			max-width: 100%;
		}
		#<%=LightBoxGallery.ClientID%> .EDGresponsive .EDGmain
		{
			max-width: <%=settings.ThumbWidth%>px;
		}
		#<%=LightBoxGallery.ClientID%> .EDGresponsive .EDGimage, #LightBoxGallery .EDGresponsive .EDGvideo, #LightBoxGallery .EDGresponsive .EDGaudio
		{
			max-width: 100%;
		}
		#<%=LightBoxGallery.ClientID%> .EDGresponsive img
		{
			max-width: <%=settings.ThumbWidth%>px;
			width: 100%;
		}
		#<%=LightBoxGallery.ClientID%> .EDGresponsive input
		{
			width: 100%;
			max-width: <%=settings.ThumbWidth%>px;
		}
		#<%=LightBoxGallery.ClientID%> .EDGresponsive .EDGimage a img, #LightBoxGallery .EDGresponsive .EDGimage a, #LightBoxGallery .EDGresponsive .EDGimage a input, #LightBoxGallery .EDGresponsive .EDGmain
		{
			float: none;
		}
		#<%=LightBoxGallery.ClientID%> .EDGresponsive .EDGvideo a img, #LightBoxGallery .EDGresponsive .EDGvideo a, #LightBoxGallery .EDGresponsive .EDGmain
		{
			float: none;
		}
		#<%=LightBoxGallery.ClientID%> .EDGresponsive .EDGaudio a img, #LightBoxGallery .EDGresponsive .EDGaudio a, #LightBoxGallery .EDGresponsive .EDGmain
		{
			float: none;
		}
		#<%=LightBoxGallery.ClientID%> .EDGresponsive .EDGimage a:hover img, #LightBoxGallery .EDGresponsive .EDGvideo a:hover img, #LightBoxGallery .EDGresponsive .EDGaudio a:hover img, #LightBoxGallery .EDGresponsive .EDGimage a:hover input
		{
			float: none;
		}
	</style>
	<asp:UpdatePanel ID="upTableGallery" runat="server" UpdateMode="Conditional">
		<ContentTemplate>
			<div id="<%=MainThemeIdentifier%>" class="easydnngallery top">
				<div class="EDGbackground">
					<div class="EDGcontentbgrd">
						<div class="EDGcornerbotleft">
							<div class="EDGcornerbotright">
								<div class="EDGcornertopleft">
									<div class="EDGcornertopright">
										<div class="EDGcontent">
											<asp:Panel ID="pnlTGDisplay" runat="server" HorizontalAlign="Center">
												<asp:Label ID="lblMessage" runat="server" Text="" Visible="False"></asp:Label>
												<asp:Literal ID="ltMediaBeforeList" runat="server" EnableViewState="False"></asp:Literal>
												<asp:DataList ID="dlTableGallery" runat="server" CellPadding="0" RepeatDirection="Horizontal" RepeatColumns="4" Font-Bold="False" Font-Italic="False" Font-Overline="False" Font-Strikeout="False" Font-Underline="False" DataKeyField="PictureID" OnPreRender="dlTableGallery_PreRender"
													RepeatLayout="Table" HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Top">
													<AlternatingItemStyle HorizontalAlign="Center" />
													<EditItemStyle HorizontalAlign="Center" />
													<ItemTemplate>
														<asp:PlaceHolder ID="plImage" runat="server" Visible='<%# ToDisplay("Image",Eval("MediaType"))%>'>
															<div class="EDGmain">
																<div class="EDGimage">
																	<a data-item-index='<%#Eval("MediaItemIndex")%>' edgpid='<%#Eval("PictureID")%>' href='<%#Eval("FileName")%>' pptitle='<%#Eval("PPTitle")%>' rel='<%#Eval("RelTag")%>'>
																		<asp:Image ID="DataListImage" runat="server" ImageUrl='<%#Eval("ThumbnailImage")%>' EnableTheming="True" alt='<%#Eval("AltTag")%>' ImageAlign="Middle" />
																		<span class="flagObject"></span><span class="flag"></span><span class="leftsh"></span><span class="rightsh"></span><span class="botsh"></span><span class="topsh"></span><span class="round1"></span><span class="round2"></span><span class="round3"></span>
																		<span class="round4"></span><span class='<%#Eval("TitleClass")%>'>
																			<asp:Label ID="lblItemTitle" runat="server" Text='<%#Eval("Title")%>' Visible='<%#Eval("DisplayTitle")%>'></asp:Label><br />
																			<asp:Label ID="lblTGDescription6" runat="server" CssClass="Description" Text='<%#Eval("Description")%>' Visible='<%#Eval("DisplayDecsription")%>'></asp:Label>
																		</span></a>
																</div>
															</div>
														</asp:PlaceHolder>
														<asp:PlaceHolder ID="plEmbed" runat="server" Visible='<%# ToDisplay("Embeded Video",Eval("MediaType"))%>'>
															<div class="EDGmain">
																<div class="EDGvideo">
																	<a data-item-index='<%#Eval("MediaItemIndex")%>' edgpid='<%#Eval("PictureID")%>' href='<%#Eval("FileName")%>' rel="ednprettyPhoto_M<%=ModuleId%>" pptitle='<%#Eval("PPTitle")%>'>
																		<asp:Image ID="EmbedImageThumb" runat="server" ImageUrl='<%#Eval("ThumbnailImage")%>' alt='<%#Eval("AltTag")%>' />
																		<span class="flagObject"></span><span class="flag"></span><span class="leftsh"></span><span class="rightsh"></span><span class="botsh"></span><span class="topsh"></span><span class="round1"></span><span class="round2"></span><span class="round3"></span>
																		<span class="round4"></span><span class='<%#Eval("TitleClass")%>'>
																			<asp:Label ID="EmbedTitleLabel" runat="server" Text='<%#Eval("Title")%>' Visible='<%#Eval("DisplayTitle")%>'></asp:Label><br />
																			<asp:Label ID="lblTGDescription2" CssClass="Description" runat="server" Text='<%#Eval("Description")%>' Visible='<%#Eval("DisplayDecsription")%>'></asp:Label></span> </a>
																</div>
															</div>
														</asp:PlaceHolder>
														<asp:PlaceHolder ID="plFlash" runat="server" Visible='<%# ToDisplay("Video",Eval("Info"))%>'>
															<div class="EDGmain">
																<div class="EDGvideo">
																	<a data-item-index='<%#Eval("MediaItemIndex")%>' edgpid='<%#Eval("PictureID")%>' href='<%=ModulePath%>video.html?videourl=<%#Eval("FileName")%>&iframe=true<%#Eval("VideoSize")%>'
																		rel="ednprettyPhoto_M<%=ModuleId%>" pptitle='<%#Eval("PPTitle")%>'>
																		<asp:Image ID="FlashImageThumb" runat="server" ImageUrl='<%#Eval("ThumbnailImage")%>' alt='<%#Eval("AltTag")%>' />
																		<span class="flagObject"></span><span class="flag"></span><span class="leftsh"></span><span class="rightsh"></span><span class="botsh"></span><span class="topsh"></span><span class="round1"></span><span class="round2"></span><span class="round3"></span>
																		<span class="round4"></span><span class='<%#Eval("TitleClass")%>'>
																			<asp:Label ID="FlashTitle" runat="server" Text='<%#Eval("Title")%>' Visible='<%#Eval("DisplayTitle")%>'></asp:Label><br />
																			<asp:Label ID="lblTGDescription3" CssClass="Description" runat="server" Text='<%#Eval("Description")%>' Visible='<%#Eval("DisplayDecsription")%>'></asp:Label></span> </a>
																</div>
															</div>
														</asp:PlaceHolder>
														<asp:PlaceHolder ID="plFlashMov" runat="server" Visible='<%# ToDisplay("flashmov",Eval("Info"))%>'>
															<div class="EDGmain">
																<div class="EDGvideo">
																	<a data-item-index='<%#Eval("MediaItemIndex")%>' edgpid='<%#Eval("PictureID")%>' href='<%#Eval("Filename") %>' rel="ednprettyPhoto_M<%=ModuleId%>" pptitle='<%#Eval("PPTitle")%>'>
																		<asp:Image ID="imgflasmovthumb" runat="server" ImageUrl='<%#Eval("ThumbnailImage")%>' alt='<%#Eval("AltTag")%>' />
																		<span class="flagObject"></span><span class="flag"></span><span class="leftsh"></span><span class="rightsh"></span><span class="botsh"></span><span class="topsh"></span><span class="round1"></span><span class="round2"></span><span class="round3"></span>
																		<span class="round4"></span><span class='<%#Eval("TitleClass")%>'>
																			<asp:Label ID="Label2" runat="server" Text='<%#Eval("Title")%>' Visible='<%#Eval("DisplayTitle")%>'></asp:Label><br />
																			<asp:Label ID="lblTGDescription4" CssClass="Description" runat="server" Text='<%#Eval("Description")%>' Visible='<%#Eval("DisplayDecsription")%>'></asp:Label></span> </a>
																</div>
															</div>
														</asp:PlaceHolder>
														<asp:PlaceHolder ID="plAudio" runat="server" Visible='<%# ToDisplay("Audio",Eval("MediaType"))%>'>
															<div class="EDGmain">
																<div class="EDGaudio">
																	<a data-item-index='<%#Eval("MediaItemIndex")%>' edgpid='<%#Eval("PictureID")%>' href='<%=ModulePath%>audio.html?audiourl=<%#hostpath%><%#Eval("Filename")%>&iframe=true&width=500&height=37' rel="ednprettyPhoto_M<%=ModuleId%>" pptitle='<%#Eval("PPTitle")%>'>
																		<asp:Image ID="imgTGAudio" runat="server" ImageUrl='<%#Eval("ThumbnailImage")%>' alt='<%#Eval("AltTag")%>' />
																		<span class="flagObject"></span><span class="flag"></span><span class="leftsh"></span><span class="rightsh"></span><span class="botsh"></span><span class="topsh"></span><span class="round1"></span><span class="round2"></span><span class="round3"></span>
																		<span class="round4"></span><span class='<%#Eval("TitleClass")%>'>
																			<asp:Label ID="lblAudioTitle" runat="server" Text='<%#Eval("Title")%>' Visible='<%#Eval("DisplayTitle")%>'></asp:Label><br />
																			<asp:Label ID="lblTGDescription5" CssClass="Description" runat="server" Text='<%# Eval("Description")%>' Visible='<%#Eval("DisplayDecsription")%>'></asp:Label></span> </a>
																</div>
															</div>
														</asp:PlaceHolder>
													</ItemTemplate>
													<FooterStyle HorizontalAlign="Center" />
													<HeaderStyle HorizontalAlign="Center" />
													<ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" Wrap="False" />
													<SelectedItemStyle HorizontalAlign="Center" />
													<SeparatorStyle HorizontalAlign="Center" />
												</asp:DataList>
												<asp:Literal ID="ltMediaAfterList" runat="server" EnableViewState="False"></asp:Literal>
												<asp:GridView ID="gvPagging" runat="server" AllowPaging="True" DataKeyNames="PictureID" OnPreRender="gvTGPagination_PreRender" Width="28px" HorizontalAlign="Center" ShowFooter="True" AutoGenerateColumns="False" PageSize="1" ShowHeader="False" BorderWidth="0px"
													BorderStyle="None" Border="0" GridLines="None" CssClass="pagerbox" EnableModelValidation="True" OnPageIndexChanging="gvPagging_PageIndexChanging">
													<Columns>
														<asp:BoundField DataField="PictureID" Visible="False" />
													</Columns>
													<PagerStyle HorizontalAlign="Center" CssClass="EDGpager" BorderWidth="0px" BorderStyle="None" />
												</asp:GridView>
											</asp:Panel>
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
					<div style="clear: both">
						&nbsp;
					</div>
				</div>
			</div>
		</ContentTemplate>
	</asp:UpdatePanel>
</div>
