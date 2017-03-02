CREATE PROCEDURE [dbo].[dnn_DeleteExtensionUrlProvider] 
	@ExtensionUrlProviderID	int
AS

DELETE FROM dbo.dnn_ExtensionUrlProviders
	WHERE ExtensionUrlProviderID = @ExtensionUrlProviderID

