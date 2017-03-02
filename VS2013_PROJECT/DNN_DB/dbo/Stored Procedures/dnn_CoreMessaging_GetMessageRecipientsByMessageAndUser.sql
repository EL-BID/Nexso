CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetMessageRecipientsByMessageAndUser]
    @MessageID INT,
    @UserID INT
AS
	SELECT [RecipientID], [MessageID], [UserID], [Read], [Archived], [CreatedByUserID], [CreatedOnDate], [LastModifiedByUserID], [LastModifiedOnDate]
	FROM   dbo.dnn_CoreMessaging_MessageRecipients
	WHERE  [MessageID] = @MessageID
	AND   [UserID] = @UserID

