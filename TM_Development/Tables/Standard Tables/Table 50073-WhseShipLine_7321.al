tableextension 50074 WhseShipLine extends "Warehouse Shipment Line"
{
    //Version MITL13605,CASE13601
    fields
    {
        // Add changes to table fields here
        field(50000; "Combined Pick"; Boolean)
        {
            Description = 'MITL13601';
            CaptionML = ENU = 'Combined Pick', ENG = 'Combined Pick';
        }
        field(50001; "Product Type"; Option)
        {
            Description = 'MITL13605';
            OptionMembers = " ",Accessories,Tiles;
            OptionCaptionML = ENU = ' ,Accessories,Tiles', ENG = ' ,Accessories,Tiles';
            CaptionML = ENU = 'Product Type', ENG = 'Product Type';
        }
    }

    var
        HideValidationDialogL: Boolean;


    procedure CreatePickDocCustom(VAR WhseShptLine: Record "Warehouse Shipment Line"; WhseShptHeader2: Record "Warehouse Shipment Header")
    var
        CreatePickFromWhseShpt: Report "Whse._Shipment - Create Pick";
        WhseShptHeader: Record "Warehouse Shipment Header";
        Text0011: TextConst ENU = 'Nothing to handle.';
    begin
        WhseShptHeader2.TESTFIELD(Status, WhseShptHeader.Status::Released);
        WhseShptLine.SETFILTER(Quantity, '>0');
        WhseShptLine.SETRANGE("Completely Picked", FALSE);
        IF WhseShptLine.FIND('-') THEN BEGIN
            CreatePickFromWhseShpt.SetWhseShipmentLine(WhseShptLine, WhseShptHeader2);
            CreatePickFromWhseShpt.SetHideValidationDialog(HideValidationDialogL);
            CreatePickFromWhseShpt.USEREQUESTPAGE(NOT HideValidationDialogL);
            CreatePickFromWhseShpt.RUNMODAL;
            CreatePickFromWhseShpt.GetResultMessage;
            CLEAR(CreatePickFromWhseShpt);
        END ELSE
            IF NOT HideValidationDialogL THEN
                MESSAGE(Text0011);
    end;

    procedure SetHideValidationDialogCustom(NewHideValidationDialogL: Boolean)
    begin
        HideValidationDialogL := NewHideValidationDialogL;
    end;
}