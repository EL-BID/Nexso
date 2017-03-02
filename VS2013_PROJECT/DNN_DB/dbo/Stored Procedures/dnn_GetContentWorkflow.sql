CREATE PROCEDURE [dbo].[dnn_GetContentWorkflow]
@WorkflowID int
AS

SELECT 
  [WorkflowID],
  [PortalID],
  [WorkflowName],
  [Description],
  [IsDeleted],
  [StartAfterCreating],
  [StartAfterEditing],
  [DispositionEnabled]
FROM dbo.dnn_ContentWorkflows
WHERE WorkflowID = @WorkflowID

