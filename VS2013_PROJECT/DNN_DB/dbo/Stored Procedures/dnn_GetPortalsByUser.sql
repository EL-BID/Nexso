CREATE PROCEDURE [dbo].[dnn_GetPortalsByUser]
	@userID		int 
AS

	SELECT     dbo.dnn_vw_Portals.*
FROM         dbo.dnn_UserPortals INNER JOIN
                      dbo.dnn_vw_Portals ON 
					  dbo.dnn_UserPortals.PortalId = dbo.dnn_vw_Portals.PortalID
WHERE     (dbo.dnn_UserPortals.UserId = @userID)
		AND (dbo.dnn_vw_Portals.DefaultLanguage = dbo.dnn_vw_Portals.CultureCode)

