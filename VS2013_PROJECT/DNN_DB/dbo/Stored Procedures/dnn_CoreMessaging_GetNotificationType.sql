CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetNotificationType]
	@NotificationTypeID int
AS
BEGIN
	SELECT [NotificationTypeID], [Name], [Description], [TTL], [DesktopModuleId], [CreatedByUserID], [CreatedOnDate], [LastModifiedByUserID], [LastModifiedOnDate], [IsTask]
	FROM dbo.[dnn_CoreMessaging_NotificationTypes]
	WHERE [NotificationTypeID] = @NotificationTypeID
END

