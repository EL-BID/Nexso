create procedure [dbo].[dnn_IsUserInRole]
    
@UserID        int,
@RoleId        int,
@PortalID      int

as

select dbo.dnn_UserRoles.UserId,
       dbo.dnn_UserRoles.RoleId
from dbo.dnn_UserRoles
inner join dbo.dnn_Roles on dbo.dnn_UserRoles.RoleId = dbo.dnn_Roles.RoleId
where  dbo.dnn_UserRoles.UserId = @UserID
and    dbo.dnn_UserRoles.RoleId = @RoleId
and    dbo.dnn_Roles.PortalId = @PortalID
and    (dbo.dnn_UserRoles.ExpiryDate >= getdate() or dbo.dnn_UserRoles.ExpiryDate is null)

