CREATE PROCEDURE [dbo].[dnn_SetEventMessageComplete]
	
	@EventMessageID int

AS
	UPDATE dbo.dnn_EventQueue
		SET IsComplete = 1
	WHERE EventMessageID = @EventMessageID

