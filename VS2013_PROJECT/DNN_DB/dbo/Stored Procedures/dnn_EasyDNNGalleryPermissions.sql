CREATE PROCEDURE dbo.[dnn_EasyDNNGalleryPermissions]
    @UserID int,
    @PortalID int,
    @ModuleID int
AS 
SET NOCOUNT ON;
IF @UserID = -1
BEGIN
	SELECT [AllowToComment],[CommentEditing],[CommentDeleting],[AllowToRate],[ShowComments],[ShowRating],[AllowToDownload], [AllowToLike] FROM dbo.dnn_EasyGalleryRolePermissions WHERE RoleID IS NULL AND ModuleID = @ModuleID;
END
ELSE
BEGIN
	WITH RoleAndUserRights as
	(
		SELECT DISTINCT [AllowToComment],[CommentEditing],[CommentDeleting],[AllowToRate],[ShowComments],[ShowRating], [AllowToDownload], [AllowToLike]
			FROM dbo.dnn_EasyGalleryRolePermissions AS rps INNER JOIN dbo.dnn_UserRoles AS ur ON ur.RoleID = rps.RoleID INNER JOIN dbo.dnn_Roles as r ON r.RoleID = ur.RoleID
		WHERE ur.UserID = @UserID AND rps.ModuleID = @ModuleID AND r.PortalID = @PortalID
		UNION
		SELECT [AllowToComment],[CommentEditing],[CommentDeleting],[AllowToRate],[ShowComments],[ShowRating],[AllowToDownload], [AllowToLike] FROM  dbo.dnn_EasyGalleryUserPermissions AS ups
		WHERE ups.UserID = @UserID AND ups.ModuleID = @ModuleID
	)
	SELECT TOP(1)
		CASE WHEN EXISTS (SELECT AllowToComment FROM RoleAndUserRights WHERE AllowToComment = 1) THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END AS AllowToComment,
		CASE WHEN EXISTS (SELECT CommentEditing FROM RoleAndUserRights WHERE CommentEditing = 1) THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END AS CommentEditing,
		CASE WHEN EXISTS (SELECT CommentDeleting FROM RoleAndUserRights WHERE CommentDeleting = 1) THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END AS CommentDeleting,
		CASE WHEN EXISTS (SELECT AllowToRate FROM RoleAndUserRights WHERE AllowToRate = 1) THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END AS AllowToRate,
		CASE WHEN EXISTS (SELECT ShowComments FROM RoleAndUserRights WHERE ShowComments = 1) THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END AS ShowComments,
		CASE WHEN EXISTS (SELECT ShowRating FROM RoleAndUserRights WHERE ShowRating = 1) THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END AS ShowRating,
		CASE WHEN EXISTS (SELECT AllowToDownload FROM RoleAndUserRights WHERE AllowToDownload = 1) THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END AS AllowToDownload,
		CASE WHEN EXISTS (SELECT AllowToLike FROM RoleAndUserRights WHERE AllowToLike = 1) THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END AS AllowToLike
	FROM RoleAndUserRights
END