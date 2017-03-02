CREATE PROCEDURE [dbo].[dnn_CoreMessaging_UpdateSubscriptionDescription]
	@ObjectKey NVARCHAR(255), 
    @PortalId INT,
    @Description NVARCHAR(255)	
AS 
	BEGIN
		UPDATE dbo.dnn_CoreMessaging_Subscriptions
		SET [Description] = @Description
		WHERE PortalId = @PortalId 
		AND ObjectKey LIKE @ObjectKey		
		SELECT @@ROWCOUNT AS [ResultStatus]      
	END

