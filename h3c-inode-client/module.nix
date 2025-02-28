{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.h3c-inode-client;
in
{
  options.services.h3c-inode-client = {
    enable = lib.mkEnableOption "H3C iNodeClient - ssl vpn client.";
    package = lib.mkPackageOption pkgs "h3c-inode-client" {
      default = pkgs.callPackage ./package.nix { };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."iNode/inodesys.conf".source = "${cfg.package}/etc/iNode/inodesys.conf";
    environment.systemPackages = [ cfg.package ];

    systemd.services.h3c-inode-client = {
      wantedBy = [
        "network-online.target"
        "graphical.target"
      ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "simple";
        RemainAfterExit = "yes";
        ExecStartPre = "${cfg.package}/bin/setup.sh";
        ExecStart = "${cfg.package}/bin/AuthenMngService";
        ExecStop = "${cfg.package}/bin/AuthenMngService -k";
      };
    };
  };
}
