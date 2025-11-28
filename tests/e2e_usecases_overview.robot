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

    TypeText           Username or email address           ${github_username}
    TypeSecret         Password                    ${github_password}
    ClickText          Sign in

    