create procedure [dbo].[dnn_DeleteHtmlTextUsers]

as

delete
from   dnn_HtmlTextUsers
where  HtmlTextUserID in 
  ( select HtmlTextUserID
    from   dnn_HtmlTextUsers
    inner join dbo.dnn_HtmlText on dbo.dnn_HtmlTextUsers.ItemID = dbo.dnn_HtmlText.ItemID
    where dnn_HtmlTextUsers.ItemID = dnn_HtmlText.ItemID
    and dnn_HtmlTextUsers.StateID <> dnn_HtmlText.StateID )

