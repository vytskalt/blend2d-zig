{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    zls = {
      url = "github:zigtools/zls?rev=a26718049a8657d4da04c331aeced1697bc7652b"; # 0.13.0 release
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        zig-overlay.follows = "zig-overlay";
      };
    };
  };

  outputs = { nixpkgs, zig-overlay, zls, ... }:
  let
    forAllSystems = function:
      nixpkgs.lib.genAttrs (builtins.attrNames zig-overlay.packages) (system:
        function (import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              zig-pkgs = zig-overlay.packages.${prev.system};
              zls-pkgs = zls.packages.${prev.system};
            })
          ];
        }));
  in rec {
    packages = forAllSystems (pkgs: {
      devshell = devShells.${pkgs.system}.default.inputDerivation;
    });

    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          zig-pkgs.default
          zls-pkgs.zls
        ];
      };
    });
  };
}
