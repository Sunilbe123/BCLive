codeunit 50006 "WEB Handling Item"
{
    // version RM 17082015,R4238,R4596

    // RM 17/08/2014
    // Changes marked with RM
    // 
    // R4238 - RM - 10.12.2015
    // Stop Vendor Item No. being updated
    // 
    // R4596 - RM - 16.02.2016
    // If WEBItem.Name is blank then do not perform a modify as this usually strips items of details

    TableNo = "WEB Index";

    trigger OnRun()
    begin
        //RM 18.09.2015 >>
        HandleItem(Rec);
        //RM 18.09.2015 <<
    end;

    var
        WebSetup: Record "WEB Setup";
        WebItem: Record "WEB Item";
        WEbToolbox: Codeunit "WEB Toolbox";
        BlankDecTxt: Label 'Blank Description Ignored';

    procedure GetWebSetup()
    begin
        WebSetup.GET;
    end;

    procedure HandleItem(var WebIndex: Record "WEB Index")
    begin
        WebItem.Reset();
        WebItem.SETFILTER("Index No.", FORMAT(WebIndex."Line no."));
        WebItem.FINDFIRST;
        CASE WebItem."LineType" OF
            WebItem."LineType"::Insert:
                WEBItemInsert(WebIndex);
                //RM 17/08/2015 >>
            WebItem."LineType"::Modify:
                WEBItemModify(WebIndex);
            WebItem."LineType"::Delete:
                WEBItemDelete(WebIndex);
                //RM 17/08/2015 <<
        END;
    end;

    procedure WEBItemInsert(var WEBIndex: Record "WEB Index")
    var
        Item: Record Item;
        ReCRef: RecordRef;
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        ConfigTemplateHeader: Record "Config. Template Header";
        WEBItem: Record "WEB Item";
    begin
        GetWebSetup;
        WebSetup.TESTFIELD("WEB Item Template");

        WEBItem.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        WEBItem.FINDFIRST;
        CASE WEBItem."LineType" OF
            WEBItem."LineType"::Insert:
                BEGIN
                    IF NOT Item.GET(WEBItem.SKU) THEN BEGIN
                        Item.INIT;
                        Item."No." := WEBItem.SKU;
                        Item.INSERT(TRUE);
                        Item.Description := COPYSTR(WEBItem.Name, 1, 50);
                        Item."Description 2" := COPYSTR(WEBItem.Name, 51, 50);
                        Item."Vendor Item No." := WEBItem."Manufacturer SKU";
                        IF WEBItem.Barcode <> '' THEN
                            InsertItemCrossRef(WEBItem.SKU, WEBItem.Barcode);

                        //WEBItem.Barcode
                        IF WEBItem.Weight <> 0 THEN
                            Item."Gross Weight" := WEBItem.Weight;
                        IF WEBItem.Height <> 0 THEN
                            Item.Height := WEBItem.Height;
                        IF WEBItem.Width <> 0 THEN
                            Item.Width := WEBItem.Width;

                        // MITL 14068 ++
                        IF WEBItem.Weight <> 0 THEN
                            Item."Net Weight" := WEBItem.Weight;
                        IF WEBItem."Vendor Number" <> '' THEN
                            Item."Vendor No." := WEBItem."Vendor Number";
                        IF WEBItem."Manufacturer SKU" <> '' THEN
                            Item."Vendor Item No." := WEBItem."Manufacturer SKU";
                        IF (WEBItem.Height <> 0) AND (WEBItem.Width <> 0) THEN
                            Item.Size := FORMAT(WEBItem.Height) + 'X' + FORMAT(WEBItem.Width);
                        Item.Status := Item.Status::Current;
                        // MITL 14068 --

                        Item."Qty Per SQM" := WEBItem."Qty Per SQM";

                        Item.VALIDATE("Unit Price", WEBItem.Price);
                        Item.VALIDATE("Base Unit of Measure", 'PCS');
                        Item.MODIFY(TRUE);
                        ReCRef.GETTABLE(Item);
                        ConfigTemplateHeader.SETRANGE(ConfigTemplateHeader.Code, WebSetup."WEB Item Template");
                        ConfigTemplateHeader.FINDFIRST;
                        ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, ReCRef);
                        WEbToolbox.UpdateIndex(WEBIndex, 1, '');
                    END ELSE
                        WEbToolbox.UpdateIndex(WEBIndex, 2, 'Item Already exists');
                END;
            WEBItem."LineType"::Delete: //WEbToolbox.UpdateIndex(WEBIndex,1,''); //RM 17/08/2015
                WEbToolbox.UpdateIndex(WEBIndex, 2, 'Item Delete not allowed');
                //RM 17/08/2015 <<
        END;
    end;

    procedure WEBItemModify(var WEBIndex: Record "WEB Index")
    var
        Item: Record Item;
        ReCRef: RecordRef;
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        ConfigTemplateHeader: Record "Config. Template Header";
        WEBItem: Record "WEB Item";
    begin
        //RM 17/08/2015 >>
        GetWebSetup;
        WebSetup.TESTFIELD("WEB Item Template");
        WEBItem.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        WEBItem.FINDFIRST;
        IF Item.GET(WEBItem.SKU) THEN BEGIN

            //R4596 >>
            IF WEBItem.Name = '' THEN BEGIN
                WEbToolbox.UpdateIndex(WEBIndex, 3, BlankDecTxt);
                EXIT;
            END;
            //R4596 <<

            Item.Description := COPYSTR(WEBItem.Name, 1, 50);
            Item."Description 2" := COPYSTR(WEBItem.Name, 51, 50);
            //Item."Vendor Item No." := WEBItem."Manufacturer SKU"; //Stop update as per request from Matt  R4238
            Item.VALIDATE("Unit Price", WEBItem.Price);
            Item.VALIDATE("Base Unit of Measure", 'PCS');
            IF WEBItem.Barcode <> '' THEN
                InsertItemCrossRef(WEBItem.SKU, WEBItem.Barcode);

            //WEBItem.Barcode
            IF WEBItem.Weight <> 0 THEN
                Item."Gross Weight" := WEBItem.Weight;
            IF WEBItem.Height <> 0 THEN
                Item.Height := WEBItem.Height;
            IF WEBItem.Width <> 0 THEN
                Item.Width := WEBItem.Width;

            // MITL 14068 ++
            IF WEBItem.Weight <> 0 THEN
                Item."Net Weight" := WEBItem.Weight;
            IF WEBItem."Vendor Number" <> '' THEN
                Item."Vendor No." := WEBItem."Vendor Number";
            IF WEBItem."Manufacturer SKU" <> '' THEN
                Item."Vendor Item No." := WEBItem."Manufacturer SKU";
            IF (WEBItem.Height <> 0) AND (WEBItem.Width <> 0) THEN
                Item.Size := FORMAT(WEBItem.Height) + 'X' + FORMAT(WEBItem.Width);
            // MITL 14068 --

            Item."Qty Per SQM" := WEBItem."Qty Per SQM";
            Item.MODIFY(TRUE);

            ReCRef.GETTABLE(Item);
            ConfigTemplateHeader.SETRANGE(ConfigTemplateHeader.Code, WebSetup."WEB Item Template");
            ConfigTemplateHeader.FINDFIRST;
            ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, ReCRef);
            WEbToolbox.UpdateIndex(WEBIndex, 1, '');
        END ELSE
            WEbToolbox.UpdateIndex(WEBIndex, 2, 'Item Does not exists');
        //RM 17/08/2015 <<
    end;

    procedure WEBItemDelete(var WEBIndex: Record "WEB Index")
    var
        Item: Record Item;
        ReCRef: RecordRef;
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        ConfigTemplateHeader: Record "Config. Template Header";
        WEBItem: Record "WEB Item";
    begin
        //RM 17/08/2015 >>
        GetWebSetup;
        WebSetup.TESTFIELD("WEB Item Template");
        WEBItem.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WEBItem.FINDFIRST then;
        //  WEBItem.Type::Delete : WEbToolbox.UpdateIndex(WEBIndex,1,''); //RM 17/08/2015
        WEbToolbox.UpdateIndex(WEBIndex, 2, 'Item Delete not allowed');
        //RM 17/08/2015 <<
    end;

    local procedure InsertItemCrossRef(ItemNo: Code[20]; Barcode: Text[100])
    var
        ItemCrossReference: Record "Item Cross Reference";
    begin
        ItemCrossReference.INIT;
        ItemCrossReference."Item No." := ItemNo;
        ItemCrossReference."Cross-Reference Type" := ItemCrossReference."Cross-Reference Type"::"Bar Code";
        ItemCrossReference."Cross-Reference No." := Barcode;
        ItemCrossReference."Unit of Measure" := 'PCS';
        IF ItemCrossReference.INSERT THEN;
    end;
}

