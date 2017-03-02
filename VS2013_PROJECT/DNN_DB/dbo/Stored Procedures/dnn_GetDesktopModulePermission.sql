CREATE PROCEDURE [dbo].[dnn_GetDesktopModulePermission]
	@DesktopModulePermissionID	int
AS
    SELECT *
    FROM dbo.dnn_vw_DesktopModulePermissions
    WHERE DesktopModulePermissionID = @DesktopModulePermissionID

