CREATE PROCEDURE [dbo].[dnn_AddTermToContent] 
	@TermID			int,
	@ContentItemID	int
AS
	INSERT INTO dbo.dnn_ContentItems_Tags (
		TermID,
		ContentItemID
	)

	VALUES (
		@TermID,
		@ContentItemID
	)

	SELECT SCOPE_IDENTITY()

