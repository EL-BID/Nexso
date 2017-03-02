CREATE PROCEDURE [dbo].[dnn_UpdateTabVersion]
    @TabID			int,
    @VersionGuid	uniqueidentifier
AS
    UPDATE dbo.dnn_Tabs
        SET    VersionGuid = @VersionGuid
    WHERE  TabID = @TabID

