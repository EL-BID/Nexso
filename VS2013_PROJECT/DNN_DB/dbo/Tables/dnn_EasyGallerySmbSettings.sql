CREATE TABLE [dbo].[dnn_EasyGallerySmbSettings] (
    [ModuleID]             INT NOT NULL,
    [ShowDetailsPanel]     BIT NOT NULL,
    [ShowSocialSharing]    BIT NOT NULL,
    [ShowFacbook]          BIT NOT NULL,
    [ShowTwitter]          BIT NOT NULL,
    [ShowGooglePlus]       BIT NOT NULL,
    [ShowPinterst]         BIT NOT NULL,
    [ShowLinkedin]         BIT NOT NULL,
    [AvatarProvider]       INT NOT NULL,
    [ShowTitle]            BIT NOT NULL,
    [ShowDescription]      BIT NOT NULL,
    [ShowThumbnails]       BIT NOT NULL,
    [ShowUploaderInfo]     BIT NOT NULL,
    [ShowEmailLink]        BIT NOT NULL,
    [PostCommentToJournal] BIT NOT NULL,
    [ShowDownloadLink]     BIT CONSTRAINT [DF_dnn_EasyGallerySmbSettings_ShowDownloadLink] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_EasyGallerySmbSettings] PRIMARY KEY CLUSTERED ([ModuleID] ASC),
    CONSTRAINT [FK_dnn_EasyGallerySmbSettings_dnn_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE
);

