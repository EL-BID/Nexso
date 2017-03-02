CREATE PROCEDURE [dbo].[dnn_EasyDNNfieldsAddToExchangeRateList]
	@ACodeBase nvarchar(5),
	@PortalID int,
	@ACode nvarchar(5),
    @ExchangeRate decimal(19,6), 
    @UnitOf int,
    @DisplayOnReport bit,
    @DisplayFormat nvarchar(10)
AS 
DECLARE @NewPosition int;
DECLARE @DateCreated datetime;
DECLARE @inserted int;
SET @inserted = 0;
SET @NewPosition = 0;
SET @DateCreated = GETUTCDATE();
BEGIN TRANSACTION;
BEGIN TRY
    SET NOCOUNT ON 
	IF exists (SELECT Position FROM dbo.[dnn_EasyDNNfieldsExchangeRate] WHERE PortalID = @PortalID)
	BEGIN
		SELECT @NewPosition = max(Position) FROM dbo.[dnn_EasyDNNfieldsExchangeRate] WHERE PortalID = @PortalID;
	SET @NewPosition = @NewPosition + 10;
	END
	ELSE
	BEGIN
		SET @NewPosition = 10; 
	END
	INSERT INTO dbo.[dnn_EasyDNNfieldsExchangeRate] ([ACodeBase],[PortalID],[ACode],[Unit],[ExchangeRate],[DateTime],[Position],[DisplayOnReport],[DisplayFormat]) VALUES (@ACodeBase, @PortalID, @ACode,@UnitOf, @ExchangeRate, @DateCreated, @NewPosition, @DisplayOnReport, @DisplayFormat)
	SET @inserted = SCOPE_IDENTITY();
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;

return @inserted;


