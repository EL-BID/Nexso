CREATE PROCEDURE [dbo].[dnn_GetUnIndexedContentItems] 
AS
	SELECT *
	FROM dbo.dnn_ContentItems
	WHERE Indexed = 0

