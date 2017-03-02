CREATE PROCEDURE dbo.[dnn_EasyDNNGalleryCountListByCurrentUser]
	@PortalID int,
	@ModuleID int,
	@GalleryID int,
	@UserID int,
	@CurrentUserID int,
	@GroupId int = 1,
	@MediaType nvarchar(40) = 'Image,Video,Embeded Video,Audio,'
AS
SET NOCOUNT ON;
WITH tempEGP AS (
	SELECT Distinct egp.[PictureID] FROM dbo.dnn_EasyGalleryPictures AS egp
		INNER JOIN dbo.dnn_EasyGallery as eg ON eg.GalleryID= egp.GalleryID
		INNER JOIN dbo.dnn_EasyGalleryCategory AS egc ON eg.CategoryID = egc.CategoryID
		INNER JOIN dbo.dnn_EasyGalleryModuleCategory AS egmc ON  egc.CategoryID = egmc.CategoryID
		LEFT OUTER JOIN dbo.dnn_EasyGallerySecurity AS egs on egs.GalleryID = eg.GalleryID
		INNER JOIN dbo.dnn_Journal_User_Permissions(@PortalId,@CurrentUserId, @GroupId) as t ON t.seckey = egs.SecurityKey OR egs.SecurityKey IS NULL 
	WHERE egmc.ModuleID= @ModuleID AND egp.JournalID IS NULL AND ((@GalleryID <> 0 AND (egp.GalleryID=@GalleryID)) OR (@GalleryID = 0)) AND eg.UserID=@UserID AND (egp.MediaApproved = 'True' OR egp.MediaApproved IS NULL) AND egp.MediaType In (Select ParsedString From dbo.dnn_EDSGallery_ParseStringList(@MediaType))
	UNION ALL
	SELECT Distinct egp.[PictureID] FROM dbo.dnn_EasyGalleryPictures AS egp
		INNER JOIN dbo.dnn_Journal_Security as js ON js.JournalId = egp.JournalId
		INNER JOIN dbo.dnn_EasyGallery as eg ON eg.GalleryID= egp.GalleryID
		INNER JOIN dbo.dnn_Journal_User_Permissions(@PortalId,@CurrentUserId, @GroupId) as t ON t.seckey = js.SecurityKey
	WHERE egp.JournalID IS NOT NULL AND ((@GalleryID <> 0 AND (egp.GalleryID=@GalleryID)) OR (@GalleryID = 0)) AND eg.UserID=@UserID AND (egp.MediaApproved = 'True' OR egp.MediaApproved IS NULL) AND egp.MediaType In (Select ParsedString From dbo.dnn_EDSGallery_ParseStringList(@MediaType))
)
SELECT COUNT([PictureID]) FROM tempEGP