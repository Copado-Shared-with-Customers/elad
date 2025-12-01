*** Settings ***
Library                QForce
Resource               ../resources/custom_keywords.robot
Suite Setup            Setup Browser
Suite Teardown         End suite

*** Variables ***

*** Test Cases ***
Log in with MFA to a third-party site
    [Documentation]    Automates the GitHub login process with conditional Multi-Factor Authentication (MFA) handling.
    ...
    ...                This test case navigates to GitHub, enters user credentials, and intelligently handles
    ...                two-factor authentication if required. The test uses the GetOTP keyword to generate
    ...                time-based one-time passwords (TOTP) when 2FA is detected.
    ...
    ...                **Prerequisites:**
    ...                - Variables must be defined: ${github_username}, ${github_password}, ${github_secret}
    ...                - GitHub account must be accessible
    ...                - If 2FA is enabled, ${github_secret} must contain the valid TOTP secret key
    ...
    ...                **Test Flow:**
    ...                1. Navigate to GitHub homepage
    ...                2. Click Sign in button
    ...                3. Enter username and password
    ...                4. Submit login form
    ...                5. Check if two-factor authentication is required
    ...                6. If 2FA detected, generate and enter OTP code
    ...                7. Verify successful login by confirming Dashboard appears
    ...
    ...                **Expected Result:**
    ...                User is successfully logged in and the Dashboard page is displayed.
    [Tags]             MFA                         GitHub
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

    VerifyText         Dashboard

Filling and submitting a third-party form that triggers record creation in Salesforce
    [Documentation]
    [Tags]
    GoTo               https://orgfarm-4cf24f140f-dev-ed.develop.my.site.com/PublicDataIntake/
    
    ${TODAY}=          Get Current Date            result_format=%d-%m-%Y %H:%M
    TypeText           Contact Name                Hidde Visser
    TypeText           Email                       test@test.com
    TypeText           Phone                       0123456789
    TypeText           Subject                     Case ${TODAY}
    TypeText           Description                 Test for creating a case through the website!
    ClickText          Submit Case

    VerifyText         Thank you for submitting your case!

    OpenWindow
    SwitchWindow       NEW

    Home

    SXHPTABHEY4UBVOBH6AEXBC4B6CDFWVW