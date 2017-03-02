CREATE PROCEDURE [dbo].[dnn_CoreMessaging_DeleteNotificationType]
	@NotificationTypeID int
AS
BEGIN
	-- First delete related data
	DELETE
	FROM dbo.[dnn_CoreMessaging_Messages]
	WHERE [NotificationTypeID] = @NotificationTypeID
	
	DELETE
	FROM dbo.[dnn_CoreMessaging_NotificationTypeActions]
	WHERE [NotificationTypeID] = @NotificationTypeID

	-- Finally delete the Notification type
	DELETE
	FROM dbo.[dnn_CoreMessaging_NotificationTypes]
	WHERE [NotificationTypeID] = @NotificationTypeID
END

