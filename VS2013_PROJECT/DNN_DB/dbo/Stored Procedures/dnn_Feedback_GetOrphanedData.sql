CREATE PROCEDURE [dbo].[dnn_Feedback_GetOrphanedData]

AS

       SELECT COUNT(*) As [ItemCount], f.ModuleID As [ModuleID] FROM  dbo.dnn_Feedback f
       LEFT OUTER JOIN  dbo.dnn_Modules m ON f.ModuleID = m.ModuleID
       WHERE m.ModuleID is null
       GROUP BY f.ModuleID
