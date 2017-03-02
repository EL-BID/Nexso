CREATE PROCEDURE [dbo].[dnn_Messaging_MarkMessageAsDispatched]
	@MessageId int
AS
BEGIN
	Update dnn_Messaging_Messages set EmailSent = 1, EmailSentDate =GETDATE()   where MessageID =@MessageId
END

