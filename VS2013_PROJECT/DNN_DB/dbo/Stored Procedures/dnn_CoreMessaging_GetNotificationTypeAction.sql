CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetNotificationTypeAction]
	@NotificationTypeActionID int
AS
BEGIN
	SELECT [NotificationTypeActionID], [NotificationTypeID], [NameResourceKey], [DescriptionResourceKey], [ConfirmResourceKey], [Order], [APICall], [CreatedByUserID], [CreatedOnDate], [LastModifiedByUserID], [LastModifiedOnDate]
	FROM dbo.[dnn_CoreMessaging_NotificationTypeActions]
	WHERE [NotificationTypeActionID] = @NotificationTypeActionID
END

