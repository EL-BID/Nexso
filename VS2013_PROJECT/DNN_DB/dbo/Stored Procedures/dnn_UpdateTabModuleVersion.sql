CREATE PROCEDURE [dbo].[dnn_UpdateTabModuleVersion]
    @TabModuleID	int,
    @VersionGuid	uniqueidentifier
AS
    UPDATE dbo.dnn_TabModules
        SET    VersionGuid = @VersionGuid
    WHERE  TabModuleID = @TabModuleID

