CREATE PROCEDURE [dbo].[dnn_UpdateEventLogPendingNotif]
	@LogConfigID int
AS
UPDATE dbo.dnn_EventLog
SET LogNotificationPending = 0
WHERE LogNotificationPending = 1
AND LogConfigID = @LogConfigID

