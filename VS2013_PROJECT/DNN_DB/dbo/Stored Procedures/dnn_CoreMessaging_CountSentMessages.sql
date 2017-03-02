CREATE PROCEDURE [dbo].[dnn_CoreMessaging_CountSentMessages]
	@UserID int,
	@PortalID int
AS
BEGIN
	SELECT COUNT(MessageID) AS TotalRecords
	FROM dbo.[dnn_CoreMessaging_Messages]
	WHERE SenderUserID = @UserID
	AND NotificationTypeID IS NULL AND PortalID = @PortalID
END

