report 50028 "Inventory by Location"
{
    DefaultLayout = RDLC;
    RDLCLayout = '.\InventoryByLocation.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Inventory By Location';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem(Invtbylocationloop; Integer)
        {
            column(LocationCode; InvtbylocQuery.Location_Code)
            {
            }
            column(Cost_Expected; InvtbylocQuery.Sum_Cost_Amount_Expected)
            {
            }
            column(Cose_Actual; InvtbylocQuery.Sum_Cost_Amount_Actual)
            {
            }
            column(Quantity; InvtbylocQuery.Sum_Quantity)
            {
            }
            column(CompanyInfo_Name; CompanyInformation.Name)
            {
            }
            column(Cost_Total; InvtbylocQuery.Sum_Cost_Amount_Actual + InvtbylocQuery.Sum_Cost_Amount_Expected)
            {
            }
            // MITL.SM.20200909 ++
            column(AmtonRcptBIN; AmtonRcptBIN)
            {

            }
            column(AmtonShipBIN; AmtonShipBIN)
            {

            }
            column(AmtonAdjBIN; AmtonAdjBIN)
            {

            }
            // MITL.SM.20200909 --
            trigger OnAfterGetRecord()
            begin
                AmtonRcptBIN := 0;
                AmtonShipBIN := 0;
                AmtonAdjBIN := 0;
                // AvgCost := 0;

                IF NOT InvtbylocQuery.READ THEN
                    CurrReport.BREAK;
                If InvtbylocQuery.Location_Code = '' then
                    CurrReport.Skip()
                // MITL.SM.20200909 ++
                else begin
                    //MITL.SM.20200918++
                    WhseEntry.Reset();
                    WhseEntry.SetCurrentKey("Location Code", "Bin Code");//MITL.VS.20201001
                    //WhseEntry.SetCurrentKey("Location Code", "Zone Code");
                    WhseEntry.SetRange("Location Code", InvtbylocQuery.Location_Code);
                    //WhseEntry.SetFilter("Zone Code", '%1|%2', 'RECEIVE', 'RECEIVING');
                    WhseEntry.SetFilter("Bin Code", '%1|%2', 'RECEIVE', 'RECEIVING');//MITL.VS.20201001
                    if WhseEntry.FindSet() then
                        repeat
                            recItem.Get(WhseEntry."Item No.");
                            AmtonRcptBIN += WhseEntry.Quantity * recItem."Unit Cost";
                        until WhseEntry.Next() = 0;

                    WhseEntry.Reset();
                    WhseEntry.SetCurrentKey("Location Code", "Bin Code");//MITL.VS.20201001		    
                    //WhseEntry.SetCurrentKey("Location Code", "Zone Code");
                    WhseEntry.SetRange("Location Code", InvtbylocQuery.Location_Code);
                    //WhseEntry.SetFilter("Zone Code", '%1|%2', 'SHIP', 'SHIPPING');
                    WhseEntry.SetFilter("Bin Code", '%1|%2', 'SHIP', 'SHIPPING');//MITL.VS.20201001
                    if WhseEntry.FindSet() then
                        repeat
                            recItem.Get(WhseEntry."Item No.");
                            AmtonShipBIN += WhseEntry.Quantity * recItem."Unit Cost";
                        until WhseEntry.Next() = 0;

                    WhseEntry.Reset();
                    WhseEntry.SetCurrentKey("Location Code", "Bin Code");//MITL.VS.20201001                    
                                                                         //WhseEntry.SetCurrentKey("Location Code", "Zone Code");
                    WhseEntry.SetRange("Location Code", InvtbylocQuery.Location_Code);
                    //WhseEntry.SetRange("Zone Code", 'ADJUSTMENT');
                    WhseEntry.SetRange("Bin Code", 'ADJ');//MITL.VS.20201001		    
                    if WhseEntry.FindSet() then
                        repeat
                            recItem.Get(WhseEntry."Item No.");
                            AmtonAdjBIN += WhseEntry.Quantity * recItem."Unit Cost";
                        until WhseEntry.Next() = 0;
                    //MITL.SM.20200918--

                    /*
                    if InvtbylocQuery.Sum_Quantity <> 0 then
                        AvgCost := ROUND((InvtbylocQuery.Sum_Cost_Amount_Expected + InvtbylocQuery.Sum_Cost_Amount_Actual) / InvtbylocQuery.Sum_Quantity, 0.01);
                    BINInventory.SETFILTER(BINInventory.Location_Code, InvtbylocQuery.Location_Code);
                    BINInventory.SETFILTER(BINInventory.Zone_Code, '%1|%2', 'RECEIVE', 'RECEIVING');
                    BINInventory.OPEN;
                    IF BINInventory.READ THEN
                        AmtonRcptBIN := round(BINInventory.Quantity * AvgCost, 0.01);

                    BINInventory.SETFILTER(BINInventory.Location_Code, InvtbylocQuery.Location_Code);
                    BINInventory.SETFILTER(BINInventory.Zone_Code, 'SHIP', 'SHIPPING');
                    BINInventory.OPEN;
                    IF BINInventory.READ THEN
                        AmtonShipBIN := round(BINInventory.Quantity * AvgCost, 0.01);

                    BINInventory.SETFILTER(BINInventory.Location_Code, InvtbylocQuery.Location_Code);
                    BINInventory.SETFILTER(BINInventory.Zone_Code, 'ADJUSTMENT');
                    BINInventory.OPEN;
                    IF BINInventory.READ THEN
                        AmtonAdjBIN := round(BINInventory.Quantity * AvgCost, 0.01);

                    */
                end;
                // MITL.SM.20200909 --

            end;

            trigger OnPostDataItem()
            begin
                InvtbylocQuery.CLOSE;
                // BINInventory.Close();
            end;

            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;

                //InvtbylocQuery.SetFilter(InvtbylocQuery.Type, 'Inventory');
                InvtbylocQuery.OPEN;
                // BINInventory.Open();

            end;
        }
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
        CompanyInformation: Record "Company Information";
        InvtbylocQuery: Query InventoryByLocationQuery;
        // BINInventory: Query "BIN Inventory";
        // MITL.SM.20200909 ++
        WhseEntry: Record "Warehouse Entry";
        recItem: Record Item;
        AvgCost: Decimal;
        AmtonRcptBIN: Decimal;
        AmtonShipBIN: Decimal;
        AmtonAdjBIN: Decimal;
        // MITL.SM.20200909 --
}