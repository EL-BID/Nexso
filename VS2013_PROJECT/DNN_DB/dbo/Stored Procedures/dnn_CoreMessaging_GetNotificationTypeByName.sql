CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetNotificationTypeByName]
	@Name nvarchar(100)
AS
BEGIN
	SELECT [NotificationTypeID], [Name], [Description], [TTL], [DesktopModuleId], [CreatedByUserID], [CreatedOnDate], [LastModifiedByUserID], [LastModifiedOnDate], [IsTask]
	FROM dbo.[dnn_CoreMessaging_NotificationTypes]
	WHERE [Name] LIKE @Name
END

