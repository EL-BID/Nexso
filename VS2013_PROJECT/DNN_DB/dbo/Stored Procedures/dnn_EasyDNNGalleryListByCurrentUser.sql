CREATE PROCEDURE dbo.[dnn_EasyDNNGalleryListByCurrentUser]
	@PortalID int,
	@ModuleID int,
	@GalleryID int,
	@UserID int,
	@CurrentUserID int,
	@GroupId int = 1,
	@ItemsFrom int = 1,
	@ItemsTo int = 500,
	@OrderBy nvarchar(20) = 'Position ASC',
	@MediaType nvarchar(40) = 'Image,Video,Embeded Video,Audio,'
AS
SET NOCOUNT ON;
WITH tempEGP AS (
	SELECT Distinct egp.[PictureID],egp.[PortalID],egp.[UserID],egp.[GalleryID],egp.[Title],egp.[Description],egp.[FileName],egp.[ThumbUrl],egp.[Position],egp.[MediaType],egp.[ShortEmbedUrl]
	  ,egp.[ViewerThumb],egp.[Info],egp.[FileExtension],egp.[ImageUrl],egp.[DateUploaded],egp.[StartupImage],egp.[HiResVersion],egp.[JournalId],egp.[RatingValue],egur.Value
	FROM dbo.dnn_EasyGalleryPictures AS egp INNER JOIN dbo.dnn_EasyGallery as eg ON eg.GalleryID= egp.GalleryID 
	INNER JOIN dbo.dnn_EasyGalleryCategory AS egc ON eg.CategoryID = egc.CategoryID
	INNER JOIN dbo.dnn_EasyGalleryModuleCategory AS egmc ON  egc.CategoryID = egmc.CategoryID
	LEFT OUTER JOIN dbo.dnn_EasyGallerySecurity AS egs on egs.GalleryID = eg.GalleryID
	INNER JOIN dbo.dnn_Journal_User_Permissions(@PortalId,@CurrentUserId, @GroupId) as t ON t.seckey = egs.SecurityKey OR egs.SecurityKey IS NULL 
	left join dbo.dnn_EasyGalleryUserRating as egur on egp.PictureID= egur.PictureID AND egur.UserID=@CurrentUserID
	WHERE egmc.ModuleID= @ModuleID AND egp.JournalID IS NULL AND ((@GalleryID <> 0 AND (egp.GalleryID=@GalleryID)) OR (@GalleryID = 0)) AND eg.UserID=@UserID AND (egp.MediaApproved = 'True' OR egp.MediaApproved IS NULL) AND egp.MediaType In (Select ParsedString From dbo.dnn_EDSGallery_ParseStringList(@MediaType))
	UNION ALL
	SELECT Distinct egp.[PictureID],egp.[PortalID],egp.[UserID],egp.[GalleryID],egp.[Title],egp.[Description],egp.[FileName],egp.[ThumbUrl],egp.[Position],egp.[MediaType],egp.[ShortEmbedUrl]
	  ,egp.[ViewerThumb],egp.[Info],egp.[FileExtension],egp.[ImageUrl],egp.[DateUploaded],egp.[StartupImage],egp.[HiResVersion],egp.[JournalId],egp.[RatingValue],egur.Value
	FROM dbo.dnn_EasyGalleryPictures AS egp INNER JOIN dbo.dnn_Journal_Security as js ON js.JournalId = egp.JournalId
	INNER JOIN dbo.dnn_EasyGallery as eg ON eg.GalleryID= egp.GalleryID 
	INNER JOIN dbo.dnn_EasyGalleryCategory AS egc ON eg.CategoryID = egc.CategoryID
	INNER JOIN dbo.dnn_EasyGalleryModuleCategory AS egmc ON  egc.CategoryID = egmc.CategoryID
	INNER JOIN dbo.dnn_Journal_User_Permissions(@PortalId,@CurrentUserId, @GroupId) as t ON t.seckey = js.SecurityKey
	left join dbo.dnn_EasyGalleryUserRating as egur on egp.PictureID= egur.PictureID AND egur.UserID=@CurrentUserID
	WHERE egmc.ModuleID= @ModuleID AND egp.JournalID IS NOT NULL AND ((@GalleryID <> 0 AND (egp.GalleryID=@GalleryID)) OR (@GalleryID = 0)) AND eg.UserID=@UserID AND (egp.MediaApproved = 'True' OR egp.MediaApproved IS NULL) AND egp.MediaType In (Select ParsedString From dbo.dnn_EDSGallery_ParseStringList(@MediaType))
),
tempct AS (SELECT gct.PictureID, gct.ThumbCreated From dbo.dnn_EasyGalleryCreatedThumbs gct Where gct.ModuleID = @ModuleID)
SELECT * FROM (SELECT Distinct tempEGP.*,tempct.ThumbCreated, ROW_NUMBER() OVER (ORDER BY 
	 CASE WHEN @OrderBy ='Position ASC' THEN Position END,
	 CASE WHEN @OrderBy ='Position DESC' THEN Position END DESC,
	 CASE WHEN @OrderBy ='DateUploaded ASC' THEN DateUploaded END,
	 CASE WHEN @OrderBy ='DateUploaded DESC' THEN DateUploaded END DESC,
	 CASE WHEN @OrderBy ='FileName ASC' THEN FileName END,
	 CASE WHEN @OrderBy ='FileName DESC' THEN FileName END DESC,
	 CASE WHEN @OrderBy ='Title ASC' THEN Title END,
	 CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC) as Kulike
 FROM tempEGP left join tempct on tempEGP.PictureID = tempct.PictureID) AS Result
 WHERE Kulike BETWEEN @ItemsFrom AND @ItemsTo ORDER BY 
	 CASE WHEN @OrderBy ='Position ASC' THEN Position END,
	 CASE WHEN @OrderBy ='Position DESC' THEN Position END DESC,
	 CASE WHEN @OrderBy ='DateUploaded ASC' THEN DateUploaded END,
	 CASE WHEN @OrderBy ='DateUploaded DESC' THEN DateUploaded END DESC,
	 CASE WHEN @OrderBy ='FileName ASC' THEN FileName END,
	 CASE WHEN @OrderBy ='FileName DESC' THEN FileName END DESC,
	 CASE WHEN @OrderBy ='Title ASC' THEN Title END,
	 CASE WHEN @OrderBy ='Title DESC' THEN Title END DESC