#!/usr/bin/env sh

set -e

#borg=borg-job-rpi4
borg=borg
archiveName=$1

json=$($borg list --json)
tag=$(jq -r '"{repository_location=\""+.repository.location+"\"}"' <<< $json)
echo "# HELP borgbackup_archive_count Number of archives in the repository"
echo "# TYPE borgbackup_archive_count gauge"
echo "borgbackup_archive_count$tag $(jq -r '.archives | length' <<< $json)"


json=$($borg info --json "::$archiveName")

archive_tag=$(jq -r '"{repository_location=\""+.repository.location+"\",archive_hostname=\""+.archives[0].hostname+"\",archive_username=\""+.archives[0].username+"\",archive_name=\""+.archives[0].name+"\"}"' <<< $json)

echo "# HELP borgbackup_last_start The timestamp of the last archive (unixtimestamp)"
echo "# TYPE borgbackup_last_start gauge"
# gmtime converts local time to UTC
echo "borgbackup_last_start$archive_tag $(jq -r '.archives[0].start|strptime("%Y-%m-%dT%H:%M:%S.000000")|mktime|gmtime|mktime' <<< $json)"

echo "# HELP borgbackup_last_compressed_size The compressed size of the last archive"
echo "# TYPE borgbackup_last_compressed_size gauge"
echo "borgbackup_last_compressed_size$archive_tag $(jq -r '.archives[0].stats.compressed_size' <<< $json)"

echo "# HELP borgbackup_last_deduplicated_size The deduplicated size of the last archive"
echo "# TYPE borgbackup_last_deduplicated_size gauge"
echo "borgbackup_last_deduplicated_size$archive_tag $(jq -r '.archives[0].stats.deduplicated_size' <<< $json)"

echo "# HELP borgbackup_last_nfiles The number of files in the last archive"
echo "# TYPE borgbackup_last_nfiles gauge"
echo "borgbackup_last_nfiles$archive_tag $(jq -r '.archives[0].stats.nfiles' <<< $json)"

echo "# HELP borgbackup_last_original_size The original size of the last archive"
echo "# TYPE borgbackup_last_original_size gauge"
echo "borgbackup_last_original_size$archive_tag $(jq -r '.archives[0].stats.original_size' <<< $json)"

echo "# HELP borgbackup_last_duration The backup duration of the last archive"
echo "# TYPE borgbackup_last_duration gauge"
echo "borgbackup_last_duration$archive_tag $(jq -r '.archives[0].duration' <<< $json)"

cache_tag=$(jq -r '"{repository_location=\""+.repository.location+"\",cache_path=\""+.cache.path+"\"}"' <<< $json)

echo "# HELP borgbackup_cache_total_chunks The total number of chunks in the cache"
echo "# TYPE borgbackup_cache_total_chunks gauge"
echo "borgbackup_cache_total_chunks$cache_tag $(jq -r '.cache.stats.total_chunks' <<< $json)"

echo "# HELP borgbackup_cache_total_csize The total size of the chunks in the cache"
echo "# TYPE borgbackup_cache_total_csize gauge"
echo "borgbackup_cache_total_csize$cache_tag $(jq -r '.cache.stats.total_csize' <<< $json)"

echo "# HELP borgbackup_cache_total_size The total size of the cache"
echo "# TYPE borgbackup_cache_total_size gauge"
echo "borgbackup_cache_total_size$cache_tag $(jq -r '.cache.stats.total_size' <<< $json)"

echo "# HELP borgbackup_cache_total_unique_chunks The total number of unique chunks in the cache"
echo "# TYPE borgbackup_cache_total_unique_chunks gauge"
echo "borgbackup_cache_total_unique_chunks$cache_tag $(jq -r '.cache.stats.total_unique_chunks' <<< $json)"

echo "# HELP borgbackup_cache_unique_csize The total size of the unique chunks in the cache"
echo "# TYPE borgbackup_cache_unique_csize gauge"
echo "borgbackup_cache_unique_csize$cache_tag $(jq -r '.cache.stats.unique_csize' <<< $json)"

echo "# HELP borgbackup_cache_unique_size The total size of the unique chunks in the cache"
echo "# TYPE borgbackup_cache_unique_size gauge"
echo "borgbackup_cache_unique_size$cache_tag $(jq -r '.cache.stats.unique_size' <<< $json)"


