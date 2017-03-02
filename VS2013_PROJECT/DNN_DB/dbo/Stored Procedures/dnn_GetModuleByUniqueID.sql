CREATE PROCEDURE [dbo].[dnn_GetModuleByUniqueID]
    @UniqueID   uniqueidentifier
AS
	SELECT	* 
	FROM	dbo.dnn_vw_Modules
	WHERE	UniqueID = @UniqueID

