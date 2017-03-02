create procedure [dbo].[dnn_GetWorkflows]
	@PortalID int
as
	select *
	from   dbo.dnn_Workflow
	where (PortalID = @PortalID or PortalID is null)
	order by WorkflowName

