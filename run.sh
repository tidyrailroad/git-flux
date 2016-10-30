#!/bin/sh

function flux(){
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
} &&
    function project(){
        case ${1} in
            start)
            ;;
        esac &&
        true
    } &&
    function milestone(){
        case ${1} in
            start)
            ;;
        esac &&
            true
    } &&
    function issue(){
        case ${1} in
            start)
                shift &&
                    start_issue ${@} &&
                    true
            ;;
            rebase)
                shift &&
                    rebase_issue ${@} &&
                    true
            ;;
            finish)
                shift &&
                    finish_issue ${@} &&
                    true
            ;;
        esac &&
            true
    } &&
    function start_issue(){
        MILESTONE=/$(printf %05d ${1})/$(printf %05d ${2}) &&
            git fetch upstream milestones/${MILESTONE} &&
            git checkout upstream/${MILESTONE} &&
            git checkout -b issues/${MILESTONE}/$(printf %05d ${3})/$(uuidgen) &&
            true
    } &&
    function rebase_issue(){
        ([ ! -z "$(git clean -n -d)" ] || (echo "There are files not under version control." && exit 64)) &&
            ([ ! -z "$(git diff)" ] || (echo "There are uncommitted changes." && exit 65)) &&
            MAJOR=$(git rev-parse --abbrev-ref HEAD | cut --fields 2 --delimiter "/") &&
            MINOR==$(git rev-parse --abbrev-ref HEAD | cut --fields 3 --delimiter "/") &&
            ISSUE==$(git rev-parse --abbrev-ref HEAD | cut --fields 3 --delimiter "/") &&
            git fetch upstream milestones/${MAJOR}/${MINOR} &&
            BRANCH=issues/${MAJOR}/${MINOR}/${ISSUE}/$(uuidgen) &&
            git checkout -b ${BRANCH} &&
            git push origin ${BRANCH} &&
            true
    } &&
    function finish_issue(){
        rebase_issue &&
            MAJOR=$(git rev-parse --abbrev-ref HEAD | cut --fields 2 --delimiter "/") &&
            MINOR==$(git rev-parse --abbrev-ref HEAD | cut --fields 3 --delimiter "/") &&
            ISSUE==$(git rev-parse --abbrev-ref HEAD | cut --fields 3 --delimiter "/") &&
            BRANCH=merge-requests/${MAJOR}/${MINOR}/${ISSUE} &&
            git checkout -b ${BRANCH} &&
            git reset milestones/${MAJOR}/${MINOR} &&
            git commit &&
            git push origin ${BRANCH} &&
            true
    } &&
    flux ${@} &&
    true
