CREATE PROCEDURE [dbo].[dnn_GetSharedModulesByPortal]
	@Portald int
AS
	SELECT * FROM dbo.dnn_vw_TabModules tb		
	WHERE tb.PortalID != tb.OwnerPortalID	
	AND tb.OwnerPortalID = @Portald

