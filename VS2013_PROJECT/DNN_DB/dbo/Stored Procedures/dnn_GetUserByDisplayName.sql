CREATE PROCEDURE [dbo].[dnn_GetUserByDisplayName]

	@PortalID int,
	@DisplayName nvarchar(128)

AS
	SELECT * FROM dbo.dnn_vw_Users
	WHERE  DisplayName = @DisplayName
		AND  ((@PortalId IS NULL) OR (PortalId = @PortalID) OR IsSuperUser = 1)

