page 50122 "Comport Setup"
{
    // version MITL2219

    Caption = 'Comport Setup';
    PageType = List;
    SourceTable = 50100;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(LLOP_ID; LLOP_ID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Current_Weight; Current_Weight)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Device_ID; Device_ID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        CreateScaleConnection;
    end;

    local procedure CreateScaleConnection()
    var
        DatabaseConnectionString: Text;
        DatabaseName: Text;
    begin
        DatabaseName := 'BCLive';
        DatabaseConnectionString := 'Server=TMSERVER;Database=BCLive;User ID=sa;Password=TMPassw0rd@99';

        IF HASTABLECONNECTION(TABLECONNECTIONTYPE::ExternalSQL, DatabaseName) THEN
            UNREGISTERTABLECONNECTION(TABLECONNECTIONTYPE::ExternalSQL, DatabaseName);

        REGISTERTABLECONNECTION(TABLECONNECTIONTYPE::ExternalSQL, DatabaseName, DatabaseConnectionString);
        // REGISTERTABLECONNECTION(TABLECONNECTIONTYPE::ExternalSQL, 'LLOP_Weight', 'Server=TMSERVER.database.windows.net;Database=BCDEVTables;User ID=sa;Password=TMPassw0rd@99');
        SETDEFAULTTABLECONNECTION(TABLECONNECTIONTYPE::ExternalSQL, DatabaseName);
    end;
}

