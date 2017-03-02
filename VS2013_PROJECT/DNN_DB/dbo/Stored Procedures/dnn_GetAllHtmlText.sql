create procedure [dbo].[dnn_GetAllHtmlText]

@ModuleID int

as

select dbo.dnn_HtmlText.*,
       dbo.dnn_WorkflowStates.*,
       dbo.dnn_Workflow.WorkflowName,
       dbo.dnn_Users.DisplayName,
       dbo.dnn_Modules.PortalID
from   dbo.dnn_HtmlText
inner join dbo.dnn_Modules on dbo.dnn_Modules.ModuleID = dbo.dnn_HtmlText.ModuleID
inner join dbo.dnn_WorkflowStates on dbo.dnn_WorkflowStates.StateID = dbo.dnn_HtmlText.StateID
inner join dbo.dnn_Workflow on dbo.dnn_WorkflowStates.WorkflowID = dbo.dnn_Workflow.WorkflowID
left outer join dbo.dnn_Users on dbo.dnn_HtmlText.LastModifiedByUserID = dbo.dnn_Users.UserID
where  dbo.dnn_HtmlText.ModuleID = @ModuleID
order by dbo.dnn_HtmlText.LastModifiedOnDate desc

