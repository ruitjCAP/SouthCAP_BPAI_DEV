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

