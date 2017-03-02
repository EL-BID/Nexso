CREATE PROCEDURE [dbo].[dnn_DeleteContentWorkflowStatePermission]
	@WorkflowStatePermissionID int
AS
    DELETE FROM dbo.dnn_ContentWorkflowStatePermission
    WHERE WorkflowStatePermissionID = @WorkflowStatePermissionID

