function paperless-id -a type -d "select id of a paperless relation"
    if test -z "$type"
        echo "No type specified"
        return 1
    end

    set -l id (http --check-status --ignore-stdin "localhost:9876/api/$type/" Authorization:@$HOME/.paperless-token \
        | jq -r '.results[] | (.id | tostring) + " " + .name' \
        | fzf --with-nth 2.. \
        | awk '{print $1}')

    if test -z "$id"
        return 1
    else
        echo $id
    end
end
