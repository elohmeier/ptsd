{
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.ssh-tpm-agent ];

  home.sessionVariablesExtra = ''
    if [[ -z "SSH_AUTH_SOCK" ]]; then
      export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-tpm-agent.sock
    fi
  '';

  systemd.user.services.ssh-tpm-agent = {
    Unit = {
      ConditionEnvironment = "!SSH_AGENT_PID";
      Description = "ssh-tpm-agent service";
      Documentation = "man:ssh-agent(1) man:ssh-add(1) man:ssh(1)";
      Requires = "ssh-tpm-agent.socket";
    };

    Service = {
      Environment = "SSH_TPM_AUTH_SOCK=%t/ssh-tpm-agent.sock";
      ExecStart = "${pkgs.ssh-tpm-agent}/bin/ssh-tpm-agent";
      PassEnvironment = "SSH_AGENT_PID";
      SuccessExitStatus = 2;
      Type = "simple";
    };

    Install.Also = "ssh-agent.socket";
  };

  systemd.user.sockets.ssh-tpm-agent = {
    Unit = {
      Description = "SSH TPM agent socket";
      Documentation = "man:ssh-agent(1) man:ssh-add(1) man:ssh(1)";
    };

    Socket = {
      ListenStream = "%t/ssh-tpm-agent.sock";
      SocketMode = "0600";
      Service = "ssh-tpm-agent.service";
    };

    Install.WantedBy = [ "sockets.target" ];
  };
}
