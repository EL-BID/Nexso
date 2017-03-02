create procedure [dbo].[dnn_GetHtmlTextUser]

@UserID int

as

select dnn_HtmlTextUsers.*,
       dnn_WorkflowStates.StateName
from   dbo.dnn_HtmlTextUsers
inner join dbo.dnn_WorkflowStates on dbo.dnn_HtmlTextUsers.StateID = dbo.dnn_WorkflowStates.StateID
where  dnn_HtmlTextUsers.UserID = @UserID
order by dnn_HtmlTextUsers.CreatedOnDate asc

