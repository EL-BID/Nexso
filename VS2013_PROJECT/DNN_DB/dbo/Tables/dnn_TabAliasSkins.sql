CREATE TABLE [dbo].[dnn_TabAliasSkins] (
    [TabAliasSkinId]       INT            IDENTITY (1, 1) NOT NULL,
    [TabId]                INT            NOT NULL,
    [PortalAliasId]        INT            NOT NULL,
    [SkinSrc]              NVARCHAR (200) NOT NULL,
    [CreatedByUserId]      INT            NULL,
    [CreatedOnDate]        DATETIME       NULL,
    [LastModifiedByUserId] INT            NULL,
    [LastModifiedOnDate]   DATETIME       NULL,
    CONSTRAINT [PK_dnn_TabAliasSkin] PRIMARY KEY CLUSTERED ([TabAliasSkinId] ASC)
);

