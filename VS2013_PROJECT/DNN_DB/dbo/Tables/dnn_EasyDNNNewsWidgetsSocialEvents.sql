CREATE TABLE [dbo].[dnn_EasyDNNNewsWidgetsSocialEvents] (
    [ModuleID]            INT            NOT NULL,
    [NewsModuleID]        INT            NOT NULL,
    [HTMLTemplate]        NVARCHAR (256) NOT NULL,
    [Theme]               NVARCHAR (256) NOT NULL,
    [ThemeStyle]          NVARCHAR (256) NOT NULL,
    [ShowActionBar]       BIT            NOT NULL,
    [ShowGoingUsers]      BIT            NOT NULL,
    [ShowNotGoingUsers]   BIT            NOT NULL,
    [ShowMaybeGoingUsers] BIT            NOT NULL,
    [Imported]            BIT            NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsWidgetsSocialEvents] PRIMARY KEY CLUSTERED ([ModuleID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsWidgetsSocialEvents_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE
);

