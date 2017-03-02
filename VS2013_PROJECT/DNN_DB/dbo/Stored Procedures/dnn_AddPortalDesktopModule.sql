CREATE PROCEDURE [dbo].[dnn_AddPortalDesktopModule]
	@PortalID			int,
	@DesktopModuleId	int,
	@CreatedByUserID	int

as

insert into dbo.dnn_PortalDesktopModules ( 
	PortalId,
	DesktopModuleId,
	CreatedByUserID,
	CreatedOnDate,
	LastModifiedByUserID,
	LastModifiedOnDate
)
values (
	@PortalID,
	@DesktopModuleId,
	@CreatedByUserID,
	getdate(),
	@CreatedByUserID,
	getdate()
)

select SCOPE_IDENTITY()

