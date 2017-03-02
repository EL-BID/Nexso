create procedure [dbo].[dnn_UpdateUrlTracking]

@PortalID     int,
@Url          nvarchar(255),
@LogActivity  bit,
@TrackClicks  bit,
@ModuleId     int,
@NewWindow    bit

as

update dbo.dnn_UrlTracking
set    LogActivity = @LogActivity,
       TrackClicks = @TrackClicks,
       NewWindow = @NewWindow
where  PortalID = @PortalID
and    Url = @Url
and    ((ModuleId = @ModuleId) or (ModuleId is null and @ModuleId is null))

