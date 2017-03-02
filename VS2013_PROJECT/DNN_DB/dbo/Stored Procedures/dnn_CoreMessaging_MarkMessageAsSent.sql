CREATE PROCEDURE [dbo].[dnn_CoreMessaging_MarkMessageAsSent]
	@MessageId int,
	@RecipientId int
AS
BEGIN
	Update dbo.dnn_CoreMessaging_MessageRecipients set EmailSent = 1  where MessageID =@MessageId AND RecipientId=@RecipientId
END

