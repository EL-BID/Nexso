CREATE TABLE [dbo].[dnn_EasyDNNNewsTagsLocalization] (
    [TagID]      INT           NOT NULL,
    [LocaleCode] NVARCHAR (20) NOT NULL,
    [Name]       NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsTagsLocalization] PRIMARY KEY CLUSTERED ([TagID] ASC, [LocaleCode] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsTagsLocalization_EasyDNNNewsNewTags] FOREIGN KEY ([TagID]) REFERENCES [dbo].[dnn_EasyDNNNewsNewTags] ([TagID]) ON DELETE CASCADE
);

