CREATE PROCEDURE [dbo].[dnn_DeleteFolder]	
    @PortalID int,
    @FolderPath nvarchar(300)
AS
BEGIN
    IF @PortalID is null
    BEGIN
        DELETE FROM dbo.dnn_Folders
        WHERE PortalID is null AND FolderPath = @FolderPath
    END ELSE BEGIN
        DELETE FROM dbo.dnn_Folders
        WHERE PortalID = @PortalID AND FolderPath = @FolderPath
    END
END

