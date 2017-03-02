CREATE PROCEDURE [dbo].[dnn_GetTabPermissionsByTabID]
	@TabID int, 
	@PermissionID int
AS

	SELECT  *
	FROM    dbo.dnn_vw_TabPermissions
	WHERE   (TabID = @TabID OR (TabID IS NULL AND PermissionCode = 'SYSTEM_TAB'))
		AND	(PermissionID = @PermissionID OR @PermissionID = -1)

