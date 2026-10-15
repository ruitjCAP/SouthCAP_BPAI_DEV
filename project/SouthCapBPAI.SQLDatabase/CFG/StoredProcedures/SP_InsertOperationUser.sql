CREATE   PROCEDURE CFG.SP_InsertOperationUser
    @UserName  VARCHAR(255),
    @UserType  VARCHAR(50)  = NULL,
    @IsActive  BIT          = 1,
    @CreatedBy VARCHAR(100) = NULL,
    @Code  INT          = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

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

