create procedure [dbo].[dnn_UpdateSystemMessage]

@PortalID     int,
@MessageName  nvarchar(50),
@MessageValue ntext

as

update dbo.dnn_SystemMessages
set    MessageValue = @MessageValue
where  ((PortalID = @PortalID) or (PortalID is null and @PortalID is null))
and    MessageName = @MessageName

