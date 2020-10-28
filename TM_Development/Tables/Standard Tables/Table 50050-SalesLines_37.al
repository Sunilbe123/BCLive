tableextension 50050 SalesLines extends "Sales Line"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Cut Size"; Boolean)
        {
            Caption = 'Cut Size';
        }
        field(50001; "Cut Size To-Do"; Boolean)
        {
            Caption = 'Cut Size To-Do';
        }
        field(50002; Processed; Boolean)
        {
            Description = 'R4317';
            Caption = 'Processed';
        }
        field(50003; "Pick Line Qty"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Lookup ("Warehouse Activity Line"."Qty. to Handle" WHERE ("Activity Type" = CONST (Pick), "Source No." = FIELD ("Document No."), "Source Line No." = FIELD ("Line No."), "Item No." = FIELD ("No."), "Action Type" = CONST (Take)));
            Editable = false;
        }
        field(50004; "Picked Line Qty"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Lookup ("Registered Whse. Activity Line".Quantity WHERE ("Activity Type" = CONST (Pick), "Source No." = FIELD ("Document No."), "Source Line No." = FIELD ("Line No."), "Item No." = FIELD ("No."), "Action Type" = CONST (Take)));
            Editable = false;
        }
        field(50021; WebOrderItemID; Text[30])
        {
            Description = 'INS1.1';
        }
    }

    var
        myInt: Integer;

    procedure PostMovementLines(var WebCreditMemoP: Record "WEB Credit Header")
    var
        WhseWorksheetLineL: Record "Whse. Worksheet Line";
        CreateMovFromWhseSourceL: Report "WhseSource-CreateDocument";
        SortL: Option "",Item,Document,"Shelf/Bin No.","Due Date","Ship-To","Bin Ranking","Action Type";
        locationL: Record Location;
        WhseWorksheetLine2: Record "Whse. Worksheet Line";
    begin
        // CASE 13601
        WhseWorksheetLineL.RESET;
        WhseWorksheetLineL.SETRANGE("Movement Type", WhseWorksheetLineL."Movement Type"::"Order Cancellation");
        IF WhseWorksheetLineL.FindFirst() THEN BEGIN
            IF locationL.GET(WhseWorksheetLineL."Location Code") THEN;
            WhseWorksheetLine2.RESET;
            WhseWorksheetLine2.SETRANGE("Worksheet Template Name", locationL."Auto Movement Template");
            WhseWorksheetLine2.SETRANGE(Name, locationL."Auto Movement Batch Name");
            WhseWorksheetLine2.SETRANGE("Movement Type", WhseWorksheetLine2."Movement Type"::"Order Cancellation");
            WhseWorksheetLine2.SETRANGE("Source Document", WhseWorksheetLine2."Source Document"::"Sales Order");
            WhseWorksheetLine2.SetRange("Source Type", 37);
            WhseWorksheetLine2.SetRange("Source No.", WebCreditMemoP."Order ID");
            IF WhseWorksheetLine2.FindSet() THEN BEGIN
                CreateMovFromWhseSourceL.ExecuteForCredit(TRUE);
                CreateMovFromWhseSourceL.Initialize('', SortL::"Shelf/Bin No.", FALSE, FALSE, FALSE);
                CreateMovFromWhseSourceL.SetWhseWkshLine(WhseWorksheetLine2);
                CreateMovFromWhseSourceL.USEREQUESTPAGE(FALSE);
                CreateMovFromWhseSourceL.RUN;
                CreateMovFromWhseSourceL.GetResultMessage(3);
                CLEAR(CreateMovFromWhseSourceL);
            END;
        END;
        // CASE 13601
    end;

    procedure CreateMovementLines()
    var
        RegisteredWhseActivityLineL: Record "Registered Whse. Activity Line";

    begin
        // CASE 13601
        RegisteredWhseActivityLineL.RESET;
        RegisteredWhseActivityLineL.SETRANGE("Source Document", RegisteredWhseActivityLineL."Source Document"::"Sales Order");
        RegisteredWhseActivityLineL.SETRANGE("Source No.", "Document No.");
        RegisteredWhseActivityLineL.SETRANGE("Source Line No.", "Line No.");
        RegisteredWhseActivityLineL.SETRANGE("Action Type", RegisteredWhseActivityLineL."Action Type"::Take);
        IF RegisteredWhseActivityLineL.FINDSET THEN
            REPEAT
                InitWhseWorksheetLines(RegisteredWhseActivityLineL);
            UNTIL RegisteredWhseActivityLineL.NEXT = 0;
        // CASE 13601
    end;

    procedure InitWhseWorksheetLines(RegisteredWhseActivityLine: Record "Registered Whse. Activity Line")
    var
        WhseWorksheetLineL: Record "Whse. Worksheet Line";
        LineNoL: Integer;
        LocationL: Record Location;
    begin
        // CASE 13601
        IF LocationL.GET(RegisteredWhseActivityLine."Location Code") THEN;

        WhseWorksheetLineL.RESET;
        WhseWorksheetLineL.SETRANGE("Worksheet Template Name", LocationL."Auto Movement Template");
        WhseWorksheetLineL.SETRANGE(Name, LocationL."Auto Movement Batch Name");
        IF WhseWorksheetLineL.FINDLAST THEN
            LineNoL := WhseWorksheetLineL."Line No." + 10000
        ELSE
            LineNoL := 10000;

        WhseWorksheetLineL.INIT;
        WhseWorksheetLineL.VALIDATE("Worksheet Template Name", LocationL."Auto Movement Template");
        WhseWorksheetLineL.VALIDATE(Name, LocationL."Auto Movement Batch Name");
        WhseWorksheetLineL."Line No." := LineNoL;
        WhseWorksheetLineL.VALIDATE("Whse. Document Type", WhseWorksheetLineL."Whse. Document Type"::" ");
        WhseWorksheetLineL."Whse. Document No." := RegisteredWhseActivityLine."Source No.";
        WhseWorksheetLineL."Whse. Document Line No." := RegisteredWhseActivityLine."Source Line No.";
        WhseWorksheetLineL.VALIDATE("Source No.", RegisteredWhseActivityLine."Source No.");
        WhseWorksheetLineL.VALIDATE("Source Line No.", RegisteredWhseActivityLine."Source Line No.");
        WhseWorksheetLineL.VALIDATE("Source Document", RegisteredWhseActivityLine."Source Document");
        WhseWorksheetLineL."Source Type" := RegisteredWhseActivityLine."Source Type";
        WhseWorksheetLineL."Source Subline No." := RegisteredWhseActivityLine."Source Subline No.";
        WhseWorksheetLineL."Source Subtype" := RegisteredWhseActivityLine."Source Type";
        WhseWorksheetLineL.VALIDATE("Item No.", Rec."No.");
        WhseWorksheetLineL.VALIDATE(Quantity, RegisteredWhseActivityLine.Quantity);
        WhseWorksheetLineL."Qty. to Handle" := RegisteredWhseActivityLine.Quantity;
        WhseWorksheetLineL."Qty. to Handle (Base)" := RegisteredWhseActivityLine.Quantity;
        WhseWorksheetLineL.VALIDATE("Location Code", RegisteredWhseActivityLine."Location Code");
        WhseWorksheetLineL."From Bin Code" := LocationL."Shipment Bin Code";
        WhseWorksheetLineL."To Bin Code" := RegisteredWhseActivityLine."Bin Code";
        WhseWorksheetLineL."Movement Type" := WhseWorksheetLineL."Movement Type"::"Order Cancellation";
        WhseWorksheetLineL.INSERT(TRUE);
        // CASE 13601
    end;

    //MITL.NK.20200706<<
    procedure CreateMovementLinesPartialQty(pQty: Decimal)
    var
        RegisteredWhseActivityLineL: Record "Registered Whse. Activity Line";

    begin
        // CASE 13601
        RegisteredWhseActivityLineL.RESET;
        RegisteredWhseActivityLineL.SETRANGE("Source Document", RegisteredWhseActivityLineL."Source Document"::"Sales Order");
        RegisteredWhseActivityLineL.SETRANGE("Source No.", "Document No.");
        RegisteredWhseActivityLineL.SETRANGE("Source Line No.", "Line No.");
        RegisteredWhseActivityLineL.SETRANGE("Action Type", RegisteredWhseActivityLineL."Action Type"::Take);
        IF RegisteredWhseActivityLineL.FINDSET THEN
            REPEAT
                InitWhseWorksheetLinesPartial(RegisteredWhseActivityLineL, pQty);
            UNTIL RegisteredWhseActivityLineL.NEXT = 0;
        // CASE 13601
    end;

    procedure InitWhseWorksheetLinesPartial(RegisteredWhseActivityLine: Record "Registered Whse. Activity Line"; pQty: Decimal)
    var
        WhseWorksheetLineL: Record "Whse. Worksheet Line";
        LineNoL: Integer;
        LocationL: Record Location;
    begin
        // CASE 13601
        IF LocationL.GET(RegisteredWhseActivityLine."Location Code") THEN;

        WhseWorksheetLineL.RESET;
        WhseWorksheetLineL.SETRANGE("Worksheet Template Name", LocationL."Auto Movement Template");
        WhseWorksheetLineL.SETRANGE(Name, LocationL."Auto Movement Batch Name");
        IF WhseWorksheetLineL.FINDLAST THEN
            LineNoL := WhseWorksheetLineL."Line No." + 10000
        ELSE
            LineNoL := 10000;

        WhseWorksheetLineL.INIT;
        WhseWorksheetLineL.VALIDATE("Worksheet Template Name", LocationL."Auto Movement Template");
        WhseWorksheetLineL.VALIDATE(Name, LocationL."Auto Movement Batch Name");
        WhseWorksheetLineL."Line No." := LineNoL;
        WhseWorksheetLineL.VALIDATE("Whse. Document Type", WhseWorksheetLineL."Whse. Document Type"::" ");
        WhseWorksheetLineL."Whse. Document No." := RegisteredWhseActivityLine."Source No.";
        WhseWorksheetLineL."Whse. Document Line No." := RegisteredWhseActivityLine."Source Line No.";
        WhseWorksheetLineL.VALIDATE("Source No.", RegisteredWhseActivityLine."Source No.");
        WhseWorksheetLineL.VALIDATE("Source Line No.", RegisteredWhseActivityLine."Source Line No.");
        WhseWorksheetLineL.VALIDATE("Source Document", RegisteredWhseActivityLine."Source Document");
        WhseWorksheetLineL."Source Type" := RegisteredWhseActivityLine."Source Type";
        WhseWorksheetLineL."Source Subline No." := RegisteredWhseActivityLine."Source Subline No.";
        WhseWorksheetLineL."Source Subtype" := RegisteredWhseActivityLine."Source Type";
        WhseWorksheetLineL.VALIDATE("Item No.", Rec."No.");
        WhseWorksheetLineL.VALIDATE(Quantity, pQty);
        WhseWorksheetLineL."Qty. to Handle" := pQty;
        WhseWorksheetLineL."Qty. to Handle (Base)" := pQty;
        WhseWorksheetLineL.VALIDATE("Location Code", RegisteredWhseActivityLine."Location Code");
        WhseWorksheetLineL."From Bin Code" := LocationL."Shipment Bin Code";
        WhseWorksheetLineL."To Bin Code" := RegisteredWhseActivityLine."Bin Code";
        WhseWorksheetLineL."Movement Type" := WhseWorksheetLineL."Movement Type"::"Order Cancellation";
        WhseWorksheetLineL.INSERT(TRUE);
        // CASE 13601
    end;
    //MITL.NK.20200706>>
}