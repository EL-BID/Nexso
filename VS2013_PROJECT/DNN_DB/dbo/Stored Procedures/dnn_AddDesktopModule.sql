CREATE PROCEDURE [dbo].[dnn_AddDesktopModule]
	@PackageID		int,
	@ModuleName		nvarchar(128),
	@FolderName		nvarchar(128),
	@FriendlyName		nvarchar(128),
	@Description		nvarchar(2000),
	@Version		nvarchar(8),
	@IsPremium		bit,
	@IsAdmin		bit,
	@BusinessController	nvarchar(200),
	@SupportedFeatures	int,
	@Shareable		int,
	@CompatibleVersions	nvarchar(500),
	@Dependencies		nvarchar(400),
	@Permissions		nvarchar(400),
	@ContentItemId		int,
	@CreatedByUserID	int

AS
	INSERT INTO dbo.dnn_DesktopModules (
		PackageID,
		ModuleName,
		FolderName,
		FriendlyName,
		Description,
		Version,
		IsPremium,
		IsAdmin,
		BusinessControllerClass,
		SupportedFeatures,
		Shareable,
		CompatibleVersions,
		Dependencies,
		Permissions,
		CreatedByUserID,
		CreatedOnDate,
		LastModifiedByUserID,
		LastModifiedOnDate,
		ContentItemId
	)
	VALUES (
		@PackageID,
		@ModuleName,
		@FolderName,
		@FriendlyName,
		@Description,
		@Version,
		@IsPremium,
		@IsAdmin,
		@BusinessController,
		@SupportedFeatures,
		@Shareable,
		@CompatibleVersions,
		@Dependencies,
		@Permissions,
		@CreatedByUserID,
		getdate(),
		@CreatedByUserID,
		getdate(),
		@ContentItemId
	)

	SELECT SCOPE_IDENTITY()

