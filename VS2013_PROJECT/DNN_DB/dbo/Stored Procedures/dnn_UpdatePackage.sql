CREATE PROCEDURE [dbo].[dnn_UpdatePackage]
	@PackageID			int,
	@PortalID			int,
	@FriendlyName	    nvarchar(250),
	@Description	    nvarchar(2000),
	@PackageType	    nvarchar(50),
	@Version		    nvarchar(50),
	@License		    ntext,
	@Manifest		    ntext,
	@Owner				nvarchar(100),
	@Organization		nvarchar(100),
	@Url				nvarchar(250),
	@Email				nvarchar(100),
	@ReleaseNotes	    ntext,
	@IsSystemPackage    bit,
	@LastModifiedByUserID	int,
	@FolderName			nvarchar(128),
	@IconFile			nvarchar(100)
AS
	UPDATE dbo.dnn_Packages
		SET	
			PortalID = @PortalID,
			FriendlyName = @FriendlyName,
			[Description] = @Description,
			PackageType = @PackageType,
			Version = @Version,
			License = @License,
			Manifest = @Manifest,
			[Owner] = @Owner,
			Organization = @Organization,
			Url = @Url,
			Email = @Email,
			ReleaseNotes = @ReleaseNotes,
			IsSystemPackage = @IsSystemPackage,
			[LastModifiedByUserID] = @LastModifiedByUserID,	[LastModifiedOnDate] = getdate(),
			FolderName = @FolderName,
			IconFile = @IconFile
		WHERE  PackageID = @PackageID

