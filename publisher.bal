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

function invokeGoogleChatNotification(string caseNumber, string caseId, string frustratedLevel)
returns GoogleChatResponse|http:ClientError {

    GoogleChatRequest googleChatRequest = {
        "cards":
            {
            "header": {
                "title": "Frustration Detected ⚠️"
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
                                "topLabel": "Frustration Level",
                                "content": frustratedLevel
                            }
                        }
                    ]
                }
            ]
        }
    };

    return googleChat->post(googleChatSpaceId, {...googleChatRequest}, mediaType = mime:APPLICATION_JSON);
}

function sendEmail(EscalationResponse escalationResponse) returns error? {

    string emailTemplateContent = generateEmailTemplateContent(escalationResponse);
    string? email = escalationResponse.assignedUserEmail;

    if email is string {
        email:Message emailSettingsForAssignedCasesResult =
        setEmailSettingsForAssignedCases(emailTemplateContent, smtpClient, escalationResponse, email);
        check smtpClient->sendMessage(emailSettingsForAssignedCasesResult);
        log:printDebug(emailSettingsForAssignedCasesResult.toString());
    } else {
        email:Message emailSettingsForOpenCasesResult =
        setEmailSettingsForOpenCases(emailTemplateContent, smtpClient, escalationResponse);
        check smtpClient->sendMessage(emailSettingsForOpenCasesResult);
        log:printDebug(emailSettingsForOpenCasesResult.toString());
    }

}

function createEmailList(EscalationResponse escalationResponse) returns string[] {

    string? email = escalationResponse.abtTeamEmail;
    if escalationResponse.assignedUserEmail == "" {
        string[] ccEmails = [];

        if (escalationResponse.productName == PRODUCT_IDENTITY_SERVER
        || escalationResponse.productName == PRODUCT_IDENTITY_SERVER_ANALYTICS) {
            ccEmails.push(iam_cs_email);
        } else if (email is string && email != "") {
            ccEmails.push(email);
        }
        return ccEmails;
    } else {
        string[] mailArr = [...emailGroup];
        if (escalationResponse.productName == PRODUCT_IDENTITY_SERVER
        || escalationResponse.productName == PRODUCT_IDENTITY_SERVER_ANALYTICS) {
            mailArr.push(iam_cs_email);
        } else if (email is string && escalationResponse.abtTeamEmail != "") {
            mailArr.push(email);
        }
        return mailArr;
    }
}

function setEmailSettingsForOpenCases(string emailBody, email:SmtpClient smtpClient, EscalationResponse finalFormattedResponse)
returns email:Message
    => {
    to: emailGroup,
    cc: createEmailList(finalFormattedResponse),
    'from: sourceEmail,
    subject: EMAIL_SUBJECT_COMMON + " " + finalFormattedResponse.caseNumber,
    contentType: mime:TEXT_HTML,
    htmlBody: emailBody
};

function setEmailSettingsForAssignedCases
(string emailBody, email:SmtpClient smtpClient, EscalationResponse finalFormattedResponse, string email)
returns email:Message
    => {
    to: [email],
    cc: createEmailList(finalFormattedResponse),
    'from: sourceEmail,
    subject: EMAIL_SUBJECT_COMMON + " " + finalFormattedResponse.caseNumber,
    contentType: mime:TEXT_HTML,
    htmlBody: emailBody
};

function generateEmailTemplateContent(EscalationResponse finalFormattedResponse) returns string {

    string? email = finalFormattedResponse.assignedUserEmail;
    string result = re `caseNumber`.replaceAll(template, finalFormattedResponse.caseNumber);
    result = re `caseId`.replaceAll(result, finalFormattedResponse.caseId);

    if (email is string) {
        result = re `assignedUserEmail`.replaceAll(result, email);
    } else {
        result = re `assignedUserEmail`.replaceAll(result, "No Assignee Yet");
    }

    result = re `frustratedLevel`.replaceAll(result, finalFormattedResponse.frustratedLevel.toString());
    result = re `commentPostedTimestampInSN`.replaceAll(result, finalFormattedResponse.commentPostedTimestampInSN);

    return result;
}
