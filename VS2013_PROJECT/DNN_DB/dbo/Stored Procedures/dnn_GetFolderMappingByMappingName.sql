CREATE PROCEDURE [dbo].[dnn_GetFolderMappingByMappingName]
	@PortalID int,
	@MappingName nvarchar(50)
AS
BEGIN
	SELECT *
	FROM dbo.[dnn_FolderMappings]
	WHERE ISNULL(PortalID, -1) = ISNULL(@PortalID, -1) AND MappingName = @MappingName
END

