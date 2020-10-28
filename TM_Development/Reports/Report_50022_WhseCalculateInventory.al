//MITL.MF.5409 Copy of standard report 7340 for filtering Bin Content with "Odd-Even Bin Flag"
report 50022 "Whse. Calculate Inventory 1"
{
    // version NAVW113.04

    Caption = 'Whse. Calculate Inventory';
    ProcessingOnly = true;
    dataset
    {
        dataitem("Bin Content"; "Bin Content")
        {
            DataItemTableView = SORTING ("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");
            RequestFilterFields = "Zone Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code", "Bin Type Code", "Warehouse Class Code";
            trigger OnAfterGetRecord()
            begin
                IF SkipCycleSKU("Location Code", "Item No.", "Variant Code") THEN
                    CurrReport.SKIP;

                IF NOT HideValidationDialog THEN
                    Window.UPDATE;
                CALCFIELDS("Quantity (Base)");
                IF ("Quantity (Base)" <> 0) OR ZeroQty THEN
                    InsertWhseJnlLine("Bin Content");
            end;

            trigger OnPostDataItem()
            begin
                IF NOT HideValidationDialog THEN
                    Window.CLOSE;
            end;

            trigger OnPreDataItem()
            var
                WhseJnlTemplate: Record "Warehouse Journal Template";
                WhseJnlBatch: Record "Warehouse Journal Batch";

            begin
                OddEvenflag := GetFilter("Odd-Even Bin Flag");
                IF RegisteringDate = 0D THEN
                    ERROR(Text001, WhseJnlLine.FIELDCAPTION("Registering Date"));

                SETRANGE("Location Code", WhseJnlLine."Location Code");

                WhseJnlTemplate.GET(WhseJnlLine."Journal Template Name");
                WhseJnlBatch.GET(
                  WhseJnlLine."Journal Template Name",
                  WhseJnlLine."Journal Batch Name", WhseJnlLine."Location Code");
                IF NextDocNo = '' THEN BEGIN
                    IF WhseJnlBatch."No. Series" <> '' THEN BEGIN
                        WhseJnlLine.SETRANGE("Journal Template Name", WhseJnlLine."Journal Template Name");
                        WhseJnlLine.SETRANGE("Journal Batch Name", WhseJnlLine."Journal Batch Name");
                        WhseJnlLine.SETRANGE("Location Code", WhseJnlLine."Location Code");
                        IF NOT WhseJnlLine.FINDFIRST THEN
                            NextDocNo :=
                              NoSeriesMgt.GetNextNo(WhseJnlBatch."No. Series", RegisteringDate, FALSE);
                        WhseJnlLine.INIT;
                    END;
                    IF NextDocNo = '' THEN
                        ERROR(Text001, WhseJnlLine.FIELDCAPTION("Whse. Document No."));
                END;

                NextLineNo := 0;

                IF NOT HideValidationDialog THEN
                    Window.OPEN(Text002, "Bin Code");

                SetAutoCalcFields("Odd-Even Bin Flag"); // MITL
            end;
        }
        dataitem("Warehouse Entry"; "Warehouse Entry")
        {

            trigger OnAfterGetRecord()
            var
                BinContent: Record "Bin Content";
                BinL: Record Bin;
            begin
                GetLocation("Location Code");
                IF ("Bin Code" = Location."Adjustment Bin Code") OR
                   SkipCycleSKU("Location Code", "Item No.", "Variant Code")
                THEN
                    CurrReport.SKIP;

                BinContent.COPYFILTERS("Bin Content");
                BinContent.SETRANGE("Location Code", "Location Code");
                BinContent.SETRANGE("Item No.", "Item No.");
                BinContent.SETRANGE("Variant Code", "Variant Code");
                BinContent.SETRANGE("Unit of Measure Code", "Unit of Measure Code");
                IF NOT BinContent.ISEMPTY THEN
                    CurrReport.SKIP;

                BinL.Reset();
                BinL.SetRange("Location Code", "Location Code");
                BinL.SetRange(Code, "Bin Code");
                if OddEvenflag <> '' then
                    BinL.SetFilter("Odd-Even Bin Flag", OddEvenflag);
                if not BinL.FindFirst() then
                    CurrReport.Skip();

                TempBinContent.INIT;
                TempBinContent."Location Code" := "Location Code";
                TempBinContent."Item No." := "Item No.";
                TempBinContent."Zone Code" := "Zone Code";
                TempBinContent."Bin Code" := "Bin Code";
                TempBinContent."Variant Code" := "Variant Code";
                TempBinContent."Unit of Measure Code" := "Unit of Measure Code";
                TempBinContent."Quantity (Base)" := 0;
                TempBinContent."Odd-Even Bin Flag" := BinL."Odd-Even Bin Flag";
                IF NOT TempBinContent.FIND THEN
                    TempBinContent.INSERT;
            end;

            trigger OnPostDataItem()
            begin
                TempBinContent.RESET;
                IF TempBinContent.FINDSET THEN
                    REPEAT
                        InsertWhseJnlLine(TempBinContent);
                    UNTIL TempBinContent.NEXT = 0;
            end;

            trigger OnPreDataItem()
            begin
                IF ("Bin Content".GETFILTER("Zone Code") = '') AND
                   ("Bin Content".GETFILTER("Bin Code") = '')
                THEN
                    CurrReport.BREAK;

                "Bin Content".COPYFILTER("Location Code", "Location Code");
                "Bin Content".COPYFILTER("Zone Code", "Zone Code");
                "Bin Content".COPYFILTER("Bin Code", "Bin Code");
                "Bin Content".COPYFILTER("Item No.", "Item No.");
                "Bin Content".COPYFILTER("Variant Code", "Variant Code");
                "Bin Content".COPYFILTER("Unit of Measure Code", "Unit of Measure Code");
                "Bin Content".COPYFILTER("Bin Type Code", "Bin Type Code");
                "Bin Content".COPYFILTER("Lot No. Filter", "Lot No.");
                "Bin Content".COPYFILTER("Serial No. Filter", "Serial No.");
                TempBinContent.RESET;
                TempBinContent.DELETEALL;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(RegisteringDate; RegisteringDate)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Registering Date';
                        ToolTip = 'Specifies the date for registering this batch job. The program automatically enters the work date in this field, but you can change it.';

                        trigger OnValidate()
                        begin
                            ValidateRegisteringDate;
                        end;
                    }
                    field(WhseDocumentNo; NextDocNo)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Whse. Document No.';
                        ToolTip = 'Specifies which document number will be entered in the Document No. field on the journal lines created by the batch job.';
                    }
                    field(ZeroQty; ZeroQty)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Items Not on Inventory';
                        ToolTip = 'Specifies if journal lines should be created for items that are not on inventory, that is, items where the value in the Qty. (Calculated) field is 0.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            IF RegisteringDate = 0D THEN
                RegisteringDate := WORKDATE;
            ValidateRegisteringDate;
        end;
    }

    labels
    {
    }

    var
        Text001: Label 'Enter the %1.';
        Text002: Label 'Processing bins    #1##########';
        WhseJnlBatch: Record "Warehouse Journal Batch";
        WhseJnlLine: Record "Warehouse Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        Location: Record Location;
        Bin: Record Bin;
        TempBinContent: Record "Bin Content" temporary;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Window: Dialog;
        RegisteringDate: Date;
        CycleSourceType: Option " ",Item,SKU;
        PhysInvtCountCode: Code[10];
        NextDocNo: Code[20];
        NextLineNo: Integer;
        ZeroQty: Boolean;
        HideValidationDialog: Boolean;
        StockProposal: Boolean;
        OddEvenflag: Text;

    [Scope('Personalization')]
    procedure SetWhseJnlLine(var NewWhseJnlLine: Record "Warehouse Journal Line")
    begin
        WhseJnlLine := NewWhseJnlLine;
    end;

    local procedure ValidateRegisteringDate()
    begin
        WhseJnlBatch.GET(
          WhseJnlLine."Journal Template Name",
          WhseJnlLine."Journal Batch Name", WhseJnlLine."Location Code");
        IF WhseJnlBatch."No. Series" = '' THEN
            NextDocNo := ''
        ELSE BEGIN
            NextDocNo :=
              NoSeriesMgt.GetNextNo(WhseJnlBatch."No. Series", RegisteringDate, FALSE);
            CLEAR(NoSeriesMgt);
        END;
    end;

    [Scope('Personalization')]
    procedure InsertWhseJnlLine(BinContent: Record "Bin Content")
    var
        WhseEntry: Record "Warehouse Entry";
        ItemUOM: Record "Item Unit of Measure";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        ExpDate: Date;
        EntriesExist: Boolean;
    begin
        WITH WhseJnlLine DO BEGIN
            IF NextLineNo = 0 THEN BEGIN
                LOCKTABLE;
                SETRANGE("Journal Template Name", "Journal Template Name");
                SETRANGE("Journal Batch Name", "Journal Batch Name");
                SETRANGE("Location Code", "Location Code");
                IF FINDLAST THEN
                    NextLineNo := "Line No.";

                SourceCodeSetup.GET;
            END;

            GetLocation(BinContent."Location Code");

            WhseEntry.SETCURRENTKEY(
              "Item No.", "Bin Code", "Location Code", "Variant Code",
              "Unit of Measure Code", "Lot No.", "Serial No.", "Entry Type");
            WhseEntry.SETRANGE("Item No.", BinContent."Item No.");
            WhseEntry.SETRANGE("Bin Code", BinContent."Bin Code");
            WhseEntry.SETRANGE("Location Code", BinContent."Location Code");
            WhseEntry.SETRANGE("Variant Code", BinContent."Variant Code");
            WhseEntry.SETRANGE("Unit of Measure Code", BinContent."Unit of Measure Code");
            IF WhseEntry.FIND('-') THEN;
            REPEAT
                WhseEntry.SETRANGE("Lot No.", WhseEntry."Lot No.");
                WhseEntry.SETRANGE("Serial No.", WhseEntry."Serial No.");
                WhseEntry.CALCSUMS("Qty. (Base)");
                IF (WhseEntry."Qty. (Base)" <> 0) OR ZeroQty THEN BEGIN
                    ItemUOM.GET(BinContent."Item No.", BinContent."Unit of Measure Code");
                    NextLineNo := NextLineNo + 10000;
                    INIT;
                    "Line No." := NextLineNo;
                    VALIDATE("Registering Date", RegisteringDate);
                    VALIDATE("Entry Type", "Entry Type"::"Positive Adjmt.");
                    VALIDATE("Whse. Document No.", NextDocNo);
                    VALIDATE("Item No.", BinContent."Item No.");
                    VALIDATE("Variant Code", BinContent."Variant Code");
                    VALIDATE("Location Code", BinContent."Location Code");
                    "From Bin Code" := Location."Adjustment Bin Code";
                    "From Zone Code" := Bin."Zone Code";
                    "From Bin Type Code" := Bin."Bin Type Code";
                    VALIDATE("To Zone Code", BinContent."Zone Code");
                    VALIDATE("To Bin Code", BinContent."Bin Code");
                    VALIDATE("Zone Code", BinContent."Zone Code");
                    SetProposal(StockProposal);
                    VALIDATE("Bin Code", BinContent."Bin Code");
                    VALIDATE("Source Code", SourceCodeSetup."Whse. Phys. Invt. Journal");
                    VALIDATE("Unit of Measure Code", BinContent."Unit of Measure Code");
                    "Serial No." := WhseEntry."Serial No.";
                    "Lot No." := WhseEntry."Lot No.";
                    "Warranty Date" := WhseEntry."Warranty Date";
                    ExpDate := ItemTrackingMgt.ExistingExpirationDate("Item No.", "Variant Code", "Lot No.", "Serial No.", FALSE, EntriesExist);
                    IF EntriesExist THEN
                        "Expiration Date" := ExpDate
                    ELSE
                        "Expiration Date" := WhseEntry."Expiration Date";
                    "Phys. Inventory" := TRUE;

                    "Qty. (Calculated)" := ROUND(WhseEntry."Qty. (Base)" / ItemUOM."Qty. per Unit of Measure", 0.00001);
                    "Qty. (Calculated) (Base)" := WhseEntry."Qty. (Base)";

                    VALIDATE("Qty. (Phys. Inventory)", "Qty. (Calculated)");
                    VALIDATE("Qty. (Phys. Inventory) (Base)", WhseEntry."Qty. (Base)");

                    IF Location."Use ADCS" THEN
                        VALIDATE("Qty. (Phys. Inventory)", 0);
                    "Registering No. Series" := WhseJnlBatch."Registering No. Series";
                    "Whse. Document Type" :=
                      "Whse. Document Type"::"Whse. Phys. Inventory";
                    IF WhseJnlBatch."Reason Code" <> '' THEN
                        "Reason Code" := WhseJnlBatch."Reason Code";
                    "Phys Invt Counting Period Code" := PhysInvtCountCode;
                    "Phys Invt Counting Period Type" := CycleSourceType;
                    INSERT(TRUE);
                    OnAfterWhseJnlLineInsert(WhseJnlLine);
                END;
                IF WhseEntry.FIND('+') THEN;
                WhseEntry.SETRANGE("Lot No.");
                WhseEntry.SETRANGE("Serial No.");
            UNTIL WhseEntry.NEXT = 0;
        END;
    end;

    [Scope('Personalization')]
    procedure InitializeRequest(NewRegisteringDate: Date; WhseDocNo: Code[20]; ItemsNotOnInvt: Boolean)
    begin
        RegisteringDate := NewRegisteringDate;
        NextDocNo := WhseDocNo;
        ZeroQty := ItemsNotOnInvt;
    end;

    [Scope('Personalization')]
    procedure InitializePhysInvtCount(PhysInvtCountCode2: Code[10]; CycleSourceType2: Option " ",Item,SKU)
    begin
        PhysInvtCountCode := PhysInvtCountCode2;
        CycleSourceType := CycleSourceType2;
    end;

    [Scope('Personalization')]
    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    local procedure SkipCycleSKU(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]): Boolean
    var
        SKU: Record "Stockkeeping Unit";
    begin
        IF CycleSourceType = CycleSourceType::Item THEN
            IF SKU.READPERMISSION THEN
                IF SKU.GET(LocationCode, ItemNo, VariantCode) THEN
                    EXIT(TRUE);
        EXIT(FALSE);
    end;

    [Scope('Personalization')]
    procedure GetLocation(LocationCode: Code[10])
    begin
        IF Location.Code <> LocationCode THEN BEGIN
            Location.GET(LocationCode);
            Location.TESTFIELD("Adjustment Bin Code");
            Bin.GET(Location.Code, Location."Adjustment Bin Code");
            Bin.TESTFIELD("Zone Code");
        END;
    end;

    [Scope('Personalization')]
    procedure SetProposalMode(NewValue: Boolean)
    begin
        StockProposal := NewValue;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterWhseJnlLineInsert(var WarehouseJournalLine: Record "Warehouse Journal Line")
    begin
    end;
}

