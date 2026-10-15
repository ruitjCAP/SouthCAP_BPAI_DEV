CREATE TABLE [BRZ].[Balancete] (
    [balancete_id]          BIGINT          IDENTITY (1, 1) NOT NULL,
    [ativo_codigo]          NVARCHAR (20)   NOT NULL,
    [periodo_inicio]        DATE            NOT NULL,
    [periodo_fim]           DATE            NOT NULL,
    [conta]                 NVARCHAR (30)   NOT NULL,
    [designacao]            NVARCHAR (500)  NULL,
    [debito_periodo_eur]    DECIMAL (19, 2) NULL,
    [credito_periodo_eur]   DECIMAL (19, 2) NULL,
    [saldo_periodo_eur]     DECIMAL (19, 2) NULL,
    [debito_acumulado_eur]  DECIMAL (19, 2) NULL,
    [credito_acumulado_eur] DECIMAL (19, 2) NULL,
    [saldo_acumulado_eur]   DECIMAL (19, 2) NULL,
    [ficheiro_origem]       NVARCHAR (255)  NULL,
    [linha_origem]          INT             NULL,
    [hash_linha]            CHAR (64)       NULL,
    [data_carga]            DATETIME2 (7)   DEFAULT (sysdatetime()) NULL,
    [data_versao]           DATETIME2 (7)   DEFAULT (sysdatetime()) NULL,
    [num_versao]            INT             DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([balancete_id] ASC),
    CONSTRAINT [IX_balancete_composite_1] CHECK ([periodo_inicio]<=[periodo_fim])
);


GO

CREATE NONCLUSTERED INDEX [IX_balancete_ativo_periodo]
    ON [BRZ].[Balancete]([ativo_codigo] ASC, [periodo_inicio] ASC, [periodo_fim] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_balancete_carga]
    ON [BRZ].[Balancete]([data_carga] DESC);


GO

CREATE NONCLUSTERED INDEX [IX_balancete_conta]
    ON [BRZ].[Balancete]([conta] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_balancete_num_versao]
    ON [BRZ].[Balancete]([ativo_codigo] ASC, [periodo_inicio] ASC, [periodo_fim] ASC, [num_versao] DESC);


GO

