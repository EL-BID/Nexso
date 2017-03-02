CREATE FUNCTION [dbo].[dnn_GetProfileElement]
(
	@fieldName AS NVARCHAR(100),
	@fields AS NVARCHAR(4000),
	@values AS NVARCHAR(4000)
)

RETURNS NVARCHAR(4000)

AS

BEGIN

	-- If input is invalid, return null.
	IF  @fieldName IS NULL
		OR LEN(@fieldName) = 0
		OR @fields IS NULL
		OR LEN(@fields) = 0
		OR @values IS NULL
		OR LEN(@values) = 0
		RETURN NULL

	-- locate FieldName in Fields
	DECLARE @fieldNameToken AS NVARCHAR(20)
	DECLARE @fieldNameStart AS INTEGER, @valueStart AS INTEGER, @valueLength AS INTEGER

	-- Only handle string type fields (:S:)
	SET @fieldNameStart = CHARINDEX(@fieldName + ':S',@Fields,0)

	-- If field is not found, return null
	IF @fieldNameStart = 0 RETURN NULL
	SET @fieldNameStart = @fieldNameStart + LEN(@fieldName) + 3

	-- Get the field token which I've defined as the start of the field offset to the end of the length
	SET @fieldNameToken =
	SUBSTRING(@Fields,@fieldNameStart,LEN(@Fields)-@fieldNameStart)

	-- Get the values for the offset and length
	SET @valueStart = dbo.dnn_getelement(1,@fieldNameToken,':')
	SET @valueLength = dbo.dnn_getelement(2,@fieldNameToken,':')

	-- Check for sane values, 0 length means the profile item was stored, just no data
	IF @valueLength = 0 RETURN ''

	-- Return the string
	RETURN SUBSTRING(@values, @valueStart+1, @valueLength)
END

