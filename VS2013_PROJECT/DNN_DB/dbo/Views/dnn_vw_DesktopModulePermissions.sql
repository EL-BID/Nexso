-- use new FK
CREATE VIEW [dbo].[dnn_vw_DesktopModulePermissions]
AS
SELECT  PP.DesktopModulePermissionID,
        PP.PortalDesktopModuleID,
        P.PermissionID,
        PP.RoleID,
        R.RoleName,
        PP.AllowAccess,
        PP.UserID,
        U.Username,
        U.DisplayName,
        P.PermissionCode,
        P.ModuleDefID,
        P.PermissionKey,
        P.PermissionName,
        PP.CreatedByUserID,
        PP.CreatedOnDate,
        PP.LastModifiedByUserID,
        PP.LastModifiedOnDate
FROM        dbo.[dnn_DesktopModulePermission] AS PP
 INNER JOIN dbo.[dnn_Permission]              AS P  ON PP.PermissionID = P.PermissionID
 LEFT  JOIN dbo.[dnn_Roles]                   AS R  ON PP.RoleID = R.RoleID
 LEFT  JOIN dbo.[dnn_Users]                   AS U  ON PP.UserID = U.UserID

