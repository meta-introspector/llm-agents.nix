{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.iptables-capture
    pkgs.proxy-qos
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

  systemd.timers.proxy-qos = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2m";
      OnUnitActiveSec = "5m";
      Unit = "proxy-qos.service";
    };
  };

  systemd.services.proxy-qos = {
    description = "Record proxy QoS metrics";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.proxy-qos}/bin/proxy-qos";
    };
  };
}
