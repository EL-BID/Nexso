CREATE PROCEDURE [dbo].[dnn_CoreMessaging_DeleteMessage]
	@MessageID int
AS
	DELETE FROM dbo.dnn_CoreMessaging_Messages
	WHERE  [MessageID] = @MessageID

