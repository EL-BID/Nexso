CREATE PROCEDURE [dbo].[dnn_UpdateModuleDefinition]

	@ModuleDefId			int,    
	@FriendlyName			nvarchar(128),
	@DefinitionName			nvarchar(128),
	@DefaultCacheTime		int,
	@LastModifiedByUserID	int

as

update dbo.dnn_ModuleDefinitions 
	SET FriendlyName = @FriendlyName,
		DefinitionName = @DefinitionName,
		DefaultCacheTime = @DefaultCacheTime,
		LastModifiedByUserID = @LastModifiedByUserID,
		LastModifiedOnDate = getdate()
	WHERE ModuleDefId = @ModuleDefId

