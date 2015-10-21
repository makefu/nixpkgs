{ config, lib, pkgs, ... }:

with lib;
let
  gunicorn = pkgs.pythonPackages.gunicorn;
  bepasty = pkgs.pythonPackages.bepasty-server;
  gevent = pkgs.pythonPackages.gevent;
  python = pkgs.pythonPackages.python;
  cfg = config.services.bepasty;
  user = "bepasty";
  group = "bepasty";
  default_home = "/var/lib/bepasty";
in
{
  options.services.bepasty = {
    enable = mkEnableOption "enable configured Bepasty Servers";

    servers = mkOption {
      default = {};
      description = ''
        configure a number of bepasty servers which will be started with
        gunicorn.
      '';
      type = with types ; attrsOf (submodule ({
        options = {
          bind = mkOption {
            type = types.str;
            description = ''
              Bind address to be used for this server.
            '';
            example = "0.0.0.0:8000";
            default = "127.0.0.1:8000";
          };

          secretKey = mkOption {
            type = types.str;
            description = ''
              server secret for safe session cookies, must be set.
            '';
            default = "";
          };

          workDir = mkOption {
            type = types.str;
            description = ''
              Path to the working directory (used for sockets and pidfile).
              Defaults to the users home directory. Must be accessible to nginx,
              permissions will be set to 755
            '';
            default = default_home ;
          };

          dataDir = mkOption {
            type = types.str;
            description = ''
              Defaults to the new users home dir which defaults to
              /var/lib/bepasty/data
              '';
            default = default_home+"/data";
          };


          defaultPermissions = mkOption {
            # TODO: listOf str
            type = types.str;
            description = ''
            default permissions for all unauthenticated users.
            '';
            example = "read,create,delete";
            default = "read";
          };

          extraConfig = mkOption {
            type = types.str;
            description = ''
              Extra configuration for bepasty server to be appended on the
              confugration.
            '';
            default = "";
            # TODO configure permissions in separate
            example = ''
              PERMISSIONS = {
                'myadminsecret': 'admin,list,create,read,delete',
              }
              MAX_ALLOWED_FILE_SIZE = 5 * 1000 * 1000
              '';
          };
        };
      }));
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ bepasty ];
    # creates gunicorn systemd service for each configured server
    systemd.services = mapAttrs' (name: server:
      nameValuePair ("bepasty-server-${name}-gunicorn")
        ({
          description = "Bepasty Server ${name}";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          restartIfChanged = true;
          environment = {
            BEPASTY_CONFIG = "${server.workDir}/bepasty-${name}.conf";
            PYTHONPATH= "${bepasty}/lib/${python.libPrefix}/site-packages:${gevent}/lib/${python.libPrefix}/site-packages";
          };
          serviceConfig = {
            Type = "simple";
            PrivateTmp = true;
            PermissionsStartOnly = true;
            ExecStartPre = assert server.secretKey != ""; pkgs.writeScript "bepasty-server.${name}-init" ''
              #!/bin/sh
              mkdir -p "${server.workDir}"
              mkdir -p "${server.dataDir}"
              chown ${user}:${group} "${server.workDir}" "${server.dataDir}"
              cat > ${server.workDir}/bepasty-${name}.conf <<EOF
              SITENAME="${name}"
              STORAGE_FILESYSTEM_DIRECTORY="${server.dataDir}"
              SECRET_KEY="${server.secretKey}"
              DEFAULT_PERMISSIONS="${server.defaultPermissions}"
              ${server.extraConfig}
              EOF
            '';
            ExecStart = ''${gunicorn}/bin/gunicorn bepasty.wsgi --name ${name} \
              -u bepasty \
              -g bepasty \
              --workers 3 --log-level=info \
              --bind=${server.bind} \
              --pid ${server.workDir}/gunicorn-${name}.pid \
              -k gevent
            '';
          };
        })
    ) cfg.servers;

    users.extraUsers = [{
      uid = config.ids.uids.bepasty;
      name = user;
      group = group;
      home = default_home;
    }];

    users.extraGroups = [
      { name = group;
        gid = config.ids.gids.bepasty;
      } ];
  };
}
