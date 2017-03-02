CREATE PROCEDURE [dbo].[dnn_GetModuleByDefinition]
      @PortalId int,
      @DefinitionName nvarchar(128)
AS
	SELECT M.*   
	FROM dbo.dnn_vw_Modules M
		INNER JOIN dbo.dnn_ModuleDefinitions as MD ON M.ModuleDefID = MD.ModuleDefID
		INNER JOIN dbo.dnn_Tabs as T ON M.TabID = T.TabID
	WHERE ((M.PortalId = @PortalId) or (M.PortalId is null and @PortalID is null))
		AND MD.DefinitionName = @DefinitionName
		AND M.IsDeleted = 0
		AND T.IsDeleted = 0

