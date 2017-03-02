CREATE PROCEDURE [dbo].[dnn_GetContentItemsByTabId] 
	@TabId int
AS
	SELECT * FROM dbo.dnn_ContentItems WHERE TabID = @TabId

