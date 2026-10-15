CREATE PROCEDURE CFG.SP_InsertConfigTable
    @TableName NVARCHAR(255),
    @TableSheetName NVARCHAR(255),
    @TableFileName NVARCHAR(255),
    @TableDescription NVARCHAR(1000) = NULL,
    @TableType NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO CFG.ConfigTable
    (
        TableName,
        TableSheetName,
        TableFileName,
        TableDescription,
        TableType,
        CreatedAt,
        CreatedBy
    )
    VALUES
    (
        @TableName,
        @TableSheetName,
        @TableFileName,
        @TableDescription,
        @TableType,
        GETDATE(),
        SYSTEM_USER
    );

END;

GO

