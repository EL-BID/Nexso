-- new helper function for paging, replacing inefficient stored procedure
CREATE FUNCTION [dbo].[dnn_PageUpperBound]
(
    @PageIndex Int, -- Page number starting with 0 or Null for all
    @PageSize  Int  -- number of items per page or Null for all
) 
	RETURNS    Int
AS
BEGIN
    DECLARE @bound Int = Cast(0x7fffffff AS Int)
    IF IsNull(@PageSize, -1) > 0 AND IsNull(@PageIndex, -1) >= 0 AND IsNull(@PageIndex, 0) <= (Cast(0x7fffffff AS Int) / IsNull(@PageSize, 1) -1)
        SET @Bound = @PageSize * (@PageIndex + 1)
    RETURN @Bound
END

