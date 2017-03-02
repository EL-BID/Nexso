CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetMessageRecipient]
    @RecipientID INT
AS
	SELECT [RecipientID], [MessageID], [UserID], [Read], [Archived], [CreatedByUserID], [CreatedOnDate], [LastModifiedByUserID], [LastModifiedOnDate]
	FROM   dbo.dnn_CoreMessaging_MessageRecipients
	WHERE  [RecipientID] = @RecipientID

