CREATE PROCEDURE [dbo].[dnn_CoreMessaging_DeleteSubscriptionType]
	@SubscriptionTypeId int
AS
BEGIN
	DELETE FROM dbo.[dnn_CoreMessaging_SubscriptionTypes] WHERE [SubscriptionTypeId] = @SubscriptionTypeId

	IF @@ROWCOUNT <> 0
		SELECT 0 AS [ResultStatus]
	ELSE
		SELECT -1 AS [ResultStatus]
END

