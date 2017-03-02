CREATE PROCEDURE [dbo].[dnn_UpdateIPFilter]
	@IPFilterID		int,
	@IPAddress		nvarchar(50),
	@SubnetMask		nvarchar(50),
	@RuleType		tinyint,
	@LastModifiedByUserID		int
AS 
	BEGIN
		UPDATE dbo.dnn_IPFilter 
			SET 
				IPAddress = @IPAddress,
				SubnetMask = @SubnetMask,
				RuleType = @RuleType,
				LastModifiedByUserID = @LastModifiedByUserID,
				LastModifiedOnDate = getdate()
			WHERE IPFilterID = @IPFilterID
	END

