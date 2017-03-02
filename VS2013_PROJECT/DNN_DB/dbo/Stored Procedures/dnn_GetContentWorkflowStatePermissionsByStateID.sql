CREATE PROCEDURE [dbo].[dnn_GetContentWorkflowStatePermissionsByStateID]
	@StateID int
AS
    SELECT *
    FROM dbo.dnn_vw_ContentWorkflowStatePermissions
	WHERE StateID = @StateID

