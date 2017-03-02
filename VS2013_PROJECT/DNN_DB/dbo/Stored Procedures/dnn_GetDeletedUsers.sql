CREATE PROCEDURE [dbo].[dnn_GetDeletedUsers]
	@PortalID			int
AS
 IF @PortalID is null
  BEGIN
	SELECT  *
	FROM	dbo.dnn_vw_Users
	WHERE  PortalId IS Null
		AND IsDeleted = 1
	ORDER BY UserName
  END ELSE BEGIN
	SELECT  *
	FROM	dbo.dnn_vw_Users
	WHERE  PortalId = @PortalID		
		AND IsDeleted = 1
	ORDER BY UserName
  END

