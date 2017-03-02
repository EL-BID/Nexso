CREATE TABLE [dbo].[dnn_SearchDeletedItems] (
    [SearchDeletedItemsID] INT            IDENTITY (1, 1) NOT NULL,
    [DateCreated]          DATETIME       DEFAULT (getutcdate()) NOT NULL,
    [Document]             NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_dnn_SearchDeletedItems] PRIMARY KEY CLUSTERED ([SearchDeletedItemsID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_SearchDeletedItems_DateCreated]
    ON [dbo].[dnn_SearchDeletedItems]([DateCreated] ASC);

