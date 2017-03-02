CREATE PROCEDURE [dbo].[dnn_AddSearchCommonWord]
	@CommonWord nvarchar(255),
	@Locale nvarchar(10)
AS

INSERT INTO dbo.dnn_SearchCommonWords (
	[CommonWord],
	[Locale]
) VALUES (
	@CommonWord,
	@Locale
)

select SCOPE_IDENTITY()

