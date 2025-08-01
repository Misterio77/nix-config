# Forked from upstream
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    filterAttrs
    getAttrs
    mapAttrs
    mapAttrs'
    mapAttrsToList
    ;

  cfg = config.programs.vdirsyncer;

  vdirsyncerCalendarAccounts = filterAttrs (_: v: v.vdirsyncer.enable) (
    mapAttrs' (n: v: lib.nameValuePair ("calendar_" + n) v) config.accounts.calendar.accounts
  );

  vdirsyncerContactAccounts = filterAttrs (_: v: v.vdirsyncer.enable) (
    mapAttrs' (n: v: lib.nameValuePair ("contacts_" + n) v) config.accounts.contact.accounts
  );

  vdirsyncerAccounts = vdirsyncerCalendarAccounts // vdirsyncerContactAccounts;

  wrap = s: ''"${s}"'';

  listString = l: "[${concatStringsSep ", " l}]";

  localStorage =
    a:
    filterAttrs (_: v: v != null) (
      (getAttrs [ "type" "fileExt" "encoding" ] a.local)
      // {
        path = a.local.path;
        postHook =
          if a.vdirsyncer.postHook != null then
            (pkgs.writeShellScriptBin "post-hook" a.vdirsyncer.postHook + "/bin/post-hook")
          else
            null;
      }
    );

  remoteStorage =
    a:
    filterAttrs (_: v: v != null) (
      (getAttrs [ "type" "url" "userName" "passwordCommand" ] a.remote)
      // (
        if a.vdirsyncer == null then
          { }
        else
          getAttrs [
            "urlCommand"
            "userNameCommand"
            "itemTypes"
            "verify"
            "verifyFingerprint"
            "auth"
            "authCert"
            "userAgent"
            "tokenFile"
            "clientIdCommand"
            "clientSecretCommand"
            # ADDED
            "accessTokenCommand"
            # END ADDED
            "timeRange"
          ] a.vdirsyncer
      )
    );

  pair =
    a:
    filterAttrs (k: v: k == "collections" || (v != null && v != [ ])) (
      getAttrs [ "collections" "conflictResolution" "metadata" "partialSync" ] a.vdirsyncer
    );

  pairs = mapAttrs (_: v: pair v) vdirsyncerAccounts;
  localStorages = mapAttrs (_: v: localStorage v) vdirsyncerAccounts;
  remoteStorages = mapAttrs (_: v: remoteStorage v) vdirsyncerAccounts;

  optionString =
    n: v:
    if (n == "type") then
      ''type = "${v}"''
    else if (n == "path") then
      ''path = "${v}"''
    else if (n == "fileExt") then
      ''fileext = "${v}"''
    else if (n == "encoding") then
      ''encoding = "${v}"''
    else if (n == "postHook") then
      ''post_hook = "${v}"''
    else if (n == "url") then
      ''url = "${v}"''
    else if (n == "urlCommand") then
      "url.fetch = ${listString (map wrap ([ "command" ] ++ v))}"
    else if (n == "timeRange") then
      ''
        start_date = "${v.start}"
        end_date = "${v.end}"''
    else if (n == "itemTypes") then
      "item_types = ${listString (map wrap v)}"
    else if (n == "userName") then
      ''username = "${v}"''
    else if (n == "userNameCommand") then
      "username.fetch = ${listString (map wrap ([ "command" ] ++ v))}"
    else if (n == "password") then
      ''password = "${v}"''
    else if (n == "passwordCommand") then
      "password.fetch = ${listString (map wrap ([ "command" ] ++ v))}"
    else if (n == "passwordPrompt") then
      ''password.fetch = ["prompt", "${v}"]''
    else if (n == "verify") then
      ''verify = "${v}"''
    else if (n == "verifyFingerprint") then
      ''verify_fingerprint = "${v}"''
    else if (n == "auth") then
      ''auth = "${v}"''
    else if (n == "authCert" && lib.isString v) then
      ''auth_cert = "${v}"''
    else if (n == "authCert") then
      "auth_cert = ${listString (map wrap v)}"
    else if (n == "userAgent") then
      ''useragent = "${v}"''
    else if (n == "tokenFile") then
      ''token_file = "${v}"''
    else if (n == "clientId") then
      ''client_id = "${v}"''
    else if (n == "clientIdCommand") then
      "client_id.fetch = ${listString (map wrap ([ "command" ] ++ v))}"
    else if (n == "clientSecret") then
      ''client_secret = "${v}"''
    else if (n == "clientSecretCommand") then
      "client_secret.fetch = ${listString (map wrap ([ "command" ] ++ v))}"
    # ADDED
    else if (n == "accessToken") then
      ''access_token = "${v}"''
    else if (n == "accessTokenCommand") then
      "access_token.fetch = ${listString (map wrap ([ "command" ] ++ v))}"
    # END ADDED
    else if (n == "metadata") then
      "metadata = ${listString (map wrap v)}"
    else if (n == "partialSync") then
      ''partial_sync = "${v}"''
    else if (n == "collections") then
      let
        contents = map (c: if (lib.isString c) then ''"${c}"'' else listString (map wrap c)) v;
      in
      "collections = ${if ((isNull v) || v == [ ]) then "null" else listString contents}"
    else if (n == "conflictResolution") then
      if v == "remote wins" then
        ''conflict_resolution = "a wins"''
      else if v == "local wins" then
        ''conflict_resolution = "b wins"''
      else
        "conflict_resolution = ${listString (map wrap ([ "command" ] ++ v))}"
    else
      throw "Unrecognized option: ${n}";

  attrsString = a: concatStringsSep "\n" (mapAttrsToList optionString a);

  pairString = n: v: ''
    [pair ${n}]
    a = "${n}_remote"
    b = "${n}_local"
    ${attrsString v}
  '';

  configFile = pkgs.writeText "config" ''
    [general]
    status_path = "${cfg.statusPath}"

    ### Pairs

    ${concatStringsSep "\n" (mapAttrsToList pairString pairs)}

    ### Local storages

    ${concatStringsSep "\n\n" (
      mapAttrsToList (n: v: "[storage ${n}_local]" + "\n" + attrsString v) localStorages
    )}

    ### Remote storages

    ${concatStringsSep "\n\n" (
      mapAttrsToList (n: v: "[storage ${n}_remote]" + "\n" + attrsString v) remoteStorages
    )}
  '';

in
{
  disabledModules = ["programs/vdirsyncer"];
  imports = [
    (inputs.home-manager + "/modules/programs/vdirsyncer/accounts.nix")
  ];

  options = {
    programs.vdirsyncer = {
      enable = lib.mkEnableOption "vdirsyncer";

      package = lib.mkPackageOption pkgs "vdirsyncer" { };

      statusPath = lib.mkOption {
        type = lib.types.str;
        default = "${config.xdg.dataHome}/vdirsyncer/status";
        defaultText = "$XDG_DATA_HOME/vdirsyncer/status";
        description = ''
          A directory where vdirsyncer will store some additional data for the next sync.

          For more information, see the
          [vdirsyncer manual](https://vdirsyncer.pimutils.org/en/stable/config.html#general-section).
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions =
      let

        mutuallyExclusiveOptions = [
          [
            "url"
            "urlCommand"
          ]
          [
            "userName"
            "userNameCommand"
          ]
        ];

        requiredOptions =
          t:
          if (t == "caldav" || t == "carddav" || t == "http") then
            [ "url" ]
          else if (t == "filesystem") then
            [
              "path"
              "fileExt"
            ]
          else if (t == "singlefile") then
            [ "path" ]
          else if (t == "google_calendar" || t == "google_contacts") then
            [
            ]
          else
            throw "Unrecognized storage type: ${t}";

        allowedOptions =
          let
            remoteOptions = [
              "urlCommand"
              "userName"
              "userNameCommand"
              "password"
              "passwordCommand"
              "passwordPrompt"
              "verify"
              "verifyFingerprint"
              "auth"
              "authCert"
              "userAgent"
            ];
          in
          t:
          if (t == "caldav") then
            [
              "timeRange"
              "itemTypes"
            ]
            ++ remoteOptions
          else if (t == "carddav" || t == "http") then
            remoteOptions
          else if (t == "filesystem") then
            [
              "fileExt"
              "encoding"
              "postHook"
            ]
          else if (t == "singlefile") then
            [ "encoding" ]
          else if (t == "google_calendar") then
            [
              "timeRange"
              "itemTypes"
              "tokenFile"
              "clientId"
              "clientSecret"
              "clientIdCommand"
              "clientSecretCommand"
              # ADDED
              "accessTokenCommand"
              # END ADDED
            ]
          else if (t == "google_contacts") then
            [
              "clientIdCommand"
              "clientSecretCommand"
              # ADDED
              "accessTokenCommand"
              # END ADDED
            ]
          else
            throw "Unrecognized storage type: ${t}";

        assertStorage =
          n: v:
          let
            allowed = allowedOptions v.type ++ (requiredOptions v.type);
          in
          mapAttrsToList
            (
              a: v':
              [
                {
                  assertion = (lib.elem a allowed);
                  message = ''
                    Storage ${n} is of type ${v.type}. Option
                    ${a} is not allowed for this type.
                  '';
                }
              ]
              ++ (
                let
                  required = lib.filter (a: !lib.hasAttr "${a}Command" v) (requiredOptions v.type);
                in
                map (a: [
                  {
                    assertion = lib.hasAttr a v;
                    message = ''
                      Storage ${n} is of type ${v.type}, but required
                      option ${a} is not set.
                    '';
                  }
                ]) required
              )
              ++ map (
                attrs:
                let
                  defined = lib.attrNames (filterAttrs (n: v: v != null) (lib.genAttrs attrs (a: v.${a} or null)));
                in
                {
                  assertion = lib.length defined <= 1;
                  message = "Storage ${n} has mutually exclusive options: ${concatStringsSep ", " defined}";
                }
              ) mutuallyExclusiveOptions
            )
            (
              removeAttrs v [
                "type"
                "_module"
              ]
            );

        storageAssertions =
          lib.flatten (mapAttrsToList assertStorage localStorages)
          ++ lib.flatten (mapAttrsToList assertStorage remoteStorages);

      in
      storageAssertions;
    home.packages = [ cfg.package ];
    xdg.configFile."vdirsyncer/config".source = configFile;
  };
}

