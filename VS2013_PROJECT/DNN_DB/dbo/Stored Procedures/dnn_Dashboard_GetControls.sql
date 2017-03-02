CREATE PROCEDURE [dbo].[dnn_Dashboard_GetControls] 
	@IsEnabled bit
AS
BEGIN
	IF @IsEnabled = 0 BEGIN
		SELECT *
		FROM dbo.[dnn_Dashboard_Controls]
		ORDER BY ViewOrder
	END
	ELSE BEGIN
		SELECT *
		FROM dbo.[dnn_Dashboard_Controls]
		WHERE IsEnabled = 1
		ORDER BY ViewOrder
	END
END

