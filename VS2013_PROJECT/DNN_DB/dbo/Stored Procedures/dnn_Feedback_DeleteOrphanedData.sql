CREATE PROCEDURE [dbo].[dnn_Feedback_DeleteOrphanedData]

AS

BEGIN
 WITH OrphanedData
   AS (SELECT f.ModuleID FROM  dbo.dnn_Feedback f
       LEFT OUTER JOIN  dbo.dnn_Modules m ON f.ModuleID = m.ModuleID
       WHERE m.ModuleID is null)
   
   DELETE FROM  dbo.dnn_Feedback
   FROM  dbo.dnn_Feedback f
   JOIN OrphanedData o ON f.ModuleId = o.ModuleID
END
