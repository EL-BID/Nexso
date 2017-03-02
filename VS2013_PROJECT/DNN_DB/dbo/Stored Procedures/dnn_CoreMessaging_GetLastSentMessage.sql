CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetLastSentMessage]
	@UserID int,
	@PortalID INT
AS
BEGIN
	SELECT TOP 1 *	
	FROM dbo.[dnn_CoreMessaging_Messages]
	WHERE SenderUserID = @UserID	
	AND PortalID=@PortalID
	AND NotificationTypeID IS NULL
	ORDER BY MessageID DESC
END

