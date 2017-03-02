CREATE PROCEDURE [dbo].[dnn_CoreMessaging_AddSubscription]
	@UserId INT ,
	@PortalId INT ,
	@SubscriptionTypeId INT ,
	@ObjectKey NVARCHAR(255) ,
	@Description NVARCHAR(255),
	@ModuleId INT ,
	@TabId INT,
	@ObjectData NVARCHAR(MAX)
AS 
	BEGIN
        DECLARE @SubscriptionId INT = NULL   
        
        SELECT  TOP 1 @SubscriptionId = SubscriptionId
		FROM    dbo.dnn_CoreMessaging_Subscriptions
		WHERE   UserId = @UserId
				AND (( @PortalId is null and PortalId is null) or (PortalId = @PortalId))
				AND SubscriptionTypeId = @SubscriptionTypeID
				AND ObjectKey = @ObjectKey
				AND ((@ModuleId is null and ModuleId is null ) or (ModuleId = @ModuleId))	
				AND ((@TabId is null and TabId is null ) or (TabId = @TabId))
		      
        IF (@SubscriptionId IS NULL) 
			BEGIN
				INSERT  INTO dbo.dnn_CoreMessaging_Subscriptions
						( UserId ,
							PortalId ,
							SubscriptionTypeId ,
							ObjectKey ,
							Description,
							CreatedOnDate ,
							ModuleId ,
							TabId,
							ObjectData
						)
				VALUES  ( @UserId ,
							@PortalId ,
							@SubscriptionTypeId ,
							@ObjectKey ,
							@Description,
							GETUTCDATE() ,
							@ModuleId ,
							@TabId,
							@ObjectData
						)

				SELECT  SCOPE_IDENTITY() AS [SubscriptionId]
			END
		ELSE 
			BEGIN
				UPDATE  dbo.dnn_CoreMessaging_Subscriptions
				SET     UserId = @UserId ,
						PortalId = @PortalId ,
						SubscriptionTypeId = @SubscriptionTypeId ,
						ObjectKey = @ObjectKey ,
						Description = @Description ,
						ModuleId = @ModuleId ,
						TabId = @TabId,
						ObjectData = @ObjectData
				WHERE   SubscriptionId = @SubscriptionId

				SELECT  @SubscriptionId AS [SubscriptionId]
			END
	END

