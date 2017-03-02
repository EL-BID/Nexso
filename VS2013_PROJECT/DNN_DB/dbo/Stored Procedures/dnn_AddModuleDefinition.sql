CREATE PROCEDURE [dbo].[dnn_AddModuleDefinition]

	@DesktopModuleId int,    
	@FriendlyName    nvarchar(128),
	@DefinitionName nvarchar(128),
	@DefaultCacheTime int,
	@CreatedByUserID  int

as

insert into dbo.dnn_ModuleDefinitions (
	DesktopModuleId,
	FriendlyName,
	DefinitionName,
	DefaultCacheTime,
	CreatedByUserID,
	CreatedOnDate,
	LastModifiedByUserID,
	LastModifiedOnDate
)
values (
	@DesktopModuleId,
	@FriendlyName,
	@DefinitionName,
	@DefaultCacheTime,
	@CreatedByUserID,
	getdate(),
	@CreatedByUserID,
	getdate()
)

select SCOPE_IDENTITY()

