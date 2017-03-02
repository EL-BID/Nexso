CREATE TABLE [dbo].[Solution] (
    [SolutionId]            UNIQUEIDENTIFIER NOT NULL,
    [OrganizationId]        UNIQUEIDENTIFIER NOT NULL,
    [SolutionTypeId]        INT              NULL,
    [Title]                 VARCHAR (200)    NULL,
    [TagLine]               VARCHAR (500)    NULL,
    [Description]           VARCHAR (1500)   NULL,
    [Biography]             VARCHAR (1000)   NULL,
    [Challenge]             VARCHAR (1000)   NULL,
    [Approach]              VARCHAR (1000)   NULL,
    [Results]               VARCHAR (1000)   NULL,
    [ImplementationDetails] VARCHAR (2000)   NULL,
    [AdditionalCost]        VARCHAR (500)    NULL,
    [AvailableResources]    VARCHAR (500)    NULL,
    [TimeFrame]             VARCHAR (500)    NULL,
    [Duration]              INT              NULL,
    [DurationDetails]       VARCHAR (500)    NULL,
    [SolutionStatusId]      INT              NULL,
    [SolutionType]          VARCHAR (50)     NULL,
    [Topic]                 INT              NULL,
    [Language]              VARCHAR (5)      NULL,
    [CreatedUserId]         INT              NULL,
    [Deleted]               BIT              CONSTRAINT [DF_Solution_Deleted] DEFAULT ((0)) NULL,
    [Country]               NCHAR (50)       NULL,
    [Region]                NCHAR (50)       NULL,
    [City]                  NCHAR (50)       NULL,
    [Address]               VARCHAR (200)    NULL,
    [ZipCode]               VARCHAR (50)     NULL,
    [Logo]                  VARCHAR (200)    NULL,
    [Cost1]                 DECIMAL (16, 2)  NULL,
    [Cost2]                 DECIMAL (16, 2)  NULL,
    [Cost3]                 DECIMAL (16, 2)  NULL,
    [DeliveryFormat]        INT              NULL,
    [Cost]                  DECIMAL (20, 2)  NULL,
    [CostType]              INT              NULL,
    [CostDetails]           VARCHAR (500)    NULL,
    [SolutionState]         INT              NULL,
    [Beneficiaries]         INT              NULL,
    [DateCreated]           DATETIME         NULL,
    [DateUpdated]           DATETIME         NULL,
    [ChallengeReference]    VARCHAR (50)     NULL,
    [CustomData]            VARCHAR (MAX)    NULL,
    [CustomDataTemplate]    VARCHAR (MAX)    NULL,
    [CustomDataScore]       VARCHAR (MAX)    NULL,
    [CustomScore]           FLOAT (53)       NULL,
    [DatePublished]         DATETIME         NULL,
    [VideoObject]           VARCHAR (500)    NULL,
    CONSTRAINT [PK_Solution] PRIMARY KEY CLUSTERED ([SolutionId] ASC),
    CONSTRAINT [FK_Solution_Organization] FOREIGN KEY ([OrganizationId]) REFERENCES [dbo].[Organization] ([OrganizationID])
);


GO
ALTER TABLE [dbo].[Solution] NOCHECK CONSTRAINT [FK_Solution_Organization];





