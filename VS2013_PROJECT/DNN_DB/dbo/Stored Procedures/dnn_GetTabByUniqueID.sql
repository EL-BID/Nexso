CREATE PROCEDURE [dbo].[dnn_GetTabByUniqueID]
    @UniqueID   uniqueidentifier
AS
	SELECT	* 
	FROM	dbo.dnn_vw_Tabs
	WHERE	UniqueID = @UniqueID

