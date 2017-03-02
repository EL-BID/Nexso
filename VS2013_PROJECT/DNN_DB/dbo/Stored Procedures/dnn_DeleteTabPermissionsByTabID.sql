CREATE PROCEDURE [dbo].[dnn_DeleteTabPermissionsByTabID]
	@TabID int
AS

DELETE FROM dbo.dnn_TabPermission
WHERE
	[TabID] = @TabID

