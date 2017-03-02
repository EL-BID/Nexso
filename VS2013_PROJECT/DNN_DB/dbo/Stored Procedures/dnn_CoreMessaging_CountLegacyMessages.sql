CREATE PROCEDURE [dbo].[dnn_CoreMessaging_CountLegacyMessages]    
AS
	--Return total records
	SELECT COUNT(*) AS TotalRecords
	FROM dbo.[dnn_Messaging_Messages]

