CREATE PROCEDURE [dbo].[dnn_UpdateModulePermission]
    @ModulePermissionId     Int, -- not null!
    @PortalId               Int, -- not null!
    @ModuleId               Int, -- not null!
    @PermissionId           Int, -- not null!
    @RoleId                 Int, -- might be negative for virtual roles
    @AllowAccess            Bit, -- false: deny, true: grant
    @UserId                 Int, -- -1 is replaced by Null
    @LastModifiedByUserId   Int  -- -1 is replaced by Null
AS
    UPDATE dbo.[dnn_ModulePermission] SET
        [ModuleId]             = @ModuleId,
        [PortalId]             = @PortalId,
        [PermissionId]         = @PermissionId,
        [RoleId]               = @RoleId,
        [AllowAccess]          = @AllowAccess,
        [UserId]               = CASE WHEN @UserId = -1 THEN Null ELSE @UserId  END,
        [LastModifiedByUserId] = CASE WHEN @LastModifiedByUserId = -1 THEN Null ELSE @LastModifiedByUserId  END,
        [LastModifiedOnDate]   = GetDate()
    WHERE
        [ModulePermissionID]   = @ModulePermissionID

