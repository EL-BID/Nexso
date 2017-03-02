CREATE PROCEDURE [dbo].[dnn_GetLanguagePackByPackage]

	@PackageID int

AS
	SELECT * FROM dbo.dnn_LanguagePacks 
        WHERE  PackageID = @PackageID

