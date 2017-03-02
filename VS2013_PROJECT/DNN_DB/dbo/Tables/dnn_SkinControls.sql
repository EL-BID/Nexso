CREATE TABLE [dbo].[dnn_SkinControls] (
    [SkinControlID]            INT            IDENTITY (1, 1) NOT NULL,
    [PackageID]                INT            CONSTRAINT [DF_dnn_SkinControls_PackageID] DEFAULT ((-1)) NOT NULL,
    [ControlKey]               NVARCHAR (50)  NULL,
    [ControlSrc]               NVARCHAR (256) NULL,
    [IconFile]                 NVARCHAR (100) NULL,
    [HelpUrl]                  NVARCHAR (200) NULL,
    [SupportsPartialRendering] BIT            CONSTRAINT [DF_dnn_SkinControls_SupportsPartialRendering] DEFAULT ((0)) NOT NULL,
    [CreatedByUserID]          INT            NULL,
    [CreatedOnDate]            DATETIME       NULL,
    [LastModifiedByUserID]     INT            NULL,
    [LastModifiedOnDate]       DATETIME       NULL,
    CONSTRAINT [PK_dnn_SkinControls] PRIMARY KEY CLUSTERED ([SkinControlID] ASC),
    CONSTRAINT [FK_dnn_SkinControls_dnn_Packages] FOREIGN KEY ([PackageID]) REFERENCES [dbo].[dnn_Packages] ([PackageID]) ON DELETE CASCADE ON UPDATE CASCADE
);

