CREATE PROCEDURE [dbo].[dnn_DeleteRoleGroup]

	@RoleGroupId      int
	
AS

DELETE  
FROM dbo.dnn_RoleGroups
WHERE  RoleGroupId = @RoleGroupId

