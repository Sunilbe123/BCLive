table 50036 "Pick Crt_Buffer1"
{
    // version NAVW19.00,CASE13605

    Caption = 'Summary Buffer for Move.';
    DrillDownPageID = "Bin Contents List";
    LookupPageID = "Bin Contents List";

    fields
    {
        field(1; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            NotBlank = true;
            TableRelation = Location;
        }
        field(2; "Zone Code"; Code[10])
        {
            Caption = 'Zone Code';
            Editable = false;
            NotBlank = true;
            TableRelation = Zone.Code WHERE ("Location Code" = FIELD ("Location Code"));
        }
        field(3; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            NotBlank = true;
            TableRelation = IF ("Zone Code" = FILTER ('')) Bin.Code WHERE ("Location Code" = FIELD ("Location Code"))
            ELSE
            IF ("Zone Code" = FILTER (<> '')) Bin.Code WHERE ("Location Code" = FIELD ("Location Code"),
                                                            "Zone Code" = FIELD ("Zone Code"));
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = Item WHERE (Type = CONST (Inventory));
        }
        field(10; "Bin Type Code"; Code[10])
        {
            Caption = 'Bin Type Code';
            Editable = false;
            TableRelation = "Bin Type";
        }
        field(11; "Warehouse Class Code"; Code[10])
        {
            Caption = 'Warehouse Class Code';
            Editable = false;
            TableRelation = "Warehouse Class";
        }
        field(12; "Block Movement"; Option)
        {
            Caption = 'Block Movement';
            OptionCaption = ' ,Inbound,Outbound,All';
            OptionMembers = " ",Inbound,Outbound,All;
        }
        field(15; "Min. Qty."; Decimal)
        {
            Caption = 'Min. Qty.';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(16; "Max. Qty."; Decimal)
        {
            Caption = 'Max. Qty.';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(21; "Bin Ranking"; Integer)
        {
            Caption = 'Bin Ranking';
            Editable = false;
        }
        field(26; Quantity; Decimal)
        {
            CalcFormula = Sum ("Warehouse Entry".Quantity WHERE ("Location Code" = FIELD ("Location Code"),
                                                                "Bin Code" = FIELD ("Bin Code"),
                                                                "Item No." = FIELD ("Item No."),
                                                                "Variant Code" = FIELD ("Variant Code"),
                                                                "Unit of Measure Code" = FIELD ("Unit of Measure Code"),
                                                                "Lot No." = FIELD ("Lot No. Filter"),
                                                                "Serial No." = FIELD ("Serial No. Filter")));
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(29; "Pick Qty."; Decimal)
        {
            CalcFormula = Sum ("Warehouse Activity Line"."Qty. Outstanding" WHERE ("Location Code" = FIELD ("Location Code"),
                                                                "Bin Code" = FIELD ("Bin Code"),
                                                                "Item No." = FIELD ("Item No."),
                                                                "Variant Code" = FIELD ("Variant Code"),
                                                                "Unit of Measure Code" = FIELD ("Unit of Measure Code"),
                                                                "Action Type" = CONST (Take),
                                                                "Lot No." = FIELD ("Lot No. Filter"),
                                                                "Serial No." = FIELD ("Serial No. Filter"),
                                                                "Assemble to Order" = CONST (false)));
            Caption = 'Pick Qty.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(30; "Neg. Adjmt. Qty."; Decimal)
        {
            CalcFormula = Sum ("Warehouse Journal Line"."Qty. (Absolute)" WHERE ("Location Code" = FIELD ("Location Code"),
                                                                "From Bin Code" = FIELD ("Bin Code"),
                                                                "Item No." = FIELD ("Item No."),
                                                                "Variant Code" = FIELD ("Variant Code"),
                                                                "Unit of Measure Code" = FIELD ("Unit of Measure Code"),
                                                                "Lot No." = FIELD ("Lot No. Filter"),
                                                                "Serial No." = FIELD ("Serial No. Filter")));
            Caption = 'Neg. Adjmt. Qty.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(31; "Put-away Qty."; Decimal)
        {
            CalcFormula = Sum ("Warehouse Activity Line"."Qty. Outstanding" WHERE ("Location Code" = FIELD ("Location Code"),
                                                                                  "Bin Code" = FIELD ("Bin Code"),
                                                                                  "Item No." = FIELD ("Item No."),
                                                                                  "Variant Code" = FIELD ("Variant Code"),
                                                                                  "Unit of Measure Code" = FIELD ("Unit of Measure Code"),
                                                                                  "Action Type" = CONST (Place),
                                                                                  "Lot No." = FIELD ("Lot No. Filter"),
                                                                                  "Serial No." = FIELD ("Serial No. Filter")));
            Caption = 'Put-away Qty.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(32; "Pos. Adjmt. Qty."; Decimal)
        {
            CalcFormula = Sum ("Warehouse Journal Line"."Qty. (Absolute)" WHERE ("Location Code" = FIELD ("Location Code"),
                                                                                "To Bin Code" = FIELD ("Bin Code"),
                                                                                "Item No." = FIELD ("Item No."),
                                                                                "Variant Code" = FIELD ("Variant Code"),
                                                                                "Unit of Measure Code" = FIELD ("Unit of Measure Code"),
                                                                                "Lot No." = FIELD ("Lot No. Filter"),
                                                                                "Serial No." = FIELD ("Serial No. Filter")));
            Caption = 'Pos. Adjmt. Qty.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(37; "Fixed"; Boolean)
        {
            Caption = 'Fixed';
        }
        field(40; "Cross-Dock Bin"; Boolean)
        {
            Caption = 'Cross-Dock Bin';
        }
        field(41; Default; Boolean)
        {
            Caption = 'Default';
        }
        field(50; "Quantity (Base)"; Decimal)
        {
            CalcFormula = Sum ("Warehouse Entry"."Qty. (Base)" WHERE ("Location Code" = FIELD ("Location Code"),
                                                                     "Item No." = FIELD ("Item No."),
                                                                     "Variant Code" = FIELD ("Variant Code"),
                                                                     "Unit of Measure Code" = FIELD ("Unit of Measure Code"),
                                                                     "Lot No." = FIELD ("Lot No. Filter"),
                                                                     "Serial No." = FIELD ("Serial No. Filter"),
                                                                     "Bin Code" = FIELD ("Adjustment Bin Code Filter")));
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(51; "Move Quantity (Base)"; Decimal)
        {
            CalcFormula = Sum ("Warehouse Activity Line"."Qty. Outstanding (Base)" WHERE ("Location Code" = FIELD ("Location Code"),
                                                                                         "Item No." = FIELD ("Item No."),
                                                                                         "Variant Code" = FIELD ("Variant Code"),
                                                                                         "Unit of Measure Code" = FIELD ("Unit of Measure Filter"),
                                                                                         "Action Type" = CONST (Take),
                                                                                         "Lot No." = FIELD ("Lot No. Filter"),
                                                                                         "Serial No." = FIELD ("Serial No. Filter"),
                                                                                         "Assemble to Order" = CONST (false),
                                                                                         "Bin Code" = FIELD ("Adjustment Bin Code Filter"),
                                                                                         "Activity Type" = CONST (Movement)));
            Caption = 'Move Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(52; "Negative Adjmt. Qty. (Base)"; Decimal)
        {
            CalcFormula = Sum ("Warehouse Journal Line"."Qty. (Absolute, Base)" WHERE ("Location Code" = FIELD ("Location Code"),
                                                                                      "Item No." = FIELD ("Item No."),
                                                                                      "Variant Code" = FIELD ("Variant Code"),
                                                                                      "Unit of Measure Code" = FIELD ("Unit of Measure Code"),
                                                                                      "Lot No." = FIELD ("Lot No. Filter"),
                                                                                      "Serial No." = FIELD ("Serial No. Filter"),
                                                                                      "Bin Code" = FIELD ("Adjustment Bin Code Filter")));
            Caption = 'Negative Adjmt. Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(53; "Put-away Quantity (Base)"; Decimal)
        {
            CalcFormula = Sum ("Warehouse Activity Line"."Qty. Outstanding (Base)" WHERE ("Location Code" = FIELD ("Location Code"),
                                                                                         "Item No." = FIELD ("Item No."),
                                                                                         "Variant Code" = FIELD ("Variant Code"),
                                                                                         "Unit of Measure Code" = FIELD ("Unit of Measure Code"),
                                                                                         "Action Type" = CONST (Place),
                                                                                         "Lot No." = FIELD ("Lot No. Filter"),
                                                                                         "Serial No." = FIELD ("Serial No. Filter"),
                                                                                         "Bin Code" = FIELD ("Adjustment Bin Code Filter")));
            Caption = 'Put-away Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(54; "Positive Adjmt. Qty. (Base)"; Decimal)
        {
            CalcFormula = Sum ("Warehouse Journal Line"."Qty. (Absolute, Base)" WHERE ("Location Code" = FIELD ("Location Code"),
                                                                                      "Item No." = FIELD ("Item No."),
                                                                                      "Variant Code" = FIELD ("Variant Code"),
                                                                                      "Unit of Measure Code" = FIELD ("Unit of Measure Code"),
                                                                                      "Lot No." = FIELD ("Lot No. Filter"),
                                                                                      "Serial No." = FIELD ("Serial No. Filter"),
                                                                                      "Bin Code" = FIELD ("Adjustment Bin Code Filter")));
            Caption = 'Positive Adjmt. Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(55; "ATO Components Pick Qty."; Decimal)
        {
            CalcFormula = Sum ("Warehouse Activity Line"."Qty. Outstanding" WHERE ("Location Code" = FIELD ("Location Code"),
                                                                                  "Item No." = FIELD ("Item No."),
                                                                                  "Variant Code" = FIELD ("Variant Code"),
                                                                                  "Unit of Measure Code" = FIELD ("Unit of Measure Code"),
                                                                                  "Action Type" = CONST (Take),
                                                                                  "Lot No." = FIELD ("Lot No. Filter"),
                                                                                  "Serial No." = FIELD ("Serial No. Filter"),
                                                                                  "Assemble to Order" = CONST (true),
                                                                                  "ATO Component" = CONST (True),
                                                                                  "Bin Code" = FIELD ("Adjustment Bin Code Filter")));
            Caption = 'ATO Components Pick Qty.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(56; "ATO Components Pick Qty (Base)"; Decimal)
        {
            CalcFormula = Sum ("Warehouse Activity Line"."Qty. Outstanding (Base)" WHERE ("Location Code" = FIELD ("Location Code"),
                                                                                         "Item No." = FIELD ("Item No."),
                                                                                         "Variant Code" = FIELD ("Variant Code"),
                                                                                         "Unit of Measure Code" = FIELD ("Unit of Measure Code"),
                                                                                         "Action Type" = CONST (Take),
                                                                                         "Lot No." = FIELD ("Lot No. Filter"),
                                                                                         "Serial No." = FIELD ("Serial No. Filter"),
                                                                                         "Assemble to Order" = CONST (true),
                                                                                         "ATO Component" = CONST (True),
                                                                                         "Bin Code" = FIELD ("Adjustment Bin Code Filter")));
            Caption = 'ATO Components Pick Qty (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5402; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No." = FIELD ("Item No."));
        }
        field(5404; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }
        field(5407; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            NotBlank = true;
            TableRelation = "Item Unit of Measure".Code WHERE ("Item No." = FIELD ("Item No."));
        }
        field(6500; "Lot No. Filter"; Code[20])
        {
            Caption = 'Lot No. Filter';
            FieldClass = FlowFilter;
        }
        field(6501; "Serial No. Filter"; Code[20])
        {
            Caption = 'Serial No. Filter';
            FieldClass = FlowFilter;
        }
        field(6502; Dedicated; Boolean)
        {
            Caption = 'Dedicated';
            Editable = false;
        }
        field(6503; "Unit of Measure Filter"; Code[10])
        {
            Caption = 'Unit of Measure Filter';
            FieldClass = FlowFilter;
            TableRelation = "Item Unit of Measure".Code WHERE ("Item No." = FIELD ("Item No."));
        }
        field(6504; "Movement Qty (Base)"; Decimal)
        {
            CalcFormula = Sum ("Whse. Worksheet Line"."Qty. (Base)" WHERE ("Location Code" = FIELD ("Location Code"),
                                                                          "Item No." = FIELD ("Item No."),
                                                                          "Variant Code" = FIELD ("Variant Code"),
                                                                          "Unit of Measure Code" = FIELD ("Unit of Measure Code")));
            Caption = 'Movement Qty (Base)';
            FieldClass = FlowField;
        }
        field(6505; "Qty to Pick (Base)"; Decimal)
        {
            Caption = 'Qty to Pick (Base)';
        }
        field(6506; "Demand Qty (Base)"; Decimal)
        {
            Caption = 'Demand Qty (Base)';
        }
        field(6507; "Bulk Bin Qty (Base)"; Decimal)
        {
            Caption = 'Bulk Bin Qty (Base)';
        }
        field(6508; "Short Fall (Base)"; Decimal)
        {
            Caption = 'Short Fall (Base)';
        }
        field(6509; "Adjustment Bin Code Filter"; Code[20])
        {
            Caption = 'Adjustment Bin Code';
            FieldClass = FlowFilter;
        }
        field(6510; "Pick Bin Stock (Base)"; Decimal)
        {
            Caption = 'Pick Bin Stock (Base)';
        }
        field(6511; "Shortage Stock (Base)"; Decimal)
        {
            Caption = 'Shortage Stock (Base)';
        }
        field(6512; "Total Avail Qty to Pick (Base)"; Decimal)
        {
            Caption = 'Total Avail Qty to Pick (Base)';
            Editable = false;
        }
        field(6513; "Pick Quantity (Base)"; Decimal)
        {
            CalcFormula = Sum ("Warehouse Activity Line"."Qty. Outstanding (Base)" WHERE ("Location Code" = FIELD ("Location Code"),
                                                                                         "Item No." = FIELD ("Item No."),
                                                                                         "Variant Code" = FIELD ("Variant Code"),
                                                                                         "Unit of Measure Code" = FIELD ("Unit of Measure Filter"),
                                                                                         "Action Type" = CONST (Take),
                                                                                         "Lot No." = FIELD ("Lot No. Filter"),
                                                                                         "Serial No." = FIELD ("Serial No. Filter"),
                                                                                         "Assemble to Order" = CONST (false),
                                                                                         "Bin Code" = FIELD ("Adjustment Bin Code Filter"),
                                                                                         "Activity Type" = FILTER (<> Movement)));
            Caption = 'Pick Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code")
        {
        }
        key(Key2; "Bin Type Code")
        {
        }
        key(Key3; "Location Code", "Item No.", "Variant Code", "Cross-Dock Bin", "Qty. per Unit of Measure", "Bin Ranking")
        {
        }
        key(Key4; "Location Code", "Warehouse Class Code", "Fixed", "Bin Ranking")
        {
        }
        key(Key5; "Location Code", "Item No.", "Variant Code", "Warehouse Class Code", "Fixed", "Bin Ranking")
        {
        }
        key(Key6; "Item No.")
        {
        }
        key(Key7; Default, "Location Code", "Item No.", "Variant Code", "Bin Code")
        {
        }
        key(Key8; "Location Code", "Item No.", "Variant Code", "Unit of Measure Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        BinContent: Record "Bin Content";
    begin
    end;

    var
        Item: Record Item;
        Location: Record Location;
        Bin: Record Bin;
        UOMMgt: Codeunit "Unit of Measure Management";

    procedure CalcQtyAvailToTake(ExcludeQtyBase: Decimal): Decimal
    begin
        SetFilterOnUnitOfMeasure;
        CALCFIELDS("Quantity (Base)", "Negative Adjmt. Qty. (Base)", "Move Quantity (Base)", "ATO Components Pick Qty (Base)", "Pick Quantity (Base)");
        EXIT(
          "Quantity (Base)" -
          (("Move Quantity (Base)" + "ATO Components Pick Qty (Base)" + "Pick Quantity (Base)") - ExcludeQtyBase + "Negative Adjmt. Qty. (Base)"));
    end;

    procedure CalcQtyAvailToTakeUOM(): Decimal
    begin
        GetItem("Item No.");
        IF Item."No." <> '' THEN
            EXIT(ROUND(CalcQtyAvailToTake(0) / UOMMgt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code"), 0.00001));
    end;

    procedure CalcQtyAvailToPick(ExcludeQtyBase: Decimal): Decimal
    begin
        IF (NOT Dedicated) AND (NOT ("Block Movement" IN ["Block Movement"::Outbound, "Block Movement"::All])) THEN
            EXIT(CalcQtyAvailToTake(ExcludeQtyBase) - CalcQtyWithBlockedItemTracking);
    end;

    procedure CalcQtyWithBlockedItemTracking(): Decimal
    var
        SerialNoInfo: Record "Serial No. Information";
        LotNoInfo: Record "Lot No. Information";
        XBinContent: Record "Bin Content";
        QtySNBlocked: Decimal;
        QtyLNBlocked: Decimal;
        QtySNAndLNBlocked: Decimal;
        SNGiven: Boolean;
        LNGiven: Boolean;
        NoITGiven: Boolean;
    begin
        SerialNoInfo.SETRANGE("Item No.", "Item No.");
        SerialNoInfo.SETRANGE("Variant Code", "Variant Code");
        COPYFILTER("Serial No. Filter", SerialNoInfo."Serial No.");
        SerialNoInfo.SETRANGE(Blocked, TRUE);

        LotNoInfo.SETRANGE("Item No.", "Item No.");
        LotNoInfo.SETRANGE("Variant Code", "Variant Code");
        COPYFILTER("Lot No. Filter", LotNoInfo."Lot No.");
        LotNoInfo.SETRANGE(Blocked, TRUE);

        IF SerialNoInfo.ISEMPTY AND LotNoInfo.ISEMPTY THEN
            EXIT;

        SNGiven := NOT (GETFILTER("Serial No. Filter") = '');
        LNGiven := NOT (GETFILTER("Lot No. Filter") = '');

        XBinContent.COPY(Rec);
        SETRANGE("Serial No. Filter");
        SETRANGE("Lot No. Filter");

        NoITGiven := NOT SNGiven AND NOT LNGiven;
        IF SNGiven OR NoITGiven THEN
            IF SerialNoInfo.FINDSET THEN
                REPEAT
                    SETRANGE("Serial No. Filter", SerialNoInfo."Serial No.");
                    CALCFIELDS("Quantity (Base)");
                    QtySNBlocked += "Quantity (Base)";
                    SETRANGE("Serial No. Filter");
                UNTIL SerialNoInfo.NEXT = 0;

        IF LNGiven OR NoITGiven THEN
            IF LotNoInfo.FINDSET THEN
                REPEAT
                    SETRANGE("Lot No. Filter", LotNoInfo."Lot No.");
                    CALCFIELDS("Quantity (Base)");
                    QtyLNBlocked += "Quantity (Base)";
                    SETRANGE("Lot No. Filter");
                UNTIL LotNoInfo.NEXT = 0;

        IF (SNGiven AND LNGiven) OR NoITGiven THEN
            IF SerialNoInfo.FINDSET THEN
                REPEAT
                    IF LotNoInfo.FINDSET THEN
                        REPEAT
                            SETRANGE("Serial No. Filter", SerialNoInfo."Serial No.");
                            SETRANGE("Lot No. Filter", LotNoInfo."Lot No.");
                            CALCFIELDS("Quantity (Base)");
                            QtySNAndLNBlocked += "Quantity (Base)";
                        UNTIL LotNoInfo.NEXT = 0;
                UNTIL SerialNoInfo.NEXT = 0;

        COPY(XBinContent);
        EXIT(QtySNBlocked + QtyLNBlocked - QtySNAndLNBlocked);
    end;

    local procedure CalcQtyAvailToPutAway(ExcludeQtyBase: Decimal): Decimal
    begin
        CALCFIELDS("Quantity (Base)", "Positive Adjmt. Qty. (Base)", "Put-away Quantity (Base)");
        EXIT(
          ROUND("Max. Qty." * "Qty. per Unit of Measure", 0.00001) -
          ("Quantity (Base)" + "Put-away Quantity (Base)" - ExcludeQtyBase + "Positive Adjmt. Qty. (Base)"));
    end;

    procedure SetFilterOnUnitOfMeasure()
    begin
        IF Location.GET("Location Code") THEN
            IF Location."Directed Put-away and Pick" THEN
                SETRANGE("Unit of Measure Filter", "Unit of Measure Code")
            ELSE
                SETRANGE("Unit of Measure Filter");
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        IF Location.Code <> LocationCode THEN
            Location.GET(LocationCode);
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        IF Item."No." = ItemNo THEN
            EXIT;

        IF ItemNo = '' THEN
            Item.INIT
        ELSE
            Item.GET(ItemNo);
    end;
}

