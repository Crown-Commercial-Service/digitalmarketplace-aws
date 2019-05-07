argsOuter@{...}:
let
  # specifying args defaults in this slightly non-standard way to allow us to include the default values in `args`
  args = rec {
    pkgs = import <nixpkgs> {};
    pythonPackages = pkgs.python36Packages;
    forDev = true;
    localOverridesPath = ./local.nix;
  } // argsOuter;
in (with args; {
  digitalMarketplaceAWSEnv = (pkgs.stdenv.mkDerivation rec {
    name = "digitalmarketplace-aws-env";
    shortName = "dm-aws";
    buildInputs = [
      pythonPackages.python
      pkgs.glibcLocales
      pkgs.nodejs
      pkgs.jq
      pkgs.sops
      (pkgs.terraform.overrideAttrs (oldAttrs: rec {
        name = "terraform-0.11.13";
        src = pkgs.fetchFromGitHub {
          owner  = "hashicorp";
          repo   = "terraform";
          rev    = "v0.11.13";
          sha256 = "014d2ibmbp5yc1802ckdcpwqbm5v70xmjdyh5nadn02dfynaylna";
        };
      }))
      pkgs.libyaml
      pkgs.libffi
      pkgs.cloudfoundry-cli
      ((import ./aws-auth.nix) (with pkgs; { inherit stdenv fetchFromGitHub makeWrapper jq awscli openssl; }))
    ] ++ pkgs.stdenv.lib.optionals forDev ([
      ] ++ pkgs.stdenv.lib.optionals pkgs.stdenv.isDarwin [
      ]
    );

    hardeningDisable = pkgs.stdenv.lib.optionals pkgs.stdenv.isDarwin [ "format" ];

    VIRTUALENV_ROOT = (toString (./.)) + "/venv${pythonPackages.python.pythonVersion}";
    VIRTUAL_ENV_DISABLE_PROMPT = "1";
    SOURCE_DATE_EPOCH = "315532800";

    # if we don't have this, we get unicode troubles in a --pure nix-shell
    LANG="en_GB.UTF-8";

    shellHook = ''
      export PS1="\[\e[0;36m\](nix-shell\[\e[0m\]:\[\e[0;36m\]${shortName})\[\e[0;32m\]\u@\h\[\e[0m\]:\[\e[0m\]\[\e[0;36m\]\w\[\e[0m\]\$ "

      if [ ! -e $VIRTUALENV_ROOT ]; then
        ${pythonPackages.python}/bin/python -m venv $VIRTUALENV_ROOT
      fi
      source $VIRTUALENV_ROOT/bin/activate
      make -C ${toString (./.)} requirements${pkgs.stdenv.lib.optionalString forDev "-dev"}
    '';
  }).overrideAttrs (if builtins.pathExists localOverridesPath then (import localOverridesPath args) else (x: x));
})
