CREATE PROCEDURE [dbo].[dnn_GetPortalRoles]
    @PortalId     Int -- Null: Host Roles
AS
BEGIN
    SELECT R.*,
          (SELECT COUNT(*) FROM dbo.[dnn_UserRoles] U WHERE U.RoleID = R.RoleID) AS UserCount
     FROM dbo.[dnn_Roles] R
    WHERE (R.PortalId = @PortalId OR R.PortalId is null)
      AND (R.RoleId >= 0) -- DNN-4288: hide system role atm to prevent duplicates. Might be removed, after API has been adopt
    ORDER BY R.RoleName
	OPTION (OPTIMIZE FOR (@PortalId UNKNOWN))
END

