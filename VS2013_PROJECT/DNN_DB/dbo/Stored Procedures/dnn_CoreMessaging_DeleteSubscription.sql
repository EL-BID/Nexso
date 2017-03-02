CREATE PROCEDURE [dbo].[dnn_CoreMessaging_DeleteSubscription]
	@SubscriptionId int
AS 
BEGIN
	DELETE FROM dbo.[dnn_CoreMessaging_Subscriptions] WHERE [SubscriptionId] = @SubscriptionId

	IF @@ROWCOUNT <> 0
		SELECT 0 AS [ResultStatus]
	ELSE
		SELECT -1 AS [ResultStatus]
END

