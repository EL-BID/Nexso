CREATE PROCEDURE [dbo].[dnn_GetUserByVanityUrl]

	@PortalID int,
	@VanityUrl nvarchar(100)

AS
	SELECT * FROM dbo.dnn_vw_Users
	WHERE  VanityUrl = @VanityUrl
		AND  ((@PortalId IS NULL) OR (PortalId = @PortalID) OR IsSuperUser = 1)

