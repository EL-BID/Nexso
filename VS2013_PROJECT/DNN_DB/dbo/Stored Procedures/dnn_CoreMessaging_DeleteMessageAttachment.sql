CREATE PROCEDURE [dbo].[dnn_CoreMessaging_DeleteMessageAttachment]
    @MessageAttachmentID int
AS
	DELETE FROM dbo.dnn_CoreMessaging_MessageAttachments
	WHERE  [MessageAttachmentID] = @MessageAttachmentID

