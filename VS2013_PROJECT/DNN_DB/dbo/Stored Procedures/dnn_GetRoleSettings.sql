CREATE PROCEDURE [dbo].[dnn_GetRoleSettings]
	@RoleId     int

AS
	SELECT *
	FROM dbo.dnn_RoleSettings
	WHERE  RoleID = @RoleId

