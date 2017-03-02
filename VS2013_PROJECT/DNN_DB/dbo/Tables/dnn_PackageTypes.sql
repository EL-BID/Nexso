CREATE TABLE [dbo].[dnn_PackageTypes] (
    [PackageType]                    NVARCHAR (100) NOT NULL,
    [Description]                    NVARCHAR (500) NOT NULL,
    [SecurityAccessLevel]            INT            NOT NULL,
    [EditorControlSrc]               NVARCHAR (250) NULL,
    [SupportsSideBySideInstallation] BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_PackageTypes_1] PRIMARY KEY CLUSTERED ([PackageType] ASC)
);

