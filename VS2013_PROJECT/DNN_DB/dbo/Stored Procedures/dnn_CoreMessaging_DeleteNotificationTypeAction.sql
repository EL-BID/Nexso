CREATE PROCEDURE [dbo].[dnn_CoreMessaging_DeleteNotificationTypeAction]
	@NotificationTypeActionID int
AS
BEGIN
	DELETE 
	FROM dbo.[dnn_CoreMessaging_NotificationTypeActions]
	WHERE [NotificationTypeActionID] = @NotificationTypeActionID
END

