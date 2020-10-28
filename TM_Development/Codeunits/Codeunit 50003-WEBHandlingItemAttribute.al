codeunit 50003 "WEB Handling Item Attribute"
{
    // version RM 17082015,R4522

    // RM - 17.08.2015
    // Changes marked RM
    // 
    // R4522 - RM - 09.02.2016
    // Create new base unit of measure for item if not one present already, currently only BOX required.
    //   Added function UpdateBaseUOM

    TableNo = "WEB Index";

    trigger OnRun()
    var
        WebItemAttribute: Record "WEB Item Attribute";
    begin
        //RM 18.09.2015 >>
        HandleAttribute(Rec);
        //RM 18.09.2015 <<
    end;

    var
        ItemAttribute: Record "Item Attributes";
        WebToolbox: Codeunit "WEB Toolbox";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        BoxQtyText: Label 'BOX QUANTITY';
        BoxUOMText: Label 'BOX';

    procedure InsertAttribute(var WEBIndex: Record "WEB Index")
    var
        WebItemAttribute: Record "WEB Item Attribute";
    begin
        WebItemAttribute.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));

        IF WebItemAttribute.FINDFIRST THEN BEGIN
            IF ItemAttribute.GET(WebItemAttribute.Sku, WebItemAttribute.Attibute) THEN
                WebToolbox.UpdateIndex(WEBIndex, 2, 'Record Not Found')
            ELSE BEGIN
                ItemAttribute."Item No." := WebItemAttribute.Sku;
                ItemAttribute.Attribute := WebItemAttribute.Attibute;
                ItemAttribute."Attribute Value" := WebItemAttribute."Attribute Value";
                ItemAttribute.INSERT;

                UpdateBaseUOM(ItemAttribute); //R4522

                WebToolbox.UpdateIndex(WEBIndex, 1, '');
            END;
        END ELSE
            WebToolbox.UpdateIndex(WEBIndex, 2, 'Record Not Found');
    end;

    procedure ModifyAttribute(var WEBIndex: Record "WEB Index")
    var
        WebItemAttribute: Record "WEB Item Attribute";
    begin
        WebItemAttribute.Reset();
        WebItemAttribute.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WebItemAttribute.FINDFIRST THEN BEGIN
            IF ItemAttribute.GET(WebItemAttribute.Sku, WebItemAttribute.Attibute) THEN BEGIN
                ItemAttribute."Attribute Value" := WebItemAttribute."Attribute Value";
                ItemAttribute.MODIFY; //RM 17.08.2015

                UpdateBaseUOM(ItemAttribute); //R4522

                WebToolbox.UpdateIndex(WEBIndex, 1, '');
            END ELSE
                InsertAttribute(WEBIndex);
            WebToolbox.UpdateIndex(WEBIndex, 1, '');
            // WebToolbox.UpdateIndex(WEBIndex,1,'Import record not found'); //RM 17.08.2015
        END ELSE
            WebToolbox.UpdateIndex(WEBIndex, 2, 'Record not found to modify');
    end;

    procedure DeleteAttribute(var WEBIndex: Record "WEB Index")
    var
        WebItemAttribute: Record "WEB Item Attribute";
    begin
        WebItemAttribute.Reset();
        WebItemAttribute.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WebItemAttribute.FINDFIRST THEN BEGIN
            IF ItemAttribute.GET(WebItemAttribute.Sku, WebItemAttribute.Attibute) THEN BEGIN
                ItemAttribute.DELETE;
                //RM 17.08.2015 >>
                WebToolbox.UpdateIndex(WEBIndex, 1, '');   //*** May not be allowed check with Mark
                                                           //WebToolbox.UpdateIndex(WEBIndex,1,'');
                                                           //RM 17.08.2015 <<
            END;
            //RM 17.08.2015 >>
        END ELSE
            WebToolbox.UpdateIndex(WEBIndex, 2, 'Record not found to delete');
        //RM 17.08.2015 <<
    end;

    procedure HandleAttribute(var WEBIndex: Record "WEB Index")
    var
        WebItemAttribute: Record "WEB Item Attribute";
    begin
        WebItemAttribute.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WebItemAttribute.FINDFIRST THEN BEGIN
            CASE WebItemAttribute."LineType" OF
                WebItemAttribute."LineType"::Insert:
                    InsertAttribute(WEBIndex);
                WebItemAttribute."LineType"::Modify:
                    ModifyAttribute(WEBIndex);
                WebItemAttribute."LineType"::Delete:
                    DeleteAttribute(WEBIndex);
            END;
        END ELSE
            WebToolbox.UpdateIndex(WEBIndex, 2, 'Imported Record Not Found')
    end;

    procedure UpdateBaseUOM(ItemAttribute: Record "Item Attributes")
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        QtyPerUOM: Decimal;
    begin
        //R4522 >>
        IF UPPERCASE(ItemAttribute.Attribute) <> BoxQtyText THEN
            EXIT;

        //Only insert/change if there's not one present already - Matt
        IF NOT ItemUnitOfMeasure.GET(ItemAttribute."Item No.", BoxUOMText) THEN BEGIN
            ItemUnitOfMeasure.VALIDATE("Item No.", ItemAttribute."Item No.");
            ItemUnitOfMeasure.VALIDATE(Code, BoxUOMText);

            EVALUATE(QtyPerUOM, ItemAttribute."Attribute Value");
            ItemUnitOfMeasure.VALIDATE("Qty. per Unit of Measure", QtyPerUOM);

            ItemUnitOfMeasure.INSERT(TRUE);
        END;
        //R4522 <<
    end;
}

