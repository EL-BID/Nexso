CREATE FUNCTION [dbo].[dnn_EDS_StringListToTable]
(  
    @List		nvarchar(max)
) 
RETURNS @TableOfValues TABLE 
(  
	KeyID	int	not null primary key
) 
AS 
BEGIN
	DECLARE @CategoryID varchar(10), @Pos int
	SET @List = LTRIM(RTRIM(@List))+ ','
	SET @Pos = CHARINDEX(',', @List, 1)
	IF REPLACE(@List, ',', '') <> ''
		BEGIN
			WHILE @Pos > 0
			BEGIN
				SET @CategoryID = LTRIM(RTRIM(LEFT(@List, @Pos - 1)))
				IF @CategoryID <> ''
					BEGIN
						INSERT INTO @TableOfValues (KeyID) VALUES (CAST(@CategoryID AS int))
					END
				SET @List = RIGHT(@List, LEN(@List) - @Pos)
				SET @Pos = CHARINDEX(',', @List, 1)
			END
		END	
RETURN
END


