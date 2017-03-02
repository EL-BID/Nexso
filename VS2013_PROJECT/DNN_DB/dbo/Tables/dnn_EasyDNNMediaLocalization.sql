CREATE TABLE [dbo].[dnn_EasyDNNMediaLocalization] (
    [PictureID]    INT             NOT NULL,
    [LocaleCode]   NVARCHAR (20)   NOT NULL,
    [LocaleString] NVARCHAR (150)  NULL,
    [Title]        NVARCHAR (250)  NULL,
    [Description]  NVARCHAR (MAX)  NULL,
    [MediaUrl]     NVARCHAR (1500) NULL,
    [PortalID]     INT             NULL,
    [Subtitle]     NVARCHAR (2000) NULL,
    CONSTRAINT [PK_dnn_EasyDNNMediaLocalization] PRIMARY KEY CLUSTERED ([PictureID] ASC, [LocaleCode] ASC),
    CONSTRAINT [FK_dnn_EasyDNNMediaLocalization_EasyGalleryPictures] FOREIGN KEY ([PictureID]) REFERENCES [dbo].[dnn_EasyGalleryPictures] ([PictureID]) ON DELETE CASCADE
);



