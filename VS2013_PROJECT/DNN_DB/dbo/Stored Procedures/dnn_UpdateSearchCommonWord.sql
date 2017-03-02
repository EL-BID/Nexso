CREATE PROCEDURE [dbo].[dnn_UpdateSearchCommonWord]
	@CommonWordID int, 
	@CommonWord nvarchar(255), 
	@Locale nvarchar(10) 
AS

UPDATE dbo.dnn_SearchCommonWords SET
	[CommonWord] = @CommonWord,
	[Locale] = @Locale
WHERE
	[CommonWordID] = @CommonWordID

