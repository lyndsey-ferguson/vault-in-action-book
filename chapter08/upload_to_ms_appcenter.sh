#!/usr/bin/env bash

APK=$1

# Begin by creating an "upload resource" to track
# the upload and update its status
function create_upload_resource {
	local upload_resource
  upload_resource=$( \
    curl -X POST \
    --silent \
    "https://api.appcenter.ms/v0.1/apps/magic-dollar/Magic-Dollar-Wallet/uploads/releases" \
    -H "accept: application/json" \
    -H "X-API-Token: $MAGIC_DOLLAR_APK_API_TOKEN" \
    -H  "Content-Type: application/json" \
  )
  PROPOSED_RELEASE_ID=$(echo $upload_resource | jq -r '.id')
  PACKAGE_ASSET_ID=$(echo $upload_resource | jq -r '.package_asset_id')
  UPLOAD_DOMAIN=$(echo $upload_resource | jq -r '.upload_domain')
  URL_ENCODED_TOKEN=$(echo $upload_resource | jq -r '.url_encoded_token')
}

# Complete the upload by marking the "upload resource"
# as "uploadFinished"
function mark_upload_complete {
  local finished_url
  finished_url="https://file.appcenter.ms/upload/finished/$PACKAGE_ASSET_ID?token=$URL_ENCODED_TOKEN"

  curl --silent -d POST -H "Content-Type: application/json" -H "Accept: application/json" -H "X-API-Token: $MAGIC_DOLLAR_APK_API_TOKEN" "$finished_url" > /dev/null

  COMMIT_URL="https://api.appcenter.ms/v0.1/apps/magic-dollar/Magic-Dollar-Wallet/uploads/releases/$PROPOSED_RELEASE_ID"

  curl --silent -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "X-API-Token: $MAGIC_DOLLAR_APK_API_TOKEN" \
    --data '{"upload_status": "uploadFinished", "id": "'"$UPLOAD_ID"'"}' \
    -X PATCH $COMMIT_URL > /dev/null
}

# Wait until the upload we started and completed
# has been processed and is available as a
# release in MS App Center
function poll_until_upload_processed {
  local end_time
  end_time=$((SECONDS+60))

  while [ $SECONDS -lt $end_time ]; do
    RELEASE_STATUS_URL="https://api.appcenter.ms/v0.1/apps/magic-dollar/Magic-Dollar-Wallet/uploads/releases/$PROPOSED_RELEASE_ID"
    POLL_RESULT=$(curl -s -H "Content-Type: application/json" -H "Accept: application/json" -H "X-API-Token: $MAGIC_DOLLAR_APK_API_TOKEN" $RELEASE_STATUS_URL)
    RELEASE_ID=$(echo $POLL_RESULT | jq -r '.release_distinct_id')

    if [[ $RELEASE_ID != null ]]; then
      echo "Success: ${APK} uploaded with release id ${RELEASE_ID}"
      break
    fi
  done
  if [[ -z $RELEASE_ID ]]; then
    echo "Error: failed to upload ${APK}"
    exit 1
  fi
}

# Release the uploaded APK for download
function release_upload {
  local distribute_url
  distribute_url="https://api.appcenter.ms/v0.1/apps/magic-dollar/Magic-Dollar-Wallet/uploads/releases/$PROPOSED_RELEASE_ID"

  curl --silent -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "X-API-Token: $MAGIC_DOLLAR_APK_API_TOKEN" \
    --data '{"upload_status": "uploadFinished" }' \
    -X PATCH $distribute_url > /dev/null
}

# Send the application to our testers group
function distribute_to_testers {
  local beta_testers_group_id
  beta_testers_group_id="5fcb0720-f0ce-4d81-aceb-25a06e115cde"

  local distribute_testers_url
  distribute_testers_url="https://api.appcenter.ms/v0.1/apps/magic-dollar/Magic-Dollar-Wallet/releases/${RELEASE_ID}/groups"
  curl --silent -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "X-API-Token: $MAGIC_DOLLAR_APK_API_TOKEN" \
    --data '{"mandatory_update": true, "id" : "'${beta_testers_group_id}'", "notify_testers": true}' \
    -X POST $distribute_testers_url > /dev/null
}

# Get the file size and chunk size that MS App Center
# will allow us to upload the chunks of the APK
function prepare_for_upload {
  FILE_SIZE_BYTES=$(wc -c "${APK}" | awk '{print $1}')
  APP_TYPE='application/vnd.android.package-archive'

  METADATA_URL="https://file.appcenter.ms/upload/set_metadata/${PACKAGE_ASSET_ID}?file_name=${APK}&file_size=${FILE_SIZE_BYTES}&token=${URL_ENCODED_TOKEN}&content_type=${APP_TYPE}"

  local upload_metadata
  upload_metadata=$( \
    curl --silent -d POST -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "X-API-Token: $MAGIC_DOLLAR_APK_API_TOKEN" $METADATA_URL \
  )

  UPLOAD_ID=$(echo $upload_metadata | jq -r '.id')
  CHUNK_SIZE=$(echo $upload_metadata | jq -r '.chunk_size')
}

# Upload the APK file chunks
function upload_file {
  tmp_dir=$(mktemp -d -t magic-dollar-beta-upload-XXXXXX)
  split -b $CHUNK_SIZE "${APK}" $tmp_dir/split

  block_number=0

  for i in $tmp_dir/*
  do
      block_number=$(($block_number + 1))
      content_length=$(wc -c "$i" | awk '{print $1}')

      upload_chunk_url="https://file.appcenter.ms/upload/upload_chunk/$PACKAGE_ASSET_ID?token=$URL_ENCODED_TOKEN&block_number=$block_number"

      curl -X POST $upload_chunk_url \
        --silent \
        --data-binary "@$i" \
        -H "Content-Length: $content_length" \
        -H "Content-Type: application/octet-stream" > /dev/null
  done

  mark_upload_complete
  poll_until_upload_processed
  release_upload
}

create_upload_resource
prepare_for_upload
upload_file
distribute_to_testers

