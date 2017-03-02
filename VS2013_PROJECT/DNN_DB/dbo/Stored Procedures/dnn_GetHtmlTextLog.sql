create procedure [dbo].[dnn_GetHtmlTextLog]

@ItemID int

as

select dnn_HtmlTextLog.ItemID,
       dnn_HtmlTextLog.StateID,
       dnn_WorkflowStates.StateName,
       dnn_HtmlTextLog.Comment,
       dnn_HtmlTextLog.Approved,
       dnn_HtmlTextLog.CreatedByUserID,
       dnn_Users.DisplayName,
       dnn_HtmlTextLog.CreatedOnDate
from dbo.dnn_HtmlTextLog
inner join dbo.dnn_WorkflowStates on dbo.dnn_HtmlTextLog.StateID = dbo.dnn_WorkflowStates.StateID
left outer join dbo.dnn_Users on dbo.dnn_HtmlTextLog.CreatedByUserID = dbo.dnn_Users.UserID
where ItemID = @ItemID
order by dnn_HtmlTextLog.CreatedOnDate desc

