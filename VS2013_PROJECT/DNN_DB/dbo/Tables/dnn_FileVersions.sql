CREATE TABLE [dbo].[dnn_FileVersions] (
    [FileId]               INT            NOT NULL,
    [Version]              INT            NOT NULL,
    [FileName]             NVARCHAR (246) NOT NULL,
    [Extension]            NVARCHAR (100) NOT NULL,
    [Size]                 INT            NOT NULL,
    [Width]                INT            NULL,
    [Height]               INT            NULL,
    [ContentType]          NVARCHAR (200) NOT NULL,
    [Content]              IMAGE          NULL,
    [CreatedByUserID]      INT            NULL,
    [CreatedOnDate]        DATETIME       NULL,
    [LastModifiedByUserID] INT            NULL,
    [LastModifiedOnDate]   DATETIME       NULL,
    [SHA1Hash]             VARCHAR (40)   NULL,
    CONSTRAINT [PK_dnn_FileVersions] PRIMARY KEY CLUSTERED ([FileId] ASC, [Version] ASC),
    CONSTRAINT [FK_dnn_FileVersions_Files] FOREIGN KEY ([FileId]) REFERENCES [dbo].[dnn_Files] ([FileId]) ON DELETE CASCADE
);

