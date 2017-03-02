CREATE PROCEDURE [dbo].[dnn_AddDefaultFolderTypes]
	@PortalID int
AS
BEGIN
	INSERT INTO dbo.[dnn_FolderMappings] (PortalID, MappingName, FolderProviderType, Priority)
	SELECT @PortalID, 'Standard', 'StandardFolderProvider', 1
	UNION ALL
	SELECT @PortalID, 'Secure', 'SecureFolderProvider', 2
	UNION ALL
	SELECT @PortalID, 'Database', 'DatabaseFolderProvider', 3
END

