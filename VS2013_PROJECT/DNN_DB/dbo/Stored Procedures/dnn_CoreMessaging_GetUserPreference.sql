CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetUserPreference]
	@PortalId INT ,	
	@UserId INT
AS 
BEGIN
	SELECT PortalId, UserId, MessagesEmailFrequency, NotificationsEmailFrequency
	FROM dbo.dnn_CoreMessaging_UserPreferences UP
	WHERE	UP.PortalId = @PortalId
		AND
			UP.UserId = @UserId	
END

