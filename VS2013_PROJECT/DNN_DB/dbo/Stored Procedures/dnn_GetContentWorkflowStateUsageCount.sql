CREATE PROCEDURE [dbo].[dnn_GetContentWorkflowStateUsageCount]
	@StateId INT
AS
	SELECT COUNT(ci.ContentItemID)
	FROM dbo.[dnn_ContentItems] ci 
	WHERE ci.StateId = @StateId

