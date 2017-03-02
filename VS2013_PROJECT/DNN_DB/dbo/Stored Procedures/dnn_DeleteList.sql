CREATE procedure [dbo].[dnn_DeleteList]
	@ListName nvarchar(50),
	@ParentKey nvarchar(150)

AS
DELETE 
	FROM dbo.dnn_vw_Lists
	WHERE ListName = @ListName
		AND ParentKey =@ParentKey

