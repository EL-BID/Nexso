CREATE PROCEDURE [dbo].[dnn_CoreMessaging_DeleteNotification]
	@NotificationID int
AS
BEGIN
	DELETE
	FROM dbo.[dnn_CoreMessaging_Messages]
	WHERE [MessageID] = @NotificationID AND [NotificationTypeID] IS NOT NULL
END

