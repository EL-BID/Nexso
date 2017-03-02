CREATE TABLE [dbo].[dnn_EasyDNNNewsNewTags] (
    [TagID]       INT           IDENTITY (1, 1) NOT NULL,
    [Name]        NVARCHAR (50) NOT NULL,
    [PortalID]    INT           NOT NULL,
    [DateCreated] DATETIME      CONSTRAINT [DF_dnn_EasyDNNNewsNewTags_DateCreated] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsItemTags] PRIMARY KEY CLUSTERED ([TagID] ASC),
    CONSTRAINT [IX_dnn_EasyDNNNewsItemTags] UNIQUE NONCLUSTERED ([PortalID] ASC, [Name] ASC)
);

