CREATE PROCEDURE [dbo].[dnn_EasyDNNfieldsExchangeGroupCFPosition]
(
@ComandType	int,
@FieldsTemplateID	int,
@CustomFieldID	int       
)
AS
DECLARE @CurrentPosition int;
SET @CurrentPosition = 0;
DECLARE @MaxMinPosition int;
SET @MaxMinPosition = 0;
DECLARE @ContentUpDownID int;
SET @ContentUpDownID = 0;
DECLARE @PositionOneUpDown int;
SET @PositionOneUpDown = 0;
BEGIN TRANSACTION;
BEGIN TRY
        SET NOCOUNT ON;      
        IF (@ComandType = 1) -- ovo je za pomicanje gore, prema vrhu, tj prema prvome koji je dodan u listu
        BEGIN
			SELECT @CurrentPosition = Position FROM dbo.[dnn_EasyDNNfieldsTemplateItems] WHERE FieldsTemplateID = @FieldsTemplateID AND CustomFieldID = @CustomFieldID;
			SELECT @MaxMinPosition = min(Position) FROM dbo.[dnn_EasyDNNfieldsTemplateItems] WHERE FieldsTemplateID = @FieldsTemplateID;
			IF (@CurrentPosition <> @MaxMinPosition) -- tu se može usporediti kad je to min value
				BEGIN
					SELECT @PositionOneUpDown = max(Position) FROM dbo.[dnn_EasyDNNfieldsTemplateItems] WHERE FieldsTemplateID = @FieldsTemplateID AND Position < @CurrentPosition;
					UPDATE dbo.[dnn_EasyDNNfieldsTemplateItems] SET Position = @CurrentPosition WHERE Position = @PositionOneUpDown AND FieldsTemplateID = @FieldsTemplateID;
					UPDATE dbo.[dnn_EasyDNNfieldsTemplateItems] SET Position = @PositionOneUpDown WHERE FieldsTemplateID = @FieldsTemplateID AND CustomFieldID = @CustomFieldID;
				END
        END
        ELSE IF(@ComandType = 0) -- ovo je za pomicanje dolje -- znači da je commandType jednako 0, ali budemo mi to provjerili za svaki slučaj
		BEGIN
			SELECT @CurrentPosition = Position FROM dbo.[dnn_EasyDNNfieldsTemplateItems] WHERE FieldsTemplateID = @FieldsTemplateID AND CustomFieldID = @CustomFieldID;
			SELECT @MaxMinPosition = max(Position) FROM dbo.[dnn_EasyDNNfieldsTemplateItems] WHERE FieldsTemplateID = @FieldsTemplateID;
			IF (@CurrentPosition <> @MaxMinPosition)
				BEGIN
					SELECT @PositionOneUpDown = min(Position) FROM dbo.[dnn_EasyDNNfieldsTemplateItems] WHERE FieldsTemplateID = @FieldsTemplateID AND Position > @CurrentPosition;
					UPDATE dbo.[dnn_EasyDNNfieldsTemplateItems] SET Position = @CurrentPosition WHERE Position = @PositionOneUpDown AND FieldsTemplateID = @FieldsTemplateID;
					UPDATE dbo.[dnn_EasyDNNfieldsTemplateItems] SET Position = @PositionOneUpDown WHERE FieldsTemplateID = @FieldsTemplateID AND CustomFieldID = @CustomFieldID;
				END
		END        
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;


