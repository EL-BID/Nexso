CREATE PROCEDURE [dbo].[dnn_GetUsersByRolename]
	@PortalID	INT,
	@Rolename	NVARCHAR(50)
AS
	DECLARE @UserPortalId INT
	DECLARE @PortalGroupId INT
	SELECT @PortalGroupId = PortalGroupId FROM dbo.[dnn_Portals] WHERE PortalID = @PortalID
	IF EXISTS(SELECT PortalGroupID FROM dbo.[dnn_PortalGroups] WHERE PortalGroupID = @PortalGroupId)
	BEGIN
		SELECT @UserPortalId = MasterPortalID FROM dbo.[dnn_PortalGroups] WHERE PortalGroupID = @PortalGroupId
	END
	ELSE
	BEGIN
		SELECT @UserPortalId = @PortalID
	END
	SELECT     
		U.*, 
		UP.PortalId, 
		UP.Authorised, 
		UP.IsDeleted,
		UP.RefreshRoles,
		UP.VanityUrl
	FROM dbo.dnn_UserPortals AS UP 
			RIGHT OUTER JOIN dbo.dnn_UserRoles  UR 
			INNER JOIN dbo.dnn_Roles R ON UR.RoleID = R.RoleID 
			RIGHT OUTER JOIN dbo.dnn_Users AS U ON UR.UserID = U.UserID 
		ON UP.UserId = U.UserID	
	WHERE ( UP.PortalId = @UserPortalId OR @UserPortalId IS Null )
		AND (UP.IsDeleted = 0 OR UP.IsDeleted Is NULL)
		AND (R.RoleName = @Rolename)
		AND (R.PortalId = @PortalID OR @PortalID IS Null )
	ORDER BY U.FirstName + ' ' + U.LastName

