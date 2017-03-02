CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetNotifications]
	@UserID int,
	@PortalID int,
	@AfterNotificationID int,
	@NumberOfRecords int
AS
BEGIN
	--Get the top message for each conversation
	;WITH Notifications AS
	(
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
            M.[Context],
			ROW_NUMBER() OVER(ORDER BY M.[CreatedOnDate] DESC) AS RowNumber
		FROM dbo.[dnn_CoreMessaging_Messages] AS M
		JOIN dbo.[dnn_CoreMessaging_MessageRecipients] MR ON M.MessageID = MR.MessageID
		WHERE [NotificationTypeId] IS NOT NULL
		AND MR.UserID = @UserID
		AND M.PortalID = @PortalID
		AND (M.[ExpirationDate] IS NULL OR (M.[ExpirationDate] IS NOT NULL AND M.[ExpirationDate] > GETUTCDATE()))
	)	
	SELECT * FROM Notifications
	WHERE (@AfterNotificationID > 0 AND RowNumber BETWEEN (SELECT RowNumber + 1 FROM Notifications WHERE [MessageID] = @AfterNotificationID) AND (SELECT RowNumber + @NumberOfRecords FROM Notifications WHERE [MessageID] = @AfterNotificationID)) OR
	(@AfterNotificationID = -1 AND RowNumber BETWEEN 1 AND @NumberOfRecords)
	ORDER BY RowNumber ASC
END

