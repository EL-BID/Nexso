CREATE PROCEDURE [dbo].[dnn_GetListEntry]

	@ListName nvarchar(50),
	@Value nvarchar(200),
	@EntryID int

AS
	SELECT *
	FROM dbo.dnn_vw_Lists
	WHERE ([ListName] = @ListName OR @ListName='')
		AND ([EntryID]=@EntryID OR @EntryID = -1)
		AND ([Value]=@Value OR @Value = '')

