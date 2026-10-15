CREATE OR ALTER PROCEDURE CFG.SP_InsertOperationUser
    @UserName  VARCHAR(255),
    @UserType  VARCHAR(50)  = NULL,
    @IsActive  BIT          = 1,
    @CreatedBy VARCHAR(100) = NULL
AS
BEGIN

    INSERT INTO CFG.OperationUser
        (UserName, UserType, IsActive, CreatedAt, CreatedBy)
    VALUES
        (LTRIM(RTRIM(@UserName)),
         @UserType,
         @IsActive,
         SYSDATETIME(),
         SYSTEM_USER);

END;
GO



CREATE OR ALTER PROCEDURE CFG.SP_InsertCalculation
    @CalculationCode        VARCHAR(255),
    @ItemId                 INT,
    @CalculationOrder       INT             = NULL,
    @CalculationType        VARCHAR(50)     = NULL,
    @IsActive               BIT             = 1,
    @CalculationDescription NVARCHAR(1000)  = NULL,
    @CreatedBy              VARCHAR(100)    = NULL
    
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO CFG.Calculation
        (CalculationCode, 
         ItemId,
         CalculationOrder,
         CalculationType,
         IsActive,
         CalculationDescription,
         CreatedBy)
    VALUES
        (@CalculationCode,
         @ItemId,
         @CalculationOrder,
         @CalculationType,
         @IsActive,
         @CalculationDescription,
         SYSTEM_USER);

END;
GO



CREATE PROCEDURE CFG.SP_InsertConfigEntity
    @ParentEntityId INT = NULL,
    @EntityName NVARCHAR(255),
    @EntityType VARCHAR(100) = NULL,
    @EntityDescription NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO CFG.ConfigEntity (
        ParentEntityId,
        EntityName,
        EntityType,
        EntityDescription,
        CreatedAt,
        CreatedBy
    )
    VALUES (
        @ParentEntityId,
        @EntityName,
        @EntityType,
        @EntityDescription,
        GETDATE(),
        SYSTEM_USER
    );

    
END;
GO


CREATE PROCEDURE CFG.SP_InsertConfigItem
    @TableId INT,
    @ItemName NVARCHAR(255),
    @ParentItemID INT = NULL,
    @ItemType VARCHAR(20) = NULL,
    @ItemOrder INT = NULL,
    @InputType VARCHAR(50) = NULL,
    @DataType VARCHAR(50) = NULL,
    @ItemMandatory BIT,
    @ItemDescription NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO CFG.ConfigItem
    (
        TableId,
        ItemName,
        ParentItemID,
        ItemType,
        ItemOrder,
        InputType,
        DataType,
        ItemMandatory,
        ItemDescription,
        CreatedAt,
        CreatedBy
    )
    VALUES
    (
        @TableId,
        @ItemName,
        @ParentItemID,
        @ItemType,
        @ItemOrder,
        @InputType,
        @DataType,
        @ItemMandatory,
        @ItemDescription,
        GETDATE(),
        SYSTEM_USER
    );
END;
GO


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





