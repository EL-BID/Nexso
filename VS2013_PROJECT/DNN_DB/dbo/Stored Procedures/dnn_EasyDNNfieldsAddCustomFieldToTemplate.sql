CREATE PROCEDURE [dbo].[dnn_EasyDNNfieldsAddCustomFieldToTemplate]
	@FieldsTemplateID int,
	@CustomFieldID int   
AS 
	DECLARE @NewPosition int;
	DECLARE @DateCreated datetime;
	DECLARE @inserted int;
	SET @inserted = 0;
	SET @NewPosition = '0';
	SET @DateCreated = GETDATE();
BEGIN TRANSACTION;
BEGIN TRY
    SET NOCOUNT ON;
    IF NOT exists (SELECT CustomFieldID FROM dbo.[dnn_EasyDNNfieldsTemplateItems] WHERE FieldsTemplateID = @FieldsTemplateID AND CustomFieldID=@CustomFieldID)
    BEGIN
		IF exists (SELECT Position FROM dbo.[dnn_EasyDNNfieldsTemplateItems] WHERE FieldsTemplateID = @FieldsTemplateID)
		BEGIN
		    SELECT @NewPosition = max(Position) FROM dbo.[dnn_EasyDNNfieldsTemplateItems] WHERE FieldsTemplateID = @FieldsTemplateID;
			SET @NewPosition = @NewPosition + 10;
		END
		ELSE
		BEGIN
			SET @NewPosition = 10; 
		END
		INSERT INTO dbo.[dnn_EasyDNNfieldsTemplateItems] ([FieldsTemplateID],[CustomFieldID],[Position]) VALUES (@FieldsTemplateID,@CustomFieldID, @NewPosition);
		SET @inserted = SCOPE_IDENTITY();  
	END
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;

return @inserted;


