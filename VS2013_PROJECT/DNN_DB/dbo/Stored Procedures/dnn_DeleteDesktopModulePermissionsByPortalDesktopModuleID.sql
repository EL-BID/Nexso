CREATE PROCEDURE [dbo].[dnn_DeleteDesktopModulePermissionsByPortalDesktopModuleID]
	@PortalDesktopModuleID int
AS
    DELETE FROM dbo.dnn_DesktopModulePermission
    WHERE PortalDesktopModuleID = @PortalDesktopModuleID

