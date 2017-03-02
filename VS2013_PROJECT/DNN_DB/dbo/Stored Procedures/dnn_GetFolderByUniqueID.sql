CREATE PROCEDURE [dbo].[dnn_GetFolderByUniqueID]
    @UniqueID   uniqueidentifier
AS
	SELECT	* 
	FROM	dbo.dnn_Folders
	WHERE	UniqueID = @UniqueID

