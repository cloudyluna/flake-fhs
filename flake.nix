{
  description = ''
    A nix flake for setting up Linux's File Hierarchy System (FHS) environment.
    This enables user to download a pre-compiled executables, compiled from another
    Linux systems and run them as if they were natively produced on another NixOS system.
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        fhs = pkgs.buildFHSEnv {
          name = "flake-fhs";
          targetPkgs = (
            let
              XPackages = with pkgs.xorg; [
                libX11
                libXcursor
                libXext
                libXi
                libXinerama
                libXrandr
              ];
              commonPackages = with pkgs; [
                cmake
                automake
                autoconf
                gnumake
                pkg-config
                wayland
                openssl
                clang
                lldb
                valgrind
              ];
            in
            pkgs:
            [
            ]
            ++ XPackages
            ++ commonPackages
          );
        };

      in
      {
        devShells.default = fhs.env;
      }
    );
}
