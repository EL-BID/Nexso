CREATE TABLE [dbo].[dnn_ContentTypes] (
    [ContentTypeID] INT            IDENTITY (1, 1) NOT NULL,
    [ContentType]   NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_dnn_ContentTypes] PRIMARY KEY CLUSTERED ([ContentTypeID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_ContentTypes_ContentType]
    ON [dbo].[dnn_ContentTypes]([ContentType] ASC);

