CREATE PROCEDURE [dbo].[dnn_EasyDNNfieldsExchangeElementsPosition]
(
	@ComandType	int,
	@FieldElementID	int,
	@CustomFieldID	int,
	@FEParentID int = null       
)
AS

DECLARE @FEParentIDTemp int;

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
			SELECT @CurrentPosition = Position FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE FieldElementID = @FieldElementID AND CustomFieldID = @CustomFieldID;
			IF @FEParentID IS NULL
			BEGIN
				SELECT @MaxMinPosition = min(Position) FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE CustomFieldID = @CustomFieldID;
			END
			ELSE
			BEGIN
				SELECT @MaxMinPosition = min(Position) FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE CustomFieldID = @CustomFieldID AND FEParentID = @FEParentID;
			END
			IF (@CurrentPosition <> @MaxMinPosition) -- tu se može usporediti kad je to min value
				BEGIN
					IF @FEParentID IS NULL
					BEGIN
						SELECT @PositionOneUpDown = max(Position) FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE CustomFieldID = @CustomFieldID AND Position < @CurrentPosition;
					END
					ELSE
					BEGIN
						SELECT @PositionOneUpDown = max(Position) FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE CustomFieldID = @CustomFieldID AND FEParentID = @FEParentID AND Position < @CurrentPosition;				
					END
					UPDATE dbo.[dnn_EasyDNNfieldsMultiElements] SET Position = @CurrentPosition WHERE Position = @PositionOneUpDown AND CustomFieldID = @CustomFieldID;
					UPDATE dbo.[dnn_EasyDNNfieldsMultiElements] SET Position = @PositionOneUpDown WHERE FieldElementID = @FieldElementID AND CustomFieldID = @CustomFieldID;
				END
        END
        ELSE IF(@ComandType = 0) -- ovo je za pomicanje dolje -- znači da je commandType jednako 0, ali budemo mi to provjerili za svaki slučaj
		BEGIN
			SELECT @CurrentPosition = Position FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE FieldElementID = @FieldElementID AND CustomFieldID = @CustomFieldID;
			IF @FEParentID IS NULL
			BEGIN
				SELECT @MaxMinPosition = max(Position) FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE CustomFieldID = @CustomFieldID;
			END
			ELSE
			BEGIN
				SELECT @MaxMinPosition = max(Position) FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE CustomFieldID = @CustomFieldID AND FEParentID = @FEParentID;
			END
			IF (@CurrentPosition <> @MaxMinPosition)
				BEGIN
					IF @FEParentID IS NULL
					BEGIN
						SELECT @PositionOneUpDown = min(Position) FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE CustomFieldID = @CustomFieldID AND Position > @CurrentPosition;
					END
					ELSE
					BEGIN
						SELECT @PositionOneUpDown = min(Position) FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE CustomFieldID = @CustomFieldID AND FEParentID = @FEParentID AND Position > @CurrentPosition;			
					END			
					UPDATE dbo.[dnn_EasyDNNfieldsMultiElements] SET Position = @CurrentPosition WHERE Position = @PositionOneUpDown AND CustomFieldID = @CustomFieldID;
					UPDATE dbo.[dnn_EasyDNNfieldsMultiElements] SET Position = @PositionOneUpDown WHERE FieldElementID = @FieldElementID AND CustomFieldID = @CustomFieldID;
				END
		END        
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;


