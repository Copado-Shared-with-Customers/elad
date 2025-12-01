*** Settings ***
Library                         QForce
Library                         CopadoAI
Library                         String
Library                         DateTime


*** Variables ***
${browser}                      chrome


*** Keywords ***
Setup Browser
    [Arguments]                 ${url}=about:blank          ${browser}=chrome
    Set Library Search Order    QWeb                        QForce
    Open Browser                ${url}                      ${browser}
    SetConfig                   LineBreak                   ${EMPTY}                    #\ue000
    SetConfig                   DefaultTimeout              30s                         #sometimes salesforce is slow
    Evaluate                    random.seed()               random                      # initialize random generator
    SetConfig                   Delay                       0.3                         # adds a delay of 0.3 between keywords. This is helpful in cloud with limited resources.

End suite
    Close All Browsers

Login
    [Documentation]             Login to Salesforce instance
    [Arguments]                 ${login_url}=${sf_login_url}                            ${username}=${sf_username}                          ${password}=${sf_password}
    GoTo                        ${login_url}
    TypeText                    Username                    ${username}
    TypeText                    Password                    ${password}
    ClickText                   Log In
    ${isMFA}=                   IsText                      Verify Your Identity        #Determines MFA is prompted
    Log To Console              ${isMFA}
    IF                          ${isMFA}                    #Conditional Statement for if MFA verification is required to proceed
        ${mfa_code}=            GetOTP                      ${username}                 ${sf_secret}                ${password}
        TypeSecret              Code                        ${mfa_code}
        ClickText               Verify
    END

Global search and select type
    [Documentation]             searching and navigating to name with specific type
    [Arguments]                 ${name}                     ${type}
    ClickText                   Search...
    # ClickElement              //button[contains(@aria-label,'Search')]
    TypeText                    Search...                   ${name}
    Clickelement                //span[contains(@title,'${name}')]/ancestor::div[@class\='instant-results-list']//span[contains(text(),'${type}')]

Home
    [Documentation]
    [Arguments]
    Login
    VerifyText                  Home

    # pop-up Welcome to the Digital Experiences app!
    Close pop up                Welcome to the Digital Experiences app!                 Cancel and close

    Close pop up                Dismiss                     Dismiss

Close pop up
    [Documentation]             Conditionally closes a pop-up dialog if specific text is present on the screen.
    ...
    ...                         This keyword checks for the presence of text within a pop-up and clicks the close button if found.
    ...                         If the pop-up is not present, no action is taken (non-blocking behavior).
    ...
    ...                         *Arguments:*
    ...                         - ``text_in_pop_up``: Text to verify the pop-up is displayed (required)
    ...                         - ``close_option``: Text of the button/link to close the pop-up (optional, default: "Close")
    ...
    ...                         *Examples:*
    ...                         | Close pop up | Are you sure you want to proceed? |
    ...                         | Close pop up | Session expired | OK |
    ...                         | Close pop up | Changes saved successfully | Done |
    ...
    ...                         *Returns:* None
    [Arguments]                 ${text_in_pop_up}           ${close_option}=Close
    ${pop_up}                   IsText                      ${text_in_pop_up}

    IF                          ${pop_up}
        ClickText               ${close_option}s
    END

Format Phone Number
    [Arguments]                 ${raw}

    # Remove dots
    ${clean}=                   Replace String              ${raw}                      .                           ${EMPTY}

    # Initialize variables
    ${number}=                  Set Variable                ${EMPTY}
    ${ext}=                     Set Variable                ${EMPTY}

    # Split into phone and extension if 'x' exists
    ${has_ext}=                 Run Keyword And Return Status                           Should Contain              ${clean}                x
    Run Keyword If              ${has_ext}                  ${parts}=                   Split String                ${clean}                x
    Run Keyword If              ${has_ext}                  ${number}=                  Set Variable                ${parts}[0]
    Run Keyword If              ${has_ext}                  ${ext}=                     Set Variable                ${parts}[1]

    # If no extension, entire string is number
    Run Keyword If              not ${has_ext}              ${number}=                  Set Variable                ${clean}

    # Format the number (assumes 10 digits)
    ${area}=                    Set Variable                ${number[0:3]}
    ${pre}=                     Set Variable                ${number[3:6]}
    ${line}=                    Set Variable                ${number[6:10]}

    # Build final string
    ${formatted}=               Set Variable                (${area}) ${pre}-${line}
    Run Keyword If              '${ext}' != ''              ${formatted}=               Set Variable                ${formatted} x${ext}

    RETURN                      ${formatted}
