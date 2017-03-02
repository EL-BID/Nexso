CREATE TABLE [dbo].[dnn_TabVersions] (
    [TabVersionId]         INT      IDENTITY (1, 1) NOT NULL,
    [TabId]                INT      NOT NULL,
    [Version]              INT      NOT NULL,
    [TimeStamp]            DATETIME NOT NULL,
    [IsPublished]          BIT      NOT NULL,
    [CreatedByUserID]      INT      NOT NULL,
    [CreatedOnDate]        DATETIME NOT NULL,
    [LastModifiedByUserID] INT      NOT NULL,
    [LastModifiedOnDate]   DATETIME NOT NULL,
    CONSTRAINT [PK_dnn_TabVersions] PRIMARY KEY CLUSTERED ([TabVersionId] ASC),
    CONSTRAINT [FK_dnn_TabVersions_dnn_TabId] FOREIGN KEY ([TabId]) REFERENCES [dbo].[dnn_Tabs] ([TabID]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_TabVersions] UNIQUE NONCLUSTERED ([TabId] ASC, [Version] DESC)
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_TabVersions_TabId]
    ON [dbo].[dnn_TabVersions]([TabId] ASC);

