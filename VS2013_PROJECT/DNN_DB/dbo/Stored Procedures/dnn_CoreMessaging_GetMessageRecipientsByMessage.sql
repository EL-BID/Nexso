CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetMessageRecipientsByMessage]
    @MessageID INT
AS
	SELECT [RecipientID], [MessageID], [UserID], [Read], [Archived], [CreatedByUserID], [CreatedOnDate], [LastModifiedByUserID], [LastModifiedOnDate]
	FROM   dbo.dnn_CoreMessaging_MessageRecipients
	WHERE  [MessageID] = @MessageID

