CREATE PROCEDURE [dbo].[dnn_Journal_TypeFilters_Delete]
@PortalId int,
@ModuleId int
AS
DELETE FROM dbo.[dnn_Journal_TypeFilters] WHERE PortalId = @PortalId AND ModuleId=@ModuleId

