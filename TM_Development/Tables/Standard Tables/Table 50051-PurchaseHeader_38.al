tableextension 50051 PurchaseHeader extends "Purchase Header"
{
    fields
    {
        // Add changes to table fields here
        //MITL.MF.5407 Added option Available to Load in PO Status field++
        field(50000; "PO Status"; Option)
        {
            Description = 'MITL2184';
            CaptionML = ENU = 'PO Status', ENG = 'PO Status';
            OptionMembers = " ","Loaded Enroute","Waiting For Banks & Lloyd","Waiting For Production","Waiting For Supplier To Confirm Ready","UK Deliveries","Available to Load";
            OptionCaptionML = ENU = ' ,Loaded Enroute,Waiting For Banks & Lloyd,Waiting For Production,Waiting For Supplier To Confirm Ready,UK Deliveries,Available to Load',
                        ENG = ' ,Loaded Enroute,Waiting For Banks & Lloyd,Waiting For Production,Waiting For Supplier To Confirm Ready,UK Deliveries,Available to Load';
        }
        field(50001; "Container No."; Text[250])
        {
            CaptionML = ENU = 'Container No.', ENG = 'Container No.';
            Description = 'MITL2184';
        }
        field(50002; "TimeUpdated"; Text[30])
        {
            CaptionML = ENU = 'Time', ENG = 'Time';
            Description = 'MITL2184';

            trigger OnValidate()
            var
                VarTimeL: Time;
            begin
                //MITL2184 ++
                EVALUATE(VarTimeL, TimeUpdated);
                TimeUpdated := FORMAT(VarTimeL, 0, '<Hours24,2>:<Minutes,2>');
                //MITL2184 **
            end;
        }
    }



    var
        myInt: Integer;
}