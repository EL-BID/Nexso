CREATE PROCEDURE [dbo].[dnn_UpdateAnonymousUser]
    @UserID  char(36),
    @PortalID  int,
    @TabID   int,
    @LastActiveDate datetime 
as
begin
 update dbo.dnn_AnonymousUsers set 
  TabID = @TabID,
  LastActiveDate = @LastActiveDate
 where
  UserID = @UserID
  and PortalID = @PortalID

 if @@ROWCOUNT = 0
 begin
  insert into dbo.dnn_AnonymousUsers
   (UserID, PortalID, TabID, CreationDate, LastActiveDate) 
  VALUES
   (@UserID, @PortalID, @TabID, GetDate(), @LastActiveDate)
 end
end

