CREATE PROCEDURE  [dbo].[dnn_AddEventLog]
	@LogGUID varchar(36),
	@LogTypeKey nvarchar(35),
	@LogUserID int,
	@LogUserName nvarchar(50),
	@LogPortalID int,
	@LogPortalName nvarchar(100),
	@LogCreateDate datetime,
	@LogServerName nvarchar(50),
	@LogProperties ntext,
	@LogConfigID int,
	@ExceptionHash varchar(100) = NULL
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM  dbo.[dnn_EventLogTypes] WHERE LogTypeKey = @LogTypeKey)
	BEGIN
		-- Add new Event Type
			EXEC  dbo.[dnn_AddEventLogType] @LogTypeKey, @LogTypeKey, N'', N'DotNetNuke.Logging.EventLogType', N'GeneralAdminOperation'

		-- Add new Event Type Config
			EXEC  dbo.[dnn_AddEventLogConfig] @LogTypeKey, NULL, 0, -1, 0, 1, 1, 1, N'', N''

		-- As the new log config is unlogged, exit without logging
			Return
	END

	DECLARE @LogEventID bigint

	INSERT INTO  dbo.[dnn_EventLog]
		(LogGUID,
		LogTypeKey,
		LogUserID,
		LogUserName,
		LogPortalID,
		LogPortalName,
		LogCreateDate,
		LogServerName,
		LogProperties,
		LogConfigID,
		ExceptionHash)
	VALUES
		(@LogGUID,
		@LogTypeKey,
		@LogUserID,
		@LogUserName,
		@LogPortalID,
		@LogPortalName,
		@LogCreateDate,
		@LogServerName,
		@LogProperties,
		@LogConfigID,
		@ExceptionHash)

	SELECT @LogEventID = SCOPE_IDENTITY()

	DECLARE @NotificationActive bit
	DECLARE @NotificationThreshold bit
	DECLARE @ThresholdQueue int
	DECLARE @NotificationThresholdTime int
	DECLARE @NotificationThresholdTimeType int
	DECLARE @MinDateTime smalldatetime
	DECLARE @CurrentDateTime smalldatetime

	SET @CurrentDateTime = getDate()

	SELECT TOP 1 @NotificationActive = EmailNotificationIsActive,
		@NotificationThreshold = NotificationThreshold,
		@NotificationThresholdTime = NotificationThresholdTime,
		@NotificationThresholdTimeType = NotificationThresholdTimeType,
		@MinDateTime = 
			CASE
				 --seconds
				WHEN NotificationThresholdTimeType=1 THEN DateAdd(second, NotificationThresholdTime * -1, @CurrentDateTime)
				--minutes
				WHEN NotificationThresholdTimeType=2  THEN DateAdd(minute, NotificationThresholdTime * -1, @CurrentDateTime)
				--hours
				WHEN NotificationThresholdTimeType=3  THEN DateAdd(Hour, NotificationThresholdTime * -1, @CurrentDateTime)
				--days
				WHEN NotificationThresholdTimeType=4  THEN DateAdd(Day, NotificationThresholdTime * -1, @CurrentDateTime)
			END
	FROM  dbo.[dnn_EventLogConfig]
	WHERE ID = @LogConfigID

	IF @NotificationActive=1
	BEGIN
		
		SELECT @ThresholdQueue = COUNT(*)
		FROM  dbo.[dnn_EventLog] el
			INNER JOIN  dbo.[dnn_EventLogConfig] elc
				ON  el.LogConfigID =  elc.ID
		WHERE LogCreateDate > @MinDateTime

		IF @ThresholdQueue >= @NotificationThreshold
		BEGIN
			UPDATE  dbo.[dnn_EventLog]
			SET LogNotificationPending = 1 
			WHERE LogConfigID = @LogConfigID
				AND LogNotificationPending IS NULL		
				AND LogCreateDate > @MinDateTime
		END

	END
 
	SELECT @LogEventID
END

