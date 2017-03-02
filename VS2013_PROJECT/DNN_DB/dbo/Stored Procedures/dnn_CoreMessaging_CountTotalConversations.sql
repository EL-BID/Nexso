CREATE PROCEDURE [dbo].[dnn_CoreMessaging_CountTotalConversations]
	@UserID int,
	@PortalID int
AS
BEGIN
	SELECT COUNT(DISTINCT M.ConversationID) AS TotalConversations
	FROM dbo.[dnn_CoreMessaging_Messages] M
	JOIN dbo.[dnn_CoreMessaging_MessageRecipients] MR ON M.MessageID = MR.MessageID
	WHERE NotificationTypeID IS NULL AND PortalID = @PortalID AND Archived = 0 AND UserID = @UserID
END

