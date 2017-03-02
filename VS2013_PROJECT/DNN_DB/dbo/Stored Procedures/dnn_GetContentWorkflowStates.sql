CREATE PROCEDURE [dbo].[dnn_GetContentWorkflowStates]
	@WorkflowID int
AS
    SELECT 
		[StateID],
		[WorkflowID],
		[StateName],
		[Order],
		[IsActive],
		[SendEmail],
		[SendMessage],
		[IsDisposalState],
		[OnCompleteMessageSubject],
		[OnCompleteMessageBody],
		[OnDiscardMessageSubject],
		[OnDiscardMessageBody]
	FROM dbo.dnn_ContentWorkflowStates
    WHERE WorkflowID = @WorkflowID

