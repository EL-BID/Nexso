CREATE PROCEDURE [dbo].[dnn_DeletePortalInfo]
	@PortalID int

AS
	/* Delete all the Portal Modules */
	DELETE
	FROM dbo.dnn_Modules
	WHERE PortalId = @PortalID

	/* Delete all the Portal Skins */
	DELETE
	FROM dbo.dnn_Packages
	WHERE  PortalId = @PortalID

	/* Delete Portal */
	DELETE
	FROM dbo.dnn_Portals
	WHERE  PortalId = @PortalID

