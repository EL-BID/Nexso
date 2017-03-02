CREATE TABLE [dbo].[dnn_EasyDNNNewsAuthorProfileImages] (
    [UserID]   INT           NOT NULL,
    [ModuleID] INT           NOT NULL,
    [Width]    INT           NOT NULL,
    [Height]   INT           NOT NULL,
    [Created]  BIT           NOT NULL,
    [Resizing] NVARCHAR (15) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsAuthorProfileImages] PRIMARY KEY CLUSTERED ([UserID] ASC, [ModuleID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsAuthorProfileImages_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsAuthorProfileImages_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE
);

