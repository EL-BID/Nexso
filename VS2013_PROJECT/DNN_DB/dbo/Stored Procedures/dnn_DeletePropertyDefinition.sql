CREATE PROCEDURE [dbo].[dnn_DeletePropertyDefinition]

	@PropertyDefinitionId int

AS

UPDATE dbo.dnn_ProfilePropertyDefinition 
	SET Deleted = 1
	WHERE  PropertyDefinitionId = @PropertyDefinitionId

