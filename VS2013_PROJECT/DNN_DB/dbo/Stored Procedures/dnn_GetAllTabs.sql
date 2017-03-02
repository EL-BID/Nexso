CREATE PROCEDURE [dbo].[dnn_GetAllTabs] 
AS
	SELECT *
		FROM dbo.dnn_vw_Tabs
		ORDER BY Level, ParentID, TabOrder

