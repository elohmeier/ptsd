{
  hosts = {

    and2 = {
      # U.S. Handy
      nets = {
        dlrgvpn = {
          ip4.addr = "191.18.21.2";
          wireguard.pubkey = "/5uhmBD09M5MK0no5aURYjeUeHFelYSoyEbs9s1l1WI=";
        };
      };
    };

    apu2 = {
      # DLRG
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.34";
          aliases = [
            "apu2.nw"
          ];
          wireguard = {
            pubkey = "eQXHytFmxA8HyECId+vVaTOVE9iCaWV7KVGs5ps6glQ=";
            networks = [ "192.168.168.0/24" ];
          };
        };

        dlrgvpn = {
          ip4.addr = "191.18.21.34";
          # ip4.addr = "192.168.178.201"; # avm integrated wireguard
          wireguard = {
            pubkey = "eQXHytFmxA8HyECId+vVaTOVE9iCaWV7KVGs5ps6glQ=";
            networks = [ "192.168.168.0/24" ];
          };
        };

        tailscale.ip4.addr = "100.121.61.124";
      };
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM8kcXGoM6iZJy6Q/EHl+i2oXvMvzepeilNqM9a/otYu ";
      borg.quota = "10G";
      borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPzI7RRxol+dp3oj+IVZcwc2F9du6AVZc2HtFoLhDDV";
    };

    # fb1: 192.168.178.1
    fb1 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.57";
          aliases = [
            "fb1.nw"
          ];
          wireguard.pubkey = "Lb8YbkDPg7ceSpba5jmgEKIbTswWWlngKttylhPgfW4=";
          wireguard.psk = true;
          wireguard.endpoint = "xx625i9umx768rfs.myfritz.net:55542";
        };
      };
      # borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAedN5tK3x6WeDX1uWjdpzvTeFxUfj/gkjzmXsO4a5GF ";
      # ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAmFFLdagMiRdvDEXh4cMPoDNoomJb4uq1Rq6SKBNhAW ";
      # syncthing.id = "2AADVPK-KFYRXRI-VFVXNQP-HT24VE7-AI7DPIW-EWT5Z2H-CNEDSD2-NE43OA2";
    };
    # fb2: 192.168.178.2

    iph2 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.33"; # Lu
          wireguard.pubkey = "BJD/QMJ/hF2opW+tVGYFjdY14+y60QQQlP6X5bdgK1w=";
        };
      };
      syncthing.id = "3R7SFB7-A3EV77C-ACD4U32-CB7GWDB-DSBWODH-ENVTZN4-TL2EL2N-M3YCZQ7";
    };

    iph3 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.44"; # 12 Mini
          aliases = [
            "iph3.nw"
          ];
          wireguard.pubkey = "F//4NrmUWnSFTTIMSG/6iQAi50Yc4rVVEA3M9JBRfHQ=";
        };
      };
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGJjBtV0lwSjIvGRIyBcF3YfAdvlIURTp0xWJxcKZ83b ";
      #syncthing.id = "SCFQ5CF-6VROBCX-HHYLBCJ-E3YYBOT-4NXQAQT-2CM5GXP-GBSIDWG-KGS3BQU";
      syncthing.id = "RRBOULJ-AM7RF5Z-XMJFALR-UDOUMSR-UQ5TZHK-EDJOHSL-NP4XWVR-4FOBUAU";
    };

    ipd1 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.38"; # Enno
          aliases = [
            "ipd1.nw"
          ];
          wireguard.pubkey = ''
            JgZZ9Os5M/O2B+b5GaajcfV01wj8nTByoUdhF76yNiM=
          '';
        };
      };
      syncthing.id = "VVL2XGW-QHONW4N-LLLU7GA-LZ3SFE2-VEOQE2V-AWDX3QM-CYBIOON-PDPJEAV";
    };

    ipd2 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.40"; # Lu
          aliases = [
            "ipd2.nw"
          ];
          wireguard.pubkey = "+i2sgu4OY2p5J5qO8N8Ritr8ySPyYqSeQayyEx9cBVc=";
        };
      };
    };

    htz1 = {
      domain = "nn42.de";
      nets = {
        www = {
          ip4.addr = "159.69.186.234";
          ip6.addr = "2a01:4f8:c010:1adc::1";
          aliases = [
            "git.nerdworks.de"
          ];
        };
        nwvpn = {
          ip4.addr = "191.18.19.32";
          aliases = [
            "htz1.nw"
          ];
          wireguard.pubkey = ''
            UeAoj/VLCmoWLGjAkFRXYLYeac/tLM2itmkq4GKz0zg=
          '';
        };
        tailscale.ip4.addr = "100.106.245.41";
      };
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPYs2VSLe3WazR2xKDPx1yv3kkSVNlAWTh8bO4WqOTJu ";
      borg.quota = "10G";
      borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINYICIA6R9ydw/GSfL1ZyHy7BJqAKRmmi2nQmoCFO7eD";
    };

    htz2 = {
      domain = "nn42.de";
      nets = {
        www = {
          ip4.addr = "116.203.211.215";
          ip6.addr = "2a01:4f8:c2c:b468::1";
        };
        nwvpn = {
          ip4.addr = "191.18.19.36";
          aliases = [
            "htz2.nw"
          ];
          wireguard.pubkey = ''
            dLfyCkEPM2bDwcO2JEYBv772dXX+JM6bsnSpttaN0gs=
          '';
        };
        tailscale.ip4.addr = "100.72.221.108";
      };
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC8oMXFMl21K1NNVQJpjgY8TAJb0qGZ9GmL6H+aZqDbq ";
      borg.quota = "40G";
      borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiChsC/0G5VMstNm5tGr/m0T6+ELGXDBzuGjEERO/jq";
      syncthing.id = "N75EGVO-QHGB7RL-FYI2GH3-QFTLVIT-EIWXV2D-JDAYHXI-GXJWKHK-4C74HQ7";
    };

    # Fraam WWW
    htz3 = {
      domain = "host.fraam.de";
      nets = {
        www = {
          ip4.addr = "78.47.98.124";
          ip6.addr = "2a01:4f8:c0c:5dac::1";
        };
        nwvpn = {
          ip4.addr = "191.18.19.41";
          aliases = [
            "htz3.nw"
          ];
          wireguard.pubkey = "GXkobxcjA/HiURqcFonxNronh5P9m4Ze7g27oiPbOBc=";
        };
        tailscale.ip4.addr = "100.85.77.18";
      };
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFRtD/G7EoOsriINw1hbRcx3Pa/gAllVbyaXFoEE3O0r ";
      # syncthing.id = "IC6TOSI-OYORQ4W-DSOMJU7-QYSECNO-XFD2F5U-DMN3G4E-D2E5CZ5-5XR7TQM";
      borg.quota = "20G";
      borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEC8cOA1MLntU6B55MLu1rgLMI/jmC2iffRQT2ySmM1m";
    };

    # Lu
    mb3 = {
      borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN1I2tWffmioOtFbsc/t5iuxOVJ8IZkrHTfkvkSw+dTJ";
      borg.quota = "300G";
      syncthing.id = "HG55JUD-HYZEYV5-7TJKT2W-STGV4R4-NXYTCU2-ATJUV2C-GSK7ICF-TVXWOQO";
    };

    mb4 = {
      borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZ6hB+Qs1yKat2Bz6gweo6yOotHVz+z4bi1hrfhgRVC";
      borg.quota = "1.3T";
      syncthing.id = "BCJ2QQN-P4JUP5E-NS5AUOL-MDQH3XF-CHQ76SE-V3QCNZ6-QRDMENX-UUNBTA6";
      nets.nwvpn = {
        ip4.addr = "191.18.19.58";
        wireguard.pubkey = "b0sBX64Klpglf7DKmQ8rcQCs3rCZMrxuK8NAoLVV2gQ=";
      };
    };

    nas1 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.37";
          aliases = [
            "nas1.nw"
          ];
          wireguard = {
            pubkey = "52uBY3v3s7JE74MRVLepEx8vQliKCpzZteGXG0EhNGU=";
            networks = [ "192.168.178.0/24" ];
          };
        };
        bs53lan = {
          ip4.addr = "192.168.178.37"; # ip hardcoded for scan-to-ftp on prt1, remember to update as well
        };
        tailscale.ip4.addr = "100.101.207.64";
      };
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPzSELiOpE3nCNPSeylax/W3UfXbzSBVQ3mqjHBz/yPy ";
      borg.quota = "500G";
      borg.pubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2g2ga5+52k9vQwbX204VK+ZXEb9dIhbicRe1bZXunDS00MI/kvC1NnLrKpZSJmtieyRBSnYkWkWsejFMKe9TWuTQqd5wceFIASr7bUVInoxQazpYaC07H4wkx1uoeKZqCvQfJD/BCIrPQfXnm8lOwMPWKhAml0wnOPo3EOIFffW5vszxi2RRRLh4af1Azs2pd6/9E+TJnA4foOTgAA1dQEou1X+0eLCEtEwjJFPLNFRVOImXfB4dZ0mke/WTae5DUfUuT4Guz0uf11VYeG1iCorcOLk/0w+LcP4aJMllK3znXQHc/Olm+Og+l4MpRsJTZRke23k+GSgf31BPbvGJJ root@nas1";
      syncthing.id = "HGJGPWK-AZ7W6YP-42W6HGC-4OD3U33-GQZJ6N3-24YL7V2-CB26CIJ-DT5RXAW";
    };

    pine2 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.56";
          aliases = [
            "pine2.nw"
          ];
          wireguard.pubkey = "kIsdr5zQZZ4/a57L34usMp7iDerpFnhso1iJZULYeB0=";
        };
      };
      borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII3m3FVgXDnF1tvbxxjHUbuMUWC9apNz9+ik/dFeRHGW ";
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIe64IM1iczrndEOxXnS3u2wLK+PL/BxYfLzNca8uEc/ ";
      syncthing.id = "6PLUM7O-R2WRQ2B-7VXR3U2-MTFMAD2-4W64UYE-D6LOYA6-VO53HK2-MEYKMQH";
    };

    rpi2 = {
      # DLRG
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.35";
          aliases = [
            "rpi2.nw"
          ];
          wireguard = {
            pubkey = "BoZpusHOB9dNMFvnpwV2QitB0ejJEDAhEUPv+uI9iFo=";
            networks = [ "192.168.178.0/24" ];
          };
        };

        dlrgvpn = {
          ip4.addr = "191.18.21.35";
          wireguard = {
            pubkey = "BoZpusHOB9dNMFvnpwV2QitB0ejJEDAhEUPv+uI9iFo=";
            networks = [ "192.168.178.0/24" ];
          };
        };
      };
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDQw7ZYiuLCgx6ISk5GdrNBLg78HTstQapro/W7nodyV ";
      borg.quota = "2G";
      borg.pubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0ZTIne3ZVSxS+Xm4yef7gzF/rzHeR2I163x43ZsTU0cHrtQdIckZNZhohTVx+moeSj1hKewWZvIedUllxu3EdiuIFai8xQXtLys62fjHfIP69VBeOcTpWfWm8r8cLUoTJJ19Ll8IRBofruywPjkUkBeSIfEHCX8rZoQaSQkKSixOg5cKr5Fbl0lBmRtJGk/NxFZxoJ61IIoLzihErmA7wK6ZCUA3EbY5SCm7g66LAHjNIJa90VGhAHQnlDLhR1YSkHPmd13FJawhgId8Smipvs9SZNniZsKiknfi2IMxbpu6qXMYwiS9AMqUtpEDYrsq5+T+hZEWo4ArBu/FPtX25 root@nw35";
    };

    rpi3 = {
      nets.tailscale.ip4.addr = "100.88.111.60";
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMnXf+pWWQfw1YWbypUX6Dm/JQXaEbWrUlOWdz5JYngN";
    };

    rpi4 = {
      nets.tailscale.ip4.addr = "100.122.164.57";
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPfSkbsHju/PLP527ghKEn/YlSHY8I8Y1fXVSkmUnLEE";
      syncthing.id = "EXAME75-EMFDX7G-VXRB2GS-T2JLHXO-LEXTXGX-6DXSPGQ-E3FS742-MVRPZAX";
    };

    # Archer C7 v5  192.168.178.3
    wrt1 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.53";
          aliases = [
            "wrt1.nw"
          ];
          wireguard.pubkey = "tKU/Y7nCTzg1fJ8CI9VZi1P9GbX/JUr/5gZIEcjh3zQ=";
        };
      };
      # borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDmvuyIVtiPWjC0j7k8YTQo4X/kUSAT3YLPHxPg/liPh ";
      # ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbb6WUxXAkOyHZCNmFZzm/Fd4pjf6F9MRqyxcRBFnLg ";
      # syncthing.id = "XS3GEDA-BNG53H5-ZRVSAGT-3I5BGZL-VRZI6S7-2E64NHK-TKDXYJT-UKKSIAB";
    };

    wrt2 = {
      nets = {
        fraam_buero_vpn = {
          ip4.addr = "191.18.23.45";
          wireguard.pubkey = "edW3MrRctb1Yed5fHRiSPcDMdvCU/zZpLG1CBqiFY0k=";
        };
        nwvpn = {
          ip4.addr = "191.18.19.45";
          aliases = [
            "wrt2.nw"
          ];
          wireguard.pubkey = "edW3MrRctb1Yed5fHRiSPcDMdvCU/zZpLG1CBqiFY0k=";
        };
      };
      #ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPsWy/P+07j1BCt/y7mIHsxCf5p58fiyLLM2gnrjXDn7 ";
      #syncthing.id = "JGZOJNY-YNPRJSK-OMQ5BPK-S3RHB55-SI4OSZ3-XEYCKBL-CCJKYX2-NVKAUAQ";
    };

    ext-arvid-laptop.syncthing.id = "KLWJQ4L-WCFCZTD-UE4BPVY-46BDBAW-QPYX3MC-OORAN6R-FXDVQ5P-NK5K4AC";

    ext-susann = {
      nets = {
        fraam_buero_vpn = {
          ip4.addr = "191.18.23.54";
          wireguard.pubkey = "Qmk8C0TomZP8ubRCztAIn9adfFY6J47pzKTvPWoL4GQ=";
        };
      };
    };

    rotebox.nets.tailscale.ip4.addr = "100.110.205.110";

    matrix.nets.tailscale.ip4.addr = "100.73.35.23";

  };
}
