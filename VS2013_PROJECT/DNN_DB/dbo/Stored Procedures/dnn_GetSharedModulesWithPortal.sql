CREATE PROCEDURE [dbo].[dnn_GetSharedModulesWithPortal]
	@Portald int
AS
	SELECT * FROM dbo.dnn_vw_TabModules tb		
	WHERE tb.PortalID != tb.OwnerPortalID	
	AND tb.PortalID = @Portald

