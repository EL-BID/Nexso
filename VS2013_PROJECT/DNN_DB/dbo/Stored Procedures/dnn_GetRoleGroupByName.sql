CREATE PROCEDURE [dbo].[dnn_GetRoleGroupByName]
	@PortalID		int,
	@RoleGroupName	nvarchar(50)
AS
	SELECT *
		FROM dbo.dnn_RoleGroups
		WHERE  PortalId = @PortalID 
			AND RoleGroupName = @RoleGroupName

