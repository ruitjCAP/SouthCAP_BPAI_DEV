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

