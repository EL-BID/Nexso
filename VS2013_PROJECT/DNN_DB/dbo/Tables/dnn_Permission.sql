CREATE TABLE [dbo].[dnn_Permission] (
    [PermissionID]         INT          IDENTITY (1, 1) NOT NULL,
    [PermissionCode]       VARCHAR (50) NOT NULL,
    [ModuleDefID]          INT          NOT NULL,
    [PermissionKey]        VARCHAR (50) NOT NULL,
    [PermissionName]       VARCHAR (50) NOT NULL,
    [ViewOrder]            INT          CONSTRAINT [DF_dnn_Permission_ViewOrder] DEFAULT ((9999)) NOT NULL,
    [CreatedByUserID]      INT          NULL,
    [CreatedOnDate]        DATETIME     NULL,
    [LastModifiedByUserID] INT          NULL,
    [LastModifiedOnDate]   DATETIME     NULL,
    CONSTRAINT [PK_dnn_Permission] PRIMARY KEY CLUSTERED ([PermissionID] ASC),
    CONSTRAINT [IX_dnn_Permission] UNIQUE NONCLUSTERED ([PermissionCode] ASC, [ModuleDefID] ASC, [PermissionKey] ASC)
);

