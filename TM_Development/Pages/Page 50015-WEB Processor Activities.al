page 50015 "WEB Processor Activities"
{
    // version NAVW17.10,R4311

    // R4311 - RM - 09.12.2015
    // Added WEB Daily Reconciliation cue group

    Caption = 'Activities';
    PageType = CardPart;
    SourceTable = "WEB Cue";


    layout
    {
        area(content)
        {
            cuegroup("WEB Static Data")
            {
                Caption = 'WEB Static Data';
                field("No. Of Item Today"; "No. Of Item Today")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Caption = 'No. Of Item Today';
                    Image = Document;
                }
                field("No. Of Customers Today"; "No. Of Customers Today")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Caption = 'No. Of Customers Today';
                    Image = Document;
                }
            }
            cuegroup("WEB Transactions")
            {
                Caption = 'WEB Transactions';
                field("No. Of Orders Today"; "No. Of Orders Today")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    ShowMandatory = true;
                }
                field("No. of Shipments Today"; "No. of Shipments Today")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("No. Of Credits Today"; "No. Of Credits Today")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
            cuegroup("WEB Errors Today")
            {
                Caption = 'WEB Errors Today';
                field("No. Of Errors Today"; "No. Of Errors Today")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("No. Of Errors Today - Customer"; "No. Of Errors Today - Customer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("No. Of Errors Today - Order"; "No. Of Errors Today - Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("No. Of Errors Today - Item"; "No. Of Errors Today - Item")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("No. Of Errors Today - Shipment"; "No. Of Errors Today - Shipment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("No. Of Errors Today - Credit"; "No. Of Errors Today - Credit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("WEB Requests Outstanding"; "WEB Requests Outstanding")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
            cuegroup("WEB Errors")
            {
                Caption = 'WEB Errors';
                field("No. Of Errors"; "No. Of Errors")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Style = Unfavorable;
                    StyleExpr = TRUE;
                }
                field("No. Of Errors - Customer"; "No. Of Errors - Customer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("No. Of Errors - Order"; "No. Of Errors - Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("No. Of Errors - Item"; "No. Of Errors - Item")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("No. Of Errors - Shipment"; "No. Of Errors - Shipment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("No. Of Errors - Credit"; "No. Of Errors - Credit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
            cuegroup("WEB Daily Reconciliation")
            {
                Caption = 'WEB Daily Reconciliation';
                field("No. Of Unreconciled Records"; "No. Of Unreconciled Records")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
            repeater("WEB Records")
            {
                Caption = 'WEB Records';
                field("Last Orders"; "Last Orders")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    StyleExpr = TRUE;
                }
                field("Last Item"; "Last Item")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Last Shipments"; "Last Shipments")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Last Credits"; "Last Credits")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Last Customers"; "Last Customers")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        RESET;

        IF NOT GET THEN BEGIN

            INIT;

            INSERT;

        END;
        SETFILTER("Date Filter", '%1', TODAY);
        SETRANGE("DateTime Filter", CREATEDATETIME(TODAY, 000001T), CREATEDATETIME(TODAY, 235959T));
    end;
}

