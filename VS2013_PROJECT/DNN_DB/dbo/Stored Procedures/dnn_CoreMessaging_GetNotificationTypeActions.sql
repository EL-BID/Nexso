CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetNotificationTypeActions]
	@NotificationTypeID int
AS
BEGIN
	SELECT [NotificationTypeActionID], [NotificationTypeID], [NameResourceKey], [DescriptionResourceKey], [ConfirmResourceKey], [Order], [APICall], [CreatedByUserID], [CreatedOnDate], [LastModifiedByUserID], [LastModifiedOnDate]
	FROM dbo.[dnn_CoreMessaging_NotificationTypeActions]
	WHERE [NotificationTypeID] = @NotificationTypeID
	ORDER BY [Order]
END

