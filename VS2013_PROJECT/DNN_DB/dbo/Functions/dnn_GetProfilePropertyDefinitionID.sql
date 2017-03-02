-- optimized
CREATE FUNCTION [dbo].[dnn_GetProfilePropertyDefinitionID]
(   @PortalID     Int,         -- might be 0
    @PropertyName nVarChar(50) -- required
)   
	RETURNS 	  Int
AS
	BEGIN
		DECLARE @DefinitionID Int = -1
		IF NOT IsNull(@PropertyName, '') = ''
			SELECT @DefinitionID = PropertyDefinitionID
			  FROM dbo.[dnn_ProfilePropertyDefinition]
			  WHERE IsNull(PortalID, -1) = IsNull(@PortalID, -1) AND PropertyName = @PropertyName
		RETURN @DefinitionID
	END

