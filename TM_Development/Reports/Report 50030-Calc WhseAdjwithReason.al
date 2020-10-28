report 50033 "Calc Whse. Adj. with Reason"
{
    // version NAVW18.00,MITL13687,MITL14137,5767

    // // MITL.5767.SM.28042020 ++
    // Added new function and new filter

    Caption = 'Calculate Whse. Adjustment';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item; 27)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Location Filter", "Variant Filter";
            dataitem(DataItem5444; 2000000026)
            {
                DataItemTableView = SORTING(Number)
                                    WHERE(Number = CONST(1));

                trigger OnAfterGetRecord()
                begin
                    WITH AdjmtBinQuantityBuffer DO BEGIN
                        Location.RESET;
                        Item.COPYFILTER("Location Filter", Location.Code);
                        Location.SETRANGE("Directed Put-away and Pick", TRUE);
                        //MITL-13562
                        IF LocationCode <> '' THEN
                            Location.SETRANGE(Code, LocationCode);
                        // MITL-13562
                        IF Location.FINDSET THEN
                            REPEAT
                                WhseEntry.SETRANGE("Location Code", Location.Code);
                                WhseEntry.SETRANGE("Bin Code", Location."Adjustment Bin Code");

                                // MITL.5767.SM.28042020 ++
                                IF ReasonCodeFilterApplied THEN BEGIN
                                    WhseEntry.SETRANGE("Reason Code", ReasonCodeFilter);
                                    WhseEntry.SETRANGE("Registering Date", StartDateg, DMY2DATE(31, 12, 9999)); // MITL.5767.SM.04052020
                                END;
                                // MITL.5767.SM.28042020 --

                                IF WhseEntry.FINDSET THEN
                                    REPEAT
                                        IF WhseEntry."Qty. (Base)" <> 0 THEN BEGIN
                                            RESET;
                                            SETRANGE("Item No.", WhseEntry."Item No.");
                                            SETRANGE("Variant Code", WhseEntry."Variant Code");
                                            SETRANGE("Location Code", WhseEntry."Location Code");
                                            SETRANGE("Bin Code", WhseEntry."Bin Code");
                                            SETRANGE("Unit of Measure Code", WhseEntry."Unit of Measure Code");
                                            SETRANGE("Reason Code", WhseEntry."Reason Code"); // MITL14137 ++
                                            IF WhseEntry."Lot No." <> '' THEN
                                                SETRANGE("Lot No.", WhseEntry."Lot No.");
                                            IF WhseEntry."Serial No." <> '' THEN
                                                SETRANGE("Serial No.", WhseEntry."Serial No.");
                                            IF FINDSET THEN BEGIN
                                                "Qty. to Handle (Base)" := "Qty. to Handle (Base)" + WhseEntry."Qty. (Base)";
                                                MODIFY;
                                            END ELSE BEGIN
                                                INIT;
                                                "Item No." := WhseEntry."Item No.";
                                                "Variant Code" := WhseEntry."Variant Code";
                                                "Location Code" := WhseEntry."Location Code";
                                                "Bin Code" := WhseEntry."Bin Code";
                                                "Unit of Measure Code" := WhseEntry."Unit of Measure Code";
                                                "Base Unit of Measure" := Item."Base Unit of Measure";
                                                "Lot No." := WhseEntry."Lot No.";
                                                "Serial No." := WhseEntry."Serial No.";
                                                "Qty. to Handle (Base)" := WhseEntry."Qty. (Base)";
                                                "Qty. Outstanding (Base)" := WhseEntry."Qty. (Base)";
                                                "Reason Code" := WhseEntry."Reason Code";  // MITL14137 ++
                                                INSERT;
                                            END;
                                        END;
                                    UNTIL WhseEntry.NEXT = 0;
                            UNTIL Location.NEXT = 0;

                        RESET;
                        ReservEntry.RESET;
                        ReservEntry.SETCURRENTKEY("Source ID");
                        ItemJnlLine.RESET;
                        ItemJnlLine.SETCURRENTKEY("Item No.");
                        IF FINDSET THEN BEGIN
                            REPEAT
                                ItemJnlLine.RESET;
                                ItemJnlLine.SETCURRENTKEY("Item No.");
                                ItemJnlLine.SETRANGE("Journal Template Name", ItemJnlLine."Journal Template Name");
                                ItemJnlLine.SETRANGE("Journal Batch Name", ItemJnlLine."Journal Batch Name");
                                ItemJnlLine.SETRANGE("Item No.", "Item No.");
                                ItemJnlLine.SETRANGE("Location Code", "Location Code");
                                ItemJnlLine.SETRANGE("Unit of Measure Code", "Unit of Measure Code");
                                ItemJnlLine.SETRANGE("Warehouse Adjustment", TRUE);
                                IF ItemJnlLine.FINDSET THEN
                                    REPEAT
                                        ReservEntry.SETRANGE("Source Type", DATABASE::"Item Journal Line");
                                        ReservEntry.SETRANGE("Source ID", ItemJnlLine."Journal Template Name");
                                        ReservEntry.SETRANGE("Source Batch Name", ItemJnlLine."Journal Batch Name");
                                        ReservEntry.SETRANGE("Source Ref. No.", ItemJnlLine."Line No.");
                                        IF "Lot No." <> '' THEN
                                            ReservEntry.SETRANGE("Lot No.", "Lot No.");
                                        IF "Serial No." <> '' THEN
                                            ReservEntry.SETRANGE("Serial No.", "Serial No.");
                                        IF ReservEntry.FINDSET THEN
                                            REPEAT
                                                "Qty. to Handle (Base)" += ReservEntry."Qty. to Handle (Base)";
                                                "Qty. Outstanding (Base)" += ReservEntry."Qty. to Handle (Base)";
                                            UNTIL ReservEntry.NEXT = 0;
                                    UNTIL ItemJnlLine.NEXT = 0;
                            UNTIL NEXT = 0;
                            MODIFY;
                        END;
                    END;
                end;

                trigger OnPostDataItem()
                var
                    ItemUOM: Record 5404;
                    QtyInUOM: Decimal;
                begin
                    WITH AdjmtBinQuantityBuffer DO BEGIN
                        RESET;
                        IF FINDSET THEN
                            REPEAT
                                IF "Location Code" <> '' THEN
                                    SETRANGE("Location Code", "Location Code");
                                SETRANGE("Variant Code", "Variant Code");
                                SETRANGE("Unit of Measure Code", "Unit of Measure Code");

                                SETRANGE("Reason Code", "Reason Code"); // MITL 14137 ++

                                WhseQtyBase := 0;
                                SETFILTER("Qty. to Handle (Base)", '>0');
                                IF FINDSET THEN BEGIN
                                    REPEAT
                                        WhseQtyBase := WhseQtyBase - "Qty. to Handle (Base)";
                                    UNTIL NEXT = 0
                                END;

                                ItemUOM.GET("Item No.", "Unit of Measure Code");
                                QtyInUOM := ROUND(WhseQtyBase / ItemUOM."Qty. per Unit of Measure", 0.00001);
                                IF (QtyInUOM <> 0) AND FINDFIRST THEN
                                    InsertItemJnlLine(
                                      "Item No.", "Variant Code", "Location Code",
                                      QtyInUOM, WhseQtyBase, "Unit of Measure Code", 1, "Reason Code"); // MITL14137 ++

                                WhseQtyBase := 0;
                                SETFILTER("Qty. to Handle (Base)", '<0');
                                IF FINDSET THEN
                                    REPEAT
                                        WhseQtyBase := WhseQtyBase - "Qty. to Handle (Base)";
                                    UNTIL NEXT = 0;
                                QtyInUOM := ROUND(WhseQtyBase / ItemUOM."Qty. per Unit of Measure", 0.00001);
                                IF (QtyInUOM <> 0) AND FINDFIRST THEN
                                    InsertItemJnlLine(
                                      "Item No.", "Variant Code", "Location Code",
                                      QtyInUOM, WhseQtyBase, "Unit of Measure Code", 0, "Reason Code"); // MITL14137 ++

                                WhseQtyBase := 0;
                                SETRANGE("Qty. to Handle (Base)");
                                IF FINDSET THEN
                                    REPEAT
                                        WhseQtyBase := WhseQtyBase - "Qty. to Handle (Base)";
                                    UNTIL NEXT = 0;
                                QtyInUOM := ROUND(WhseQtyBase / ItemUOM."Qty. per Unit of Measure", 0.00001);
                                IF ((QtyInUOM = 0) AND (WhseQtyBase < 0)) AND FINDFIRST THEN
                                    InsertItemJnlLine(
                                      "Item No.", "Variant Code", "Location Code",
                                      WhseQtyBase, WhseQtyBase, "Base Unit of Measure", 1, "Reason Code"); // MITL14137 ++

                                FINDLAST;
                                SETRANGE("Location Code");
                                SETRANGE("Variant Code");
                                SETRANGE("Unit of Measure Code");
                                SETRANGE("Reason Code"); // MITL 14137 ++
                            UNTIL NEXT = 0;
                        RESET;
                        DELETEALL;
                    END;
                end;

                trigger OnPreDataItem()
                begin
                    CLEAR(Location);
                    WhseEntry.RESET;
                    WhseEntry.SETCURRENTKEY("Item No.", "Bin Code", "Location Code", "Variant Code");
                    WhseEntry.SETRANGE("Item No.", Item."No.");

                    IF NOT ReasonCodeFilterApplied THEN//MITL_VS_20200615
                        WhseEntry.SETRANGE("Int. Register No.", IntRegisterNo); // MITL14137 ++

                    Item.COPYFILTER("Variant Filter", WhseEntry."Variant Code");

                    IF NOT WhseEntry.FIND('-') THEN
                        CurrReport.BREAK;

                    AdjmtBinQuantityBuffer.RESET;
                    AdjmtBinQuantityBuffer.DELETEALL;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                IF NOT HideValidationDialog THEN
                    Window.UPDATE;
            end;

            trigger OnPostDataItem()
            begin
                IF NOT HideValidationDialog THEN
                    Window.CLOSE;
            end;

            trigger OnPreDataItem()
            var
                ItemJnlTemplate: Record 82;
                ItemJnlBatch: Record 233;
            begin
                IF PostingDate = 0D THEN
                    ERROR(Text000);

                ItemJnlTemplate.GET(ItemJnlLine."Journal Template Name");
                ItemJnlBatch.GET(ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name");
                IF NextDocNo = '' THEN BEGIN
                    IF ItemJnlBatch."No. Series" <> '' THEN BEGIN
                        ItemJnlLine.SETRANGE("Journal Template Name", ItemJnlLine."Journal Template Name");
                        ItemJnlLine.SETRANGE("Journal Batch Name", ItemJnlLine."Journal Batch Name");
                        IF NOT ItemJnlLine.FIND('-') THEN
                            NextDocNo := NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series", PostingDate, FALSE);
                        ItemJnlLine.INIT;
                    END;
                    IF NextDocNo = '' THEN
                        ERROR(Text001);
                END;

                NextLineNo := 0;

                IF NOT HideValidationDialog THEN
                    Window.OPEN(Text002, "No.");
            end;
        }
    }

    requestpage
    {
        Caption = 'Calculate Inventory';
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PostingDate; PostingDate)
                    {
                        Caption = 'Posting Date';

                        trigger OnValidate()
                        begin
                            ValidatePostingDate;
                        end;
                    }
                    field(NextDocNo; NextDocNo)
                    {
                        Caption = 'Document No.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            IF PostingDate = 0D THEN
                PostingDate := WORKDATE;
            ValidatePostingDate;
        end;
    }

    labels
    {
    }

    var
        Text000: Label 'Enter the posting date.';
        Text001: Label 'Enter the document no.';
        Text002: Label 'Processing items    #1##########';
        ItemJnlBatch: Record 233;
        ItemJnlLine: Record 83;
        WhseEntry: Record 7312;
        Location: Record 14;
        SourceCodeSetup: Record 242;
        AdjmtBinQuantityBuffer: Record 7330 temporary;
        ReservEntry: Record 337;
        NoSeriesMgt: Codeunit 396;
        Window: Dialog;
        PostingDate: Date;
        NextDocNo: Code[20];
        WhseQtyBase: Decimal;
        NextLineNo: Integer;
        HideValidationDialog: Boolean;
        LocationCode: Code[20];
        IntRegisterNo: Integer;
        ReasonCodeFilter: Code[10];
        ReasonCodeFilterApplied: Boolean;
        StartDateg: Date;

    procedure SetItemJnlLine(var NewItemJnlLine: Record 83)
    begin
        ItemJnlLine := NewItemJnlLine;
    end;

    local procedure ValidatePostingDate()
    begin
        ItemJnlBatch.GET(ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name");
        IF ItemJnlBatch."No. Series" = '' THEN
            NextDocNo := ''
        ELSE BEGIN
            NextDocNo := NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series", PostingDate, FALSE);
            CLEAR(NoSeriesMgt);
        END;
    end;

    local procedure InsertItemJnlLine(ItemNo: Code[20]; VariantCode2: Code[10]; LocationCode2: Code[10]; Quantity2: Decimal; QuantityBase2: Decimal; UOM2: Code[10]; EntryType2: Option "Negative Adjmt.","Positive Adjmt."; ReasonCode: Code[20])
    var
        Location: Record 14;
        WhseEntry2: Record 7312;
        WhseEntry3: Record 7312;
        ReservEntry: Record 337;
        CreateReservEntry: Codeunit 99000830;
        OrderLineNo: Integer;
    begin
        WITH ItemJnlLine DO BEGIN
            IF NextLineNo = 0 THEN BEGIN
                LOCKTABLE;
                RESET;
                SETRANGE("Journal Template Name", "Journal Template Name");
                SETRANGE("Journal Batch Name", "Journal Batch Name");
                IF FIND('+') THEN
                    NextLineNo := "Line No.";

                SourceCodeSetup.GET;
            END;
            NextLineNo := NextLineNo + 10000;

            IF QuantityBase2 <> 0 THEN BEGIN
                INIT;
                "Line No." := NextLineNo;
                VALIDATE("Posting Date", PostingDate);
                IF QuantityBase2 > 0 THEN
                    VALIDATE("Entry Type", "Entry Type"::"Positive Adjmt.")
                ELSE BEGIN
                    VALIDATE("Entry Type", "Entry Type"::"Negative Adjmt.");
                    Quantity2 := -Quantity2;
                    QuantityBase2 := -QuantityBase2;
                END;
                VALIDATE("Document No.", NextDocNo);
                VALIDATE("Item No.", ItemNo);
                VALIDATE("Variant Code", VariantCode2);
                VALIDATE("Location Code", LocationCode2);
                VALIDATE("Source Code", SourceCodeSetup."Item Journal");
                VALIDATE("Unit of Measure Code", UOM2);
                VALIDATE("Reason Code", ReasonCode); // MITL14137 ++
                IF LocationCode2 <> '' THEN
                    Location.GET(LocationCode2);
                "Posting No. Series" := ItemJnlBatch."Posting No. Series";

                VALIDATE(Quantity, Quantity2);
                "Quantity (Base)" := QuantityBase2;
                "Invoiced Qty. (Base)" := QuantityBase2;
                "Warehouse Adjustment" := TRUE;
                INSERT(TRUE);

                IF Location.Code <> '' THEN
                    IF Location."Directed Put-away and Pick" THEN BEGIN
                        WhseEntry2.SETCURRENTKEY(
                          "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code",
                          "Lot No.", "Serial No.", "Entry Type");
                        WhseEntry2.SETRANGE("Item No.", "Item No.");
                        WhseEntry2.SETRANGE("Bin Code", Location."Adjustment Bin Code");
                        WhseEntry2.SETRANGE("Location Code", "Location Code");
                        WhseEntry2.SETRANGE("Variant Code", "Variant Code");
                        WhseEntry2.SETRANGE("Unit of Measure Code", UOM2);
                        WhseEntry2.SETFILTER("Entry Type", '%1|%2', EntryType2, WhseEntry2."Entry Type"::Movement);
                        IF WhseEntry2.FIND('-') THEN
                            REPEAT
                                WhseEntry2.SETRANGE("Lot No.", WhseEntry2."Lot No.");
                                WhseEntry2.SETRANGE("Serial No.", WhseEntry2."Serial No.");
                                WhseEntry2.CALCSUMS("Qty. (Base)");

                                WhseEntry3.SETCURRENTKEY(
                                  "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code",
                                  "Lot No.", "Serial No.", "Entry Type");
                                WhseEntry3.COPYFILTERS(WhseEntry2);
                                CASE EntryType2 OF
                                    EntryType2::"Positive Adjmt.":
                                        WhseEntry3.SETRANGE("Entry Type", WhseEntry3."Entry Type"::"Negative Adjmt.");
                                    EntryType2::"Negative Adjmt.":
                                        WhseEntry3.SETRANGE("Entry Type", WhseEntry3."Entry Type"::"Positive Adjmt.");
                                END;
                                WhseEntry3.CALCSUMS("Qty. (Base)");
                                IF ABS(WhseEntry3."Qty. (Base)") > ABS(WhseEntry2."Qty. (Base)") THEN
                                    WhseEntry2."Qty. (Base)" := 0
                                ELSE
                                    WhseEntry2."Qty. (Base)" := WhseEntry2."Qty. (Base)" + WhseEntry3."Qty. (Base)";

                                IF WhseEntry2."Qty. (Base)" <> 0 THEN BEGIN
                                    IF "Order Type" = "Order Type"::Production THEN
                                        OrderLineNo := "Order Line No.";
                                    CreateReservEntry.CreateReservEntryFor(
                                      DATABASE::"Item Journal Line",
                                      "Entry Type",
                                      "Journal Template Name",
                                      "Journal Batch Name",
                                      OrderLineNo,
                                      "Line No.",
                                      "Qty. per Unit of Measure",
                                      ABS(WhseEntry2.Quantity),
                                      ABS(WhseEntry2."Qty. (Base)"),
                                      WhseEntry2."Serial No.",
                                      WhseEntry2."Lot No.");
                                    IF WhseEntry2."Qty. (Base)" < 0 THEN             // Only Date on positive adjustments
                                        CreateReservEntry.SetDates(WhseEntry2."Warranty Date", WhseEntry2."Expiration Date");
                                    CreateReservEntry.CreateEntry(
                                      "Item No.",
                                      "Variant Code",
                                      "Location Code",
                                      Description,
                                      0D,
                                      0D,
                                      0,
                                      ReservEntry."Reservation Status"::Prospect);
                                END;
                                WhseEntry2.FIND('+');
                                WhseEntry2.SETRANGE("Lot No.");
                                WhseEntry2.SETRANGE("Serial No.");
                            UNTIL WhseEntry2.NEXT = 0;
                    END;
            END;
        END;
    end;

    procedure InitializeRequest(NewPostingDate: Date; DocNo: Code[20])
    begin
        PostingDate := NewPostingDate;
        NextDocNo := DocNo;
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    procedure InitializeLocation(Location: Code[20])
    begin
        LocationCode := Location;
    end;

    procedure SetInternalRegNo(IRegNo: Integer)
    begin
        IntRegisterNo := IRegNo;
    end;

    procedure SetReasonCodeFilter(NewReasonCode: Code[10]; ApplyResonCodefilter: Boolean; StartDateP: Date)
    begin
        // MITL.5767.SM.28042020
        ReasonCodeFilter := NewReasonCode;
        ReasonCodeFilterApplied := ApplyResonCodefilter;
        StartDateg := StartDateP;// MITL.5767.SM.04052020
    end;
}

