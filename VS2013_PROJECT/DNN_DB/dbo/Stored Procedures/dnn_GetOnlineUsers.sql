CREATE PROCEDURE [dbo].[dnn_GetOnlineUsers]
	@PortalID int
AS
	SELECT *
		FROM dbo.dnn_UsersOnline UO
			INNER JOIN dbo.dnn_vw_Users U ON UO.UserID = U.UserID 
			INNER JOIN dbo.dnn_UserPortals UP ON U.UserID = UP.UserId
		WHERE  UP.PortalID = @PortalID AND U.PortalID = @PortalID

