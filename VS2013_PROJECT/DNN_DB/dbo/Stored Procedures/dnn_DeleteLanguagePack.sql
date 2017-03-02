CREATE PROCEDURE [dbo].[dnn_DeleteLanguagePack]

	@LanguagePackID		int

AS
    DELETE
	    FROM	dbo.dnn_LanguagePacks
	    WHERE   LanguagePackID = @LanguagePackID

