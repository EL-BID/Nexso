CREATE PROCEDURE [dbo].[dnn_DeleteFolderPermission]
	@FolderPermissionID int
AS

DELETE FROM dbo.dnn_FolderPermission
WHERE
	[FolderPermissionID] = @FolderPermissionID

