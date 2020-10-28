page 50069 BinContentsCustom
{
    // version NAVW113.00

    ApplicationArea = Warehouse;
    Caption = 'Stock Details For Items';
    DataCaptionExpression = '';
    InsertAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Bin Content";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Options1)
            {
                Caption = 'Options';
                field(LocationCodeG; LocationCodeG)
                {
                    ApplicationArea = Location;
                    Caption = 'Location Filter';
                    ToolTip = 'Specifies the locations that bin contents are shown for.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Location.RESET;
                        Location.SETRANGE("Bin Mandatory", TRUE);
                        IF LocationCodeG <> '' THEN
                            Location.Code := LocationCodeG;
                        IF PAGE.RUNMODAL(PAGE::"Locations with Warehouse List", Location) = ACTION::LookupOK THEN BEGIN
                            Location.TESTFIELD("Bin Mandatory", TRUE);
                            LocationCodeG := Location.Code;
                            DefFilter;
                        END;
                        CurrPage.UPDATE(TRUE);
                    end;

                    trigger OnValidate()
                    begin
                        ZoneCodeG := '';
                        IF LocationCodeG <> '' THEN BEGIN
                            IF WMSMgt.LocationIsAllowed(LocationCodeG) THEN BEGIN
                                Location.GET(LocationCodeG);
                                Location.TESTFIELD("Bin Mandatory", TRUE);
                            END ELSE
                                ERROR(Text000, USERID);
                        END;
                        DefFilter;
                        LocationCodeOnAfterValidate;
                    end;
                }
                field(ZoneCodeG; ZoneCodeG)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Zone Filter';
                    ToolTip = 'Specifies the filter that allows you to see an overview of the documents with a certain value in the Service Zone Code field.';

                    trigger OnLookup(var TextP: Text): Boolean
                    begin
                        Zone.RESET;
                        IF ZoneCodeG <> '' THEN
                            Zone.Code := ZoneCodeG;
                        IF LocationCodeG <> '' THEN
                            Zone.SETRANGE("Location Code", LocationCodeG);
                        IF PAGE.RUNMODAL(0, Zone) = ACTION::LookupOK THEN BEGIN
                            ZoneCodeG := Zone.Code;
                            LocationCodeG := Zone."Location Code";
                            DefFilter;
                        END;
                        CurrPage.UPDATE(TRUE);
                    end;

                    trigger OnValidate()
                    begin
                        DefFilter;
                        ZoneCodeOnAfterValidate;
                    end;
                }
            }
            repeater(Detail)
            {
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the location code of the bin.';
                    Visible = false;
                }
                field("Zone Code"; "Zone Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the zone code of the bin.';
                    Visible = false;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the bin where the items are picked or put away.';

                    trigger OnValidate()
                    begin
                        CheckQty;
                    end;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the item that will be stored in the bin.';

                    trigger OnValidate()
                    begin
                        CheckQty;
                    end;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        CheckQty;
                    end;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Qty. per Unit of Measure"; "Qty. per Unit of Measure")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of base units of measure that are in the unit of measure specified for the item in the bin.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        CheckQty;
                    end;
                }
                field(Default; Default)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies if the bin is the default bin for the associated item.';
                }
                field(Dedicated; Dedicated)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies if the bin is used as a dedicated bin, which means that its bin content is available only to certain resources.';
                }
                field("Warehouse Class Code"; "Warehouse Class Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the warehouse class code. Only items with the same warehouse class can be stored in this bin.';
                }
                field("Bin Type Code"; "Bin Type Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code of the bin type that was selected for this bin.';
                }
                field("Bin Ranking"; "Bin Ranking")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the bin ranking.';
                }
                field("Block Movement"; "Block Movement")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies how the movement of a particular item, or bin content, into or out of this bin, is blocked.';
                }
                field("Min. Qty."; "Min. Qty.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the minimum number of units of the item that you want to have in the bin at all times.';
                }
                field("Max. Qty."; "Max. Qty.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the maximum number of units of the item that you want to have in the bin.';
                }
                field(CalcQtyUOM; CalcQtyUOM)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Quantity';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the quantity of the item in the bin that corresponds to the line.';
                }
                field("Quantity (Base)"; "Quantity (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies how many units of the item, in the base unit of measure, are stored in the bin.';
                }
                field("Pick Quantity (Base)"; "Pick Quantity (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies how many units of the item, in the base unit of measure, will be picked from the bin.';
                }
                field("ATO Components Pick Qty (Base)"; "ATO Components Pick Qty (Base)")
                {
                    ApplicationArea = Assembly;
                    ToolTip = 'Specifies how many assemble-to-order units are picked for assembly.';
                }
                field("Negative Adjmt. Qty. (Base)"; "Negative Adjmt. Qty. (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies how many item units, in the base unit of measure, will be posted on journal lines as negative quantities.';
                }
                field("Put-away Quantity (Base)"; "Put-away Quantity (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies how many units of the item, in the base unit of measure, will be put away in the bin.';
                }
                field("Positive Adjmt. Qty. (Base)"; "Positive Adjmt. Qty. (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies how many item units, in the base unit of measure, will be posted on journal lines as positive quantities.';
                }
                field(CalcQtyAvailToTakeUOM; CalcQtyAvailToTakeUOM)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Available Qty. to Take';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the quantity of the item that is available in the bin.';
                }
                field(FixedL; Fixed)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies that the item (bin content) has been associated with this bin, and that the bin should normally contain the item.';
                }
                field("Cross-Dock Bin"; "Cross-Dock Bin")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies if the bin content is in a cross-dock bin.';
                }
            }
            group(Group1)
            {
                fixed(FixedLayout1)
                {
                    group("Item Description")
                    {
                        Caption = 'Item Description';
                        field(ItemDescription; ItemDescription)
                        {
                            ApplicationArea = Warehouse;
                            Editable = false;
                            ShowCaption = false;
                        }
                    }
                    group("Qty. on Adjustment Bin")
                    {
                        Caption = 'Qty. on Adjustment Bin';
                        field(CalcQtyonAdjmtBin; CalcQtyonAdjmtBin)
                        {
                            ApplicationArea = Warehouse;
                            Caption = 'Qty. on Adjustment Bin';
                            DecimalPlaces = 0 : 5;
                            Editable = false;
                            ToolTip = 'Specifies the adjusted quantity in a bin, when the quantity recorded in the system is inaccurate because of a physical gain or loss of an item.';

                            trigger OnDrillDown()
                            var
                                WhseEntry: Record "Warehouse Entry";
                            begin
                                LocationGet("Location Code");
                                WhseEntry.SETCURRENTKEY(
                                  "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code");
                                WhseEntry.SETRANGE("Item No.", "Item No.");
                                WhseEntry.SETRANGE("Bin Code", AdjmtLocation."Adjustment Bin Code");
                                WhseEntry.SETRANGE("Location Code", "Location Code");
                                WhseEntry.SETRANGE("Variant Code", "Variant Code");
                                WhseEntry.SETRANGE("Unit of Measure Code", "Unit of Measure Code");

                                PAGE.RUNMODAL(PAGE::"Warehouse Entries", WhseEntry);
                            end;
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            part("Lot Numbers by Bin FactBox"; "Lot Numbers by Bin FactBox")
            {
                ApplicationArea = ItemTracking;
                SubPageLink = "Item No." = FIELD ("Item No."),
                              "Variant Code" = FIELD ("Variant Code"),
                              "Location Code" = FIELD ("Location Code");
                Visible = false;
            }
            systempart(RecordLinks; Links)
            {
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line1")
            {
                Caption = '&Line';
                Image = Line;
                action("Warehouse Entries")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Warehouse Entries';
                    Image = BinLedger;
                    RunObject = Page "Warehouse Entries";
                    RunPageLink = "Item No." = FIELD ("Item No."),
                                  "Location Code" = FIELD ("Location Code"),
                                  "Bin Code" = FIELD ("Bin Code"),
                                  "Variant Code" = FIELD ("Variant Code");
                    RunPageView = SORTING ("Item No.", "Bin Code", "Location Code", "Variant Code");
                    ToolTip = 'View completed warehouse activities related to the document.';
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        GetItemDescr("Item No.", "Variant Code", ItemDescription);
        DataCaption := STRSUBSTNO('%1 ', "Bin Code");
    end;

    trigger OnOpenPage()
    begin
        ItemDescription := '';
        GetWhseLocation(LocationCodeG, ZoneCodeG);
    end;

    var
        Location: Record Location;
        AdjmtLocation: Record Location;
        Zone: Record Zone;
        WMSMgt: Codeunit "WMS Management";
        LocationCodeG: Code[10];
        ZoneCodeG: Code[10];
        DataCaption: Text[80];
        ItemDescription: Text[50];
        Text000: Label 'Location code is not allowed for user %1.';
        LocFilter: Text[250];

    local procedure DefFilter()
    begin
        FILTERGROUP := 2;
        IF LocationCodeG <> '' THEN
            SETRANGE("Location Code", LocationCodeG)
        ELSE BEGIN
            CLEAR(LocFilter);
            CLEAR(Location);
            Location.SETRANGE("Bin Mandatory", TRUE);
            IF Location.FIND('-') THEN
                REPEAT
                    IF WMSMgt.LocationIsAllowed(Location.Code) THEN
                        LocFilter := LocFilter + Location.Code + '|';
                UNTIL Location.NEXT = 0;
            IF STRLEN(LocFilter) <> 0 THEN
                LocFilter := COPYSTR(LocFilter, 1, (STRLEN(LocFilter) - 1));
            SETFILTER("Location Code", LocFilter);
        END;
        IF ZoneCodeG <> '' THEN
            SETRANGE("Zone Code", ZoneCodeG)
        ELSE
            SETRANGE("Zone Code");
        FILTERGROUP := 0;
    end;

    local procedure CheckQty()
    begin
        TESTFIELD(Quantity, 0);
        TESTFIELD("Pick Qty.", 0);
        TESTFIELD("Put-away Qty.", 0);
        TESTFIELD("Pos. Adjmt. Qty.", 0);
        TESTFIELD("Neg. Adjmt. Qty.", 0);
    end;

    local procedure LocationGet(LocationCodeG: Code[10])
    begin
        IF AdjmtLocation.Code <> LocationCodeG THEN
            AdjmtLocation.GET(LocationCodeG);
    end;

    local procedure LocationCodeOnAfterValidate()
    begin
        CurrPage.UPDATE(TRUE);
    end;

    local procedure ZoneCodeOnAfterValidate()
    begin
        CurrPage.UPDATE(TRUE);
    end;
}

