CREATE PROCEDURE [dbo].[dnn_UpdateExtensionUrlProvider] 
	@ExtensionUrlProviderID		int,
	@IsActive					bit
AS
	UPDATE dbo.dnn_ExtensionUrlProviders
		SET IsActive = @IsActive
		WHERE ExtensionUrlProviderID = @ExtensionUrlProviderID

