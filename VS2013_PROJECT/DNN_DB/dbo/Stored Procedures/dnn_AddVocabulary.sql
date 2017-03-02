CREATE PROCEDURE [dbo].[dnn_AddVocabulary] 
	@VocabularyTypeID	int,
	@Name				nvarchar(250),
	@Description		nvarchar(2500),
	@Weight				int,
	@ScopeID			int,
	@ScopeTypeID		int,
	@CreatedByUserID	int
AS
	INSERT INTO dbo.dnn_Taxonomy_Vocabularies (
		VocabularyTypeID,
		[Name],
		Description,
		Weight,
		ScopeID,
		ScopeTypeID,
		CreatedByUserID,
		CreatedOnDate,
		LastModifiedByUserID,
		LastModifiedOnDate
	)

	VALUES (
		@VocabularyTypeID,
		@Name,
		@Description,
		@Weight,
		@ScopeID,
		@ScopeTypeID,
		@CreatedByUserID,
		getdate(),
		@CreatedByUserID,
		getdate()
	)

	SELECT SCOPE_IDENTITY()

