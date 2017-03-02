CREATE PROCEDURE [dbo].[dnn_GetTabVersionDetails]
	@TabVersionId INT
AS
BEGIN
	SELECT   
		[TabVersionDetailId] ,
        [TabVersionId] ,
		[ModuleId] ,
		[ModuleVersion] ,
		[PaneName] ,
		[ModuleOrder] ,
		[Action],
	    [CreatedByUserID] ,
		[CreatedOnDate],
		[LastModifiedByUserID],
		[LastModifiedOnDate]
	FROM dbo.[dnn_TabVersionDetails]
	WHERE [TabVersionId] = @TabVersionId
END

