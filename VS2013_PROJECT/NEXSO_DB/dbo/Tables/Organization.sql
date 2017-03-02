CREATE TABLE [dbo].[Organization] (
    [OrganizationID] UNIQUEIDENTIFIER NOT NULL,
    [Code]           VARCHAR (100)    NULL,
    [Name]           VARCHAR (100)    NULL,
    [Address]        VARCHAR (200)    NULL,
    [Phone]          VARCHAR (100)    NULL,
    [Email]          VARCHAR (100)    NULL,
    [ContactEmail]   VARCHAR (100)    NULL,
    [Website]        VARCHAR (100)    NULL,
    [Twitter]        VARCHAR (100)    NULL,
    [Skype]          VARCHAR (100)    NULL,
    [Facebook]       VARCHAR (100)    NULL,
    [GooglePlus]     VARCHAR (100)    NULL,
    [LinkedIn]       VARCHAR (100)    NULL,
    [Description]    VARCHAR (800)    NULL,
    [Logo]           VARCHAR (200)    NULL,
    [Country]        VARCHAR (50)     NULL,
    [Region]         VARCHAR (50)     NULL,
    [City]           VARCHAR (50)     NULL,
    [ZipCode]        VARCHAR (50)     NULL,
    [Created]        DATETIME         NULL,
    [Updated]        DATETIME         NULL,
    [Latitude]       DECIMAL (10, 7)  NULL,
    [Longitude]      DECIMAL (10, 7)  NULL,
    [GoogleLocation] VARCHAR (1000)   NULL,
    [Language]       VARCHAR (5)      NULL,
    [Year]           INT              NULL,
    [Staff]          INT              NULL,
    [Budget]         MONEY            NULL,
    [CheckedBy]      VARCHAR (30)     NULL,
    [CreatedOn]      DATETIME         NULL,
    [UpdatedOn]      DATETIME         NULL,
    [CreatedBy]      INT              NULL,
    [Deleted]        BIT              NULL,
    CONSTRAINT [PK_Organization] PRIMARY KEY CLUSTERED ([OrganizationID] ASC)
);





