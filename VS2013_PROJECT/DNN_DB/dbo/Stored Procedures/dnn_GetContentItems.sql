CREATE PROCEDURE [dbo].[dnn_GetContentItems] 
	@ContentTypeId	int,
	@TabId			int,
	@ModuleId		int
AS
	SELECT *
	FROM dbo.dnn_ContentItems
	WHERE (ContentTypeId = @ContentTypeId OR @ContentTypeId IS NULL)
		AND (TabId = @TabId OR @TabId IS NULL)
		AND (ModuleId = @ModuleId OR @ModuleId IS NULL)

