CREATE PROCEDURE [dbo].[dnn_CoreMessaging_DeleteUserFromConversation]
	@ConversationID INT,
    @UserID INT
AS
    --Remove the User from recipients list
	DELETE FROM dbo.[dnn_CoreMessaging_MessageRecipients]
		WHERE [UserID] = @UserID
		AND MessageID IN (SELECT MessageID FROM dbo.[dnn_CoreMessaging_Messages] WHERE ConversationID = @ConversationID)
    
    --Remove Messages which has no recipient
    DELETE FROM dbo.[dnn_CoreMessaging_Messages]
        FROM dbo.[dnn_CoreMessaging_Messages] m
        LEFT JOIN dbo.[dnn_CoreMessaging_MessageRecipients] mr on MR.MessageID = m.MessageID
        WHERE ConversationID = @ConversationID AND mr.MessageID IS NULL

