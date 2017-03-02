CREATE PROCEDURE [dbo].[dnn_CoreMessaging_AddSubscriptionType]
	@SubscriptionName NVARCHAR(50) ,
	@FriendlyName NVARCHAR(50) ,
	@DesktopModuleId INT
AS
	DECLARE @currentId int

	SELECT TOP(1) @currentId = SubscriptionTypeId
	FROM dbo.dnn_CoreMessaging_SubscriptionTypes
	WHERE DesktopModuleId = @DesktopModuleId
	  AND SubscriptionName = @SubscriptionName

	IF @currentId IS NOT NULL
	BEGIN
		SELECT @currentId
	END
	ELSE
	BEGIN
		INSERT  dbo.dnn_CoreMessaging_SubscriptionTypes
				( SubscriptionName ,
				  FriendlyName ,
				  DesktopModuleId
				)
		VALUES  ( @SubscriptionName ,
				  @FriendlyName ,
				  @DesktopModuleId
				)
		SELECT SCOPE_IDENTITY()
	END
