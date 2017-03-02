-- use new FK
CREATE VIEW [dbo].[dnn_vw_TabPermissions]
AS
SELECT  TP.TabPermissionID,
        T.TabID,
        T.PortalId,
        P.PermissionID,
        TP.RoleID,
        R.RoleName,
        TP.AllowAccess,
        TP.UserID,
        U.Username,
        U.DisplayName,
        P.PermissionCode,
        P.ModuleDefID,
        P.PermissionKey,
        P.PermissionName,
        TP.CreatedByUserID,
        TP.CreatedOnDate,
        TP.LastModifiedByUserID,
        TP.LastModifiedOnDate
FROM        dbo.[dnn_TabPermission]    AS TP
 INNER JOIN dbo.[dnn_Tabs]             AS T  ON TP.TabId        = T.TabId
 INNER JOIN dbo.[dnn_Permission]       AS P  ON TP.PermissionID = P.PermissionID
 LEFT  JOIN dbo.[dnn_Roles]            AS R  ON TP.RoleID       = R.RoleID
 LEFT  JOIN dbo.[dnn_Users]            AS U  ON TP.UserID       = U.UserID

