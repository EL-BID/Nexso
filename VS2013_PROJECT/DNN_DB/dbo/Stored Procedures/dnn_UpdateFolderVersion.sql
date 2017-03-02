CREATE PROCEDURE [dbo].[dnn_UpdateFolderVersion]
	@FolderID		int,
    @VersionGuid	uniqueidentifier
AS
    UPDATE dbo.dnn_Folders
        SET    VersionGuid = @VersionGuid
    WHERE  FolderID = @FolderID

