<%@ control language="C#" autoeventwireup="true" inherits="EasyDNNSolutions.Modules.EasyDNNNews.GalleryControlAudio, App_Web_gallerycontrolaudio.ascx.1b1ab6" enableviewstate="false" %>
<style type="text/css">
	#<%=dlAudioGallery.ClientID %>	.audiojs {
		width: <%=settings.ThumbWidth%>px;
	}
</style>
<script type="text/javascript">
	eds1_8(document).ready(function ($) {
		audiojs.events.ready(function () {
			var as = audiojs.createAll(null, $('#<%=dlAudioGallery.ClientID%> audio'));
		});
	});
</script>
<div id="AudioGalleryID" runat="server" class="article_gallery">
	<asp:Panel ID="pnlAudioGallery" runat="server">
		<div id='<%=settings.GalleryTheme.Substring(0, settings.GalleryTheme.LastIndexOf("."))%>' class="easydnngallery">
			<div class="EDGbackground">
				<div class="EDGcontentbgrd">
					<div class="EDGcornerbotleft">
						<div class="EDGcornerbotright">
							<div class="EDGcornertopleft">
								<div class="EDGcornertopright">
									<div class="EDGcontent" style="text-align: center;">
										<asp:Label ID="lblMessage" runat="server" Text="" Visible="False"></asp:Label>
										<asp:DataList ID="dlAudioGallery" runat="server" Font-Bold="False" Font-Italic="False" Font-Overline="False" Font-Strikeout="False" Font-Underline="False" HorizontalAlign="Center" ItemStyle-VerticalAlign="Top" CssClass="audio_gallery">
											<EditItemStyle HorizontalAlign="Center" />
											<ItemStyle VerticalAlign="Top" />
											<ItemTemplate>
												<div class="AudioTitle">
													<asp:Label ID="lblAGMediaTitle" runat="server" CssClass="EDGTitleText" Text='<%#Eval("Title") %>' Visible="<%#settings.ShowTitle%>" />
												</div>
												<div class="AudioBody">
													<audio src="<%=hostpath%><%#Eval("Filename")%>" preload="none"></audio>
												</div>
												<div class="AudioDescription">
													<asp:Label ID="lblAGMediaDescription" runat="server" CssClass="EDGTitleText" Text='<%#Server.HtmlDecode(DataBinder.Eval(Container.DataItem, "Description").ToString())%>' Visible="<%#settings.ShowDescription%>" />
												</div>
											</ItemTemplate>
										</asp:DataList>
										<asp:GridView ID="gvAudioGalPagination" runat="server" AllowPaging="True" AutoGenerateColumns="False" BorderWidth="0px" BorderStyle="None" DataKeyNames="NumOf" HorizontalAlign="Center" PageSize="1" ShowFooter="True" GridLines="None" CssClass="gallery_pagination"
											OnPageIndexChanging="gvAudioGalPagination_PageIndexChanging">
											<Columns>
												<asp:BoundField DataField="FileName" Visible="False" />
											</Columns>
											<PagerStyle BorderWidth="0px" CssClass="EDGpager" HorizontalAlign="Center" />
										</asp:GridView>
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
	</asp:Panel>
</div>
