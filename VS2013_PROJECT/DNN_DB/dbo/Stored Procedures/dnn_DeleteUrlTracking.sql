create procedure [dbo].[dnn_DeleteUrlTracking]

@PortalID     int,
@Url          nvarchar(255),
@ModuleID     int

as

delete
from   dbo.dnn_UrlTracking
where  PortalID = @PortalID
and    Url = @Url
and    ((ModuleId = @ModuleId) or (ModuleId is null and @ModuleId is null))

