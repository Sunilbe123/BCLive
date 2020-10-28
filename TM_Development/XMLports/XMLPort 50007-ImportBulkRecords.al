xmlport 50007 ImportBulkRecords
{
    //Version MITL4192
    Direction = Both;
    Caption = 'Import Bulk Records';
    Format = VariableText;
    TextEncoding = UTF8;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement(ProcessBulkRecord; ProcessBulkRecord)
            {
                fieldelement(OrderNo; ProcessBulkRecord."Order No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(ShipmentNo; ProcessBulkRecord."Whse. Shipment No.")
                {
                    MinOccurs = Zero;
                }
                // trigger OnAfterInsertRecord()
                // var
                //     myInt: Integer;
                // begin
                //     ProcessBulkRecord."Order No." := OrderNo;
                //     ProcessBulkRecord."Whse. Shipment No." := ShipmentNo;
                // end;
            }
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {

                }
            }
        }
    }

    var
        myInt: Integer;
}