CREATE PROCEDURE [dbo].[dnn_GetModulePermissionsByPortal]
    @PortalId Int -- Not Null!
AS
    SELECT *
    FROM dbo.[dnn_vw_ModulePermissions]
    WHERE PortalID = @PortalID

