CREATE PROCEDURE [dbo].[dnn_GetSearchCommonWordsByLocale]
	@Locale nvarchar(10)
	
AS

SELECT
	[CommonWordID],
	[CommonWord],
	[Locale]
FROM
	dbo.dnn_SearchCommonWords
WHERE
	[Locale] = @Locale

