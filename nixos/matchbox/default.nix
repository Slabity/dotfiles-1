
let
  krops = (import <nixpkgs> {}).callPackage ../krops.nix {};
  lib = import "${krops}/lib";
  pkgs = import "${krops}/pkgs" {};

  source = lib.evalSource [{
    nixpkgs.file = {
      path = toString <nixpkgs>;
      exclude = [ ".git" ];
    };
    dotfiles.file = {
      path = toString ./../..;
      exclude = [ ".git" ];
    };
    nixos-config.symlink = "dotfiles/nixos/matchbox/configuration.nix";

    secrets.pass = {
      dir  = toString ../secrets/joerg;
      name = "matchbox";
    };

    shared-secrets.pass = {
      dir  = toString ../secrets/shared;
      name = "shared";
    };
  }];
in pkgs.krops.writeDeploy "deploy" {
  source = source;
  buildTarget = "joerg@localhost";
  crossDeploy = true;
  target = "root@matchbox.r";
}