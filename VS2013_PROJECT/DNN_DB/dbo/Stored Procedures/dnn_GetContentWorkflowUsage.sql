CREATE PROCEDURE [dbo].[dnn_GetContentWorkflowUsage]
	@WorkflowId INT,
	@PageIndex INT,
	@PageSize INT
AS
	DECLARE @StartIndex INT = ((@PageIndex - 1) * @PageSize) + 1
	DECLARE @EndIndex INT = (@PageIndex * @PageSize)
	
	;WITH ContenResourcesSet AS
    (
		SELECT wu.*, ROW_NUMBER() OVER (Order BY wu.ContentType, wu.ContentName) AS [Index]
		FROM dbo.[dnn_vw_ContentWorkflowUsage] wu 		
		WHERE wu.WorkflowID = @WorkflowId
    )
   SELECT * FROM ContenResourcesSet WHERE [Index] BETWEEN @StartIndex AND @EndIndex

