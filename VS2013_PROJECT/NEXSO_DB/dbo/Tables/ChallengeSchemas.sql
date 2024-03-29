﻿CREATE TABLE [dbo].[ChallengeSchemas] (
    [ChallengeReference] VARCHAR (50)  NOT NULL,
    [ChallengeTitle]     VARCHAR (100) NOT NULL,
    [Description]        VARCHAR (500) NULL,
    [Created]            DATETIME      NOT NULL,
    [Updated]            DATETIME      NOT NULL,
    [Url]                VARCHAR (100) NULL,
    [EnterUrl]           VARCHAR (100) NULL,
    [OutUrl]             VARCHAR (100) NULL,
    [Flavor]             VARCHAR (50)  NULL,
    [PreLaunch]          DATETIME      NULL,
    [Launch]             DATETIME      NULL,
    [EntryFrom]          DATETIME      NULL,
    [EntryTo]            DATETIME      NULL,
    [ScoringL1From]      DATETIME      NULL,
    [ScoringL2From]      DATETIME      NULL,
    [ScoringL3From]      DATETIME      NULL,
    [ScoringL1To]        DATETIME      NULL,
    [ScoringL2To]        DATETIME      NULL,
    [ScoringL3To]        DATETIME      NULL,
    [Closed]             DATETIME      NULL,
    [PublishType]        VARCHAR (50)  NULL,
    [VisibilityFront]    BIT           NULL,
    [Brand]              VARCHAR (50)  NULL,
    CONSTRAINT [PK_Challenges_1] PRIMARY KEY CLUSTERED ([ChallengeReference] ASC)
);

