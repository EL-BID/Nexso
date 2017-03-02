CREATE PROCEDURE [dbo].[dnn_GetEventLogPendingNotifConfig]
AS

SELECT 	COUNT(*) as PendingNotifs,
	elc.ID,
	elc.LogTypeKey, 
	elc.LogTypePortalID, 
	elc.LoggingIsActive,
	elc.KeepMostRecent,
	elc.EmailNotificationIsActive,
	elc.NotificationThreshold,
	elc.NotificationThresholdTime,
	elc.NotificationThresholdTimeType,
	elc.MailToAddress, 
	elc.MailFromAddress
FROM dbo.dnn_EventLogConfig elc
INNER JOIN dbo.dnn_EventLog
ON dbo.dnn_EventLog.LogConfigID = elc.ID
WHERE dbo.dnn_EventLog.LogNotificationPending = 1
GROUP BY elc.ID,
	elc.LogTypeKey, 
	elc.LogTypePortalID, 
	elc.LoggingIsActive,
	elc.KeepMostRecent,
	elc.EmailNotificationIsActive,
	elc.NotificationThreshold,
	elc.NotificationThresholdTime,
	elc.NotificationThresholdTimeType,
	elc.MailToAddress, 
	elc.MailFromAddress

