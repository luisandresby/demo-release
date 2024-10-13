#!/bin/bash

### IMPORTS
    dirname="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
    root=$(dirname $dirname)

    source "$dirname/lib/colors.sh"
    source "$dirname/lib/select.sh"
    source "$dirname/lib/array.sh"
    source "$dirname/lib/utils.sh"

### PRE-RELEASE
    # este script añade a _CHANGELOG los titulos de los issues que se han resuelto
    # y se queda a la espera, para poder editar el archivo, cuando este listo, puedes continuar el proceso
    npm run release:issues && 

    responses=(YES)
    title="✋ Edit the _CHANGELOG and hit 1 when its ready, or 2 to cancel the process"
    response=$(createSelect "$(printgreen "${title}")" "NO" "${responses[@]}")
    if [ ! "$response" = "YES" ];then
        # Discard all changes
        git restore .
        abort "$(printred "✋ cancelling ... bye bye")"
    fi
    # haz un commit con los cambios del _CHANGELO y continua la release
    git commit -am "changelog(auto)" &&

### RELEASE
version_bump_modes=("patch" "minor" "major")
version_bump_responses=("continue pre-release" "patch" "minor" "major")
pre_releases=("beta" "rc")

    CURRENT_BRANCH=$(git branch --show-current)
    if [ ! "$CURRENT_BRANCH" = "dev" ];then
        echo "$(printred "🛑 You must be in DEV branch to make a new release")"
        abort "$(printred "✋ cancelling ... bye bye")"
    fi

    PREVIOUS_RELEASE=$(git describe --tags --abbrev=0 $(git rev-list --tags --max-count=1))
    printblue "✋ Latest release ${PREVIOUS_RELEASE}"

    title="Select how the version would be bumped ?"
    message="✋ ${title}"
    VERSION_BUMP=$(createSelect "$(printgreen "${message}")" "Cancel" "${version_bump_responses[@]}")

    if ! $(inArray "$VERSION_BUMP" "${version_bump_responses[@]}"); then
        abort "$(printred "✋ cancelling ... bye bye")"
    fi

    if [ "$VERSION_BUMP" = "continue pre-release" ];then
        VERSION_BUMP=""
        IS_PRE_RELEASE="--preRelease"
        #CHANGELOG_GEN="--no-plugins.@release-it/conventional-changelog.infile"
        CHANGELOG_GEN=""
    else

        title="Is this a pre-release ?"
        message="✋ ${title}"
        PRE_RELEASE_MODE=$(createSelect "$(printgreen "${message}")" "No" "${pre_releases[@]}")

        if $(inArray "$PRE_RELEASE_MODE" "${pre_releases[@]}") ; then
            IS_PRE_RELEASE="--preRelease=${PRE_RELEASE_MODE}"
            # se genera el changelog de la pre-release, pero no se guarda
            # me podria intenresar guardarlo, por tener granularidad de los cambios
            #CHANGELOG_GEN="--no-plugins.@release-it/conventional-changelog.infile"
            CHANGELOG_GEN=""
        else
            IS_PRE_RELEASE=""
            CHANGELOG_GEN=""
        fi

    fi

    NEW_RELEASE=$(npx release-it $VERSION_BUMP $IS_PRE_RELEASE --release-version --no-git.requireCleanWorkingDir)

    responses=(YES)
    title="✋ This config generates a new ${VERSION_BUMP} release, do you want to continue ?"$'\n'"$NEW_RELEASE"
    response=$(createSelect "$(printgreen "${title}")" "NO" "${responses[@]}")
    if [ ! "$response" = "YES" ];then
        abort "$(printred "✋ cancelling ... bye bye")"
    fi

# Generate a new release in dev branch
ORIGIN_BRANCH="dev"
git checkout $ORIGIN_BRANCH &&
git pull &&
# release-it
npx release-it $VERSION_BUMP $IS_PRE_RELEASE $CHANGELOG_GEN
# HOOKS are configured in package.json
# after:bump, sync version in package.production.json

# this commit to the DEV branch launches BUILD+PUSH stages in the giltab-ci definition