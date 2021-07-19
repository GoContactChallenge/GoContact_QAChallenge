*** Settings ***
Resource    ../Keywords/WEB_keywords.robot

Test Setup      Open GitHub Website

Test Teardown   Close GitHub Website

*** Test Cases ***

Registration - Check Password 3-level Strength Mechanism
    [Documentation]     Go to 'Sign up', insert an email and validate that password has 3-level strenght mechanism and it is working correctly for each password.

    ${email}=   Set Variable  challenge_teste_qwerty123@gmail.com

    Go To Registration Page and Wait for Form

    Insert and Validate if Password is Good    ${email}     password=qwerty        message_to_validate=Password is too short    #size less than 8
    Insert and Validate if Password is Good    ${email}     password=qwertyqwerty  message_to_validate=Password needs a number and lowercase letter     #only numbers or only letters
    Insert and Validate if Password is Good    ${email}     password=Qwerty123     message_to_validate=Password is strong      #at least size 8 with numbers and letters

Registration - Validate Anti Robot Mechanism is Active
    [Documentation]     Go to 'Sign Up', insert credentials and validate that anti robot puzzle is working.

    Go To Registration Page and Wait for Form

    ## Some "valid" format credentials for validate the form
    Insert Sign Up Credentials      challenge_test_qwerty123@gmail.com         Qwerty123      TesteQwerty123

    Go to iFrame and Check that Puzzle is Working

Repo - Create New Empty Repository
    [Documentation]     Click in 'Sign In', insert credentials and create a new repository with a unique name.

    Go To GitHub Sign In Page

    Login In GitHub Website

    # Define the name (with unique timestamp) and description of the repo
    ${timestamp}=           Get Current Date    result_format=%Y%m%d%H%M
    Create New Repository and Fill Information      Repo_Test_${timestamp}    Some description for some repo     private

Repo - Create New File and Validate it
    [Documentation]     Validate the creation of a file in the repository and check that the file content was correctly created.

    Go To GitHub Sign In Page

    Login In GitHub Website

    # Define part of the name of the repo where to create the file (ex. *my_repo*). Make sure at least 1 repo exists. You can run the TC for Repo creation before this test
    Search for a Repository and Enter it    Repo_Test

    Create new File             FileNameExample     SampleContent

    Validate new Created File   FileNameExample     SampleContent

Repo - Change Repo Access from Private to Public and Check that anyone can access it
    [Documentation]     This CT validates that when changing the repo visibility, users can or cannot access accordingly configured (argument) visibility option:
    ...                 Change Repo Access from Private to Public and Check that ANYONE can access it (public argument)
    ...                 Change Repo Access from Public to Private and Check that NO ONE can access it (private argument)

    # This Variables are Case sensitive
    ${repo_visibility}=     Set Variable    private
#    ${repo_visibility}=     Set Variable    public

    Go To GitHub Sign In Page

    Login In GitHub Website

    # Define here part of the name of the repo and Make sure at least 1 repo exists. Tip: You can run a TC for Repo creation before this test
    ${repo_name_changed}=   Search for a Repository and Enter it  Repo_Test

    Go to Repository Settings

    Change Repository Visibility                    ${repo_name_changed}    ${repo_visibility}

    Confirm Visibily Changes with Anonymous User    ${repo_name_changed}    ${repo_visibility}

Repo - Search and Remove a Repository with Success
    [Documentation]     Validate that the Search mechanism is working and also the deletion of the repository searched.

    Go To GitHub Sign In Page

    Login In GitHub Website

    # Define part of the name of the repo to delete (ex. *my_repo*). Make sure at least 1 repo exists. You can run the TC for Repo creation before this test
    ${repo_name_deleted}=       Search for a Repository and Enter it    Repo_Test

    Go to Repository Settings

    Remove this Repository  ${repo_name_deleted}

Project - Create a New Project
    [Documentation]     Click in 'Sign In', insert credentials and create a new Project with the specification passed in keyword arguments.

    Go To GitHub Sign In Page

    Login In GitHub Website

    Click in Sub Menu Option   Your projects

    # Define the name (with unique timestamp) and description of the Project to create. Case sensitive
    ${timestamp}=   Get Current Date    result_format=%Y%m%d%H%M
    Create New Project and Fill Information      ProjectTest_${timestamp}    Some description for some Project      Basic kanban     Private

Project - Edit Project Information
    [Documentation]     Click in 'Sign In', insert credentials, search for a Project and edit it.

    Go To GitHub Sign In Page

    Login In GitHub Website

    Click in Sub Menu Option   Your projects

    Search for a Project    ProjectTest_

    Open Project Menu Options and Select Sub Option     ProjectTest_     Edit

    ${timestamp}=   Get Current Date    result_format=%Y%m%d%H%M
    Edit Project Information    ProjectTest_     ProjectTestNewName_${timestamp}     Project Test New Description

Project - Search and Remove an Existing Project
    [Documentation]     Click in 'Sign In', insert credentials, search for a Project and remove it.

    Go To GitHub Sign In Page

    Login In GitHub Website

    Click in Sub Menu Option   Your projects

    Search for a Project    ProjectTest

    Open Project Menu Options and Select Sub Option     ProjectTest     Edit

    Delete this Project

Profile - Edit User Personal Information and Validate it
    [Documentation]  Click in 'Sign In', insert valid credentials, go to 'Your Profile' section and edit user personal information with success.

    Go To GitHub Sign In Page

    Login In GitHub Website

    Click in Sub Menu Option   Your profile

    ## bio, company, location, website, twitter
    Edit User Profile Information   Some interesting things to others   My Company     My Location     my_website@teste.pt    @MyTwitter
