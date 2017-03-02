CREATE PROCEDURE [dbo].[dnn_GetContentItemsByVocabularyId] 
	@VocabularyID int
AS
BEGIN
	SELECT c.*
	FROM dbo.dnn_ContentItems As c
		INNER JOIN dbo.dnn_ContentItems_Tags ct ON ct.ContentItemID = c.ContentItemID
		INNER JOIN dbo.dnn_Taxonomy_Terms t ON t.TermID = ct.TermID
	WHERE t.VocabularyID = @VocabularyID
END

