report 50030 "Suspect Inventory"
{
    UsageCategory = Administration;
    ApplicationArea = All;

    RDLCLayout = '.\SuspectInventory.rdlc';
    dataset
    {
        //dataitem(Zone; Zone)//MITL.VS.20200923
        //{
        //DataItemTableView = WHERE ("Bin Type Code" = FILTER ('RECEIVE' | 'SHIP'));//MITL.VS.20200923
        dataitem("Warehouse Entry"; "Warehouse Entry")
        {
            //DataItemTableView = /*sorting("Zone Code", "Source No.", "Item No.")*/ where ("Zone Code" = filter ('RECEIVE' | 'SHIP' | 'RECEIVING' | 'SHIPPING'));//RECIEVE
            DataItemTableView = /*sorting("Zone Code", "Source No.", "Item No.")*/ where ("Bin Code" = filter ('RECEIVE' | 'SHIP' | 'RECEIVING' | 'SHIPPING'));//MITL.VS.20201001

            //DataItemLinkReference = Zone;//MITL.VS.20200923
            //DataItemLink = "Location Code" = FIELD ("Location Code"), "Zone Code" = FIELD (Code);//MITL.VS.20200923

            column(Entry_No_; "Entry No.")
            {

            }
            column(Item_No_; "Item No.")
            {

            }
            column(Location_Code; "Location Code")
            {

            }
            column(Quantity; Quantity)
            {

            }
            column(SuspectReason; SuspectReason)
            {

            }
            column(CompanyInfo_Name; CompanyInfo.Name)
            {

            }
            column(CostAmount; CostAmount)
            {

            }
            column(Source_No_; "Source No.")
            {

            }
            column(Source_Line_No_; "Source Line No.")
            {

            }
            trigger OnPreDataItem()
            begin

            end;

            trigger OnAfterGetRecord()
            begin
                CostAmount := 0;
                //if "Zone Code" in ['RECEIVE', 'RECEIVING'] then begin//MITL.VS.20201001
                if "Bin Code" in ['RECEIVE', 'RECEIVING'] then begin//MITL.VS.20201001
                    if CheckQtyonReceivingZone() then
                        CurrReport.Skip()
                    else begin
                        g_recItem.Get("Warehouse Entry"."Item No.");
                        CostAmount := g_recItem."Unit Cost" * "Warehouse Entry".Quantity;
                        SuspectReason := 0;
                    end;
                end;
                //IF "Zone Code" IN ['SHIP', 'SHIPPING'] then begin
                IF "Bin Code" IN ['SHIP', 'SHIPPING'] then begin//MITL.VS.20201001
                    if CheckQtyonShippingZone() then
                        CurrReport.Skip()
                    else begin
                        g_recItem.Get("Warehouse Entry"."Item No.");
                        CostAmount := g_recItem."Unit Cost" * "Warehouse Entry".Quantity;
                        SuspectReason := 1;
                    end;
                end;
            end;

            trigger OnPostDataItem()
            begin

            end;
        }
        //}//MITL.VS.20200923

    }

    requestpage
    {
        layout
        {
            area(Content)
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
                    ApplicationArea = All;

                }
            }
        }
    }

    var
        SuspectReason: Option "Put-Away is missing","Sales Order not Found or not shipped","Mannual Movement";
        CompanyInfo: Record "Company Information";
        g_recItem: Record Item;
        CostAmount: Decimal;
        g_WhseEntryQty: Query "Whse. Entry Qty";

    local procedure CheckQtyonReceivingZone(): Boolean
    var
        l_WhseActiLines: Record "Warehouse Activity Line";
        l_RegisteredWhseActiLines: Record "Registered Whse. Activity Line";
    begin
        l_WhseActiLines.Reset();
        l_WhseActiLines.SetRange("Source Document", "Warehouse Entry"."Source Document");
        l_WhseActiLines.SetRange("Source No.", "Warehouse Entry"."Source No.");
        l_WhseActiLines.SetRange("Source Line No.", "Warehouse Entry"."Source Line No.");
        l_WhseActiLines.SetRange("Activity Type", l_WhseActiLines."Activity Type"::"Put-away");
        if l_WhseActiLines.FindFirst() then
            exit(true);

        l_RegisteredWhseActiLines.Reset();
        l_RegisteredWhseActiLines.SetRange("Source Document", "Warehouse Entry"."Source Document");
        l_RegisteredWhseActiLines.SetRange("Source No.", "Warehouse Entry"."Source No.");
        l_RegisteredWhseActiLines.SetRange("Source Line No.", "Warehouse Entry"."Source Line No.");
        l_RegisteredWhseActiLines.SetRange("Activity Type", l_WhseActiLines."Activity Type"::"Put-away");
        if l_RegisteredWhseActiLines.FindFirst() then
            exit(true);

        exit(false);
    end;

    trigger OnPreReport()
    begin
        CompanyInfo.get();
        // g_WhseEntryQty.Open();
    end;

    trigger OnPostReport()
    begin
        // g_WhseEntryQty.Close();
    end;

    local procedure CheckQtyonShippingZone(): Boolean
    var
        l_salesline: Record "Sales Line";
        PickQty: Decimal;
        ShippedQty: Decimal;

    begin
        PickQty := 0;
        ShippedQty := 0;
        l_salesline.Reset();
        l_salesline.SetRange("Document Type", "Warehouse Entry"."Source Subtype");
        l_salesline.SetRange("Document No.", "Warehouse Entry"."Source No.");
        l_salesline.SetRange("Line No.", "Warehouse Entry"."Source Line No.");
        if l_salesline.FindFirst() then
            exit(true);

        /*
        g_WhseEntryQty.SetRange(g_WhseEntryQty.Source_No_, "Warehouse Entry"."Source No.");
        g_WhseEntryQty.SetRange(g_WhseEntryQty.Source_Line_No_, "Warehouse Entry"."Source Line No.");
        g_WhseEntryQty.SetRange(g_WhseEntryQty.Location_Code, "Warehouse Entry"."Location Code");
        g_WhseEntryQty.SetRange(g_WhseEntryQty.Zone_Code, "Warehouse Entry"."Zone Code");
        g_WhseEntryQty.SetRange(g_WhseEntryQty.Source_Code, 'WHPICK');
        g_WhseEntryQty.Open();
        if g_WhseEntryQty.Read() then
            PickQty := g_WhseEntryQty.Quantity;
        g_WhseEntryQty.SetRange(g_WhseEntryQty.Source_No_, "Warehouse Entry"."Source No.");
        g_WhseEntryQty.SetRange(g_WhseEntryQty.Source_Line_No_, "Warehouse Entry"."Source Line No.");
        g_WhseEntryQty.SetRange(g_WhseEntryQty.Location_Code, "Warehouse Entry"."Location Code");
        g_WhseEntryQty.SetRange(g_WhseEntryQty.Zone_Code, "Warehouse Entry"."Zone Code");
        g_WhseEntryQty.SetRange(g_WhseEntryQty.Source_Code, 'SALES');
        g_WhseEntryQty.Open();
        if g_WhseEntryQty.Read() then
            ShippedQty := g_WhseEntryQty.Quantity;
        IF ABS(PickQty) = ABS(ShippedQty) then
            exit(true);
        */

        exit(false);
    end;
}