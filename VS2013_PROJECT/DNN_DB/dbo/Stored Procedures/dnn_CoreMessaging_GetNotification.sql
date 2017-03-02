CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetNotification]
	@NotificationId int
AS
BEGIN
	SELECT
		M.[MessageID],
		M.[NotificationTypeId],
		M.[To],
		M.[From],
		M.[Subject],
		M.[Body],
		M.[SenderUserID],
		M.[ExpirationDate],
        M.[IncludeDismissAction],
		M.[CreatedByUserID],
		M.[CreatedOnDate],
		M.[LastModifiedByUserID],
		M.[LastModifiedOnDate],
        M.[Context]
	FROM dbo.[dnn_CoreMessaging_Messages] AS M
	WHERE [NotificationTypeId] IS NOT NULL
	AND M.MessageID = @NotificationId
END

