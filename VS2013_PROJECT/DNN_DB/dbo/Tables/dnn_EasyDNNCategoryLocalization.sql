CREATE TABLE [dbo].[dnn_EasyDNNCategoryLocalization] (
    [CategoryID]   INT             NOT NULL,
    [PortalID]     INT             NOT NULL,
    [LocaleCode]   NVARCHAR (20)   NOT NULL,
    [LocaleString] NVARCHAR (150)  NULL,
    [Title]        NVARCHAR (500)  NULL,
    [Description]  NVARCHAR (2000) NULL,
    CONSTRAINT [PK_dnn_EasyDNNCategoryLocalization] PRIMARY KEY CLUSTERED ([CategoryID] ASC, [LocaleCode] ASC),
    CONSTRAINT [FK_dnn_EasyDNNCategoryLocalization_dnn_EasyGalleryCategory] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[dnn_EasyGalleryCategory] ([CategoryID]) ON DELETE CASCADE
);

