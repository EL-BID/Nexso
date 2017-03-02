CREATE PROCEDURE [dbo].[dnn_GetContentWorkflowSource]
	@WorkflowID INT,
    @SourceName NVARCHAR(20)
AS
    SELECT 
		[SourceID],
		[WorkflowID],
		[SourceName],
		[SourceType]
	FROM dbo.dnn_ContentWorkflowSources
    WHERE WorkflowID = @WorkflowID AND SourceName = @SourceName

