function upload-to-paperless -d "upload documents to paperless"

    argparse --name=upload-to-paperless h/help c/correspondent= d/documenttype= -- $argv
    or return 1

    if test -n "$_flag_h"
        echo "Usage: upload-to-paperless [-h] [-c correspondent-id] [-d documenttype-id] file1 file2 ..."
        return
    end

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
                created="$created" \
                correspondent="$_flag_c" \
                document_type="$_flag_d"

        end
    else
        echo "No files specified"
        return 1
    end

end
