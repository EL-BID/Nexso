CREATE PROCEDURE [dbo].[dnn_UpdateSimpleTerm] 
	@TermID					int,
	@VocabularyID			int,
	@Name					nvarchar(250),
	@Description			nvarchar(2500),
	@Weight					int,
	@LastModifiedByUserID	int
AS
	UPDATE dbo.dnn_Taxonomy_Terms
		SET 
			VocabularyID = @VocabularyID,
			[Name] = @Name,
			Description = @Description,
			Weight = @Weight,
			LastModifiedByUserID = @LastModifiedByUserID,
			LastModifiedOnDate = getdate()
	WHERE TermID = @TermID

