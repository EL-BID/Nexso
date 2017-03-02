create procedure [dbo].[dnn_GetProfile]

@UserID    int, 
@PortalID  int

as

select *
from   dbo.dnn_Profile
where  UserId = @UserID 
and    PortalId = @PortalID

