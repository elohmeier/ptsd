function upload-to-paperless -d "upload documents to paperless"

    if count $argv >/dev/null
        for document in $argv

            set -f filename (basename $document | path change-extension '')

            # try to extract the date from the filename
            set -f created (string match -rg '^(\d{4}-\d{2}-\d{2})\D.*' $filename)
            if test -n "$created"
                set -f filename (string sub -s 11 $filename|string trim -l -c ' -_')
            end

            echo "Uploading $document to paperless"
            # $HOME/.paperless-token contains 'Token <token>'
            http -f --check-status --ignore-stdin POST localhost:9876/api/documents/post_document/ \
                Authorization:@$HOME/.paperless-token \
                document@"$document" \
                title="$filename" \
                created="$created"

        end
    else
        echo "No files specified"
        return 1
    end

end
