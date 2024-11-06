// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerina/http;

type EscalationRequest record {|
    string caseId;
    string caseNumber;
    string comment;
    string assignee;
    string assignedUserEmail;
    string commentPostedTimestampInSN;
    string productName;
    string abtTeamEmail;
|};

type OpenAIResponse record {|
    string comment;
    boolean isFrustrated;
    float frustratedLevel;
|};

type GoogleChatResponse record {|
    string name;
    Card[] cards;
    ChatThread thread;
    Space space;
|};

type ChatThread record {
    string name;
};

type Space record {
    string name;
};

type EscalationResponse record {|
    string caseId;
    string caseNumber;
    string asginee;
    string assignedUserEmail;
    boolean isFrustrated;
    float frustratedLevel;
    string commentPostedTimestampInSN;
    string productName;
    string abtTeamEmail;
|};

type Card record {|
    Header header;
    Section[] sections;
|};

type Header record {|
    string title;
|};

type Section record {|
    Widget[] widgets;
|};

type Widget record {|
    KeyValue keyValue;
|};

type KeyValue record {|
    string topLabel;
    string content;
|};

# Custom error type.
#
# + body - Error message record
public type EscalationResponseError record {|
    *http:InternalServerError;
    ErrorMsg body;
|};

# Error message record.
#
# + message - Error message
public type ErrorMsg record {|
    string message;
|};
