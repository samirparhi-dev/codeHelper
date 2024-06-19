#!/bin/bash
# Author: <Name Here>
# License: Same as Repository Licence
# Usage : Beta-Release
# Date : Today's Date>

set -e
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)
BOLD=$(tput bold)

echo -e "\n${BLUE}###################################################${RESET}"

echo -e "\n${BOLD}${YELLOW}Info!${RESET} ${BLUE}You are using CodeQL playbook!\n
\n ⚠️ To run this Playbook We assume:\n
\n  1.You have alreday confirgured GitHub Action for this project.\n
    2.You have Curl, wget, Git and Jq installed on your PC.\n
    3.You need to first configure GitHub Action for the repository.\n
    4.You have github token configured in your PC\n"

echo -e "\n${BLUE}###################################################${RESET}"

echo -e "\n${BLUE}We need few info to make this process smoother.\nWhat is your Project name?${RESET}"
read REPO_NAME

echo -e "\n${BLUE}On which Namespace (some time called as Org) the project is in?${RESET}"
read REPO_OWNER

echo -e "\n${BLUE} Please keyin your github Token. \nWe dont read or record it. you are safe${RESET}"
read -s GITHUB_TOKEN

echo -e "\n${BLUE} Which version of $REPO_NAME you want to Scan ?${RESET}"
read  PROJECT_VERSION

echo -e "\n${BLUE} Tell us the workspace where you do all the activity related to $REPO_NAME project ${RESET}"
read  RESULT_DIR

echo -e "\n${BLUE}https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/workflows"

# Check if the CodeQL GitHub Action is configured 

workflow_id=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
-H "Accept: application/vnd.github.v3+json" \
"https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/workflows" | jq -r '.workflows[] | select(.name == "CodeQL") | .id')

echo -e "\n${BLUE}Recent GitHub workfow id is : $workflow_id${RESET}"

if [ ! -z "$workflow_id" ]; then

    echo -e "\n${BLUE}✅CodeQL is Configured.${RESET}"
else
    echo -e "\n${BLUE}❌ CodeQL GitHub Action is not configured in this repository.Kindly configure and comeback here."
    exit 1
fi

# Get the latest workflow run status

workflow_status=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
-H "Accept: application/vnd.github.v3+json" \
"https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/workflows/$workflow_id/runs?per_page=1" | jq -r '.workflow_runs[0].conclusion')

echo "$workflow_status"

# Check if the workflow run was successful

if [ "$workflow_status" == "success" ]; then
    echo -e "\n${BLUE}✅ Latest CodeQL GitHub Action was successful${RESET}"
else
    echo -e "\n${BLUE}❌ Latest CodeQL GitHub Action was not successful${RESET}"
    exit 1
fi
echo -e "\n${BLUE}ℹ Cloning the assessment github Repo${RESET}"
git clone https://github.com/$REPO_OWNER/besecure-assessment-datastore.git $RESULT_DIR

echo -e "\n${BLUE}ℹ Navigting to your project folder${RESET}"
cd $RESULT_DIR/besecure-assessment-datastore

echo -e "\n${BLUE}ℹ Creating a new branch for this project${RESET}"
git checkout -b codeql/$REPO_NAME-$PROJECT_VERSION-assessment
git branch

echo -e "\n${BLUE}ℹ Creating a new Directory for this project to store Assesment results${RESET}"
mkdir $RESULT_DIR/besecure-assessment-datastore/$REPO_NAME/$REPO_NAME-$PROJECT_VERSION

echo -e "\n${BLUE}ℹ Getting report for your Code QL run and storing in Assesment data store Directory${RESET}"
CodeQL_result=$(curl -sS \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $BESMAN_GH_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/$BESMAN_NAMESPACE/$BESMAN_ARTIFACT_NAME/code-scanning/alerts?page=10" >>$RESULT_DIR/besecure-assessment-datastore/$REPO_NAME/$REPO_NAME-$PROJECT_VERSION/$REPO_NAME-$PROJECT_VERSION-codeql-report.json )

echo -e "\n${BLUE}ℹ Commiting changes${RESET}"
git add .
git commit -m "Added codeql report for $REPO_NAME version $PROJECT_VERSION"

echo -e "\n${BLUE}ℹ Pushing your report to assessment data store assesment to Remote.${RESET}"

git push origin codeql/$REPO_NAME-$PROJECT_VERSION-assessment

echo -e "\n${BLUE}😊 You have successfuly served the purpose.${RESET}"

echo -e "\n${BLUE}Hit us a ⭐️ on our github:https://github.com/Be-Secure/BeSman , if you like this ${RESET}"
