-- results order added
CREATE FUNCTION [dbo].[dnn_GetProfileFieldSQL]
(
    @PortalID 	 Int,
    @TemplateSql nVarChar(max)
)
	RETURNS 	 nVarChar(max)
AS
	BEGIN
		DECLARE @sql nVarChar(max);

		SELECT @sql = COALESCE(@sql + ',','') + '[' + PropertyName + ']' + @TemplateSql
		 FROM dbo.[dnn_ProfilePropertyDefinition]
		 WHERE IsNull(PortalID, -1) = IsNull(@PortalID, -1)
		   AND Deleted = 0
		ORDER BY ViewOrder
		RETURN (@sql)
	END

