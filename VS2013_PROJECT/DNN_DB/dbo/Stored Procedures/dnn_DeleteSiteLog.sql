CREATE PROCEDURE [dbo].[dnn_DeleteSiteLog]
	@DateTime                      datetime, 
	@PortalID                      int

AS
	DELETE FROM dbo.dnn_SiteLog WITH(READPAST)
	WHERE  PortalId = @PortalID
		AND    DateTime < @DateTime

