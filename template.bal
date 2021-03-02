import ballerina/config;
import ballerina/io;
import ballerinax/sfdc;
import ballerinax/googleapis_sheets as sheets4;

const string CREATED = "created";

sfdc:SalesforceConfiguration sfConfig = {
    baseUrl: config:getAsString("SF_EP_URL"),
    clientConfig: {
        accessToken: config:getAsString("SF_ACCESS_TOKEN"),
        refreshConfig: {
            clientId: config:getAsString("SF_CLIENT_ID"),
            clientSecret: config:getAsString("SF_CLIENT_SECRET"),
            refreshToken: config:getAsString("SF_REFRESH_TOKEN"),
            refreshUrl: config:getAsString("SF_REFRESH_URL")
        }
    }
};

sheets4:SpreadsheetConfiguration spreadsheetConfig = {
    oauth2Config: {
        accessToken: config:getAsString("GS_ACCESS_TOKEN"),
        refreshConfig: {
            clientId: config:getAsString("GS_CLIENT_ID"),
            clientSecret: config:getAsString("GS_CLIENT_SECRET"),
            refreshUrl: config:getAsString("GS_REFRESH_URL"),
            refreshToken: config:getAsString("GS_REFRESH_TOKEN")
        }
    }
};

sfdc:ListenerConfiguration listenerConfig = {
    username: config:getAsString("SF_USERNAME"),
    password: config:getAsString("SF_PASSWORD")
};

listener sfdc:Listener sfdcEventListener = new (listenerConfig);
sfdc:BaseClient sfdcClient = new (sfConfig);
sheets4:Client gSheetClient = new (spreadsheetConfig);

@sfdc:ServiceConfig {topic:config:getAsString("SF_LEAD_TOPIC")}
service on sfdcEventListener {
    remote function onEvent(json lead) {
        io:StringReader sr = new (lead.toJsonString());
        json|error leadInfo = sr.readJson();
        if (leadInfo is json) {
            io:println(leadInfo);
             if(CREATED.equalsIgnoreCaseAscii(leadInfo.event.'type.toString())){
                var leadId = leadInfo.sobject.Id;
                io:println(leadId);
                var leadRecord = sfdcClient->getLeadById(leadId.toString());
                if(leadRecord is json){
                    error? resp = createSheetWithNewLead(leadRecord);
                    if(resp is error){
                        io:println("Ret",resp);
                    }
                }
                else {
                    io:println(leadRecord);
                }
            }        
        }
        else
        {
            io:println(leadInfo);
        }
    }
}

function createSheetWithNewLead(json lead) returns @tainted error?{
    io:println("Start==========================",lead);
    io:println("=====================================================");
    sheets4:Spreadsheet spreadsheet = check gSheetClient->openSpreadsheetById(config:getAsString("GS_SPREADSHEET_ID"));
    io:println(spreadsheet.spreadsheetId);
    io:println("+++++++++++++++++++++++++=====Sheet Before=====+++++++++++++");
    sheets4:Sheet sheet = check spreadsheet.getSheetByName(config:getAsString("GS_SHEET_NAME"));
    io:println("+++++++++++++++++++++++++==========+++++++++++++");
    (int|string|float)[] rowDetails = [];
    map<json> leadMap = <map<json>> lead;
    io:println("Inner===================>>>>>>>>>>>>>>>><<<<<<<<<<",leadMap);
    io:println("=====================================================");
    foreach var [key, value] in leadMap.entries() {
        rowDetails.push(value.toString());
    }
    var response = sheet->appendRow(rowDetails);
    io:println(response);
}
