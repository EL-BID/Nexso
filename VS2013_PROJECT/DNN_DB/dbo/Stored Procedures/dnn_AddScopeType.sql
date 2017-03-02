CREATE PROCEDURE [dbo].[dnn_AddScopeType] 
	@ScopeType			nvarchar(250)
AS
	INSERT INTO dbo.dnn_Taxonomy_ScopeTypes (
		ScopeType
	)

	VALUES (
		@ScopeType
	)

	SELECT SCOPE_IDENTITY()

