// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

public configurable string env = "Development";
public configurable string openAiApiKey = "sk-svcacct-JNfABSHpGEH-lalfNa3egZbQt3mDFXZvkGzwIMA_bKXs8BqtubPQnszV7eqdgMv7orQCRL9rlGc9UwT3BlbkFJN8YYyBBOdH_jTV8ceNdft3yAicXvBicoav743LPBTM80YgCicN6Z5PqyE9VXWoEswvSsKgk-PShC8A";
public configurable float frustrationThreshhold = 0.5;
public configurable string googleChatSpaceId = "/AAAAPgPwmf4/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=pDTlyj4YBEe_V9mJTUM_kae0d67RPGl9Buc8AXi5exE%3D";
public configurable string prePrompt = "Act as a sentimental analyzer kept in order to review customer feedback and respond back if the given comments given by customer is a frustrated comment or not. Statements like Case moved to Waiting on WSO2 should not concider as a frustrated comment. Consider the given comment is ";
public configurable string postPrompt = ". Based on these comments provide the probability value for isFrustrated by checking whether the comment is frustrated or not per each comment. Provide a  JSON output only by containing the above response. JSON output should be included comment, isFrustrated and frustrataedLevel as JSON object’s keys and respective values should be set by analyzing the comment. Comment should include the provided comment input, IsFrustrated should be a boolean. (either true or false) and frustratedLevl denotes a probability value as float variable to 03 decimal points which indicates the level of frustration. Don't use frustrationLevel key workd instead use frustratedLevel. of frustrationLevel. You must use frustratedLevel key word instead of frustrationLevel key word to denote the probability";
