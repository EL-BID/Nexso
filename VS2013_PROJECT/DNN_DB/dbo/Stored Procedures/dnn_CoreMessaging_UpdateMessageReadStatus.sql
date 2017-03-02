CREATE PROCEDURE [dbo].[dnn_CoreMessaging_UpdateMessageReadStatus]
	@ConversationID int,
	@UserID          int,
	@Read			 bit
AS
BEGIN
UPDATE dbo.[dnn_CoreMessaging_MessageRecipients] SET [Read]=@Read 
WHERE UserID = @UserID
AND MessageID IN (SELECT MessageID FROM dbo.[dnn_CoreMessaging_Messages] WHERE ConversationID=@ConversationID)
END

