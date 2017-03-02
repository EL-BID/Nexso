CREATE PROCEDURE [dbo].[dnn_DeleteDesktopModulePermissionsByUserID]
    @UserId   INT,  -- required, not null!
	@PortalId INT -- Null affects all sites
AS
    DELETE FROM dbo.[dnn_DesktopModulePermission]
    WHERE UserID = @UserId
     AND (PortalDesktopModuleID IN (SELECT PortalDesktopModuleID 
									FROM dbo.[dnn_PortalDesktopModules] 
									WHERE PortalID = @PortalId) OR IsNull(@PortalId, -1) = -1)

