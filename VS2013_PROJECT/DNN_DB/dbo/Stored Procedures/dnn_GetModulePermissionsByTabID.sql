CREATE PROCEDURE [dbo].[dnn_GetModulePermissionsByTabID]
    @TabId Int -- Not Null!
AS
    SELECT MP.*
    FROM        dbo.[dnn_Tabs]                 AS T
    INNER JOIN  dbo.[dnn_TabModules]           AS TM ON TM.TabID    = T.TabID
    INNER JOIN  dbo.[dnn_vw_ModulePermissions] AS MP ON TM.ModuleID = MP.ModuleID AND T.PortalID = MP.PortalID
    WHERE T.TabID = @TabId

