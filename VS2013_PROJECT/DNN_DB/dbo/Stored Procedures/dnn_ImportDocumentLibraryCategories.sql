CREATE PROCEDURE [dbo].[dnn_ImportDocumentLibraryCategories]
	@VocabularyID 				int
AS
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.[dnn_dlfp_Category]') AND type in (N'U'))
	BEGIN
		INSERT INTO dbo.dnn_Taxonomy_Terms([Name],[VocabularyID])
		SELECT DISTINCT CategoryName,VID=@VocabularyID
		FROM         dbo.dnn_dlfp_Category where CategoryName NOT IN (SELECT [name] from dbo.dnn_Taxonomy_Terms)
	END

