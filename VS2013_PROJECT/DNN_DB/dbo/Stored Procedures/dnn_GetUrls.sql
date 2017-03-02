create procedure [dbo].[dnn_GetUrls]

@PortalID     int

as

select *
from   dbo.dnn_Urls
where  PortalID = @PortalID
order by Url

