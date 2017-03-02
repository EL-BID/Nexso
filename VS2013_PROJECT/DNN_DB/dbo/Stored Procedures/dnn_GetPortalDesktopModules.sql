CREATE PROCEDURE [dbo].[dnn_GetPortalDesktopModules]
	@PortalId int,
	@DesktopModuleId int

AS
	SELECT dnn_PortalDesktopModules.*,
		   PortalName,
		   FriendlyName
	FROM   dnn_PortalDesktopModules
		INNER JOIN dnn_vw_Portals ON dnn_PortalDesktopModules.PortalId = dnn_vw_Portals.PortalId
		INNER JOIN dnn_DesktopModules ON dnn_PortalDesktopModules.DesktopModuleId = dnn_DesktopModules.DesktopModuleId
	WHERE  ((dnn_PortalDesktopModules.PortalId = @PortalId) OR @PortalId is null)
		AND    ((dnn_PortalDesktopModules.DesktopModuleId = @DesktopModuleId) OR @DesktopModuleId is null)
	ORDER BY dnn_PortalDesktopModules.PortalId, dnn_PortalDesktopModules.DesktopModuleId

