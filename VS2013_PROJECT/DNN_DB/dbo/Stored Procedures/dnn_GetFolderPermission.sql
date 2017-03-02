CREATE PROCEDURE [dbo].[dnn_GetFolderPermission]
	
	@FolderPermissionID int

AS
SELECT *
FROM dbo.dnn_vw_FolderPermissions
WHERE FolderPermissionID = @FolderPermissionID

