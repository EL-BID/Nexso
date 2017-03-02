CREATE PROCEDURE [dbo].[dnn_CoreMessaging_CountMessagesByConversation]
	@ConversationID int
AS
BEGIN
	SELECT COUNT(*) AS TotalRecords
	FROM dbo.dnn_CoreMessaging_Messages
	WHERE (ConversationID = @ConversationID)
END

