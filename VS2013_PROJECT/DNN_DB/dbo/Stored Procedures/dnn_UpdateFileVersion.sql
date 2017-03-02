CREATE PROCEDURE [dbo].[dnn_UpdateFileVersion]
	@FileID			int,
    @VersionGuid	uniqueidentifier
AS
    UPDATE dbo.dnn_Files
        SET    VersionGuid = @VersionGuid
    WHERE  FileID = @FileID

