/*
codeunit 50023 ScaleIntegrationCOD
{
    //Version MITL225
    trigger OnRun()
    begin
        SQLConnection();
    end;

    var
        myInt: Integer;

    local procedure SQLConnection()
    var
        DatabaseName: Text;
        DatabaseConnectionString: Text;
    begin
        DatabaseName := 'BCTEST';
        DatabaseConnectionString := 'Server=TMSERVER;Database=BCTEST';

        IF HASTABLECONNECTION(TABLECONNECTIONTYPE::ExternalSQL, DatabaseName) THEN
            UNREGISTERTABLECONNECTION(TABLECONNECTIONTYPE::ExternalSQL, DatabaseName);

        REGISTERTABLECONNECTION(TABLECONNECTIONTYPE::ExternalSQL, DatabaseName, DatabaseConnectionString);
        SETDEFAULTTABLECONNECTION(TABLECONNECTIONTYPE::ExternalSQL, DatabaseName);
    end;
}
*/