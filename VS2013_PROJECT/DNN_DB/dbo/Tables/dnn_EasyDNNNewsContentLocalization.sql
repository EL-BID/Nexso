CREATE TABLE [dbo].[dnn_EasyDNNNewsContentLocalization] (
    [ArticleID]            INT             NOT NULL,
    [LocaleCode]           NVARCHAR (20)   NOT NULL,
    [LocaleString]         NVARCHAR (150)  NULL,
    [Title]                NVARCHAR (800)  NOT NULL,
    [SubTitle]             NVARCHAR (4000) NULL,
    [Summary]              NVARCHAR (4000) NULL,
    [Article]              NVARCHAR (MAX)  NULL,
    [DetailType]           NVARCHAR (50)   NULL,
    [DetailTypeData]       NVARCHAR (400)  NULL,
    [clTitleLink]          NVARCHAR (800)  DEFAULT ('') NOT NULL,
    [MetaDecription]       NVARCHAR (1000) DEFAULT ('') NOT NULL,
    [MetaKeywords]         NVARCHAR (500)  DEFAULT ('') NOT NULL,
    [MainImageTitle]       NVARCHAR (500)  NULL,
    [MainImageDescription] NVARCHAR (2000) NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsContentLocalization] PRIMARY KEY CLUSTERED ([ArticleID] ASC, [LocaleCode] ASC),
    CONSTRAINT [chk_dnn_EasyDNNNewsContentLocalization_clTitleLink_Lenght] CHECK (len([clTitleLink])>(0)),
    CONSTRAINT [chk_dnn_EasyDNNNewsContentLocalization_Title_Lenght] CHECK (len([Title])>(0)),
    CONSTRAINT [FK_dnn_EasyDNNNewsContentLocalization_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE
);

