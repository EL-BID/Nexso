CREATE PROCEDURE [dbo].[dnn_DeleteDesktopModulePermission]
	@DesktopModulePermissionID int
AS
    DELETE FROM dbo.dnn_DesktopModulePermission
    WHERE DesktopModulePermissionID = @DesktopModulePermissionID

