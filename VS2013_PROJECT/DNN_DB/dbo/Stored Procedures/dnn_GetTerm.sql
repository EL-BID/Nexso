CREATE PROCEDURE [dbo].[dnn_GetTerm] 
	@TermId			int
AS
	SELECT TT.*,
		(SELECT    COUNT(CI.ContentItemID)
			  FROM      dbo.[dnn_ContentItems_Tags] T
			  INNER JOIN dbo.[dnn_ContentItems] CI ON CI.ContentItemID = T.ContentItemID
			  WHERE     T.TermID = TT.TermID
			) AS TotalTermUsage ,
		(SELECT    COUNT(CI.ContentItemID)
			  FROM      dbo.[dnn_ContentItems_Tags] T
			  INNER JOIN dbo.[dnn_ContentItems] CI ON CI.ContentItemID = T.ContentItemID
			  WHERE     T.TermID = TT.TermID
			  AND	    CI.CreatedOnDate > DATEADD(day, -30, GETDATE())
		) AS MonthTermUsage ,
		(SELECT    COUNT(CI.ContentItemID)
			  FROM      dbo.[dnn_ContentItems_Tags] T
			  INNER JOIN dbo.[dnn_ContentItems] CI ON CI.ContentItemID = T.ContentItemID
			  WHERE     T.TermID = TT.TermID
			  AND	    CI.CreatedOnDate > DATEADD(day, -7, GETDATE())
		) AS WeekTermUsage ,
		(SELECT    COUNT(CI.ContentItemID)
			  FROM      dbo.[dnn_ContentItems_Tags] T
			  INNER JOIN dbo.[dnn_ContentItems] CI ON CI.ContentItemID = T.ContentItemID
			  WHERE     T.TermID = TT.TermID
			  AND	    CI.CreatedOnDate > DATEADD(day, -1, GETDATE())
		) AS DayTermUsage
	FROM dbo.dnn_Taxonomy_Terms TT
	WHERE TT.TermId = @TermId

