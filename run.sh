#!/bin/sh

project(){
    start(){
        git init &&
            git remote add origin ${1} &&
            git remote add upstream ${2} &&
            git remote set-url --push upstream no_push &&
            git remote add authority ${3} &&
            git config user.email "${4}" &&
            git config user.name "${5}" &&
            cat /opt/git-flux/post-commit.sh > .git/hooks/post-commit &&
            chmod 0500 .git/hooks/post-commit &&
            (git fetch upstream milestones-00000-00000 && git checkout upstream/milestones-00000-00000 ||
            (
                git checkout -b milestones-00000-00000 && 
                    cp /opt/git-flux/COPYING . && 
                    cp /opt/git-flux/README.md . && 
                    git add README.md COPYING && 
                    git commit -m "init" && 
                    git push authority milestones-00000-00000 && 
                    git fetch upstream milestones-00000-00000 && 
                    git checkout upstream/milestones-00000-00000 && 
                    git branch -D milestones-00000-00000 &&
                    true
                )
            ) &&
            true
    } &&
        case ${1} in
            start)
                shift &&
                    start ${@} &&
                    true
            ;;
        esac &&
        true
} &&
    milestone(){
        major(){
            MAJOR=$(git branch | grep "*" | cut -f 2 -d "-") &&
                NEXT=$(printf %05d $((${MAJOR}+1))) &&
                (! git fetch upstream milestones-${NEXT}-00000 > /dev/null 2>&1 || (echo "Ineligible for a major milestone upgrade." && exit 66)) &&
                MINOR=$(git branch | grep "*" | cut -f 3 -d "-" | cut -f 1 -d ")") &&
                git fetch upstream milestones-${MAJOR}-${MINOR} &&
                git checkout upstream/milestones-${MAJOR}-${MINOR} &&
                git checkout -b milestones-${NEXT}-00000 &&
                git push authority milestones-${NEXT}-00000 &&
                git fetch upstream milestones-${NEXT}-00000 &&
                git checkout upstream/milestones-${NEXT}-00000 &&
                git branch -D milestones-${NEXT}-00000 &&
                true
        } &&
            minor(){
                MAJOR=$(git branch | grep "*" | cut -f 2 -d "-") &&
                    MINOR=$(git branch | grep "*" | cut -f 3 -d "-" | cut -f 1 -d ")") &&
                    NEXT=$(printf %05d $((${MINOR}+1))) &&
                    (! git fetch upstream milestones-${MAJOR}-${NEXT} > /dev/null 2>&1 || (echo "Ineligible for a minor milestone upgrade." && exit 67)) &&
                    git fetch upstream milestones-${MAJOR}-${MINOR} &&
                    git checkout upstream/milestones-${MAJOR}-${MINOR} &&
                    git checkout -b milestones-${MAJOR}-${NEXT} &&
                    git push authority milestones-${MAJOR}-${NEXT} &&
                    git fetch upstream milestones-${MAJOR}-${NEX} &&
                    git checkout upstream/milestones-${MAJOR}-${NEXT} &&
                    git branch -D milestones-${MAJOR}-${NEXT} &&
                    true
            } &&
            release(){
                CURRENT=$(git rev-parse --abbrev-ref HEAD) &&
                    MAJOR=$(git branch | grep "*" | cut -f 2 -d "-") &&
                    MINOR=$(git branch | grep "*" | cut -f 3 -d "-") &&
                    findit(){
                        RELEASE=$((${@})) &&
                            ((git fetch --tags upstream $((${MAJOR})).$((${MINOR})).${RELEASE} > /dev/null 2>&1 && findit $((${RELEASE}+1))) || echo ${RELEASE}) &&
                            true
                    } &&
                    RELEASE=$(findit 0) &&
                    git fetch upstream milestones-${MAJOR}-${MINOR} &&
                    git checkout upstream/milestones-${MAJOR}-${MINOR} &&
                    git tag -a $((${MAJOR})).$((${MINOR})).${RELEASE} -m "Version $((${MAJOR})).$((${MINOR})).${RELEASE}"
                    git push --follow-tags authority $((${MAJOR})).$((${MINOR})).${RELEASE} &&
                    git checkout ${CURRENT} &&
                    true
            } &&
            case ${1} in
                major)
                    shift &&
                        major ${@} &&
                        true
                ;;
                minor)
                    shift &&
                        minor ${@} &&
                        true
                ;;
                release)
                    shift &&
                        release ${@} &&
                        true
                ;;
            esac &&
                true
    } &&
    issue(){
        start(){
            MILESTONE=/$(printf %05d ${1})/$(printf %05d ${2}) &&
                git fetch upstream milestones-${MILESTONE} &&
                git checkout upstream/${MILESTONE} &&
                git checkout -b issues/${MILESTONE}/$(printf %05d ${3})/$(uuidgen) &&
                true
        } &&
            rebase(){
                ([ ! -z "$(git clean -n -d)" ] || (echo "There are files not under version control." && exit 64)) &&
                    ([ ! -z "$(git diff)" ] || (echo "There are uncommitted changes." && exit 65)) &&
                    MAJOR=$(git branch | grep "*" | cut -f 2 -d "-") &&
                    MINOR=$(git branch | grep "*" | cut -f 3 -d "-") &&
                    ISSUE=$(git rev-parse --abbrev-ref HEAD | cut -f 3 -d "-") &&
                    git fetch upstream milestones-${MAJOR}-${MINOR} &&
                    BRANCH=issues/${MAJOR}-${MINOR}-${ISSUE}/$(uuidgen) &&
                    git checkout -b ${BRANCH} &&
                    git push origin ${BRANCH} &&
                    true
            } &&
            finish(){
                rebase_issue &&
                    MAJOR=$(git branch | grep "*" | cut -f 2 -d "-") &&
                    MINOR=$(git branch | grep "*" | cut -f 3 -d "-") &&
                    ISSUE=$(git rev-parse --abbrev-ref HEAD | cut -f 3 -d "-") &&
                    BRANCH=requests-${MAJOR}-${MINOR}-${ISSUE} &&
                    git checkout -b ${BRANCH} &&
                    git reset milestones-${MAJOR}-${MINOR} &&
                    git commit &&
                    git push authority ${BRANCH} &&
                    true
            } &&
            case ${1} in
                start)
                    shift &&
                        start ${@} &&
                        true
                    ;;
                    rebase)
                        shift &&
                            rebase ${@} &&
                            true
                    ;;
                    finish)
                        shift &&
                            finish ${@} &&
                            true
                    ;;
                esac &&
                true
    } &&
    case ${1} in
        project)
            shift &&
                project ${@} &&
                true
        ;;
        milestone)
            shift &&
                milestone ${@} &&
                true
        ;;
        issue)
            shift &&
                issue ${@} &&
                true
    esac &&
    true
