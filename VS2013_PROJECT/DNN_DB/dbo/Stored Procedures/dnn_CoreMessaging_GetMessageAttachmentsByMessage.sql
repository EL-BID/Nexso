CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetMessageAttachmentsByMessage]
    @MessageID INT
AS
	SELECT [MessageID], [FileID], [CreatedByUserID], [CreatedOnDate], [LastModifiedByUserID], [LastModifiedOnDate]
	FROM   dbo.dnn_CoreMessaging_MessageAttachments
	WHERE  [MessageID] = @MessageID

