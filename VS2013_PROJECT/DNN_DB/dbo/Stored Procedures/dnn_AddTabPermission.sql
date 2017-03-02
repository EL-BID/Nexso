CREATE PROCEDURE [dbo].[dnn_AddTabPermission]
    @TabID              Int, -- not null!
    @PermissionId       Int, -- not null!
    @RoleId             Int, -- might be negative for virtual roles
    @AllowAccess        Bit, -- false: deny, true: grant
    @UserId             Int, -- -1 is replaced by Null
    @CreatedByUserId    Int  -- -1 is replaced by Null
AS
BEGIN
    INSERT INTO dbo.[dnn_TabPermission] (
        [TabID],
        [PermissionID],
        [RoleId],
        [AllowAccess],
        [UserId],
        [CreatedByUserId],
        [CreatedOnDate],
        [LastModifiedByUserId],
        [LastModifiedOnDate]
    ) VALUES (
        @TabID,
        @PermissionID,
        @RoleId,
        @AllowAccess,
        CASE WHEN @UserId = -1 THEN Null ELSE @UserId END,
        CASE WHEN @CreatedByUserID = -1 THEN Null ELSE @CreatedByUserID END,
        GetDate(),
        CASE WHEN @CreatedByUserID = -1 THEN Null ELSE @CreatedByUserID END,
        GetDate()
    )
    SELECT SCOPE_IDENTITY()
END

