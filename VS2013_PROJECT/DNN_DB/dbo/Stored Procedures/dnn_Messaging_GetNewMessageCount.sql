CREATE PROCEDURE [dbo].[dnn_Messaging_GetNewMessageCount] 
	@PortalID int,
	@UserID int
AS
	SELECT count(*) FROM dnn_Messaging_Messages WHERE ToUserID = @UserID AND Status = 1

