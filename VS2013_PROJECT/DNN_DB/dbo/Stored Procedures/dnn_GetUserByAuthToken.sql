CREATE PROCEDURE [dbo].[dnn_GetUserByAuthToken]

	@PortalId	int,
	@UserToken	nvarchar(1000),
	@AuthType	nvarchar(100)

AS
	SELECT u.* 
		FROM dbo.dnn_vw_Users u
			INNER JOIN dbo.dnn_UserAuthentication ua ON u.UserID = ua.UserID
	WHERE  ua.AuthenticationToken = @UserToken
		AND ua.AuthenticationType = @AuthType
		AND    (PortalId = @PortalId OR IsSuperUser = 1 OR @PortalId is null)

