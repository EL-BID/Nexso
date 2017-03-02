CREATE PROCEDURE [dbo].[dnn_GetEventLogPendingNotif]
	@LogConfigID int
AS
SELECT *
FROM dbo.dnn_vw_EventLog
WHERE LogNotificationPending = 1
AND LogConfigID = @LogConfigID

