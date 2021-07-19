*** Settings ***
Documentation       Resource containing generic keywords to handle git hub web page.

Library     SeleniumLibrary
Library     DateTime

# Importing common configuration variables (ex. app url, browser default, delays, etc)
Resource    ../Configs/GitHub_config.robot

*** Keywords ***
Take App Evidence
    [Documentation]     Wrapper keyword to take evidences in a easier way (ex. without file extension) and with timestamp for have the evidences correctly in a correct order (not alphabetically).
    [Arguments]     ${evidence_name}

    ## timestamp for evidence screenshots be organized by time and not by name
    ${timestamp}=   Get Current Date    result_format=%Y%m%d%H%M%S

    Capture Page Screenshot     ${timestamp}_${evidence_name}.png

Open GitHub Website
    [Documentation]     Open GitHub URL in browser and maximize it.

    Log To Console  ${\n}Open and Maximizing Browser Window.

    Open Browser    ${GITHUB_URL}      ${GITHUB_BROWSER}

    Maximize Browser Window

    #to have time to follow the execution - can be decreased
    Set Selenium Speed  0.2

    Wait Until Page Contains Element    //a[text()[contains(.,'Sign up')]]

    Log To Console      GitHub Website open.

Close GitHub Website
    [Documentation]     Close all open browsers.

    Close All Browsers

    Log To Console      All Browsers closed.

Go to GitHub Sign In Page
    [Documentation]     Go to Sign In in the GitHub Page.

    Click Element      //a[text()[contains(.,'Sign in')]]

    Wait Until Page Contains    Sign in to GitHub

    Log To Console      GitHub Sign In page.

Login in GitHub Website
    [Documentation]     In the Sign In Page, insert credentials and validate that user is logged in.

    Input Text      name=login      ${GITHUB_LOGIN}

    Input Password  name=password   ${GITHUB_PASSWORD}

    Click Element   //input[@value='Sign in']

    Wait Until Page Contains Element    //summary[@aria-label='View profile and more']

    Log To Console      Log in in GitHub with success.

Go to Registration Page and Wait for Form
    [Documentation]     Go to registration page by clicking 'Sign Up' button.

    Click Element      //a[text()[contains(.,'Sign up')]]

    Wait Until Element Is Visible    id=email

    Log To Console      I am in Registration Page.

Insert and Validate if Password is Good
    [Documentation]     Insert email and password and check that message returned in UI is equals passed in keyword argument.
    [Arguments]     ${email}    ${password}     ${message_to_validate}

    Log To Console      Insert the Email and continue.

    # Insert Email
    Input Text      id=email    ${email}

    Wait Until Element Is Enabled   //div[@id='email-container']//button[text()[contains(.,'Continue')]]

    Click Element   //div[@id='email-container']//button[text()[contains(.,'Continue')]]

    Log To Console      Insert the Password and continue.

    # Insert Password
    Wait Until Element Is Visible   id=password

    Input Password      id=password    ${password}

    Wait Until Element Is Visible   //p[@id= 'password-err']/p[contains(@class, 'password-validity-summary')]

    Log To Console      Get the password validation message and validate.

    ${message_ui}=  Get Text    //p[@id= 'password-err']/p[contains(@class, 'password-validity-summary')]
    Log To Console  Message UI: ${message_ui}

    Take App Evidence     PasswordMessage

    Should Be Equal As Strings  ${message_to_validate}  ${message_ui}

Insert Sign Up Credentials
    [Documentation]     Insert Sign Up Credentials (email, password and username). Product updates default is 'n' when not passed.
    [Arguments]     ${email}    ${password}     ${username}     ${opt_in}=n

    Log To Console      Insert the Email and continue.

    # Insert Email
    Input Text      id=email    ${email}

    Wait Until Element Is Enabled   //div[@id='email-container']//button[text()[contains(.,'Continue')]]

    Click Element   //div[@id='email-container']//button[text()[contains(.,'Continue')]]

    Log To Console      Insert the Password and continue.

    # Insert Password
    Wait Until Element Is Visible   id=password

    Input Password      id=password    ${password}

    Wait Until Element Is Enabled   //div[@id='password-container']//button[text()[contains(.,'Continue')]]

    Click Element   //div[@id='password-container']//button[text()[contains(.,'Continue')]]

    Log To Console      Insert the Username and continue.

    # Insert Username
    Wait Until Element Is Visible   id=login

    Input Text      id=login    ${username}

    Wait Until Element Is Enabled   //div[@id='username-container']//button[text()[contains(.,'Continue')]]

    Click Element   //div[@id='username-container']//button[text()[contains(.,'Continue')]]

    Log To Console      Insert the Opt In and continue.

    # Insert Opt In Value (would you like to receive product updates and announcements via email?) - default will be 'n'
    Wait Until Element Is Visible   id=opt_in
#    Scroll Element Into View    id=opt_in      #if problem with small screens occurs scroll should fix it
    Input Text      id=opt_in    ${opt_in}

    Wait Until Element Is Enabled   //div[@id='opt-in-container']//button[text()[contains(.,'Continue')]]

    Click Element   //div[@id='opt-in-container']//button[text()[contains(.,'Continue')]]

Go to iFrame and Check that Puzzle is Working
    [Documentation]     Enter in the page iFrames to find the Puzzle and start it.


    # Wait and select Frames to find elements inside them
    Wait Until Element Is Visible   id=captcha-and-submit-container

    Log To Console      Trying to find and start the puzzle with retries.
    # Try a few times because this is tricky - when puzzle takes to long, it only fails when trying to click in puzzle, because iFrames are (aparently) already visible
    Wait Until Keyword Succeeds    3 times    5 sec   Open and Click The Puzzle

    Take App Evidence     PuzzleActive

    Pass Execution  Puzzle is active and Responding

Open and Click the Puzzle
    [Documentation]     Go to each iFrame (select) and Start the Puzzle.

    Log to Console  Trying to open the Puzzle.
    # Identified problems with page when inputs inserted to fast (ex. sometimes inputs or puzzle not shown)
    Set Selenium Speed  0.3

    Wait Until Element Is Visible    //iframe[@title[contains(.,'Please verify by completing this captcha.')]]
    Select Frame    //iframe[@title[contains(.,'Please verify by completing this captcha.')]]

    Wait Until Element Is Visible    //iframe[@title[contains(.,'Please solve this puzzle so we know you are a real person')]]
    Select Frame    //iframe[@title[contains(.,'Please solve this puzzle so we know you are a real person')]]

    Wait Until Element Is Visible    id=CaptchaFrame
    Select Frame    CaptchaFrame

    # Click Start Puzzle
    Wait Until Element Is Visible   //a[text()[contains(.,'Start puzzle')]]
    Click Element   //a[text()[contains(.,'Start puzzle')]]

    Log To Console      Click Puzzle Started.

    # Select Challenge Elements
    Wait Until Element Is Visible   (//div[@id='game_children_challenge']//a)[1]
    Click Element   (//div[@id='game_children_challenge']//a)[1]

    Log To Console      Challenge clicked.

    ## Selenium speed reverted
    Set Selenium Speed  0.1

Create New Repository and Fill Information
    [Documentation]     Create new empty repository, fill the required information and validate its succesfull creation.
    [Arguments]     ${name}     ${description}      ${visibility}=private

    Log To Console      Click New Repository.

    ## check if first time, first repo
    ${first_repo}=      run keyword and return status     element should be visible     //a[text()[contains(.,'Create repository')]]

    ## there are more elements in the page equals to '//a[text()[contains(.,'New')]]' but are hidden (responsive) so for that reason we use //aside element (side bar)
    ## when there are repos already, there is another different button
    Run Keyword If  ${first_repo}==${True}    Click Link   //a[text()[contains(.,'Create repository')]]
    ...     ELSE                        Click Link  //aside//a[text()[contains(.,'New')]]

    Wait Until Element Is Visible   //h1[text()[contains(.,'Create a new repository')]]

    Log To Console      Insert the name, description and visibility.

    Input Text  id=repository_name      ${name}

    Input Text  id=repository_description      ${description}

    # Set visibility to public or private (default: private)
    Click Element   id=repository_visibility_${visibility}

    Take App Evidence     RepoInfoFilled

    Log To Console      Click to create and confirm.

    Click Button    //button[text()[contains(.,'Create repository')]]

    Wait Until Page Contains    Quick setup — if you’ve done this kind of thing before

    Take App Evidence     RepoCreated

Create new File
    [Documentation]     Create new file in a repository with some content.
    [Arguments]     ${filename}    ${filecontent}

    Log To Console  Creating New File: ${filename}.

    # if already exists created files, there isnt the option Creating New File directly
    # we need to click in Go to File > Create New File (xpaths are different)
    ${count}=   Get Element Count   //a[text()='creating a new file']

    # there are created files already
    Run Keyword If  '${count}' == '0'   Run Keywords
    ...                                     Click Element   //span[text()[contains(.,'Add file')]]/..
    ...                             AND     Click Element   //button[text()[contains(.,'Create new file')]]/..
    # there is not created files yet
    ...         ELSE                    Click Element  //a[text()='creating a new file']

    Log To Console  Fill the file information (name and content).

    Input Text  //input[@aria-label='Name your file…']      ${filename}

    # Insert First line content
    Input Text  //div[@class='CodeMirror-code']//pre    ${filecontent}

    Log To Console  Commit new File.
    Click Element  //button[text()[contains(.,'Commit new file')]]

    Wait Until Page Contains  Create
    Page Should Contain     ${filename}
    Take App Evidence     NewFileCreated

Validate new Created File
    [Documentation]     Checks that the created file was actually created and its content its OK.
    [Arguments]     ${filename}    ${filecontent}

    Log To Console  Go to File: ${filename}.

    Click Element   //a[text()[contains(.,'Go to file')]]

    Wait Until Page Contains Element  //span[text()[contains(.,'${filename}')]]

    Click Element   //span[text()[contains(.,'${filename}')]]

    Wait Until Page Contains    History

    Log To Console  Get the file content.
    ## Get first line content
    ${file_content_ui}=     Get Text    //table//td[contains(@class, 'js-file-line')]

    Log To Console  File Content UI: ${file_content_ui}

    Take App Evidence     FileContent

    # Compare
    Should Be Equal As Strings  ${file_content_ui}  ${filecontent}

Search for a Repository and Enter it
    [Documentation]    Search for the Repository substring and choose the first obtained and return it.
    [Arguments]     ${repo_name}

    Log To Console  Searching Repo: ${repo_name}

    # Search because when too many repos, this repo can be hidden
    Input Text  //aside//input[@aria-label='Find a repository…']    ${repo_name}

    log to console  Select the first repo to delete.

    ${repo_name_deleted}=       Get text   (//aside//span[text()[contains(.,'${repo_name}')]])[1]

    log to console      Deleting the repository: ${repo_name_deleted}

    Click Element   (//aside//span[text()[contains(.,'${repo_name}')]])[1]

    Wait Until Page Contains    Code

    [Return]    ${repo_name_deleted}

Go to Repository Settings
    [Documentation]     Go to Repository settings option.

    Log To Console  Go to Repository Settings.

    Click Element   //span[text()='Settings']

    Wait Until Element Is Visible   //h2[text()='Settings']

Remove This Repository
    [Documentation]     Click to remove the repository, confirm it and validates that was succesfully removed.
    [Arguments]  ${repo_name}

    Log To Console  Click to remove repo: ${repo_name}.

    Click Element   //summary[text()[contains(.,'Delete this repository')]]

    Log To Console  Wait for confirmation dialog and confirm the deletion.
    Wait Until Element Is Visible   //div[text()[contains(.,'Are you absolutely sure?')]]

    ## Insert the repo name for confirmation - only input in the confirmation Dialog
    Input Text  //input[@aria-label='Type in the name of the repository to confirm that you want to delete this repository.']  ${GITHUB_USERNAME}/${repo_name}

    Click Element   //span[text()='I understand the consequences, delete this repository']/..

    Wait Until Page Contains    was successfully deleted
    Take App Evidence     ProjectRemoved

Change Repository Visibility
    [Documentation]     Change the visibility of a repo.
    [Arguments]     ${repo_name}    ${repo_visibility}

    log to console  Click to change visibility.
    Click Element   //summary[text()[contains(.,'Change visibility')]]

    Wait Until Element Is Visible   //h1[text()[contains(.,'Change repository visibility')]]

    log to console  Set visibility to: ${repo_visibility}.
    # Set visibility to public or private regardless the current visibility
    Click Element   //input[@value='${repo_visibility}']

    Log to Console  Type to confirm repository visibility changing.
    Input Text  //input[@aria-label='Type in the name of the repository to confirm that you want to change the visibility of this repository.']  ${GITHUB_USERNAME}/${repo_name}

    Take App Evidence     ChangeRepositoryVisibility

    Click Element   //button[text()[contains(.,'I understand, change repository visibility.')]]

Confirm Visibily Changes with Anonymous User
    [Documentation]     Open a new browser with anonymous user and validate that visibility is taking effect.
    [Arguments]     ${repo_name}    ${repo_visibility}

    Log To Console  Go to Repo URL (anonymous user in another browser): ${GITHUB_URL}/${GITHUB_USERNAME}/${repo_name}

    # Open second brower (anonymous user)
    Open Browser    ${GITHUB_URL}/${GITHUB_USERNAME}/${repo_name}   ${GITHUB_BROWSER}

    # Switch to that browser
    Switch Browser  2

    Take App Evidence     VisibilityEvidence

    Run Keyword If  '${repo_visibility}' == 'public'    Page Should Contain     ${repo_name}
    Run Keyword If  '${repo_visibility}' == 'private'   Page Should Contain Element     //img[@alt='404 “This is not the web page you are looking for”']

    Log To Console  Validation OK. Repository is '${repo_visibility}'.

    # Close second brower (anonymous user)
    Close Browser

Click in Sub Menu Option
    [Arguments]     ${option}
    [Documentation]     Select subsection inside User "Profile Pic". Options can be any from list: Your profile, Your repositories, Your codespaces, Upgrade, Feature Preview, Help or Settings
    ...                 Only 'Sign out' is a button instead of 'a' but this kw is prepared for that.

    Log To Console  Go to sub menu option '${option}'.

    Click Element   //summary[@aria-label='View profile and more']

    Wait Until Element Is Visible   //details-menu/a[text()='Your projects']

    # if Sign out > click in button
    Run Keyword If  '${option}' == 'Sign Out'   Click Element   //details-menu//button[text()[contains(.,'Sign out')]]
    ...     ELSE    Click Element   //details-menu/a[text()='${option}']

Create New Project and Fill Information
    [Documentation]     Create new empty Project, fill the required information and validate its succesfull creation.
    [Arguments]      ${project_name}    ${project_description}      ${project_template}=None     ${project_visibility}=Private

    Log To Console  Click New Project for creating project: ${project_name}.

    Click Element   (//div[contains(@class, 'container-lg')]//a[text()[contains(.,'New project')]])[1]

    Wait Until Element Is Visible   //div[text()[contains(.,'Create a new project')]]

    Log To Console  Fill project information (name and description).
    Log To Console  Name: ${project_name}
    Log To Console  Description: ${project_description}
    # Name
    Input Text  id=project_name      ${project_name}

    # Description
    Input Text  id=project_body      ${project_description}


    Log To Console  Fill template: ${project_template}

    # Template
    Click Element   //i[text()[contains(.,'Template')]]/..
    Wait Until Element Is Visible  //span[text()='${project_template}']/../..
    Click Element   //span[text()='${project_template}']/../..

    Log To Console  Set visibility to: ${project_visibility}.
    # Visibility
    Click Element   //label[text()[contains(.,'${project_visibility}')]]/..//input

    Take App Evidence     ProjectInfoFilled

    Log To Console  Click created and validate creation.

    Click Button    //button[text()[contains(.,'Create project')]]

    Take App Evidence     ProjectCreated

    Page Should Contain     Projects

Search for a Project
    [Documentation]     Search for an existing project to handle in another keywords.
    [Arguments]     ${project_name}

    log to console  Search for a Project: ${project_name}.

    Wait Until Element Is Visible   //div[@id='user-projects-list']//input

    Input Text  //div[@id='user-projects-list']//input      ${project_name}${\n}

#    Wait Until Element Is Visible   //a[text()='${project_name}']
    Wait Until Element Is Visible   //a[text()[contains(.,'${project_name}')]]

Open Project Menu Options and Select Sub Option
    [Documentation]     Options can be Edit or Settings. Close is an 'a' not a 'button'
    [Arguments]     ${project_name}     ${sub_option}

    Wait Until Element Is Enabled   (//a[text()[contains(.,'${project_name}')]])[1]

    # click 3 dots icon
    ${project_name_select}=       Get Text        (//a[text()[contains(.,'${project_name}')]])[1]
    log to console      Project Name: ${project_name_select}
    Click Element  //a[text()[contains(.,'${project_name_select}')]]/../../..//summary

    Log To Console  Select a project: ${project_name_select}.

    ## only to see if already open before click
    Wait Until Element Is Visible   //details-menu//a[text()[contains(.,'Edit')]]

    Log To Console  Select the sub option: ${sub_option}.

    # Settings is a button. The rest are 'a'
    Run Keyword If  '${sub_option}' == 'Close'   Click Element   //details-menu//button[text()[contains(.,'Close')]]
    ...         ELSE                             Click Element   //details-menu//a[text()[contains(.,'${sub_option}')]]

Edit Project Information
    [Documentation]     Fill new project information for the project found.
    [Arguments]     ${project_name}     ${new_project_name}     ${new_project_description}

    Wait Until Element Is Visible   //div[text()[contains(.,'Edit')]]/span[text()[contains(.,'${project_name}')]]

    Log To Console  Fill the project new information:
    Log To Console  Current Name: ${project_name}
    Log To Console  New Name: ${new_project_name}
    Log To Console  New Description: ${new_project_description}

    # Name
    Input Text  id=project_name      ${new_project_name}

    # Description
    Input Text  id=project_body      ${new_project_description}

    Log To Console  Click to Save Project and wait info to be updated.

    Click Element   //button[text()='Save project']

    Wait Until Page Contains    Project updated

    Take App Evidence     ProjectEditedEvidence

    Page Should Contain     ${new_project_name}

Delete this Project
    [Documentation]     Click to delete the project found and confirm the alert.

    Log To Console  Click to delete this project.
    Wait Until Element Is Visible   //button[text()='Delete project']

    Click Element   //button[text()='Delete project']

    Log To Console  Confirm the alert (OK).

    # Confirm alert OK
    Handle Alert

    Wait Until Page Contains Element        (//div[contains(@class, 'container-lg')]//a[text()[contains(.,'New project')]])[1]

    Take App Evidence     ProjectDeleted

Edit User Profile Information
    [Documentation]     Fill new User Profile information and validates that was succesfully changed.
    [Arguments]   ${user_bio}   ${user_company}     ${user_location}     ${user_website}    ${user_twitter}

    Log To Console  Click to Edit User Profile.

    Wait until element is visible  //button[text()='Edit profile']

    Click Element   //button[text()='Edit profile']

    Log To Console  ${\n}Fill the new information:
    Log To Console  Bio: ${user_bio}
    Log To Console  Company: ${user_company}
    Log To Console  Location: ${user_location}
    Log To Console  Website: ${user_website}
    Log To Console  Twitter: ${user_twitter}

    #Insert BIO
    Input Text  //textarea[@aria-label='Add a bio']     ${user_bio}

    #Insert company
    Input Text  //input[@aria-label='Company']       ${user_company}

    #Insert location
    Input Text  //input[@aria-label='Location']      ${user_location}

    #Insert website
    Input Text  //input[@aria-label='Website']       ${user_website}

    #Insert twitter
    Input Text  //input[@aria-label='Twitter username']     ${user_twitter}

    #Click Save
    Click Element   //button[text()[contains(.,'Save')]]

    Wait Until Page Contains Element    //div[contains(@class, 'js-profile-editable-area')]/div[contains(@class, 'user-profile-bio')]

    Take App Evidence     InfoEditedEvidence

    ## validate stored info against kw inputs
    ${user_bio_ui}=        Get Text    //div[contains(@class, 'js-profile-editable-area')]/div[contains(@class, 'user-profile-bio')]
    ${user_company_ui}=    Get Text    //li[contains(@aria-label, 'Organization:')]//div
    ${user_location_ui}=   Get Text    //li[contains(@aria-label, 'Home location:')]/span
    ${user_website_ui}=    Get Text    //li[@itemprop = 'url']/a
    ${user_twitter_ui}=    Get Text    //li[@itemprop = 'twitter']/a

    Log To Console  ${\n}Getting the information from UI:
    Log To Console  UI_user_bio: ${user_bio_ui}
    Log To Console  UI_user_company: ${user_company_ui}
    Log To Console  UI_user_location: ${user_location_ui}
    Log To Console  UI_user_website: ${user_website_ui}
    Log To Console  UI_user_twitter: ${user_twitter_ui}

    Log To Console  Compare the info obtained from UI with the one passed as arguments.

    ## assertions for all values
    Should Be Equal As Strings      ${user_bio_ui}          ${user_bio}
    Should Be Equal As Strings      ${user_company_ui}      ${user_company}
    Should Be Equal As Strings      ${user_location_ui}     ${user_location}
    Should Be Equal As Strings      ${user_website_ui}      ${user_website}
    Should Be Equal As Strings      ${user_twitter_ui}      ${user_twitter}