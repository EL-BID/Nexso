-- use new FK
CREATE VIEW [dbo].[dnn_vw_ModulePermissions]
AS
SELECT  MP.ModulePermissionID,
        MP.ModuleID,
        MP.PortalID,
        P.PermissionID,
        MP.RoleID,
        R.RoleName,
        MP.AllowAccess,
        MP.UserID,
        U.Username,
        U.DisplayName,
        P.PermissionCode,
        P.ModuleDefID,
        P.PermissionKey,
        P.PermissionName,
        MP.CreatedByUserID,
        MP.CreatedOnDate,
        MP.LastModifiedByUserID,
        MP.LastModifiedOnDate
FROM        dbo.[dnn_ModulePermission] AS MP
 INNER JOIN dbo.[dnn_Permission]       AS P  ON MP.PermissionID = P.PermissionID
 LEFT  JOIN dbo.[dnn_Roles]            AS R  ON MP.RoleID       = R.RoleID
 LEFT  JOIN dbo.[dnn_Users]            AS U  ON MP.UserID       = U.UserID

