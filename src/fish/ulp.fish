function ulp -d "upload documents to paperless choosing associations via fzf"

    set -f documenttype (paperless-id -t document_types)
    set -f correspondent (paperless-id -t correspondents)
    set -f tags (paperless-id -t tags -m)

    upload-to-paperless \
        --documenttype=$documenttype \
        --correspondent=$correspondent \
        --tag=$tags \
        $argv

end
