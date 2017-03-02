CREATE PROCEDURE [dbo].[dnn_GetTermUsage] 
	@TermId int
AS
	SELECT
		(SELECT    COUNT(CI.ContentItemID)
			  FROM      dbo.[dnn_ContentItems_Tags] T
			  INNER JOIN dbo.[dnn_ContentItems] CI ON CI.ContentItemID = T.ContentItemID
			  WHERE     T.TermID = @TermId
			) AS TotalTermUsage ,
		(SELECT    COUNT(CI.ContentItemID)
			  FROM      dbo.[dnn_ContentItems_Tags] T
			  INNER JOIN dbo.[dnn_ContentItems] CI ON CI.ContentItemID = T.ContentItemID
			  WHERE     T.TermID = @TermId
			  AND	    CI.CreatedOnDate > DATEADD(day, -30, GETDATE())
		) AS MonthTermUsage ,
		(SELECT    COUNT(CI.ContentItemID)
			  FROM      dbo.[dnn_ContentItems_Tags] T
			  INNER JOIN dbo.[dnn_ContentItems] CI ON CI.ContentItemID = T.ContentItemID
			  WHERE     T.TermID = @TermId
			  AND	    CI.CreatedOnDate > DATEADD(day, -7, GETDATE())
		) AS WeekTermUsage ,
		(SELECT    COUNT(CI.ContentItemID)
			  FROM      dbo.[dnn_ContentItems_Tags] T
			  INNER JOIN dbo.[dnn_ContentItems] CI ON CI.ContentItemID = T.ContentItemID
			  WHERE     T.TermID = @TermId
			  AND	    CI.CreatedOnDate > DATEADD(day, -1, GETDATE())
		) AS DayTermUsage
	FROM dbo.dnn_Taxonomy_Terms TT
	WHERE TermID = @TermId

