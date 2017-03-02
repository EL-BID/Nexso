CREATE PROCEDURE [dbo].[dnn_GetPortalByPortalAliasID]

	@PortalAliasId  int

AS
SELECT P.*
FROM dbo.dnn_vw_Portals P
	INNER JOIN dbo.dnn_PortalAlias PA ON P.PortalID = PA.PortalID
WHERE PA.PortalAliasId = @PortalAliasId

