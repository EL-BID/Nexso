CREATE PROCEDURE [dbo].[dnn_CoreMessaging_IsSubscribed]
	@PortalId INT ,
	@UserId INT ,
	@SubscriptionTypeId INT ,
	@ObjectKey NVARCHAR(255) ,
	@ModuleId INT ,
	@TabId INT
AS 
	BEGIN
		SELECT  TOP 1 *
		FROM    dbo.dnn_CoreMessaging_Subscriptions
		WHERE   UserId = @UserId
				AND (( @PortalId is null and PortalId is null) or (PortalId = @PortalId))
				AND SubscriptionTypeId = @SubscriptionTypeID
				AND ObjectKey = @ObjectKey
				AND ((@ModuleId is null and ModuleId is null ) or (ModuleId = @ModuleId))	
				AND ((@TabId is null and TabId is null ) or (TabId = @TabId))
	END

