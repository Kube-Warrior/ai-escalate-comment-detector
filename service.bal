// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerina/http;
import ballerina/log;

@http:ServiceConfig {
    cors: {
        allowOrigins: [
            "https://wso2sndev.wso2.com",
            "https://support.wso2.com",
            "https://wso2sndev.service-now.com"
        ],
        allowCredentials: true,
        allowHeaders: ["accept", "Content-Type"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}

service / on new http:Listener(9090) {
    resource function post escalations(EscalationRequest escalationRequest)
    returns EscalationResponse|EscalationResponseError {

        do {
            string response = check getChatCompletionResponse(escalationRequest.comment);
            json aiformattedJSONResponse = check response.fromJsonString();
            OpenAIResponse openAIResponse = check aiformattedJSONResponse.cloneWithType();

            EscalationResponse escalationResponse = check generateEscalationResponse(escalationRequest, openAIResponse);

            if openAIResponse.frustratedLevel > frustrationThreshhold {
                log:printDebug("Possible escalation detected on " + escalationRequest.caseId + " at " + escalationRequest.commentPostedTimestampInSN);
                GoogleChatResponse sendChatAlertResult = check invokeGoogleChatNotification(
                        escalationRequest.caseId,
                        escalationRequest.caseNumber,
                        openAIResponse.frustratedLevel.toString()
                );
                log:printDebug("Alert published to " + sendChatAlertResult.name);

            }
            return escalationResponse;

        } on fail error err {
            log:printError(err.message(), stackTrace = err.stackTrace());
            EscalationResponseError internalError = {body: {message: err.message()}};
            return internalError;
        }
    }
}

function generateEscalationResponse(EscalationRequest escalationRequest, OpenAIResponse openAIResponse)
returns EscalationResponse|error
    => {
    caseId: escalationRequest.caseId,
    caseNumber: escalationRequest.caseNumber,
    asginee: escalationRequest.assignee,
    assignedUserEmail: escalationRequest.assignedUserEmail,
    isFrustrated: openAIResponse.isFrustrated,
    frustratedLevel: openAIResponse.frustratedLevel,
    commentPostedTimestampInSN: escalationRequest.commentPostedTimestampInSN,
    productName: escalationRequest.productName,
    abtTeamEmail: escalationRequest.abtTeamEmail
};
