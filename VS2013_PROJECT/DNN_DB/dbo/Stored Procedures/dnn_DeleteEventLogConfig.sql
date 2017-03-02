CREATE PROCEDURE [dbo].[dnn_DeleteEventLogConfig]
	@ID int
AS
DELETE FROM dbo.dnn_EventLogConfig
WHERE ID = @ID

