{
  nwvpn = {
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
    # TODO: implement filter in htz1.nix
    #htz1 = {
    #    ip ="191.18.19.32";
    #    publicKey = "UeAoj/VLCmoWLGjAkFRXYLYeac/tLM2itmkq4GKz0zg=";
    #};
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
    rpi3 = { # RPi-HomeMatic      
    };
    ws1 = {
      ip = "191.18.19.80";
      publicKey = "yvrstaKyRf0fyJi9BpGWkL/BWt6XYArIzygJ410SxR0=";
    };
  };
}
