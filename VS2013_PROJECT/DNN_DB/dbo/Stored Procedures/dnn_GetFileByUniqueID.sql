CREATE PROCEDURE [dbo].[dnn_GetFileByUniqueID]
    @UniqueID   uniqueidentifier
AS
	SELECT	* 
	FROM	dbo.dnn_Files
	WHERE	UniqueID = @UniqueID

