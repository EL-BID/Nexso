CREATE PROCEDURE [dbo].[dnn_RemoveTermsFromContent] 
	@ContentItemID	int
AS
	DELETE dbo.dnn_ContentItems_Tags 
	WHERE ContentItemID = @ContentItemID

