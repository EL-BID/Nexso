CREATE TABLE [dbo].[dnn_ContentItems_Tags] (
    [ContentItemTagID] INT IDENTITY (1, 1) NOT NULL,
    [ContentItemID]    INT NOT NULL,
    [TermID]           INT NOT NULL,
    CONSTRAINT [PK_dnn_ContentItems_Tags] PRIMARY KEY CLUSTERED ([ContentItemTagID] ASC),
    CONSTRAINT [FK_dnn_ContentItems_Tags_dnn_ContentItems] FOREIGN KEY ([ContentItemID]) REFERENCES [dbo].[dnn_ContentItems] ([ContentItemID]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_dnn_ContentItems_Tags_dnn_Taxonomy_Terms] FOREIGN KEY ([TermID]) REFERENCES [dbo].[dnn_Taxonomy_Terms] ([TermID]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_ContentItems_Tags]
    ON [dbo].[dnn_ContentItems_Tags]([ContentItemID] ASC, [TermID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_ContentItems_Tags_TermID]
    ON [dbo].[dnn_ContentItems_Tags]([TermID] ASC);

