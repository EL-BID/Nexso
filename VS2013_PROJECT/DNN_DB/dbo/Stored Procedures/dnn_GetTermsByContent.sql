CREATE PROCEDURE [dbo].[dnn_GetTermsByContent] 
	@ContentItemID			int
AS
	SELECT TT.*
	FROM dbo.dnn_ContentItems_Tags TG
		INNER JOIN dbo.dnn_Taxonomy_Terms TT ON TG.TermID = TT.TermID
	WHERE TG.ContentItemID = @ContentItemID

