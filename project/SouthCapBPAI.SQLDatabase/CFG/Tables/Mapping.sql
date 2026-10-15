CREATE TABLE [CFG].[Mapping] (
    [MappingId]        INT           IDENTITY (1, 1) NOT NULL,
    [Code]             VARCHAR (50)  NULL,
    [IDNormalizacao]   VARCHAR (50)  NULL,
    [Ficheiro]         VARCHAR (100) NOT NULL,
    [Sheet]            VARCHAR (100) NOT NULL,
    [Tabela]           VARCHAR (200) NOT NULL,
    [Campo]            VARCHAR (200) NOT NULL,
    [Formato]          VARCHAR (100) NULL,
    [TipoInput]        VARCHAR (200) NULL,
    [TOC]              BIT           NULL,
    [OPE]              BIT           NULL,
    [NOS]              BIT           NULL,
    [MAXIRENT]         BIT           NULL,
    [CIM]              BIT           NULL,
    [EIF]              BIT           NULL,
    [SC]               BIT           NULL,
    [TORDELIS]         BIT           NULL,
    [LigacoesExternas] VARCHAR (MAX) NULL,
    [Calculos]         VARCHAR (MAX) NULL,
    [MomentoExecucao]  INT           NULL,
    [Observacoes]      VARCHAR (MAX) NULL,
    [CreatedDate]      DATETIME2 (0) NOT NULL,
    [ModifiedDate]     DATETIME2 (0) NULL,
    CONSTRAINT [PK_Mapping] PRIMARY KEY CLUSTERED ([MappingId] ASC)
);


GO

