{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.iptables-capture
    pkgs.rustnet
  ];

  systemd.services.iptables-capture-install = {
    description = "Install transparent iptables capture rules";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.iptables-capture}/bin/iptables-capture install";
      RemainAfterExit = true;
    };
  };
}
