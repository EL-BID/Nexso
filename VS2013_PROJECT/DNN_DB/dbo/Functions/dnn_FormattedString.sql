-- added for easier string handling
CREATE FUNCTION [dbo].[dnn_FormattedString]
(
    @InputStr nVarChar(2000), -- might be null or empty, in this case an empty string is returned (format ignored)!
    @Format   nVarChar(2000)  -- not null or empty, contains token @@@
)
	RETURNS   nVarChar(4000)  -- replaced string, e.g. FormattedString('World', 'Hello @0!') returns 'Hello World!' 
AS
BEGIN
	DECLARE @RetVal AS nVarChar(4000) = ''
	IF NOT IsNull(@InputStr,'') = ''
		SET @retVal = REPLACE(@Format, N'@0', @InputStr)
	RETURN @RetVal
END

