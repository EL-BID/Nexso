CREATE PROCEDURE [dbo].[dnn_GetContentWorkflowUsageCount]
	@WorkflowId INT
AS
	SELECT COUNT(*)
	FROM dbo.[dnn_vw_ContentWorkflowUsage] wu 	
	WHERE wu.WorkflowID = @WorkflowId

