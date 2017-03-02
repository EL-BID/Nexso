CREATE PROCEDURE [dbo].[dnn_DeletePermission]
	@PermissionID int
AS

DELETE FROM dbo.dnn_Permission
WHERE
	[PermissionID] = @PermissionID

