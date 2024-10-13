#!/bin/bash
# REQUIRES jq installed, on mac: brew install jq

dirname="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
root=$(dirname $dirname)

source "$dirname/lib/colors.sh"
source "$dirname/lib/select.sh"
source "$dirname/lib/array.sh"
source "$dirname/lib/utils.sh"

append_to_top_of_a_file() {
    local content=$1
    local file_path=$2
    echo -e $content | cat - $file_path > temp && mv temp $file_path
}

###
# GILTAB CREDENTIALS
###
    GITLAB_CREDENTIALS_FILE="$dirname/.env_gitlab"
    if [ -f "$GITLAB_CREDENTIALS_FILE" ]; then
        # GITLAB credentials and registry url are in .env_gitlab file
        source "$GITLAB_CREDENTIALS_FILE"
    fi
    if [ -z "$GITLAB_PROJECT_TOKEN" ]; then
        abort "$(printred "✋ cancelling ... bye bye (env_gitlab variables are not correctly set)")"
    fi
    echo "🙆 Gitlab credentials for user ${GITLAB_USER} in project ${GITLAB_PROJECT}"

CHANGELOG_FILE="$root/_CHANGELOG.md"
# Get the last created tag
last_tag=$(git describe --tags --abbrev=0)
# last_tag="1.6.0-beta.0"
branch1="dev"
branch2="dev-integration"
branch3="root-integration"
limit=30

# Merge branch '51-configsources-error-crear-fuente' into 'dev'
merged=( $(git log --merges "$last_tag..HEAD" -n $limit --grep="Merge branch '.*' into '$branch1'" --grep="Merge branch '.*' into '$branch2'" --grep="Merge branch '.*' into '$branch3'" --pretty=format:"%s") )
# TODOS
# merged=( $(git log --merges -n $limit --grep="Merge branch '.*' into '$branch1'" --grep="Merge branch '.*' into '$branch2'" --grep="Merge branch '.*' into '$branch3'" --pretty=format:"%s") )
branch_names=()
for item in "${merged[@]}"; do
    # echo $item
    if [ -n "$item" ] && [ ! $item = " " ] && [ ! $item = "" ] && [ ! "$item" = "Merge" ] && [ ! "$item" = "branch" ] && [ ! "$item" = "into" ] && [ ! "$item" = "'$branch1'" ] && [ ! "$item" = "'$branch2'" ] && [ ! "$item" = "'$branch3'" ] ;then
        branch_names+=("$item")
    fi
done

# for item in "${branch_names[@]}"; do
#     echo $item
# done


issues=()
for element in "${branch_names[@]}"; do
    # echo "$element" | tr -d "'" # remove all ocurrences of ''
    number=$(echo $element | tr -d "'" | sed -n 's/\([0-9]*\).*/\1/p')
    if [ -n $number ] && [ ! $number = " " ] && [ ! $number = "" ]; then
        issues+=("$number")
    fi
done

# for item in "${issues[@]}"; do
#     echo $item
# done

if [ ${#issues[@]} = 0 ]; then
    changelog_empty_title="<release-empty>\n"
    append_to_top_of_a_file "$changelog_empty_title" "$CHANGELOG_FILE"
    echo "No issues resolved since $last_tag"
    exit 0
else
    echo "${#branch_names[@]} branches and ${#issues[@]} resolved issues since $last_tag"
fi

# GET /issues?iids[]=42&iids[]=43
issue_list=""
for id in "${issues[@]}"; do
    issue_list+="iids[]=$id&"
done
issue_list_clean=${issue_list%?} # remove last & CHAR
# echo "issue_list: $issue_list_clean"

# echo $issue_list
json_data=$(curl -s --header "Authorization: Bearer $GITLAB_PROJECT_TOKEN" "https://gitlab.isid.com/api/v4/projects/23/issues?$issue_list_clean" )

changelog_content=$(echo "$json_data" | jq -c '.[]'| while read -r object; do
  # Extract values from each object
  key1=$(echo "$object" | jq -r '.iid')
  key2=$(echo "$object" | jq -r '.title')

  # Use the extracted values (for example, print them)
  issueUrl="https://gitlab.isid.com/frontend/intelion-2/-/issues/$key1"
  newChange="- [$key1]($issueUrl). $key2"
  echo "${newChange}\n"
done)

changelog_content_withTitleTag="<release-auto>\n\n""$changelog_content"
if [ -f "$CHANGELOG_FILE" ];then
    append_to_top_of_a_file "$changelog_content_withTitleTag" "$CHANGELOG_FILE"
else
    abort "$(printred "✋ cancelling ... bye bye _CHANGELOG file was not found")"
fi