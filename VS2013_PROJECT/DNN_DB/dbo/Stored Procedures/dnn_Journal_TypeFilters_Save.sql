CREATE PROCEDURE [dbo].[dnn_Journal_TypeFilters_Save]
@PortalId int,
@ModuleId int,
@JournalTypeId int
AS
INSERT INTO dbo.[dnn_Journal_TypeFilters] 
	(PortalId, ModuleId, JournalTypeId)
	VALUES
	(@PortalId, @ModuleId, @JournalTypeId)

