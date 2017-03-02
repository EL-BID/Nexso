CREATE PROCEDURE [dbo].[dnn_GetDesktopModulesByPortal]
	@PortalId int 
AS 
	SELECT DISTINCT DM.* 
	FROM dbo.dnn_vw_DesktopModules DM 
	WHERE ( IsPremium = 0 ) 
	OR  ( DesktopModuleID IN ( 
		SELECT DesktopModuleID 
		FROM dbo.dnn_PortalDesktopModules PDM 
		WHERE PDM.PortalId = @PortalId ) ) 
	ORDER BY FriendlyName

