#!/bin/sh

function project(){
    case ${1} in
        start)
        ;;
    esac &&
    true
} &&
    function milestone(){
        function major(){
            MAJOR=$(git rev-parse --abbrev-ref HEAD | cut --fields 2 --delimiter "/") &&
                NEXT=$(printf %05d $((${MAJOR}+1))) &&
                (git fetch upstream milestones/${NEXT}/00000 || (echo "Ineligible for a major milestone upgrade." && exit 66)) &&
                MINOR=$(git rev-parse --abbrev-ref HEAD | cut --fields 3 --delimiter "/") &&
                git checkout upstream/milestones/${MAJOR}/${MINOR} &&
                git checkout -b milestones/${NEXT}/00000 &&
                git push origin milestones/${NEXT}/00000 &&
                true
        } &&
            function minor(){
                MAJOR=$(git rev-parse --abbrev-ref HEAD | cut --fields 2 --delimiter "/") &&
                    MINOR=$(git rev-parse --abbrev-ref HEAD | cut --fields 3 --delimiter "/") &&
                    NEXT=$(printf %05d $((${MINOR}+1))) &&
                    (git fetch upstream milestones/${MAJOR}/${NEXT} || (echo "Ineligible for a minor milestone upgrade." && exit 67)) &&
                    git checkout upstream/milestone/${MAJOR}/${MINOR} &&
                    git checkout -b milestones/${MAJOR}/${NEXT} &&
                    git push origin milestones/${MAJOR}/${NEXT}
                    true
            } &&
            function release(){
                MAJOR=$(git rev-parse --abbrev-ref HEAD | cut --fields 2 --delimiter "/") &&
                    MINOR=$(git rev-parse --abbrev-ref HEAD | cut --fields 3 --delimiter "/") &&
                    git fetch upstream/${MAJOR}/${MINOR}/ &&
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
    function issue(){
        function start(){
            MILESTONE=/$(printf %05d ${1})/$(printf %05d ${2}) &&
                git fetch upstream milestones/${MILESTONE} &&
                git checkout upstream/${MILESTONE} &&
                git checkout -b issues/${MILESTONE}/$(printf %05d ${3})/$(uuidgen) &&
                true
        } &&
            function rebase(){
                ([ ! -z "$(git clean -n -d)" ] || (echo "There are files not under version control." && exit 64)) &&
                    ([ ! -z "$(git diff)" ] || (echo "There are uncommitted changes." && exit 65)) &&
                    MAJOR=$(git rev-parse --abbrev-ref HEAD | cut --fields 2 --delimiter "/") &&
                    MINOR=$(git rev-parse --abbrev-ref HEAD | cut --fields 3 --delimiter "/") &&
                    ISSUE=$(git rev-parse --abbrev-ref HEAD | cut --fields 3 --delimiter "/") &&
                    git fetch upstream milestones/${MAJOR}/${MINOR} &&
                    BRANCH=issues/${MAJOR}/${MINOR}/${ISSUE}/$(uuidgen) &&
                    git checkout -b ${BRANCH} &&
                    git push origin ${BRANCH} &&
                    true
            } &&
            function finish(){
                rebase_issue &&
                    MAJOR=$(git rev-parse --abbrev-ref HEAD | cut --fields 2 --delimiter "/") &&
                    MINOR=$(git rev-parse --abbrev-ref HEAD | cut --fields 3 --delimiter "/") &&
                    ISSUE=$(git rev-parse --abbrev-ref HEAD | cut --fields 3 --delimiter "/") &&
                    BRANCH=merge-requests/${MAJOR}/${MINOR}/${ISSUE} &&
                    git checkout -b ${BRANCH} &&
                    git reset milestones/${MAJOR}/${MINOR} &&
                    git commit &&
                    git push origin ${BRANCH} &&
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
