CREATE PROCEDURE [dbo].[dnn_UpdateLanguagePack]
	@LanguagePackID			int,
	@PackageID			    int,
	@LanguageID			    int,
	@DependentPackageID		int,
	@LastModifiedByUserID	int

AS
	UPDATE dbo.dnn_LanguagePacks
		SET
			PackageID = @PackageID,
			LanguageID = @LanguageID,
			DependentPackageID = @DependentPackageID,
			[LastModifiedByUserID] = @LastModifiedByUserID,	
			[LastModifiedOnDate] = GETDATE()
	WHERE LanguagePackID = @LanguagePackID

	SELECT @LanguagePackID

