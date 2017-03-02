CREATE PROCEDURE [dbo].[dnn_GetDesktopModulePermissionsByPortalDesktopModuleID]
	@PortalDesktopModuleID int
AS
    SELECT *
    FROM dbo.dnn_vw_DesktopModulePermissions
	WHERE   PortalDesktopModuleID = @PortalDesktopModuleID

