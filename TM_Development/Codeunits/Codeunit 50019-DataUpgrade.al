codeunit 50019 DataUpgrade
{
    Subtype = Upgrade;
    trigger OnRun()
    begin

    end;

    trigger OnCheckPreconditionsPerCompany()
    begin

    end;

    trigger OnCheckPreconditionsPerDatabase()
    begin

    end;

    trigger OnUpgradePerCompany()
    var
        archivedVersion: Text;
    begin
        archivedVersion := NAVAPP.GetArchiveVersion();
        if archivedVersion = '1.0.0.0' then begin
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::SalesOrderProcessingBatch);
            // NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Bin Data Update"); //MITL.AJ.03032020 On request of MATT stock values will be read from SQL now.
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Payment Method Template MAP");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Cut Size Analysis");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Activity Tracking Audit");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Unplanned Counts Registrations");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Rox Logging");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Scanner Scans");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Item Attributes");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Customer");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Order Header");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Order Lines");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Posted Pick Audit");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Customer Ship-To");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Shipment Header");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Shipment Lines");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Item");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Item Attribute");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Credit Header");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Credit Lines");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Index");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Mapping");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Setup");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Requests");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Cue");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Log");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Available Stock");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Customer Bill-To");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Order Status");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Daily Reconciliation");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Combined Picks");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Web Write Offs");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB User Scan");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"WEB Item Updates");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Pick Crt_Whse Shp Lines");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Pick Crt_Buffer1");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Pick Crt_Buffer2");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Pick Creation Status");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Activity Master");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Activity Status");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Scale Weight Capture");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::ItemChgCalculation);
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::Location);
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"G/L Entry");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::Customer);
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::Item);
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Cust. Ledger Entry");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Sales Header");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Sales Line");
            NAVAPP.RESTOREARCHIVEDATA(DATABASE::"Purchase Header");
            NavApp.RestoreArchiveData(Database::"Purchase Line");
            NavApp.RestoreArchiveData(Database::"Gen. Journal Line");
            NavApp.RestoreArchiveData(Database::"User Setup");
            NavApp.RestoreArchiveData(Database::"Sales Shipment Header");
            NavApp.RestoreArchiveData(Database::"Sales Shipment Line");
            NavApp.RestoreArchiveData(Database::"Sales Invoice Header");
            NavApp.RestoreArchiveData(Database::"Sales Invoice Line");
            NavApp.RestoreArchiveData(Database::"Sales Cr.Memo Header");
            NavApp.RestoreArchiveData(Database::"Sales Cr.Memo Line");
            NavApp.RestoreArchiveData(Database::"Purch. Inv. Line");
            NavApp.RestoreArchiveData(Database::"Reason Code");
            NavApp.RestoreArchiveData(Database::"Sales & Receivables Setup");
            NavApp.RestoreArchiveData(Database::"Inventory Setup");
            NavApp.RestoreArchiveData(Database::"Warehouse Activity Header");
            NavApp.RestoreArchiveData(Database::"Warehouse Activity Line");
            NavApp.RestoreArchiveData(Database::"Registered Whse. Activity Hdr.");
            NavApp.RestoreArchiveData(Database::"Registered Whse. Activity Line");
            NavApp.RestoreArchiveData(Database::"Item Charge");
            NavApp.RestoreArchiveData(Database::"Value Entry");
            NavApp.RestoreArchiveData(Database::"Item Charge Assignment (Purch)");
            NavApp.RestoreArchiveData(Database::"Warehouse Shipment Header");
            NavApp.RestoreArchiveData(Database::"Warehouse Shipment Line");
            NavApp.RestoreArchiveData(Database::"Whse. Worksheet Line");
            NavApp.RestoreArchiveData(Database::"Whse. Worksheet Name");
            NavApp.RestoreArchiveData(Database::"Warehouse Journal Line");
            NavApp.RestoreArchiveData(Database::"Warehouse Entry");
            NavApp.RestoreArchiveData(Database::"Bin Content Buffer");
            NavApp.RestoreArchiveData(Database::"Item Ledger Entry");
            NavApp.RestoreArchiveData(Database::"Ship-to Address");
            NavApp.RestoreArchiveData(Database::"Bank Account Ledger Entry");
            NavApp.RestoreArchiveData(Database::"Job Queue Entry");
            NavApp.RestoreArchiveData(Database::"Sales Price");
            NavApp.RestoreArchiveData(Database::"Sales Line Discount");
            NavApp.RestoreArchiveData(Database::"Bin Content");
            NavApp.RestoreArchiveData(Database::Bin);
            NavApp.RestoreArchiveData(Database::Vendor);
            NavApp.RestoreArchiveData(Database::"Reminder Header");
        end;
    end;

    trigger OnUpgradePerDatabase()
    begin

    end;

    trigger OnValidateUpgradePerCompany()
    begin

    end;

    trigger OnValidateUpgradePerDatabase()
    begin

    end;

}