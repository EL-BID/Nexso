CREATE PROCEDURE [dbo].[dnn_AddMetaData] 
	@ContentItemID		int,
	@Name				nvarchar(100),
	@Value				nvarchar(MAX)
AS
	DECLARE @MetaDataID	int
	SET @MetaDataID = (SELECT MetaDataID FROM dnn_MetaData WHERE MetaDataName = @Name)
	
	IF @MetaDataID IS NULL
		BEGIN
			--Insert new item into MetaData table
			INSERT INTO dbo.dnn_MetaData ( MetaDataName ) VALUES ( @Name )

			SET @MetaDataID = (SELECT SCOPE_IDENTITY() )
		END
		
	INSERT INTO dbo.dnn_ContentItems_MetaData (
		ContentItemID,
		MetaDataID,
		MetaDataValue
	)
	VALUES (
		@ContentItemID,
		@MetaDataID,
		@Value
	)

