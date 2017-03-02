CREATE PROCEDURE [dbo].[dnn_CoreMessaging_DeleteLegacyMessage]
    @MessageID int
AS
	DELETE FROM dbo.dnn_Messaging_Messages
	WHERE  [MessageID] = @MessageID

