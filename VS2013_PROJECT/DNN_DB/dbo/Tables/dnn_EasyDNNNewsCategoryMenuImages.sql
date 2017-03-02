CREATE TABLE [dbo].[dnn_EasyDNNNewsCategoryMenuImages] (
    [CategoryID] INT           NOT NULL,
    [ModuleID]   INT           NOT NULL,
    [Width]      INT           NOT NULL,
    [Height]     INT           NOT NULL,
    [Created]    BIT           NOT NULL,
    [Resizing]   NVARCHAR (15) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsCategoryMenuImages] PRIMARY KEY CLUSTERED ([CategoryID] ASC, [ModuleID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsCategoryMenuImages_EasyDNNNewsCategoryList] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[dnn_EasyDNNNewsCategoryList] ([CategoryID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsCategoryMenuImages_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE
);

