function upload-to-paperless -d "upload documents to paperless"

    argparse --name=upload-to-paperless h/help c/correspondent= d/documenttype= t/tag=+ -- $argv
    or return 1

    if test -n "$_flag_h"
        echo "Usage: upload-to-paperless [-h] [-c correspondent-id] [-d documenttype-id] [-t tag1] [-t tag2] ... file1 file2 ..."
        return
    end

    # "1 2" -> "tags=1 tags=2 "
    set -f tags (echo $_flag_t | awk '{split($0, a, " "); for (i in a) printf "tags=%s ", a[i]}')

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
            xh -b -f --check-status --ignore-stdin POST localhost:9876/api/documents/post_document/ \
                Authorization:@$HOME/.paperless-token \
                document@"$document" \
                title="$filename" \
                created="$created" \
                correspondent="$_flag_c" \
                document_type="$_flag_d" \
                $tags
        end
    else
        echo "No files specified"
        return 1
    end

end
