{ ... }:

{
  services.asterisk = {
    enable = true;
    confFiles = {
      "extensions.conf" = ''
        [tests]
        ; Dial 100 for "hello, world"
        exten =>     0541100,1,Answer()
        same  =>     n,Wait(1)
        same  =>     n,Playback(hello-world)
        same  =>     n,Hangup()

        [softphones]
        :exten => _X.,1,Dial(Local/Mobil@gateways,50,o)
        include => tests

        [internal]
        include => tests
        
        [unauthorized]

        ;[incomming]
        ;exten => _X.,1,Dial(Local/Mobil@gateways,50,o)

        ;[gateways]
        ;exten => Mobil,1,Set(CALLERID(name)=49''${CALLERID(number):1})
        ;exten => Mobil,2,Set(CALLERID(number)=49''${CALLERID(number):1})
        ;exten => Mobil,3,Dial(SIP/dlrgogos@192.168.178.1)
      '';

      "pjsip.conf" = ''
        [simpletrans]
        type=transport
        protocol=udp
        bind=192.168.168.41
        
        [dlrgogos]
        type = endpoint
        context = internal
        disallow = all
        allow = ulaw
        aors = dlrgogos
        auth = authdlrgogos

        [dlrgogos]
        type = aor
        max_contacts = 1

        [authdlrgogos]
        type=auth
        auth_type=userpass
        password=XXXXXXXXXXXXXXXXXXXXXXXX
        username=dlrgogos

        [transport-udp-nat]
        type=transport
        protocol=udp
        bind=192.168.178.201
        ;local_net=192.168.178.0/24
        ;external_media_address=192.168.178.201
        ;external_signaling_address=192.168.178.201

        ;===============TRUNK
 
        [mytrunk]
        type=registration
        transport=transport-udp-nat
        outbound_auth=mytrunk
        server_uri=sip:192.168.178.1
        client_uri=sip:dlrgogos@192.168.178.1
        retry_interval=60
        
        [mytrunk]
        type=auth
        auth_type=userpass
        password=XXXXXXXXXXXXXXXXXXXXXXXX
        username=dlrgogos
        
        [mytrunk]
        type=aor
        contact=sip:192.168.178.1:5060
        
        [mytrunk]
        type=endpoint
        transport=transport-udp-nat
        context=from-external
        disallow=all
        allow=ulaw
        outbound_auth=mytrunk
        aors=mytrunk
        
        [mytrunk]
        type=identify
        endpoint=mytrunk
        match=192.168.178.1
      '';
    };
  };
}
