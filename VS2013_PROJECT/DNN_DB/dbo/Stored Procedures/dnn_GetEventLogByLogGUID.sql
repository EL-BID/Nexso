CREATE PROCEDURE [dbo].[dnn_GetEventLogByLogGUID]
	@LogGUID varchar(36)
AS
SELECT *
FROM dbo.dnn_vw_EventLog
WHERE (LogGUID = @LogGUID)

