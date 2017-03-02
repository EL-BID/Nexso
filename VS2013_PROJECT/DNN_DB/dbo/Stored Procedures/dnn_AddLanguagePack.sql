CREATE PROCEDURE [dbo].[dnn_AddLanguagePack]

	@PackageID			    int,
	@LanguageID			    int,
	@DependentPackageID		int,
	@CreatedByUserID	int

AS
	INSERT INTO dbo.dnn_LanguagePacks (
		PackageID,
		LanguageID,
		DependentPackageID,
		[CreatedByUserID],
		[CreatedOnDate],
		[LastModifiedByUserID],
		[LastModifiedOnDate]

	)
	VALUES (
		@PackageID,
		@LanguageID,
		@DependentPackageID,
		@CreatedByUserID,
	  	getdate(),
	  	@CreatedByUserID,
	  	getdate()
	)
	SELECT SCOPE_IDENTITY()

