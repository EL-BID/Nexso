CREATE TABLE [dbo].[dnn_EasyDNNNewsModuleSearchable] (
    [ModuleID]     INT NOT NULL,
    [isSearchable] BIT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsModuleSearchable] PRIMARY KEY CLUSTERED ([ModuleID] ASC)
);

