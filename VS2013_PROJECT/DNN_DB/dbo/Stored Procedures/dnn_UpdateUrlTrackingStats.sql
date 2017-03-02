create procedure [dbo].[dnn_UpdateUrlTrackingStats]

@PortalID     int,
@Url          nvarchar(255),
@ModuleId     int

as

update dbo.dnn_UrlTracking
set    Clicks = Clicks + 1,
       LastClick = getdate()
where  PortalID = @PortalID
and    Url = @Url
and    ((ModuleId = @ModuleId) or (ModuleId is null and @ModuleId is null))

