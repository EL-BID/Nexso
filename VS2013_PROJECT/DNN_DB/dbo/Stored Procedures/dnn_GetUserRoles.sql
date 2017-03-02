CREATE PROCEDURE [dbo].[dnn_GetUserRoles]
	@PortalId  int,
	@UserId    int
AS
	SELECT *
		FROM dbo.dnn_vw_UserRoles
		WHERE UserID = @UserId AND PortalID = @PortalId

