create procedure [dbo].[dnn_GetUrl]

@PortalID     int,
@Url          nvarchar(255)

as

select *
from   dbo.dnn_Urls
where  PortalID = @PortalID
and    Url = @Url

