// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerinax/openai.chat;

final chat:Client chatClient = check new ({
    auth: {
        token: openAiApiKey
    }
});

# Constructs the prompt to be sent to OpenAI and invokes the completion API.
#
# + comment - Customer comment
# + return - The response string from OpenAI or an error
isolated function getChatCompletionResponse(string comment) returns string|error {

    chat:CreateChatCompletionRequest completionRequest = {
        model: OPEN_AI_MODEL_NAME,
        temperature: OPEN_AI_TEMPERATURE,
        max_tokens: OPEN_AI_MAX_TOKENS,
        messages: [
            {
                role: OPEN_AI_ROLE_NAME,
                content: prePrompt + comment + postPrompt
            }
        ]
    };

    chat:CreateChatCompletionResponse res = check chatClient->/chat/completions.post(completionRequest);
    string? content = res.choices[0]?.message?.content;
    return content ?: error("Contenet of the messange is null");
}
