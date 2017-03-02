CREATE PROCEDURE [dbo].[dnn_GetExpiredPortals]

AS
SELECT * FROM dbo.dnn_vw_Portals
WHERE ExpiryDate < getDate()

