CREATE PROCEDURE [dbo].[dnn_Messaging_GetMessage] 
	@MessageID bigint
AS
	SELECT * FROM dnn_Messaging_Messages WHERE MessageID = @MessageID

