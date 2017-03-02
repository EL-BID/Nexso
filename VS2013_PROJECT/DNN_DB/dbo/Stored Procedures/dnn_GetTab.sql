CREATE PROCEDURE [dbo].[dnn_GetTab]

@TabId    int

AS
SELECT *
FROM   dbo.dnn_vw_Tabs
WHERE  TabId = @TabId

