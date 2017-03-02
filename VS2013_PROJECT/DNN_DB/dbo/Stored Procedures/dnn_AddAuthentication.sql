CREATE PROCEDURE [dbo].[dnn_AddAuthentication]
	@PackageID				int,
	@AuthenticationType     nvarchar(100),
	@IsEnabled				bit,
	@SettingsControlSrc     nvarchar(250),
	@LoginControlSrc		nvarchar(250),
	@LogoffControlSrc		nvarchar(250),
	@CreatedByUserID	int
AS
	INSERT INTO dnn_Authentication (
		PackageID,
		AuthenticationType,
		IsEnabled,
		SettingsControlSrc,
		LoginControlSrc,
		LogoffControlSrc,
		[CreatedByUserID],
		[CreatedOnDate],
		[LastModifiedByUserID],
		[LastModifiedOnDate]
	)
	VALUES (
		@PackageID,
		@AuthenticationType,
		@IsEnabled,
		@SettingsControlSrc,
		@LoginControlSrc,
		@LogoffControlSrc,
		@CreatedByUserID,
		getdate(),
		@CreatedByUserID,
		getdate()
	)

	SELECT SCOPE_IDENTITY()

