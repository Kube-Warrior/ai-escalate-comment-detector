// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerina/http;
import ballerina/mime;

final http:Client googleChat = check new (GOOGLE_CHAT_API);

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
