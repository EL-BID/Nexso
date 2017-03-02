CREATE FUNCTION dbo.[dnn_EDSGallery_StringListToTable]
(  
    @List		nvarchar(max)
) 
RETURNS @TableOfValues TABLE
(  
	KeyID int not null
) 
AS 
	BEGIN
		DECLARE @KeyID varchar(10), @Pos int
		SET @List = LTRIM(RTRIM(@List))+ ','
		SET @Pos = CHARINDEX(',', @List, 1)
		IF REPLACE(@List, ',', '') <> ''
			BEGIN
				WHILE @Pos > 0
				BEGIN
					SET @KeyID = LTRIM(RTRIM(LEFT(@List, @Pos - 1)))
					IF @KeyID <> ''
						BEGIN
							INSERT INTO @TableOfValues (KeyID) VALUES (CAST(@KeyID AS int))
						END
					SET @List = RIGHT(@List, LEN(@List) - @Pos)
					SET @Pos = CHARINDEX(',', @List, 1)
				END
			END	
	RETURN
	END