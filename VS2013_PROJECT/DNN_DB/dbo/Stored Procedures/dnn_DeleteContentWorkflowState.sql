CREATE PROCEDURE [dbo].[dnn_DeleteContentWorkflowState]
	@StateID int
AS
    DELETE FROM dbo.dnn_ContentWorkflowStates
    WHERE StateID = @StateID

