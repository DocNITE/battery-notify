{
  description = "Battery Power Level Alert";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.battery-alert = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in pkgs.stdenv.mkDerivation {
      name = "battery-alert";
      src = ./.;

      buildPhase = ''
        gcc -o battery_alert battery_alert.c
      '';

      installPhase = ''
        mkdir -p $out/bin
        cp battery_alert $out/bin/
      '';
    };

    nixosModules.battery-alert = { config, lib, pkgs, ... }: {
      options = {
        services.battery-alert = {
          enable = lib.mkEnableOption "Enable battery power level alert service";
          threshold = lib.mkOption {
            type = lib.types.int;
            default = 20;
            description = "Battery level threshold for alert (in percentage)";
          };
          interval = lib.mkOption {
            type = lib.types.str;
            default = "1min";
            description = "Interval at which to check the battery level";
          };
        };
      };

      config = lib.mkIf config.services.battery-alert.enable {
        systemd.services.battery-alert = {
          description = "Battery Power Level Alert Service";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${self.packages.x86_64-linux.battery-alert}/bin/battery_alert";
          };
        };

        systemd.timers.battery-alert = {
          description = "Run Battery Alert Periodically";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = config.services.battery-alert.interval;
            OnUnitActiveSec = config.services.battery-alert.interval;
            Unit = "battery-alert.service";
          };
        };
      };
    };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.battery-alert;
  };
}
