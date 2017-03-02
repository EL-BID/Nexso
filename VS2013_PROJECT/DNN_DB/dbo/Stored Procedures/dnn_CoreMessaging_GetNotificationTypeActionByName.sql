CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetNotificationTypeActionByName]
	@NotificationTypeID int,
	@NameResourceKey nvarchar(100)
AS
BEGIN
	SELECT [NotificationTypeActionID], [NotificationTypeID], [NameResourceKey], [DescriptionResourceKey], [ConfirmResourceKey], [Order], [APICall], [CreatedByUserID], [CreatedOnDate], [LastModifiedByUserID], [LastModifiedOnDate]
	FROM dbo.[dnn_CoreMessaging_NotificationTypeActions]
	WHERE [NotificationTypeID] = @NotificationTypeID AND [NameResourceKey] LIKE @NameResourceKey
END

