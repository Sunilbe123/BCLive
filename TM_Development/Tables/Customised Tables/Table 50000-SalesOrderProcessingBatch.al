table 50000 SalesOrderProcessingBatch
{
    //Version='MITL13547'
    //MITL13547 - New table created for batch process of Sales Order
    CaptionML=ENU='Sales Order Processing Batch',ENG='Sales Order Processing Batch';
    
    fields
    {
        field(1;"Sales Order No."; Code[20])
        {
            CaptionML=ENU='Sales Order No.',ENG='Sales Order No.';
            Description='MITL13547';
        }
        field(2; "Captured Error"; Text[250])
        {
           CaptionML=ENU='Captured Error',ENG='Captured Error';
           Description='MITL13547';
        }
        field(3;"Shipped"; Code[20])
        {
            CaptionML=ENU='Shipped',ENG='Shipped';
            Description='MITL13547';
            FieldClass=FlowField;
            CalcFormula=Lookup("Sales Shipment Header"."Your Reference" WHERE ("Order No."=FIELD("Sales Order No."),"Your Reference"=FILTER('C-13547')));
        }
        field(4;"Invoiced"; Code[20])
        {
            CaptionML=ENU='Invoiced',ENG='Invoiced';
            Description='MITL13547';
            FieldClass=FlowField;
            CalcFormula=Lookup("Sales Invoice Header"."Your Reference" WHERE ("Order No."=FIELD("Sales Order No."),"Your Reference"=FILTER('C-13547')));
        }
    }
    
    keys
    {
        key(PK; "Sales Order No.")
        {
            Clustered = true;
        }
    }
    
    var
        myInt: Integer;
    
    trigger OnInsert()
    begin
        
    end;
    
    trigger OnModify()
    begin
        
    end;
    
    trigger OnDelete()
    begin
        
    end;
    
    trigger OnRename()
    begin
        
    end;
    
}