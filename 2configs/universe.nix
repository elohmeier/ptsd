{
  nwvpn = {
    # fb1: 192.168.178.1
    # fb2: 192.168.178.2
    # arc1 = {}; # Archer C7 v5  192.168.178.3
    mb1 = {
      ip = "191.18.19.1";
      publicKey = "3SL8LpzYj4cncLpx3CEqOCmsQaJ45j9G51g41YNU+kw=";
    };
    nuc1 = {
      ip = "191.18.19.10";
      publicKey = "dcBlwkidRDhcQT6OaqZS1wM9jUMdWS7iZy8+1534hDw=";
    };
    apu1 = {
      ip = "191.18.19.11";
      publicKey = "t6zE4F6k5PjaSyUU69iDJbK3eVXy+7jgeSuV2+cfGWA=";
    };
    rpi1 = {
      ip = "191.18.19.13";
      publicKey = "DtNG2BXRCww/p140Cpme4UyE5ZTAxyh0fMi9a9lplHs=";
    };
    iph1 = {
      ip = "191.18.19.15"; # 8+
      publicKey = "xs4hm1bIlQ5eB5JsjbVetOvsJZ8MSVO8jSQgIpcJcy0=";
    };
    and1 = {
      ip = "191.18.19.21"; # Moto G
      publicKey = "40c+WrVo8IXU+OMA/+6Z4otbtePu0vtucafyfQ4+YAo=";
    };
    tp1 = {
      ip = "191.18.19.30"; # TP X280
      publicKey = "y6NCfYWUCR6aqoLsjqQRbfhz7rLqrtUOnY3HTWa0HFI=";
    };
    eee1 = {
      ip = "191.18.19.31"; # Oma
      publicKey = "GRjSScIwM2VBYpLkl5L9iThvJ2YNYiNWZPBND9eniBU=";
    };
    htz1 = {
      ip = "191.18.19.32";
      publicKey = "UeAoj/VLCmoWLGjAkFRXYLYeac/tLM2itmkq4GKz0zg=";
    };
    iph2 = {
      ip = "191.18.19.33"; # Lu
      publicKey = "BJD/QMJ/hF2opW+tVGYFjdY14+y60QQQlP6X5bdgK1w=";
    };
    apu2 = {
      ip = "191.18.19.34"; # DLRG
      publicKey = "eQXHytFmxA8HyECId+vVaTOVE9iCaWV7KVGs5ps6glQ=";
      networks = [ "192.168.168.0/24" ];
    };
    rpi2 = {
      ip = "191.18.19.35"; # DLRG
      publicKey = "BoZpusHOB9dNMFvnpwV2QitB0ejJEDAhEUPv+uI9iFo=";
      networks = [ "192.168.178.0/24" ];
    };
    htz2 = {
      ip = "191.18.19.36";
      publicKey = "dLfyCkEPM2bDwcO2JEYBv772dXX+JM6bsnSpttaN0gs=";
    };
    nas1 = {
      ip = "191.18.19.37";
      publicKey = "52uBY3v3s7JE74MRVLepEx8vQliKCpzZteGXG0EhNGU=";
    };
    #rpi3 = {
    # RPi-HomeMatic      
    #};
    ws1 = {
      ip = "191.18.19.80";
      publicKey = "yvrstaKyRf0fyJi9BpGWkL/BWt6XYArIzygJ410SxR0=";
    };
  };

  # not used yet
  hosts = {
    apu1 = {
      cores = 2;
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
    };

    apu2 = {
      cores = 2;
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.34";
          aliases = [
            "apu2.nw"
          ];
          wireguard.pubkey = ''
            eQXHytFmxA8HyECId+vVaTOVE9iCaWV7KVGs5ps6glQ=
          '';
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM8kcXGoM6iZJy6Q/EHl+i2oXvMvzepeilNqM9a/otYu ";
    };

    eee1 = {
      cores = 2;
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
    };

    htz1 = {
      cores = 1;
      nets = {
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
    };

    htz2 = {
      cores = 1;
      nets = {
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
    };

    nas1 = {
      cores = 4;
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.37";
          aliases = [
            "nas1.nw"
          ];
          wireguard.pubkey = ''
            52uBY3v3s7JE74MRVLepEx8vQliKCpzZteGXG0EhNGU=
          '';
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPzSELiOpE3nCNPSeylax/W3UfXbzSBVQ3mqjHBz/yPy ";
    };


    nuc1 = {
      cores = 4;
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
    };

    rpi2 = {
      cores = 1;
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.35";
          aliases = [
            "rpi2.nw"
          ];
          wireguard.pubkey = ''
            BoZpusHOB9dNMFvnpwV2QitB0ejJEDAhEUPv+uI9iFo=
          '';
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDQw7ZYiuLCgx6ISk5GdrNBLg78HTstQapro/W7nodyV ";
    };

    tp1 = {
      cores = 8;
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.30";
          aliases = [
            "tp1.nw"
          ];
          wireguard.pubkey = ''
            y6NCfYWUCR6aqoLsjqQRbfhz7rLqrtUOnY3HTWa0HFI=
          '';
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOhX8m3f1fpboga+H/uZeCUawyqur2dNBZwK6+ZaAlj ";
    };

    ws1 = {
      cores = 24;
      nets = {
        nwvpn = {
          ip4.addr = "191.18.19.80";
          aliases = [
            "ws1.nw"
          ];
          wireguard.pubkey = ''
            yvrstaKyRf0fyJi9BpGWkL/BWt6XYArIzygJ410SxR0=
          '';
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxl5cu7JzupBVvcuT7hpAD2aPqGCDDV8ergHqeFinem ";
    };
  };
}
