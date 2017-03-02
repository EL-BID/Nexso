CREATE TABLE [dbo].[dnn_ModuleControls] (
    [ModuleControlID]          INT            IDENTITY (1, 1) NOT NULL,
    [ModuleDefID]              INT            NULL,
    [ControlKey]               NVARCHAR (50)  NULL,
    [ControlTitle]             NVARCHAR (50)  NULL,
    [ControlSrc]               NVARCHAR (256) NULL,
    [IconFile]                 NVARCHAR (100) NULL,
    [ControlType]              INT            NOT NULL,
    [ViewOrder]                INT            NULL,
    [HelpUrl]                  NVARCHAR (200) NULL,
    [SupportsPartialRendering] BIT            CONSTRAINT [DF_dnn_ModuleControls_SupportsPartialRendering] DEFAULT ((0)) NOT NULL,
    [CreatedByUserID]          INT            NULL,
    [CreatedOnDate]            DATETIME       NULL,
    [LastModifiedByUserID]     INT            NULL,
    [LastModifiedOnDate]       DATETIME       NULL,
    [SupportsPopUps]           BIT            CONSTRAINT [DF_dnn_ModuleControls_SupportsPopUps] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_ModuleControls] PRIMARY KEY CLUSTERED ([ModuleControlID] ASC),
    CONSTRAINT [FK_dnn_ModuleControls_dnn_ModuleDefinitions] FOREIGN KEY ([ModuleDefID]) REFERENCES [dbo].[dnn_ModuleDefinitions] ([ModuleDefID]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_ModuleControls] UNIQUE NONCLUSTERED ([ModuleDefID] ASC, [ControlKey] ASC, [ControlSrc] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_ModuleControls_ControlKey_ViewOrder]
    ON [dbo].[dnn_ModuleControls]([ControlKey] ASC, [ViewOrder] ASC);

