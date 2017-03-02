CREATE PROCEDURE [dbo].[dnn_DeleteIPFilter]
	@IPFilterID	int
AS 
	BEGIN
		DELETE FROM dbo.dnn_IPFilter  
			WHERE IPFilterID = @IPFilterID
	END

