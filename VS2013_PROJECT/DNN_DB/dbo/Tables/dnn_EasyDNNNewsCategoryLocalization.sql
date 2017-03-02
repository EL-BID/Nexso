CREATE TABLE [dbo].[dnn_EasyDNNNewsCategoryLocalization] (
    [CategoryID]   INT            NOT NULL,
    [LocaleCode]   NVARCHAR (20)  NOT NULL,
    [LocaleString] NVARCHAR (150) NULL,
    [Title]        NVARCHAR (200) NOT NULL,
    [CategoryText] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsCategoryLocalization] PRIMARY KEY CLUSTERED ([CategoryID] ASC, [LocaleCode] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsCategoryLocalization_EasyDNNNewsCategoryList] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[dnn_EasyDNNNewsCategoryList] ([CategoryID]) ON DELETE CASCADE
);

