CREATE TABLE [dbo].[dnn_EasyDNNNewsLinksLocalization] (
    [LinkID]     INT           NOT NULL,
    [LocaleCode] NVARCHAR (20) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsLinksLocalization] PRIMARY KEY CLUSTERED ([LinkID] ASC, [LocaleCode] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsLinksLocalization_EasyDNNNewsLinks] FOREIGN KEY ([LinkID]) REFERENCES [dbo].[dnn_EasyDNNNewsLinks] ([LinkID]) ON DELETE CASCADE
);

