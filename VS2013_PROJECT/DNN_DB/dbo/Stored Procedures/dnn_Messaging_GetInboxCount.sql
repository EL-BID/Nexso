CREATE PROCEDURE [dbo].[dnn_Messaging_GetInboxCount] 
	@PortalID int,
	@UserID int
AS

	SELECT COUNT (*)[Body]
	FROM dbo.dnn_Messaging_Messages
	WHERE (ToUserID= @UserID AND Status in (1,2) AND SkipPortal = '0') 
		OR (FromUserID = @UserID AND Status = 0)

