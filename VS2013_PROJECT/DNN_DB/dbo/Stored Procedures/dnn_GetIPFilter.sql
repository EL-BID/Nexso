CREATE PROCEDURE [dbo].[dnn_GetIPFilter]
@InputFilter int
AS 
	SELECT * FROM dbo.dnn_IPFilter where IPFilterID=@InputFilter

