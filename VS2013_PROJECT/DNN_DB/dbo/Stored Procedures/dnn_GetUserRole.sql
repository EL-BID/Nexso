CREATE PROCEDURE [dbo].[dnn_GetUserRole]

	@PortalID int, 
	@UserID int, 
	@RoleId int

AS
	SELECT	*
	    FROM	dbo.dnn_vw_UserRoles
	    WHERE   UserId = @UserID
		    AND  PortalId = @PortalID
		    AND  RoleId = @RoleId

