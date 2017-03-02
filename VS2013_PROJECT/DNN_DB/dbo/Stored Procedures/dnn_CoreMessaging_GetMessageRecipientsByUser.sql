CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetMessageRecipientsByUser]
    @UserID INT
AS
	SELECT [RecipientID], [MessageID], [UserID], [Read], [Archived], [CreatedByUserID], [CreatedOnDate], [LastModifiedByUserID], [LastModifiedOnDate]
	FROM   dbo.dnn_CoreMessaging_MessageRecipients
	WHERE  [UserID] = @UserID

