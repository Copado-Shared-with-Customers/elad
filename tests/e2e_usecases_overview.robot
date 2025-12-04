*** Settings ***
Library                         QForce
Library                         FakerLibrary                locale=en_GB
Resource                        ../resources/custom_keywords.robot
Test Setup                      Setup Browser
Test Teardown                   End suite

*** Variables ***
${experience_cloud_site}        https://orgfarm-4cf24f140f-dev-ed.develop.my.site.com/PublicDataIntake/

*** Test Cases ***
GitHub Login Flow Including MFA Verification
    [Documentation]             Automates the GitHub login process with conditional Multi-Factor Authentication (MFA) handling.
    ...
    ...                         This test case navigates to GitHub, enters user credentials, and intelligently handles
    ...                         two-factor authentication if required. The test uses the GetOTP keyword to generate
    ...                         time-based one-time passwords (TOTP) when 2FA is detected.
    ...
    ...                         **Prerequisites:**
    ...                         - Variables must be defined: ${github_username}, ${github_password}, ${github_secret}
    ...                         - GitHub account must be accessible
    ...                         - If 2FA is enabled, ${github_secret} must contain the valid TOTP secret key
    ...
    ...                         **Test Flow:**
    ...                         1. Navigate to GitHub homepage
    ...                         2. Click Sign in button
    ...                         3. Enter username and password
    ...                         4. Submit login form
    ...                         5. Check if two-factor authentication is required
    ...                         6. If 2FA detected, generate and enter OTP code
    ...                         7. Verify successful login by confirming Dashboard appears
    ...
    ...                         **Expected Result:**
    ...                         User is successfully logged in and the Dashboard page is displayed.
    [Tags]                      MFA                         GitHub

    # Navigate to GitHub homepage to initiate login flow
    GoTo                        https://github.com/

    # Click the Sign in button to access the login form
    ClickText                   Sign in

    # Enter GitHub username or email address in the credentials form
    TypeText                    Username or email address                               ${github_username}

    # Securely enter password (masked input, not logged in execution logs)
    TypeSecret                  Password                    ${github_password}

    # Submit the login form to authenticate with GitHub
    ClickText                   Sign in

    # Check if GitHub requires two-factor authentication for this account
    # Returns True if "Two-factor authentication" text is present on the page
    ${2fa}                      IsText                      Two-factor authentication

    # Conditional MFA handling: only execute if 2FA challenge is detected
    IF                          ${2fa}
    # Generate time-based one-time password (TOTP) using the account's secret key
    # GetOTP uses the TOTP algorithm (RFC 6238) to create a 6-digit code valid for 30 seconds
        ${mfa_code}=            GetOTP                      ${github_username}          ${github_secret}      ${github_password}

        # Enter the generated MFA code into the two-factor authentication input field
        TypeText                Enter the code              ${mfa_code}
    END

    # Verify successful login by confirming the Dashboard page is displayed
    # This serves as the final assertion that authentication completed successfully
    VerifyText                  Dashboard


Verify Experience Cloud Case Submission With Multi-User Ownership Transfer
    [Documentation]             **Purpose:** Validates end-to-end case creation workflow from Experience Cloud public form submission
    ...                         through Salesforce verification and ownership reassignment.
    ...
    ...                         **Preconditions:**
    ...                         - Experience Cloud site must be accessible at ${experience_cloud_site}
    ...                         - User must have access to Salesforce Cases object
    ...                         - User must have permission to view "All Open Cases" list view
    ...                         - User "Marcel Assaraf" must exist in the system
    ...                         - User must have permission to change case ownership
    ...
    ...                         **Test Flow:**
    ...                         1. **Form Submission:** Navigate to Experience Cloud public site and submit case form with randomly generated contact data
    ...                         2. **Submission Verification:** Confirm successful submission via thank you message
    ...                         3. **Salesforce Verification:** Switch to Salesforce and verify case appears in "All Open Cases" list view
    ...                         4. **Data Validation:** Verify all submitted form fields match case record fields (Web Name, Subject, Web Phone, Web Email)
    ...                         5. **Ownership Transfer:** Login as Marcel Assaraf and reassign case ownership
    ...                         6. **Transfer Verification:** Confirm case owner updated to Marcel Assaraf
    ...
    ...                         **Expected Results:**
    ...                         - Experience Cloud form submits successfully with confirmation message
    ...                         - Case record created in Salesforce with unique timestamp-based subject
    ...                         - All form data accurately mapped to corresponding case fields
    ...                         - Case appears in "All Open Cases" list view
    ...                         - Case ownership successfully transferred to Marcel Assaraf
    ...                         - Case Owner field displays "Marcel Assaraf"
    ...
    ...                         **Test Data:**
    ...                         - Contact Name: Randomly generated via FakerLibrary (First Name + Last Name)
    ...                         - Email: {first_name}.{last_name}@notexist.com
    ...                         - Phone: Randomly generated via FakerLibrary
    ...                         - Subject: "Case {current_date_time}" (format: dd-mm-yyyy HH:MM)
    ...                         - Description: "Test for creating a case through the website!"
    ...                         - New Owner: Marcel Assaraf
    ...
    ...                         **Technical Notes:**
    ...                         - Uses FakerLibrary (locale=en_GB) for realistic test data generation
    ...                         - Implements multi-window handling for Experience Cloud and Salesforce contexts
    ...                         - Timestamp-based subject ensures unique case identification across test runs
    [Tags]                      E2E                         Experience Cloud            Case Management       Salesforce            Integration    Ownership Transfer    Public Form

    # Navigate to Experience Cloud public site and submit case form
    GoTo                        ${experience_cloud_site}

    # Generate random contact data using FakerLibrary
    ${first_name}               FakerLibrary.First Name
    ${last_name}                FakerLibrary.Last Name
    ${phone_number}             FakerLibrary.Phone Number

    # Fill form with generated data
    TypeText                    Contact Name                ${first_name} ${last_name}
    TypeText                    Email                       ${first_name}.${last_name}@notexist.com
    TypeText                    Phone                       ${phone_number}
    Log To Console              ${phone_number}

    # Create unique subject with timestamp for case identification
    ${TODAY}=                   Get Current Date            result_format=%d-%m-%Y %H:%M
    TypeText                    Subject                     Case ${TODAY}

    TypeText                    Description                 Test for creating a case through the website!
    ClickText                   Submit Case

    # Verify successful form submission
    VerifyText                  Thank you for submitting your case!

    # Switch to Salesforce to verify case creation
    OpenWindow
    SwitchWindow                NEW

    Home

    ClickText                   Cases

    ClickText                   Select a List View: Cases
    ClickText                   All Open Cases

    ClickText                   Case ${TODAY}

    # Verify all form data mapped correctly to case fields
    VerifyField                 Web Name                    ${first_name} ${last_name}
    VerifyField                 Subject                     Case ${TODAY}
    VerifyField                 Web Phone                   ${phone_number}
    VerifyField                 Web Email                   ${first_name}.${last_name}@notexist.com

    # Capture case number for ownership transfer
    ${CASE_NUMBER}              GetFieldValue               Case Number

    # Login as Marcel Assaraf to perform ownership transfer
    Login As                    Marcel Assaraf

    ClickText                   Cases

    ClickText                   Select a List View: Cases
    ClickText                   All Open Cases

    # Search for case by case number
    Global search and select type                           ${CASE_NUMBER}              Case

    # Change case ownership to Marcel Assaraf
    ClickText                   Change Owner                anchor=Delete
    UseModal                    On
    VerifyText                  Change Case Owner
    TypeText                    Select New Owner            Marcel\n
    ClickText                   Marcel Assaraf              tag=a
    ClickText                   Submit

    # Verify ownership transfer successful
    VerifyField                 Case Owner                  Marcel Assaraf              partial_match=True

Verify File Upload To Case Record Via Related Files
    [Documentation]             **Purpose:** Validates that users can successfully upload files to a Case record through the Related Files component.
    ...
    ...                         **Preconditions:**
    ...                         - User must be logged into Salesforce
    ...                         - User must have Create permission on Case object
    ...                         - User must have permission to upload files
    ...                         - Test file 'crt_overview.jpg' must exist in the files directory
    ...
    ...                         **Test Steps:**
    ...                         1. Navigate to Cases from Home
    ...                         2. Create a new Case with Email as the origin
    ...                         3. Navigate to Related tab
    ...                         4. Upload a test image file
    ...                         5. Verify successful upload confirmation
    ...
    ...                         **Expected Results:**
    ...                         - Case is created successfully
    ...                         - File uploads without errors
    ...                         - System displays "1 of 1 file uploaded" confirmation message
    ...
    ...                         **Test Data:**
    ...                         - Case Origin: Email
    ...                         - Upload File: crt_overview.jpg
    [Tags]                      Case Management             File Upload                 Smoke Test            Related Files

    # Navigate to Salesforce Home page to establish starting point
    Home

    # Click Home tab to ensure we're on the main navigation
    ClickText                   Home

    # Navigate to Cases object from the App Launcher or navigation menu
    ClickText                   Cases

    # Click New button to open the Case creation form
    ClickText                   New

    # Enable modal context to interact with the New Case dialog
    # This ensures subsequent actions target elements within the modal window
    UseModal                    On

    # Select "Email" from the Case Origin picklist (required field indicated by *)
    # This sets how the customer contacted support
    PickList                    *Case Origin                Email

    # Click Save button to create the Case record
    # partial_match=False ensures we click the exact "Save" button, not "Save & New"
    ClickText                   Save                        partial_match=False

    # Disable modal context after the dialog closes
    # Returns focus to the main page content
    UseModal                    Off

    # Verify Case was created successfully by checking for confirmation message
    # This assertion confirms the Case record exists before proceeding to file upload
    VerifyText                  Case created

    # Navigate to the Related tab to access the Files related list
    # This tab contains all related records including Files, Activities, etc.
    ClickText                   Related

    # Upload the test image file to the Case record
    # UploadFile locates the "Upload Files" button and attaches crt_overview.jpg
    # File must exist in the project's files directory or specified path
    UploadFile                  Upload Files                crt_overview.jpg

    # Verify the upload completed successfully by checking the confirmation message
    # "1 of 1 file uploaded" indicates all selected files were processed without errors
    VerifyText                  1 of 1 file uploaded

    # Close the file upload dialog by clicking Done
    # delay=5s allows time for the file to be fully processed and attached to the record
    # This prevents timing issues where the file might not be immediately visible
    ClickText                   Done                        delay=5s
