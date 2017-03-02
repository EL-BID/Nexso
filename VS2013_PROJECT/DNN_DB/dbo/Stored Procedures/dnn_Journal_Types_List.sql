CREATE PROCEDURE [dbo].[dnn_Journal_Types_List]
@PortalId int
AS
SELECT * 
FROM dbo.[dnn_Journal_Types]
WHERE (PortalId = -1 OR PortalId = @PortalId)

