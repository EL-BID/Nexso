CREATE PROCEDURE [dbo].[dnn_GetRoleGroups]
	@PortalID		int
AS
	SELECT *
		FROM dbo.dnn_RoleGroups
		WHERE  PortalId = @PortalID
		ORDER BY RoleGroupName

