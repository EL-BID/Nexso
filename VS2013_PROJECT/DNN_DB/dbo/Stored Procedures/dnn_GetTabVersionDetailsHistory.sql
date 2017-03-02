CREATE PROCEDURE [dbo].[dnn_GetTabVersionDetailsHistory]
	@TabID iNT,
    @Version INT
AS
BEGIN    
	SELECT tvd.[TabVersionDetailId]
		  ,tvd.[TabVersionId]
		  ,tvd.[ModuleId]
		  ,tvd.[ModuleVersion]
		  ,tvd.[PaneName]
		  ,tvd.[ModuleOrder]
		  ,tvd.[Action]
		  ,tvd.[CreatedByUserID]
		  ,tvd.[CreatedOnDate]
		  ,tvd.[LastModifiedByUserID]
		  ,tvd.[LastModifiedOnDate]
	FROM dbo.[dnn_TabVersionDetails] tvd
	INNER JOIN dbo.[dnn_TabVersions] tv ON tvd.TabVersionId = tv.TabVersionId
	WHERE tv.Version <= @Version
		AND tv.TabId = @TabID
	ORDER BY tvd.CreatedOnDate 
END

