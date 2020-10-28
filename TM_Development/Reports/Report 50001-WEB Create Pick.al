report 50001 "WEB Create Pick"
{
    // version NAVW19.00

    Caption = 'Create Pick';
    ProcessingOnly = true;
    UseRequestPage = false;

    dataset
    {
        dataitem(DataItem5444; 2000000026)
        {
            DataItemTableView = SORTING (Number)
                                WHERE (Number = CONST (1));

            trigger OnAfterGetRecord()
            begin
                // MITL 16Jan2020 ++
                PickWkshLine.SetCurrentKey("From Bin Code");
                // MITL 16Jan2020 ++
                PickWkshLine.SETFILTER("Qty. to Handle (Base)", '>%1', 0);
                PickWkshLineFilter.COPYFILTERS(PickWkshLine);

                IF PickWkshLine.FIND('-') THEN BEGIN
                    IF PickWkshLine."Location Code" = '' THEN
                        Location.INIT
                    ELSE
                        Location.GET(PickWkshLine."Location Code");
                    REPEAT
                        PickWkshLine.CheckBin(PickWkshLine."Location Code", PickWkshLine."To Bin Code", TRUE);
                        TempNo := TempNo + 1;

                        IF PerWhseDoc THEN BEGIN
                            PickWkshLine.SETRANGE("Whse. Document Type", PickWkshLine."Whse. Document Type");
                            PickWkshLine.SETRANGE("Whse. Document No.", PickWkshLine."Whse. Document No.");
                        END;
                        IF PerDestination THEN BEGIN
                            PickWkshLine.SETRANGE("Destination Type", PickWkshLine."Destination Type");
                            PickWkshLine.SETRANGE("Destination No.", PickWkshLine."Destination No.");
                            IF PerItem THEN BEGIN
                                PickWkshLine.SETRANGE("Item No.", PickWkshLine."Item No.");
                                IF PerBin THEN BEGIN
                                    IF NOT Location."Bin Mandatory" THEN
                                        PickWkshLine.SETRANGE("Shelf No.", PickWkshLine."Shelf No.");
                                    IF PerDate THEN BEGIN
                                        PickWkshLine.SETRANGE("Due Date", PickWkshLine."Due Date");
                                        CreateTempLine;
                                        PickWkshLineFilter.COPYFILTER("Due Date", PickWkshLine."Due Date");
                                    END ELSE BEGIN
                                        PickWkshLineFilter.COPYFILTER("Due Date", PickWkshLine."Due Date");
                                        CreateTempLine;
                                    END;
                                    IF NOT Location."Bin Mandatory" THEN
                                        PickWkshLineFilter.COPYFILTER("Shelf No.", PickWkshLine."Shelf No.");
                                END ELSE BEGIN
                                    IF NOT Location."Bin Mandatory" THEN
                                        PickWkshLineFilter.COPYFILTER("Shelf No.", PickWkshLine."Shelf No.");
                                    IF PerDate THEN BEGIN
                                        PickWkshLine.SETRANGE("Due Date", PickWkshLine."Due Date");
                                        CreateTempLine;
                                        PickWkshLineFilter.COPYFILTER("Due Date", PickWkshLine."Due Date");
                                    END ELSE BEGIN
                                        PickWkshLineFilter.COPYFILTER("Due Date", PickWkshLine."Due Date");
                                        CreateTempLine;
                                    END;
                                END;
                                PickWkshLineFilter.COPYFILTER("Item No.", PickWkshLine."Item No.");
                            END ELSE BEGIN
                                PickWkshLineFilter.COPYFILTER("Item No.", PickWkshLine."Item No.");
                                IF PerBin THEN BEGIN
                                    IF NOT Location."Bin Mandatory" THEN
                                        PickWkshLine.SETRANGE("Shelf No.", PickWkshLine."Shelf No.");
                                    IF PerDate THEN BEGIN
                                        PickWkshLine.SETRANGE("Due Date", PickWkshLine."Due Date");
                                        CreateTempLine;
                                        PickWkshLineFilter.COPYFILTER("Due Date", PickWkshLine."Due Date");
                                    END ELSE BEGIN
                                        PickWkshLineFilter.COPYFILTER("Due Date", PickWkshLine."Due Date");
                                        CreateTempLine;
                                    END;
                                    IF NOT Location."Bin Mandatory" THEN
                                        PickWkshLineFilter.COPYFILTER("Shelf No.", PickWkshLine."Shelf No.");
                                END ELSE BEGIN
                                    IF NOT Location."Bin Mandatory" THEN
                                        PickWkshLineFilter.COPYFILTER("Shelf No.", PickWkshLine."Shelf No.");
                                    IF PerDate THEN BEGIN
                                        PickWkshLine.SETRANGE("Due Date", PickWkshLine."Due Date");
                                        CreateTempLine;
                                        PickWkshLineFilter.COPYFILTER("Due Date", PickWkshLine."Due Date");
                                    END ELSE BEGIN
                                        PickWkshLineFilter.COPYFILTER("Due Date", PickWkshLine."Due Date");
                                        CreateTempLine;
                                    END;
                                END;
                            END;
                            PickWkshLineFilter.COPYFILTER("Destination Type", PickWkshLine."Destination Type");
                            PickWkshLineFilter.COPYFILTER("Destination No.", PickWkshLine."Destination No.");
                        END ELSE BEGIN
                            PickWkshLineFilter.COPYFILTER("Destination Type", PickWkshLine."Destination Type");
                            PickWkshLineFilter.COPYFILTER("Destination No.", PickWkshLine."Destination No.");
                            IF PerItem THEN BEGIN
                                PickWkshLine.SETRANGE("Item No.", PickWkshLine."Item No.");
                                IF PerBin THEN BEGIN
                                    IF NOT Location."Bin Mandatory" THEN
                                        PickWkshLine.SETRANGE("Shelf No.", PickWkshLine."Shelf No.");
                                    IF PerDate THEN BEGIN
                                        PickWkshLine.SETRANGE("Due Date", PickWkshLine."Due Date");
                                        CreateTempLine;
                                        PickWkshLineFilter.COPYFILTER("Due Date", PickWkshLine."Due Date");
                                    END ELSE BEGIN
                                        PickWkshLineFilter.COPYFILTER("Due Date", PickWkshLine."Due Date");
                                        CreateTempLine;
                                    END;
                                    IF NOT Location."Bin Mandatory" THEN
                                        PickWkshLineFilter.COPYFILTER("Shelf No.", PickWkshLine."Shelf No.");
                                END ELSE BEGIN
                                    IF NOT Location."Bin Mandatory" THEN
                                        PickWkshLineFilter.COPYFILTER("Shelf No.", PickWkshLine."Shelf No.");
                                    IF PerDate THEN BEGIN
                                        PickWkshLine.SETRANGE("Due Date", PickWkshLine."Due Date");
                                        CreateTempLine;
                                        PickWkshLineFilter.COPYFILTER("Due Date", PickWkshLine."Due Date");
                                    END ELSE BEGIN
                                        PickWkshLineFilter.COPYFILTER("Due Date", PickWkshLine."Due Date");
                                        CreateTempLine;
                                    END;
                                END;
                                PickWkshLineFilter.COPYFILTER("Item No.", PickWkshLine."Item No.");
                            END ELSE BEGIN
                                PickWkshLineFilter.COPYFILTER("Item No.", PickWkshLine."Item No.");
                                IF PerBin THEN BEGIN
                                    IF NOT Location."Bin Mandatory" THEN
                                        PickWkshLine.SETRANGE("Shelf No.", PickWkshLine."Shelf No.");
                                    IF PerDate THEN BEGIN
                                        PickWkshLine.SETRANGE("Due Date", PickWkshLine."Due Date");
                                        CreateTempLine;
                                        PickWkshLineFilter.COPYFILTER("Due Date", PickWkshLine."Due Date");
                                    END ELSE BEGIN
                                        PickWkshLineFilter.COPYFILTER("Due Date", PickWkshLine."Due Date");
                                        CreateTempLine;
                                    END;
                                    IF NOT Location."Bin Mandatory" THEN
                                        PickWkshLineFilter.COPYFILTER("Shelf No.", PickWkshLine."Shelf No.");
                                END ELSE BEGIN
                                    IF NOT Location."Bin Mandatory" THEN
                                        PickWkshLineFilter.COPYFILTER("Shelf No.", PickWkshLine."Shelf No.");
                                    IF PerDate THEN BEGIN
                                        PickWkshLine.SETRANGE("Due Date", PickWkshLine."Due Date");
                                        CreateTempLine;
                                        PickWkshLineFilter.COPYFILTER("Due Date", PickWkshLine."Due Date");
                                    END ELSE BEGIN
                                        PickWkshLineFilter.COPYFILTER("Due Date", PickWkshLine."Due Date");
                                        CreateTempLine;
                                    END;
                                END;
                            END;
                        END;
                        PickWkshLineFilter.COPYFILTER("Whse. Document Type", PickWkshLine."Whse. Document Type");
                        PickWkshLineFilter.COPYFILTER("Whse. Document No.", PickWkshLine."Whse. Document No.");
                    UNTIL NOT PickWkshLine.FIND('-');
                    CheckPickActivity;
                END ELSE
                    ERROR(Text000);
            end;

            trigger OnPreDataItem()
            begin
                CLEAR(CreatePick);
                CreatePick.SetValues(
                  AssignedID, 0, SortPick, 1, MaxNoOfSourceDoc, MaxNoOfLines, PerZone,
                  DoNotFillQtytoHandle, BreakbulkFilter, PerBin);
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
                    group("Create Pick")
                    {
                        Caption = 'Create Pick';
                        field(PerWhseDoc; PerWhseDoc)
                        {
                            Caption = 'Per Whse. Document';
                        }
                        field(PerDestination; PerDestination)
                        {
                            Caption = 'Per Cust./Vend./Loc.';
                        }
                        field(PerItem; PerItem)
                        {
                            Caption = 'Per Item';
                        }
                        field(PerZone; PerZone)
                        {
                            Caption = 'Per From Zone';
                        }
                        field(PerBin; PerBin)
                        {
                            Caption = 'Per Bin';
                        }
                        field(PerDate; PerDate)
                        {
                            Caption = 'Per Due Date';
                        }
                    }
                    field(MaxNoOfLines; MaxNoOfLines)
                    {
                        BlankZero = true;
                        Caption = 'Max. No. of Pick Lines';
                        MultiLine = true;
                    }
                    field(MaxNoOfSourceDoc; MaxNoOfSourceDoc)
                    {
                        BlankZero = true;
                        Caption = 'Max. No. of Pick Source Docs.';
                        MultiLine = true;
                    }
                    field(AssignedID; AssignedID)
                    {
                        Caption = 'Assigned User ID';
                        TableRelation = "Warehouse Employee";

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            WhseEmployee: Record "Warehouse Employee";
                            LookupWhseEmployee: Page "Warehouse Employee List";
                        begin
                            WhseEmployee.SETCURRENTKEY("Location Code");
                            WhseEmployee.SETRANGE("Location Code", LocationCode);
                            LookupWhseEmployee.LOOKUPMODE(TRUE);
                            LookupWhseEmployee.SETTABLEVIEW(WhseEmployee);
                            IF LookupWhseEmployee.RUNMODAL = ACTION::LookupOK THEN BEGIN
                                LookupWhseEmployee.GETRECORD(WhseEmployee);
                                AssignedID := WhseEmployee."User ID";
                            END;
                        end;

                        trigger OnValidate()
                        var
                            WhseEmployee: Record 7301;
                        begin
                            IF AssignedID <> '' THEN
                                WhseEmployee.GET(AssignedID, LocationCode);
                        end;
                    }
                    field(SortPick; SortPick)
                    {
                        Caption = 'Sorting Method for Pick Lines';
                        MultiLine = true;
                        OptionCaption = ' ,Item,Document,Shelf/Bin No.,Due Date,Destination,Bin Ranking,Action Type';
                    }
                    field(BreakbulkFilter; BreakbulkFilter)
                    {
                        Caption = 'Set Breakbulk Filter';
                    }
                    field(DoNotFillQtytoHandle; DoNotFillQtytoHandle)
                    {
                        Caption = 'Do Not Fill Qty. to Handle';
                    }
                    field(PrintPick; PrintPick)
                    {
                        Caption = 'Print Pick';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            IF LocationCode <> '' THEN BEGIN
                Location.GET(LocationCode);
                IF Location."Use ADCS" THEN
                    DoNotFillQtytoHandle := TRUE;
            END;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        SortPick := SortPick::"Shelf No."; // CASE13582
    end;

    var
        Text000: Label 'There is nothing to handle.';
        Text001: Label 'Pick activity no. %1 has been created.';
        Text002: Label 'Pick activities no. %1 to %2 have been created.';
        Location: Record Location;
        PickWkshLine: Record "Whse. Worksheet Line";
        PickWkshLineFilter: Record "Whse. Worksheet Line";
        Cust: Record Customer;
        CreatePick: Codeunit "WEB Create Pick2";
        LocationCode: Code[10];
        AssignedID: Code[50];
        FirstPickNo: Code[20];
        FirstSetPickNo: Code[20];
        LastPickNo: Code[20];
        MaxNoOfLines: Integer;
        MaxNoOfSourceDoc: Integer;
        TempNo: Integer;
        SortPick: Option " ",Item,Document,"Shelf No.","Due Date",Destination,"Bin Ranking","Action Type";
        PerDestination: Boolean;
        PerItem: Boolean;
        PerZone: Boolean;
        PerBin: Boolean;
        PerWhseDoc: Boolean;
        PerDate: Boolean;
        PrintPick: Boolean;
        DoNotFillQtytoHandle: Boolean;
        Text003: Label 'You can create a Pick only for the available quantity in %1 %2 = %3,%4 = %5,%6 = %7,%8 = %9.';
        BreakbulkFilter: Boolean;
        NothingToHandleErr: Label 'There is nothing to handle. %1.';
        GlobalPIckNo: Code[20];

    local procedure CreateTempLine()
    var
        PickWhseActivHeader: Record "Warehouse Activity Header";
        TempWhseItemTrkgLine: Record "Whse. Item Tracking Line" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        PickQty: Decimal;
        PickQtyBase: Decimal;
        TempMaxNoOfSourceDoc: Integer;
        OldFirstSetPickNo: Code[20];
        TotalQtyPickedBase: Decimal;
    begin
        PickWkshLine.LOCKTABLE;
        REPEAT
            IF Location."Bin Mandatory" AND
               (NOT Location."Always Create Pick Line")
            THEN
                IF PickWkshLine.CalcAvailableQtyBase() < 0 THEN
                    ERROR(
                      Text003,
                      PickWkshLine.TABLECAPTION, PickWkshLine.FIELDCAPTION("Worksheet Template Name"),
                      PickWkshLine."Worksheet Template Name", PickWkshLine.FIELDCAPTION(Name),
                      PickWkshLine.Name, PickWkshLine.FIELDCAPTION("Location Code"),
                      PickWkshLine."Location Code", PickWkshLine.FIELDCAPTION("Line No."),
                      PickWkshLine."Line No.");

            PickWkshLine.TESTFIELD("Qty. per Unit of Measure");
            CreatePick.SetWhseWkshLine(PickWkshLine, TempNo);
            CASE PickWkshLine."Whse. Document Type" OF
                PickWkshLine."Whse. Document Type"::Shipment:
                    CreatePick.SetTempWhseItemTrkgLine(
                      PickWkshLine."Whse. Document No.", DATABASE::"Warehouse Shipment Line", '', 0,
                      PickWkshLine."Whse. Document Line No.", PickWkshLine."Location Code");
                PickWkshLine."Whse. Document Type"::Assembly:
                    CreatePick.SetTempWhseItemTrkgLine(
                      PickWkshLine."Whse. Document No.", DATABASE::"Assembly Line", '', 0,
                      PickWkshLine."Whse. Document Line No.", PickWkshLine."Location Code");
                PickWkshLine."Whse. Document Type"::"Internal Pick":
                    CreatePick.SetTempWhseItemTrkgLine(
                      PickWkshLine."Whse. Document No.", DATABASE::"Whse. Internal Pick Line", '', 0,
                      PickWkshLine."Whse. Document Line No.", PickWkshLine."Location Code");
                PickWkshLine."Whse. Document Type"::Production:
                    CreatePick.SetTempWhseItemTrkgLine(
                      PickWkshLine."Source No.", PickWkshLine."Source Type", '', PickWkshLine."Source Line No.",
                      PickWkshLine."Source Subline No.", PickWkshLine."Location Code");
                ELSE // Movement Worksheet Line
                    CreatePick.SetTempWhseItemTrkgLine(
                      PickWkshLine.Name, DATABASE::"Prod. Order Component", PickWkshLine."Worksheet Template Name",
                      0, PickWkshLine."Line No.", PickWkshLine."Location Code");
            END;

            PickQty := PickWkshLine."Qty. to Handle";
            PickQtyBase := PickWkshLine."Qty. to Handle (Base)";
            IF (PickQty > 0) AND
               (PickWkshLine."Destination Type" = PickWkshLine."Destination Type"::Customer)
            THEN BEGIN
                PickWkshLine.TESTFIELD("Destination No.");
                Cust.GET(PickWkshLine."Destination No.");
                Cust.CheckBlockedCustOnDocs(Cust, PickWkshLine."Source Document", FALSE, FALSE);
            END;

            CreatePick.SetCalledFromWksh(TRUE);

            WITH PickWkshLine DO
                CreatePick.CreateTempLine("Location Code", "Item No.", "Variant Code",
                  "Unit of Measure Code", '', "To Bin Code", "Qty. per Unit of Measure", PickQty, PickQtyBase);

            TotalQtyPickedBase := CreatePick.GetActualQtyPickedBase;

            // Update/delete lines
            PickWkshLine."Qty. to Handle (Base)" := PickWkshLine.CalcBaseQty(PickWkshLine."Qty. to Handle");
            IF PickWkshLine."Qty. (Base)" =
               PickWkshLine."Qty. Handled (Base)" + TotalQtyPickedBase
            THEN
                PickWkshLine.DELETE(TRUE)
            ELSE BEGIN
                PickWkshLine."Qty. Handled" := PickWkshLine."Qty. Handled" + PickWkshLine.CalcQty(TotalQtyPickedBase);
                PickWkshLine."Qty. Handled (Base)" := PickWkshLine.CalcBaseQty(PickWkshLine."Qty. Handled");
                PickWkshLine."Qty. Outstanding" := PickWkshLine.Quantity - PickWkshLine."Qty. Handled";
                PickWkshLine."Qty. Outstanding (Base)" := PickWkshLine.CalcBaseQty(PickWkshLine."Qty. Outstanding");
                PickWkshLine."Qty. to Handle" := 0;
                PickWkshLine."Qty. to Handle (Base)" := 0;
                PickWkshLine.MODIFY;
            END;
        UNTIL PickWkshLine.NEXT = 0;

        OldFirstSetPickNo := FirstSetPickNo;
        CreatePick.CreateWhseDocument(FirstSetPickNo, LastPickNo, FALSE, GlobalPIckNo);
        IF FirstSetPickNo = OldFirstSetPickNo THEN
            EXIT;

        IF FirstPickNo = '' THEN
            FirstPickNo := FirstSetPickNo;
        CreatePick.ReturnTempItemTrkgLines(TempWhseItemTrkgLine);
        ItemTrackingMgt.UpdateWhseItemTrkgLines(TempWhseItemTrkgLine);
        COMMIT;

        TempMaxNoOfSourceDoc := MaxNoOfSourceDoc;
        PickWhseActivHeader.SETRANGE(Type, PickWhseActivHeader.Type::Pick);
        PickWhseActivHeader.SETRANGE("No.", FirstSetPickNo, LastPickNo);
        PickWhseActivHeader.FIND('-');
        REPEAT
            IF SortPick > 0 THEN
                PickWhseActivHeader.SortWhseDoc;
            COMMIT;
            IF PrintPick THEN BEGIN
                REPORT.RUN(REPORT::"Picking List", FALSE, FALSE, PickWhseActivHeader);
                TempMaxNoOfSourceDoc -= 1;
            END;
        UNTIL ((PickWhseActivHeader.NEXT = 0) OR (TempMaxNoOfSourceDoc = 0));
    end;

    procedure SetWkshPickLine(var PickWkshLine2: Record "Whse. Worksheet Line")
    begin
        PickWkshLine.COPYFILTERS(PickWkshLine2);
        LocationCode := PickWkshLine2."Location Code";
    end;

    procedure GetResultMessage(): Boolean
    begin
        IF FirstPickNo <> '' THEN
            IF FirstPickNo = LastPickNo THEN
                MESSAGE(Text001, FirstPickNo)
            ELSE
                MESSAGE(Text002, FirstPickNo, LastPickNo);
        EXIT(FirstPickNo <> '');
    end;

    procedure InitializeReport(AssignedID2: Code[50]; MaxNoOfLines2: Integer; MaxNoOfSourceDoc2: Integer; SortPick2: Option " ",Item,Document,"Shelf/Bin No.","Due Date","Ship-To","Bin Ranking","Action Type"; PerDestination2: Boolean; PerItem2: Boolean; PerZone2: Boolean; PerBin2: Boolean; PerWhseDoc2: Boolean; PerDate2: Boolean; PrintPick2: Boolean; DoNotFillQtytoHandle2: Boolean; BreakbulkFilter2: Boolean)
    begin
        AssignedID := AssignedID2;
        MaxNoOfLines := MaxNoOfLines2;
        MaxNoOfSourceDoc := MaxNoOfSourceDoc2;
        SortPick := SortPick2;
        PerDestination := PerDestination2;
        PerItem := PerItem2;
        PerZone := PerZone2;
        PerBin := PerBin2;
        PerWhseDoc := PerWhseDoc2;
        PerDate := PerDate2;
        PrintPick := PrintPick2;
        DoNotFillQtytoHandle := DoNotFillQtytoHandle2;
        BreakbulkFilter := BreakbulkFilter2;
    end;

    local procedure CheckPickActivity()
    begin
        IF FirstPickNo = '' THEN
            ERROR(NothingToHandleErr, CreatePick.GetExpiredItemMessage);
    end;

    procedure GetPickNo(PickNo: Code[20])
    begin
        GlobalPIckNo := PickNo;
    end;
}

