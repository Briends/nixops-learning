{
  description = "nixops quick hack learning";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    devenv.url = "github:cachix/devenv";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    nix2container.url = "github:nlewo/nix2container";
  };

  nixConfig = {
    extra-trusted-public-keys = ''
      devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
    '';
    extra-substituters = ''
      https://devenv.cachix.org
    '';
    allow-broken = true;
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:

    (flake-parts.lib.evalFlakeModule 
      { inherit self inputs; }
      {
        systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

        imports = [
          inputs.devenv.flakeModule
        ];

        perSystem = { config, self', inputs', pkgs, system, lib, ... }:
        {
            _module.args.pkgs = import nixpkgs { config.allowUnfree = true; inherit system; };

            devenv.shells.default = {
              languages.nix.enable = true;
        
              packages = with pkgs; [
                nixops_unstable
              ];

            };
        };
      }).config.flake;
}

