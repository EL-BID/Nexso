CREATE PROCEDURE [dbo].[dnn_GetContentWorkflows]
	@PortalID int
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
WHERE (PortalID = @PortalID OR PortalID IS null)

