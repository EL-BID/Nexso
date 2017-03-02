CREATE PROCEDURE [dbo].[dnn_CoreMessaging_DeleteSubscriptionsByObjectKey]
	@PortalId int,
	@ObjectKey NVARCHAR(255)
AS
BEGIN
	DELETE
	FROM dbo.dnn_CoreMessaging_Subscriptions
	WHERE PortalId = @PortalId
		AND ObjectKey = @ObjectKey
END

