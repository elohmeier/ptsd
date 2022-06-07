{
  hosts = {

    and1 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.21"; # Moto G
          wireguard.pubkey = "40c+WrVo8IXU+OMA/+6Z4otbtePu0vtucafyfQ4+YAo=";
        };
      };
    };

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
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM8kcXGoM6iZJy6Q/EHl+i2oXvMvzepeilNqM9a/otYu ";
      borg.quota = "10G";
      borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPzI7RRxol+dp3oj+IVZcwc2F9du6AVZc2HtFoLhDDV";
    };

    apu3 = {
      # SVB
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.47";
          aliases = [
            "apu3.nw"
          ];
          wireguard.pubkey = "rZ3/TTTxZCIHqRP8+s9yyGgh8PV+4XL07WhC6pubrTs=";
        };
        svbvpn = {
          ip4.addr = "191.18.22.47";
          wireguard.pubkey = "rZ3/TTTxZCIHqRP8+s9yyGgh8PV+4XL07WhC6pubrTs=";
        };
      };
      #borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGQksFDH60CvwLh6mBkMqMpjH+CG5yzt1wvwWGSF+clI ";
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIER5LHYQ/MckDcnay4ZU8WLlkPwKubOX7tSWw8mbpyKB ";
      syncthing.id = "QWH3PPM-K2IUQWD-5ETD5UZ-JNBNST5-YAC6623-Z3346LS-EBGIUFP-IHECRQD";
    };

    # fb1: 192.168.178.1
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
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
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
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPYs2VSLe3WazR2xKDPx1yv3kkSVNlAWTh8bO4WqOTJu ";
      borg.quota = "10G";
      borg.pubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhkj8G0uPZfmAcr3jHZ06w6omMUtPYQpNCJNwdm7bFF6sDpUzabkN7pUm8mlNQhX3ZxDcqCyi5sK3IgSh2Ii0RaVL4e3JidJXo86e9QxSnNxx4AYI2BFnEXjLk5U8n5/vsE9xCpf3K7/6EwkciFzE1dKUxbiHiHM4Q+RcNsYCyH8sJQ9qHNgy3g76USmMn6h8NO149xpkEhRFrPaJO4v/oc1vObuEVhtcBHYB1CpUDEjhlM2ohwlE3KtZgOllxPfkSTGr/fom4JUZhbTvbXEI2inm6IzHBgfSViNvj7St/kh0pHTDlSImRhWkj1UATkpP87TgJgut99OjZPpx/JHsZ root@nw32";
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
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC8oMXFMl21K1NNVQJpjgY8TAJb0qGZ9GmL6H+aZqDbq ";
      borg.quota = "25G";
      borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiChsC/0G5VMstNm5tGr/m0T6+ELGXDBzuGjEERO/jq";
      syncthing.id = "WYSYYAE-AKYEVZX-Q5TZWDH-JMF2IKQ-E5UT5MC-4LD32VA-ENUC3UJ-YMDS2QD";
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
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFRtD/G7EoOsriINw1hbRcx3Pa/gAllVbyaXFoEE3O0r ";
      # syncthing.id = "IC6TOSI-OYORQ4W-DSOMJU7-QYSECNO-XFD2F5U-DMN3G4E-D2E5CZ5-5XR7TQM";
      borg.quota = "20G";
      borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDFd67n+vkojWj5gxGjOrflLLVC4yPxbHmdc6tIQTQbZ root@htz3";
    };

    # SVB Wireguard
    htz4 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.50";
          aliases = [
            "htz4.nw"
          ];
          wireguard.pubkey = "j9KtrJslyEtamuJndSoarUtYSfSPa7Gnb1lYMuHeh18=";
        };
        svbvpn = {
          ip4.addr = "191.18.22.50";
          wireguard.pubkey = "j9KtrJslyEtamuJndSoarUtYSfSPa7Gnb1lYMuHeh18=";
        };
      };
      #borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIATiX3dPvDYW/jbEBCP5OxT2ZBjMGtDQYFWlyeJpYqJO ";
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICc6Kd9LqfN5xxSrYfR+Gb9/bg59icErD7zxkseX+Ewi ";
      #syncthing.id = "4SFYF5A-W5GKBI7-3CNSB2B-CUEZP4F-W3WLSFO-X6X6ZYY-TBCG3AD-ZXBXYAL";
    };

    mb1 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.1";
          wireguard.pubkey = "tX3ZcAKc1WB/U7m6N5LQADcloBGCpeo55O3Ad/nEMjE=";
        };
      };
      borg.quota = "250G";
      #borg.pubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDlR+65fc6NMQxLSs9ubMYDbMlLuunlFrfoXAzw71ZmXprn2lk3KgSr1Qy8KRMoKLhT/UcnDVQaUhBn76XsxbeBcW4d/E0uoSrTSU5c5+iUY4bbjV+53vHwLawxplyQMpeEDybXYqMoFwS+lcskWc6MPWgeTcZRi0WLyXZ/juSMrjkt0GUOzeLZHMTnfqikJsasuOCN10FP1bufMfDAOyMnp+9EZVxORCoE9hKhnSHa6pBupuL2ZmI94/SZBM9h05WNClD0ALaWQtAHyHBxC+W4eJ2SyvqXfXzXu9iD6y9JQOv5TeztmB95NmHDkrf0LiLao+QIkEJwbJbDhsBrIcw1 enno@nw1.jtor69.lohmeier-gruppe.de";
      #syncthing.id = "UTCDUPE-ZYG4TR4-U7R2PNO-XCFIQEI-YQTLNLX-PJPA7SO-IFEGARK-LZVUAAD";

      # generated 2020-04-11:
      #ssh.privkey.path = <secrets/ssh.id_ed25519>;
      #ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDbpnk4YS5w51xA5TlwkZXDLa/NpfnrBrr2GJ8lr7dO2 ";
      #syncthing.id = "SLWUTIH-5EBKWLM-YHV2AIW-VVTP2WJ-TQEV3SK-AV7LIWO-DEISQOR-HHKRWAE";

      # Lu 2020-04-13
      syncthing.id = "ZA4UDHV-NW5LOFF-55X6MKU-IWRBHZP-RLS3AHK-OK7IKIP-ULUSVSE-4EONVQ6";
      borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJqrrWnc5yZeE6cBSETtBLi4Zee5tZe7AA3P0ZuDsW75 luisa@mb1.host.nerdworks.de";
    };

    # Lu
    mb3 = {
      syncthing.id = "HG55JUD-HYZEYV5-7TJKT2W-STGV4R4-NXYTCU2-ATJUV2C-GSK7ICF-TVXWOQO";
    };

    mb4 = {
      syncthing.id = "BCJ2QQN-P4JUP5E-NS5AUOL-MDQH3XF-CHQ76SE-V3QCNZ6-QRDMENX-UUNBTA6";
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
          ip4.addr = "192.168.178.12"; # ip hardcoded for scan-to-ftp on prt1, remember to update as well
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
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

    rpi1 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.13";
          aliases = [
            "rpi1.nw"
          ];
          wireguard.pubkey = "XLWYA662V7Nki+Y3XFv0SwuIdcEX4971M2VHGfy7vQg=";
        };
      };
      borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO1zsBwsqn5wFRUvhheLRY0tGph2zka6jWN4AR6lw/ol ";
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIeWY71r2ca5O+HH5Zqk2o9Xu0wZfVSFWnaLSC6BExR1 ";
      syncthing.id = "2UYTNUI-HEJ7Q2C-RNP424P-AF3SXFJ-2BU7WDO-PIOBR7C-P4GNFH4-LUJPYQ5";
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
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDQw7ZYiuLCgx6ISk5GdrNBLg78HTstQapro/W7nodyV ";
      borg.quota = "2G";
      borg.pubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0ZTIne3ZVSxS+Xm4yef7gzF/rzHeR2I163x43ZsTU0cHrtQdIckZNZhohTVx+moeSj1hKewWZvIedUllxu3EdiuIFai8xQXtLys62fjHfIP69VBeOcTpWfWm8r8cLUoTJJ19Ll8IRBofruywPjkUkBeSIfEHCX8rZoQaSQkKSixOg5cKr5Fbl0lBmRtJGk/NxFZxoJ61IIoLzihErmA7wK6ZCUA3EbY5SCm7g66LAHjNIJa90VGhAHQnlDLhR1YSkHPmd13FJawhgId8Smipvs9SZNniZsKiknfi2IMxbpu6qXMYwiS9AMqUtpEDYrsq5+T+hZEWo4ArBu/FPtX25 root@nw35";
    };

    #rpi3 = {
    # RPi-HomeMatic      
    #};

    rpi4 = {
      # RPi 4, KVM
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.42";
          aliases = [
            "rpi4.nw"
          ];
          wireguard.pubkey = "uDl6XZq9Fdld0VPp6vRPpaexoV4rBmpqK3hlDTSenmc=";
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPfSkbsHju/PLP527ghKEn/YlSHY8I8Y1fXVSkmUnLEE ";
      syncthing.id = "7BIKFUR-AV4WN5J-UGPEVCW-2W3MNDP-AKNHCFJ-6LZABHY-KKICNRF-CMVDHQF";
    };

    rpi4-raspbian = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.52";
          aliases = [
            "rpi4-raspbian.nw"
          ];
          wireguard.pubkey = "GRdTVaSXOVLTLRGy3kvA8+CAnolD3wHQIajXlQqBnCg=";
        };
      };
      #borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkQvZfYfhJ/NglEuHVIDFaJKuDIMYziO6BQqiOl5b+/ ";
      #ssh.privkey.path = <secrets/ssh.id_ed25519>;
      #ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK1TBjIy5NiktNEnZv4Zp5btRuZZlKzEh6hZEdvEztfr ";

      #ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICaUCru8yO/jnBrJDaFfw83/I5pcBRIorVFgZwT14vnA"; # raspbian
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXGVhKcu7EU6DsSm8un8DBTqz+ElIDhvB1jHnUmApnt"; # pikvm
      #syncthing.id = "ZWP5S3V-O6T4AAV-LFD63E3-Z36YHGW-TVL5OMC-WZT4W5B-BX7PXPC-J3YSDAG";
    };

    rpi5 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.49";
          aliases = [
            "rpi5.nw"
          ];
          wireguard.pubkey = "7CgaFlxQVgnRILH8JQzc3j+NPAAbxHatiuim8Q0CLFo=";
        };
      };
      #borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII3ImbGIgcGl4hSSD0mYvvmY50K9rr91Mk25kxilj3el ";
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBEoHcMO5Nb/CyRvVoVYNBvWwsld46XeNQwTGmiMZCnb ";
      syncthing.id = "Z2SFNXE-YJML4D5-6EWCHIT-T2IXXSN-Z7WO5BM-UU7IHUF-JAFB3TX-XKLALAS";
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
      # ssh.privkey.path = <secrets/ssh.id_ed25519>;
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
      #ssh.privkey.path = <secrets/ssh.id_ed25519>;
      #ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPsWy/P+07j1BCt/y7mIHsxCf5p58fiyLLM2gnrjXDn7 ";
      #syncthing.id = "JGZOJNY-YNPRJSK-OMQ5BPK-S3RHB55-SI4OSZ3-XEYCKBL-CCJKYX2-NVKAUAQ";
    };

    ws1 = {
      nets = {
        fraam_buero_vpn = {
          ip4.addr = "191.18.23.80";
          wireguard.pubkey = "yvrstaKyRf0fyJi9BpGWkL/BWt6XYArIzygJ410SxR0=";
        };

        nwvpn = {
          ip4.addr = "191.18.19.80";
          aliases = [
            "ws1.nw"
          ];
          wireguard.pubkey = "yvrstaKyRf0fyJi9BpGWkL/BWt6XYArIzygJ410SxR0=";
        };

        dlrgvpn = {
          ip4.addr = "191.18.21.80";
          wireguard.pubkey = "yvrstaKyRf0fyJi9BpGWkL/BWt6XYArIzygJ410SxR0=";
        };

        bs53lan = {
          ip4.addr = "192.168.178.218"; # DHCP (!)
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxl5cu7JzupBVvcuT7hpAD2aPqGCDDV8ergHqeFinem ";
      syncthing.id = "463IXFR-CH3QL6E-REW64TF-JMGOCZX-VQN556L-MGWC5ER-CQFSW3B-7XLZ4AH";
      borg.quota = "210G";
      borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEf6ThFU/I+qMVM/u5iNPB1Fgkn4Pk/Rr/FgzuHJAKy/ nwbackup@ws1";
    };

    ws2 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.51";
          aliases = [
            "ws2.nw"
          ];
          wireguard.pubkey = "0i86gpKz0Nz04opoNB+uyAAuoiODP36+S8TMy/hSVDM=";
        };
      };
      borg.quota = "100G";
      borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIOxp2UyjSlvBURKKvspgwYtBQb6+F7ufhzRQN7gZj5 ";
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDaApGIjxRh3py4cltezsZt7s6Ph+UI1ZxXhk50vx0eb ";
      syncthing.id = "UUPA6QV-KGYMQ7J-EK3WBXK-JBTAPS4-AB2XZZW-FPD23UP-NHYTQBF-TU56LAF";
    };

    ext-arvid = {
      syncthing.id = "Z7HYCDN-UQA4KQC-ZW6M4QG-2FQ3VVL-HPVIQYB-26OOJZM-2TO7FVN-OXKFBQX";
    };

    ext-arvid-laptop = {
      syncthing.id = "KLWJQ4L-WCFCZTD-UE4BPVY-46BDBAW-QPYX3MC-OORAN6R-FXDVQ5P-NK5K4AC";
    };

    ext-stefan = {
      syncthing.id = "LRSIJOJ-VDYM3PR-RULNIWS-LFP4NO5-ENQNAEK-BMFLTVH-VG6BVCI-EJ27KQV";
    };

    ext-susann = {
      nets = {
        fraam_buero_vpn = {
          ip4.addr = "191.18.23.54";
          wireguard.pubkey = "Qmk8C0TomZP8ubRCztAIn9adfFY6J47pzKTvPWoL4GQ=";
        };
      };
    };

    svb-win1 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.48";
          aliases = [
            "svb-win1.nw"
          ];
          wireguard.pubkey = "qc0RF8c8jKAuchPk8eaGTVCI6E2GLXpeJ4Y3XKQg/jM=";
        };
        svbvpn = {
          ip4.addr = "191.18.22.48";
          wireguard.pubkey = "qc0RF8c8jKAuchPk8eaGTVCI6E2GLXpeJ4Y3XKQg/jM=";
        };
      };
      #borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAuJNimfNjw0QE4BsPW9QR0sHMHkL01GydAjrTnSN5KT ";
      #ssh.privkey.path = <secrets/ssh.id_ed25519>;
      #ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMuP9fEqxESCd0b3GO1mKkXQo9mbUrql/W0DFMGLjtsa ";
      #syncthing.id = "RCLLB5S-G5WHIGJ-ZJYXKMQ-W4PE7JJ-LJBM7E3-HEGZOX6-MPQXCYB-S6NNHAL";
    };
  };
}
