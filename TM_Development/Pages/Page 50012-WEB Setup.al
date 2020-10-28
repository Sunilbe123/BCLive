page 50012 "WEB Setup"
{
    // version RM 05112015,R4424,R4561,R4622

    // RM - 05.11.2015
    // Added Credit Memo Discount Account and Returns Location
    // 
    // R4424 - RM - 13.01.2016
    // Added fields: -
    //   Error Start Date
    //   Show Inserts Only
    // 
    // R4561 - RM - 09.02.2016
    // Added Default Customer to General tab
    // 
    // R4622 - RM - 24.02.2016
    // Added "Alert Email From Address"

    PageType = Card;
    SourceTable = "WEB Setup";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("WEB Customer Template"; "WEB Customer Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("WB Guest Customer Nos"; "WB Guest Customer Nos")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("WEB Item Template"; "WEB Item Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Default Customer"; "Default Customer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Web Location"; "Web Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
            group(Banking)
            {
                field("Payment Journal Template"; "Payment Journal Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Payment Journal Batch"; "Payment Journal Batch")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
            group(Shipping)
            {
                field("Shipping and Handling Code"; "Shipping and Handling Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
            group(Stock)
            {
                field("Receive Stock on Cr. Memo"; "Receive Stock on Cr. Memo")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
            group(Orders)
            {
                field("Order Variance Tolerance"; "Order Variance Tolerance")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
            group("Credit Memos")
            {
                field("Credit Memo Discount Account"; "Credit Memo Discount Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Returns Location"; "Returns Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
            group("Error Reporting")
            {
                field("Error Start Date"; "Error Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Show Inserts only"; "Show Inserts only")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Alert Email From Address"; "Alert Email From Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
            group("Stock Write Off")
            {
                field("Stock Write Off Batch"; "Stock Write Off Batch")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Stock Write Reason Code"; "Stock Write Reason Code")
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
}

