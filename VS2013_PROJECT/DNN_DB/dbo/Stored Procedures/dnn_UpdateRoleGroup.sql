CREATE PROCEDURE [dbo].[dnn_UpdateRoleGroup] 
	@RoleGroupId		int,
	@RoleGroupName		nvarchar(50),
	@Description		nvarchar(1000),
	@LastModifiedUserID int
AS

	UPDATE dbo.dnn_RoleGroups
	SET    RoleGroupName		= @RoleGroupName,
		   Description			= @Description,
		   LastModifiedByUserID = @LastModifiedUserID,
		   LastModifiedOnDate		= getdate()
	WHERE  RoleGroupId = @RoleGroupId

