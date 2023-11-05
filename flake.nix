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
                nix
                nixops_unstable
              ];

            };
        };
      }).config.flake // { 
        nixopsConfigurations.default = 
          let
            domain = "${credentials.project}.briends.com";
            keyjson = builtins.fromJSON (builtins.readFile "/Users/jloos/Developer/nixops-learning/ai-playground-c437-707226309d66.json");
            credentials = {
              project = keyjson.project_id;
              serviceAccount = keyjson.client_email;
              accessKey = keyjson.private_key;
            };
          
          in {
            inherit nixpkgs;
            network.description = domain;
            network.storage.legacy.databasefile = "./deployments.nixops";
            
            resources.gceNetworks.web = credentials // {
              firewall = {
                allow-http = {
                  allowed.tcp = [ 80 ];
                  sourceRanges =  ["0.0.0.0/0"];
                };
                allow-ssh = {
                  allowed.tcp = [ 22 ];
                  sourceRanges =  ["0.0.0.0/0"];
                };
              };
            };

            defaults._module.args = {
              inherit domain credentials;
            };
            
            hello = import ./hello-world.nix;
          };
      };
}

