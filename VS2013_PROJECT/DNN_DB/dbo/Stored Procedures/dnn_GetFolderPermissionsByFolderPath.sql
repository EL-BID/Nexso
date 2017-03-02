CREATE PROCEDURE [dbo].[dnn_GetFolderPermissionsByFolderPath]
	
	@PortalID int,
	@FolderPath nvarchar(300), 
	@PermissionID int

AS
SELECT *
FROM dbo.dnn_vw_FolderPermissions

WHERE	((FolderPath = @FolderPath 
				AND ((PortalID = @PortalID) OR (PortalID IS NULL AND @PortalID IS NULL)))
			OR (FolderPath IS NULL AND PermissionCode = 'SYSTEM_FOLDER'))
	AND	(PermissionID = @PermissionID OR @PermissionID = -1)

