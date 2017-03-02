CREATE PROCEDURE [dbo].[dnn_GetSystemMessage]
 @PortalID     int,
 @MessageName  nvarchar(50)
AS
BEGIN
 if @PortalID is null
 begin
  select MessageValue
  from   dbo.dnn_SystemMessages
  where  PortalID is null and MessageName = @MessageName
 end else begin
  select MessageValue
  from   dbo.dnn_SystemMessages
  where  PortalID = @PortalID and MessageName = @MessageName
 end
END

