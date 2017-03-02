CREATE PROCEDURE [dbo].[dnn_DeleteEventLogType]
	@LogTypeKey nvarchar(35)
AS
DELETE FROM dbo.dnn_EventLogTypes
WHERE	LogTypeKey = @LogTypeKey

