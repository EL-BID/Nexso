﻿CREATE FUNCTION [dbo].[WordCount] ( @solutionId uniqueidentifier ) 
RETURNS INT
AS
BEGIN

DECLARE @Index          INT
DECLARE @Char           CHAR(1)
DECLARE @PrevChar       CHAR(1)
DECLARE @WordCount      INT
DECLARE @InputString varchar(max)



SELECT @InputString=ISNULL(title,' ')+' '+ISNULL(TagLine,' ')+' '+
ISNULL(Challenge,' ')+' '+ISNULL(Approach,' ')+' '+ISNULL(Results,' ')+' '+
ISNULL(Description,' ')+ISNULL(CostDetails ,' ')+
ISNULL(ImplementationDetails,' ')+ISNULL(DurationDetails,' ')
FROM [Solution]
WHERE SolutionId=@solutionId

SET @Index = 1
SET @WordCount = 0

WHILE @Index <= LEN(@InputString)
BEGIN
    SET @Char     = SUBSTRING(@InputString, @Index, 1)
    SET @PrevChar = CASE WHEN @Index = 1 THEN ' '
                         ELSE SUBSTRING(@InputString, @Index - 1, 1)
                    END

    IF @PrevChar = ' ' AND @Char != ' '
        SET @WordCount = @WordCount + 1

    SET @Index = @Index + 1
END

RETURN @WordCount

END

