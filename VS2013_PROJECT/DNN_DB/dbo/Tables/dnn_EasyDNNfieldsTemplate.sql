CREATE TABLE [dbo].[dnn_EasyDNNfieldsTemplate] (
    [FieldsTemplateID] INT             IDENTITY (1, 1) NOT NULL,
    [PortalID]         INT             NOT NULL,
    [Name]             NVARCHAR (250)  NOT NULL,
    [Description]      NVARCHAR (1000) NOT NULL,
    [CssURL]           NVARCHAR (500)  NOT NULL,
    [HTMLURL]          NVARCHAR (500)  NOT NULL,
    [Position]         INT             NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNfieldsTemplate] PRIMARY KEY CLUSTERED ([FieldsTemplateID] ASC)
);

