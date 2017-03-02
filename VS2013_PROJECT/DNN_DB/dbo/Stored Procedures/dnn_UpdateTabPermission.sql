CREATE PROCEDURE [dbo].[dnn_UpdateTabPermission]
    @TabPermissionId        Int, -- not null!
    @TabId                  Int, -- not null!
    @PermissionId           Int, -- not null!
    @RoleId                 Int, -- might be negative for virtual roles
    @AllowAccess            Bit, -- false: deny, true: grant
    @UserId                 Int, -- -1 is replaced by Null
    @LastModifiedByUserId   Int  -- -1 is replaced by Null
AS
    UPDATE dbo.[dnn_TabPermission] SET
        [TabID]                = @TabId,
        [PermissionID]         = @PermissionId,
        [RoleID]               = @RoleId,
        [AllowAccess]          = @AllowAccess,
        [UserID]               = CASE WHEN @UserId = -1 THEN Null ELSE @UserId  END,
        [LastModifiedByUserId] = CASE WHEN @LastModifiedByUserId = -1 THEN Null ELSE @LastModifiedByUserId  END,
        [LastModifiedOnDate]   = GetDate()
    WHERE
        [TabPermissionID]      = @TabPermissionId

