CREATE TABLE [dbo].[dnn_Version] (
    [VersionId]   INT           IDENTITY (1, 1) NOT NULL,
    [Major]       INT           NOT NULL,
    [Minor]       INT           NOT NULL,
    [Build]       INT           NOT NULL,
    [Name]        NVARCHAR (50) NULL,
    [CreatedDate] DATETIME      NOT NULL,
    CONSTRAINT [PK_dnn_Version] PRIMARY KEY CLUSTERED ([VersionId] ASC),
    CONSTRAINT [IX_dnn_Version] UNIQUE NONCLUSTERED ([Major] ASC, [Minor] ASC, [Build] ASC)
);

