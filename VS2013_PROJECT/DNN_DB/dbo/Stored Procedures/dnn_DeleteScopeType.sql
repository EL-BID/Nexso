CREATE PROCEDURE [dbo].[dnn_DeleteScopeType] 
	@ScopeTypeId			int
AS
	DELETE FROM dbo.dnn_Taxonomy_ScopeTypes
	WHERE ScopeTypeId = @ScopeTypeId

