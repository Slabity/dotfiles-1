{ config, ... }: {
  services.gogs = {
    enable = true;
    database = {
      type = "postgres";
      host = "/run/postgresql";
      port = 5432;
    };
    domain = "git.thalheim.io";
    rootUrl = "https://git.thalheim.io";
    extraConfig = ''
      [mailer]
      ENABLED = true
      FROM = gogs@thalheim.io
      USER = gogs@thalheim.io
      HOST = mail.thalheim.io:587
      PASSWD = #dbpass#

      [service]
      DISABLE_REGISTRATION = true
    '';
  };

  services.nginx = {
    virtualHosts."git.thalheim.io" = {
      useACMEHost = "thalheim.io";
      forceSSL = true;
      locations."/".extraConfig = ''
        proxy_pass http://localhost:3000;
      '';
    };
  };

  services.netdata.httpcheck.checks.gogs = {
    url = "https://git.thalheim.io";
    regex = "Gogs";
  };

  services.openldap.extraConfig = ''
    objectClass ( 1.3.6.1.4.1.28293.1.2.4 NAME 'gitlab'
            SUP uidObject AUXILIARY
            DESC 'Added to an account to allow gitlab access'
            MUST (mail) )
  '';

  # for database key
  systemd.services.gogs.serviceConfig.SupplementaryGroups = [ "keys" ];
}
