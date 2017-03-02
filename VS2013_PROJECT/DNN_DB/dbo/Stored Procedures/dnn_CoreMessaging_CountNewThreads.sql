CREATE PROCEDURE [dbo].[dnn_CoreMessaging_CountNewThreads]
	@UserID int,
	@PortalID INT
AS
BEGIN
	SELECT COUNT(*) AS TotalNewThreads
	FROM dbo.[dnn_CoreMessaging_MessageRecipients] MR
	JOIN dbo.[dnn_CoreMessaging_Messages] M ON MR.MessageID = M.MessageID
	WHERE MR.UserID = @UserID
	AND MR.[Read] = 0
	AND M.PortalID=@PortalID
	AND M.NotificationTypeID IS NULL
END

