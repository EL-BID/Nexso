CREATE PROCEDURE [dbo].[dnn_GetContentWorkflowStatePermission]
	@WorkflowStatePermissionID	int
AS
    SELECT *
    FROM dbo.dnn_vw_ContentWorkflowStatePermissions
    WHERE WorkflowStatePermissionID = @WorkflowStatePermissionID

