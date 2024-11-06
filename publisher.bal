// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerina/email;
import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/mime;

final email:SmtpClient smtpClient = check new (mailClient, username, app_password);
final http:Client googleChat = check new (GOOGLE_CHAT_API);
final string template = check io:fileReadString(EMAIL_TEMPLATE_PATH);

function invokeGoogleChatNotification(string caseNumber, string caseId, string frustratedLevel) returns GoogleChatResponse|error {

    json paylod = {
        "cards": [
            {
                "header": {
                    "title": "Frustraction Detected ⚠️"
                },
                "sections": [
                    {
                        "widgets": [
                            {
                                "keyValue": {
                                    "topLabel": "Case ID/Number",
                                    "content": caseId + "/" + caseNumber
                                }
                            },
                            {
                                "keyValue": {
                                    "topLabel": "Frustraction Level",
                                    "content": frustratedLevel
                                }
                            }
                        ]
                    }
                ]
            }
        ]
    };

    string response = check googleChat->post(googleChatSpaceId, paylod, mediaType = mime:APPLICATION_JSON);
    json jsonResponse = check response.fromJsonString();
    GoogleChatResponse googleChatResponse = check jsonResponse.cloneWithType();
    log:printDebug("Google Chat Response :  " + googleChatResponse.toString());
    return googleChatResponse;

}

function sendEmail(EscalationResponse escalationResponse) returns error? {

    string emailTemplateContent = check generateEmailTemplateContent(escalationResponse);

    if escalationResponse.assignedUserEmail == "" {
        email:Message emailSettingsForOpenCasesResult = check setEmailSettingsForOpenCases(emailTemplateContent, smtpClient, escalationResponse);
        check smtpClient->sendMessage(emailSettingsForOpenCasesResult);
        log:printDebug(emailSettingsForOpenCasesResult.toString());
    } else {
        email:Message emailSettingsForAssignedCasesResult = check setEmailSettingsForAssignedCases(emailTemplateContent, smtpClient, escalationResponse, escalationResponse.productName, escalationResponse.abtTeamEmail);
        check smtpClient->sendMessage(emailSettingsForAssignedCasesResult);
        log:printDebug(emailSettingsForAssignedCasesResult.toString());
    }
}

function createEmailList(EscalationResponse escalationResponse) returns string[]|error {

    if escalationResponse.assignedUserEmail == "" {
        string[] ccEmails = [];
        if (escalationResponse.productName == PRODUCT_IDENTITY_SERVER || escalationResponse.productName == PRODUCT_IDENTITY_SERVER_ANALYTICS) {
            ccEmails.push("");
        } else if (escalationResponse.abtTeamEmail != "") {
            ccEmails.push(escalationResponse.abtTeamEmail);
        }
        return ccEmails;
    } else {
        string[] mailArr = check emailGroup.cloneWithType();
        if (escalationResponse.productName == PRODUCT_IDENTITY_SERVER || escalationResponse.productName == PRODUCT_IDENTITY_SERVER_ANALYTICS) {
            mailArr.push(EMAIL_IAM_CS);
        } else if (escalationResponse.abtTeamEmail != "") {
            mailArr.push(escalationResponse.abtTeamEmail);
        }
        return mailArr;
    }
}

function setEmailSettingsForOpenCases(string emailBody, email:SmtpClient smtpClient, EscalationResponse finalFormattedResponse) returns email:Message|error
    => {
    to: emailGroup,
    cc: check createEmailList(finalFormattedResponse),
    'from: sourceEmail,
    subject: EMAIL_SUBJECT_COMMON + " " + finalFormattedResponse.caseNumber,
    contentType: mime:TEXT_HTML,
    htmlBody: emailBody
};

function setEmailSettingsForAssignedCases(string emailBody, email:SmtpClient smtpClient, EscalationResponse finalFormattedResponse, string productName, string abtTeamEmail) returns email:Message|error
    => {
    to: [finalFormattedResponse.assignedUserEmail],
    cc: check createEmailList(finalFormattedResponse),
    'from: sourceEmail,
    subject: EMAIL_SUBJECT_COMMON + " " + finalFormattedResponse.caseNumber,
    contentType: mime:TEXT_HTML,
    htmlBody: emailBody
};

function generateEmailTemplateContent(EscalationResponse finalFormattedResponse) returns string|error {

    string result = re `caseNumber`.replaceAll(template, finalFormattedResponse.caseNumber);
    result = re `caseId`.replaceAll(result, finalFormattedResponse.caseId);
    result = re `assignedUserEmail`.replaceAll(result, finalFormattedResponse.assignedUserEmail);
    result = re `frustratedLevel`.replaceAll(result, finalFormattedResponse.frustratedLevel.toString());
    result = re `commentPostedTimestampInSN`.replaceAll(result, finalFormattedResponse.commentPostedTimestampInSN);

    return result;
}
