CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetMessageAttachment]
    @MessageAttachmentID INT
AS
	SELECT [MessageID], [FileID], [CreatedByUserID], [CreatedOnDate], [LastModifiedByUserID], [LastModifiedOnDate]
	FROM   dbo.dnn_CoreMessaging_MessageAttachments
	WHERE  [MessageAttachmentID] = @MessageAttachmentID

