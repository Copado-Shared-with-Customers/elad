*** Settings ***
Library                QForce
Resource               ../resources/custom_keywords.robot
Suite Setup            Setup Browser
Suite Teardown         End suite

*** Variables ***

*** Test Cases ***
Log in with MFA to a third-party site
    [Documentation]
    [Tags]
    GoTo               https://github.com/
    ClickText          Sign in

    TypeText           Username or email address                               ${github_username}
    TypeSecret         Password                    ${github_password}
    ClickText          Sign in

    ${2fa}             IsText                      Two-factor authentication

    IF                 ${2fa}
        ${mfa_code}=                               GetOTP                      ${github_username}                        ${github_secret}    ${github_password}
        TypeText       Enter the code              ${mfa_code}
    END