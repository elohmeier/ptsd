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

    if test -n "$_flag_m"
        set -f header "$_flag_t: Please select one or many"
    else
        set -f header "$_flag_t: Please select one"
    end

    set -l id (FZF_DEFAULT_COMMAND="paperless-ids $_flag_t" \
        fzf --bind 'ctrl-r:reload(eval "$FZF_DEFAULT_COMMAND")' \
        --header="$header (press CTRL-R to reload)" --layout=reverse \
        --with-nth 2.. $_flag_m \
        | awk '{print $1}')

    if test -z "$id"
        return 1
    else
        echo $id
    end
end
