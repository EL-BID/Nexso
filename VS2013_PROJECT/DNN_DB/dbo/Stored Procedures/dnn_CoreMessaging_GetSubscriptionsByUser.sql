CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetSubscriptionsByUser]
	@PortalId int,
	@UserId int,
	@SubscriptionTypeID int
AS
BEGIN
	SELECT *
	FROM dbo.[dnn_CoreMessaging_Subscriptions]
	WHERE 
			(( @PortalId is null and PortalId is null) or (PortalId = @PortalId))
			AND UserId = @UserId
			AND (@SubscriptionTypeID IS NULL OR SubscriptionTypeID = @SubscriptionTypeID)
END

