CREATE TABLE [dbo].[dnn_EasyDNNfieldsCurrency] (
    [ACode]    NVARCHAR (5)   NOT NULL,
    [NCode]    INT            NOT NULL,
    [Currency] NVARCHAR (250) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNfieldsCurrency] PRIMARY KEY CLUSTERED ([ACode] ASC)
);


GO

CREATE TRIGGER [dbo].[dnn_EasyDNNnewsTCurrencyBaseCorrectOnDelete] ON [dbo].[dnn_EasyDNNfieldsCurrency]
	AFTER DELETE
AS
DECLARE @CodeOld AS nvarchar(5);
DECLARE @CodeBase AS nvarchar(5);
BEGIN
	SET NOCOUNT ON;
	SET @CodeOld = (SELECT [ACode] FROM deleted)
	SET @CodeBase = (SELECT [ACodeBase] FROM dbo.[dnn_EasyDNNfieldsCurrencySettings] WHERE [ACodeBase] = @CodeOld)
	IF(@CodeBase IS NOT NULL)
	BEGIN
		DELETE FROM dbo.[dnn_EasyDNNfieldsCurrencySettings] WHERE [ACodeBase] = @CodeOld
	END
END;



GO

CREATE TRIGGER [dbo].[dnn_EasyDNNnewsTCurrencyBaseCorrectOnUpdate] ON [dbo].[dnn_EasyDNNfieldsCurrency]
	AFTER UPDATE
AS
DECLARE @CodeNew AS NVARCHAR(5);
DECLARE @CodeOld AS NVARCHAR(5);
DECLARE @CodeNewExists AS NVARCHAR(5);
BEGIN
	SET NOCOUNT ON;
	SET @CodeNew = (SELECT TOP (1) [ACode] FROM inserted)
	SET @CodeOld = (SELECT TOP (1) [ACode] FROM deleted)
	SET @CodeNewExists = (SELECT TOP (1) [ACode] FROM dbo.[dnn_EasyDNNfieldsCurrency] WHERE [ACode] = @CodeNew)
	IF(@CodeNewExists IS NOT NULL)
	BEGIN
		IF(@CodeNew <> @CodeOld)
		BEGIN
			UPDATE dbo.[dnn_EasyDNNfieldsCurrencySettings] SET [ACodeBase] = @CodeNew WHERE [ACodeBase] = @CodeOld
		END
	END
END;


