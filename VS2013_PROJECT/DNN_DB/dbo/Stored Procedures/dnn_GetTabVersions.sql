CREATE PROCEDURE [dbo].[dnn_GetTabVersions]
	@TabId INT
AS
BEGIN
	SELECT   
		[TabVersionId],
		[TabId],
		[Version],
		[TimeStamp],
		[IsPublished],
	    [CreatedByUserID],
		[CreatedOnDate],
		[LastModifiedByUserID],
		[LastModifiedOnDate]
	FROM dbo.[dnn_TabVersions]
	WHERE [TabId] = @TabId
END

