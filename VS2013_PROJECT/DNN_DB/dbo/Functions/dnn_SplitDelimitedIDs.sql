-- new helper function to return a table with id's, passed as a single string with delimiter
CREATE FUNCTION [dbo].[dnn_SplitDelimitedIDs]
(
	@RecordIDList VarChar(2000),
	@Delimiter    VarChar(   2) = ','
)
RETURNS 
	@IntegerList Table (RecordID Int)
AS
	BEGIN
		DECLARE @RecordID VarChar(10)
		DECLARE @Start    Int        = 0
		DECLARE @Pos      Int        = 1

		SET @RecordIDList = @RecordIDList + @Delimiter
		SET @Pos = CHARINDEX(@Delimiter, @RecordIDList, 1)

		WHILE @Pos > 0 BEGIN
			SET @RecordID = LTRIM(RTRIM(SUBSTRING(@RecordIDList, @Start, @Pos - @Start)))
			IF @RecordID <> ''
				INSERT INTO @IntegerList (RecordID) VALUES (CAST(@RecordID AS Int)) -- use appropriate conversion
			SET @Start = @Pos + len(@Delimiter)
			SET @Pos = CHARINDEX(@Delimiter, @RecordIDList, @Start)
		END
		RETURN
	END

