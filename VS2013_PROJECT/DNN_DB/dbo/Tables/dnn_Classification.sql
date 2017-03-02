CREATE TABLE [dbo].[dnn_Classification] (
    [ClassificationId]   INT            IDENTITY (1, 1) NOT NULL,
    [ClassificationName] NVARCHAR (200) NOT NULL,
    [ParentId]           INT            NULL,
    CONSTRAINT [PK_dnn_VendorCategory] PRIMARY KEY CLUSTERED ([ClassificationId] ASC),
    CONSTRAINT [FK_dnn_Classification_dnn_Classification] FOREIGN KEY ([ParentId]) REFERENCES [dbo].[dnn_Classification] ([ClassificationId])
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Classification]
    ON [dbo].[dnn_Classification]([ParentId] ASC);

