tableextension 50078 BinContentBufferExt extends "Bin Content Buffer"
{
    //Version  MITL13687,MITL14137
    //MITL14137 - Fields added  to calculate whse. adjustment only for specified whse. batch.
    fields
    {
        // Add changes to table fields here

        field(50100; "Whse. Template Code"; Code[10])
        {
            Description = 'MITL14137';
            CaptionML = ENU = 'Whse. Template Code', ENG = 'Whse. Template Code';
        }
        field(50101; "Whse. Batch Code"; Code[10])
        {
            Description = 'MITL14137';
            CaptionML = ENU = 'Whse. Batch Code', ENG = 'Whse. Batch Code';
        }
        field(50102; "Reason Code"; Code[10])
        {

        }
    }
    var
        myInt: Integer;


}