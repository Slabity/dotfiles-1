{ pkgs, lib, ... }:
let
  path = lib.makeBinPath ([
    pkgs.coreutils
    pkgs.utillinux
    pkgs.nodePackages_latest.bitwarden-cli
    pkgs.systemd
    pkgs.gnused
  ]);
  askpass = "${pkgs.gnome3.seahorse}/libexec/seahorse/ssh-askpass";
  bw = pkgs.writeScriptBin "bw" ''
    #!${pkgs.runtimeShell}
    export PATH=${path};
    token_file=/run/user/$(id -u)/bw-token
    lock_file=/run/user/$(id -u)/bw-token.lock

    export DISPLAY="$(systemctl --user show-environment | sed 's/^DISPLAY=\(.*\)/\1/; t; d')"

    if [[ -e "$token_file" ]]; then
      export BW_SESSION=$(<"$token_file")
    else
      exec 9>"$lock_file"
      while ! flock -n 9; do
        sleep 1
      done
      if [[ -e "$token_file" ]]; then
        export BW_SESSION=$(<"$token_file")
      else
        for i in $(seq 1 4); do
          password=$(${askpass} "bitwarden (try $i/4)")
          export BW_SESSION=$(bw unlock --raw "$password")
          if [[ "$BW_SESSION" != "" ]]; then
            echo "$BW_SESSION" > "$token_file"
            break
          fi
        done
      fi
    fi

    exec bw "$@"
  '';
in {
  home.packages = with pkgs; [ bw ];
}
