CREATE PROCEDURE [dbo].[dnn_GetPropertyDefinition]

	@PropertyDefinitionID	int

AS
SELECT	dbo.dnn_ProfilePropertyDefinition.*
FROM	dbo.dnn_ProfilePropertyDefinition
WHERE PropertyDefinitionID = @PropertyDefinitionID
	AND Deleted = 0

