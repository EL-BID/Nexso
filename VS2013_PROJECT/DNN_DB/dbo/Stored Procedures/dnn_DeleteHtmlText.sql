create procedure [dbo].[dnn_DeleteHtmlText]

@ModuleID int,
@ItemID int

as

delete
from   dbo.dnn_HtmlText
where  ModuleID = @ModuleID
and ItemID = @ItemID

