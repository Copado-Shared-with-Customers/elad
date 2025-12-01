*** Settings ***
Library                     QForce
Library                     FakerLibrary
Resource                    ../resources/custom_keywords.robot
Test Setup                  Setup Browser
Test Teardown               End suite

*** Variables ***
${experience_cloud_site}    https://orgfarm-4cf24f140f-dev-ed.develop.my.site.com/PublicDataIntake/

*** Test Cases ***
Log in with MFA to a third-party site
    [Documentation]         Automates the GitHub login process with conditional Multi-Factor Authentication (MFA) handling.
    ...
    ...                     This test case navigates to GitHub, enters user credentials, and intelligently handles
    ...                     two-factor authentication if required. The test uses the GetOTP keyword to generate
    ...                     time-based one-time passwords (TOTP) when 2FA is detected.
    ...
    ...                     **Prerequisites:**
    ...                     - Variables must be defined: ${github_username}, ${github_password}, ${github_secret}
    ...                     - GitHub account must be accessible
    ...                     - If 2FA is enabled, ${github_secret} must contain the valid TOTP secret key
    ...
    ...                     **Test Flow:**
    ...                     1. Navigate to GitHub homepage
    ...                     2. Click Sign in button
    ...                     3. Enter username and password
    ...                     4. Submit login form
    ...                     5. Check if two-factor authentication is required
    ...                     6. If 2FA detected, generate and enter OTP code
    ...                     7. Verify successful login by confirming Dashboard appears
    ...
    ...                     **Expected Result:**
    ...                     User is successfully logged in and the Dashboard page is displayed.
    [Tags]                  MFA                         GitHub
    GoTo                    https://github.com/
    ClickText               Sign in

    TypeText                Username or email address                               ${github_username}
    TypeSecret              Password                    ${github_password}
    ClickText               Sign in

    ${2fa}                  IsText                      Two-factor authentication

    IF                      ${2fa}
        ${mfa_code}=        GetOTP                      ${github_username}          ${github_secret}    ${github_password}
        TypeText            Enter the code              ${mfa_code}
    END

    VerifyText              Dashboard

Submit Experience Cloud case form and verify record creation in Salesforce
    [Documentation]         End-to-end test that submits a case via Experience Cloud public form and verifies creation in Salesforce.
    ...
    ...                     Test Flow: Navigate to public site → Fill form with random data → Submit →
    ...                     Verify confirmation → Switch to Salesforce → Verify case in "All Open Cases" list view
    ...
    ...                     Prerequisites: ${experience_cloud_site} variable defined, Salesforce access to Cases
    ...
    ...                     Expected: Case appears in Salesforce with unique timestamp-based subject
    [Tags]                  E2E                         ExperienceCloud             CaseManagement      Salesforce            Integration
    # ... rest of test case
    GoTo                    ${experience_cloud_site}

    # Using FakerLib for generating a contact name and phone number
    ${first_name}           FakerLibrary.First Name
    ${last_name}            FakerLibrary.Last Name
    ${phone_number}         FakerLibrary.Phone Number

    # filling the form with the created data
    TypeText                Contact Name                ${first_name} ${last_name}
    TypeText                Email                       ${first_name}.${last_name}@notexist.com
    TypeText                Phone                       ${phone_number}
    Log To Console          ${phone_number}

    # Create a unique subject with today's date and time
    ${TODAY}=               Get Current Date            result_format=%d-%m-%Y %H:%M
    TypeText                Subject                     Case ${TODAY}

    TypeText                Description                 Test for creating a case through the website!
    ClickText               Submit Case

    VerifyText              Thank you for submitting your case!

    OpenWindow
    SwitchWindow            NEW

    Home

    ClickText               Cases

    ClickText               Select a List View: Cases
    ClickText               All Open Cases

    ClickText               Case ${TODAY}

    VerifyField             Web Name                    ${first_name} ${last_name}
    VerifyField             Subject                     Case ${TODAY}
    VerifyField             Web Phone                   ${phone_number}
    VerifyField             Web Email                   ${first_name}.${last_name}@notexist.com