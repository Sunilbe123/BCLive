report 50000 "Whse._Shipment - Create Pick"
{
    // version NAVW19.00,CASE13605

    Caption = 'Whse.-Shipment - Create Pick';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Warehouse Shipment Line"; 7321)
        {
            DataItemTableView = SORTING ("No.", "Line No.");
            dataitem("Assembly Header"; 900)
            {
                DataItemTableView = SORTING ("Document Type", "No.");
                dataitem("Assembly Line"; 901)
                {
                    DataItemLink = "Document Type" = FIELD ("Document Type"),
                                   "Document No." = FIELD ("No.");
                    DataItemTableView = SORTING ("Document Type", "Document No.", "Line No.");

                    trigger OnAfterGetRecord()
                    var
                        WMSMgt: Codeunit 7302;
                    begin
                        WMSMgt.CheckInboundBlockedBin("Location Code", "Bin Code", "No.", "Variant Code", "Unit of Measure Code");

                        WhseWkshLine.SETRANGE("Source Line No.", "Line No.");
                        IF NOT WhseWkshLine.FINDFIRST THEN
                            CreatePick.CreateAssemblyPickLine("Assembly Line")
                        ELSE
                            WhseWkshLineFound := TRUE;
                    end;

                    trigger OnPreDataItem()
                    begin
                        SETRANGE(Type, Type::Item);
                        SETFILTER("Remaining Quantity (Base)", '>0');

                        WhseWkshLine.SETCURRENTKEY(
                          "Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.");
                        WhseWkshLine.SETRANGE("Source Type", DATABASE::"Assembly Line");
                        WhseWkshLine.SETRANGE("Source Subtype", "Assembly Header"."Document Type");
                        WhseWkshLine.SETRANGE("Source No.", "Assembly Header"."No.");
                    end;
                }

                trigger OnPreDataItem()
                var
                    SalesLine: Record 37;
                begin
                    IF NOT "Warehouse Shipment Line"."Assemble to Order" THEN
                        CurrReport.BREAK;

                    SalesLine.GET("Warehouse Shipment Line"."Source Subtype",
                      "Warehouse Shipment Line"."Source No.",
                      "Warehouse Shipment Line"."Source Line No.");
                    SalesLine.AsmToOrderExists("Assembly Header");
                    SETRANGE("Document Type", "Document Type");
                    SETRANGE("No.", "No.");
                end;
            }

            trigger OnAfterGetRecord()
            var
                QtyToPick: Decimal;
                QtyToPickBase: Decimal;
            begin
                IF Location."Directed Put-away and Pick" THEN
                    CheckBin(0, 0);

                WhseWkshLine.RESET;
                WhseWkshLine.SETCURRENTKEY(
                  "Whse. Document Type", "Whse. Document No.", "Whse. Document Line No.");
                WhseWkshLine.SETRANGE(
                  "Whse. Document Type", WhseWkshLine."Whse. Document Type"::Shipment);
                WhseWkshLine.SETRANGE("Whse. Document No.", WhseShptHeader."No.");

                WhseWkshLine.SETRANGE("Whse. Document Line No.", "Line No.");
                IF NOT WhseWkshLine.FINDFIRST THEN BEGIN
                    TESTFIELD("Qty. per Unit of Measure");
                    CALCFIELDS("Pick Qty. (Base)", "Pick Qty.");
                    QtyToPickBase := "Qty. (Base)" - ("Qty. Picked (Base)" + "Pick Qty. (Base)");
                    QtyToPick := Quantity - ("Qty. Picked" + "Pick Qty.");
                    IF QtyToPick > 0 THEN BEGIN
                        IF "Destination Type" = "Destination Type"::Customer THEN BEGIN
                            TESTFIELD("Destination No.");
                            Cust.GET("Destination No.");
                            Cust.CheckBlockedCustOnDocs(Cust, "Source Document", FALSE, FALSE);
                        END;

                        CreatePick.SetWhseShipment(
                          "Warehouse Shipment Line", 1, WhseShptHeader."Shipping Agent Code",
                          WhseShptHeader."Shipping Agent Service Code", WhseShptHeader."Shipment Method Code");
                        IF NOT "Assemble to Order" THEN BEGIN
                            CreatePick.SetTempWhseItemTrkgLine(
                              "No.", DATABASE::"Warehouse Shipment Line",
                              '', 0, "Line No.", "Location Code");
                            CreatePick.CreateTempLine(
                              "Location Code", "Item No.", "Variant Code", "Unit of Measure Code",
                              '', "Bin Code", "Qty. per Unit of Measure", QtyToPick, QtyToPickBase);
                        END;
                    END;
                END ELSE
                    WhseWkshLineFound := TRUE;
            end;

            trigger OnPostDataItem()
            var
                TempWhseItemTrkgLine: Record 6550 temporary;
                ItemTrackingMgt: Codeunit 6500;
            begin
                CreatePick.ReturnTempItemTrkgLines(TempWhseItemTrkgLine);
                IF TempWhseItemTrkgLine.FIND('-') THEN
                    REPEAT
                        ItemTrackingMgt.CalcWhseItemTrkgLine(TempWhseItemTrkgLine);
                    UNTIL TempWhseItemTrkgLine.NEXT = 0;
            end;

            trigger OnPreDataItem()
            begin
                CreatePick.SetValues(
                  AssignedID, 1, SortActivity, 1, 0, 0, FALSE, DoNotFillQtytoHandle, BreakbulkFilter, FALSE);

                COPYFILTERS(WhseShptLine);
                SETFILTER("Qty. (Base)", '>0');
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(AssignedID; AssignedID)
                    {
                        Caption = 'Assigned User ID';
                        TableRelation = "Warehouse Employee";

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            WhseEmployee: Record 7301;
                            LookupWhseEmployee: Page 7348;
                        begin
                            WhseEmployee.SETCURRENTKEY("Location Code");
                            WhseEmployee.SETRANGE("Location Code", Location.Code);
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
                                WhseEmployee.GET(AssignedID, Location.Code);
                        end;
                    }
                    field(SortingMethodForActivityLines; SortActivity)
                    {
                        Caption = 'Sorting Method for Activity Lines';
                        MultiLine = true;
                        OptionCaption = ' ,Item,Document,Shelf or Bin,Due Date,Destination,Bin Ranking,Action Type';
                    }
                    field(BreakbulkFilter; BreakbulkFilter)
                    {
                        Caption = 'Set Breakbulk Filter';
                    }
                    field(DoNotFillQtytoHandle; DoNotFillQtytoHandle)
                    {
                        Caption = 'Do Not Fill Qty. to Handle';
                    }
                    field(PrintDoc; PrintDoc)
                    {
                        Caption = 'Print Document';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            IF Location."Use ADCS" THEN
                DoNotFillQtytoHandle := TRUE;
        end;
    }

    labels
    {
    }

    trigger OnPostReport()
    var
        WhseActivHeader: Record 5766;
        TempWhseItemTrkgLine: Record 6550 temporary;
        ItemTrackingMgt: Codeunit 6500;
    begin
        //CreatePick.CreateWhseDocument(FirstActivityNo,LastActivityNo,true);
        CreatePick.CreateWhseDocument(FirstActivityNo, LastActivityNo, FALSE);

        CreatePick.ReturnTempItemTrkgLines(TempWhseItemTrkgLine);
        ItemTrackingMgt.UpdateWhseItemTrkgLines(TempWhseItemTrkgLine);

        WhseActivHeader.SETRANGE(Type, WhseActivHeader.Type::Pick);
        WhseActivHeader.SETRANGE("No.", FirstActivityNo, LastActivityNo);
        IF WhseActivHeader.FIND('-') THEN BEGIN
            REPEAT
                IF SortActivity > 0 THEN
                    WhseActivHeader.SortWhseDoc;
            UNTIL WhseActivHeader.NEXT = 0;

            IF PrintDoc THEN
                REPORT.RUN(REPORT::"Picking List", FALSE, FALSE, WhseActivHeader);
        END //ELSE
            //ERROR(NothingToHandleErr);
    end;

    trigger OnPreReport()
    begin
        CLEAR(CreatePick);
        EverythingHandled := TRUE;
    end;

    var
        Location: Record Location;
        WhseShptHeader: Record "Warehouse Shipment Header";
        WhseShptLine: Record "Warehouse Shipment Line";
        WhseWkshLine: Record "Whse. Worksheet Line";
        Cust: Record Customer;
        CreatePick: Codeunit Create_Pick;
        FirstActivityNo: Code[20];
        LastActivityNo: Code[20];
        AssignedID: Code[50];
        SortActivity: Option " ",Item,Document,"Shelf or Bin","Due Date",Destination,"Bin Ranking","Action Type";
        PrintDoc: Boolean;
        EverythingHandled: Boolean;
        WhseWkshLineFound: Boolean;
        HideValidationDialog: Boolean;
        DoNotFillQtytoHandle: Boolean;
        BreakbulkFilter: Boolean;
        SingleActivCreatedMsg: Label '%1 activity no. %2 has been created.%3', Comment = '%1=WhseActivHeader.Type;%2=Whse. Activity No.;%3=Concatenates ExpiredItemMessageText';
        SingleActivAndWhseShptCreatedMsg: Label '%1 activity no. %2 has been created.\For Warehouse Shipment lines that have existing Pick Worksheet lines, no %3 lines have been created.%4', Comment = '%1=WhseActivHeader.Type;%2=Whse. Activity No.;%3=WhseActivHeader.Type;%4=Concatenates ExpiredItemMessageText';
        MultipleActivCreatedMsg: Label '%1 activities no. %2 to %3 have been created.%4', Comment = '%1=WhseActivHeader.Type;%2=First Whse. Activity No.;%3=Last Whse. Activity No.;%4=Concatenates ExpiredItemMessageText';
        MultipleActivAndWhseShptCreatedMsg: Label '%1 activities no. %2 to %3 have been created.\For Warehouse Shipment lines that have existing Pick Worksheet lines, no %4 lines have been created.%5', Comment = '%1=WhseActivHeader.Type;%2=First Whse. Activity No.;%3=Last Whse. Activity No.;%4=WhseActivHeader.Type;%5=Concatenates ExpiredItemMessageText';
        NothingToHandleErr: Label 'There is nothing to handle.';

    procedure SetWhseShipmentLine(var WhseShptLine2: Record "Warehouse Shipment Line"; WhseShptHeader2: Record "Warehouse Shipment Header")
    begin
        WhseShptLine.COPY(WhseShptLine2);
        WhseShptHeader := WhseShptHeader2;
        AssignedID := WhseShptHeader2."Assigned User ID";
        GetLocation(WhseShptLine."Location Code");
    end;

    procedure GetResultMessage(): Boolean
    var
        WhseActivHeader: Record "Warehouse Activity Header";
        ExpiredItemMessageText: Text[100];
    begin
        ExpiredItemMessageText := CreatePick.GetExpiredItemMessage;
        IF FirstActivityNo = '' THEN
            EXIT(FALSE);

        IF NOT HideValidationDialog THEN BEGIN
            WhseActivHeader.Type := WhseActivHeader.Type::Pick;
            IF WhseWkshLineFound THEN BEGIN
                IF FirstActivityNo = LastActivityNo THEN
                    MESSAGE(
                      STRSUBSTNO(
                        SingleActivAndWhseShptCreatedMsg, FORMAT(WhseActivHeader.Type), FirstActivityNo,
                        FORMAT(WhseActivHeader.Type), ExpiredItemMessageText))
                ELSE
                    MESSAGE(
                      STRSUBSTNO(
                        MultipleActivAndWhseShptCreatedMsg, FORMAT(WhseActivHeader.Type), FirstActivityNo, LastActivityNo,
                        FORMAT(WhseActivHeader.Type), ExpiredItemMessageText));
            END ELSE BEGIN
                IF FirstActivityNo = LastActivityNo THEN
                    MESSAGE(
                      STRSUBSTNO(SingleActivCreatedMsg, FORMAT(WhseActivHeader.Type), FirstActivityNo, ExpiredItemMessageText))
                ELSE
                    MESSAGE(
                      STRSUBSTNO(MultipleActivCreatedMsg, FORMAT(WhseActivHeader.Type),
                        FirstActivityNo, LastActivityNo, ExpiredItemMessageText));
            END;
        END;
        EXIT(EverythingHandled);
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        IF Location.Code <> LocationCode THEN BEGIN
            IF LocationCode = '' THEN
                CLEAR(Location)
            ELSE
                Location.GET(LocationCode);
        END;
    end;

    procedure Initialize(AssignedID2: Code[50]; SortActivity2: Option " ",Item,Document,"Shelf/Bin No.","Due Date","Ship-To","Bin Ranking","Action Type"; PrintDoc2: Boolean; DoNotFillQtytoHandle2: Boolean; BreakbulkFilter2: Boolean)
    begin
        AssignedID := AssignedID2;
        SortActivity := SortActivity2;
        PrintDoc := PrintDoc2;
        DoNotFillQtytoHandle := DoNotFillQtytoHandle2;
        BreakbulkFilter := BreakbulkFilter2;
    end;
}

