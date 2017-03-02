-- use new FK
CREATE VIEW [dbo].[dnn_vw_FolderPermissions]
AS
SELECT  FP.FolderPermissionID,
        F.FolderID,
        F.FolderPath,
        F.PortalID,
        P.PermissionID,
        FP.RoleID,
        R.RoleName,
        FP.AllowAccess,
        FP.UserID,
        U.Username,
        U.DisplayName,
        P.PermissionCode,
        P.ModuleDefID,
        P.PermissionKey,
        P.PermissionName,
        FP.CreatedByUserID,
        FP.CreatedOnDate,
        FP.LastModifiedByUserID,
        FP.LastModifiedOnDate
FROM         dbo.[dnn_FolderPermission] AS FP
 INNER JOIN  dbo.[dnn_Folders]          AS F ON FP.FolderID     = F.FolderID
 INNER JOIN  dbo.[dnn_Permission]       AS P ON FP.PermissionID = P.PermissionID
 LEFT  JOIN  dbo.[dnn_Roles]            AS R ON FP.RoleID       = R.RoleID
 LEFT  JOIN  dbo.[dnn_Users]            AS U ON FP.UserID       = U.UserID

