CREATE PROCEDURE [dbo].[dnn_DeleteContentWorkflowLogs]
	@ContentItemID int,
	@WorkflowID int
AS
    DELETE FROM dbo.[dnn_ContentWorkflowLogs]
	WHERE ContentItemID = @ContentItemID AND WorkflowID = @WorkflowID

	SELECT @@ROWCOUNT

