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
    [Arguments]                 ${login_url}=${sf_login_url}    ${username}=${sf_username}    ${password}=${sf_password}
    GoTo                        ${login_url}
    TypeText                    Username                    ${username}
    TypeText                    Password                    ${password}
    ClickText                   Log In
    ${isMFA}=                   IsText                      Verify Your Identity        #Determines MFA is prompted
    Log To Console              ${isMFA}
    IF                          ${isMFA}                    #Conditional Statement for if MFA verification is required to proceed
        ${mfa_code}=            GetOTP                      ${username}                 ${MY_SECRET}                ${password}
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
    VerifyText    Home