CREATE PROCEDURE [dbo].[dnn_CoreMessaging_DeleteMessageRecipientByMessageAndUser]
    @MessageID int,
    @UserID int
AS
BEGIN
	DELETE
	FROM dbo.[dnn_CoreMessaging_MessageRecipients]
	WHERE [MessageID] = @MessageID AND [UserID] = @UserID
END

