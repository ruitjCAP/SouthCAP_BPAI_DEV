CREATE   PROCEDURE dbo.usp_InsertOperationUserTest
     @UserCode  INT,
    @UserName  VARCHAR(255),
    @UserType  VARCHAR(50)  = NULL,
    @IsActive  BIT          = 1,
    @CreatedBy VARCHAR(100) = NULL,
    @Code  INT          = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @UserName IS NULL OR LTRIM(RTRIM(@UserName)) = ''
    BEGIN
        THROW 50001, 'UserName is required.', 1;
    END

    INSERT INTO dbo.OperationUserTest
        (UserCode,UserName, UserType, IsActive, CreatedAt, CreatedBy)
    VALUES
        (@UserCode,
        LTRIM(RTRIM(@UserName)),
         @UserType,
         @IsActive,
         SYSDATETIME(),
         COALESCE(@CreatedBy, ORIGINAL_LOGIN()));

    SET @Code = SCOPE_IDENTITY();

END;

GO

