create procedure [dbo].[dnn_AddSystemMessage]

@PortalID     int,
@MessageName  nvarchar(50),
@MessageValue ntext

as

insert into dbo.dnn_SystemMessages (
  PortalID,
  MessageName,
  MessageValue
)
values (
  @PortalID,
  @MessageName,
  @MessageValue
)

