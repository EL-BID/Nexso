CREATE PROCEDURE [dbo].[dnn_CoreMessaging_SetUserPreference]
	@PortalId INT ,	
	@UserId INT,
	@MessagesEmailFrequency INT,
	@NotificationsEmailFrequency INT
AS 
BEGIN	
	UPDATE dbo.dnn_CoreMessaging_UserPreferences
	SET MessagesEmailFrequency = @MessagesEmailFrequency
		,NotificationsEmailFrequency = @NotificationsEmailFrequency
	WHERE PortalId = @PortalId
	AND UserId = @UserId

	IF @@ROWCOUNT = 0 BEGIN
		INSERT INTO dbo.dnn_CoreMessaging_UserPreferences (PortalId, UserId, MessagesEmailFrequency, NotificationsEmailFrequency)
		VALUES (@PortalId, @UserId, @MessagesEmailFrequency, @NotificationsEmailFrequency)
	END	
END

