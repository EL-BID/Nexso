CREATE FUNCTION [dbo].[dnn_Journal_SplitText](@text varchar(8000), @delimiter char(1))
RETURNS @words TABLE (objectid smallint primary key, string varchar(1000), optionalid int)
AS
BEGIN
	DECLARE @pos smallint,
		@i smallint,
		@j smallint,
		@s varchar(255),
        @o int

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
				SET @o = 0
	            IF CHARINDEX('|',@s,0) > 0
					BEGIN
						SET @o = SUBSTRING(@s,0,CHARINDEX('|',@s,0))
						SET @s = SUBSTRING(@s,CHARINDEX('|',@s,0)+1,LEN(@s))

					END

				IF NOT EXISTS (SELECT 1 FROM @words WHERE [string]=@s)
				BEGIN
					INSERT INTO @words
					VALUES (@pos, @s, @o)
				END
			END

			SET @pos = @i + 1
			WHILE @pos < LEN(@text) AND SUBSTRING(@text, @pos, 1) IN (' ', ',')
				SET @pos = @pos + 1
		END
		ELSE
		BEGIN
			SET @s = SUBSTRING(@text, @pos, LEN(@text) - @pos + 1)
			IF CHARINDEX('|',@s,0) > 0
			BEGIN
				SET @o = SUBSTRING(@s,0,CHARINDEX('|',@s,0))
				SET @s = SUBSTRING(@s,CHARINDEX('|',@s,0)+1,LEN(@s))

			END

			IF NOT EXISTS (SELECT 1 FROM @words WHERE [string]=@s)
			BEGIN
				INSERT INTO @words
				VALUES (@pos, @s ,@o)
			END

			SET @pos = LEN(@text) + 1
		END
	END

	RETURN
END

