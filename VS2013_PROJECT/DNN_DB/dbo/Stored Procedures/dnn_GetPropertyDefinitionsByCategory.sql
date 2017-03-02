CREATE PROCEDURE [dbo].[dnn_GetPropertyDefinitionsByCategory]
	@PortalID	int,
	@Category	nvarchar(50)

AS
SELECT	*
	FROM	dbo.dnn_ProfilePropertyDefinition
	WHERE  (PortalId = @PortalID OR (PortalId IS NULL AND @PortalID IS NULL))
		AND PropertyCategory = @Category
	ORDER BY ViewOrder

