CREATE PROCEDURE [dbo].[dnn_UpdateAuthentication]
	@AuthenticationID       int,
	@PackageID				int,
	@AuthenticationType     nvarchar(100),
	@IsEnabled				bit,
	@SettingsControlSrc     nvarchar(250),
	@LoginControlSrc		nvarchar(250),
	@LogoffControlSrc		nvarchar(250),
	@LastModifiedByUserID	int
AS
	UPDATE dbo.dnn_Authentication
	SET    PackageID = @PackageID,
		   AuthenticationType = @AuthenticationType,
		   IsEnabled = @IsEnabled,
		   SettingsControlSrc = @SettingsControlSrc,
		   LoginControlSrc = @LoginControlSrc,
		   LogoffControlSrc = @LogoffControlSrc,
		   [LastModifiedByUserID] = @LastModifiedByUserID,	
		   [LastModifiedOnDate] = getdate()
	WHERE  AuthenticationID = @AuthenticationID

