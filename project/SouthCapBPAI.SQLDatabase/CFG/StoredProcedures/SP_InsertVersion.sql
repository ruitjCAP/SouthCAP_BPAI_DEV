
CREATE   PROCEDURE [CFG].[SP_InsertVersion]
    @VersionCode    VARCHAR(50),
    @VersionName    VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO CFG.Version
        (VersionCode, VersionName, VersionStatus)
    VALUES
        (LTRIM(RTRIM(@VersionCode)),
         @VersionName,
         'OPEN');

END;

GO

