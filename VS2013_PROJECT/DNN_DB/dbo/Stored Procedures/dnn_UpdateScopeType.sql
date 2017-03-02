CREATE PROCEDURE [dbo].[dnn_UpdateScopeType] 
	@ScopeTypeId				int,
	@ScopeType					nvarchar(250)
AS
	UPDATE dbo.dnn_Taxonomy_ScopeTypes 
		SET 
			ScopeType = @ScopeType
	WHERE ScopeTypeId = @ScopeTypeId

