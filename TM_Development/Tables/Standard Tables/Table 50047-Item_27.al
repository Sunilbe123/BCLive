tableextension 50047 tems extends Item
{
    //ver MITL2219,R1666,R2173,MITL13605
    //MITL2219 - Added new fields for Scale Integration Requirement
    fields
    {
        // Add changes to table fields here
        field(50000; "Manufacturer Description"; Text[70])
        {
            Description = 'R1666';
        }
        field(50001; Size; Text[30])
        {
            Description = 'R1666';
        }
        field(50002; "Manufacturer SKU"; Text[30])
        {
            Description = 'R1666';
        }
        field(50003; Discontinued; Boolean)
        {
        }
        field(50004; "Inventory_(No Returns)"; Decimal)
        {
            Description = 'R2173';
            FieldClass = FlowField;
            CalcFormula = Sum ("Item Ledger Entry".Quantity WHERE ("Item No." = FIELD ("No."), "Global Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"), "Global Dimension 2 Code" = FIELD ("Global Dimension 2 Filter"), "Location Code" = FILTER (<> 'RETURNS'), "Drop Shipment" = FIELD ("Drop Shipment Filter"), "Variant Code" = FIELD ("Variant Filter"), "Lot No." = FIELD ("Lot No. Filter"), "Serial No." = FIELD ("Serial No. Filter")));
            Editable = false;
        }
        field(50005; "Qty Per SQM"; Decimal)
        {
        }
        field(50006; Height; Decimal)
        {
        }
        field(50007; Width; Decimal)
        {
        }
        field(50008; Status; Option)
        {
            OptionMembers = "",Current,Clearance,Discontinued,"To Order","Shop Only";
        }
        field(50009; "Item Weight Tolerence %"; Decimal)
        {
            Description = 'MITL2219';
            CaptionML = ENU = 'Item Weight Tolerence %', ENG = 'Item Weight Tolerence %';
        }
        field(50014; "Product Type"; Option)
        {
            Description = 'MITL13605';
            OptionMembers = " ",Accessories,Tiles;
        }
        field(50020; WebItemFlag; Boolean)
        {
        }
        field(50021; WebID; text[30])
        {
        }
        field(50022; WebSyncFlag; Code[1])
        {
        }
        field(50023; WebStockFlag; Code[1])
        {
        }
        field(50024; WebTierPriceSyncFlag; Code[1])
        {
        }
        field(50025; WebSpecialPriceSyncFlag; Code[1])
        {
        }
        field(50026; WebProdType; Option)
        {
            OptionMembers = " ",Simple,Configurable,Bundle,Grouped;
            InitValue = Simple;
        }
        field(50027; WebPriceType; Option)
        {
            OptionMembers = "",Fixed,Dynamic;
        }
        // MITL17Jan2020 ++
        field(50028; "Landed Cost"; Decimal)
        {
            CaptionML = ENG = 'Landed Cost', ENU = 'Landed Cost';
        }
        // MITL17Jan2020 --


    }

    var
        myInt: Integer;
}