{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs { }
}:

with pkgs;
let
  inherit (lib) optional optionals;

  basePackages = [
    (import ./nix/default.nix { inherit pkgs; })
    pkgs.niv
  ];

  inputs =  basePackages ++ lib.optionals stdenv.isLinux [ inotify-tools ]
    ++ lib.optionals stdenv.isDarwin
    (with darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices ]);

  hooks = ''
    mkdir -p .nix-mix .nix-hex .livebook
    export MIX_HOME=$PWD/.nix-mix
    export HEX_HOME=$PWD/.nix-hex

    export MIX_PATH="${beam.packages.erlangR25.hex}/lib/erlang/lib/hex/ebin"
    export PATH=${erlangR25}/bin:$MIX_HOME/bin:$HEX_HOME/bin:$MIX_HOME/escripts:bin:$PATH

    export LANG=C.UTF-8
    # keep your shell history in iex
    export ERL_AFLAGS="-kernel shell_history enabled"

    export MIX_ENV=dev
  '';
in

mkShell {
  buildInputs = inputs;
  shellHook = hooks;

  LOCALE_ARCHIVE = if pkgs.stdenv.isLinux then "${pkgs.glibcLocales}/lib/locale/locale-archive" else "";
}
