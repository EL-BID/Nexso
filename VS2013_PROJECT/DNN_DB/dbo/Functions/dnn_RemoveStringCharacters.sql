CREATE FUNCTION [dbo].[dnn_RemoveStringCharacters]
(
		@string nvarchar(max), 
		@remove nvarchar(100)
)
RETURNS nvarchar(max)
AS
BEGIN
    WHILE @string LIKE '%[' + @remove + ']%'
    BEGIN
        SET @string = REPLACE(@string,SUBSTRING(@string,PATINDEX('%[' + @remove + ']%',@string),1),'')
    END

    RETURN @string
END

