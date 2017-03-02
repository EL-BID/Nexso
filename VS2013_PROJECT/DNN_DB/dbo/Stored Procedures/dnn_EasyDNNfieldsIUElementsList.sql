CREATE PROCEDURE [dbo].[dnn_EasyDNNfieldsIUElementsList]
	@CustomFieldID int,
	@FieldElementID int = 0,
	@FEParentID int = null,
    @Text nvarchar(300), 
    @DefSelected bit = 0,
    @IsChilde bit = 0      
AS 
DECLARE @NewPosition int;
DECLARE @DateCreated datetime;
DECLARE @inserted int;
SET @inserted = 0;
SET @NewPosition = '0';
SET @DateCreated = GETUTCDATE();
BEGIN TRANSACTION;
BEGIN TRY
    SET NOCOUNT ON;
    -- Get last position
    IF @FieldElementID = 0 -- onda je insert
		BEGIN
			IF @FEParentID IS NULL
			BEGIN
				IF EXISTS (SELECT Position FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE CustomFieldID=@CustomFieldID AND FEParentID IS NULL)
					BEGIN
						SELECT @NewPosition = max(Position) FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE CustomFieldID=@CustomFieldID AND FEParentID IS NULL;
						SET @NewPosition = @NewPosition + 10;
					END
				ELSE
					BEGIN
						SET @NewPosition = 10; 
					END
			END
			ELSE
			BEGIN
				IF EXISTS (SELECT Position FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE CustomFieldID=@CustomFieldID AND FEParentID=@FEParentID)
					BEGIN
						SELECT @NewPosition = max(Position) FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE CustomFieldID=@CustomFieldID AND FEParentID=@FEParentID;
						SET @NewPosition = @NewPosition + 10;
					END
				ELSE
					BEGIN
						SET @NewPosition = 10; 
					END
			END
			INSERT INTO dbo.[dnn_EasyDNNfieldsMultiElements]([CustomFieldID],[FEParentID],[Text],[Position],[DefSelected])VALUES(@CustomFieldID,@FEParentID,@Text,@NewPosition,@DefSelected)
			SET @inserted = SCOPE_IDENTITY();	
		END
	ELSE -- onda je update
	BEGIN
		-- treba ustanoviti tip elementa u smislu da li je prije imao parent ili nije, jer se sad u slucaju updejta moze promjeniti parent
		DECLARE @PreviousParentID int;
		SELECT @PreviousParentID = [FEParentID] FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE FieldElementID=@FieldElementID AND CustomFieldID = @CustomFieldID;
		IF @PreviousParentID IS NULL
		BEGIN
			IF @FEParentID IS NULL -- element nije imao parent znaci sve ostaje isto
			BEGIN
				UPDATE dbo.[dnn_EasyDNNfieldsMultiElements] SET [FEParentID] = @FEParentID, [Text] = @Text WHERE FieldElementID=@FieldElementID AND CustomFieldID = @CustomFieldID;
			END
			ELSE -- element nije imao parent sad ga ima treba mjenjati poziciju
			BEGIN
				IF EXISTS (SELECT Position FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE CustomFieldID=@CustomFieldID AND FEParentID = @FEParentID)
					BEGIN
						SELECT @NewPosition = max(Position) FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE CustomFieldID=@CustomFieldID AND FEParentID = @FEParentID;
						SET @NewPosition = @NewPosition + 10;
					END
				ELSE
					BEGIN
						SET @NewPosition = 10; 
					END
				UPDATE dbo.[dnn_EasyDNNfieldsMultiElements] SET [FEParentID] = @FEParentID, [Text] = @Text, [Position] = @NewPosition WHERE FieldElementID=@FieldElementID AND CustomFieldID = @CustomFieldID; 	
			END
		END
		ELSE -- prije je imao parent
		BEGIN
			IF @FEParentID IS NULL -- element je imao parent sada ga vise nema. treba promjeniti poziciju na zadnjeg u listi koji nemaju parent
			BEGIN
				IF EXISTS (SELECT Position FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE CustomFieldID=@CustomFieldID AND FEParentID IS NULL)
					BEGIN
						SELECT @NewPosition = max(Position) FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE CustomFieldID=@CustomFieldID AND FEParentID IS NULL;
						SET @NewPosition = @NewPosition + 10;
					END
				ELSE
					BEGIN
						SET @NewPosition = 10; 
					END
				UPDATE dbo.[dnn_EasyDNNfieldsMultiElements] SET [FEParentID] = @FEParentID, [Text] = @Text, [Position] = @NewPosition WHERE FieldElementID=@FieldElementID AND CustomFieldID = @CustomFieldID; 
			END
			ELSE -- element je imao parent i ima ga i dalje, treba vidjeti da li je isti parent ili razliciti, ako je isti ne treba mjenjati poziciju ako je razliciti onda treba
			BEGIN
				IF @PreviousParentID = @FEParentID -- parent je isti
				BEGIN
					UPDATE dbo.[dnn_EasyDNNfieldsMultiElements] SET [Text] = @Text WHERE FieldElementID=@FieldElementID AND CustomFieldID = @CustomFieldID;
				END
				ELSE			
				BEGIN
					IF EXISTS (SELECT Position FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE CustomFieldID=@CustomFieldID AND FEParentID = @FEParentID)
						BEGIN
							SELECT @NewPosition = max(Position) FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE CustomFieldID=@CustomFieldID AND FEParentID = @FEParentID;
							SET @NewPosition = @NewPosition + 10;
						END
					ELSE
						BEGIN
							SET @NewPosition = 10; 
						END
					UPDATE dbo.[dnn_EasyDNNfieldsMultiElements] SET [FEParentID] = @FEParentID, [Text] = @Text, [Position] = @NewPosition WHERE FieldElementID=@FieldElementID AND CustomFieldID = @CustomFieldID;
				END
			END
		END
	END
	
	IF @IsChilde = 1 -- treba update main cf
	BEGIN
		IF NOT EXISTS (SELECT CustomFieldID FROM dbo.[dnn_EasyDNNfields] WHERE [IsChilde] = 1 AND CustomFieldID=@CustomFieldID)
		BEGIN
			UPDATE dbo.[dnn_EasyDNNfields] SET [IsChilde] = 1 WHERE CustomFieldID=@CustomFieldID;
		END
	END
	IF @FEParentID IS NOT NULL
	BEGIN
		DECLARE @CFParentID int;
		SELECT @CFParentID = CustomFieldID FROM dbo.[dnn_EasyDNNfields] WHERE CustomFieldID IN (SELECT CustomFieldID FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE FieldElementID = @FEParentID)
		IF @CFParentID IS NOT NULL
		BEGIN
			IF NOT EXISTS (SELECT CustomFieldID FROM dbo.[dnn_EasyDNNfields] WHERE [IsParent] = 1 AND CustomFieldID=@CFParentID)
			BEGIN
				UPDATE dbo.[dnn_EasyDNNfields] SET [IsParent]= 1 WHERE CustomFieldID = @CFParentID;
			END
		END
	END     
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;

return @inserted;


