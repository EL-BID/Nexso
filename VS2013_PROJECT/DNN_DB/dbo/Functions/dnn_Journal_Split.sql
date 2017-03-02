CREATE FUNCTION [dbo].[dnn_Journal_Split](@text varchar(8000), @delimiter char(1))
RETURNS @words TABLE (objectid smallint primary key, id int)
AS
BEGIN
	DECLARE @pos smallint,
		@i smallint,
		@j smallint,
		@s varchar(255)

	SET @pos = 1

	WHILE @pos <= LEN(@text)
	BEGIN
		SET @i = CHARINDEX(' ', @text, @pos)
		SET @j = CHARINDEX(@delimiter, @text, @pos)

		IF @i > 0 OR @j > 0
		BEGIN
			IF @i = 0 OR (@j > 0 AND @j < @i)
				SET @i = @j

			IF @i > @pos
			BEGIN
				-- @i now holds the earliest delimiter in the string
				SET @s = SUBSTRING(@text, @pos, @i - @pos)
	
				INSERT INTO @words
				VALUES (@pos, @s)
			END

			SET @pos = @i + 1
			WHILE @pos < LEN(@text) AND SUBSTRING(@text, @pos, 1) IN (' ', ',')
				SET @pos = @pos + 1
		END
		ELSE
		BEGIN
			INSERT INTO @words
			VALUES (@pos, SUBSTRING(@text, @pos, LEN(@text) - @pos + 1))

			SET @pos = LEN(@text) + 1
		END
	END
	
	RETURN
END

