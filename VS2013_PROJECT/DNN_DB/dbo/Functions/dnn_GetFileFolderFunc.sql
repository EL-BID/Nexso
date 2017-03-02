CREATE FUNCTION [dbo].[dnn_GetFileFolderFunc](@FolderD INT)
RETURNS nvarchar(246) 
AS
BEGIN
    DECLARE @folderPath nvarchar(246)
    select @folderPath=folderpath from dbo.[dnn_Folders] where folderid=@FolderD
return @folderPath
  
END;

