CREATE PROCEDURE [dbo].[dnn_GetRoleGroup]
	@PortalID		int,
	@RoleGroupId    int
AS
	SELECT *
		FROM dbo.dnn_RoleGroups
		WHERE  (RoleGroupId = @RoleGroupId OR RoleGroupId IS NULL AND @RoleGroupId IS NULL)
			AND    PortalId = @PortalID

