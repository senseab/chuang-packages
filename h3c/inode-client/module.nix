{
  lib,
  config,
  pkgs-chuang,
  ...
}:
let
  cfg = config.services.h3c-inode-client;
in
{
  options.services.h3c-inode-client = {
    enable = lib.mkEnableOption "H3C iNodeClient - ssl vpn client.";
    package = lib.mkPackageOption pkgs-chuang "h3c.inode-client" {
      pkgsText = "pkgs-chuang";
      default = [
        "h3c"
        "inode-client"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."iNode/inodesys.conf".source = "${cfg.package}/etc/iNode/inodesys.conf";
    environment.systemPackages = [ cfg.package ];

    systemd.services.h3c-inode-client =
      let
        target = "network-online.target";
      in
      {
        wants = [ target ];
        after = [ target ];
        serviceConfig = {
          Type = "simple";
          RemainAfterExit = "yes";
          ExecStartPre = "${cfg.package}/bin/setup";
          ExecStart = "${cfg.package}/bin/AuthenMngService";
          ExecStop = "${cfg.package}/bin/AuthenMngService -k";
        };
      };
  };
}
