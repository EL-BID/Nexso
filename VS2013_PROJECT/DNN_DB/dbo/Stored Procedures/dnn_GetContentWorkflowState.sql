CREATE PROCEDURE [dbo].[dnn_GetContentWorkflowState]
	@StateID int
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
    WHERE StateID = @StateID

