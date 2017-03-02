CREATE TABLE [dbo].[dnn_EasyGalleryUserPermissions] (
    [UserID]          INT NOT NULL,
    [ModuleID]        INT NOT NULL,
    [ShowComments]    BIT NOT NULL,
    [AllowToComment]  BIT NOT NULL,
    [CommentEditing]  BIT NOT NULL,
    [CommentDeleting] BIT NOT NULL,
    [ShowRating]      BIT NOT NULL,
    [AllowToRate]     BIT NOT NULL,
    [AllowToDownload] BIT NOT NULL,
    [AllowToLike]     BIT DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_EasyGalleryUserPermissions] PRIMARY KEY CLUSTERED ([UserID] ASC, [ModuleID] ASC),
    CONSTRAINT [FK_dnn_EasyGalleryUserPermissions_dnn_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyGalleryUserPermissions_dnn_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE
);

