{ pkgs, ... }:

# Config file example (JSON):
# [
#   {
#     "user": "user@example.com",
#     "drives": [
#       { "name": "shared drive 1", "id": "0AKb_abcdefxyz" },
#       { "name": "shared drive 2", "id": "0AA2_abcdefxyz" },
#       { "name": "my", "id": "" }
#     ]
#   }
# ]

{
  systemd.services.rclone-fraam-gdrive-backup = {
    description = "rclone job for fraam-gdrive-backup";
    path = with pkgs; [ rclone jq gnused ];
    script = ''
      for userrow in $(jq -r '.[] | @base64' "$CREDENTIALS_DIRECTORY/gdrive-cfg"); do
      	_jq() {
      		echo "''${userrow}" | base64 --decode | jq -r "''${1}"
      	}

      	user=$(_jq '.user')

      	for driverow in $(_jq '.drives[] | @base64'); do
      		_jq2() {
      			echo "''${driverow}" | base64 --decode | jq -r "''${1}"
      		}
      		safename=$(_jq2 '.name' | sed 's/[^a-zA-Z0-9]/_/g')
      		id=$(_jq2 '.id')
      		safeid=''${id:-$(echo $user | sed 's/[^a-zA-Z0-9]/_/g')} # default to username if not set

      		echo "Downloading $user's $safename ($safeid)..."
      		touch "/var/lib/syncthing/fraam-gdrive-backup/''${safeid}_''${safename}"
      		# rclone dedupe ...flags... --dedupe-mode rename "''${safename}"
      		rclone sync --drive-client-id "110476733789902981992" --drive-service-account-file "''${CREDENTIALS_DIRECTORY}/gdrive-key" --drive-scope "drive.readonly" --drive-impersonate "$user" --drive-team-drive "$id" --drive-skip-shortcuts ":drive:" "/var/lib/syncthing/fraam-gdrive-backup/''${safeid}"
      		echo ""
      	done

      done
    '';

    serviceConfig = {
      # execution
      Type = "oneshot";
      LoadCredential = [
        "gdrive-key:/var/lib/syncthing/fraam-gdrive-backup-2dcf90646dee.json"
        "gdrive-cfg:/var/lib/syncthing/fraam-gdrives.json"
      ];
      ReadWritePaths = [ "/var/lib/syncthing/fraam-gdrive-backup" ];

      # hardening
      User = "syncthing";
      Group = "syncthing";
      StartLimitBurst = 5;
      NoNewPrivileges = true;
      LimitNPROC = 64;
      LimitNOFILE = 1048576;
      PrivateTmp = true;
      PrivateDevices = true;
      PrivateUsers = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ProtectControlGroups = true;
      ProtectClock = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "noaccess";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      RestrictAddressFamilies = "AF_INET AF_INET6";
      RestrictNamespaces = true;
      DevicePolicy = "closed";
      RestrictRealtime = true;
      SystemCallFilter = "@system-service";
      SystemCallErrorNumber = "EPERM";
      SystemCallArchitectures = "native";
      UMask = "0066";
    };
    wants = [ "network.target" "network-online.target" ];
    startAt = "*-*-* 05:00:00";
  };
}
