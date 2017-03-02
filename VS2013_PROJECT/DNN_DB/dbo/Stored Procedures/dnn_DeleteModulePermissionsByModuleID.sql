CREATE PROCEDURE [dbo].[dnn_DeleteModulePermissionsByModuleID]
	@ModuleID int,
	@PortalID int
AS
	DELETE FROM dbo.dnn_ModulePermission
		WHERE ModuleID = @ModuleID
			AND PortalID = @PortalID

