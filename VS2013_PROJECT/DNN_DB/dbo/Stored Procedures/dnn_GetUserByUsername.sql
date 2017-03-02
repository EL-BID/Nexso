CREATE PROCEDURE [dbo].[dnn_GetUserByUsername]

	@PortalID int,
	@Username nvarchar(100)

AS
	SELECT * FROM dbo.dnn_vw_Users
	WHERE  Username = @Username
		AND  ((@PortalId IS NULL) OR (PortalId = @PortalID) OR IsSuperUser = 1)

