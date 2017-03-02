CREATE PROCEDURE [dbo].[dnn_PublishTab]
	@TabID INT
AS
BEGIN 
        UPDATE dbo.[dnn_Tabs] SET            
            [HasBeenPublished] = 1
        WHERE TabID = @TabID
END

