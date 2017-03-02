create procedure [dbo].[dnn_DeleteSystemMessage]

@PortalID     int,
@MessageName  nvarchar(50)

as

delete
from   dbo.dnn_SystemMessages
where  PortalID = @PortalID
and    MessageName = @MessageName

