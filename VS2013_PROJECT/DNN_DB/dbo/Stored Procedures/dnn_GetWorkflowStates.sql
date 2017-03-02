create procedure [dbo].[dnn_GetWorkflowStates]
	@WorkflowID int

as

select *
from   dbo.dnn_WorkflowStates
inner join dbo.dnn_Workflow on dbo.dnn_WorkflowStates.WorkflowID = dbo.dnn_Workflow.WorkflowID
where dbo.dnn_WorkflowStates.WorkflowID = @WorkflowID
order by [Order]

