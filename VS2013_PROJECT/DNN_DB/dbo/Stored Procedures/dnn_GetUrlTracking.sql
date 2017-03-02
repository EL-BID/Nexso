create procedure [dbo].[dnn_GetUrlTracking]

@PortalID     int,
@Url          nvarchar(255),
@ModuleId     int

as

select *
from   dbo.dnn_UrlTracking
where  PortalID = @PortalID
and    Url = @Url
and    ((ModuleId = @ModuleId) or (ModuleId is null and @ModuleId is null))

