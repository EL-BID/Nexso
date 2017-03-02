CREATE PROCEDURE [dbo].[dnn_CoreMessaging_DeleteUserNotifications]
	@UserId int,
	@PortalId int
AS
BEGIN
	DELETE FROM dbo.dnn_CoreMessaging_Messages
	WHERE PortalId = @PortalId
	  AND MessageID IN (SELECT MessageID FROM dbo.dnn_CoreMessaging_MessageRecipients WHERE UserID = @UserId)

	SELECT @@ROWCOUNT
END

