CREATE PROCEDURE [dbo].[dnn_GetPropertyDefinitionsByPortal]

	@PortalID	int

AS
SELECT	dbo.dnn_ProfilePropertyDefinition.*
	FROM	dbo.dnn_ProfilePropertyDefinition
	WHERE  (PortalId = @PortalID OR (PortalId IS NULL AND @PortalID IS NULL))		
	ORDER BY ViewOrder

