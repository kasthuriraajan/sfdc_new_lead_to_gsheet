// // Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
// //
// // WSO2 Inc. licenses this file to you under the Apache License,
// // Version 2.0 (the "License"); you may not use this file except
// // in compliance with the License.
// // You may obtain a copy of the License at
// //
// // http://www.apache.org/licenses/LICENSE-2.0
// //
// // Unless required by applicable law or agreed to in writing,
// // software distributed under the License is distributed on an
// // "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// // KIND, either express or implied.  See the License for the
// // specific language governing permissions and limitations
// // under the License.

import ballerina/log;
import ballerina/test;
import ballerina/runtime;
import ballerinax/sfdc;

json testLeadRecord = {
    
    LastName:"James",
    FirstName:"Tylor",
    Salutation:"Mr.",
    Title:"Manager",
    Company:"R&D Exports",
    Street:"Main Street",
    City:"Jaffna",
    Country:"SriLanka",
    Email:"james@example.com",
    Status:"Open - Not Contacted"
};
string testLeadId = "";

@test:Config {}
function testNewLeadRecord() {
    log:print("sfdcClient -> createLead()");
    string|sfdc:Error leadResponse = sfdcClient->createLead(testLeadRecord);
    if (leadResponse is string) {
        test:assertNotEquals(leadResponse, "", msg = "Found empty response!");
        testLeadId = <@untainted>leadResponse;
    } else {
       log:printError(leadResponse.toString());
    }
    runtime:sleep(120000);
}
