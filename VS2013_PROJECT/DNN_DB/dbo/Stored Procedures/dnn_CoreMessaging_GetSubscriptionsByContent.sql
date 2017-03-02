CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetSubscriptionsByContent]
	@PortalId int,
	@SubscriptionTypeID int,
	@ObjectKey NVARCHAR(255)
AS
BEGIN
	SELECT *
	FROM dbo.[dnn_CoreMessaging_Subscriptions]
	WHERE 
		(( @PortalId is null and PortalId is null) or (PortalId = @PortalId))
		AND SubscriptionTypeID = @SubscriptionTypeID
		AND ObjectKey = @ObjectKey
END

