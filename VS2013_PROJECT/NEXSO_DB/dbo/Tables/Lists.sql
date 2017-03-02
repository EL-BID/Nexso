CREATE TABLE [dbo].[Lists] (
    [Key]       VARCHAR (50)  NOT NULL,
    [Category]  VARCHAR (50)  NOT NULL,
    [Culture]   VARCHAR (10)  NOT NULL,
    [Value]     VARCHAR (200) NOT NULL,
    [ValueType] VARCHAR (50)  NULL,
    [Label]     VARCHAR (500) NULL,
    [Order]     INT           CONSTRAINT [DF_Lists_Order] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Lists] PRIMARY KEY CLUSTERED ([Key] ASC, [Category] ASC, [Culture] ASC)
);

