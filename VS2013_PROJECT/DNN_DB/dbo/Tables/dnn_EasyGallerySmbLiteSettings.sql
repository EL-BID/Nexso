CREATE TABLE [dbo].[dnn_EasyGallerySmbLiteSettings] (
    [ModuleID]              INT NOT NULL,
    [ShowTitle]             BIT NOT NULL,
    [WrapperResizeDuration] INT NOT NULL,
    [ShowFacbook]           BIT NOT NULL,
    [ShowTwitter]           BIT NOT NULL,
    [ShowGooglePlus]        BIT NOT NULL,
    [ShowPinterst]          BIT NOT NULL,
    [ShowLinkedin]          BIT NOT NULL,
    CONSTRAINT [PK_dnn_EasyGallerySmbLiteSettings] PRIMARY KEY CLUSTERED ([ModuleID] ASC),
    CONSTRAINT [FK_dnn_EasyGallerySmbLiteSettings_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE
);

