function paperless-id -d "select id of a paperless relation"

    argparse --name=paperless-id m/multiple t/type= h/help -- $argv
    or return 1

    if test -n "$_flag_h"
        echo "Usage: paperless-id [-h] [-m] [-t type]"
        return
    end

    if test -z "$_flag_t"
        echo "Please specify a type"
        return 1
    end

    set -l id (http --check-status --ignore-stdin "localhost:9876/api/$_flag_t/" Authorization:@$HOME/.paperless-token \
        | jq -r '.results[] | (.id | tostring) + " " + .name' \
        | fzf --with-nth 2.. $_flag_m \
        | awk '{print $1}')

    if test -z "$id"
        return 1
    else
        echo $id
    end
end
