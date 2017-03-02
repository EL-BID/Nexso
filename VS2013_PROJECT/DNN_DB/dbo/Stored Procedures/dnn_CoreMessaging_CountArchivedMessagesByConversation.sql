CREATE PROCEDURE [dbo].[dnn_CoreMessaging_CountArchivedMessagesByConversation]
	@ConversationID int
AS
BEGIN
	SELECT COUNT(*) AS TotalArchivedThreads
	FROM dbo.[dnn_CoreMessaging_MessageRecipients]
	WHERE MessageID IN (SELECT MessageID FROM dbo.[dnn_CoreMessaging_Messages] WHERE ConversationID = @ConversationID)
	AND [Archived] = 1
END

