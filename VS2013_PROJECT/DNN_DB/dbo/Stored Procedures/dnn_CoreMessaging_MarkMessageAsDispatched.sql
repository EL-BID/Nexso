CREATE PROCEDURE [dbo].[dnn_CoreMessaging_MarkMessageAsDispatched]
	@MessageId int,
	@RecipientId int
AS
BEGIN
	Update dbo.dnn_CoreMessaging_MessageRecipients set EmailSent = 1, EmailSentDate =GETDATE()   where MessageID =@MessageId AND RecipientId=@RecipientId
END

