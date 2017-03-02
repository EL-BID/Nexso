CREATE PROCEDURE [dbo].[dnn_AddExtensionUrlProvider] 
	@ExtensionUrlProviderID	int, 
    @DesktopModuleId		int, 
    @ProviderName			nvarchar(150), 
    @ProviderType			nvarchar(1000), 
    @SettingsControlSrc		nvarchar(1000), 
    @IsActive				bit, 
    @RewriteAllUrls			bit, 
    @RedirectAllUrls		bit, 
    @ReplaceAllUrls			bit
AS

IF EXISTS (SELECT * FROM dbo.dnn_ExtensionUrlProviders WHERE ExtensionUrlProviderID = @ExtensionUrlProviderID)
	BEGIN
		UPDATE dbo.dnn_ExtensionUrlProviders
			SET
				DesktopModuleId = @DesktopModuleId,
				ProviderName = @ProviderName,
				ProviderType = @ProviderType,
				SettingsControlSrc = @SettingsControlSrc,
				IsActive = @IsActive,
				RewriteAllUrls = @RewriteAllUrls,
				RedirectAllUrls = @RedirectAllUrls,
				ReplaceAllUrls = @ReplaceAllUrls
			WHERE ExtensionUrlProviderID = @ExtensionUrlProviderID
	END
ELSE
	BEGIN
		INSERT INTO dbo.dnn_ExtensionUrlProviders (
				DesktopModuleId,
				ProviderName,
				ProviderType,
				SettingsControlSrc,
				IsActive,
				RewriteAllUrls,
				RedirectAllUrls,
				ReplaceAllUrls
		)
		VALUES (
				@DesktopModuleId,
				@ProviderName,
				@ProviderType,
				@SettingsControlSrc,
				@IsActive,
				@RewriteAllUrls,
				@RedirectAllUrls,
				@ReplaceAllUrls
		)
		
		SET @ExtensionUrlProviderID = @@IDENTITY
		
	END
	
SELECT @ExtensionUrlProviderID

