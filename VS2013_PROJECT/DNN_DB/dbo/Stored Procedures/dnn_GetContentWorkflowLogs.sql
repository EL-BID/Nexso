CREATE PROCEDURE [dbo].[dnn_GetContentWorkflowLogs]
	@ContentItemID int,
	@WorkflowID int
AS
    SELECT *
	FROM dbo.[dnn_ContentWorkflowLogs]
	WHERE ContentItemID = @ContentItemID AND WorkflowID = @WorkflowID

