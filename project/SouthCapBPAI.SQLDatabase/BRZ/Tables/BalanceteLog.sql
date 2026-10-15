CREATE TABLE [BRZ].[BalanceteLog] (
    [log_id]          BIGINT           IDENTITY (1, 1) NOT NULL,
    [execucao_id]     UNIQUEIDENTIFIER NOT NULL,
    [data_hora]       DATETIME2 (7)    DEFAULT (sysdatetime()) NULL,
    [etapa]           NVARCHAR (50)    NOT NULL,
    [status]          NVARCHAR (20)    NOT NULL,
    [mensagem]        NVARCHAR (1000)  NOT NULL,
    [ficheiro_origem] NVARCHAR (255)   NULL,
    [ativo_codigo]    NVARCHAR (20)    NULL,
    [periodo_inicio]  DATE             NULL,
    [periodo_fim]     DATE             NULL,
    [linhas_afetadas] INT              NULL,
    [num_versao]      INT              NULL,
    [duracao_ms]      INT              NULL,
    [detalhe_erro]    NVARCHAR (MAX)   NULL,
    [dry_run]         BIT              DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([log_id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_log_data_hora]
    ON [BRZ].[BalanceteLog]([data_hora] DESC);


GO

CREATE NONCLUSTERED INDEX [IX_log_execucao]
    ON [BRZ].[BalanceteLog]([execucao_id] ASC);


GO

