create procedure [dbo].[dnn_DeleteUserRole]

@UserID int,
@RoleId int

as

delete
from dbo.dnn_UserRoles
where  UserId = @UserID
and    RoleId = @RoleId

