CREATE PROCEDURE [dbo].[dnn_GetPropertyDefinitionByName]
	@PortalID	int,
	@Name		nvarchar(50)

AS
SELECT	*
	FROM	dbo.dnn_ProfilePropertyDefinition
	WHERE  (PortalId = @PortalID OR (PortalId IS NULL AND @PortalID IS NULL))
		AND PropertyName = @Name
	ORDER BY ViewOrder

