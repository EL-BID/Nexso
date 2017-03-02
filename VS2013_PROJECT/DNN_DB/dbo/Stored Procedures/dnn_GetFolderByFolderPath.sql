CREATE PROCEDURE [dbo].[dnn_GetFolderByFolderPath]
 @PortalID int,
 @FolderPath nvarchar(300)
AS
BEGIN
 if @PortalID is not null
 begin
  SELECT *
  FROM dbo.dnn_Folders
  WHERE PortalID = @PortalID AND FolderPath = @FolderPath
 end else begin
  SELECT *
  FROM dbo.dnn_Folders
  WHERE PortalID is null AND  FolderPath = @FolderPath
 end
END

