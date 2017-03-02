CREATE PROCEDURE [dbo].[dnn_Journal_TypeFilters_List]
@PortalId int,
@ModuleId int
AS
SELECT jt.JournalTypeId, jt.JournalType from dbo.[dnn_Journal_Types] as jt INNER JOIN
	dbo.[dnn_Journal_TypeFilters] as jf ON jf.JournalTypeId = jt.JournalTypeId
WHERE jt.PortalId = @PortalId AND jf.ModuleId = @ModuleId

