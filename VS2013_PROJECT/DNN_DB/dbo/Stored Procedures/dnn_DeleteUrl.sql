create procedure [dbo].[dnn_DeleteUrl]

@PortalID     int,
@Url          nvarchar(255)

as

delete
from   dbo.dnn_Urls
where  PortalID = @PortalID
and    Url = @Url

