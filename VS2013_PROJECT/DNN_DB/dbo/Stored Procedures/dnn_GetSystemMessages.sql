create procedure [dbo].[dnn_GetSystemMessages]

as

select MessageName
from   dbo.dnn_SystemMessages
where  PortalID is null

