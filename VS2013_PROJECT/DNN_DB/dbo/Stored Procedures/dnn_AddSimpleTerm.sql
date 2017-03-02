CREATE PROCEDURE [dbo].[dnn_AddSimpleTerm] 
	@VocabularyID		int,
	@Name				nvarchar(250),
	@Description		nvarchar(2500),
	@Weight				int,
	@CreatedByUserID	int
AS
	INSERT INTO dbo.dnn_Taxonomy_Terms (
		VocabularyID,
		[Name],
		Description,
		Weight,
		CreatedByUserID,
		CreatedOnDate,
		LastModifiedByUserID,
		LastModifiedOnDate
	)

	VALUES (
		@VocabularyID,
		@Name,
		@Description,
		@Weight,
		@CreatedByUserID,
		getdate(),
		@CreatedByUserID,
		getdate()
	)

	SELECT SCOPE_IDENTITY()

