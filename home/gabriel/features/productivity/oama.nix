{config, ...}: let
  pass = "${config.programs.password-store.package}/bin/pass";
in {
  programs.oama = {
    enable = true;
    settings = {
      encryption.tag = "KEYRING";
      services.google = {
        client_id_cmd = "${pass} oama/google_client_id | head -1";
        client_secret_cmd = "${pass} oama/google_client_secret | head -1";
        auth_scope = "https://mail.google.com/ https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/contacts";
        access_type = "offline";
      };
    };
  };
}
