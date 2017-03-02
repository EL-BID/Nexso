CREATE PROCEDURE [dbo].[dnn_GetUser]

	@PortalID int,
	@UserID int

AS
SELECT * FROM dbo.dnn_vw_Users U
WHERE  UserId = @UserID
	AND    (PortalId = @PortalID or IsSuperUser = 1)

