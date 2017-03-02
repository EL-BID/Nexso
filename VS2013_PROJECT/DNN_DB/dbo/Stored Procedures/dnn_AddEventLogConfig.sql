CREATE procedure [dbo].[dnn_AddEventLogConfig]
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

DECLARE @ID int
SET @ID = (SELECT EC.ID FROM dbo.dnn_EventLogConfig EC 
				WHERE (EC.LogTypeKey = @LogTypeKey OR (EC.LogTypeKey IS NULL AND @LogTypeKey IS NULL))  
					AND (EC.LogTypePortalID = @LogTypePortalID  OR (EC.LogTypePortalID IS NULL AND @LogTypePortalID IS NULL))
			)

IF @ID IS NULL
	BEGIN
		INSERT INTO dbo.dnn_EventLogConfig
			(LogTypeKey,
			LogTypePortalID,
			LoggingIsActive,
			KeepMostRecent,
			EmailNotificationIsActive,
			NotificationThreshold,
			NotificationThresholdTime,
			NotificationThresholdTimeType,
			MailFromAddress,
			MailToAddress)
		VALUES
			(@LogTypeKey,
			@LogTypePortalID,
			@LoggingIsActive,
			@KeepMostRecent,
			@EmailNotificationIsActive,
			@NotificationThreshold,
			@NotificationThresholdTime,
			@NotificationThresholdTimeType,
			@MailFromAddress,
			@MailToAddress)
	END
ELSE
	BEGIN
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
	END

