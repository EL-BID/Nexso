CREATE PROCEDURE [dbo].[dnn_UpdateLanguage]

	@LanguageID			    int,
	@CultureCode		    nvarchar(50),
	@CultureName            nvarchar(200),
	@FallbackCulture        nvarchar(50),
	@LastModifiedByUserID	int

AS
	UPDATE dbo.dnn_Languages
		SET
			CultureCode = @CultureCode,
			CultureName = @CultureName,
			FallbackCulture = @FallbackCulture,
			[LastModifiedByUserID] = @LastModifiedByUserID,	
			[LastModifiedOnDate] = getdate()
	WHERE LanguageID = @LanguageID

