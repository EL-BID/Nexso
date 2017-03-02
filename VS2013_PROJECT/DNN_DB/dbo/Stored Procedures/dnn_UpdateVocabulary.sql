CREATE PROCEDURE [dbo].[dnn_UpdateVocabulary] 
	@VocabularyID			int,
	@VocabularyTypeID		int,
	@Name					nvarchar(250),
	@Description			nvarchar(2500),
	@Weight					int,
	@ScopeID				int,
	@ScopeTypeID			int,
	@LastModifiedByUserID	int
AS
	UPDATE dbo.dnn_Taxonomy_Vocabularies
		SET 
			VocabularyTypeID = @VocabularyTypeID,
			[Name] = @Name,
			Description = @Description,
			Weight = @Weight,
			ScopeID = @ScopeID,
			ScopeTypeID = @ScopeTypeID,
			LastModifiedByUserID = @LastModifiedByUserID,
			LastModifiedOnDate = getdate()
	WHERE VocabularyId = @VocabularyId

