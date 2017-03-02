CREATE PROCEDURE [dbo].[dnn_CalculatePagingInformation]
-- this procedure is deprecated, please use more efficient functions pageLowerBound AND pageUpperBound instead!
-- 2147483647 = Cast(0x7fffffff AS Int)
	@pageIndex 		Int, 	    -- negative to return all rows!
	@pageSize 		Int, 		-- negative OR 0 returns all rows
	@rowsToReturn  	Int output, -- row number of record AFTER last row (0 based) 
	@pageLowerBound Int output, -- row number of first record (0 based)
	@pageUpperBound Int output  -- row number of record AFTER last row (1 based)
AS
BEGIN 
	IF IsNull(@pageSize, 2147483647) < 2147483647 AND IsNull(@PageIndex, -1) >= 0 BEGIN
		SET @pageLowerBound = dbo.dnn_pageLowerBound(@pageIndex, @pageSize) - 1
		SET @rowsToReturn   = dbo.dnn_pageUpperBound(@pageIndex, @pageSize) 
		SET @pageUpperBound = @rowsToReturn + 1 
	END ELSE BEGIN
		SET @pageLowerBound = 0
		SET @rowsToReturn   = 2147483647 
		SET @pageUpperBound = 2147483647 
	END
END

