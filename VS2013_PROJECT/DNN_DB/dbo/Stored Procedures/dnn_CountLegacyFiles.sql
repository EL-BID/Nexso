CREATE PROCEDURE [dbo].[dnn_CountLegacyFiles]
AS
BEGIN

SELECT COUNT(*) FROM dbo.[dnn_Files] WHERE ContentItemID IS NULL
END

