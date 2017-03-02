CREATE TABLE [dbo].[dnn_Dashboard_Controls] (
    [DashboardControlID]             INT            IDENTITY (1, 1) NOT NULL,
    [DashboardControlKey]            NVARCHAR (50)  NOT NULL,
    [IsEnabled]                      BIT            NOT NULL,
    [DashboardControlSrc]            NVARCHAR (250) NOT NULL,
    [DashboardControlLocalResources] NVARCHAR (250) NOT NULL,
    [ControllerClass]                NVARCHAR (250) NULL,
    [ViewOrder]                      INT            CONSTRAINT [DF_dnn_Dashboard_Controls_ViewOrder] DEFAULT ((0)) NOT NULL,
    [PackageID]                      INT            CONSTRAINT [DF_dnn_Dashboard_Controls_PackageID] DEFAULT ((-1)) NOT NULL,
    CONSTRAINT [PK_dnn_Dashboard] PRIMARY KEY CLUSTERED ([DashboardControlID] ASC),
    CONSTRAINT [FK_dnn_Dashboard_Controls_dnn_Packages] FOREIGN KEY ([PackageID]) REFERENCES [dbo].[dnn_Packages] ([PackageID]) ON DELETE CASCADE ON UPDATE CASCADE
);

