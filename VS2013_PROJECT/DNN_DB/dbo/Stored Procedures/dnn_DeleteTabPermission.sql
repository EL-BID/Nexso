CREATE PROCEDURE [dbo].[dnn_DeleteTabPermission]
	@TabPermissionID int
AS

DELETE FROM dbo.dnn_TabPermission
WHERE
	[TabPermissionID] = @TabPermissionID

