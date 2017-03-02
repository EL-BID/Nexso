CREATE TABLE [dbo].[dnn_VendorClassification] (
    [VendorClassificationId] INT IDENTITY (1, 1) NOT NULL,
    [VendorId]               INT NOT NULL,
    [ClassificationId]       INT NOT NULL,
    CONSTRAINT [PK_dnn_VendorClassification] PRIMARY KEY CLUSTERED ([VendorClassificationId] ASC),
    CONSTRAINT [FK_dnn_VendorClassification_dnn_Classification] FOREIGN KEY ([ClassificationId]) REFERENCES [dbo].[dnn_Classification] ([ClassificationId]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_VendorClassification_dnn_Vendors] FOREIGN KEY ([VendorId]) REFERENCES [dbo].[dnn_Vendors] ([VendorId]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_VendorClassification] UNIQUE NONCLUSTERED ([VendorId] ASC, [ClassificationId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_VendorClassification_1]
    ON [dbo].[dnn_VendorClassification]([ClassificationId] ASC);

