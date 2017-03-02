CREATE PROCEDURE [dbo].[dnn_GetTabPermission]

	@TabPermissionID int

AS
SELECT *
FROM dbo.dnn_vw_TabPermissions
WHERE TabPermissionID = @TabPermissionID

