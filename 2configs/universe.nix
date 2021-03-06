{
  hosts = {
    # fb1: 192.168.178.1
    # fb2: 192.168.178.2
    # arc1 = {}; # Archer C7 v5  192.168.178.3

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

    apu1 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.11";
          aliases = [
            "apu1.nw"
          ];
          wireguard.pubkey = ''
            t6zE4F6k5PjaSyUU69iDJbK3eVXy+7jgeSuV2+cfGWA=
          '';
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEoUyEnCGv00sy4Zzul1XdF/6CMPg4Z4BMcJ3RSJ89Eq ";
      borg.quota = "10G";
      borg.pubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC85A+mfN5Y8JpGWG70XHbcwWOMConaiN4avmC9oLwsevT9RzeQjhCOjBs0Qw2ES+wfcuUfIOuYrC80A94dmCakL6EtIJAiWRp0fcP9Bh/kwVZJCv0rBQh9Sk/wCJ9N849CH0R1AKTXf74WlS7TGcqka0KLNhiT/tsM8aOkKcC135eQ7Hn2u9uzI5ZHoyIb6dl7oEyg5MgY9arr59VojBg6J6MTsdCUfv2muJQR4+aGd0/UBWnYgmfsHZnOGUvzk9qBwZN7zJrEcD2sTgROPlmnYm65xsM4l2G9soQ3S8N4bnF3pejgx+rMm0eKjMGI/RZ2IhAIUJAFdTZaj3Ule+81 root@nw11";
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
          wireguard = {
            pubkey = "eQXHytFmxA8HyECId+vVaTOVE9iCaWV7KVGs5ps6glQ=";
            networks = [ "192.168.168.0/24" ];
          };
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM8kcXGoM6iZJy6Q/EHl+i2oXvMvzepeilNqM9a/otYu ";
      borg.quota = "10G";
      borg.pubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKmKohBpSvpZE8UJHhE0sh1bNedclcMfx4vrRt5x2BbbYqZkaDi8XgV0MN4YccsAUE4zBypsMflWy/gsCSowc0VuOwuvpz/+NIg2NQLsvgkcdszLNQG7Ikuj7E9J1dXfWzpDLL9ZCRToCAuwfC8H/3oNLfMSI/FmtfFyBOPQt0i+PzDSpNh/vW+zrBSWxRaaaXJc9JXh1xVg0AeyhtyfQAi9SLCECmLRZ/aDWGWu/41DgQQbMvUfSPYM38Z8s817g/QHnHvb+JLjULr7otOWUE69VvEHsWSWwkLr+wouvZP9ExDrEm7vEL6wcJiV3MdJKW1ziKIJ7NbfFDVYTiYW/3 root@nw34";
    };

    eee1 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.31";
          aliases = [
            "eee1.nw"
          ];
          wireguard.pubkey = ''
            GRjSScIwM2VBYpLkl5L9iThvJ2YNYiNWZPBND9eniBU=
          '';
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrj3IURmrKLMUZrFFlENJedliTcjzvZrJiJUbSskVIH ";
      borg.quota = "1G";
      borg.pubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCcoNHjJHYPe7YVeBhLoSFrP0hkwwS4eXqR569QnHWXoijO2R+neAkiaxnQ+dgKidWhv8ek0EfIOjV/dLhjfrhlKH9P9QCueQl7OsAzLza8khmbjQ2N4dEwPj3w9axzFJKzipMRxgJeHSlAUWxOQKiiuyIB1QqOEczCz4nXw+h3M9VZhzhioKC0CTiGOuhcbAn6HRzDc55D/ved5nw0f3Gl/xJf7vQiNxepYuLRU72CDdL8+H7WLAJTdxVaR0Oyj4xSC7xfCzaw1qUPb/2hbHVcFuR8BZsHaYd0O/PbBqP8zmq2kkCmIZFzkhdhlVUXm8nS1VuiV5FfSa/GEBMahLnl root@eee1";
    };

    iph1 = {
      # 8+
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.15";
          wireguard.pubkey = "xs4hm1bIlQ5eB5JsjbVetOvsJZ8MSVO8jSQgIpcJcy0=";
        };

        dlrgvpn = {
          ip4.addr = "191.18.21.15";
          wireguard.pubkey = "xs4hm1bIlQ5eB5JsjbVetOvsJZ8MSVO8jSQgIpcJcy0=";
        };
      };
    };

    iph2 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.33"; # Lu
          wireguard.pubkey = "BJD/QMJ/hF2opW+tVGYFjdY14+y60QQQlP6X5bdgK1w=";
        };
      };
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
      syncthing.id = "SCFQ5CF-6VROBCX-HHYLBCJ-E3YYBOT-4NXQAQT-2CM5GXP-GBSIDWG-KGS3BQU";
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
      borg.quota = "2G";
      borg.pubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDzkkNcPp0uXsZRsu2hXu2h/LfeOffvwldQT1XweECjV6MR0+fDcJnJrTHcRmBxxWBXlOhV6skCJFW711qoknzW+3tHTpHbzrBLI/hFXjH2eN7Bxb0kObNwl6vAWv7zhvjOVJ5pRPnDkChiJ8AJczgS8Natt9R5J0BPrMi47QCmsuh5K8Qig43gf1HXulSLbfQ1vo429B5aSFXqszJ9Ma7muHjHxOQYnj4Hn3fUoYgdggQvUTqq/WQR8VYmh8cb28iTbNvRbq3lgxT0Wah4CcBn11ozMgDKL1g+H2kmLjgywmdMGm9sbm0efHEi9BaWbx13aoz1LiOruss0UFUyk/rf root@htz2";
      syncthing.id = "WYSYYAE-AKYEVZX-Q5TZWDH-JMF2IKQ-E5UT5MC-4LD32VA-ENUC3UJ-YMDS2QD";
    };

    # Fraam WWW
    htz3 = {
      domain = "host.fraam.de";
      nets = {
        www = {
          ip4.addr = "78.47.98.124";
          ip6.addr = "2a01:4f8:c0c:5dac::1";
          aliases = [ "git.fraam.de" ];
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
      borg.quota = "5G";
      borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDFd67n+vkojWj5gxGjOrflLLVC4yPxbHmdc6tIQTQbZ root@htz3";
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
          ip4.addr = "192.168.178.12";
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPzSELiOpE3nCNPSeylax/W3UfXbzSBVQ3mqjHBz/yPy ";
      borg.quota = "500G";
      borg.pubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2g2ga5+52k9vQwbX204VK+ZXEb9dIhbicRe1bZXunDS00MI/kvC1NnLrKpZSJmtieyRBSnYkWkWsejFMKe9TWuTQqd5wceFIASr7bUVInoxQazpYaC07H4wkx1uoeKZqCvQfJD/BCIrPQfXnm8lOwMPWKhAml0wnOPo3EOIFffW5vszxi2RRRLh4af1Azs2pd6/9E+TJnA4foOTgAA1dQEou1X+0eLCEtEwjJFPLNFRVOImXfB4dZ0mke/WTae5DUfUuT4Guz0uf11VYeG1iCorcOLk/0w+LcP4aJMllK3znXQHc/Olm+Og+l4MpRsJTZRke23k+GSgf31BPbvGJJ root@nas1";
    };

    nas1-drone = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.43";
          aliases = [
            "nas1-drone.nw"
          ];
          wireguard.pubkey = "uFM+8UBkuBH5ZB+uJ0F/cOsihzNDdW0QydLwxgMIrjM=";
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBKcgKKJ3qYg1yDlfFZ/TJgB+4QFvAplGtd9cXJWMie3 ";
      syncthing.id = "QJMS5H5-ZPQ4QXO-OWCNW6J-D5GV2OG-3OSD7PP-PI3EXHO-5GE7JQP-4JKFHQC";
    };

    nas1-st-enno = {
      syncthing.id = "2U7PBTB-3AVWHDO-KKITN5S-JW5AKLX-2MLBQOR-PJDL2QH-BZZJBMD-DFX3MQI";
    };

    nas1-st-luisa = {
      syncthing.id = "HGJGPWK-AZ7W6YP-42W6HGC-4OD3U33-GQZJ6N3-24YL7V2-CB26CIJ-DT5RXAW";
    };

    nuc1 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.10";
          aliases = [
            "nuc1.nw"
          ];
          wireguard.pubkey = ''
            dcBlwkidRDhcQT6OaqZS1wM9jUMdWS7iZy8+1534hDw=
          '';
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ4xuAXx1Vjcseg5mvoSUt2MijZbSSwTsq/sD2OmU36a ";
      borg.quota = "500G";
      borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHGCCbyjVl+9cXTyF4VNAdveGxEUM6Lgmw3orKQKm7i/";
      syncthing.id = "J5JHNBN-YZYVP3A-ROFYSWJ-NIWXSUW-FDSGNUB-6UO47NL-LIGRLDM-RMSZBAQ";
    };

    rpi1 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.13";
          wireguard.pubkey = "DtNG2BXRCww/p140Cpme4UyE5ZTAxyh0fMi9a9lplHs=";
        };
      };
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

    tp1 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.30";
          aliases = [
            "tp1.nw"
          ];
          wireguard.pubkey = "y6NCfYWUCR6aqoLsjqQRbfhz7rLqrtUOnY3HTWa0HFI=";
        };

        dlrgvpn = {
          ip4.addr = "191.18.21.30";
          wireguard.pubkey = "y6NCfYWUCR6aqoLsjqQRbfhz7rLqrtUOnY3HTWa0HFI=";
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOhX8m3f1fpboga+H/uZeCUawyqur2dNBZwK6+ZaAlj ";
      borg.quota = "30G";
      borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQxSpwUFYS2KFZSolG2zAWZdrLA3EMbr3zJpzG2P+vr nwbackup@tp1";
      syncthing.id = "MQ7BT6T-BLL6LCW-P4RGFQC-WGJIM2U-2X3267C-B2IZPUR-JDPTV66-OXGR5AA";
    };

    tp1-win10 = {
      syncthing.id = "MWJZUVD-RGYIRRT-ROVVL2D-Y3S7C2C-YHIPUOT-CAECKLE-IVQ6DM4-U5EGOAZ";
    };

    tp2 = {
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.46";
          aliases = [
            "tp2.nw"
          ];
          wireguard.pubkey = "Z4QT9Fv/kssnRA0BXpuxrGjZSitZuJj7Ayw9TF7tcTo=";
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKkZ1myk87h5Faeqx34o8k8K2Rvslz4KpNATnTt6Z4ys ";
      syncthing.id = "IPFOZJJ-EZNHJZY-QHHD7HF-DW2EPT5-LCHCQBO-NOVVAE2-5LLPJIC-BTNC5QN";

      #borg.quota = "80G";
      #borg.pubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZtjfzDqnTVFhvv8PcwNka8QNZpBsDgWd7jdJTwANyzCAEMGEeKkK2GtVafgvewrm6FHxc2mYvFiQGSNz8nsPHMBIOP4Y3vc6olswZo3uh3Cvpqda8JDljhihECkBo0G6q+Zy3sayBrz6evKLh3yCiNYPAxSmfcEFZExbFVbUBcfkLxYvTc3WvZ4/YWwNUvMPoqQacP05eu5v2OWMPhleh616Hvr3aTLTjG4gsVbp5htHXX8CsfKjFnVrDZ0UcgmEowrCwiO7YCrjpieFrGLa+aMuUH4ehFGyJnjNB1DMT3bzvaZFNkcysiPyVmbZCX9IaOI6CfJoCibu2lMDGOdOP luisa richter@DESKTOP-7EM0MN5";
    };

    wrt2 = {
      nets = {
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
      borg.quota = "150G";
      borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEf6ThFU/I+qMVM/u5iNPB1Fgkn4Pk/Rr/FgzuHJAKy/ nwbackup@ws1";
    };

    ws1-drone = {
      nets.nwvpn = {
        ip4.addr = "191.18.19.39";
        wireguard.pubkey = "KT8heQPAfjkG3GB3ssi1l5/utJ8QNTTMH+0lry4qtWQ=";
      };
    };

    ws1-osx = {
      # nets = {
      #   nwvpn = {
      #     ip4.addr = "changeme";
      #     aliases = [
      #       "ws1-osx.nw"
      #     ];
      #     wireguard.pubkey = "8UTtOGTG0yMxIwcW1Wx3qqyRhOtzVqlbvtM2518RDG8=";
      #   };
      # };
      # ssh.privkey.path = <secrets/ssh.id_ed25519>;
      # ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqUKOgdqxGRi1j1K+MlMO8PIc1qu5/awA3+0tRQBE2w ";
      # syncthing.id = "5DAUFLB-CABKC4I-QSKX66C-ZYIBND4-DMCFOAK-5YACRCH-I6U4DUY-XIVOIQ2";
      borg.quota = "250G";
      borg.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDnHw3Rr+9qGmEnjKmPvzh8rFi+2H8Ye4IEsyuoPWd1V enno@ws1-osx";
      syncthing.id = "L27FGVQ-K4CEIS4-6D24HBK-RIJKAR6-GCVAWO6-3KSIJW3-L7BZNBQ-7GGL2QC";
    };

    # kvm
    ws1-win10 =
      {
        syncthing.id = "UAFAYNS-NP6HYNY-JQ3CGPD-AUZHOEC-ZSEXAHP-PUOALXX-CNOMWWN-MVUKWQR";
      };

    ws1-win10n = {
      syncthing.id = "OSIS6BW-MSSUBOX-2ASRHPY-ZBI6LHV-LS6KIZ3-6ZBFDMZ-KPUY2HS-U7SP4QU";
    };

    ext-arvid = {
      syncthing.id = "Z7HYCDN-UQA4KQC-ZW6M4QG-2FQ3VVL-HPVIQYB-26OOJZM-2TO7FVN-OXKFBQX";
    };

    ext-stefan = {
      syncthing.id = "LRSIJOJ-VDYM3PR-RULNIWS-LFP4NO5-ENQNAEK-BMFLTVH-VG6BVCI-EJ27KQV";
    };
  };
}
