CREATE PROCEDURE [dbo].[dnn_CoreMessaging_DeleteMessageRecipient]
    @RecipientID int
AS
	DELETE FROM dbo.dnn_CoreMessaging_MessageRecipients
	WHERE  [RecipientID] = @RecipientID

