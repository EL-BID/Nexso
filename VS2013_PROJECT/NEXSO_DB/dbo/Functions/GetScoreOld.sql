Create FUNCTION [dbo].[GetScoreOld] (@SolutionId uniqueidentifier,@ScoreType varchar(50) )
RETURNS INT
AS
BEGIN

DECLARE @rate          INT
SET @rate = 0

IF @ScoreType is not null
begin
SELECT @rate= AVG(Scores.ComputedValue) 
  FROM [Scores]
  where SolutionId= @SolutionId and scoretype=@ScoreType
  group by solutionid
end
else
SELECT @rate= AVG(Scores.ComputedValue) 
  FROM [Scores]
  where SolutionId= @SolutionId
  group by solutionid


RETURN @rate

END

