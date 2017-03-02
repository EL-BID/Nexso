CREATE PROCEDURE [dbo].[dnn_GetTermsByVocabulary] 
	@VocabularyID			int
AS
	SELECT TT.*
	FROM dbo.dnn_Taxonomy_Terms TT
	WHERE VocabularyID = @VocabularyID
	ORDER BY TT.TermLeft Asc, TT.Weight Asc, TT.Name Asc

