CREATE PROCEDURE [dbo].[dnn_UpdateEventLogConfig]
	@ID int,
	@LogTypeKey nvarchar(35),
	@LogTypePortalID int,
	@LoggingIsActive bit,
	@KeepMostRecent int,
	@EmailNotificationIsActive bit,
	@NotificationThreshold int,
	@NotificationThresholdTime int,
	@NotificationThresholdTimeType int,
	@MailFromAddress nvarchar(50),
	@MailToAddress nvarchar(50)
AS
UPDATE dbo.dnn_EventLogConfig
SET 	LogTypeKey = @LogTypeKey,
	LogTypePortalID = @LogTypePortalID,
	LoggingIsActive = @LoggingIsActive,
	KeepMostRecent = @KeepMostRecent,
	EmailNotificationIsActive = @EmailNotificationIsActive,
	NotificationThreshold = @NotificationThreshold,
	NotificationThresholdTime = @NotificationThresholdTime,
	NotificationThresholdTimeType = @NotificationThresholdTimeType,
	MailFromAddress = @MailFromAddress,
	MailToAddress = @MailToAddress
WHERE	ID = @ID

