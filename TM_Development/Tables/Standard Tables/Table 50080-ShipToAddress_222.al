tableextension 50080 ShipToAddressExt extends "Ship-to Address"
{
    // INS1.1
    // --Web Customer Shipping address can be created, and it will be synced with customer

    // R1671 - RM - 17.06.2014
    // Added fields-
    // 50000    Import Name         Text250
    // 50010    Import Address      Text250
    // 50020    Import Address 2    Text250
    // 50030    Import City         Text250
    // 50040    Import County       Text250
    // 50050    Import Post Code    Text250
    // 50060    Import Phone No.    Text250
    // 50070    Import Search Name  Text100
    // 50080    Import Email        Text100

    // Added function: - Unsync

    fields
    {
        // Add changes to table fields here
        field(50000; "Import Name"; text[100])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Name', ENG = 'Import Name';
        }
        field(50010; "Import Address"; text[150])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Address', ENG = 'Import Address';
        }
        field(50020; "Import Address 2"; text[150])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Address 2', ENG = 'Import Address 2';
        }
        field(50030; "Import City"; text[100])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import City', ENG = 'Import City';
        }
        field(50040; "Import County"; text[100])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import County', ENG = 'Import County';
        }
        field(50050; "Import Post Code"; text[100])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Post Code', ENG = 'Import Post Code';
        }
        field(50060; "Import Phone No."; text[100])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Phone No.', ENG = 'Import Phone No.';
        }
        field(50080; "Import Email"; text[100])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Email', ENG = 'Import Email';
        }
        field(50090; "Import Synched"; Boolean)
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Name', ENG = 'Import Name';
        }
        field(50100; "WebAddressID"; text[30])
        {
            Description = 'INS1.1';
            CaptionML = ENU = 'WebAddressID', ENG = 'WebAddressID';
        }
        field(50110; "WebIsDefault"; Boolean)
        {
            Description = 'INS1.1';
            CaptionML = ENU = 'WebIsDefault', ENG = 'WebIsDefault';
        }
    }

    var

}