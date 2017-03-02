CREATE PROCEDURE [dbo].[dnn_DeleteVocabulary] 
	@VocabularyID			int
AS
	DELETE FROM dbo.dnn_Taxonomy_Vocabularies
	WHERE VocabularyID = @VocabularyID

