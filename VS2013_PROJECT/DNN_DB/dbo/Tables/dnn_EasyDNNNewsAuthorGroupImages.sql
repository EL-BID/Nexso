CREATE TABLE [dbo].[dnn_EasyDNNNewsAuthorGroupImages] (
    [GroupID]  INT           NOT NULL,
    [ModuleID] INT           NOT NULL,
    [Width]    INT           NOT NULL,
    [Height]   INT           NOT NULL,
    [Created]  BIT           NOT NULL,
    [Resizing] NVARCHAR (15) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsAuthorGroupImages] PRIMARY KEY CLUSTERED ([GroupID] ASC, [ModuleID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsAuthorGroupImages_EasyDNNNewsAuthorGroups] FOREIGN KEY ([GroupID]) REFERENCES [dbo].[dnn_EasyDNNNewsAuthorGroups] ([GroupID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsAuthorGroupImages_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE
);

