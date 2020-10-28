page 50014 "WEB Index Monitoring ADMIN"
{
    // version RM 05112015,R4451

    // RM 05.11.2015
    // Hid Order button, added Document Button to deal with more than one type of document (shipment, credit, order)
    // 
    // R4424 - RM - 13.1.2015
    // Only show errors after specified date and restrict to inserts as per Matt's request
    // 
    // R4451 - RM - 21.01.16
    // Added field checked

    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Reports,WEB';
    SourceTable = "WEB Index";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Checked; Checked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }

                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Line no."; "Line no.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }

                field("Key Field 1"; "Key Field 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Key Field 2"; "Key Field 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Key Field 3"; "Key Field 3")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Key Field 4"; "Key Field 4")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Key Field 5"; "Key Field 5")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Order ID"; "Order ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Error; Error)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("DateTime Inserted"; "DateTime Inserted")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Reset Error")
            {
                Image = Error;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Status := Status::" ";
                    Error := '';
                    MODIFY;
                end;
            }
            action("Reset ALL")
            {
                Image = Error;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                Visible = false;

                trigger OnAction()
                begin
                    IF FINDSET THEN
                        REPEAT
                            Status := Status::" ";
                            Error := '';
                            MODIFY;
                        UNTIL NEXT = 0;
                    MESSAGE('Finished');
                end;
            }
            action("View Order")
            {
                Image = "Order";
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "WEB User  - Order Header";
                RunPageLink = "Order ID" = FIELD("Key Field 1");
                Visible = false;
            }
            action("View Document")
            {
                Image = "Order";
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    ShowWebDocument; //RM 05.11.2015
                end;
            }
            action("Set Filter")
            {

                trigger OnAction()
                begin
                    //R4424 >>
                    SetFilters;
                    CurrPage.UPDATE;
                    //R4424 <<
                end;
            }
            action("Toggle Checked")
            {
                Image = Task;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    WebIndex: Record "WEB Index";
                begin
                    //R4451 >>
                    CurrPage.SETSELECTIONFILTER(WebIndex);

                    IF WebIndex.FINDSET THEN
                        REPEAT
                            WebIndex.Checked := NOT WebIndex.Checked;
                            WebIndex.MODIFY;
                        UNTIL WebIndex.NEXT = 0;
                    CurrPage.UPDATE;
                    //R4451 <<
                end;
            }
            action("Post Pick, Shipment and Reset")
            {
                Image = Error;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction()
                begin

                    IF "Table Name" <> 'WEB Shipment Header' THEN BEGIN
                        MESSAGE('You can only do this for Shipments');
                        EXIT;
                    END;

                    PostShipmentandPick(Rec);
                end;
            }
            action("Retry Web Index Handling")
            {
                Image = Reuse;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    WebIndexHandling: Codeunit "WEB Index Handling";
                begin
                    WebIndexHandling.SetLineNoFilter(FORMAT("Line no."));
                    WebIndexHandling.RUN;
                    CurrPage.Update();
                end;
            }
            action("Retry WEB Combine Pick")
            {
                Image = Reuse;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                Visible = true;

                trigger OnAction()
                var
                    WEBIndexCombPick: Codeunit "WEB Index Handling - Comb Pick";
                begin
                    WEBIndexCombPick.RUN;
                    CurrPage.Update();
                end;
            }
            action("Retry Pick Creation")
            {
                Image = Reuse;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                Visible = true;

                trigger OnAction()
                var
                    PickCreation: Codeunit "Pick Creation Order to Order";
                begin
                    PickCreation.RUN;
                    CurrPage.Update();
                end;
            }
            action("Retry Auto Pick without Validate")
            {
                Image = Reuse;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                Visible = true;

                trigger OnAction()
                var
                    AutoPickCreate: Codeunit AutoPickCreateWithoutValidate;
                begin
                    AutoPickCreate.RUN;
                    CurrPage.Update();
                end;
            }
            action("Post Pick")
            {
                Image = Item;

                trigger OnAction()
                begin
                    // mitl ++++
                    CurrPage.SETSELECTIONFILTER(recWebIndex);
                    IF recWebIndex.FINDFIRST THEN
                        REPEAT
                            PostPick(recWebIndex);
                        UNTIL recWebIndex.NEXT = 0;
                end;
            }
            //MITL3118.AJ.19MAR2020 ++
            action(UpdateFromBinInPicks)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Visible = ShowButtonG;
                Image = ApplyEntries;
                Promoted = True;
                PromotedCategory = Category4;
                PromotedIsBig = True;
                CaptionML = ENU = 'Update Pick Bin In Picks';
                trigger OnAction()
                Begin
                    IF CompanyName() = 'Walls and Floors Limited' THEN
                        UpdateNewPickBininPickLines()
                    ELSE
                        Exit;
                End;
            }
            //MITL3118.AJ.19MAR2020 **

            //MITL_6702_VS++
            action("Failed Whse Shipment")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Visible = true;
                Image = Reuse;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                CaptionML = ENG = 'Failed Whse. Shipments', ENU = 'Failed Whse. Shipments';
                trigger OnAction()
                var
                    AutomateFailedShipL: Codeunit "AutomateFailedWhseShipmnt&Pick";
                begin
                    Clear(AutomateFailedShipL);
                    AutomateFailedShipL.SetDateFilter(True);
                    AutomateFailedShipL.Run();
                end;
            }
            //MITL_6702_VS++
            // MITL.SM.5442.20200803 ++
            action("Update Source No. on PutAway Header")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Visible = true;
                Image = Reuse;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    WhseActHdr_L: Record "Warehouse Activity Header";
                    WarehouseActivityLine: Record "Warehouse Activity Line";
                    WebCreditHeader_L: Record "WEB Credit Header";
                begin
                    WhseActHdr_L.Reset();
                    WhseActHdr_L.SetRange(Type, WhseActHdr_L.Type::"Put-away");
                    WhseActHdr_L.SetRange("Source Document", WhseActHdr_L."Source Document"::" ");
                    if WhseActHdr_L.FindSet() then
                        repeat
                            WarehouseActivityLine.Reset();
                            WarehouseActivityLine.SetRange("Activity Type", WhseActHdr_L.Type);
                            WarehouseActivityLine.SetRange("No.", WhseActHdr_L."No.");
                            if WarehouseActivityLine.FindFirst() then begin
                                WebCreditHeader_L.Reset();
                                WebCreditHeader_L.SetRange("Credit Memo ID", WarehouseActivityLine."Source No.");
                                if WebCreditHeader_L.FindLast() then begin
                                    WhseActHdr_L."Source Document" := WarehouseActivityLine."Source Document";
                                    WhseActHdr_L."Source No." := WebCreditHeader_L."Order ID";
                                    WhseActHdr_L."Assigned User ID" := UserId;
                                    WhseActHdr_L.Modify();
                                end;
                            end;
                        until WhseActHdr_L.Next() = 0;
                    Message('Put-Aways updated');
                end;
            }
            // MITL.SM.5442.20200803 --	    
            // action("Release order & Create Whse Shipment")
            // {
            //     ApplicationArea = All;
            //     Image = Reuse;
            //     Promoted = true;
            //     PromotedCategory = Category4;
            //     PromotedIsBig = true;
            //     Visible = true;
            //     trigger OnAction()
            //     var
            //         SalesHeader: Record "Sales Header";
            //         GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
            //         WEBLog: Record "WEB Log";
            //         ReleaseSalesDocumentCU: CODEUNIT "Release Sales Document"; //MITL_W&F
            //         SalesHeader2: Record "Sales Header";
            //         WarehouseShipmentHeader: Record "Warehouse Shipment Header";
            //         WarehouseShipmentLine: Record "Warehouse Shipment Line";
            //         WhseShipmentRelease: Codeunit "Whse.-Shipment Release";
            //         SalesLine: Record "Sales Line";
            //     begin
            //         //MITL ++ - Sales Order Credit limit Approval workflow related, if the order is approved then Warehosue shipment should automatically created.
            //         SalesHeader.Reset();
            //         SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
            //         SalesHeader.SetRange(Status, SalesHeader.Status::Open);
            //         IF SalesHeader.FindSet() then begin
            //             salesLine.Setrange("Document Type", SalesHeader2."Document Type");
            //             salesLine.Setrange("Document No.", SalesHeader2."No.");
            //             IF Not SalesLine.IsEmpty() THEN begin
            //                 repeat
            //                     ReleaseSalesDocumentCU.SetSkipCheckReleaseRestrictions;
            //                     ReleaseSalesDocumentCU.Run(SalesHeader);
            //                 until SalesHeader.Next() = 0;
            //             END;
            //         end;
            //         Commit();

            //         SalesHeader2.Reset();
            //         SalesHeader2.SetRange("Document Type", SalesHeader2."Document Type"::Order);
            //         SalesHeader2.SetRange(Status, SalesHeader2.Status::Released);
            //         IF SalesHeader2.FindSet() then
            //             repeat
            //                 WarehouseShipmentLine.Reset();
            //                 WarehouseShipmentLine.SETRANGE(WarehouseShipmentLine."Source Document", WarehouseShipmentLine."Source Document"::"Sales Order");
            //                 WarehouseShipmentLine.SETRANGE(WarehouseShipmentLine."Source No.", SalesHeader2."No.");
            //                 IF not WarehouseShipmentLine.FindSet() THEN begin
            //                     IF NOT GetSourceDocOutbound.CreateFromSalesOrderHideDialog(SalesHeader) then begin
            //                         WEBLog."Line No." := 0;
            //                         WEBLog.Note := '11' + GETLASTERRORTEXT;
            //                         WEBLog."Order ID" := SalesHeader2."No.";
            //                         WEBLog.INSERT(TRUE);
            //                     END;
            //                     Commit();
            //                 END;
            //                 WarehouseShipmentLine.SetHideValidationDialog(TRUE);
            //                 IF WarehouseShipmentHeader.GET(WarehouseShipmentLine."No.") then
            //                     IF WarehouseShipmentHeader.Status = WarehouseShipmentHeader.Status::Open then
            //                         WhseShipmentRelease.Release(WarehouseShipmentHeader);
            //             Until SalesHeader2.Next() = 0;
            //         //MITL **
            //     end;
            // }

        }
    }

    trigger OnOpenPage()
    begin
        //R4424 >>
        SetFilters;
        //R4424 <<
        //MITL3118.AJ.19MAR2020 ++
        IF UserSetupG.Get(UserId()) THEN BEGIN
            IF UserSetupG."Allow Bin Update on Picks" = true then
                ShowButtonG := TRUE
            ELSE
                ShowButtonG := False;
            CurrPage.Update();
        END;
        //MITL3118.AJ.19MAR2020 **
    end;

    var
        WebSetup: Record "WEB Setup";
        "-------MITL1.00--------": Integer;
        recWebIndex: Record "WEB Index";
        ShowButtonG: Boolean; //MITL3118.AJ.19MAR2020
        UserSetupG: Record "User Setup";  //MITL3118.AJ.19MAR2020

    procedure SetFilters()
    begin
        //R4424 >>
        WebSetup.GET;

        IF GETFILTER("DateTime Inserted") = '' THEN
            SETFILTER("DateTime Inserted", '>=%1', WebSetup."Error Start Date");

        IF GETFILTER("Table No.") <> '' THEN BEGIN
            IF FINDFIRST THEN;

            IF WebSetup."Show Inserts only" THEN BEGIN
                CASE "Table No." OF
                    50009:
                        SETRANGE("Key Field 3", 'Insert');
                    50010, 50014, 50016, 50018:
                        SETRANGE("Key Field 2", 'Insert');
                END;
            END;
        END;
        //R4424 <<
    end;

    procedure PostShipmentandPick(WEBIndex: Record "WEB Index")
    var
        WEBShipmentHeader: Record "WEB Shipment Header";
        WarehouseActivityLine: Record "Warehouse Activity Line";
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        WhseActivityRegister: Codeunit "Whse.-Activity-Register";
        WhseActivLine: Record "Warehouse Activity Line";
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        WarehouseShipmentLine2: Record "Warehouse Shipment Line";
        CreatePickFromWhseShpt: Report "Whse._Shipment - Create Pick";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesPost: Codeunit "Sales-Post";
        WhsePostShipment: Codeunit "Whse.-Post Shipment";
        SalesOrder: Record "Sales Header";
        HideMessages: Boolean;
    begin
        //WEBShipmentHeader.GET("Key Field 1",FORMAT("Key Field 2"),"Key Field 3");
        IF "Line no." = 0 THEN BEGIN
            Rec := WEBIndex;
            HideMessages := TRUE;
        END;

        Status := Status::" ";
        Error := '';
        MODIFY;

        WEBShipmentHeader.SETRANGE("Index No.", FORMAT("Line no."));
        WEBShipmentHeader.FINDFIRST;
        WarehouseActivityLine.SETRANGE("Source No.", WEBShipmentHeader."Order ID");

        IF SalesOrder.GET(SalesOrder."Document Type"::Order, WEBShipmentHeader."Order ID") THEN BEGIN
            SalesOrder."Shipping No." := WEBShipmentHeader."Shipment ID";
            SalesOrder."Posting Date" := WEBShipmentHeader."Shipment Date";
            SalesOrder.Ship := TRUE;
            SalesOrder.Invoice := TRUE;
            SalesOrder."Web Shipment Increment Id" := WEBShipmentHeader."Shipment ID";
            SalesOrder."Web Shipment Tracing No." := WEBShipmentHeader."Tracking Number";
            SalesOrder."Web Shipment Carrier" := WEBShipmentHeader."Tracking Carrier";
            SalesOrder.MODIFY;
        END;


        IF NOT WarehouseActivityLine.FINDFIRST THEN BEGIN
            WarehouseShipmentLine.SETRANGE("Source No.", WEBShipmentHeader."Order ID");
            IF WarehouseShipmentLine.FINDFIRST THEN BEGIN
                WarehouseShipmentHeader.GET(WarehouseShipmentLine."No.");
                WarehouseShipmentHeader.TESTFIELD(Status, WarehouseShipmentHeader.Status::Released);
                IF WarehouseShipmentLine.FIND('-') THEN BEGIN
                    CreatePickFromWhseShpt.SetWhseShipmentLine(WarehouseShipmentLine, WarehouseShipmentHeader);
                    CreatePickFromWhseShpt.SetHideValidationDialog(TRUE);
                    CreatePickFromWhseShpt.USEREQUESTPAGE(FALSE);
                    CreatePickFromWhseShpt.RUNMODAL;
                    CreatePickFromWhseShpt.GetResultMessage;
                    CLEAR(CreatePickFromWhseShpt);
                    COMMIT;
                    SELECTLATESTVERSION
                END;
            END;
        END;

        IF (SalesOrder."No." <> '') AND (WarehouseShipmentHeader."No." <> '') AND (SalesOrder."Shipping No." <> WarehouseShipmentHeader."No.") THEN BEGIN
            SalesOrder."Shipping No." := '';
            SalesOrder.MODIFY;
            COMMIT;
        END;

        IF (SalesOrder.Status <> SalesOrder.Status::Released) AND (NOT HideMessages) THEN
            MESSAGE('Sales Order %1 isn''t released.', SalesOrder."No.");

        IF WarehouseActivityLine.FINDFIRST THEN BEGIN
            WhseActivLine.COPY(WarehouseActivityLine);
            //WhseActivLine.FILTERGROUP(3);
            //WhseActivLine.SETRANGE(Breakbulk);
            //WhseActivLine.FILTERGROUP(0);
            //MESSAGE(WhseActivLine.GETFILTERS);
            WhseActivityRegister.RUN(WhseActivLine);
            Status := Status::" ";
            Error := '';
            MODIFY;
            COMMIT;
            IF NOT HideMessages THEN
                MESSAGE('Pick Found and posted');
        END ELSE
            IF NOT HideMessages THEN
                MESSAGE('No Pick Found');

        // Post the shipment
        WarehouseShipmentLine.RESET;
        WarehouseShipmentLine.SETRANGE("Source No.", WEBShipmentHeader."Order ID");
        WarehouseShipmentLine.SETRANGE("Source Type", 37);
        WarehouseShipmentLine.SETRANGE("Source Subtype", 1);
        IF WarehouseShipmentLine.FINDFIRST THEN BEGIN
            WarehouseShipmentHeader.GET(WarehouseShipmentLine."No.");
            WarehouseShipmentHeader.TESTFIELD(Status, WarehouseShipmentHeader.Status::Released);
            WarehouseShipmentLine2.SETRANGE("No.", WarehouseShipmentHeader."No.");
            WarehouseShipmentLine.AutofillQtyToHandle(WarehouseShipmentLine2);

            WarehouseShipmentLine2.SETFILTER("Qty. to Ship", '>0');
            IF (NOT WarehouseShipmentLine2.ISEMPTY) AND (SalesOrder.Status = SalesOrder.Status::Released) THEN BEGIN
                WhsePostShipment.SetPostingSettings(FALSE);
                WhsePostShipment.SetPrint(FALSE);
                WhsePostShipment.RUN(WarehouseShipmentLine);
                IF NOT HideMessages THEN
                    WhsePostShipment.GetResultMessage;
                CLEAR(WhsePostShipment);
            END;
        END;
        COMMIT;


        /*
        COMMIT;
        // invoice shipped lines
        SalesLine.SETRANGE("Document Type",SalesLine."Document Type"::Order);
        SalesLine.SETRANGE("Document No.",WEBShipmentHeader."Order ID");
        IF SalesLine.FINDSET THEN REPEAT
          CASE SalesLine.Type OF
            SalesLine.Type::Item:
              BEGIN
                SalesLine.VALIDATE("Qty. to Ship",0);
                SalesLine.VALIDATE("Qty. to Invoice",SalesLine."Quantity Shipped"-SalesLine."Quantity Invoiced");
              END;
            SalesLine.Type::"G/L Account":
              BEGIN
                SalesLine.VALIDATE("Qty. to Ship",SalesLine."Outstanding Quantity");
                SalesLine.VALIDATE("Qty. to Invoice",SalesLine.Quantity-SalesLine."Quantity Invoiced");
              END;
            ELSE
              BEGIN
                SalesLine.VALIDATE("Qty. to Ship",0);
                SalesLine.VALIDATE("Qty. to Invoice",0);
              END;
          END;
          SalesLine.MODIFY(TRUE);
        UNTIL SalesLine.NEXT = 0;
        SalesHeader.GET(SalesHeader."Document Type"::Order,WEBShipmentHeader."Order ID");
        SalesHeader.Ship := TRUE;
        SalesHeader.Invoice := TRUE;
        
        SalesHeader.MODIFY;
        SalesPost.RUN(SalesHeader);
        */

    end;
    //MITL3118.AJ.19MAR2020 ++

    Local procedure UpdateNewPickBininPickLines()
    var
        WhseActLinesL: Record "Warehouse Activity Line";
    Begin
        WhseActLinesL.Reset();
        WhseActLinesL.SetCurrentKey("Activity Type", "No.", "Action Type", "Bin Code");
        WhseActLinesL.SetRange("Activity Type", WhseActLinesL."Activity Type"::Pick);
        WhseActLinesL.SetRange("Action Type", WhseActLinesL."Action Type"::Take);
        IF WhseActLinesL.FindSet() THEN
            REPEAT
                WhseActLinesL."Picking Bin" := FindDefaultBinCode(WhseActLinesL);
                WhseActLinesL."Bin Code" := '';
                WhseActLinesL.Modify();
            UNTIL WhseActLinesL.Next() = 0;

    End;

    local procedure FindDefaultBinCode(WhseActLinesP: Record "Warehouse Activity Line"): Code[20]
    var
        BinContentL: Record "Bin Content";
    Begin
        BinContentL.Reset();
        BinContentL.SetCurrentKey(Default, "Location Code", "Item No.", "Variant Code", "Bin Code");
        BinContentL.SetRange(Default, true);
        BinContentL.SetRange("Location Code", WhseActLinesP."Location Code");
        BinContentL.SetRange("Item No.", WhseActLinesP."Item No.");
        If BinContentL.FindFirst() then
            Exit(BinContentL."Bin Code");
    End;
    //MITL3118.AJ.19MAR2020 **
    procedure PostPick(WEBIndex: Record "WEB Index")
    var
        WEBShipmentHeader: Record "WEB Shipment Header";
        WarehouseActivityLine: Record "Warehouse Activity Line";
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        WhseActivityRegister: Codeunit "Whse.-Activity-Register";
        WhseActivLine: Record "Warehouse Activity Line";
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        WarehouseShipmentLine2: Record "Warehouse Shipment Line";
        CreatePickFromWhseShpt: Report "Whse.-Shipment - Create Pick";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesPost: Codeunit "Sales-Post";
        WhsePostShipment: Codeunit "Whse.-Post Shipment";
        SalesOrder: Record "Sales Header";
        HideMessages: Boolean;
    begin
        //WEBShipmentHeader.GET("Key Field 1",FORMAT("Key Field 2"),"Key Field 3");
        IF WEBIndex."Line no." = 0 THEN BEGIN
            Rec := WEBIndex;

        END;
        HideMessages := TRUE;

        WEBIndex.Status := Status::" ";
        WEBIndex.Error := '';
        WEBIndex.MODIFY;

        WEBShipmentHeader.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WEBShipmentHeader.FINDFIRST THEN BEGIN
            WarehouseActivityLine.SETRANGE("Source No.", WEBShipmentHeader."Order ID");

            IF SalesOrder.GET(SalesOrder."Document Type"::Order, WEBShipmentHeader."Order ID") THEN BEGIN
                SalesOrder."Shipping No." := WEBShipmentHeader."Shipment ID";
                SalesOrder."Posting Date" := WEBShipmentHeader."Shipment Date";
                SalesOrder.Ship := TRUE;
                SalesOrder.Invoice := TRUE;
                SalesOrder."Web Shipment Increment Id" := WEBShipmentHeader."Shipment ID";
                SalesOrder."Web Shipment Tracing No." := WEBShipmentHeader."Tracking Number";
                SalesOrder."Web Shipment Carrier" := WEBShipmentHeader."Tracking Carrier";
                SalesOrder.MODIFY;
            END;


            IF NOT WarehouseActivityLine.FINDFIRST THEN BEGIN
                WarehouseShipmentLine.SETRANGE("Source No.", WEBShipmentHeader."Order ID");
                IF WarehouseShipmentLine.FINDFIRST THEN BEGIN
                    WarehouseShipmentHeader.GET(WarehouseShipmentLine."No.");
                    WarehouseShipmentHeader.TESTFIELD(Status, WarehouseShipmentHeader.Status::Released);
                    IF WarehouseShipmentLine.FIND('-') THEN BEGIN
                        CreatePickFromWhseShpt.SetWhseShipmentLine(WarehouseShipmentLine, WarehouseShipmentHeader);
                        CreatePickFromWhseShpt.SetHideValidationDialog(TRUE);
                        CreatePickFromWhseShpt.USEREQUESTPAGE(FALSE);
                        CreatePickFromWhseShpt.RUNMODAL;
                        CreatePickFromWhseShpt.GetResultMessage;
                        CLEAR(CreatePickFromWhseShpt);
                        COMMIT;
                        SELECTLATESTVERSION
                    END;
                END;
            END;

            IF (SalesOrder."No." <> '') AND (WarehouseShipmentHeader."No." <> '') AND (SalesOrder."Shipping No." <> WarehouseShipmentHeader."No.") THEN BEGIN
                SalesOrder."Shipping No." := '';
                SalesOrder.MODIFY;
                COMMIT;
            END;

            IF (SalesOrder.Status <> SalesOrder.Status::Released) AND (NOT HideMessages) THEN
                MESSAGE('Sales Order %1 isn''t released.', SalesOrder."No.");

            IF WarehouseActivityLine.FINDFIRST THEN BEGIN
                WhseActivLine.COPY(WarehouseActivityLine);
                //WhseActivLine.FILTERGROUP(3);
                //WhseActivLine.SETRANGE(Breakbulk);
                //WhseActivLine.FILTERGROUP(0);
                //MESSAGE(WhseActivLine.GETFILTERS);
                WhseActivityRegister.RUN(WhseActivLine);
                WEBIndex.Status := Status::" ";
                WEBIndex.Error := '';
                WEBIndex.MODIFY;
                COMMIT;
                IF NOT HideMessages THEN
                    MESSAGE('Pick Found and posted');
            END ELSE
                IF NOT HideMessages THEN
                    MESSAGE('No Pick Found');
        END;
        // Post the shipment
        WarehouseShipmentLine.RESET;
        WarehouseShipmentLine.SETRANGE("Source No.", WEBShipmentHeader."Order ID");
        WarehouseShipmentLine.SETRANGE("Source Type", 37);
        WarehouseShipmentLine.SETRANGE("Source Subtype", 1);
        IF WarehouseShipmentLine.FINDFIRST THEN BEGIN
            WarehouseShipmentHeader.GET(WarehouseShipmentLine."No.");
            WarehouseShipmentHeader.TESTFIELD(Status, WarehouseShipmentHeader.Status::Released);
            WarehouseShipmentLine2.SETRANGE("No.", WarehouseShipmentHeader."No.");
            WarehouseShipmentLine.AutofillQtyToHandle(WarehouseShipmentLine2);
            //
            //  WarehouseShipmentLine2.SETFILTER("Qty. to Ship",'>0');
            //  IF (NOT WarehouseShipmentLine2.ISEMPTY) AND (SalesOrder.Status = SalesOrder.Status::Released) THEN BEGIN
            //    WhsePostShipment.SetPostingSettings(FALSE);
            //    WhsePostShipment.SetPrint(FALSE);
            //    WhsePostShipment.RUN(WarehouseShipmentLine);
            //    IF NOT HideMessages THEN
            //      WhsePostShipment.GetResultMessage;
            //    CLEAR(WhsePostShipment);
            //  END;
        END;
        COMMIT;


        /*
        COMMIT;
        // invoice shipped lines
        SalesLine.SETRANGE("Document Type",SalesLine."Document Type"::Order);
        SalesLine.SETRANGE("Document No.",WEBShipmentHeader."Order ID");
        IF SalesLine.FINDSET THEN REPEAT
          CASE SalesLine.Type OF
            SalesLine.Type::Item:
              BEGIN
                SalesLine.VALIDATE("Qty. to Ship",0);
                SalesLine.VALIDATE("Qty. to Invoice",SalesLine."Quantity Shipped"-SalesLine."Quantity Invoiced");
              END;
            SalesLine.Type::"G/L Account":
              BEGIN
                SalesLine.VALIDATE("Qty. to Ship",SalesLine."Outstanding Quantity");
                SalesLine.VALIDATE("Qty. to Invoice",SalesLine.Quantity-SalesLine."Quantity Invoiced");
              END;
            ELSE
              BEGIN
                SalesLine.VALIDATE("Qty. to Ship",0);
                SalesLine.VALIDATE("Qty. to Invoice",0);
              END;
          END;
          SalesLine.MODIFY(TRUE);
        UNTIL SalesLine.NEXT = 0;
        SalesHeader.GET(SalesHeader."Document Type"::Order,WEBShipmentHeader."Order ID");
        SalesHeader.Ship := TRUE;
        SalesHeader.Invoice := TRUE;
        
        SalesHeader.MODIFY;
        SalesPost.RUN(SalesHeader);
        */

    end;
}

