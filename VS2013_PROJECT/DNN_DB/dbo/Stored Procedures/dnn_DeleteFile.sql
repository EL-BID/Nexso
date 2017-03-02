CREATE PROCEDURE [dbo].[dnn_DeleteFile]	
    @PortalID int,
	@FileName nvarchar(246),
	@FolderID int
AS
BEGIN
    IF @PortalID is null
    BEGIN
        DELETE FROM dbo.dnn_Files WHERE FileName = @FileName AND FolderID = @FolderID AND PortalId IS Null
    END ELSE BEGIN
        DELETE FROM dbo.dnn_Files WHERE FileName = @FileName AND FolderID = @FolderID AND PortalId = @PortalID
    END
END

